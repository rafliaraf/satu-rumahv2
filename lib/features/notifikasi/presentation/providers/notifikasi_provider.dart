import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/notifikasi_model.dart';

class NotifikasiNotifier extends StateNotifier<List<NotifikasiModel>> {
  NotifikasiNotifier()
      : super([
          NotifikasiModel(
            id: '1',
            jenis: JenisNotifikasi.pengajuanBaru,
            judul: 'Pengajuan baru',
            deskripsi: 'Griya Mangkubumi Asri (SR-2025-0148) telah diajukan dan menunggu verifikasi teknis.',
            waktu: DateTime(2025, 5, 8, 9, 21),
            isRead: false,
            targetRoute: '/admin/pengajuan/detail/SR-2025-0148',
          ),
          NotifikasiModel(
            id: '2',
            jenis: JenisNotifikasi.dokumenDiunggahUlang,
            judul: 'Permintaan perbaikan telah terkirim',
            deskripsi: 'Tamansari Asri Residence (SR-2025-0144) telah melengkapi verifikasi teknis.',
            waktu: DateTime(2025, 5, 10, 10, 0),
            isRead: false,
            targetRoute: '/admin/pengajuan/detail/SR-2025-0144',
          ),
          NotifikasiModel(
            id: '3',
            jenis: JenisNotifikasi.reminderSurvey,
            judul: 'Survey ditugaskan',
            deskripsi: 'Pesona Cibeureum Pratama (SR-2025-0146) telah diagendakan survey lokasi.',
            waktu: DateTime(2025, 5, 12, 14, 0),
            isRead: false,
            targetRoute: '/monitoring',
          ),
          NotifikasiModel(
            id: '4',
            jenis: JenisNotifikasi.deadlineVerifikasi,
            judul: 'Monitoring final tersedia',
            deskripsi: 'Hasil monitoring Bungursari Harmoni Indah (SR-2025-0145) telah disahkan Final.',
            waktu: DateTime(2025, 5, 11, 16, 0),
            isRead: true,
            targetRoute: '/monitoring',
          ),
          NotifikasiModel(
            id: '5',
            jenis: JenisNotifikasi.deadlineVerifikasi,
            judul: 'Dokumen persetujuan akhir tersedia',
            deskripsi: 'Kencana Kawalu Regency (SR-2025-0147) siap untuk survey lokasi perwaskim.',
            waktu: DateTime(2025, 5, 13, 8, 30),
            isRead: true,
          ),
        ]);

  void addNotification(NotifikasiModel item) {
    state = [item, ...state];
  }

  void markAsRead(String id) {
    state = state.map((item) => item.id == id ? item.copyWith(isRead: true) : item).toList();
  }

  void markAllAsRead() {
    state = state.map((item) => item.copyWith(isRead: true)).toList();
  }

  int get unreadCount => state.where((e) => !e.isRead).length;
}

final notifikasiProvider = StateNotifierProvider<NotifikasiNotifier, List<NotifikasiModel>>((ref) {
  return NotifikasiNotifier();
});

final unreadNotifikasiCountProvider = Provider<int>((ref) {
  final notifs = ref.watch(notifikasiProvider);
  return notifs.where((e) => !e.isRead).length;
});

final unreadCountProvider = unreadNotifikasiCountProvider;
