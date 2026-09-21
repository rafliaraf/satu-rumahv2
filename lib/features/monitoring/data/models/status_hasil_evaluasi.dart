import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

enum StatusHasilEvaluasi {
  sesuaiSiteplan,
  tidakSesuaiSiteplan,
  perluEvaluasiLanjutan,
}

extension StatusHasilEvaluasiX on StatusHasilEvaluasi {
  String get label {
    switch (this) {
      case StatusHasilEvaluasi.sesuaiSiteplan:
        return 'Sesuai Siteplan';
      case StatusHasilEvaluasi.tidakSesuaiSiteplan:
        return 'Tidak Sesuai Siteplan';
      case StatusHasilEvaluasi.perluEvaluasiLanjutan:
        return 'Perlu Evaluasi Lanjutan';
    }
  }

  Color get color {
    switch (this) {
      case StatusHasilEvaluasi.sesuaiSiteplan:
        return AppColors.statusSuccess;
      case StatusHasilEvaluasi.tidakSesuaiSiteplan:
        return AppColors.chilliDust;
      case StatusHasilEvaluasi.perluEvaluasiLanjutan:
        return AppColors.warning;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case StatusHasilEvaluasi.sesuaiSiteplan:
        return AppColors.pistachioCream.withValues(alpha: 0.25);
      case StatusHasilEvaluasi.tidakSesuaiSiteplan:
        return AppColors.chilliDust.withValues(alpha: 0.12);
      case StatusHasilEvaluasi.perluEvaluasiLanjutan:
        return AppColors.warning.withValues(alpha: 0.12);
    }
  }

  IconData get icon {
    switch (this) {
      case StatusHasilEvaluasi.sesuaiSiteplan:
        return Icons.check_circle_outline;
      case StatusHasilEvaluasi.tidakSesuaiSiteplan:
        return Icons.cancel_outlined;
      case StatusHasilEvaluasi.perluEvaluasiLanjutan:
        return Icons.error_outline;
    }
  }

  bool get wajibRencanaTindakLanjut {
    switch (this) {
      case StatusHasilEvaluasi.sesuaiSiteplan:
        return false;
      case StatusHasilEvaluasi.tidakSesuaiSiteplan:
      case StatusHasilEvaluasi.perluEvaluasiLanjutan:
        return true;
    }
  }
}
