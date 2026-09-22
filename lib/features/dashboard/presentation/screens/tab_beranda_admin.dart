import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/data_state_view.dart';
import '../../../../core/widgets/prototype_data_banner.dart';
import '../../../pengajuan/data/models/status_tahap_pengajuan.dart';
import '../providers/admin_dashboard_provider.dart';
import '../../../../core/widgets/app_header.dart';

class TabBerandaAdmin extends ConsumerWidget {
  const TabBerandaAdmin({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsState = ref.watch(adminDashboardMetricsAsyncProvider);

    return Scaffold(
      appBar: const AppHeader(title: 'Pemerintah Kota Tasikmalaya', subtitle: 'SATU RUMAH'),
      backgroundColor: AppColors.background,
      body: metricsState.when(
        loading: () => const DataStateView.loading(),
        error: (error, stack) => DataStateView.error(
          onAction: () => ref.invalidate(adminDashboardMetricsAsyncProvider),
        ),
        data: (metrics) {
          final primaryAction = metrics.pengajuanPerluAksi.isEmpty
              ? null
              : metrics.pengajuanPerluAksi.first;
          final latestMonitoring = metrics.monitoringTerbaru.isEmpty
              ? null
              : metrics.monitoringTerbaru.first;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting Header
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Halo, ',
                                style: AppTextStyles.h3.copyWith(
                                  fontWeight: FontWeight.normal,
                                  color: AppColors.cocoaBeanRoast,
                                ),
                              ),
                              Text(
                                'Rizki Pratama',
                                style: AppTextStyles.h3.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.cocoaBeanRoast,
                                ),
                              ),
                              const SizedBox(width: 4),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Verifikator Administrasi',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const PrototypeDataBanner(),
                const SizedBox(height: 16),

                // Grid 2x2 Ringkasan Statistik (White rounded cards)
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.35,
                  children: [
                    _buildMockupStatCard(
                      context,
                      count:
                          metrics.pengajuanBaruCount.toString().padLeft(2, '0'),
                      label: 'Pengajuan Baru',
                      icon: Icons.article_outlined,
                      iconBgColor: AppColors.champagneToast.withValues(
                        alpha: 0.45,
                      ),
                      iconColor: AppColors.cocoaBeanRoast,
                      onTap: () => context.push('/admin/pengajuan'),
                    ),
                    _buildMockupStatCard(
                      context,
                      count:
                          metrics.verifikasiTeknisCount.toString().padLeft(2, '0'),
                      label: 'Menunggu Teknis',
                      icon: Icons.access_time,
                      iconBgColor: AppColors.champagneToast.withValues(
                        alpha: 0.35,
                      ),
                      iconColor: AppColors.statusAttention,
                      onTap: () => context.push('/admin/pengajuan'),
                    ),
                    _buildMockupStatCard(
                      context,
                      count:
                          metrics.surveyTerjadwalCount.toString().padLeft(2, '0'),
                      label: 'Survey Minggu Ini',
                      icon: Icons.calendar_today_outlined,
                      iconBgColor: AppColors.pistachioCream.withValues(
                        alpha: 0.35,
                      ),
                      iconColor: AppColors.statusSuccess,
                      onTap: () => context.push('/admin/pengajuan'),
                    ),
                    _buildMockupStatCard(
                      context,
                      count:
                          metrics.perluTindakLanjutCount.toString().padLeft(2, '0'),
                      label: 'Perlu Tindak Lanjut',
                      icon: Icons.error_outline,
                      iconBgColor: AppColors.statusAttention.withValues(
                        alpha: 0.12,
                      ),
                      iconColor: AppColors.statusAttention,
                      onTap: () => context.push('/monitoring'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Section "Pengajuan Perlu Aksi"
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pengajuan Perlu Aksi',
                      style: AppTextStyles.h3.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.cocoaBeanRoast,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/admin/pengajuan'),
                      child: Text(
                        'Lihat Semua',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.actionPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (primaryAction == null)
                  const DataStateView.empty(
                    title: 'Tidak ada pengajuan perlu aksi',
                    message: 'Pengajuan baru akan muncul di bagian ini.',
                  )
                else
                  SizedBox(
                    height: 165,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        InkWell(
                          onTap: () => context.push(
                            '/admin/pengajuan/detail/${primaryAction.id}',
                          ),
                          borderRadius: AppRadii.card,
                          child: Container(
                            width: 280,
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              color: AppColors.cocoaBeanRoast,
                              borderRadius: AppRadii.card,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: AppRadii.control,
                                  ),
                                  child: Text(
                                    primaryAction.statusTahap.label,
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  primaryAction.namaPerumahan,
                                  style: AppTextStyles.titleMedium.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  primaryAction.namaPt,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: Colors.white.withValues(alpha: 0.82),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Spacer(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Progress tahap',
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: Colors.white.withValues(
                                          alpha: 0.82,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${(primaryAction.statusTahap.progressRatio * 100).round()}%',
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                ClipRRect(
                                  borderRadius: AppRadii.small,
                                  child: LinearProgressIndicator(
                                    value:
                                        primaryAction.statusTahap.progressRatio,
                                    backgroundColor: Colors.white24,
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                          AppColors.pistachioCream,
                                        ),
                                    minHeight: 6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),

                // Section "Monitoring Terjadwal"
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Monitoring Terjadwal',
                      style: AppTextStyles.h3.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.cocoaBeanRoast,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/monitoring'),
                      child: Text(
                        'Kalender',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.actionPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (latestMonitoring == null)
                  const DataStateView.empty(
                    title: 'Belum ada monitoring terjadwal',
                    message:
                        'Jadwal monitoring akan muncul setelah penugasan dibuat.',
                  )
                else
                  Card(
                    elevation: 0,
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadii.card,
                    ),
                    color: AppColors.surface,
                    child: InkWell(
                      borderRadius: AppRadii.card,
                      onTap: () => context.push('/monitoring'),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.statusAttention.withValues(
                                  alpha: 0.12,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${latestMonitoring.tanggalMonitoring.day}',
                                  style: AppTextStyles.titleMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.statusAttention,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    latestMonitoring.namaPerumahan,
                                    style: AppTextStyles.titleMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on_outlined,
                                        size: 14,
                                        color: AppColors.textMuted,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          latestMonitoring
                                                  .lokasiPerumahan
                                                  .isEmpty
                                              ? 'Lokasi belum tersedia'
                                              : latestMonitoring
                                                    .lokasiPerumahan,
                                          style: AppTextStyles.bodySmall
                                              .copyWith(
                                                color: AppColors.textMuted,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: AppColors.surfaceSubtle,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.chevron_right,
                                color: AppColors.textMuted,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMockupStatCard(
    BuildContext context, {
    required String count,
    required String label,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.card),
      color: Colors.white,
      child: InkWell(
        borderRadius: AppRadii.card,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const Spacer(),
              Text(
                count,
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
