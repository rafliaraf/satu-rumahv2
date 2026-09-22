import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/doc_upload_tile.dart';
import '../../../../core/widgets/stepper_header.dart';
import '../../../../core/utils/file_picker_util.dart';
import '../providers/pengajuan_form_controller.dart';

class PengajuanStep2Screen extends ConsumerWidget {
  const PengajuanStep2Screen({super.key});

  static const List<Map<String, String>> _docKeys = [
    {'key': 'ktp', 'title': 'KTP-Elektronik Pemohon'},
    {'key': 'nib', 'title': 'Nomor Induk Berusaha (NIB)'},
    {'key': 'npwp_doc', 'title': 'NPWP Perusahaan'},
    {'key': 'asosiasi', 'title': 'Keanggotaan Asosiasi Pengembang'},
    {'key': 'legalitas', 'title': 'Legalitas Perusahaan (Akta)'},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(pengajuanFormProvider);
    final notifier = ref.read(pengajuanFormProvider.notifier);
    final missingCount = _docKeys
        .where(
          (item) =>
              formState.uploadedDocs[item['key']]?.trim().isNotEmpty != true,
        )
        .length;

    // ponytail: langsung panggil FilePickerUtil untuk membuka aplikasi Files bawaan Android
    Future<void> pickSingle(String key) async {
      final file = await FilePickerUtil.pickSingleFile(
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );
      if (!context.mounted) return;
      if (file != null) {
        notifier.uploadDocument(key, file.path ?? file.name);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Tidak ada berkas dipilih. Data tetap tidak berubah.',
              ),
            ),
          );
        }
      }
    }

    // ponytail: batch upload sekaligus dari aplikasi Files Android
    Future<void> pickBatch() async {
      final files = await FilePickerUtil.pickMultipleFiles(
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );
      if (!context.mounted) return;
      if (files.isNotEmpty) {
        int index = 0;
        for (final item in _docKeys) {
          final key = item['key']!;
          if (formState.uploadedDocs[key]?.trim().isNotEmpty != true) {
            if (index < files.length) {
              notifier.uploadDocument(
                key,
                files[index].path ?? files[index].name,
              );
              index++;
            }
          }
        }
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${files.length} berkas asli berhasil diunggah sekaligus!',
              ),
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Tidak ada berkas dipilih. Data tetap tidak berubah.',
              ),
            ),
          );
        }
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(
        title: 'Dokumen Administrasi (Step 2)',
        showNotifications: false,
        showBackButton: true,
      ),
      body: Column(
        children: [
          const StepperHeader(currentStep: 2),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Upload Dokumen Administrasi Perusahaan',
                          style: AppTextStyles.headlineMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pastikan dokumen dalam format PDF atau JPG dengan ukuran maksimal 5MB.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Banner Opsi Upload Sekaligus
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9EAE8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.chilliDust.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.folder_zip,
                              color: AppColors.chilliDust,
                              size: 22,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Sudah Siap Semua Berkas?',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: AppColors.cocoaBeanRoast,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Pilih semua file sekaligus dari aplikasi Files bawaan HP untuk mengisi 5 dokumen sekaligus.',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.grey700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: pickBatch,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.chilliDust,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: const Icon(
                              Icons.file_upload_outlined,
                              size: 18,
                            ),
                            label: const Text(
                              'Upload Sekaligus (5 Dokumen)',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  DocUploadTile(
                    title: 'KTP-Elektronik Pemohon',
                    subtitle: 'Format PDF/JPG, maks 5MB',
                    fileName: formState.uploadedDocs['ktp'],
                    onUpload: () => pickSingle('ktp'),
                    onDelete: () => notifier.deleteDocument('ktp'),
                  ),
                  DocUploadTile(
                    title: 'Nomor Induk Berusaha (NIB)',
                    subtitle: 'Format PDF, maks 5MB',
                    fileName: formState.uploadedDocs['nib'],
                    onUpload: () => pickSingle('nib'),
                    onDelete: () => notifier.deleteDocument('nib'),
                  ),
                  DocUploadTile(
                    title: 'NPWP Perusahaan',
                    subtitle: 'Format PDF/JPG, maks 5MB',
                    fileName: formState.uploadedDocs['npwp_doc'],
                    onUpload: () => pickSingle('npwp_doc'),
                    onDelete: () => notifier.deleteDocument('npwp_doc'),
                  ),
                  DocUploadTile(
                    title: 'Keanggotaan Asosiasi Pengembang',
                    subtitle: 'KTA Asosiasi yang masih berlaku',
                    fileName: formState.uploadedDocs['asosiasi'],
                    onUpload: () => pickSingle('asosiasi'),
                    onDelete: () => notifier.deleteDocument('asosiasi'),
                  ),
                  DocUploadTile(
                    title: 'Legalitas Perusahaan (Akta)',
                    subtitle: 'Akta pendirian dan perubahan terakhir',
                    fileName: formState.uploadedDocs['legalitas'],
                    onUpload: () => pickSingle('legalitas'),
                    onDelete: () => notifier.deleteDocument('legalitas'),
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
              if (missingCount > 0) ...[
                Text(
                  '$missingCount dokumen administrasi wajib belum diunggah',
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
                      onPressed: formState.isStep2Valid
                          ? () => context.push('/pengajuan/step3')
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
