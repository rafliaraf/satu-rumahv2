import 'hasil_survey_model.dart';
import 'status_tahap_pengajuan.dart';

class Pengajuan {
  final String id;
  final String namaPerumahan;
  final String namaPt;
  final String namaDirektur;
  final String npwpPerusahaan;
  final double luasLahan;
  final int jumlahUnit;
  final String tipePerumahan; // Subsidi, Komersil, Keduanya
  final String status; // Dalam Proses, Selesai, Perlu Perbaikan
  final StatusTahapPengajuan statusTahap;
  final String tanggal;
  final String? catatanPerbaikan;
  final Map<String, String> uploadedDocs; // Nama file terupload per dokumen key
  final Map<String, bool>
  verifiedDocs; // Key dokumen -> true (sesuai) / false (tidak sesuai)
  final List<String> dokumenPerluRevisi;
  final List<String> technicalFiles; // Daftar file teknis multi-upload Step 4
  final List<String>
  selectedCakupanGambar; // Item cakupan gambar teknis yang dicentang
  final DateTime? tanggalSurvey;
  final String? catatanSurvey;
  final StatusTahapPengajuan? tahapAsalPerbaikan;
  /// True after the developer has uploaded all requested revision files and
  /// the submission is waiting for an explicit Admin decision.
  final bool revisionSubmitted;
  final String? beritaAcaraPath;
  final String? skPersetujuanPath;
  final List<HasilSurveyItem> riwayatSurvey;

  Pengajuan({
    required this.id,
    required this.namaPerumahan,
    required this.namaPt,
    required this.namaDirektur,
    required this.npwpPerusahaan,
    required this.luasLahan,
    required this.jumlahUnit,
    required this.tipePerumahan,
    required this.status,
    this.statusTahap = StatusTahapPengajuan.verifikasiAdministrasi,
    required this.tanggal,
    this.catatanPerbaikan,
    required this.uploadedDocs,
    this.verifiedDocs = const {},
    this.dokumenPerluRevisi = const [],
    this.technicalFiles = const [],
    this.selectedCakupanGambar = const [],
    this.tanggalSurvey,
    this.catatanSurvey,
    this.tahapAsalPerbaikan,
    this.revisionSubmitted = false,
    this.beritaAcaraPath,
    this.skPersetujuanPath,
    this.riwayatSurvey = const [],
  });

  Pengajuan copyWith({
    String? id,
    String? namaPerumahan,
    String? namaPt,
    String? namaDirektur,
    String? npwpPerusahaan,
    double? luasLahan,
    int? jumlahUnit,
    String? tipePerumahan,
    String? status,
    StatusTahapPengajuan? statusTahap,
    String? tanggal,
    String? catatanPerbaikan,
    Map<String, String>? uploadedDocs,
    Map<String, bool>? verifiedDocs,
    List<String>? dokumenPerluRevisi,
    List<String>? technicalFiles,
    List<String>? selectedCakupanGambar,
    DateTime? tanggalSurvey,
    String? catatanSurvey,
    StatusTahapPengajuan? tahapAsalPerbaikan,
    bool? revisionSubmitted,
    bool clearRevisionMetadata = false,
    Object? beritaAcaraPath = _sentinel,
    Object? skPersetujuanPath = _sentinel,
    List<HasilSurveyItem>? riwayatSurvey,
  }) {
    return Pengajuan(
      id: id ?? this.id,
      namaPerumahan: namaPerumahan ?? this.namaPerumahan,
      namaPt: namaPt ?? this.namaPt,
      namaDirektur: namaDirektur ?? this.namaDirektur,
      npwpPerusahaan: npwpPerusahaan ?? this.npwpPerusahaan,
      luasLahan: luasLahan ?? this.luasLahan,
      jumlahUnit: jumlahUnit ?? this.jumlahUnit,
      tipePerumahan: tipePerumahan ?? this.tipePerumahan,
      status: status ?? this.status,
      statusTahap: statusTahap ?? this.statusTahap,
      tanggal: tanggal ?? this.tanggal,
      catatanPerbaikan: clearRevisionMetadata
          ? null
          : catatanPerbaikan ?? this.catatanPerbaikan,
      uploadedDocs: uploadedDocs ?? this.uploadedDocs,
      verifiedDocs: verifiedDocs ?? this.verifiedDocs,
      dokumenPerluRevisi: dokumenPerluRevisi ?? this.dokumenPerluRevisi,
      technicalFiles: technicalFiles ?? this.technicalFiles,
      selectedCakupanGambar:
          selectedCakupanGambar ?? this.selectedCakupanGambar,
      tanggalSurvey: tanggalSurvey ?? this.tanggalSurvey,
      catatanSurvey: catatanSurvey ?? this.catatanSurvey,
      tahapAsalPerbaikan: clearRevisionMetadata
          ? null
          : tahapAsalPerbaikan ?? this.tahapAsalPerbaikan,
      revisionSubmitted: revisionSubmitted ?? this.revisionSubmitted,
      beritaAcaraPath: beritaAcaraPath == _sentinel
          ? this.beritaAcaraPath
          : beritaAcaraPath as String?,
      skPersetujuanPath: skPersetujuanPath == _sentinel
          ? this.skPersetujuanPath
          : skPersetujuanPath as String?,
      riwayatSurvey: riwayatSurvey ?? this.riwayatSurvey,
    );
  }
}

/// Sentinel untuk nullable copyWith
const Object _sentinel = Object();
