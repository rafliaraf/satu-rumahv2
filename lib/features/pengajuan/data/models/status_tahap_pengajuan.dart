import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

enum StatusTahapPengajuan {
  pengajuanBaru,
  verifikasiAdministrasi,
  verifikasiTeknis,
  surveyLapangan,
  persetujuan,
  selesai,
  perluPerbaikan,
}

extension StatusTahapPengajuanX on StatusTahapPengajuan {
  String get label {
    switch (this) {
      case StatusTahapPengajuan.pengajuanBaru:
        return 'Pengajuan Baru';
      case StatusTahapPengajuan.verifikasiAdministrasi:
        return 'Verifikasi Administrasi';
      case StatusTahapPengajuan.verifikasiTeknis:
        return 'Verifikasi Teknis';
      case StatusTahapPengajuan.surveyLapangan:
        return 'Survey Lapangan';
      case StatusTahapPengajuan.persetujuan:
        return 'Persetujuan';
      case StatusTahapPengajuan.selesai:
        return 'Selesai';
      case StatusTahapPengajuan.perluPerbaikan:
        return 'Perlu Perbaikan';
    }
  }

  Color get color {
    switch (this) {
      case StatusTahapPengajuan.pengajuanBaru:
        return AppColors.info;
      case StatusTahapPengajuan.verifikasiAdministrasi:
        return AppColors.statusInfo;
      case StatusTahapPengajuan.verifikasiTeknis:
        return AppColors.statusTechnical;
      case StatusTahapPengajuan.surveyLapangan:
        return AppColors.statusSurvey;
      case StatusTahapPengajuan.persetujuan:
        return AppColors.statusApproved;
      case StatusTahapPengajuan.selesai:
        return AppColors.statusCompleted;
      case StatusTahapPengajuan.perluPerbaikan:
        return AppColors.chilliDust;
    }
  }

  Color get backgroundColor {
    return color.withValues(alpha: 0.12);
  }

  IconData get icon {
    switch (this) {
      case StatusTahapPengajuan.pengajuanBaru:
        return Icons.fiber_new;
      case StatusTahapPengajuan.verifikasiAdministrasi:
        return Icons.assignment_outlined;
      case StatusTahapPengajuan.verifikasiTeknis:
        return Icons.engineering_outlined;
      case StatusTahapPengajuan.surveyLapangan:
        return Icons.location_on_outlined;
      case StatusTahapPengajuan.persetujuan:
        return Icons.verified_outlined;
      case StatusTahapPengajuan.selesai:
        return Icons.check_circle_outline;
      case StatusTahapPengajuan.perluPerbaikan:
        return Icons.warning_amber_rounded;
    }
  }

  double get progressRatio {
    switch (this) {
      case StatusTahapPengajuan.pengajuanBaru:
        return 0.15;
      case StatusTahapPengajuan.verifikasiAdministrasi:
        return 0.35;
      case StatusTahapPengajuan.verifikasiTeknis:
        return 0.55;
      case StatusTahapPengajuan.surveyLapangan:
        return 0.75;
      case StatusTahapPengajuan.persetujuan:
        return 0.90;
      case StatusTahapPengajuan.selesai:
        return 1.0;
      case StatusTahapPengajuan.perluPerbaikan:
        return 0.40;
    }
  }
}
