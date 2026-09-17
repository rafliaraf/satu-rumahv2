import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/data_state_view.dart';
import '../../../../core/widgets/prototype_data_banner.dart';
import '../../../pengajuan/data/models/pengajuan_model.dart';
import '../providers/monitoring_form_provider.dart';
import '../providers/monitoring_list_provider.dart';
import 'status_hasil_evaluasi_badge_widget.dart';

class TabBerandaMonitoring extends ConsumerWidget {
  const TabBerandaMonitoring({super.key});

  void _startSurveyForPengajuan(
    BuildContext context,
    WidgetRef ref,
    Pengajuan p,
  ) {
    final notifier = ref.read(monitoringFormProvider.notifier);
    notifier.resetForm();
    notifier.updatePengajuanId(p.id);
    notifier.updateNamaPerumahan(p.namaPerumahan);
    notifier.updateNamaDeveloper(p.namaPt);
    notifier.updateLokasi('Kota Tasikmalaya');
    notifier.updatePelaksanaNama('Drs. Rian Hidayat, M.Si');
    notifier.updatePelaksanaJabatan('Ketua Tim Monitoring & Evaluasi DPKP');
    context.push('/monitoring/tambah');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listState = ref.watch(monitoringListAsyncProvider);
    final today = DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: 'SATU RUMAH',
        subtitle: DateFormat('EEEE, d MMMM yyyy').format(today),
      ),
      body: listState.when(
        loading: () => const DataStateView.loading(),
        error: (error, stack) => DataStateView.error(
          onAction: () => ref.invalidate(monitoringListAsyncProvider),
        ),
        data: (list) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Header Profile Card (Matching Mockup)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadii.card,
                  border: Border.all(color: AppColors.grey200),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: AppColors.champagneToast,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text('RH', style: AppTextStyles.titleMedium),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Drs. Rian Hidayat, M.Si',
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Ketua Tim Monitoring & Evaluasi DPKP',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.pistachioCream.withOpacity(0.3),
                              borderRadius: AppRadii.control,
                            ),
                            child: Text(
                              '● Tim Perwaskim Lapangan',
                              style: AppTextStyles.labelSmall.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.statusSuccess,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const PrototypeDataBanner(),
              const SizedBox(height: 20),

              // Main CTA Button
              InkWell(
                onTap: () => context.push('/monitoring/tambah'),
                borderRadius: AppRadii.card,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.actionPrimary,
                    borderRadius: AppRadii.card,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        color: Colors.white,
                        size: 36,
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '+ Tambah Laporan Baru',
                              style: AppTextStyles.titleLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Catat hasil inspeksi hari ini',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.white.withValues(alpha: 0.88),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Colors.white),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Penugasan Survey Aktif dari Admin (Realtime Bridge)
              Builder(
                builder: (context) {
                  final penugasanList = ref.watch(surveyAktifProvider);
                  if (penugasanList.isEmpty) {
                    return const DataStateView.empty(
                      title: 'Tidak ada penugasan aktif',
                      message:
                          'Penugasan survey dari Admin akan muncul di sini.',
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.event_available,
                            color: AppColors.actionPrimary,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'PENUGASAN SURVEY AKTIF DARI ADMIN (${penugasanList.length})',
                            style: AppTextStyles.labelMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.actionPrimary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ...penugasanList.map(
                        (p) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: AppRadii.card,
                            border: Border.all(
                              color: AppColors.actionPrimary.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.statusAttention
                                          .withValues(alpha: 0.12),
                                      borderRadius: AppRadii.control,
                                    ),
                                    child: Text(
                                      p.id,
                                      style: AppTextStyles.labelSmall.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.statusAttention,
                                      ),
                                    ),
                                  ),
                                  if (p.tanggalSurvey != null)
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.schedule,
                                          size: 13,
                                          color: AppColors.textMuted,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          () {
                                            try {
                                              return DateFormat(
                                                "d MMM yyyy '·' HH:mm",
                                                'id',
                                              ).format(p.tanggalSurvey!);
                                            } catch (_) {
                                              return DateFormat(
                                                "d MMM yyyy '·' HH:mm",
                                              ).format(p.tanggalSurvey!);
                                            }
                                          }(),
                                          style: AppTextStyles.labelSmall
                                              .copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                p.namaPerumahan,
                                style: AppTextStyles.titleMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                p.namaPt,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textMuted,
                                ),
                              ),
                              if (p.catatanSurvey != null &&
                                  p.catatanSurvey!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: AppRadii.small,
                                    border: Border.all(
                                      color: AppColors.grey200,
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.info_outline,
                                        size: 14,
                                        color: AppColors.actionPrimary,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          'Catatan Admin: ${p.catatanSurvey}',
                                          style: AppTextStyles.bodySmall
                                              .copyWith(
                                                color: AppColors.textMuted,
                                                height: 1.4,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                height: 42,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.actionPrimary,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: AppRadii.control,
                                    ),
                                  ),
                                  onPressed: () =>
                                      _startSurveyForPengajuan(context, ref, p),
                                  icon: const Icon(
                                    Icons.assignment_add,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    'Isi Hasil Survey & Berita Acara',
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  );
                },
              ),

              // Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'MONITORING TERBARU',
                    style: AppTextStyles.labelMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMuted,
                      letterSpacing: 0.5,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/monitoring/lapangan/riwayat'),
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

              if (list.isEmpty)
                DataStateView.empty(
                  title: 'Belum ada laporan monitoring',
                  message:
                      'Tambahkan laporan baru untuk melihat riwayat monitoring.',
                  actionLabel: 'Tambah laporan',
                  onAction: () => context.push('/monitoring/tambah'),
                )
              else
                ...list
                    .take(5)
                    .map(
                      (item) => Card(
                        elevation: 0,
                        color: Colors.white,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadii.card,
                          side: const BorderSide(color: AppColors.grey200),
                        ),
                        child: InkWell(
                          onTap: () => context.push(
                            '/monitoring/preview',
                            extra: {'model': item, 'isDraft': false},
                          ),
                          borderRadius: AppRadii.card,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                        color: AppColors.surfaceSubtle,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.location_city,
                                        color: AppColors.cocoaBeanRoast,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.namaPerumahan,
                                            style: AppTextStyles.titleMedium
                                                .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          if (item.lokasiPerumahan.isNotEmpty)
                                            Text(
                                              item.lokasiPerumahan,
                                              style: AppTextStyles.bodySmall
                                                  .copyWith(
                                                    color: AppColors.textMuted,
                                                  ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                const Divider(
                                  height: 1,
                                  color: AppColors.grey200,
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      DateFormat(
                                        'dd MMM yyyy',
                                      ).format(item.tanggalMonitoring),
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                    StatusHasilEvaluasiBadgeWidget(
                                      status: item.statusHasilEvaluasi,
                                      isCompact: true,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
