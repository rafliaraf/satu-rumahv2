import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';

class PengajuanSuccessScreen extends ConsumerWidget {
  final String pengajuanId;

  const PengajuanSuccessScreen({super.key, required this.pengajuanId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Success Icon dengan animasi pulse
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, scale, child) =>
                  Transform.scale(scale: scale, child: child),
              child: const Icon(
                Icons.check_circle_outline,
                color: AppColors.pistachioCream,
                size: 90,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Pengajuan Berhasil Dikirim!',
              textAlign: TextAlign.center,
              style: AppTextStyles.displaySmall,
            ),
            const SizedBox(height: 12),
            Text(
              'Dokumen Site Plan Anda telah berhasil dikirim ke server Disperumkim untuk tahap verifikasi berkas.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.grey700,
              ),
            ),
            const SizedBox(height: 24),

            // ID Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.grey300),
              ),
              child: Column(
                children: [
                  Text(
                    'ID PENGAJUAN',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pengajuanId,
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.chilliDust,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Banner notifikasi muncul
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.pistachioCream.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.pistachioCream.withValues(alpha: 0.4),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.notifications_active,
                    color: AppColors.pistachioCream,
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Notifikasi konfirmasi sudah dikirim ke tab Notifikasi Anda.',
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Tombol Lihat Notifikasi (navigasi ke tab Notifikasi = index 2)
            AppButton.primary(
              text: 'Lihat Notifikasi',
              onPressed: () {
                ref.read(dashboardTabProvider.notifier).state = 2;
                context.go('/dashboard');
              },
            ),
            const SizedBox(height: 12),
            AppButton.secondary(
              text: 'Lihat Detail Pengajuan',
              onPressed: () => context.push('/pengajuan/detail/$pengajuanId'),
            ),
            const SizedBox(height: 12),
            AppButton.secondary(
              text: 'Lihat Status Pengajuan',
              onPressed: () {
                ref.read(dashboardTabProvider.notifier).state = 1;
                context.go('/dashboard');
              },
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                ref.read(dashboardTabProvider.notifier).state = 0;
                context.go('/dashboard');
              },
              child: const Text(
                'Kembali ke Beranda',
                style: TextStyle(color: AppColors.grey600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
