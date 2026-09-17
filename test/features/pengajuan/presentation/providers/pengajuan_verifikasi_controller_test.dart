import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:satu_rumah/features/pengajuan/data/models/hasil_survey_model.dart';
import 'package:satu_rumah/features/pengajuan/data/models/pengajuan_model.dart';
import 'package:satu_rumah/features/pengajuan/data/models/status_tahap_pengajuan.dart';
import 'package:satu_rumah/features/pengajuan/presentation/providers/pengajuan_form_controller.dart';
import 'package:satu_rumah/features/pengajuan/presentation/providers/pengajuan_verifikasi_controller.dart';
import 'package:satu_rumah/features/pengajuan/presentation/screens/pengajuan_admin_detail_screen.dart';

Pengajuan _pengajuan({
  required StatusTahapPengajuan stage,
  Map<String, String>? uploadedDocs,
  Map<String, bool>? verifiedDocs,
  String? beritaAcaraPath,
  String? skPersetujuanPath,
  List<HasilSurveyItem> riwayatSurvey = const [],
  StatusTahapPengajuan? tahapAsalPerbaikan,
  bool revisionSubmitted = false,
}) {
  return Pengajuan(
    id: 'TEST-001',
    namaPerumahan: 'Perumahan Uji',
    namaPt: 'PT Uji',
    namaDirektur: 'Direktur Uji',
    npwpPerusahaan: '01.001',
    luasLahan: 1000,
    jumlahUnit: 10,
    tipePerumahan: 'Subsidi',
    status: stage == StatusTahapPengajuan.selesai ? 'Selesai' : 'Dalam Proses',
    statusTahap: stage,
    tanggal: '19 Agustus 2026',
    uploadedDocs: uploadedDocs ?? const {},
    verifiedDocs: verifiedDocs ?? const {},
    beritaAcaraPath: beritaAcaraPath,
    skPersetujuanPath: skPersetujuanPath,
    riwayatSurvey: riwayatSurvey,
    tahapAsalPerbaikan: tahapAsalPerbaikan,
    revisionSubmitted: revisionSubmitted,
  );
}

ProviderContainer _containerWith(Pengajuan item) {
  final container = ProviderContainer();
  container.read(pengajuanListProvider.notifier).addPengajuan(item);
  return container;
}

Pengajuan _current(ProviderContainer container) => container
    .read(pengajuanListProvider)
    .firstWhere((item) => item.id == 'TEST-001');

void main() {
  test('unknown approval is blocked with a reason', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final result = container
        .read(pengajuanVerifikasiControllerProvider.notifier)
        .approveTahap('UNKNOWN');

    expect(result.stateChanged, isFalse);
    expect(result.message, contains('tidak ditemukan'));
  });

  test('administrative approval requires every required document verified', () {
    final container = _containerWith(
      _pengajuan(
        stage: StatusTahapPengajuan.verifikasiAdministrasi,
        uploadedDocs: {'ktp': 'ktp.pdf'},
        verifiedDocs: {'ktp': true},
      ),
    );
    addTearDown(container.dispose);

    final result = container
        .read(pengajuanVerifikasiControllerProvider.notifier)
        .approveTahap('TEST-001');

    expect(result.stateChanged, isFalse);
    expect(result.message, contains('dokumen'));
    expect(
      _current(container).statusTahap,
      StatusTahapPengajuan.verifikasiAdministrasi,
    );
  });

  test('technical stage schedules survey instead of approving as a no-op', () {
    const technicalDocs = {'site_plan_dwg': 'siteplan.pdf'};
    const verified = {'site_plan_dwg': true};
    final container = _containerWith(
      _pengajuan(
        stage: StatusTahapPengajuan.verifikasiTeknis,
        uploadedDocs: technicalDocs,
        verifiedDocs: verified,
      ),
    );
    addTearDown(container.dispose);

    final approve = container
        .read(pengajuanVerifikasiControllerProvider.notifier)
        .approveTahap('TEST-001');
    final schedule = container
        .read(pengajuanVerifikasiControllerProvider.notifier)
        .jadwalkanSurvey('TEST-001', DateTime(2026, 8, 21), 'Catatan');

    expect(approve.stateChanged, isFalse);
    expect(approve.message, contains('jadwal'));
    expect(schedule.stateChanged, isTrue);
    expect(
      _current(container).statusTahap,
      StatusTahapPengajuan.surveyLapangan,
    );
  });

  test(
    'survey approval requires a final linked BA and acceptable evaluation',
    () {
      final survey = HasilSurveyItem(
        id: 'survey-1',
        tanggalSurvey: DateTime(2026, 8, 20),
        pelaksanaNama: 'Petugas',
        pelaksanaJabatan: 'Inspektur',
        lokasiPerumahan: 'Lokasi',
        statusHasilEvaluasi: 'sesuai',
        photoPaths: const ['photo.jpg'],
        isDraft: false,
      );
      final container = _containerWith(
        _pengajuan(
          stage: StatusTahapPengajuan.surveyLapangan,
          riwayatSurvey: [survey],
        ),
      );
      addTearDown(container.dispose);
      final blocked = container
          .read(pengajuanVerifikasiControllerProvider.notifier)
          .approveTahap('TEST-001');
      expect(blocked.stateChanged, isFalse);

      final upload = container
          .read(pengajuanVerifikasiControllerProvider.notifier)
          .uploadBeritaAcara('TEST-001', 'ba-final.pdf', hasilSurvey: survey);
      final approved = container
          .read(pengajuanVerifikasiControllerProvider.notifier)
          .approveTahap('TEST-001');

      expect(upload.stateChanged, isTrue);
      expect(approved.stateChanged, isTrue);
      expect(_current(container).statusTahap, StatusTahapPengajuan.persetujuan);
    },
  );

  test(
    'history-only final BA is ready and detail/controller use the same predicate',
    () {
      final survey = HasilSurveyItem(
        id: 'survey-history-ba',
        tanggalSurvey: DateTime(2026, 8, 20),
        pelaksanaNama: 'Petugas',
        pelaksanaJabatan: 'Inspektur',
        lokasiPerumahan: 'Lokasi',
        statusHasilEvaluasi: 'sesuai',
        beritaAcaraPath: 'ba-history.pdf',
        photoPaths: const ['photo.jpg'],
        isDraft: false,
      );
      final container = _containerWith(
        _pengajuan(
          stage: StatusTahapPengajuan.surveyLapangan,
          riwayatSurvey: [survey],
        ),
      );
      addTearDown(container.dispose);
      final notifier = container.read(
        pengajuanVerifikasiControllerProvider.notifier,
      );

      final baReady = notifier.surveyBaGuard('TEST-001');
      final approval = notifier.approveTahap('TEST-001');

      expect(baReady.allowed, isTrue);
      expect(approval.stateChanged, isTrue);
    },
  );

  test(
    'unacceptable evaluation blocks approval even when history-only BA is ready',
    () {
      final survey = HasilSurveyItem(
        id: 'survey-rejected',
        tanggalSurvey: DateTime(2026, 8, 20),
        pelaksanaNama: 'Petugas',
        pelaksanaJabatan: 'Inspektur',
        lokasiPerumahan: 'Lokasi',
        statusHasilEvaluasi: 'tidak_sesuai',
        beritaAcaraPath: 'ba-history.pdf',
        photoPaths: const ['photo.jpg'],
        isDraft: false,
      );
      final container = _containerWith(
        _pengajuan(
          stage: StatusTahapPengajuan.surveyLapangan,
          riwayatSurvey: [survey],
        ),
      );
      addTearDown(container.dispose);
      final notifier = container.read(
        pengajuanVerifikasiControllerProvider.notifier,
      );

      expect(notifier.surveyBaGuard('TEST-001').allowed, isTrue);
      final approval = notifier.approveTahap('TEST-001');

      expect(approval.stateChanged, isFalse);
      expect(approval.message, contains('evaluasi'));
      expect(
        _current(container).statusTahap,
        StatusTahapPengajuan.surveyLapangan,
      );
    },
  );

  test(
    'final approval requires an SK and duplicate terminal approval is blocked',
    () {
      final container = _containerWith(
        _pengajuan(stage: StatusTahapPengajuan.persetujuan),
      );
      addTearDown(container.dispose);
      final blocked = container
          .read(pengajuanVerifikasiControllerProvider.notifier)
          .approveTahap('TEST-001');
      expect(blocked.stateChanged, isFalse);

      final upload = container
          .read(pengajuanVerifikasiControllerProvider.notifier)
          .uploadSkPersetujuan('TEST-001', 'sk-final.pdf');
      final approved = container
          .read(pengajuanVerifikasiControllerProvider.notifier)
          .approveTahap('TEST-001');
      final duplicate = container
          .read(pengajuanVerifikasiControllerProvider.notifier)
          .approveTahap('TEST-001');

      expect(upload.stateChanged, isTrue);
      expect(approved.stateChanged, isTrue);
      expect(duplicate.stateChanged, isFalse);
      expect(_current(container).statusTahap, StatusTahapPengajuan.selesai);
    },
  );

  test('revision request requires both a note and named documents', () {
    final container = _containerWith(
      _pengajuan(
        stage: StatusTahapPengajuan.verifikasiAdministrasi,
        uploadedDocs: {'ktp': 'ktp.pdf'},
      ),
    );
    addTearDown(container.dispose);
    final result = container
        .read(pengajuanVerifikasiControllerProvider.notifier)
        .mintaPerbaikan('TEST-001', '  ', const []);

    expect(result.stateChanged, isFalse);
    expect(
      _current(container).statusTahap,
      StatusTahapPengajuan.verifikasiAdministrasi,
    );
  });

  test('resubmitted revision is actionable and can be approved directly', () {
    final container = _containerWith(
      _pengajuan(
        stage: StatusTahapPengajuan.perluPerbaikan,
        tahapAsalPerbaikan: StatusTahapPengajuan.verifikasiAdministrasi,
        uploadedDocs: {'kkpr_doc': 'kkpr-lama.pdf'},
      ).copyWith(
        catatanPerbaikan: 'Unggah ulang KKPR yang lebih jelas.',
        dokumenPerluRevisi: const ['kkpr_doc'],
      ),
    );
    addTearDown(container.dispose);
    final notifier = container.read(
      pengajuanVerifikasiControllerProvider.notifier,
    );

    final submitted = notifier.kirimRevisi('TEST-001', const {
      'kkpr_doc': 'kkpr-baru.pdf',
    });
    final guard = notifier.approveGuard('TEST-001');
    final approved = notifier.approveTahap('TEST-001');

    expect(submitted.stateChanged, isTrue);
    expect(submitted.nextStage, StatusTahapPengajuan.verifikasiAdministrasi);
    expect(guard.allowed, isTrue);
    expect(approved.stateChanged, isTrue);
    expect(
      _current(container).statusTahap,
      StatusTahapPengajuan.verifikasiTeknis,
    );
    expect(_current(container).revisionSubmitted, isFalse);
    expect(_current(container).tahapAsalPerbaikan, isNull);
  });

  test('technical revision can be assigned to field verification', () {
    final container = _containerWith(
      _pengajuan(
        stage: StatusTahapPengajuan.perluPerbaikan,
        tahapAsalPerbaikan: StatusTahapPengajuan.verifikasiTeknis,
        uploadedDocs: {'site_plan_dwg': 'site-plan-lama.pdf'},
      ).copyWith(
        catatanPerbaikan: 'Perbaiki site plan.',
        dokumenPerluRevisi: const ['site_plan_dwg'],
      ),
    );
    addTearDown(container.dispose);
    final notifier = container.read(
      pengajuanVerifikasiControllerProvider.notifier,
    );

    final submitted = notifier.kirimRevisi('TEST-001', const {
      'site_plan_dwg': 'site-plan-baru.pdf',
    });
    final guard = notifier.jadwalSurveyGuard('TEST-001');
    final scheduled = notifier.jadwalkanSurvey(
      'TEST-001',
      DateTime(2026, 8, 24, 9),
      'Pemeriksaan lapangan ulang',
    );

    expect(submitted.stateChanged, isTrue);
    expect(guard.allowed, isTrue);
    expect(scheduled.stateChanged, isTrue);
    expect(
      _current(container).statusTahap,
      StatusTahapPengajuan.surveyLapangan,
    );
    expect(_current(container).revisionSubmitted, isFalse);
  });

  testWidgets('admin detail exposes revision decision instead of a lock', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 800));
    final container = _containerWith(
      _pengajuan(
        stage: StatusTahapPengajuan.verifikasiAdministrasi,
        tahapAsalPerbaikan: StatusTahapPengajuan.verifikasiAdministrasi,
        revisionSubmitted: true,
      ),
    );
    addTearDown(() async {
      container.dispose();
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: PengajuanAdminDetailScreen(id: 'TEST-001'),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Approve Revisi'), findsOneWidget);
    expect(find.text('Revisi baru menunggu keputusan Admin'), findsOneWidget);
  });

  test('successful advancement out of restored revision clears its origin', () {
    final docs = {
      for (final key
          in PengajuanVerifikasiController.requiredAdministrativeDocumentKeys)
        key: 'document.pdf',
    };
    final verified = {for (final key in docs.keys) key: true};
    final container = _containerWith(
      _pengajuan(
        stage: StatusTahapPengajuan.perluPerbaikan,
        tahapAsalPerbaikan: StatusTahapPengajuan.verifikasiAdministrasi,
        uploadedDocs: docs,
        verifiedDocs: verified,
      ),
    );
    addTearDown(container.dispose);

    final result = container
        .read(pengajuanVerifikasiControllerProvider.notifier)
        .approveTahap('TEST-001');

    expect(result.stateChanged, isTrue);
    expect(
      _current(container).statusTahap,
      StatusTahapPengajuan.verifikasiTeknis,
    );
    expect(_current(container).tahapAsalPerbaikan, isNull);
  });

  testWidgets('admin detail shows history-only BA without synthetic export', (
    tester,
  ) async {
    final survey = HasilSurveyItem(
      id: 'survey-ui-ba',
      tanggalSurvey: DateTime(2026, 8, 20),
      pelaksanaNama: 'Petugas',
      pelaksanaJabatan: 'Inspektur',
      lokasiPerumahan: 'Lokasi',
      statusHasilEvaluasi: 'sesuai',
      beritaAcaraPath: 'ba-history.pdf',
      photoPaths: const ['photo.jpg'],
      isDraft: false,
    );
    final container = _containerWith(
      _pengajuan(
        stage: StatusTahapPengajuan.surveyLapangan,
        riwayatSurvey: [survey],
      ),
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: PengajuanAdminDetailScreen(id: 'TEST-001'),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Hasil Survey'));
    await tester.pump();
    await tester.drag(find.byType(ListView).last, const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(find.text('BA tersedia, ekspor belum terhubung'), findsOneWidget);
    expect(find.text('Lihat Berita Acara (PDF)'), findsNothing);
  });
}
