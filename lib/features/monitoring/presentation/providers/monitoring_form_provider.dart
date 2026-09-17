import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../notifikasi/data/models/notifikasi_model.dart';
import '../../../notifikasi/presentation/providers/notifikasi_provider.dart';
import '../../../pengajuan/data/models/hasil_survey_model.dart';
import '../../../pengajuan/data/models/pengajuan_model.dart';
import '../../../pengajuan/data/models/status_tahap_pengajuan.dart';
import '../../../pengajuan/presentation/providers/pengajuan_form_controller.dart';
import '../../../pengajuan/presentation/providers/pengajuan_verifikasi_controller.dart';
import '../../data/models/monitoring_model.dart';
import '../../data/models/status_hasil_evaluasi.dart';
import '../../data/repositories/monitoring_repository.dart';
import 'monitoring_list_provider.dart';

final monitoringRepositoryProvider = Provider<MonitoringRepository>((ref) {
  return MonitoringRepository();
});

typedef MonitoringBaUpload =
    PengajuanOperationResult Function(
      String pengajuanId,
      String filePath, {
      HasilSurveyItem? hasilSurvey,
    });

enum MonitoringSubmitStatus { success, duplicate, failure }

/// Result returned by the one canonical final-report operation.
///
/// A duplicate result is successful from the caller's perspective, but marks
/// that no second report, pengajuan history item, or notification was added.
class MonitoringSubmitResult {
  final MonitoringSubmitStatus status;
  final MonitoringModel? model;
  final String? errorMessage;

  const MonitoringSubmitResult({
    required this.status,
    this.model,
    this.errorMessage,
  });

  bool get isSuccess =>
      status == MonitoringSubmitStatus.success ||
      status == MonitoringSubmitStatus.duplicate;
  bool get isDuplicate => status == MonitoringSubmitStatus.duplicate;
  bool get isFailure => status == MonitoringSubmitStatus.failure;

  factory MonitoringSubmitResult.success(MonitoringModel model) {
    return MonitoringSubmitResult(
      status: MonitoringSubmitStatus.success,
      model: model,
    );
  }

  factory MonitoringSubmitResult.duplicate(MonitoringModel model) {
    return MonitoringSubmitResult(
      status: MonitoringSubmitStatus.duplicate,
      model: model,
    );
  }

  factory MonitoringSubmitResult.failure(String message) {
    return MonitoringSubmitResult(
      status: MonitoringSubmitStatus.failure,
      errorMessage: message,
    );
  }
}

class MonitoringFormState {
  final String? pengajuanId;
  final int currentStep;
  final DateTime tanggalMonitoring;
  final String namaPerumahan;
  final String namaDeveloper;
  final String lokasiPerumahan;
  final String maksudTujuan;
  final List<String> temuanLapangan;
  final List<String> kesimpulan;
  final List<String> kesepakatan;
  final List<String> rencanaTindakLanjut;
  final StatusHasilEvaluasi statusHasilEvaluasi;
  final String pelaksanaNama;
  final String pelaksanaJabatan;
  final String ditemuiNama;
  final String ditemuiJabatan;
  final List<String> photoPaths;
  final bool isSubmitting;
  final String? errorMessage;

  MonitoringFormState({
    this.pengajuanId,
    this.currentStep = 0,
    DateTime? tanggalMonitoring,
    this.namaPerumahan = '',
    this.namaDeveloper = '',
    this.lokasiPerumahan = '',
    this.maksudTujuan = MonitoringModel.defaultMaksudTujuan,
    this.temuanLapangan = const [''],
    this.kesimpulan = const [''],
    this.kesepakatan = const [''],
    this.rencanaTindakLanjut = const [''],
    this.statusHasilEvaluasi = StatusHasilEvaluasi.sesuaiSiteplan,
    this.pelaksanaNama = '',
    this.pelaksanaJabatan = '',
    this.ditemuiNama = '',
    this.ditemuiJabatan = '',
    this.photoPaths = const [],
    this.isSubmitting = false,
    this.errorMessage,
  }) : tanggalMonitoring = tanggalMonitoring ?? DateTime.now();

  MonitoringFormState copyWith({
    String? pengajuanId,
    int? currentStep,
    DateTime? tanggalMonitoring,
    String? namaPerumahan,
    String? namaDeveloper,
    String? lokasiPerumahan,
    String? maksudTujuan,
    List<String>? temuanLapangan,
    List<String>? kesimpulan,
    List<String>? kesepakatan,
    List<String>? rencanaTindakLanjut,
    StatusHasilEvaluasi? statusHasilEvaluasi,
    String? pelaksanaNama,
    String? pelaksanaJabatan,
    String? ditemuiNama,
    String? ditemuiJabatan,
    List<String>? photoPaths,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return MonitoringFormState(
      pengajuanId: pengajuanId ?? this.pengajuanId,
      currentStep: currentStep ?? this.currentStep,
      tanggalMonitoring: tanggalMonitoring ?? this.tanggalMonitoring,
      namaPerumahan: namaPerumahan ?? this.namaPerumahan,
      namaDeveloper: namaDeveloper ?? this.namaDeveloper,
      lokasiPerumahan: lokasiPerumahan ?? this.lokasiPerumahan,
      maksudTujuan: maksudTujuan ?? this.maksudTujuan,
      temuanLapangan: temuanLapangan ?? this.temuanLapangan,
      kesimpulan: kesimpulan ?? this.kesimpulan,
      kesepakatan: kesepakatan ?? this.kesepakatan,
      rencanaTindakLanjut: rencanaTindakLanjut ?? this.rencanaTindakLanjut,
      statusHasilEvaluasi: statusHasilEvaluasi ?? this.statusHasilEvaluasi,
      pelaksanaNama: pelaksanaNama ?? this.pelaksanaNama,
      pelaksanaJabatan: pelaksanaJabatan ?? this.pelaksanaJabatan,
      ditemuiNama: ditemuiNama ?? this.ditemuiNama,
      ditemuiJabatan: ditemuiJabatan ?? this.ditemuiJabatan,
      photoPaths: photoPaths ?? this.photoPaths,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
    );
  }
}

class MonitoringFormNotifier extends StateNotifier<MonitoringFormState> {
  final MonitoringRepository _repository;
  final Ref _ref;
  final MonitoringBaUpload? _baUploadOverride;
  final Map<String, MonitoringModel> _successfulSubmissions = {};

  MonitoringFormNotifier(
    this._repository,
    this._ref, {
    MonitoringBaUpload? uploadBa,
  }) : _baUploadOverride = uploadBa,
       super(MonitoringFormState());

  void setStep(int step) {
    state = state.copyWith(currentStep: step);
  }

  void updateTanggal(DateTime date) {
    state = state.copyWith(tanggalMonitoring: date);
  }

  void updatePengajuanId(String? pengajuanId) =>
      state = state.copyWith(pengajuanId: pengajuanId);
  void updateNamaPerumahan(String val) =>
      state = state.copyWith(namaPerumahan: val);
  void updateNamaDeveloper(String val) =>
      state = state.copyWith(namaDeveloper: val);
  void updateLokasi(String val) => state = state.copyWith(lokasiPerumahan: val);
  void updateTemuan(List<String> val) =>
      state = state.copyWith(temuanLapangan: val);
  void updateKesimpulan(List<String> val) =>
      state = state.copyWith(kesimpulan: val);
  void updateKesepakatan(List<String> val) =>
      state = state.copyWith(kesepakatan: val);
  void updateRTL(List<String> val) =>
      state = state.copyWith(rencanaTindakLanjut: val);
  void updateStatusHasilEvaluasi(StatusHasilEvaluasi val) =>
      state = state.copyWith(statusHasilEvaluasi: val);
  void updatePelaksanaNama(String val) =>
      state = state.copyWith(pelaksanaNama: val);
  void updatePelaksanaJabatan(String val) =>
      state = state.copyWith(pelaksanaJabatan: val);
  void updateDitemuiNama(String val) =>
      state = state.copyWith(ditemuiNama: val);
  void updateDitemuiJabatan(String val) =>
      state = state.copyWith(ditemuiJabatan: val);
  void updatePhotos(List<String> val) =>
      state = state.copyWith(photoPaths: val);

  /// Tombol "Isi Contoh" (Dummy Fill)
  void fillDummyData() {
    state = state.copyWith(
      tanggalMonitoring: DateTime.now(),
      namaPerumahan: 'Perumahan Permata Hijau Residence',
      lokasiPerumahan: 'Jl. Ir. H. Juanda No. 88, Kec. Cipedes, Tasikmalaya',
      temuanLapangan: [
        'Pengerjaan jalan lingkungan paving block sudah selesai 90%',
        'Saluran drainase utama mengalami pendangkalan akibat sisa material',
      ],
      kesimpulan: [
        'Pelaksanaan fisik PSU secara umum baik, perlu normalisasi saluran drainase.',
      ],
      kesepakatan: [
        'Pengembang bersedia membersihkan saluran drainase dalam 7 hari kerja.',
      ],
      rencanaTindakLanjut: [
        'Monitoring susulan kebersihan drainase pada tanggal 28 Juli 2026.',
      ],
      statusHasilEvaluasi: StatusHasilEvaluasi.tidakSesuaiSiteplan,
      pelaksanaNama: 'Drs. Rian Hidayat, M.Si',
      pelaksanaJabatan: 'Ketua Tim Monitoring & Evaluasi DPKP',
      ditemuiNama: 'Budi Santoso, S.T.',
      ditemuiJabatan: 'Site Manager PT ABC Property',
      photoPaths: const [],
    );
  }

  /// Membangun MonitoringModel untuk pratinjau Berita Acara (isDraft = true)
  MonitoringModel? buildPreviewModel() {
    if (state.namaPerumahan.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Nama Perumahan wajib diisi.');
      return null;
    }

    final filteredRTL = state.rencanaTindakLanjut
        .where((e) => e.trim().isNotEmpty)
        .toList();
    if (state.statusHasilEvaluasi.wajibRencanaTindakLanjut &&
        filteredRTL.isEmpty) {
      state = state.copyWith(
        errorMessage:
            'Untuk status "${state.statusHasilEvaluasi.label}", wajib mengisikan minimal 1 poin Rencana Tindak Lanjut.',
      );
      return null;
    }

    return MonitoringModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      pengajuanId: state.pengajuanId,
      tanggalMonitoring: state.tanggalMonitoring,
      namaPerumahan: state.namaPerumahan,
      namaDeveloper: state.namaDeveloper,
      lokasiPerumahan: state.lokasiPerumahan,
      maksudTujuan: state.maksudTujuan,
      temuanLapangan: state.temuanLapangan
          .where((e) => e.trim().isNotEmpty)
          .toList(),
      kesimpulan: state.kesimpulan.where((e) => e.trim().isNotEmpty).toList(),
      kesepakatan: state.kesepakatan.where((e) => e.trim().isNotEmpty).toList(),
      rencanaTindakLanjut: filteredRTL,
      statusHasilEvaluasi: state.statusHasilEvaluasi,
      pelaksanaNama: state.pelaksanaNama,
      pelaksanaJabatan: state.pelaksanaJabatan,
      ditemuiNama: state.ditemuiNama,
      ditemuiJabatan: state.ditemuiJabatan,
      photoPaths: state.photoPaths,
      isDraft: true,
    );
  }

  /// Finalize one draft and synchronize all local cross-role side effects.
  ///
  /// The draft ID is the default idempotency token. Repository/history writes
  /// and the notification ID use that token, so a retry after a partial local
  /// failure cannot create a second final report or notification.
  MonitoringSubmitResult submitFinal(
    MonitoringModel draft, {
    String? idempotencyToken,
  }) {
    if (state.isSubmitting) {
      return MonitoringSubmitResult.failure('Laporan sedang dikirim.');
    }

    final token = (idempotencyToken ?? draft.id).trim();
    final previous = _successfulSubmissions[token];
    if (previous != null) {
      return MonitoringSubmitResult.duplicate(previous);
    }

    if (token.isEmpty || draft.id.trim().isEmpty) {
      return _failSubmit('ID laporan tidak valid.');
    }

    if (!draft.isDraft) {
      return _failSubmit('Laporan yang sudah final tidak dapat dikirim ulang.');
    }

    if (draft.namaPerumahan.trim().isEmpty) {
      return _failSubmit('Nama Perumahan wajib diisi.');
    }

    if (draft.statusHasilEvaluasi.wajibRencanaTindakLanjut &&
        draft.rencanaTindakLanjut.every((item) => item.trim().isEmpty)) {
      return _failSubmit(
        'Untuk status "${draft.statusHasilEvaluasi.label}", wajib mengisikan minimal 1 poin Rencana Tindak Lanjut.',
      );
    }

    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      final pengajuan = _findMatchingPengajuan(draft);
      if (pengajuan == null) {
        return _failSubmit(
          'Pengajuan yang sesuai untuk laporan ini tidak ditemukan.',
        );
      }

      final finalModel = draft.copyWith(isDraft: false);
      final beritaAcaraPath =
          'BA_${finalModel.nomorSuratBA.replaceAll('/', '_')}.pdf';
      final baResult = (_baUploadOverride ?? _uploadBa)(
        pengajuan.id,
        beritaAcaraPath,
        hasilSurvey: _buildHasilSurveyItem(
          finalModel,
          beritaAcaraPath: beritaAcaraPath,
        ),
      );
      if (!baResult.succeeded) {
        return _failSubmit(baResult.message);
      }

      // All mutations below use existing public provider APIs. Each is keyed
      // by the same report ID, making retries replace the matching history item
      // instead of appending another one.
      _repository.addMonitoring(finalModel);

      final notificationId = 'ba-notif-$token';
      final notificationExists = _ref
          .read(notifikasiProvider)
          .any((item) => item.id == notificationId);
      if (!notificationExists) {
        _ref
            .read(notifikasiProvider.notifier)
            .addNotification(
              NotifikasiModel(
                id: notificationId,
                jenis: JenisNotifikasi.dokumenDiunggahUlang,
                judul: 'Berita Acara Survey Diunggah',
                deskripsi:
                    'Tim Perwaskim telah menyelesaikan survey dan mengunggah Berita Acara (${finalModel.nomorSuratBA}) untuk ${pengajuan.namaPerumahan}. Tombol Approve Tahap kini terbuka.',
                waktu: DateTime.now(),
                isRead: false,
                targetRoute: '/pengajuan/detail/${pengajuan.id}',
              ),
            );
      }

      _successfulSubmissions[token] = finalModel;
      _ref.read(monitoringListProvider.notifier).refresh();
      state = state.copyWith(isSubmitting: false, errorMessage: null);
      resetForm();
      return MonitoringSubmitResult.success(finalModel);
    } catch (error) {
      return _failSubmit('Laporan gagal dikirim: $error');
    }
  }

  /// Legacy synchronous entry point retained for existing local callers.
  /// Preview and new code must use [submitFinal] directly.
  MonitoringModel? submit() {
    final draft = buildPreviewModel();
    if (draft == null) return null;
    return submitFinal(draft).model;
  }

  MonitoringSubmitResult _failSubmit(String message) {
    state = state.copyWith(isSubmitting: false, errorMessage: message);
    return MonitoringSubmitResult.failure(message);
  }

  Pengajuan? _findMatchingPengajuan(MonitoringModel report) {
    final pengajuanList = _ref.read(pengajuanListProvider);
    if (report.pengajuanId != null && report.pengajuanId!.trim().isNotEmpty) {
      for (final pengajuan in pengajuanList) {
        if (pengajuan.id == report.pengajuanId &&
            _isEligibleSurveyStage(pengajuan)) {
          return pengajuan;
        }
      }
      return null;
    }

    final normalizedName = _normalizeHousingName(report.namaPerumahan);
    final matches = pengajuanList.where(
      (pengajuan) =>
          _isEligibleSurveyStage(pengajuan) &&
          _normalizeHousingName(pengajuan.namaPerumahan) == normalizedName,
    );
    return matches.length == 1 ? matches.first : null;
  }

  bool _isEligibleSurveyStage(Pengajuan pengajuan) {
    return pengajuan.statusTahap == StatusTahapPengajuan.surveyLapangan ||
        (pengajuan.statusTahap == StatusTahapPengajuan.perluPerbaikan &&
            pengajuan.tahapAsalPerbaikan ==
                StatusTahapPengajuan.surveyLapangan);
  }

  String _normalizeHousingName(String value) {
    return value.trim().toLowerCase().replaceFirst(
      RegExp(r'^perumahan\s+'),
      '',
    );
  }

  HasilSurveyItem _buildHasilSurveyItem(
    MonitoringModel report, {
    String? beritaAcaraPath,
  }) {
    final status = switch (report.statusHasilEvaluasi) {
      StatusHasilEvaluasi.sesuaiSiteplan => 'sesuai',
      StatusHasilEvaluasi.tidakSesuaiSiteplan => 'tidak_sesuai',
      StatusHasilEvaluasi.perluEvaluasiLanjutan => 'perlu_perbaikan',
    };

    return HasilSurveyItem(
      id: report.id,
      tanggalSurvey: report.tanggalMonitoring,
      pelaksanaNama: report.pelaksanaNama.isNotEmpty
          ? report.pelaksanaNama
          : 'Drs. Rian Hidayat, M.Si',
      pelaksanaJabatan: report.pelaksanaJabatan.isNotEmpty
          ? report.pelaksanaJabatan
          : 'Ketua Tim Monitoring & Evaluasi DPKP',
      lokasiPerumahan: report.lokasiPerumahan,
      statusHasilEvaluasi: status,
      temuanLapangan: report.temuanLapangan,
      kesimpulan: report.kesimpulan,
      kesepakatan: report.kesepakatan,
      rencanaTindakLanjut: report.rencanaTindakLanjut,
      photoPaths: report.photoPaths,
      nomorSuratBA: report.nomorSuratBA,
      beritaAcaraPath: beritaAcaraPath,
      isDraft: false,
    );
  }

  PengajuanOperationResult _uploadBa(
    String pengajuanId,
    String filePath, {
    HasilSurveyItem? hasilSurvey,
  }) {
    return _ref
        .read(pengajuanVerifikasiControllerProvider.notifier)
        .uploadBeritaAcara(pengajuanId, filePath, hasilSurvey: hasilSurvey);
  }

  void resetForm() {
    state = MonitoringFormState();
  }
}

final monitoringFormProvider =
    StateNotifierProvider<MonitoringFormNotifier, MonitoringFormState>((ref) {
      final repo = ref.watch(monitoringRepositoryProvider);
      return MonitoringFormNotifier(repo, ref);
    });
