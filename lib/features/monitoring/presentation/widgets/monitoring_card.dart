import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/monitoring_model.dart';
import 'status_hasil_evaluasi_badge_widget.dart';

class MonitoringCard extends StatelessWidget {
  final MonitoringModel item;
  final VoidCallback onTap;

  const MonitoringCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('d MMM yyyy').format(item.tanggalMonitoring);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.grey300),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(item.namaPerumahan, style: AppTextStyles.h4),
                  ),
                  const SizedBox(width: 8),
                  StatusHasilEvaluasiBadgeWidget(
                    status: item.statusHasilEvaluasi,
                    isCompact: true,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              if (item.namaDeveloper.isNotEmpty)
                Text('Developer: ${item.namaDeveloper}', style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey700)),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 14, color: AppColors.grey600),
                  const SizedBox(width: 4),
                  Text(dateStr, style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey600)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

