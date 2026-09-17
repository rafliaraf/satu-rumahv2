import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/status_hasil_evaluasi.dart';
import '../providers/monitoring_form_provider.dart';
import '../widgets/dynamic_bullet_field.dart';
import '../widgets/evidence_photo_picker.dart';
import '../widgets/status_hasil_evaluasi_selector_widget.dart';

class TambahMonitoringStepperScreen extends ConsumerStatefulWidget {
  const TambahMonitoringStepperScreen({super.key});

  @override
  ConsumerState<TambahMonitoringStepperScreen> createState() =>
      _TambahMonitoringStepperScreenState();
}

class _TambahMonitoringStepperScreenState
    extends ConsumerState<TambahMonitoringStepperScreen> {
  final ScrollController _scrollController = ScrollController();
  late TextEditingController _namaPerumahanController;
  late TextEditingController _lokasiController;
  late TextEditingController _pelaksanaNamaController;
  late TextEditingController _pelaksanaJabatanController;
  late TextEditingController _ditemuiNamaController;
  late TextEditingController _ditemuiJabatanController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(monitoringFormProvider);
    _namaPerumahanController = TextEditingController(text: state.namaPerumahan);
    _lokasiController = TextEditingController(text: state.lokasiPerumahan);
    _pelaksanaNamaController = TextEditingController(text: state.pelaksanaNama);
    _pelaksanaJabatanController = TextEditingController(
      text: state.pelaksanaJabatan,
    );
    _ditemuiNamaController = TextEditingController(text: state.ditemuiNama);
    _ditemuiJabatanController = TextEditingController(
      text: state.ditemuiJabatan,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _namaPerumahanController.dispose();
    _lokasiController.dispose();
    _pelaksanaNamaController.dispose();
    _pelaksanaJabatanController.dispose();
    _ditemuiNamaController.dispose();
    _ditemuiJabatanController.dispose();
    super.dispose();
  }

  void _syncControllers(MonitoringFormState next) {
    if (_namaPerumahanController.text != next.namaPerumahan) {
      _namaPerumahanController.text = next.namaPerumahan;
    }
    if (_lokasiController.text != next.lokasiPerumahan) {
      _lokasiController.text = next.lokasiPerumahan;
    }
    if (_pelaksanaNamaController.text != next.pelaksanaNama) {
      _pelaksanaNamaController.text = next.pelaksanaNama;
    }
    if (_pelaksanaJabatanController.text != next.pelaksanaJabatan) {
      _pelaksanaJabatanController.text = next.pelaksanaJabatan;
    }
    if (_ditemuiNamaController.text != next.ditemuiNama) {
      _ditemuiNamaController.text = next.ditemuiNama;
    }
    if (_ditemuiJabatanController.text != next.ditemuiJabatan) {
      _ditemuiJabatanController.text = next.ditemuiJabatan;
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(monitoringFormProvider);
    final notifier = ref.read(monitoringFormProvider.notifier);

    ref.listen<MonitoringFormState>(monitoringFormProvider, (previous, next) {
      _syncControllers(next);
      if (previous != null && previous.currentStep != next.currentStep) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () {
              if (formState.currentStep > 0) {
                notifier.setStep(formState.currentStep - 1);
              } else if (context.canPop()) {
                context.pop();
              } else {
                context.go('/monitoring/lapangan');
              }
            },
            borderRadius: AppRadii.pill,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.grey300),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: AppColors.cocoaBeanRoast,
                size: 18,
              ),
            ),
          ),
        ),
        title: const Text(
          'Form Monitoring Lapangan',
          style: TextStyle(
            color: AppColors.cocoaBeanRoast,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        actions: [
          if (kDebugMode)
            IconButton(
              tooltip: 'Isi Contoh',
              onPressed: () {
                notifier.fillDummyData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Data contoh berhasil diisikan!'),
                  ),
                );
              },
              icon: const Icon(
                Icons.flash_on,
                color: AppColors.actionPrimary,
                size: 20,
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Stepper Header Bar with Linear Progress Line
          _buildStepperHeader(formState.currentStep),

          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              child: _buildCurrentStep(context, formState, notifier),
            ),
          ),

          // Pinned Bottom Button Bar
          _buildBottomBar(context, formState, notifier),
        ],
      ),
    );
  }

  Widget _buildStepperHeader(int currentStep) {
    double progressPercent = (currentStep + 1) / 3.0;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      child: Column(
        children: [
          // Red linear progress bar line
          ClipRRect(
            borderRadius: AppRadii.tight,
            child: LinearProgressIndicator(
              value: progressPercent,
              minHeight: 4,
              backgroundColor: AppColors.grey200,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.actionPrimary,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Stepper Circles & Labels Row
          Row(
            children: [
              Expanded(child: _buildStepItem(1, 'Informasi Umum', currentStep)),
              const SizedBox(width: 4),
              Expanded(
                child: _buildStepItem(2, 'Informasi Lanjutan', currentStep),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _buildStepItem(3, 'Upload Dokumentasi', currentStep),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(int stepNumber, String label, int currentStep) {
    final isDone = (currentStep + 1) > stepNumber;
    final isActive = (currentStep + 1) == stepNumber;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: (isActive || isDone)
                ? AppColors.actionPrimary
                : Colors.white,
            border: Border.all(
              color: (isActive || isDone)
                  ? AppColors.actionPrimary
                  : AppColors.grey400,
              width: 1.5,
            ),
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, size: 12, color: Colors.white)
                : Text(
                    '$stepNumber',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isActive ? Colors.white : AppColors.grey600,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? AppColors.actionPrimary : AppColors.textMuted,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentStep(
    BuildContext context,
    MonitoringFormState formState,
    MonitoringFormNotifier notifier,
  ) {
    switch (formState.currentStep) {
      case 0:
        return _buildStep1(context, formState, notifier);
      case 1:
        return _buildStep2(context, formState, notifier);
      case 2:
        return _buildStep3(context, formState, notifier);
      default:
        return _buildStep1(context, formState, notifier);
    }
  }

  // STEP 1: Informasi Umum (Mockup 1)
  Widget _buildStep1(
    BuildContext context,
    MonitoringFormState state,
    MonitoringFormNotifier notifier,
  ) {
    final dateStr = DateFormat(
      'EEEE, d MMMM yyyy',
    ).format(state.tanggalMonitoring);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sub-header Uppercase Red Text
        const Text(
          'LANGKAH 01',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.actionPrimary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Informasi umum',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.cocoaBeanRoast,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Lengkapi data dasar monitoring lapangan.',
          style: TextStyle(fontSize: 13, color: AppColors.grey600),
        ),
        const SizedBox(height: 24),

        // Hari / Tanggal Monitoring
        Text(
          'Hari / Tanggal Monitoring',
          style: AppTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: state.tanggalMonitoring,
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (picked != null) notifier.updateTanggal(picked);
          },
          borderRadius: AppRadii.card,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.grey300),
              borderRadius: AppRadii.card,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateStr,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.cocoaBeanRoast,
                  ),
                ),
                const Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: AppColors.grey600,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Nama Perumahan
        _buildTextField(
          'Nama Perumahan',
          _namaPerumahanController,
          notifier.updateNamaPerumahan,
          'Masukkan Nama Perumahan',
        ),
        const SizedBox(height: 20),

        // Lokasi Perumahan
        _buildTextField(
          'Lokasi Perumahan',
          _lokasiController,
          notifier.updateLokasi,
          'Masukkan lokasi perumahan',
        ),
      ],
    );
  }

  // STEP 2: Informasi Lanjutan
  Widget _buildStep2(
    BuildContext context,
    MonitoringFormState state,
    MonitoringFormNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'LANGKAH 02',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.actionPrimary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Informasi lanjutan',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.cocoaBeanRoast,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Isi temuan, kesimpulan, dan status evaluasi lapangan.',
          style: TextStyle(fontSize: 13, color: AppColors.grey600),
        ),
        const SizedBox(height: 20),

        // Maksud & Tujuan
        Text(
          'Maksud dan Tujuan',
          style: AppTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceSubtle,
            borderRadius: AppRadii.control,
            border: Border.all(color: AppColors.grey300),
          ),
          child: Text(
            state.maksudTujuan,
            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
              color: AppColors.grey800,
            ),
          ),
        ),
        const SizedBox(height: 20),

        DynamicBulletField(
          label: 'Temuan di Lapangan',
          items: state.temuanLapangan,
          onItemsChanged: notifier.updateTemuan,
          placeholderText: 'Masukkan temuan di lapangan',
        ),
        const SizedBox(height: 20),

        DynamicBulletField(
          label: 'Kesimpulan',
          items: state.kesimpulan,
          onItemsChanged: notifier.updateKesimpulan,
          placeholderText: 'Masukkan kesimpulan',
        ),
        const SizedBox(height: 20),

        DynamicBulletField(
          label: 'Kesepakatan',
          items: state.kesepakatan,
          onItemsChanged: notifier.updateKesepakatan,
          placeholderText: 'Masukkan kesepakatan',
        ),
        const SizedBox(height: 20),

        DynamicBulletField(
          label: 'Rencana Tindak Lanjut',
          items: state.rencanaTindakLanjut,
          onItemsChanged: notifier.updateRTL,
          placeholderText: 'Masukkan rencana tindak lanjut',
        ),
        const SizedBox(height: 20),

        StatusHasilEvaluasiSelectorWidget(
          selectedStatus: state.statusHasilEvaluasi,
          onChanged: notifier.updateStatusHasilEvaluasi,
        ),
      ],
    );
  }

  // STEP 3: Evidence & Tanda Tangan (Mockup 5)
  Widget _buildStep3(
    BuildContext context,
    MonitoringFormState state,
    MonitoringFormNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'LANGKAH 03',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.actionPrimary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Evidence & tanda tangan',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.cocoaBeanRoast,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Upload foto evidence dan isi data penandatangan.',
          style: TextStyle(fontSize: 13, color: AppColors.grey600),
        ),
        const SizedBox(height: 24),

        // Photo Picker Widget
        EvidencePhotoPicker(
          photoPaths: state.photoPaths,
          onPhotosChanged: notifier.updatePhotos,
        ),
        const SizedBox(height: 28),

        // Wet Signature Section Header
        Row(
          children: [
            const Text(
              'Tanda Tangan Basah ',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.cocoaBeanRoast,
              ),
            ),
            Text(
              '(Wet Signature)',
              style: TextStyle(fontSize: 12, color: AppColors.grey600),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 2 Side-by-side Cards
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card 1: Petugas Monitoring
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadii.control,
                  border: Border.all(color: AppColors.grey300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Petugas Monitoring',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.cocoaBeanRoast,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildUnderlineField(
                      'Nama lengkap',
                      _pelaksanaNamaController,
                      notifier.updatePelaksanaNama,
                    ),
                    const SizedBox(height: 8),
                    _buildUnderlineField(
                      'Jabatan',
                      _pelaksanaJabatanController,
                      notifier.updatePelaksanaJabatan,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Card 2: Pihak Perumahan / Developer
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadii.control,
                  border: Border.all(color: AppColors.grey300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pihak Perumahan / Developer',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.cocoaBeanRoast,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildUnderlineField(
                      'Nama lengkap',
                      _ditemuiNamaController,
                      notifier.updateDitemuiNama,
                    ),
                    const SizedBox(height: 8),
                    _buildUnderlineField(
                      'Jabatan',
                      _ditemuiJabatanController,
                      notifier.updateDitemuiJabatan,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        const Text(
          '*Dokumen hasil generate akan diprint untuk Tanda Tangan Basah di lokasi.',
          style: TextStyle(
            fontSize: 11,
            fontStyle: FontStyle.italic,
            color: AppColors.grey600,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    ValueChanged<String> onChanged,
    String hint,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 13,
              color: AppColors.textMuted,
            ),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: AppRadii.card,
              borderSide: const BorderSide(color: AppColors.grey300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadii.card,
              borderSide: const BorderSide(color: AppColors.grey300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadii.card,
              borderSide: const BorderSide(color: AppColors.actionPrimary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUnderlineField(
    String hintText,
    TextEditingController controller,
    ValueChanged<String> onChanged,
  ) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 12),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 6),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.grey300),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.actionPrimary),
        ),
      ),
    );
  }

  // Pinned Bottom Button Bar
  Widget _buildBottomBar(
    BuildContext context,
    MonitoringFormState formState,
    MonitoringFormNotifier notifier,
  ) {
    final isLastStep = formState.currentStep == 2;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.actionPrimary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: AppRadii.pill),
            ),
            onPressed: () {
              if (formState.currentStep == 0) {
                if (_namaPerumahanController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Nama Perumahan wajib diisi.'),
                    ),
                  );
                  return;
                }
                notifier.setStep(1);
              } else if (formState.currentStep == 1) {
                final rtl = formState.rencanaTindakLanjut
                    .where((e) => e.trim().isNotEmpty)
                    .toList();
                if (formState.statusHasilEvaluasi.wajibRencanaTindakLanjut &&
                    rtl.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Untuk status "${formState.statusHasilEvaluasi.label}", wajib mengisikan minimal 1 poin Rencana Tindak Lanjut.',
                      ),
                      backgroundColor: AppColors.actionPrimary,
                    ),
                  );
                  return;
                }
                notifier.setStep(2);
              } else {
                // Last step -> Navigate to Preview Screen
                final previewModel = notifier.buildPreviewModel();
                if (previewModel != null) {
                  context.push(
                    '/monitoring/preview',
                    extra: {'model': previewModel, 'isDraft': true},
                  );
                } else {
                  final err = ref.read(monitoringFormProvider).errorMessage;
                  if (err != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(err),
                        backgroundColor: AppColors.actionPrimary,
                      ),
                    );
                  }
                }
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isLastStep ? 'PREVIEW & SUBMIT' : 'LANJUTKAN',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
