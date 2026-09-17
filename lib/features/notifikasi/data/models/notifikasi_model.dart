import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

enum JenisNotifikasi {
  pengajuanBaru,
  dokumenDiunggahUlang,
  reminderSurvey,
  deadlineVerifikasi,
}

extension JenisNotifikasiX on JenisNotifikasi {
  String get label {
    switch (this) {
      case JenisNotifikasi.pengajuanBaru:
        return 'Pengajuan Baru';
      case JenisNotifikasi.dokumenDiunggahUlang:
        return 'Perbaikan Dokumen';
      case JenisNotifikasi.reminderSurvey:
        return 'Reminder Survey';
      case JenisNotifikasi.deadlineVerifikasi:
        return 'Deadline Verifikasi';
    }
  }

  IconData get icon {
    switch (this) {
      case JenisNotifikasi.pengajuanBaru:
        return Icons.note_add_outlined;
      case JenisNotifikasi.dokumenDiunggahUlang:
        return Icons.replay_outlined;
      case JenisNotifikasi.reminderSurvey:
        return Icons.event_available_outlined;
      case JenisNotifikasi.deadlineVerifikasi:
        return Icons.timer_outlined;
    }
  }

  Color get color {
    switch (this) {
      case JenisNotifikasi.pengajuanBaru:
        return AppColors.info;
      case JenisNotifikasi.dokumenDiunggahUlang:
        return const Color(0xFFE65100);
      case JenisNotifikasi.reminderSurvey:
        return const Color(0xFF2E7D32);
      case JenisNotifikasi.deadlineVerifikasi:
        return AppColors.chilliDust;
    }
  }

  Color get backgroundColor {
    return color.withOpacity(0.12);
  }
}

class NotifikasiModel {
  final String id;
  final JenisNotifikasi jenis;
  final String judul;
  final String deskripsi;
  final DateTime waktu;
  final bool isRead;
  final String? targetRoute;

  NotifikasiModel({
    required this.id,
    required this.jenis,
    required this.judul,
    required this.deskripsi,
    required this.waktu,
    this.isRead = false,
    this.targetRoute,
  });

  NotifikasiModel copyWith({
    String? id,
    JenisNotifikasi? jenis,
    String? judul,
    String? deskripsi,
    DateTime? waktu,
    bool? isRead,
    String? targetRoute,
  }) {
    return NotifikasiModel(
      id: id ?? this.id,
      jenis: jenis ?? this.jenis,
      judul: judul ?? this.judul,
      deskripsi: deskripsi ?? this.deskripsi,
      waktu: waktu ?? this.waktu,
      isRead: isRead ?? this.isRead,
      targetRoute: targetRoute ?? this.targetRoute,
    );
  }
}
