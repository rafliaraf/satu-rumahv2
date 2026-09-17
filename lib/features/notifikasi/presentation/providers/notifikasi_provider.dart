import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/notifikasi_model.dart';

class NotifikasiNotifier extends StateNotifier<List<NotifikasiModel>> {
  NotifikasiNotifier()
      : super([
          NotifikasiModel(
            id: 'n1',
            jenis: JenisNotifikasi.pengajuanBaru,
            judul: 'Pengajuan Baru: Green Tasik Residence',
            deskripsi: 'Pengajuan (SR-20260720-586) telah diterima dan dalam verifikasi administrasi.',
            waktu: DateTime.now().subtract(const Duration(minutes: 1)),
            isRead: false,
            targetRoute: '/pengajuan/detail/SR-20260720-586',
          ),
          NotifikasiModel(
            id: 'n2',
            jenis: JenisNotifikasi.dokumenDiunggahUlang,
            judul: 'Dokumen Perbaikan Diunggah',
            deskripsi: 'Pengembang Griya Asri Kawalu telah memperbarui file KKPR yang sebelumnya buram.',
            waktu: DateTime.now().subtract(const Duration(hours: 5)),
            isRead: false,
            targetRoute: '/pengajuan/detail/SR-20260615-012',
          ),
          NotifikasiModel(
            id: 'n3',
            jenis: JenisNotifikasi.reminderSurvey,
            judul: 'Jadwal Survey Lapangan Besok',
            deskripsi: 'Survey lokasi Perumahan Permata Hijau Residence dijadwalkan pukul 09:00 WIB.',
            waktu: DateTime.now().subtract(const Duration(days: 1)),
            isRead: true,
            targetRoute: '/monitoring',
          ),
          NotifikasiModel(
            id: 'n4',
            jenis: JenisNotifikasi.deadlineVerifikasi,
            judul: 'Deadline Verifikasi Administrasi (H-1)',
            deskripsi: 'Batas akhir verifikasi dokumen teknis Bumi Tasik Lestari jatuh pada esok hari.',
            waktu: DateTime.now().subtract(const Duration(days: 2)),
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
