import '../models/monitoring_model.dart';
import '../models/status_hasil_evaluasi.dart';

class MonitoringRepository {
  final List<MonitoringModel> _items = [
    MonitoringModel(
      id: 'm1',
      tanggalMonitoring: DateTime(2024, 5, 20),
      namaPerumahan: 'Permata Hijau Residence',
      namaDeveloper: 'PT ABC Property',
      lokasiPerumahan: 'Jl. Ir. H. Juanda No. 45, Tasikmalaya',
      statusHasilEvaluasi: StatusHasilEvaluasi.perluEvaluasiLanjutan,
      temuanLapangan: [
        'Drainase utama sudah terbangun 80%',
        'Penerangan jalan umum belum terpasang di Blok C',
      ],
      kesimpulan: [
        'Progres pembangunan PSU sesuai jadwal namun perlu percepatan PJU.',
      ],
      kesepakatan: [
        'Pengembang bersedia menyelesaikan PJU sebelum akhir bulan.',
      ],
      rencanaTindakLanjut: [
        'Pemeriksaan ulang fisik PJU pada tanggal 5 Juni 2024.',
      ],
      pelaksanaNama: 'Ir. Ahmad Subagja',
      pelaksanaJabatan: 'Ketua Tim Evaluasi DPKP',
      ditemuiNama: 'H. Endang',
      ditemuiJabatan: 'Perwakilan PT ABC Property',
    ),
    MonitoringModel(
      id: '1',
      nomorSuratBA: 'BA/PERWASKIM/2025/05/0148',
      tanggalMonitoring: DateTime(2025, 5, 22),
      namaPerumahan: 'Griya Mangkubumi Asri',
      namaDeveloper: 'PT Citra Tasik Mandiri',
      lokasiPerumahan: 'Kec. Mangkubumi, Kota Tasikmalaya',
      statusHasilEvaluasi: StatusHasilEvaluasi.perluEvaluasiLanjutan,
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
      pelaksanaNama: 'Rahmat Hidayat, S.T.',
      pelaksanaJabatan: 'Petugas Pengawas Perwaskim',
      ditemuiNama: 'H. Asep Hendrayana, S.T.',
      ditemuiJabatan: 'Penanggung Jawab Pengembang',
      isDraft: true,
    ),
    MonitoringModel(
      id: '2',
      nomorSuratBA: 'BA/PERWASKIM/2025/05/0145',
      tanggalMonitoring: DateTime(2025, 5, 11),
      namaPerumahan: 'Bungursari Harmoni Indah',
      namaDeveloper: 'PT Galunggung Asri Propertindo',
      lokasiPerumahan: 'Kec. Bungursari, Kota Tasikmalaya',
      statusHasilEvaluasi: StatusHasilEvaluasi.sesuaiSiteplan,
      temuanLapangan: [
        'Jaringan jalan paving block telah terpasang 100%.',
        'PJU dan saluran drainase tertutup berfungsi baik.',
      ],
      kesimpulan: [
        'Seluruh prasarana sarana dan utilitas sesuai spesifikasi teknis.',
      ],
      kesepakatan: [
        'Proses penyerahan PSU siap dilanjutkan ke penandatanganan Berita Acara Final.',
      ],
      rencanaTindakLanjut: [
        'Penerbitan SK Persetujuan Penyerahan PSU oleh Kepala Dinas.',
      ],
      pelaksanaNama: 'Rahmat Hidayat, S.T.',
      pelaksanaJabatan: 'Petugas Pengawas Perwaskim',
      ditemuiNama: 'Yudi Permana, S.T.',
      ditemuiJabatan: 'Direktur Pengembang',
      isDraft: false,
    ),
  ];

  List<MonitoringModel> getAllMonitoring() {
    return List.unmodifiable(
      _items..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
    );
  }

  MonitoringModel? getMonitoringById(String id) {
    try {
      return _items.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  void addMonitoring(MonitoringModel item) {
    final existingIndex = _items.indexWhere(
      (existing) => existing.id == item.id,
    );
    if (existingIndex != -1) {
      // A report ID is the local idempotency key. A retry may upgrade a draft,
      // but must never append a second record for the same submission.
      if (_items[existingIndex].isDraft && !item.isDraft) {
        _items[existingIndex] = item;
      }
      return;
    }
    _items.insert(0, item);
  }

  List<MonitoringModel> searchMonitoring({
    String? query,
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    return _items.where((item) {
      bool matchesQuery = true;
      if (query != null && query.isNotEmpty) {
        final q = query.toLowerCase();
        matchesQuery =
            item.namaPerumahan.toLowerCase().contains(q) ||
            item.namaDeveloper.toLowerCase().contains(q) ||
            item.lokasiPerumahan.toLowerCase().contains(q);
      }

      bool matchesFromDate = true;
      if (fromDate != null) {
        matchesFromDate = item.tanggalMonitoring.isAfter(
          fromDate.subtract(const Duration(days: 1)),
        );
      }

      bool matchesToDate = true;
      if (toDate != null) {
        matchesToDate = item.tanggalMonitoring.isBefore(
          toDate.add(const Duration(days: 1)),
        );
      }

      return matchesQuery && matchesFromDate && matchesToDate;
    }).toList();
  }
}
