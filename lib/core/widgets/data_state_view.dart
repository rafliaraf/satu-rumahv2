import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

enum AppDataState { loading, empty, error }

class DataStateView extends StatelessWidget {
  final AppDataState state;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const DataStateView({
    super.key,
    required this.state,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  const DataStateView.loading({
    super.key,
    this.title = 'Memuat data',
    this.message = 'Data sedang disiapkan.',
  }) : state = AppDataState.loading,
       actionLabel = null,
       onAction = null;

  const DataStateView.empty({
    super.key,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  }) : state = AppDataState.empty;

  const DataStateView.error({
    super.key,
    this.title = 'Data belum dapat dimuat',
    this.message = 'Coba lagi untuk memuat data terbaru.',
    this.actionLabel = 'Coba lagi',
    this.onAction,
  }) : state = AppDataState.error;

  @override
  Widget build(BuildContext context) {
    final icon = switch (state) {
      AppDataState.loading => const CircularProgressIndicator(
        color: AppColors.actionPrimary,
      ),
      AppDataState.empty => const Icon(
        Icons.inbox_outlined,
        size: 40,
        color: AppColors.textMuted,
      ),
      AppDataState.error => const Icon(
        Icons.error_outline,
        size: 40,
        color: AppColors.error,
      ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.card,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          icon,
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: AppTextStyles.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            message,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: onAction,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.actionPrimary,
                minimumSize: const Size(0, 48),
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadii.control,
                ),
              ),
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
