import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../monitoring/data/models/monitoring_model.dart';
import '../../../monitoring/data/models/status_hasil_evaluasi.dart';
import '../../../monitoring/presentation/providers/monitoring_list_provider.dart';
import '../../../pengajuan/data/models/pengajuan_model.dart';
import '../../../pengajuan/data/models/status_tahap_pengajuan.dart';
import '../../../pengajuan/presentation/providers/pengajuan_form_controller.dart';

class AdminDashboardMetrics {
  final int pengajuanBaruCount;
  final int verifikasiTeknisCount;
  final int surveyTerjadwalCount;
  final int perluTindakLanjutCount;
  final List<Pengajuan> pengajuanPerluAksi;
  final List<MonitoringModel> monitoringTerbaru;

  AdminDashboardMetrics({
    required this.pengajuanBaruCount,
    required this.verifikasiTeknisCount,
    required this.surveyTerjadwalCount,
    required this.perluTindakLanjutCount,
    required this.pengajuanPerluAksi,
    required this.monitoringTerbaru,
  });
}

final adminDashboardMetricsProvider = Provider<AdminDashboardMetrics>((ref) {
  final pengajuanList = ref.watch(pengajuanListProvider);
  final monitoringList = ref.watch(monitoringListProvider);

  final pengajuanBaru = pengajuanList
      .where(
        (e) =>
            e.statusTahap == StatusTahapPengajuan.pengajuanBaru ||
            e.statusTahap == StatusTahapPengajuan.verifikasiAdministrasi,
      )
      .length;

  final verifikasiTeknis = pengajuanList
      .where((e) => e.statusTahap == StatusTahapPengajuan.verifikasiTeknis)
      .length;

  final surveyTerjadwal = pengajuanList
      .where(
        (e) =>
            e.statusTahap == StatusTahapPengajuan.surveyLapangan ||
            e.tanggalSurvey != null,
      )
      .length;

  final perluTindakLanjutPengajuan = pengajuanList
      .where(
        (e) =>
            e.statusTahap == StatusTahapPengajuan.perluPerbaikan ||
            e.revisionSubmitted,
      )
      .length;

  final perluTindakLanjutMonitoring = monitoringList
      .where((e) => e.statusHasilEvaluasi.wajibRencanaTindakLanjut)
      .length;

  final pengajuanPerluAksi = pengajuanList
      .where((e) => e.statusTahap != StatusTahapPengajuan.selesai)
      .toList();

  return AdminDashboardMetrics(
    pengajuanBaruCount: pengajuanBaru,
    verifikasiTeknisCount: verifikasiTeknis,
    surveyTerjadwalCount: surveyTerjadwal,
    perluTindakLanjutCount:
        perluTindakLanjutPengajuan + perluTindakLanjutMonitoring,
    pengajuanPerluAksi: pengajuanPerluAksi,
    monitoringTerbaru: monitoringList,
  );
});

/// Async facade keeps the role home ready for a real repository/API source.
/// The current repository is local and synchronous, so this yields one honest
/// loading frame without changing the existing data contract.
final adminDashboardMetricsAsyncProvider =
    FutureProvider<AdminDashboardMetrics>((ref) async {
      final metrics = ref.watch(adminDashboardMetricsProvider);
      await Future<void>.delayed(Duration.zero);
      return metrics;
    });
