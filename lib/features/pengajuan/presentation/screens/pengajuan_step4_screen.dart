import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/stepper_header.dart';
import '../../../../core/utils/file_picker_util.dart';
import '../providers/pengajuan_form_controller.dart';

class PengajuanStep4Screen extends ConsumerWidget {
  const PengajuanStep4Screen({super.key});

  static const List<String> daftarCakupanGambar = [
    '1 Cover',
    '2 Lembar Pengesahan Rencana Tapak',
    '3 Daftar Rincian Prasarana, Sarana dan Utilitas',
    '4 Spesimen Paraf dan Tanda Tangan',
    '5 Indeks Gambar',
    '6 Gambaran Umum',
    '7 Peta Lokasi',
    '8 Gambar Batas Tanah yang Dikuasai',
    '9 Gambar & Hasil Penyelidikan Tanah',
    '10 Gambar Rencana Tapak (Site Plan)',
    '11 Gambar RTH',
    '12 Gambar Perancangan Jaringan Jalan',
    '13 Gambar Perancangan Drainase',
    '14 Gambar Perancangan Jaringan Air Limbah',
    '15 Gambar Perancangan Jaringan Air Bersih',
    '16 Gambar Perencanaan Utilitas PJU',
    '17 Gambar Perencanaan Unit Rumah (Arsitektural)',
    '18 Gambar Perancangan Sarana Peribadatan',
    '19 Gambar Perancangan Sarana Perdagangan',
    '20 Gambar Perancangan Keamanan (Pos Satpam/Gapura/Pagar)',
    '21 TPS',
  ];

  void _showCakupanModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _CakupanChecklistModal(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(pengajuanFormProvider);
    final notifier = ref.read(pengajuanFormProvider.notifier);

    Future<void> pickMultiple() async {
      final files = await FilePickerUtil.pickMultipleFiles(
        allowedExtensions: ['dwg', 'pdf', 'zip', 'rar', 'dxf'],
      );
      if (!context.mounted) return;
      if (files.isNotEmpty) {
        notifier.addTechnicalFiles(files.map((f) => f.path ?? f.name).toList());
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Tidak ada berkas dipilih. Data tetap tidak berubah.',
            ),
          ),
        );
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(
        title: 'Dokumen Teknis (Step 4)',
        showNotifications: false,
        showBackButton: true,
      ),
      body: Column(
        children: [
          const StepperHeader(currentStep: 4),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Upload Berkas Perancangan & Site Plan',
                    style: AppTextStyles.headlineMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Unggah minimal satu berkas CAD (.dwg), PDF, atau ZIP gabungan untuk melanjutkan.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 1. Single Window Multi-File Upload Box
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.grey300, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.champagneToast.withValues(
                              alpha: 0.4,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.cloud_upload_outlined,
                            size: 36,
                            color: AppColors.chilliDust,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Pilih atau Tarik Berkas Gambar Teknis',
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.cocoaBeanRoast,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Format yang didukung: DWG, PDF, ZIP, RAR, DXF (bisa pilih banyak file sekaligus)',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.grey600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: pickMultiple,
                          icon: const Icon(Icons.add_circle_outline, size: 20),
                          label: const Text('Pilih Berkas Dokumen Teknis'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.chilliDust,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 2. List of Uploaded Technical Files
                  if (formState.technicalFiles.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Daftar Berkas Terunggah (${formState.technicalFiles.length})',
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.cocoaBeanRoast,
                          ),
                        ),
                        TextButton(
                          onPressed: pickMultiple,
                          child: const Text(
                            '+ Tambah Berkas',
                            style: TextStyle(color: AppColors.chilliDust),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: formState.technicalFiles.length,
                      itemBuilder: (context, index) {
                        final fileName = formState.technicalFiles[index];
                        final isDwg = fileName.toLowerCase().endsWith('.dwg');
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.grey200),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isDwg
                                      ? AppColors.chilliDust.withValues(
                                          alpha: 0.1,
                                        )
                                      : AppColors.champagneToast.withValues(
                                          alpha: 0.5,
                                        ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  isDwg
                                      ? Icons.architecture
                                      : Icons.picture_as_pdf,
                                  size: 20,
                                  color: isDwg
                                      ? AppColors.chilliDust
                                      : AppColors.cocoaBeanRoast,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  fileName.split(RegExp(r'[/\\]')).last,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.cocoaBeanRoast,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: AppColors.error,
                                  size: 20,
                                ),
                                onPressed: () =>
                                    notifier.removeTechnicalFile(index),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],

                  const SizedBox(height: 24),

                  // 3. Section CAKUPAN GAMBAR (Pills / Chips Selector)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.grey200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'CAKUPAN GAMBAR TEKNIS',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                      color: AppColors.grey700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Tandai gambar apa saja yang ada dalam berkas di atas:',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.grey600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => _showCakupanModal(context, ref),
                              icon: const Icon(
                                Icons.checklist,
                                size: 18,
                                color: AppColors.chilliDust,
                              ),
                              label: const Text(
                                'Pilih List',
                                style: TextStyle(
                                  color: AppColors.chilliDust,
                                  fontSize: 13,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: AppColors.chilliDust,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Green Chips Grid / Wrap (Style matching AppColors.pistachioCream)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: daftarCakupanGambar.map((item) {
                            final isSelected = formState.selectedCakupanGambar
                                .contains(item);
                            final maxChipWidth =
                                MediaQuery.of(context).size.width - 72;
                            return InkWell(
                              onTap: () => notifier.toggleCakupanGambar(item),
                              borderRadius: BorderRadius.circular(20),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                constraints: BoxConstraints(
                                  maxWidth: maxChipWidth,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.pistachioCream.withValues(
                                          alpha: 0.35,
                                        )
                                      : AppColors.surface,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.pistachioCream
                                        : AppColors.grey300,
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isSelected) ...[
                                      const Icon(
                                        Icons.check,
                                        size: 16,
                                        color: AppColors.cocoaBeanRoast,
                                      ),
                                      const SizedBox(width: 4),
                                    ],
                                    Flexible(
                                      child: Text(
                                        item,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: isSelected
                                              ? AppColors.cocoaBeanRoast
                                              : AppColors.grey700,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => notifier.selectAllCakupanGambar(
                                daftarCakupanGambar,
                              ),
                              child: const Text(
                                'Centang Semua',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.chilliDust,
                                ),
                              ),
                            ),
                            const Text(
                              '·',
                              style: TextStyle(color: AppColors.grey400),
                            ),
                            TextButton(
                              onPressed: () => notifier.clearCakupanGambar(),
                              child: const Text(
                                'Hapus Semua',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.grey600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: const Border(top: BorderSide(color: AppColors.grey200)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!formState.isStep4Valid) ...[
                Text(
                  'Minimal satu berkas teknis wajib diunggah',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.chilliDust,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
              ],
              Row(
                children: [
                  Expanded(
                    child: AppButton.secondary(
                      text: 'Kembali',
                      onPressed: () => context.pop(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppButton.primary(
                      text: 'Selanjutnya',
                      onPressed: formState.isStep4Valid
                          ? () => context.push('/pengajuan/step5')
                          : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CakupanChecklistModal extends ConsumerWidget {
  const _CakupanChecklistModal();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(pengajuanFormProvider);
    final notifier = ref.read(pengajuanFormProvider.notifier);
    final selectedCount = formState.selectedCakupanGambar.length;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 6),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pilih Cakupan Gambar Teknis',
                      style: AppTextStyles.titleMedium,
                    ),
                    Text(
                      '$selectedCount dari ${PengajuanStep4Screen.daftarCakupanGambar.length} tercentang',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.grey600,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Selesai',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.chilliDust,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: PengajuanStep4Screen.daftarCakupanGambar.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = PengajuanStep4Screen.daftarCakupanGambar[index];
                final isChecked = formState.selectedCakupanGambar.contains(
                  item,
                );
                return CheckboxListTile(
                  value: isChecked,
                  activeColor: AppColors.chilliDust,
                  checkColor: Colors.white,
                  title: Text(
                    item,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isChecked
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isChecked
                          ? AppColors.cocoaBeanRoast
                          : AppColors.grey800,
                    ),
                  ),
                  onChanged: (_) => notifier.toggleCakupanGambar(item),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => notifier.selectAllCakupanGambar(
                      PengajuanStep4Screen.daftarCakupanGambar,
                    ),
                    child: const Text('Pilih Semua'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.chilliDust,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Terapkan'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
