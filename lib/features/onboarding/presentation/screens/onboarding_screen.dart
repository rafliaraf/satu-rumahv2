import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () => context.go('/login'),
                  child: Text(
                    'Skip',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.chilliDust,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.home_work,
                        size: 64,
                        color: AppColors.chilliDust,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Selamat Datang di SATU RUMAH',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.headlineLarge,
                      ),
                      const SizedBox(height: 24),
                      _buildFeatureTile(
                        icon: Icons.assignment_turned_in,
                        title: 'Persetujuan Site Plan',
                        desc:
                            'Pengajuan dokumen perencanaan perumahan lebih cepat & terpadu.',
                      ),
                      const SizedBox(height: 16),
                      _buildFeatureTile(
                        icon: Icons.analytics,
                        title: 'Monitoring & Evaluasi',
                        desc:
                            'Pantau status verifikasi dan progress perumahan Anda secara berkala.',
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              AppButton.primary(
                text: 'Mulai Sekarang',
                onPressed: () => context.go('/login'),
              ),
              const SizedBox(height: 24),
              Text(
                'Dinas Perumahan Rakyat dan Kawasan Permukiman\nKota Tasikmalaya',
                textAlign: TextAlign.center,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureTile({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.pistachioCream, size: 28),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.grey700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
