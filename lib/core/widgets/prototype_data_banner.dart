import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Makes local fixtures honest without changing the role flow.
class PrototypeDataBanner extends StatelessWidget {
  const PrototypeDataBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Mode prototipe lokal. Data contoh ditampilkan untuk demonstrasi.',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.champagneToast.withValues(alpha: 0.42),
          borderRadius: AppRadii.control,
          border: Border.all(color: AppColors.champagneToast),
        ),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, color: AppColors.textPrimary, size: 20),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Mode prototipe lokal\nData contoh ditampilkan untuk demonstrasi, bukan data operasional.',
                style: AppTextStyles.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
