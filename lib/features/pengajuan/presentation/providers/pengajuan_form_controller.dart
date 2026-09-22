import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/hasil_survey_model.dart';
import '../../data/models/pengajuan_model.dart';
import '../../data/models/status_tahap_pengajuan.dart';

class PengajuanFormState {
  final String namaPerumahan;
  final String npwpPerusahaan;
  final double luasLahan;
  final int jumlahUnit;
  final String tipePerumahan;
  final Map<String, String> uploadedDocs;
  final List<String> technicalFiles;
  final Set<String> selectedCakupanGambar;
  final bool isAgreed;

  PengajuanFormState({
    this.namaPerumahan = '',
    this.npwpPerusahaan = '',
    this.luasLahan = 0.0,
    this.jumlahUnit = 0,
    this.tipePerumahan = 'Subsidi',
    this.uploadedDocs = const {},
    this.technicalFiles = const [],
    this.selectedCakupanGambar = const {},
    this.isAgreed = false,
  });

  bool get isStep1Valid =>
      namaPerumahan.trim().isNotEmpty &&
      npwpPerusahaan.trim().isNotEmpty &&
      luasLahan.isFinite &&
      luasLahan > 0 &&
      jumlahUnit > 0;

  bool get isStep2Valid =>
      _hasDocument('ktp') &&
      _hasDocument('nib') &&
      _hasDocument('npwp_doc') &&
      _hasDocument('asosiasi') &&
      _hasDocument('legalitas');

  bool get isStep3Valid =>
      _hasDocument('surat_permohonan') &&
      _hasDocument('info_intensitas_ruang') &&
      _hasDocument('bukti_kepemilikan_lahan') &&
      _hasDocument('bukti_tpu') &&
      _hasDocument('kkpr_doc') &&
      _hasDocument('pbg_induk') &&
      _hasDocument('rekomendasi_lingkungan') &&
      _hasDocument('pernyataan_pelepasan') &&
      _hasDocument('pernyataan_keabsahan') &&
      _hasDocument('pernyataan_psu');

  bool get isStep4Valid =>
      _hasDocument('site_plan_dwg') ||
      technicalFiles.any((file) => file.trim().isNotEmpty);

  bool get isAllValid =>
      isStep1Valid && isStep2Valid && isStep3Valid && isStep4Valid && isAgreed;

  bool _hasDocument(String key) => uploadedDocs[key]?.trim().isNotEmpty == true;

  PengajuanFormState copyWith({
    String? namaPerumahan,
    String? npwpPerusahaan,
    double? luasLahan,
    int? jumlahUnit,
    String? tipePerumahan,
    Map<String, String>? uploadedDocs,
    List<String>? technicalFiles,
    Set<String>? selectedCakupanGambar,
    bool? isAgreed,
  }) {
    return PengajuanFormState(
      namaPerumahan: namaPerumahan ?? this.namaPerumahan,
      npwpPerusahaan: npwpPerusahaan ?? this.npwpPerusahaan,
      luasLahan: luasLahan ?? this.luasLahan,
      jumlahUnit: jumlahUnit ?? this.jumlahUnit,
      tipePerumahan: tipePerumahan ?? this.tipePerumahan,
      uploadedDocs: uploadedDocs ?? Map.from(this.uploadedDocs),
      technicalFiles: technicalFiles ?? List.from(this.technicalFiles),
      selectedCakupanGambar:
          selectedCakupanGambar ?? Set.from(this.selectedCakupanGambar),
      isAgreed: isAgreed ?? this.isAgreed,
    );
  }
}

class PengajuanFormNotifier extends StateNotifier<PengajuanFormState> {
  PengajuanFormNotifier() : super(PengajuanFormState());

  void updateNamaPerumahan(String value) =>
      state = state.copyWith(namaPerumahan: value);
  void updateNpwp(String value) =>
      state = state.copyWith(npwpPerusahaan: value);
  void updateLuasLahan(double value) =>
      state = state.copyWith(luasLahan: value);
  void updateJumlahUnit(int value) => state = state.copyWith(jumlahUnit: value);
  void updateTipe(String value) => state = state.copyWith(tipePerumahan: value);
  void toggleAgreement(bool value) => state = state.copyWith(isAgreed: value);

  void uploadDocument(String key, String fileName) {
    if (key.trim().isEmpty || fileName.trim().isEmpty) return;
    final updated = Map<String, String>.from(state.uploadedDocs);
    updated[key] = fileName;
    state = state.copyWith(uploadedDocs: updated);
  }

  void deleteDocument(String key) {
    final updated = Map<String, String>.from(state.uploadedDocs);
    updated.remove(key);
    state = state.copyWith(uploadedDocs: updated);
  }

  void addTechnicalFiles(List<String> filePaths) {
    final current = List<String>.from(state.technicalFiles);
    for (var path in filePaths) {
      if (path.trim().isEmpty) continue;
      if (!current.contains(path)) {
        current.add(path);
      }
    }
    final updatedDocs = Map<String, String>.from(state.uploadedDocs);
    if (current.isNotEmpty && !updatedDocs.containsKey('site_plan_dwg')) {
      updatedDocs['site_plan_dwg'] = current.first;
    }
    state = state.copyWith(technicalFiles: current, uploadedDocs: updatedDocs);
  }

  void removeTechnicalFile(int index) {
    final current = List<String>.from(state.technicalFiles);
    if (index >= 0 && index < current.length) {
      current.removeAt(index);
    }
    final updatedDocs = Map<String, String>.from(state.uploadedDocs);
    if (current.isEmpty) {
      updatedDocs.remove('site_plan_dwg');
    } else {
      updatedDocs['site_plan_dwg'] = current.first;
    }
    state = state.copyWith(technicalFiles: current, uploadedDocs: updatedDocs);
  }

  void toggleCakupanGambar(String item) {
    final current = Set<String>.from(state.selectedCakupanGambar);
    if (current.contains(item)) {
      current.remove(item);
    } else {
      current.add(item);
    }
    state = state.copyWith(selectedCakupanGambar: current);
  }

  void selectAllCakupanGambar(List<String> allItems) {
    state = state.copyWith(selectedCakupanGambar: Set.from(allItems));
  }

  void clearCakupanGambar() {
    state = state.copyWith(selectedCakupanGambar: {});
  }

  void reset() {
    state = PengajuanFormState();
  }

  void fillDummyData() {
    state = PengajuanFormState(
      namaPerumahan: 'Green Tasik Residence',
      npwpPerusahaan: '12.345.678.9-423.000',
      luasLahan: 15000,
      jumlahUnit: 85,
      tipePerumahan: 'Subsidi',
      uploadedDocs: {
        'ktp': 'ktp_direktur_tatang.pdf',
        'nib': 'nib_perusahaan_pembangunan.pdf',
        'npwp_doc': 'npwp_perusahaan_official.pdf',
        'asosiasi': 'bukti_anggota_rei.pdf',
        'legalitas': 'akta_pendirian_pt_tasik.pdf',
        'surat_permohonan': 'surat_permohonan_persetujuan.pdf',
        'info_intensitas_ruang': 'info_intensitas_ruang.pdf',
        'bukti_kepemilikan_lahan': 'bukti_kepemilikan_lahan.pdf',
        'bukti_tpu': 'bukti_penyediaan_lahan_tpu.pdf',
        'kkpr_doc': 'kesesuaian_tata_ruang_2026.pdf',
        'pbg_induk': 'persetujuan_imb_induk.pdf',
        'rekomendasi_lingkungan': 'rekomendasi_amdal_sppl.pdf',
        'pelepasan_lahan': 'rekomendasi_pelepasan_lahan.pdf',
        'pernyataan_pelepasan': 'pernyataan_pelepasan_hak.pdf',
        'pernyataan_keabsahan': 'pernyataan_keabsahan_dokumen.pdf',
        'pernyataan_psu': 'pernyataan_kesanggupan_psu.pdf',
        'site_plan_dwg': 'design_siteplan_layout.dwg',
      },
      technicalFiles: [
        'design_siteplan_layout.dwg',
        'berkas_gambar_teknis_lengkap.pdf',
      ],
      selectedCakupanGambar: {
        '1 Cover',
        '2 Lembar Pengesahan Rencana Tapak',
        '10 Gambar Rencana Tapak (Site Plan)',
        '8 Gambar Batas Tanah yang Dikuasai',
        '9 Gambar & Hasil Penyelidikan Tanah',
        '11 Gambar RTH',
        '12 Gambar Perancangan Jaringan Jalan',
        '13 Gambar Perancangan Drainase',
        '14 Gambar Perancangan Jaringan Air Limbah',
        '15 Gambar Perancangan Jaringan Air Bersih',
        '17 Gambar Perencanaan Unit Rumah (Arsitektural)',
      },
      isAgreed: true,
    );
  }
}

final pengajuanFormProvider =
    StateNotifierProvider<PengajuanFormNotifier, PengajuanFormState>((ref) {
      return PengajuanFormNotifier();
    });

// Repository data pengajuan disinkronkan dengan database satu_rumah.sql (Admin Disperwaskim)
class PengajuanListNotifier extends StateNotifier<List<Pengajuan>> {
  PengajuanListNotifier()
    : super([
        Pengajuan(
          id: 'SR-2025-0148',
          namaPerumahan: 'Griya Mangkubumi Asri',
          namaPt: 'PT Citra Tasik Mandiri',
          namaDirektur: 'H. Asep Hendrayana, S.T.',
          npwpPerusahaan: '09.123.456.7-423.000',
          luasLahan: 34800.0,
          jumlahUnit: 148,
          tipePerumahan: 'Subsidi',
          status: 'Terjadwal',
          statusTahap: StatusTahapPengajuan.surveyLapangan,
          tanggal: '08 Mei 2025 · 09.21 WIB',
          catatanSurvey:
              'Seluruh dokumen administrasi & teknis telah diverifikasi sesuai. Survey lokasi dijadwalkan tanggal 22 Mei 2025 pukul 09.00 WIB.',
          dokumenPerluRevisi: const [],
          uploadedDocs: {
            'nib': 'nib_dan_izin_usaha.pdf',
            'npwp_doc': 'npwp_perusahaan.pdf',
            'legalitas': 'akta_pendirian_perusahaan.pdf',
            'ktp': 'ktp_direktur_utama.pdf',
            'surat_kuasa': 'surat_kuasa_penanggung_jawab.pdf',
            'site_plan_dwg': 'site_plan_yang_disahkan.pdf',
            'bukti_kepemilikan_lahan': 'bukti_kepemilikan_tanah.pdf',
            'rekomendasi_lingkungan': 'persetujuan_lingkungan.pdf',
            'pbg_induk': 'izin_pbg.pdf',
            'pernyataan_pelepasan': 'surat_pernyataan_pengembang.pdf',
          },
          technicalFiles: [
            'Paket_tekdok_GriyaMahardika.zip',
            'gambar_rencana_tapak.pdf',
            'rencana_utilitas.pdf',
            'rencana_drainase.pdf',
          ],
          selectedCakupanGambar: [
            '10 Gambar Rencana Tapak (Site Plan)',
            '12 Gambar Perancangan Jaringan Jalan',
            '13 Gambar Perancangan Drainase',
            '15 Gambar Perancangan Jaringan Air Bersih',
          ],
          tanggalSurvey: DateTime(2025, 5, 22, 9, 0),
          riwayatSurvey: [
            HasilSurveyItem(
              id: 'survey-0148',
              tanggalSurvey: DateTime(2025, 5, 22, 9, 0),
              pelaksanaNama: 'Rahmat Hidayat, S.T.',
              pelaksanaJabatan: 'Tim Pengawas Perwaskim',
              lokasiPerumahan: 'Kec. Mangkubumi, Kota Tasikmalaya',
              statusHasilEvaluasi: 'perluEvaluasi',
              temuanLapangan: [
                'Saluran drainase sisi timur belum sesuai detail rencana.',
                'Akses kendaraan pemadam perlu penegasan pada area tikungan blok C.',
              ],
              kesimpulan: [
                'Kawasan dapat dilanjutkan setelah perbaikan desain drainase dan penyampaian revisi gambar teknis.',
              ],
              kesepakatan: [
                'Pengembang akan mengunggah revisi dalam 7 hari kerja.',
              ],
              rencanaTindakLanjut: [
                'RENCANA TINDAK LANJUT WAJIB: Perbarui gambar drainase dan lengkapi simulasi manuver kendaraan pemadam sebelum persetujuan dilanjutkan.',
              ],
              photoPaths: const [],
              nomorSuratBA: 'BA/PERWASKIM/2025/05/0148',
              isDraft: true,
            ),
          ],
        ),
        Pengajuan(
          id: 'SR-2025-0147',
          namaPerumahan: 'Kencana Kawalu Regency',
          namaPt: 'PT Sukapura Mandiri Properti',
          namaDirektur: 'Dedi Setiadi, S.T.',
          npwpPerusahaan: '08.234.567.8-423.000',
          luasLahan: 18500.0,
          jumlahUnit: 85,
          tipePerumahan: 'Subsidi',
          status: 'Terjadwal',
          statusTahap: StatusTahapPengajuan.surveyLapangan,
          tanggal: '12 Mei 2025 · 15.20 WIB',
          tanggalSurvey: DateTime(2025, 5, 20, 9, 0),
          catatanSurvey:
              'Jadwal survey lokasi telah dikonfirmasi untuk tanggal 20 Mei 2025. Titik kumpul Kantor Pemasaran Kawalu.',
          uploadedDocs: {
            'ktp': 'ktp_direktur.pdf',
            'nib': 'nib_sukapura.pdf',
            'npwp_doc': 'npwp_sukapura.pdf',
            'site_plan_dwg': 'siteplan_kencana.pdf',
          },
        ),
        Pengajuan(
          id: 'SR-2025-0146',
          namaPerumahan: 'Pesona Cibeureum Pratama',
          namaPt: 'PT Priangan Griya Graha',
          namaDirektur: 'Ir. Tatan Rustandi',
          npwpPerusahaan: '07.345.678.9-423.000',
          luasLahan: 26000.0,
          jumlahUnit: 120,
          tipePerumahan: 'Subsidi',
          status: 'Menunggu verifikasi',
          statusTahap: StatusTahapPengajuan.verifikasiAdministrasi,
          tanggal: '12 Mei 2025',
          catatanPerbaikan:
              'Dokumen persyaratan lengkap dan siap diperiksa tim administratif Disperwaskim.',
          uploadedDocs: {
            'ktp': 'ktp_tatan.pdf',
            'nib': 'nib_priangan.pdf',
            'npwp_doc': 'npwp_priangan.pdf',
            'site_plan_dwg': 'siteplan_pesona.pdf',
          },
        ),
        Pengajuan(
          id: 'SR-2025-0145',
          namaPerumahan: 'Bungursari Harmoni Indah',
          namaPt: 'PT Galunggung Asri Propertindo',
          namaDirektur: 'Yudi Permana, S.T.',
          npwpPerusahaan: '06.456.789.0-423.000',
          luasLahan: 21200.0,
          jumlahUnit: 96,
          tipePerumahan: 'Komersil',
          status: 'Final',
          statusTahap: StatusTahapPengajuan.selesai,
          tanggal: '11 Mei 2025',
          catatanSurvey:
              'Hasil monitoring lapangan telah berstatus Final dan Berita Acara telah diterbitkan.',
          uploadedDocs: {'ktp': 'ktp_yudi.pdf', 'nib': 'nib_galunggung.pdf'},
        ),
        Pengajuan(
          id: 'SR-2025-0144',
          namaPerumahan: 'Tamansari Asri Residence',
          namaPt: 'PT Mitra Sejahtera Tasik',
          namaDirektur: 'Ahmad Fauzi, S.T.',
          npwpPerusahaan: '05.567.890.1-423.000',
          luasLahan: 38000.0,
          jumlahUnit: 160,
          tipePerumahan: 'Komersil',
          status: 'Siap disetujui',
          statusTahap: StatusTahapPengajuan.persetujuan,
          tanggal: '10 Mei 2025',
          catatanPerbaikan:
              'Seluruh tahapan verifikasi teknis dan monitoring telah terpenuhi.',
          uploadedDocs: {'ktp': 'ktp_ahmad.pdf', 'nib': 'nib_mitra.pdf'},
        ),
        Pengajuan(
          id: 'SR-20260720-612',
          namaPerumahan: 'Green Tasik',
          namaPt: 'PT. Tasik Indah Sentosa',
          namaDirektur: 'H. Tatang Sutisna',
          npwpPerusahaan: '09.123.456.7-423.000',
          luasLahan: 15000.0,
          jumlahUnit: 85,
          tipePerumahan: 'Subsidi',
          status: 'Dalam Proses',
          statusTahap: StatusTahapPengajuan.surveyLapangan,
          tanggal: '20 Juli 2026',
          tanggalSurvey: DateTime(2026, 6, 20, 9, 0),
          uploadedDocs: {
            'ktp': 'ktp_direktur_tatang.pdf',
            'nib': 'nib_perusahaan.pdf',
          },
        ),
      ]);

  void addPengajuan(Pengajuan p) {
    state = [p, ...state];
  }

  bool addPengajuanIfAbsent(Pengajuan p) {
    if (state.any((item) => item.id == p.id)) return false;
    addPengajuan(p);
    return true;
  }

  void updatePengajuan(Pengajuan p) {
    state = state.map((item) => item.id == p.id ? p : item).toList();
  }

  void updatePengajuanStatus(String id, String status) {
    state = state
        .map((item) => item.id == id ? item.copyWith(status: status) : item)
        .toList();
  }
}

final pengajuanListProvider =
    StateNotifierProvider<PengajuanListNotifier, List<Pengajuan>>((ref) {
      return PengajuanListNotifier();
    });
