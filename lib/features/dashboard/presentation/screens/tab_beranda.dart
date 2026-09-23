import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/data_state_view.dart';
import '../../../../core/widgets/prototype_data_banner.dart';
import '../../../../core/widgets/shortcut_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../notifikasi/data/models/notifikasi_model.dart';
import '../../../notifikasi/presentation/providers/notifikasi_provider.dart';
import '../../../pengajuan/presentation/providers/pengajuan_form_controller.dart';
import '../../../pengajuan/data/models/pengajuan_model.dart';
import '../../../../core/widgets/route_feedback.dart';
import '../providers/dashboard_provider.dart';

Pengajuan? latestPengajuan(List<Pengajuan> submissions) {
  return submissions.isEmpty ? null : submissions.first;
}

final dashboardPengajuanAsyncProvider = FutureProvider<List<Pengajuan>>((
  ref,
) async {
  final submissions = ref.watch(pengajuanListProvider);
  await Future<void>.delayed(Duration.zero);
  return submissions;
});

int? dashboardShortcutTab(String title) {
  switch (title) {
    case 'Pengajuan Saya':
      return 1;
    case 'Notifikasi':
      return 2;
    case 'Profil Saya':
      return 3;
    case 'Format Dokumen':
      return null;
    default:
      return null;
  }
}

class TabBeranda extends ConsumerWidget {
  const TabBeranda({super.key});

  void _quickDemo(BuildContext context, WidgetRef ref) {
    // Isi semua data dummy sekaligus
    ref.read(pengajuanFormProvider.notifier).fillDummyData();

    final formState = ref.read(pengajuanFormProvider);
    final randomNum = Random().nextInt(900) + 100;
    final newId = 'SR-20260720-$randomNum';

    final newPengajuan = Pengajuan(
      id: newId,
      namaPerumahan: formState.namaPerumahan,
      namaPt: 'PT. Tasik Indah Sentosa',
      namaDirektur: 'H. Tatang Sutisna',
      npwpPerusahaan: formState.npwpPerusahaan,
      luasLahan: formState.luasLahan,
      jumlahUnit: formState.jumlahUnit,
      tipePerumahan: formState.tipePerumahan,
      status: 'Dalam Proses',
      tanggal: '20 Juli 2026',
      uploadedDocs: formState.uploadedDocs,
    );

    ref.read(pengajuanListProvider.notifier).addPengajuan(newPengajuan);

    // Tambah notifikasi otomatis
    ref
        .read(notifikasiProvider.notifier)
        .addNotification(
          NotifikasiModel(
            id: 'notif-$newId',
            jenis: JenisNotifikasi.pengajuanBaru,
            judul: 'Pengajuan Berhasil Dikirim',
            deskripsi:
                'Pengajuan "${formState.namaPerumahan}" ($newId) telah diterima dan sedang dalam proses verifikasi administrasi.',
            waktu: DateTime.now(),
            targetRoute: '/pengajuan/detail/$newId',
          ),
        );

    ref.read(pengajuanFormProvider.notifier).reset();

    context.push('/pengajuan/success', extra: newId);
  }

  void _handleShortcut(BuildContext context, WidgetRef ref, String title) {
    final tab = dashboardShortcutTab(title);
    if (tab == null) {
      showUnavailableAction(context, title);
      return;
    }
    ref.read(dashboardTabProvider.notifier).state = tab;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submissionsState = ref.watch(dashboardPengajuanAsyncProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: 'SATU RUMAH',
        actions: [
          TextButton.icon(
            onPressed: () => _quickDemo(context, ref),
            icon: const Icon(
              Icons.bolt,
              color: AppColors.actionPrimary,
              size: 18,
            ),
            label: Text(
              'Demo Cepat',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.actionPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: submissionsState.when(
        loading: () => const DataStateView.loading(),
        error: (error, stack) => DataStateView.error(
          onAction: () => ref.invalidate(dashboardPengajuanAsyncProvider),
        ),
        data: (list) {
          final lastSubmission = latestPengajuan(list);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Greeting
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: AppColors.champagneToast,
                      child: Icon(
                        Icons.business,
                        color: AppColors.cocoaBeanRoast,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Halo, Pengembang!',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                          const Text(
                            'PT. Tasik Indah Sentosa',
                            style: AppTextStyles.headlineMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const PrototypeDataBanner(),
                const SizedBox(height: 20),

                // Last Submission Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: lastSubmission == null
                        ? _buildEmptySubmissionContent(context, ref)
                        : _buildLatestSubmissionContent(
                            context,
                            lastSubmission,
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                // Add Submission Button
                InkWell(
                  onTap: () {
                    ref.read(pengajuanFormProvider.notifier).reset();
                    context.push('/pengajuan/step1');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 24,
                      horizontal: 16,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.actionPrimary,
                      borderRadius: AppRadii.card,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.add_circle_outline,
                          color: Colors.white,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Buat Pengajuan Baru',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Grid Shortcut
                const Text('Menu Pintasan', style: AppTextStyles.headlineSmall),
                const SizedBox(height: 12),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.35,
                  children: [
                    ShortcutCard(
                      icon: Icons.list_alt,
                      title: 'Pengajuan Saya',
                      onTap: () => _handleShortcut(context, ref, 'Pengajuan Saya'),
                    ),
                    ShortcutCard(
                      icon: Icons.notifications_active,
                      title: 'Notifikasi',
                      onTap: () => _handleShortcut(context, ref, 'Notifikasi'),
                    ),
                    const ShortcutCard(
                      icon: Icons.download,
                      title: 'Format Dokumen',
                      disabled: true,
                    ),
                    ShortcutCard(
                      icon: Icons.person_pin,
                      title: 'Profil Saya',
                      onTap: () => _handleShortcut(context, ref, 'Profil Saya'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // System Banner Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.champagneToast.withValues(alpha: 0.4),
                    borderRadius: AppRadii.control,
                    border: Border.all(color: AppColors.champagneToast),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info, color: AppColors.cocoaBeanRoast),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'PEMBERITAHUAN:\nSistem akan mengalami pemeliharaan rutin pada 25 Juli 2026 pukul 23:00 WIB.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.cocoaBeanRoast,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptySubmissionContent(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Belum ada pengajuan', style: AppTextStyles.titleMedium),
        const SizedBox(height: 8),
        Text(
          'Mulai pengajuan site plan Anda untuk melihat statusnya di sini.',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () {
              ref.read(pengajuanFormProvider.notifier).reset();
              context.push('/pengajuan/step1');
            },
            icon: const Icon(Icons.add, color: AppColors.actionPrimary),
            label: const Text('Buat Pengajuan'),
          ),
        ),
      ],
    );
  }

  Widget _buildLatestSubmissionContent(
    BuildContext context,
    Pengajuan submission,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Pengajuan Terakhir', style: AppTextStyles.titleMedium),
            StatusBadge(status: submission.status),
          ],
        ),
        const SizedBox(height: 12),
        Text(submission.namaPerumahan, style: AppTextStyles.headlineSmall),
        const SizedBox(height: 4),
        Text(
          'Tahap: Verifikasi Administrasi',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: submission.status == 'Selesai' ? 1.0 : 0.4,
                backgroundColor: AppColors.grey200,
                color: AppColors.chilliDust,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              submission.status == 'Selesai' ? '100%' : '40%',
              style: AppTextStyles.labelSmall,
            ),
          ],
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () => context.push('/pengajuan/detail/${submission.id}'),
          child: Text(
            'Lihat Detail',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.actionPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

}
