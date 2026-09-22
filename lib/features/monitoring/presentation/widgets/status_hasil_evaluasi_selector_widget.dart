import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/status_hasil_evaluasi.dart';

class StatusHasilEvaluasiSelectorWidget extends StatelessWidget {
  final StatusHasilEvaluasi selectedStatus;
  final ValueChanged<StatusHasilEvaluasi> onChanged;

  const StatusHasilEvaluasiSelectorWidget({
    super.key,
    required this.selectedStatus,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Status Hasil Evaluasi',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.cocoaBeanRoast,
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              '*',
              style: TextStyle(color: AppColors.chilliDust, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Pilih kesimpulan evaluasi kesesuaian pelaksanaan dengan siteplan.',
          style: TextStyle(fontSize: 12, color: AppColors.grey600),
        ),
        const SizedBox(height: 12),
        ...StatusHasilEvaluasi.values.map((status) {
          final isSelected = selectedStatus == status;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: InkWell(
              onTap: () => onChanged(status),
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? status.backgroundColor : AppColors.grey50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? status.color : AppColors.grey300,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: isSelected ? status.color : AppColors.grey400,
                      size: 22,
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      status.icon,
                      color: isSelected ? status.color : AppColors.grey600,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            status.label,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? status.color : AppColors.cocoaBeanRoast,
                            ),
                          ),
                          if (status.wajibRencanaTindakLanjut) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Wajib mengisi minimal 1 poin Rencana Tindak Lanjut',
                              style: TextStyle(
                                fontSize: 11,
                                color: isSelected ? status.color : AppColors.grey600,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
