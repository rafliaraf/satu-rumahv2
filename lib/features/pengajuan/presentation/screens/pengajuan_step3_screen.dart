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

class PengajuanStep3Screen extends ConsumerWidget {
  const PengajuanStep3Screen({super.key});

  static const List<Map<String, String>> _sec1Items = [
    {'key': 'surat_permohonan'},
    {'key': 'info_intensitas_ruang'},
    {'key': 'bukti_kepemilikan_lahan'},
    {'key': 'bukti_tpu'},
  ];

  static const List<Map<String, String>> _sec2Items = [
    {'key': 'kkpr_doc'},
    {'key': 'pbg_induk'},
    {'key': 'rekomendasi_lingkungan'},
    {'key': 'pelepasan_lahan'},
  ];

  static const List<Map<String, String>> _sec3Items = [
    {'key': 'pernyataan_pelepasan'},
    {'key': 'pernyataan_keabsahan'},
    {'key': 'pernyataan_psu'},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(pengajuanFormProvider);
    final notifier = ref.read(pengajuanFormProvider.notifier);

    // ponytail: pemanggil file picker tunggal untuk Android native storage
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

    // ponytail: pemanggil batch picker per bagian
    Future<void> pickSectionBatch(
      List<Map<String, String>> sectionItems,
      String sectionTitle,
    ) async {
      final files = await FilePickerUtil.pickMultipleFiles(
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );
      if (!context.mounted) return;
      if (files.isNotEmpty) {
        int index = 0;
        for (final item in sectionItems) {
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
                '${files.length} berkas $sectionTitle berhasil diunggah!',
              ),
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Tidak ada berkas $sectionTitle yang dipilih. Data tetap tidak berubah.',
              ),
            ),
          );
        }
      }
    }

    void delete(String key) {
      notifier.deleteDocument(key);
    }

    // Section 1 Keys: Legalitas & Perizinan (4 items)
    final sec1Keys = _sec1Items.map((e) => e['key']!).toList();
    int sec1Uploaded = sec1Keys
        .where((k) => formState.uploadedDocs[k]?.trim().isNotEmpty == true)
        .length;

    // Section 2 Keys: Teknis & Rekomendasi (4 items)
    final sec2Keys = _sec2Items.map((e) => e['key']!).toList();
    int sec2Uploaded = sec2Keys
        .where((k) => formState.uploadedDocs[k]?.trim().isNotEmpty == true)
        .length;

    // Section 3 Keys: Pernyataan (3 items)
    final sec3Keys = _sec3Items.map((e) => e['key']!).toList();
    int sec3Uploaded = sec3Keys
        .where((k) => formState.uploadedDocs[k]?.trim().isNotEmpty == true)
        .length;

    // Mandatory Keys required for Step 3 validation (10 mandatory items)
    final mandatoryKeys = [
      'surat_permohonan',
      'info_intensitas_ruang',
      'bukti_kepemilikan_lahan',
      'bukti_tpu',
      'kkpr_doc',
      'pbg_induk',
      'rekomendasi_lingkungan',
      'pernyataan_pelepasan',
      'pernyataan_keabsahan',
      'pernyataan_psu',
    ];
    int uploadedMandatory = mandatoryKeys
        .where((k) => formState.uploadedDocs[k]?.trim().isNotEmpty == true)
        .length;
    int missingCount = mandatoryKeys.length - uploadedMandatory;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: 'Administrasi Perumahan (Step 3)',
        showNotifications: false,
        showBackButton: true,
        actions: [
          TextButton.icon(
            onPressed: () {
              ref.read(pengajuanFormProvider.notifier).fillDummyData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data dummy Step 3 berhasil diisi!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(
              Icons.auto_fix_high,
              size: 18,
              color: Colors.white70,
            ),
            label: Text(
              'Isi Dummy',
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const StepperHeader(currentStep: 3),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Upload Administrasi Perumahan',
                    style: AppTextStyles.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Unggah dokumen legalitas, rekomendasi teknis, dan pernyataan (Bisa pilih 1 per 1 atau sekaligus per bagian)',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Group 1: Legalitas & Perizinan
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.grey300),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: ExpansionTile(
                      initiallyExpanded: true,
                      title: Text(
                        'Dokumen legalitas & perizinan (Bagian 1)',
                        style: AppTextStyles.headlineSmall.copyWith(
                          fontSize: 15,
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: sec1Uploaded == 4
                              ? AppColors.chilliDust.withValues(alpha: 0.1)
                              : AppColors.grey200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$sec1Uploaded/4',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: sec1Uploaded == 4
                                ? AppColors.chilliDust
                                : AppColors.grey700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            children: [
                              // Tombol Unggah Sekaligus Bagian 1
                              OutlinedButton.icon(
                                onPressed: () => pickSectionBatch(
                                  _sec1Items,
                                  'Bagian 1 (Legalitas)',
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.chilliDust,
                                  side: const BorderSide(
                                    color: AppColors.chilliDust,
                                  ),
                                  minimumSize: const Size(double.infinity, 38),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.file_upload_outlined,
                                  size: 16,
                                ),
                                label: const Text(
                                  'Unggah Sekaligus Bagian 1 (4 Dokumen)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              DocUploadTile(
                                title: 'Surat permohonan persetujuan',
                                subtitle: 'Format PDF, maks 10MB',
                                fileName:
                                    formState.uploadedDocs['surat_permohonan'],
                                onUpload: () => pickSingle('surat_permohonan'),
                                onDelete: () => delete('surat_permohonan'),
                              ),
                              const SizedBox(height: 12),
                              DocUploadTile(
                                title: 'Informasi intensitas ruang',
                                subtitle: 'Format PDF, maks 10MB',
                                fileName: formState
                                    .uploadedDocs['info_intensitas_ruang'],
                                onUpload: () =>
                                    pickSingle('info_intensitas_ruang'),
                                onDelete: () => delete('info_intensitas_ruang'),
                              ),
                              const SizedBox(height: 12),
                              DocUploadTile(
                                title: 'Bukti kepemilikan lahan',
                                subtitle: 'Format PDF/Sertifikat, maks 10MB',
                                fileName: formState
                                    .uploadedDocs['bukti_kepemilikan_lahan'],
                                onUpload: () =>
                                    pickSingle('bukti_kepemilikan_lahan'),
                                onDelete: () =>
                                    delete('bukti_kepemilikan_lahan'),
                              ),
                              const SizedBox(height: 12),
                              DocUploadTile(
                                title: 'Bukti penyediaan lahan TPU',
                                subtitle: 'Format PDF, maks 10MB',
                                fileName: formState.uploadedDocs['bukti_tpu'],
                                onUpload: () => pickSingle('bukti_tpu'),
                                onDelete: () => delete('bukti_tpu'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Group 2: Teknis & Rekomendasi
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.grey300),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: ExpansionTile(
                      initiallyExpanded: false,
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dokumen teknis & rekomendasi (Bagian 2)',
                            style: AppTextStyles.headlineSmall.copyWith(
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'termasuk 1 dokumen kondisional',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.grey600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: sec2Uploaded >= 3
                              ? AppColors.chilliDust.withValues(alpha: 0.1)
                              : AppColors.grey200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$sec2Uploaded/4',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: sec2Uploaded >= 3
                                ? AppColors.chilliDust
                                : AppColors.grey700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            children: [
                              // Tombol Unggah Sekaligus Bagian 2
                              OutlinedButton.icon(
                                onPressed: () => pickSectionBatch(
                                  _sec2Items,
                                  'Bagian 2 (Teknis)',
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.chilliDust,
                                  side: const BorderSide(
                                    color: AppColors.chilliDust,
                                  ),
                                  minimumSize: const Size(double.infinity, 38),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.file_upload_outlined,
                                  size: 16,
                                ),
                                label: const Text(
                                  'Unggah Sekaligus Bagian 2 (4 Dokumen)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              DocUploadTile(
                                title:
                                    'Persetujuan Kesesuaian Kegiatan Pemanfaatan Ruang (KKPR)',
                                subtitle: 'Format PDF, maks 10MB',
                                fileName: formState.uploadedDocs['kkpr_doc'],
                                onUpload: () => pickSingle('kkpr_doc'),
                                onDelete: () => delete('kkpr_doc'),
                              ),
                              const SizedBox(height: 12),
                              DocUploadTile(
                                title:
                                    'Persetujuan Bangunan Gedung (PBG) Induk',
                                subtitle: 'Atau IMB Induk terdahulu',
                                fileName: formState.uploadedDocs['pbg_induk'],
                                onUpload: () => pickSingle('pbg_induk'),
                                onDelete: () => delete('pbg_induk'),
                              ),
                              const SizedBox(height: 12),
                              DocUploadTile(
                                title:
                                    'Rekomendasi Dokumen Lingkungan (AMDAL/UKL-UPL/SPPL)',
                                subtitle: 'Format PDF, maks 10MB',
                                fileName: formState
                                    .uploadedDocs['rekomendasi_lingkungan'],
                                onUpload: () =>
                                    pickSingle('rekomendasi_lingkungan'),
                                onDelete: () =>
                                    delete('rekomendasi_lingkungan'),
                              ),
                              const SizedBox(height: 12),
                              DocUploadTile(
                                title:
                                    'Rekomendasi Pelepasan/Penggunaan Lahan (Kondisional)',
                                subtitle: 'Jika berlaku, format PDF, maks 10MB',
                                fileName:
                                    formState.uploadedDocs['pelepasan_lahan'],
                                onUpload: () => pickSingle('pelepasan_lahan'),
                                onDelete: () => delete('pelepasan_lahan'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Group 3: Pernyataan
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.grey300),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: ExpansionTile(
                      initiallyExpanded: false,
                      title: Text(
                        'Dokumen pernyataan (Bagian 3)',
                        style: AppTextStyles.headlineSmall.copyWith(
                          fontSize: 15,
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: sec3Uploaded == 3
                              ? AppColors.chilliDust.withValues(alpha: 0.1)
                              : AppColors.grey200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$sec3Uploaded/3',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: sec3Uploaded == 3
                                ? AppColors.chilliDust
                                : AppColors.grey700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            children: [
                              // Tombol Unggah Sekaligus Bagian 3
                              OutlinedButton.icon(
                                onPressed: () => pickSectionBatch(
                                  _sec3Items,
                                  'Bagian 3 (Pernyataan)',
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.chilliDust,
                                  side: const BorderSide(
                                    color: AppColors.chilliDust,
                                  ),
                                  minimumSize: const Size(double.infinity, 38),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.file_upload_outlined,
                                  size: 16,
                                ),
                                label: const Text(
                                  'Unggah Sekaligus Bagian 3 (3 Dokumen)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              DocUploadTile(
                                title:
                                    'Surat Pernyataan Pelepasan Hak Atas Tanah',
                                subtitle: 'Format PDF bermaterai, maks 10MB',
                                fileName: formState
                                    .uploadedDocs['pernyataan_pelepasan'],
                                onUpload: () =>
                                    pickSingle('pernyataan_pelepasan'),
                                onDelete: () => delete('pernyataan_pelepasan'),
                              ),
                              const SizedBox(height: 12),
                              DocUploadTile(
                                title: 'Surat Pernyataan Keabsahan Dokumen',
                                subtitle: 'Format PDF bermaterai, maks 10MB',
                                fileName: formState
                                    .uploadedDocs['pernyataan_keabsahan'],
                                onUpload: () =>
                                    pickSingle('pernyataan_keabsahan'),
                                onDelete: () => delete('pernyataan_keabsahan'),
                              ),
                              const SizedBox(height: 12),
                              DocUploadTile(
                                title:
                                    'Surat Pernyataan Kesanggupan Penyediaan PSU',
                                subtitle: 'Format PDF bermaterai, maks 10MB',
                                fileName:
                                    formState.uploadedDocs['pernyataan_psu'],
                                onUpload: () => pickSingle('pernyataan_psu'),
                                onDelete: () => delete('pernyataan_psu'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
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
                  '$missingCount dokumen wajib belum diunggah',
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
                      onPressed: formState.isStep3Valid
                          ? () => context.push('/pengajuan/step4')
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
