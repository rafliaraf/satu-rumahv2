import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../notifikasi/data/models/notifikasi_model.dart';
import '../../../notifikasi/presentation/providers/notifikasi_provider.dart';
import '../../data/models/hasil_survey_model.dart';
import '../../data/models/pengajuan_model.dart';
import '../../data/models/status_tahap_pengajuan.dart';
import 'pengajuan_form_controller.dart';

/// The result of an administrative action in the local state machine.
///
/// `stateChanged` is deliberately separate from the message: callers must not
/// show a success affordance unless a real state mutation happened.
class PengajuanOperationResult {
  final bool stateChanged;
  final bool allowed;
  final String message;
  final StatusTahapPengajuan? previousStage;
  final StatusTahapPengajuan? nextStage;

  const PengajuanOperationResult({
    required this.stateChanged,
    this.allowed = false,
    required this.message,
    this.previousStage,
    this.nextStage,
  });

  bool get succeeded => stateChanged;
  bool get success => stateChanged;
  bool get changed => stateChanged;
  bool get isBlocked => !allowed;
  String get reason => message;
  String? get blockedReason => allowed ? null : message;

  const PengajuanOperationResult.blocked(
    String reason, {
    StatusTahapPengajuan? currentStage,
  }) : this(
         stateChanged: false,
         allowed: false,
         message: reason,
         previousStage: currentStage,
       );

  const PengajuanOperationResult.changed({
    required String message,
    StatusTahapPengajuan? previousStage,
    StatusTahapPengajuan? nextStage,
  }) : this(
         stateChanged: true,
         allowed: true,
         message: message,
         previousStage: previousStage,
         nextStage: nextStage,
       );
}

class PengajuanVerifikasiController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  /// Required documents for the administrative gate. `pelepasan_lahan` is
  /// optional in the form and is intentionally not part of this list.
  static const List<String> requiredAdministrativeDocumentKeys = [
    'ktp',
    'nib',
    'npwp_doc',
    'asosiasi',
    'legalitas',
    'surat_permohonan',
    'info_intensitas_ruang',
    'bukti_kepemilikan_lahan',
    'bukti_tpu',
    'kkpr_doc',
    'pbg_induk',
    'rekomendasi_lingkungan',
    'pernyataan_pelepasan',
    'pernyataan_keabsahan',
    'pernyataan_psu',
  ];

  static const List<String> requiredTechnicalDocumentKeys = ['site_plan_dwg'];

  PengajuanVerifikasiController(this._ref) : super(const AsyncValue.data(null));

  Pengajuan? _find(String pengajuanId) {
    for (final item in _ref.read(pengajuanListProvider)) {
      if (item.id == pengajuanId) return item;
    }
    return null;
  }

  StatusTahapPengajuan _effectiveStage(Pengajuan current) {
    if (current.statusTahap == StatusTahapPengajuan.perluPerbaikan ||
        current.revisionSubmitted) {
      return current.tahapAsalPerbaikan ??
          StatusTahapPengajuan.verifikasiAdministrasi;
    }
    return current.statusTahap;
  }

  /// A resubmitted revision is back on its original stage, but it still needs
  /// an explicit Admin decision. Keep this separate from the edit lock: the
  /// developer is locked after sending, while Admin actions remain available.
  bool _isRevisionPending(Pengajuan current) {
    return current.revisionSubmitted &&
        current.statusTahap != StatusTahapPengajuan.perluPerbaikan &&
        current.dokumenPerluRevisi.isEmpty &&
        current.tahapAsalPerbaikan != null;
  }

  bool _hasText(String? value) => value != null && value.trim().isNotEmpty;

  bool _hasRealBaPath(String? value) {
    if (!_hasText(value)) return false;
    return value!.trim().toLowerCase() != 'berita_acara_survey.pdf';
  }

  bool _hasDocument(Pengajuan current, String key) {
    if (_hasText(current.uploadedDocs[key])) return true;
    return key == 'site_plan_dwg' && current.technicalFiles.isNotEmpty;
  }

  PengajuanOperationResult _documentGuard(
    Pengajuan current,
    List<String> required,
    String label,
  ) {
    final missing = <String>[];
    final rejected = <String>[];
    final unverified = <String>[];

    for (final key in required) {
      if (!_hasDocument(current, key)) {
        missing.add(key);
        continue;
      }
      final verification = current.verifiedDocs[key];
      if (verification == false) {
        rejected.add(key);
      } else if (verification != true) {
        unverified.add(key);
      }
    }

    if (missing.isNotEmpty) {
      return PengajuanOperationResult.blocked(
        'Belum dapat melanjutkan: dokumen $label belum lengkap (${missing.join(', ')}).',
        currentStage: current.statusTahap,
      );
    }
    if (rejected.isNotEmpty) {
      return PengajuanOperationResult.blocked(
        'Belum dapat melanjutkan: dokumen ditolak (${rejected.join(', ')}). Minta perbaikan diperlukan.',
        currentStage: current.statusTahap,
      );
    }
    if (unverified.isNotEmpty) {
      return PengajuanOperationResult.blocked(
        'Belum dapat melanjutkan: verifikasi dokumen belum lengkap (${unverified.join(', ')}).',
        currentStage: current.statusTahap,
      );
    }
    return PengajuanOperationResult(
      stateChanged: false,
      allowed: true,
      message: 'Dokumen $label lengkap dan terverifikasi.',
      previousStage: current.statusTahap,
    );
  }

  HasilSurveyItem? _latestFinalSurvey(Pengajuan current) {
    for (final item in current.riwayatSurvey) {
      if (!item.isDraft) return item;
    }
    return null;
  }

  /// Authoritative BA readiness used by both approval and the admin detail UI.
  /// A BA is ready only when it is linked to a final (non-draft) survey and is
  /// present either on the pengajuan or on that survey history item.
  PengajuanOperationResult surveyBaGuard(String pengajuanId) {
    final current = _find(pengajuanId);
    if (current == null) {
      return const PengajuanOperationResult.blocked(
        'Pengajuan tidak ditemukan.',
      );
    }
    final latestFinal = _latestFinalSurvey(current);
    if (latestFinal == null) {
      return const PengajuanOperationResult.blocked(
        'Hasil survey final yang terhubung ke pengajuan belum tersedia.',
      );
    }
    if (!_hasRealBaPath(current.beritaAcaraPath) &&
        !_hasRealBaPath(latestFinal.beritaAcaraPath)) {
      return const PengajuanOperationResult.blocked(
        'Berita Acara final belum tersedia. Unggah BA yang nyata terlebih dahulu.',
      );
    }
    return const PengajuanOperationResult(
      stateChanged: false,
      allowed: true,
      message: 'Berita Acara final tersedia.',
    );
  }

  PengajuanOperationResult _surveyGuard(Pengajuan current) {
    final baGuard = surveyBaGuard(current.id);
    if (!baGuard.allowed) return baGuard;
    final latestFinal = _latestFinalSurvey(current)!;

    final evaluation = latestFinal.statusHasilEvaluasi.trim().toLowerCase();
    const acceptable = {
      'sesuai',
      'sesuaisiteplan',
      'sesuai_siteplan',
      'sesuai siteplan',
    };
    if (!acceptable.contains(evaluation)) {
      return PengajuanOperationResult.blocked(
        'Persetujuan survey diblokir karena evaluasi terakhir adalah ${latestFinal.statusLabel}.',
        currentStage: current.statusTahap,
      );
    }

    return PengajuanOperationResult(
      stateChanged: false,
      allowed: true,
      message: 'BA dan evaluasi survey dapat diterima.',
      previousStage: current.statusTahap,
    );
  }

  /// Read-only guard used by the detail screen to disable an action with its
  /// actual reason before a user taps it.
  PengajuanOperationResult approveGuard(String pengajuanId) {
    final current = _find(pengajuanId);
    if (current == null) {
      return const PengajuanOperationResult.blocked(
        'Pengajuan tidak ditemukan.',
      );
    }

    final effective = _effectiveStage(current);
    switch (effective) {
      case StatusTahapPengajuan.pengajuanBaru:
        return PengajuanOperationResult(
          stateChanged: false,
          allowed: true,
          message: 'Pengajuan siap masuk verifikasi administrasi.',
          previousStage: current.statusTahap,
        );
      case StatusTahapPengajuan.verifikasiAdministrasi:
        if (_isRevisionPending(current)) {
          return PengajuanOperationResult(
            stateChanged: false,
            allowed: true,
            message: 'Revisi siap disetujui langsung oleh Admin.',
            previousStage: current.statusTahap,
          );
        }
        return _documentGuard(
          current,
          requiredAdministrativeDocumentKeys,
          'administratif',
        );
      case StatusTahapPengajuan.verifikasiTeknis:
        return const PengajuanOperationResult.blocked(
          'Tahap teknis dilanjutkan melalui jadwal survey.',
        );
      case StatusTahapPengajuan.surveyLapangan:
        return _surveyGuard(current);
      case StatusTahapPengajuan.persetujuan:
        if (!_hasText(current.skPersetujuanPath)) {
          return const PengajuanOperationResult.blocked(
            'SK Persetujuan final belum tersedia.',
          );
        }
        return PengajuanOperationResult(
          stateChanged: false,
          allowed: true,
          message: 'SK Persetujuan tersedia untuk persetujuan akhir.',
          previousStage: current.statusTahap,
        );
      case StatusTahapPengajuan.selesai:
        return const PengajuanOperationResult.blocked(
          'Pengajuan sudah Selesai; tidak ada transisi lanjutan.',
        );
      case StatusTahapPengajuan.perluPerbaikan:
        return const PengajuanOperationResult.blocked(
          'Pengajuan masih menunggu perbaikan dokumen.',
        );
    }
  }

  /// Verifikasi dokumen individual (Sesuai / Tidak Sesuai).
  PengajuanOperationResult verifikasiDokumen(
    String pengajuanId,
    String dokumenKey,
    bool sesuai,
  ) {
    final current = _find(pengajuanId);
    if (current == null) {
      return const PengajuanOperationResult.blocked(
        'Pengajuan tidak ditemukan.',
      );
    }
    if (current.statusTahap == StatusTahapPengajuan.selesai) {
      return const PengajuanOperationResult.blocked(
        'Pengajuan sudah Selesai; dokumen tidak dapat diubah.',
      );
    }
    final key = dokumenKey.trim();
    if (key.isEmpty) {
      return const PengajuanOperationResult.blocked(
        'Dokumen yang diverifikasi belum dipilih.',
      );
    }
    if (current.verifiedDocs[key] == sesuai) {
      return PengajuanOperationResult(
        stateChanged: false,
        message: sesuai
            ? 'Dokumen sudah ditandai Sesuai.'
            : 'Dokumen sudah ditandai Tidak Sesuai.',
        previousStage: current.statusTahap,
      );
    }

    final updatedVerified = Map<String, bool>.from(current.verifiedDocs)
      ..[key] = sesuai;
    _ref
        .read(pengajuanListProvider.notifier)
        .updatePengajuan(current.copyWith(verifiedDocs: updatedVerified));
    return PengajuanOperationResult.changed(
      message: sesuai
          ? 'Dokumen ditandai Sesuai.'
          : 'Dokumen ditandai Tidak Sesuai.',
      previousStage: current.statusTahap,
      nextStage: current.statusTahap,
    );
  }

  /// Approve a stage only when its guards permit a real transition.
  PengajuanOperationResult approveTahap(String pengajuanId) {
    final current = _find(pengajuanId);
    if (current == null) {
      return const PengajuanOperationResult.blocked(
        'Pengajuan tidak ditemukan.',
      );
    }
    final guard = approveGuard(pengajuanId);
    if (!_isSuccessfulApproveGuard(guard)) return guard;

    final effective = _effectiveStage(current);
    final next = switch (effective) {
      StatusTahapPengajuan.pengajuanBaru =>
        StatusTahapPengajuan.verifikasiAdministrasi,
      StatusTahapPengajuan.verifikasiAdministrasi =>
        StatusTahapPengajuan.verifikasiTeknis,
      StatusTahapPengajuan.surveyLapangan => StatusTahapPengajuan.persetujuan,
      StatusTahapPengajuan.persetujuan => StatusTahapPengajuan.selesai,
      _ => null,
    };
    if (next == null) {
      return const PengajuanOperationResult.blocked(
        'Tahap ini tidak memiliki transisi approve yang valid.',
      );
    }

    final updated = _advance(current, next);
    _ref.read(pengajuanListProvider.notifier).updatePengajuan(updated);
    return PengajuanOperationResult.changed(
      message: 'Pengajuan dilanjutkan ke ${next.label}.',
      previousStage: current.statusTahap,
      nextStage: next,
    );
  }

  /// Minta perbaikan dokumen ke pengembang.
  PengajuanOperationResult mintaPerbaikan(
    String pengajuanId,
    String catatan,
    List<String> dokumenIds,
  ) {
    final current = _find(pengajuanId);
    if (current == null) {
      return const PengajuanOperationResult.blocked(
        'Pengajuan tidak ditemukan.',
      );
    }
    if (current.statusTahap == StatusTahapPengajuan.selesai) {
      return const PengajuanOperationResult.blocked(
        'Pengajuan sudah Selesai; permintaan perbaikan tidak tersedia.',
      );
    }
    if (current.statusTahap == StatusTahapPengajuan.perluPerbaikan) {
      return const PengajuanOperationResult.blocked(
        'Pengajuan sudah berada dalam tahap Perlu Perbaikan.',
      );
    }
    final note = catatan.trim();
    final docs = dokumenIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();
    if (note.isEmpty) {
      return const PengajuanOperationResult.blocked(
        'Catatan perbaikan wajib diisi.',
      );
    }
    if (docs.isEmpty) {
      return const PengajuanOperationResult.blocked(
        'Pilih minimal satu dokumen yang perlu diperbaiki.',
      );
    }

    final updatedModel = current.copyWith(
      status: 'Perlu Perbaikan',
      tahapAsalPerbaikan: current.statusTahap,
      statusTahap: StatusTahapPengajuan.perluPerbaikan,
      catatanPerbaikan: note,
      dokumenPerluRevisi: docs,
      revisionSubmitted: false,
    );
    _ref.read(pengajuanListProvider.notifier).updatePengajuan(updatedModel);

    _ref
        .read(notifikasiProvider.notifier)
        .addNotification(
          NotifikasiModel(
            id: 'n-${DateTime.now().millisecondsSinceEpoch}',
            jenis: JenisNotifikasi.dokumenDiunggahUlang,
            judul: 'Perbaikan Dokumen Diumumkan',
            deskripsi:
                'Catatan perbaikan untuk ${current.namaPerumahan}: $note',
            waktu: DateTime.now(),
            isRead: false,
            targetRoute: '/pengajuan/detail/${current.id}',
          ),
        );
    return PengajuanOperationResult.changed(
      message: 'Catatan perbaikan telah dikirim ke pengembang.',
      previousStage: current.statusTahap,
      nextStage: StatusTahapPengajuan.perluPerbaikan,
    );
  }

  /// Accept the requested revision files and return the record to the stage
  /// that originally requested the fix. The returned record is intentionally
  /// marked as pending so Admin can approve it directly or assign a field
  /// verification without confusing the developer edit lock with approval.
  PengajuanOperationResult kirimRevisi(
    String pengajuanId,
    Map<String, String> revisedDocs,
  ) {
    final current = _find(pengajuanId);
    if (current == null) {
      return const PengajuanOperationResult.blocked(
        'Pengajuan tidak ditemukan.',
      );
    }
    if (current.statusTahap != StatusTahapPengajuan.perluPerbaikan) {
      return const PengajuanOperationResult.blocked(
        'Pengajuan ini tidak sedang menunggu revisi.',
      );
    }
    final origin = current.tahapAsalPerbaikan;
    if (origin == null) {
      return const PengajuanOperationResult.blocked(
        'Tahap asal perbaikan belum tersedia.',
      );
    }
    if (current.dokumenPerluRevisi.isEmpty) {
      return const PengajuanOperationResult.blocked(
        'Tidak ada dokumen revisi yang perlu dikirim.',
      );
    }

    final normalized = <String, String>{};
    for (final entry in revisedDocs.entries) {
      final key = entry.key.trim();
      final path = entry.value.trim();
      if (key.isNotEmpty && path.isNotEmpty) normalized[key] = path;
    }
    final missing = current.dokumenPerluRevisi
        .where((key) => normalized[key]?.isNotEmpty != true)
        .toList();
    if (missing.isNotEmpty) {
      return PengajuanOperationResult.blocked(
        'Pilih berkas revisi untuk: ${missing.join(', ')}.',
        currentStage: current.statusTahap,
      );
    }

    final updatedUploaded = Map<String, String>.from(current.uploadedDocs)
      ..addAll(normalized);
    final updatedVerified = Map<String, bool>.from(current.verifiedDocs);
    for (final key in current.dokumenPerluRevisi) {
      // The old rejection cannot carry over to the new file version.
      updatedVerified.remove(key);
    }
    final updatedTechnicalFiles = List<String>.from(current.technicalFiles);
    final technicalPath = normalized['site_plan_dwg'];
    if (technicalPath != null) {
      if (updatedTechnicalFiles.isEmpty) {
        updatedTechnicalFiles.add(technicalPath);
      } else {
        updatedTechnicalFiles[0] = technicalPath;
      }
    }

    final updated = current.copyWith(
      uploadedDocs: updatedUploaded,
      verifiedDocs: updatedVerified,
      technicalFiles: updatedTechnicalFiles,
      status: 'Dalam Proses',
      statusTahap: origin,
      dokumenPerluRevisi: const [],
      revisionSubmitted: true,
    );
    _ref.read(pengajuanListProvider.notifier).updatePengajuan(updated);
    _ref
        .read(notifikasiProvider.notifier)
        .addNotification(
          NotifikasiModel(
            id: 'n-${DateTime.now().millisecondsSinceEpoch}',
            jenis: JenisNotifikasi.dokumenDiunggahUlang,
            judul: 'Dokumen Perbaikan Diunggah',
            deskripsi:
                'Pengembang ${current.namaPt} telah memperbarui dokumen perbaikan untuk perumahan ${current.namaPerumahan}.',
            waktu: DateTime.now(),
            isRead: false,
            targetRoute: '/admin/pengajuan/detail/${current.id}',
          ),
        );

    return PengajuanOperationResult.changed(
      message: 'Revisi dokumen berhasil diunggah dan menunggu review Admin.',
      previousStage: current.statusTahap,
      nextStage: origin,
    );
  }

  /// Read-only guard for the schedule action.
  PengajuanOperationResult jadwalSurveyGuard(String pengajuanId) {
    final current = _find(pengajuanId);
    if (current == null) {
      return const PengajuanOperationResult.blocked(
        'Pengajuan tidak ditemukan.',
      );
    }
    final effective = _effectiveStage(current);
    if (effective != StatusTahapPengajuan.verifikasiTeknis &&
        effective != StatusTahapPengajuan.surveyLapangan) {
      return const PengajuanOperationResult.blocked(
        'Jadwal survey hanya tersedia pada tahap verifikasi teknis atau survey lapangan.',
      );
    }
    if (effective == StatusTahapPengajuan.verifikasiTeknis) {
      if (_isRevisionPending(current)) {
        return PengajuanOperationResult(
          stateChanged: false,
          allowed: true,
          message: 'Revisi teknis siap ditugaskan untuk pemeriksaan lapangan.',
          previousStage: current.statusTahap,
        );
      }
      return _documentGuard(current, requiredTechnicalDocumentKeys, 'teknis');
    }
    return const PengajuanOperationResult(
      stateChanged: false,
      allowed: true,
      message: 'Jadwal survey siap diperbarui.',
    );
  }

  /// Jadwalkan (or safely reschedule) survey lapangan.
  PengajuanOperationResult jadwalkanSurvey(
    String pengajuanId,
    DateTime tanggal,
    String catatan,
  ) {
    final current = _find(pengajuanId);
    if (current == null) {
      return const PengajuanOperationResult.blocked(
        'Pengajuan tidak ditemukan.',
      );
    }
    final scheduleGuard = jadwalSurveyGuard(pengajuanId);
    if (!scheduleGuard.allowed) return scheduleGuard;
    final note = catatan.trim();
    if (current.statusTahap == StatusTahapPengajuan.surveyLapangan &&
        current.tanggalSurvey == tanggal &&
        (current.catatanSurvey ?? '') == note) {
      return const PengajuanOperationResult.blocked(
        'Jadwal survey tidak berubah.',
      );
    }

    final updated = _advance(
      current,
      StatusTahapPengajuan.surveyLapangan,
      tanggalSurvey: tanggal,
      catatanSurvey: note,
    );
    _ref.read(pengajuanListProvider.notifier).updatePengajuan(updated);

    final formattedDate =
        '${tanggal.day}/${tanggal.month}/${tanggal.year} ${tanggal.hour.toString().padLeft(2, '0')}:${tanggal.minute.toString().padLeft(2, '0')}';
    _ref
        .read(notifikasiProvider.notifier)
        .addNotification(
          NotifikasiModel(
            id: 'survey-notif-${DateTime.now().millisecondsSinceEpoch}',
            jenis: JenisNotifikasi.reminderSurvey,
            judul: 'Penugasan Survey Lapangan Baru',
            deskripsi:
                'Survey lokasi "${current.namaPerumahan}" (${current.id}) dijadwalkan pada $formattedDate WIB. Catatan: $note',
            waktu: DateTime.now(),
            isRead: false,
            targetRoute: '/pengajuan/detail/${current.id}',
          ),
        );
    return PengajuanOperationResult.changed(
      message: current.statusTahap == StatusTahapPengajuan.surveyLapangan
          ? 'Jadwal survey berhasil diperbarui.'
          : 'Jadwal survey lapangan berhasil disimpan.',
      previousStage: current.statusTahap,
      nextStage: StatusTahapPengajuan.surveyLapangan,
    );
  }

  /// Upload Berita Acara Survey. A missing picker result is not converted to a
  /// demo filename; the screen must pass a real selected path.
  PengajuanOperationResult uploadBeritaAcara(
    String pengajuanId,
    String filePath, {
    HasilSurveyItem? hasilSurvey,
  }) {
    final current = _find(pengajuanId);
    if (current == null) {
      return const PengajuanOperationResult.blocked(
        'Pengajuan tidak ditemukan.',
      );
    }
    if (_effectiveStage(current) != StatusTahapPengajuan.surveyLapangan) {
      return const PengajuanOperationResult.blocked(
        'Berita Acara hanya dapat diunggah pada tahap Survey Lapangan.',
      );
    }
    if (!_isRealFilePath(filePath, 'berita_acara_survey.pdf')) {
      return const PengajuanOperationResult.blocked(
        'Berita Acara belum dipilih. Pembatalan tidak mengubah pengajuan.',
      );
    }

    final path = filePath.trim();
    final updatedRiwayat = List<HasilSurveyItem>.from(current.riwayatSurvey);
    if (hasilSurvey != null) {
      final existing = updatedRiwayat.indexWhere((s) => s.id == hasilSurvey.id);
      if (existing == -1) {
        updatedRiwayat.insert(0, hasilSurvey);
      } else {
        updatedRiwayat[existing] = hasilSurvey;
      }
    }
    if (current.beritaAcaraPath == path &&
        (hasilSurvey == null ||
            current.riwayatSurvey.any((item) => item.id == hasilSurvey.id))) {
      return const PengajuanOperationResult.blocked(
        'Berita Acara yang sama sudah tersedia.',
      );
    }

    _ref
        .read(pengajuanListProvider.notifier)
        .updatePengajuan(
          current.copyWith(
            beritaAcaraPath: path,
            riwayatSurvey: updatedRiwayat,
          ),
        );
    return PengajuanOperationResult.changed(
      message: 'Berita Acara berhasil disimpan.',
      previousStage: current.statusTahap,
      nextStage: current.statusTahap,
    );
  }

  /// Upload SK Persetujuan akhir.
  PengajuanOperationResult uploadSkPersetujuan(
    String pengajuanId,
    String filePath,
  ) {
    final current = _find(pengajuanId);
    if (current == null) {
      return const PengajuanOperationResult.blocked(
        'Pengajuan tidak ditemukan.',
      );
    }
    if (_effectiveStage(current) != StatusTahapPengajuan.persetujuan) {
      return const PengajuanOperationResult.blocked(
        'SK Persetujuan hanya dapat diunggah pada tahap Persetujuan.',
      );
    }
    if (!_isRealFilePath(filePath, 'sk_persetujuan.pdf')) {
      return const PengajuanOperationResult.blocked(
        'SK Persetujuan belum dipilih. Pembatalan tidak mengubah pengajuan.',
      );
    }
    final path = filePath.trim();
    if (current.skPersetujuanPath == path) {
      return const PengajuanOperationResult.blocked(
        'SK Persetujuan yang sama sudah tersedia.',
      );
    }

    _ref
        .read(pengajuanListProvider.notifier)
        .updatePengajuan(current.copyWith(skPersetujuanPath: path));
    return PengajuanOperationResult.changed(
      message: 'SK Persetujuan berhasil disimpan.',
      previousStage: current.statusTahap,
      nextStage: current.statusTahap,
    );
  }

  bool _isSuccessfulApproveGuard(PengajuanOperationResult guard) {
    return guard.allowed;
  }

  bool _isRealFilePath(String value, String fallbackName) {
    final path = value.trim();
    return path.isNotEmpty && path.toLowerCase() != fallbackName.toLowerCase();
  }

  Pengajuan _advance(
    Pengajuan current,
    StatusTahapPengajuan next, {
    DateTime? tanggalSurvey,
    String? catatanSurvey,
  }) {
    final status = next == StatusTahapPengajuan.selesai
        ? 'Selesai'
        : 'Dalam Proses';
    if (current.statusTahap == StatusTahapPengajuan.perluPerbaikan ||
        current.revisionSubmitted) {
      // `Pengajuan.copyWith` intentionally keeps nullable values when passed
      // null. Rebuild the model here so the revision origin is cleared only
      // after this guarded transition succeeds.
      return Pengajuan(
        id: current.id,
        namaPerumahan: current.namaPerumahan,
        namaPt: current.namaPt,
        namaDirektur: current.namaDirektur,
        npwpPerusahaan: current.npwpPerusahaan,
        luasLahan: current.luasLahan,
        jumlahUnit: current.jumlahUnit,
        tipePerumahan: current.tipePerumahan,
        status: status,
        statusTahap: next,
        tanggal: current.tanggal,
        catatanPerbaikan: null,
        uploadedDocs: current.uploadedDocs,
        verifiedDocs: current.verifiedDocs,
        dokumenPerluRevisi: const [],
        technicalFiles: current.technicalFiles,
        selectedCakupanGambar: current.selectedCakupanGambar,
        tanggalSurvey: tanggalSurvey ?? current.tanggalSurvey,
        catatanSurvey: catatanSurvey ?? current.catatanSurvey,
        tahapAsalPerbaikan: null,
        revisionSubmitted: false,
        beritaAcaraPath: current.beritaAcaraPath,
        skPersetujuanPath: current.skPersetujuanPath,
        riwayatSurvey: current.riwayatSurvey,
      );
    }
    return current.copyWith(
      statusTahap: next,
      status: status,
      dokumenPerluRevisi: const [],
      tanggalSurvey: tanggalSurvey,
      catatanSurvey: catatanSurvey,
      revisionSubmitted: false,
      clearRevisionMetadata: current.revisionSubmitted,
    );
  }
}

final pengajuanVerifikasiControllerProvider =
    StateNotifierProvider<PengajuanVerifikasiController, AsyncValue<void>>((
      ref,
    ) {
      return PengajuanVerifikasiController(ref);
    });
