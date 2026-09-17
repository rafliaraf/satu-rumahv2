import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../pengajuan/data/models/pengajuan_model.dart';
import '../../../pengajuan/data/models/status_tahap_pengajuan.dart';
import '../../../pengajuan/presentation/providers/pengajuan_form_controller.dart';
import '../../data/models/monitoring_model.dart';
import 'monitoring_form_provider.dart';

final monitoringListProvider =
    StateNotifierProvider<MonitoringListNotifier, List<MonitoringModel>>((ref) {
      final repo = ref.watch(monitoringRepositoryProvider);
      return MonitoringListNotifier(repo);
    });

/// Async facade keeps loading and retry states explicit while the prototype
/// still reads from its local in-memory repository.
final monitoringListAsyncProvider = FutureProvider<List<MonitoringModel>>((
  ref,
) async {
  final monitoring = ref.watch(monitoringListProvider);
  await Future<void>.delayed(Duration.zero);
  return monitoring;
});

/// Provider penugasan survey aktif yang dikirim dari Admin ke Tim Perwaskim
final surveyAktifProvider = Provider<List<Pengajuan>>((ref) {
  final pengajuanList = ref.watch(pengajuanListProvider);
  return pengajuanList.where((p) {
    return p.statusTahap == StatusTahapPengajuan.surveyLapangan ||
        p.tanggalSurvey != null;
  }).toList();
});

class MonitoringListNotifier extends StateNotifier<List<MonitoringModel>> {
  final dynamic _repository;

  MonitoringListNotifier(this._repository) : super([]) {
    refresh();
  }

  void refresh() {
    state = _repository.getAllMonitoring();
  }

  void search(String query, {DateTime? fromDate, DateTime? toDate}) {
    state = _repository.searchMonitoring(
      query: query,
      fromDate: fromDate,
      toDate: toDate,
    );
  }
}
