/// Model data hasil survey lapangan (dari MonitoringModel backend)
class HasilSurveyItem {
  final String id;
  final DateTime tanggalSurvey;
  final String pelaksanaNama;
  final String pelaksanaJabatan;
  final String lokasiPerumahan;

  /// 'sesuai' | 'tidak_sesuai' | 'perlu_perbaikan'
  final String statusHasilEvaluasi;

  final List<String> temuanLapangan;
  final List<String> kesimpulan;
  final List<String> kesepakatan;
  final List<String> rencanaTindakLanjut;
  final List<String> photoPaths;
  final String? nomorSuratBA;
  final String? beritaAcaraPath;
  final bool isDraft;

  const HasilSurveyItem({
    required this.id,
    required this.tanggalSurvey,
    required this.pelaksanaNama,
    required this.pelaksanaJabatan,
    required this.lokasiPerumahan,
    required this.statusHasilEvaluasi,
    this.temuanLapangan = const [],
    this.kesimpulan = const [],
    this.kesepakatan = const [],
    this.rencanaTindakLanjut = const [],
    this.photoPaths = const [],
    this.nomorSuratBA,
    this.beritaAcaraPath,
    this.isDraft = false,
  });

  bool get sudahTerlaksana => !isDraft && photoPaths.isNotEmpty;

  bool get hasBa => beritaAcaraPath != null && beritaAcaraPath!.isNotEmpty;

  String get statusLabel {
    switch (statusHasilEvaluasi) {
      case 'sesuai':
        return 'Sesuai';
      case 'tidak_sesuai':
        return 'Tidak Sesuai';
      case 'perlu_perbaikan':
        return 'Perlu Perbaikan';
      default:
        return statusHasilEvaluasi;
    }
  }

  factory HasilSurveyItem.fromJson(Map<String, dynamic> json) {
    return HasilSurveyItem(
      id: json['id'] as String,
      tanggalSurvey: DateTime.parse(json['tanggalMonitoring'] as String),
      pelaksanaNama: json['pelaksanaNama'] as String? ?? '-',
      pelaksanaJabatan: json['pelaksanaJabatan'] as String? ?? '-',
      lokasiPerumahan: json['lokasiPerumahan'] as String? ?? '-',
      statusHasilEvaluasi: json['statusHasilEvaluasi'] as String? ?? 'sesuai',
      temuanLapangan: (json['temuanLapangan'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      kesimpulan: (json['kesimpulan'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      kesepakatan: (json['kesepakatan'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      rencanaTindakLanjut: (json['rencanaTindakLanjut'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      photoPaths: (json['photoPaths'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      nomorSuratBA: json['nomorSuratBA'] as String?,
      isDraft: json['isDraft'] as bool? ?? false,
    );
  }
}
