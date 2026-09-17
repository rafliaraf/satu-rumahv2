import 'status_hasil_evaluasi.dart';

class MonitoringModel {
  static const String defaultMaksudTujuan =
      'Kegiatan ini dilaksanakan guna memastikan kesesuaian pelaksanaan dengan '
      'perencanaan sebagai bagian dari fungsi pengawasan dan pengendalian '
      'terhadap proses pembangunan perumahan beserta penyediaan PSU-nya.';

  static const List<String> _bulanRomawi = [
    'I', 'II', 'III', 'IV', 'V', 'VI',
    'VII', 'VIII', 'IX', 'X', 'XI', 'XII'
  ];

  /// Generate nomor surat BA: 600.2.5/BA-MON/[bulanRomawi]/[tahun]
  static String generateNomorSuratBA(DateTime tanggal) {
    final bulan = _bulanRomawi[tanggal.month - 1];
    final tahun = tanggal.year;
    return '600.2.5/BA-MON/$bulan/$tahun';
  }

  final String id;
  final String? pengajuanId;
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
  final DateTime createdAt;
  final String nomorSuratBA;
  final bool isDraft;

  MonitoringModel({
    required this.id,
    this.pengajuanId,
    required this.tanggalMonitoring,
    required this.namaPerumahan,
    this.namaDeveloper = '',
    this.lokasiPerumahan = '',
    this.maksudTujuan = defaultMaksudTujuan,
    this.temuanLapangan = const [],
    this.kesimpulan = const [],
    this.kesepakatan = const [],
    this.rencanaTindakLanjut = const [],
    this.statusHasilEvaluasi = StatusHasilEvaluasi.sesuaiSiteplan,
    this.pelaksanaNama = '',
    this.pelaksanaJabatan = '',
    this.ditemuiNama = '',
    this.ditemuiJabatan = '',
    this.photoPaths = const [],
    DateTime? createdAt,
    String? nomorSuratBA,
    this.isDraft = false,
  })  : createdAt = createdAt ?? DateTime.now(),
        nomorSuratBA = nomorSuratBA ?? generateNomorSuratBA(tanggalMonitoring);

  MonitoringModel copyWith({
    String? id,
    String? pengajuanId,
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
    DateTime? createdAt,
    String? nomorSuratBA,
    bool? isDraft,
  }) {
    return MonitoringModel(
      id: id ?? this.id,
      pengajuanId: pengajuanId ?? this.pengajuanId,
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
      createdAt: createdAt ?? this.createdAt,
      nomorSuratBA: nomorSuratBA ?? this.nomorSuratBA,
      isDraft: isDraft ?? this.isDraft,
    );
  }
}
