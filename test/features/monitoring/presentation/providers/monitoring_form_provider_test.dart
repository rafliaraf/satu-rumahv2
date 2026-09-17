import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:satu_rumah/features/dashboard/presentation/providers/admin_dashboard_provider.dart';
import 'package:satu_rumah/features/monitoring/data/models/monitoring_model.dart';
import 'package:satu_rumah/features/monitoring/data/models/status_hasil_evaluasi.dart';
import 'package:satu_rumah/features/monitoring/data/repositories/monitoring_repository.dart';
import 'package:satu_rumah/features/monitoring/presentation/providers/monitoring_form_provider.dart';
import 'package:satu_rumah/features/notifikasi/presentation/providers/notifikasi_provider.dart';
import 'package:satu_rumah/features/pengajuan/data/models/status_tahap_pengajuan.dart';
import 'package:satu_rumah/features/pengajuan/presentation/providers/pengajuan_form_controller.dart';
import 'package:satu_rumah/features/pengajuan/presentation/providers/pengajuan_verifikasi_controller.dart';

MonitoringModel _draft({
  String id = 'monitoring-submit-1',
  String? pengajuanId = 'SR-20260720-612',
  StatusHasilEvaluasi status = StatusHasilEvaluasi.sesuaiSiteplan,
  List<String> rtl = const [],
}) {
  return MonitoringModel(
    id: id,
    pengajuanId: pengajuanId,
    tanggalMonitoring: DateTime(2026, 8, 19),
    namaPerumahan: 'Green Tasik',
    namaDeveloper: 'PT. Tasik Indah Sentosa',
    lokasiPerumahan: 'Kota Tasikmalaya',
    statusHasilEvaluasi: status,
    rencanaTindakLanjut: rtl,
    isDraft: true,
  );
}

void main() {
  test(
    'final submission synchronizes one report, BA history, and notification',
    () {
      final repository = MonitoringRepository();
      final container = ProviderContainer(
        overrides: [monitoringRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      final notifier = container.read(monitoringFormProvider.notifier);
      final result = notifier.submitFinal(_draft());

      expect(result.status, MonitoringSubmitStatus.success);
      expect(result.model?.isDraft, isFalse);
      expect(
        repository.getAllMonitoring().where(
          (item) => item.id == 'monitoring-submit-1',
        ),
        hasLength(1),
      );

      final pengajuan = container
          .read(pengajuanListProvider)
          .singleWhere((item) => item.id == 'SR-20260720-612');
      expect(pengajuan.beritaAcaraPath, isNotEmpty);
      final submittedHistory = pengajuan.riwayatSurvey.where(
        (item) => item.id == 'monitoring-submit-1',
      );
      expect(submittedHistory, hasLength(1));
      expect(submittedHistory.single.statusHasilEvaluasi, 'sesuai');
      expect(
        container
            .read(notifikasiProvider)
            .where((item) => item.id == 'ba-notif-monitoring-submit-1'),
        hasLength(1),
      );
      expect(container.read(monitoringFormProvider).namaPerumahan, isEmpty);
    },
  );

  test('repeated token returns duplicate without repeating side effects', () {
    final repository = MonitoringRepository();
    final container = ProviderContainer(
      overrides: [monitoringRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final notifier = container.read(monitoringFormProvider.notifier);
    final draft = _draft(id: 'monitoring-submit-duplicate');
    final first = notifier.submitFinal(draft);
    final reportCount = repository
        .getAllMonitoring()
        .where((item) => item.id == draft.id)
        .length;
    final historyCount = container
        .read(pengajuanListProvider)
        .singleWhere((item) => item.id == draft.pengajuanId)
        .riwayatSurvey
        .where((item) => item.id == draft.id)
        .length;
    final notificationCount = container
        .read(notifikasiProvider)
        .where((item) => item.id == 'ba-notif-${draft.id}')
        .length;

    final second = notifier.submitFinal(draft);

    expect(first.isSuccess, isTrue);
    expect(second.status, MonitoringSubmitStatus.duplicate);
    expect(
      repository.getAllMonitoring().where((item) => item.id == draft.id),
      hasLength(reportCount),
    );
    expect(
      container
          .read(pengajuanListProvider)
          .singleWhere((item) => item.id == draft.pengajuanId)
          .riwayatSurvey
          .where((item) => item.id == draft.id),
      hasLength(historyCount),
    );
    expect(
      container
          .read(notifikasiProvider)
          .where((item) => item.id == 'ba-notif-${draft.id}'),
      hasLength(notificationCount),
    );
  });

  test('missing matching pengajuan fails and retains form state', () {
    final repository = MonitoringRepository();
    final container = ProviderContainer(
      overrides: [monitoringRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final notifier = container.read(monitoringFormProvider.notifier);
    notifier.updateNamaPerumahan('Unlinked housing');
    final result = notifier.submitFinal(
      _draft(id: 'monitoring-submit-missing', pengajuanId: 'missing'),
    );

    expect(result.status, MonitoringSubmitStatus.failure);
    expect(result.errorMessage, contains('tidak ditemukan'));
    expect(notifier.state.namaPerumahan, 'Unlinked housing');
    expect(notifier.state.isSubmitting, isFalse);
    expect(
      repository.getAllMonitoring().where(
        (item) => item.id == 'monitoring-submit-missing',
      ),
      isEmpty,
    );
  });

  test('BA-link rejection is atomic and leaves every store unchanged', () {
    final repository = MonitoringRepository();
    final container = ProviderContainer(
      overrides: [
        monitoringRepositoryProvider.overrideWithValue(repository),
        monitoringFormProvider.overrideWith(
          (ref) => MonitoringFormNotifier(
            repository,
            ref,
            uploadBa: (_, __, {hasilSurvey}) =>
                const PengajuanOperationResult.blocked(
                  'BA ditolak oleh pengajuan.',
                ),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(monitoringFormProvider.notifier);
    notifier.updateNamaPerumahan('Draft retained after BA rejection');
    final beforePengajuan = container
        .read(pengajuanListProvider)
        .singleWhere((item) => item.id == 'SR-20260720-612');
    final result = notifier.submitFinal(
      _draft(id: 'monitoring-submit-ba-rejected'),
    );

    expect(result.status, MonitoringSubmitStatus.failure);
    expect(result.errorMessage, contains('BA ditolak'));
    expect(notifier.state.namaPerumahan, 'Draft retained after BA rejection');
    expect(
      repository.getAllMonitoring().where(
        (item) => item.id == 'monitoring-submit-ba-rejected',
      ),
      isEmpty,
    );
    final afterPengajuan = container
        .read(pengajuanListProvider)
        .singleWhere((item) => item.id == 'SR-20260720-612');
    expect(afterPengajuan.beritaAcaraPath, beforePengajuan.beritaAcaraPath);
    expect(afterPengajuan.riwayatSurvey, beforePengajuan.riwayatSurvey);
    expect(
      container
          .read(notifikasiProvider)
          .where((item) => item.id == 'ba-notif-monitoring-submit-ba-rejected'),
      isEmpty,
    );
  });

  test('name matching never selects a non-survey pengajuan', () {
    final repository = MonitoringRepository();
    final container = ProviderContainer(
      overrides: [monitoringRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final target = container
        .read(pengajuanListProvider)
        .singleWhere((item) => item.id == 'SR-20260720-612');
    container
        .read(pengajuanListProvider.notifier)
        .updatePengajuan(
          target.copyWith(statusTahap: StatusTahapPengajuan.verifikasiTeknis),
        );
    final result = container
        .read(monitoringFormProvider.notifier)
        .submitFinal(
          _draft(id: 'monitoring-submit-non-survey', pengajuanId: null),
        );

    expect(result.status, MonitoringSubmitStatus.failure);
    expect(
      repository.getAllMonitoring().where(
        (item) => item.id == 'monitoring-submit-non-survey',
      ),
      isEmpty,
    );
    expect(
      container
          .read(pengajuanListProvider)
          .singleWhere((item) => item.id == target.id)
          .riwayatSurvey,
      target.riwayatSurvey,
    );
  });

  test('rejected evaluation without RTL fails before any side effect', () {
    final repository = MonitoringRepository();
    final container = ProviderContainer(
      overrides: [monitoringRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final result = container
        .read(monitoringFormProvider.notifier)
        .submitFinal(
          _draft(
            id: 'monitoring-submit-rejected',
            status: StatusHasilEvaluasi.tidakSesuaiSiteplan,
          ),
        );

    expect(result.status, MonitoringSubmitStatus.failure);
    expect(result.errorMessage, contains('wajib'));
    expect(
      repository.getAllMonitoring().where(
        (item) => item.id == 'monitoring-submit-rejected',
      ),
      isEmpty,
    );
    expect(
      container
          .read(pengajuanListProvider)
          .singleWhere((item) => item.id == 'SR-20260720-612')
          .riwayatSurvey
          .where((item) => item.id == 'monitoring-submit-rejected'),
      isEmpty,
    );
  });

  test('follow-up evaluation keeps its distinct history status', () {
    final repository = MonitoringRepository();
    final container = ProviderContainer(
      overrides: [monitoringRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final result = container
        .read(monitoringFormProvider.notifier)
        .submitFinal(
          _draft(
            id: 'monitoring-submit-follow-up',
            status: StatusHasilEvaluasi.perluEvaluasiLanjutan,
            rtl: const ['Pemeriksaan ulang dalam 7 hari.'],
          ),
        );

    final pengajuan = container
        .read(pengajuanListProvider)
        .singleWhere((item) => item.id == 'SR-20260720-612');
    expect(result.isSuccess, isTrue);
    expect(
      pengajuan.riwayatSurvey
          .singleWhere((item) => item.id == 'monitoring-submit-follow-up')
          .statusHasilEvaluasi,
      'perlu_perbaikan',
    );
  });

  test('successful finalization refreshes dashboard monitoring metrics', () {
    final repository = MonitoringRepository();
    final container = ProviderContainer(
      overrides: [monitoringRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final before = container
        .read(adminDashboardMetricsProvider)
        .monitoringTerbaru
        .length;
    final result = container
        .read(monitoringFormProvider.notifier)
        .submitFinal(_draft(id: 'monitoring-submit-metrics'));

    expect(result.isSuccess, isTrue);
    expect(
      container.read(adminDashboardMetricsProvider).monitoringTerbaru.length,
      before + 1,
    );
  });
}
