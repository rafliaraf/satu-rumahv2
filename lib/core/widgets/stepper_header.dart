import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class StepperHeader extends StatelessWidget {
  final int currentStep; // 1 to 5
  final List<String> stepTitles = const [
    'Data PT',
    'Dok. Admin',
    'Dok. Legal',
    'Dok. Teknis',
    'Review'
  ];

  const StepperHeader({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Row(
        children: List.generate(stepTitles.length * 2 - 1, (index) {
          if (index.isOdd) {
            // Line separator
            final lineIndex = index ~/ 2;
            final isPassed = lineIndex + 1 < currentStep;
            return Expanded(
              child: Container(
                height: 3,
                color: isPassed ? AppColors.chilliDust : AppColors.grey300,
              ),
            );
          } else {
            // Step bubble
            final stepIndex = index ~/ 2;
            final stepNum = stepIndex + 1;
            final isActive = stepNum == currentStep;
            final isPassed = stepNum < currentStep;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isPassed
                        ? AppColors.chilliDust
                        : isActive
                            ? AppColors.chilliDust
                            : AppColors.grey200,
                    shape: BoxShape.circle,
                    border: isActive
                        ? Border.all(color: AppColors.champagneToast, width: 2)
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: isPassed
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : Text(
                          '$stepNum',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: isActive || isPassed ? Colors.white : AppColors.grey600,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 4),
                Text(
                  stepTitles[stepIndex],
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isActive ? AppColors.chilliDust : AppColors.grey600,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            );
          }
        }),
      ),
    );
  }
}
