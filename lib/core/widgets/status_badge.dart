import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'dalam proses':
      case 'proses':
        bgColor = AppColors.info.withValues(alpha: 0.12);
        textColor = AppColors.info;
        break;
      case 'selesai':
      case 'disetujui':
        bgColor = AppColors.pistachioCream.withValues(alpha: 0.2);
        textColor = AppColors.cocoaBeanRoast;
        break;
      case 'perlu perbaikan':
      case 'revisi':
        bgColor = AppColors.warning.withValues(alpha: 0.12);
        textColor = AppColors.warning;
        break;
      default:
        bgColor = AppColors.grey200;
        textColor = AppColors.grey700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: AppTextStyles.labelSmall.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
