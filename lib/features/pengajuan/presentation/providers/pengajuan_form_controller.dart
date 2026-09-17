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

// Repository data pengajuan (statis di memori)
class PengajuanListNotifier extends StateNotifier<List<Pengajuan>> {
  PengajuanListNotifier()
    : super([
        Pengajuan(
          id: 'SR-20260710-045',
          namaPerumahan: 'Mutiara Regency Tasik',
          namaPt: 'PT. Tasik Indah Sentosa',
          namaDirektur: 'H. Tatang Sutisna',
          npwpPerusahaan: '09.123.456.7-423.000',
          luasLahan: 20000.0,
          jumlahUnit: 120,
          tipePerumahan: 'Komersil',
          status: 'Dalam Proses',
          statusTahap: StatusTahapPengajuan.verifikasiAdministrasi,
          tanggal: '10 Juli 2026',
          uploadedDocs: {
            'ktp': 'ktp_direktur.pdf',
            'nib': 'nib_perusahaan.pdf',
            'npwp_doc': 'npwp_perusahaan.pdf',
            'asosiasi': 'bukti_asosiasi.pdf',
            'legalitas': 'legalitas_pt.pdf',
            'site_plan_dwg': 'design_siteplan_layout.dwg',
          },
          technicalFiles: [
            'design_siteplan_layout.dwg',
            'berkas_gambar_teknis_lengkap.pdf',
          ],
          selectedCakupanGambar: [
            '1 Cover',
            '2 Lembar Pengesahan Rencana Tapak',
            '3 Daftar Rincian Prasarana, Sarana dan Utilitas',
            '7 Peta Lokasi',
            '8 Gambar Batas Tanah yang Dikuasai',
            '9 Gambar & Hasil Penyelidikan Tanah',
            '10 Gambar Rencana Tapak (Site Plan)',
            '11 Gambar RTH',
            '12 Gambar Perancangan Jaringan Jalan',
            '13 Gambar Perancangan Drainase',
            '14 Gambar Perancangan Jaringan Air Limbah',
            '15 Gambar Perancangan Jaringan Air Bersih',
            '16 Gambar Perencanaan Utilitas PJU',
            '17 Gambar Perencanaan Unit Rumah (Arsitektural)',
          ],
        ),
        Pengajuan(
          id: 'SR-20260615-012',
          namaPerumahan: 'Griya Asri Kawalu',
          namaPt: 'PT. Tasik Indah Sentosa',
          namaDirektur: 'H. Tatang Sutisna',
          npwpPerusahaan: '09.123.456.7-423.000',
          luasLahan: 8500.0,
          jumlahUnit: 45,
          tipePerumahan: 'Subsidi',
          status: 'Perlu Perbaikan',
          statusTahap: StatusTahapPengajuan.perluPerbaikan,
          tahapAsalPerbaikan: StatusTahapPengajuan.verifikasiAdministrasi,
          tanggal: '15 Juni 2026',
          catatanPerbaikan:
              'Dokumen Kesesuaian Tata Ruang tidak terbaca/buram. Harap unggah ulang file dengan resolusi lebih tinggi.',
          dokumenPerluRevisi: ['kkpr_doc'],
          uploadedDocs: {
            'ktp': 'ktp_direktur.pdf',
            'nib': 'nib_perusahaan.pdf',
            'kkpr_doc': 'kkpr_buram.pdf',
          },
        ),
        Pengajuan(
          id: 'SR-20260520-008',
          namaPerumahan: 'Bumi Tasik Lestari',
          namaPt: 'PT. Tasik Indah Sentosa',
          namaDirektur: 'H. Tatang Sutisna',
          npwpPerusahaan: '09.123.456.7-423.000',
          luasLahan: 12000.0,
          jumlahUnit: 70,
          tipePerumahan: 'Komersil',
          status: 'Selesai',
          statusTahap: StatusTahapPengajuan.selesai,
          tanggal: '20 Mei 2026',
          uploadedDocs: {'ktp': 'ktp.pdf', 'nib': 'nib.pdf'},
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
          catatanSurvey:
              'Titik kumpul di gerbang utama jam 09:00 WIB. Wajib didampingi Site Manager.',
          uploadedDocs: {
            'ktp': 'ktp_direktur_tatang.pdf',
            'nib': 'nib_perusahaan.pdf',
            'npwp_doc': 'npwp_perusahaan.pdf',
            'asosiasi': 'bukti_asosiasi.pdf',
            'legalitas': 'akta_pendirian.pdf',
            'surat_permohonan': 'surat_permohonan.pdf',
            'site_plan_dwg': 'siteplan_greentasik.dwg',
          },
          technicalFiles: [
            'siteplan_greentasik.dwg',
            'berkas_gambar_teknis_greentasik.pdf',
          ],
          selectedCakupanGambar: [
            '1 Cover',
            '2 Lembar Pengesahan Rencana Tapak',
            '10 Gambar Rencana Tapak (Site Plan)',
            '11 Gambar RTH',
            '12 Gambar Perancangan Jaringan Jalan',
            '13 Gambar Perancangan Drainase',
            '14 Gambar Perancangan Jaringan Air Limbah',
            '15 Gambar Perancangan Jaringan Air Bersih',
            '17 Gambar Perencanaan Unit Rumah (Arsitektural)',
            '20 Gambar Perancangan Keamanan (Pos Satpam/Gapura/Pagar)',
          ],
          riwayatSurvey: [
            HasilSurveyItem(
              id: 'survey-001',
              tanggalSurvey: DateTime(2026, 6, 20, 9, 0),
              pelaksanaNama: 'Dimas Pratama, S.T.',
              pelaksanaJabatan: 'Inspektur Lapangan I',
              lokasiPerumahan: 'Blok C-12, Kota Tasikmalaya',
              statusHasilEvaluasi: 'sesuai',
              temuanLapangan: [
                'Pembangunan unit dan prasarana lingkungan telah sesuai dengan dokumen teknis yang diajukan.',
                'Akses jalan lingkungan dalam kondisi baik dan utilitas dasar telah tersedia.',
              ],
              kesimpulan: [
                'Kesesuaian pembangunan telah terpenuhi sesuai site plan yang disahkan.',
              ],
              kesepakatan: [
                'Pengembang akan melengkapi rambu-rambu jalan dalam 14 hari kerja.',
              ],
              rencanaTindakLanjut: [
                'Follow up pemasangan rambu jalan di blok C-D.',
              ],
              photoPaths: const [],
              nomorSuratBA: 'BA/PERWASKIM/2026/06/042',
              isDraft: false,
            ),
            HasilSurveyItem(
              id: 'survey-000',
              tanggalSurvey: DateTime(2026, 6, 12, 9, 0),
              pelaksanaNama: 'Budi Santoso, S.T.',
              pelaksanaJabatan: 'Inspektur Lapangan II',
              lokasiPerumahan: 'Blok A-B, Kota Tasikmalaya',
              statusHasilEvaluasi: 'perlu_perbaikan',
              temuanLapangan: [
                'Drainase pada blok B belum selesai dikerjakan.',
                'Terdapat ketidaksesuaian lebar jalan dengan gambar site plan.',
              ],
              kesimpulan: [
                'Perlu perbaikan sebelum dapat dilanjutkan ke tahap persetujuan.',
              ],
              photoPaths: const [],
              nomorSuratBA: 'BA/PERWASKIM/2026/06/031',
              isDraft: false,
            ),
          ],
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
