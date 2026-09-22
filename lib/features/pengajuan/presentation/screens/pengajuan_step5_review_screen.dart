import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/stepper_header.dart';
import '../../../notifikasi/data/models/notifikasi_model.dart';
import '../../../notifikasi/presentation/providers/notifikasi_provider.dart';
import '../../data/models/pengajuan_model.dart';
import '../providers/pengajuan_form_controller.dart';

class PengajuanStep5ReviewScreen extends ConsumerStatefulWidget {
  const PengajuanStep5ReviewScreen({super.key});

  @override
  ConsumerState<PengajuanStep5ReviewScreen> createState() =>
      _PengajuanStep5ReviewScreenState();
}

class _PengajuanStep5ReviewScreenState
    extends ConsumerState<PengajuanStep5ReviewScreen> {
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(pengajuanFormProvider);

    void submit() {
      if (_isSubmitting) return;

      final currentState = ref.read(pengajuanFormProvider);
      if (!currentState.isAllValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_missingRequirements(currentState))),
        );
        return;
      }
      setState(() => _isSubmitting = true);

      final now = DateTime.now();
      final newId = _newSubmissionId(now, ref.read(pengajuanListProvider));

      final newPengajuan = Pengajuan(
        id: newId,
        namaPerumahan: currentState.namaPerumahan.trim(),
        namaPt: 'PT. Tasik Indah Sentosa',
        namaDirektur: 'H. Tatang Sutisna',
        npwpPerusahaan: currentState.npwpPerusahaan.trim(),
        luasLahan: currentState.luasLahan,
        jumlahUnit: currentState.jumlahUnit,
        tipePerumahan: currentState.tipePerumahan,
        status: 'Dalam Proses',
        tanggal: '${now.day} ${_monthName(now.month)} ${now.year}',
        uploadedDocs: Map<String, String>.from(currentState.uploadedDocs),
        technicalFiles: List<String>.from(currentState.technicalFiles),
        selectedCakupanGambar: currentState.selectedCakupanGambar.toList(),
      );

      final added = ref
          .read(pengajuanListProvider.notifier)
          .addPengajuanIfAbsent(newPengajuan);
      if (!added) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Pengajuan sudah tercatat. Silakan buka daftar pengajuan.',
            ),
          ),
        );
        return;
      }

      // Tambahkan notifikasi baru secara otomatis
      ref
          .read(notifikasiProvider.notifier)
          .addNotification(
            NotifikasiModel(
              id: 'notif-$newId',
              jenis: JenisNotifikasi.pengajuanBaru,
              judul: 'Pengajuan Baru: ${currentState.namaPerumahan}',
              deskripsi:
                  'Pengajuan ($newId) telah diterima dan dalam verifikasi administrasi.',
              waktu: DateTime.now(),
              targetRoute: '/admin/pengajuan/detail/$newId',
            ),
          );

      ref.read(pengajuanFormProvider.notifier).reset();
      context.pushReplacement('/pengajuan/success', extra: newId);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(
        title: 'Review \u0026 Submit (Step 5)',
        showNotifications: false,
        showBackButton: true,
      ),
      body: Column(
        children: [
          const StepperHeader(currentStep: 5),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Tinjau Kembali Data Pengajuan',
                    style: AppTextStyles.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  if (!formState.isAllValid) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.warning.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Text(
                        _missingRequirements(formState),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.cocoaBeanRoast,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Pengembang Review Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Data Pengembang & Lahan',
                            style: AppTextStyles.titleMedium,
                          ),
                          const Divider(height: 20),
                          _buildInfoRow(
                            'Nama Perumahan',
                            formState.namaPerumahan,
                          ),
                          _buildInfoRow(
                            'NPWP Perusahaan',
                            formState.npwpPerusahaan,
                          ),
                          _buildInfoRow(
                            'Luas Lahan',
                            '${formState.luasLahan} m²',
                          ),
                          _buildInfoRow(
                            'Jumlah Unit',
                            '${formState.jumlahUnit} Unit',
                          ),
                          _buildInfoRow(
                            'Tipe Perumahan',
                            formState.tipePerumahan,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Dokumen Review Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Berkas Unggahan',
                            style: AppTextStyles.titleMedium,
                          ),
                          const Divider(height: 20),
                          _buildDocReviewRow(
                            'KTP Pemohon',
                            formState.uploadedDocs['ktp'],
                          ),
                          _buildDocReviewRow(
                            'NIB Perusahaan',
                            formState.uploadedDocs['nib'],
                          ),
                          _buildDocReviewRow(
                            'NPWP Perusahaan',
                            formState.uploadedDocs['npwp_doc'],
                          ),
                          _buildDocReviewRow(
                            'Keanggotaan Asosiasi',
                            formState.uploadedDocs['asosiasi'],
                          ),
                          _buildDocReviewRow(
                            'Legalitas Akta',
                            formState.uploadedDocs['legalitas'],
                          ),
                          _buildDocReviewRow(
                            'Kesesuaian Tata Ruang',
                            formState.uploadedDocs['kkpr_doc'] ??
                                formState.uploadedDocs['tata_ruang'],
                          ),
                          _buildDocReviewRow(
                            'PBG/IMB Induk',
                            formState.uploadedDocs['pbg_induk'] ??
                                formState.uploadedDocs['imb_induk'],
                          ),
                          _buildDocReviewRow(
                            'File AutoCAD DWG',
                            formState.uploadedDocs['site_plan_dwg'],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Declaration Checkbox
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: formState.isAgreed,
                        activeColor: AppColors.chilliDust,
                        onChanged: (val) => ref
                            .read(pengajuanFormProvider.notifier)
                            .toggleAgreement(val ?? false),
                      ),
                      const Expanded(
                        child: Text(
                          'Saya menyatakan bahwa seluruh data dan dokumen yang saya unggah adalah benar, sah, dan dapat dipertanggungjawabkan secara hukum.',
                          style: AppTextStyles.bodySmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

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
          child: Row(
            children: [
              Expanded(
                child: AppButton.secondary(
                  text: 'Edit Pengajuan',
                  onPressed: () => context.pop(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppButton.primary(
                  text: 'Kirim Pengajuan',
                  onPressed: formState.isAllValid && !_isSubmitting
                      ? submit
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _missingRequirements(PengajuanFormState state) {
    final missing = <String>[];
    if (!state.isStep1Valid) missing.add('data dasar Step 1');
    if (!state.isStep2Valid) missing.add('5 dokumen Step 2');
    if (!state.isStep3Valid) missing.add('dokumen wajib Step 3');
    if (!state.isStep4Valid) missing.add('minimal 1 berkas teknis Step 4');
    if (!state.isAgreed) missing.add('persetujuan pernyataan');
    return 'Lengkapi ${missing.join(', ')} sebelum mengirim pengajuan.';
  }

  String _newSubmissionId(DateTime now, List<Pengajuan> existing) {
    final date =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    var sequence = now.millisecondsSinceEpoch % 900;
    for (var attempt = 0; attempt < 900; attempt++) {
      final id = 'SR-$date-${(sequence + 100).toString()}';
      if (!existing.any((item) => item.id == id)) return id;
      sequence = (sequence + 1) % 900;
    }
    return 'SR-$date-${now.microsecondsSinceEpoch}';
  }

  String _monthName(int month) {
    const names = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return names[month - 1];
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey600),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocReviewRow(String label, String? filename) {
    final exists = filename != null && filename.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey600),
          ),
          Row(
            children: [
              if (exists) ...[
                const Icon(
                  Icons.check_circle,
                  color: AppColors.pistachioCream,
                  size: 18,
                ),
                const SizedBox(width: 4),
                const Text(
                  'Tersedia',
                  style: TextStyle(
                    color: AppColors.pistachioCream,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ] else ...[
                const Icon(Icons.warning, color: AppColors.error, size: 18),
                const SizedBox(width: 4),
                const Text(
                  'Belum Ada',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
