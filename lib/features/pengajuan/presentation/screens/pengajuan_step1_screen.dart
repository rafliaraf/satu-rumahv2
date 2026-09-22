import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/stepper_header.dart';
import '../providers/pengajuan_form_controller.dart';

class PengajuanStep1Screen extends ConsumerStatefulWidget {
  const PengajuanStep1Screen({super.key});

  @override
  ConsumerState<PengajuanStep1Screen> createState() =>
      _PengajuanStep1ScreenState();
}

class _PengajuanStep1ScreenState extends ConsumerState<PengajuanStep1Screen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaPerumahanController;
  late TextEditingController _npwpController;
  late TextEditingController _luasController;
  late TextEditingController _unitController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(pengajuanFormProvider);
    _namaPerumahanController = TextEditingController(text: state.namaPerumahan);
    _npwpController = TextEditingController(text: state.npwpPerusahaan);
    _luasController = TextEditingController(
      text: state.luasLahan > 0 ? state.luasLahan.toString() : '',
    );
    _unitController = TextEditingController(
      text: state.jumlahUnit > 0 ? state.jumlahUnit.toString() : '',
    );
  }

  @override
  void dispose() {
    _namaPerumahanController.dispose();
    _npwpController.dispose();
    _luasController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  void _syncState() {
    final notifier = ref.read(pengajuanFormProvider.notifier);
    notifier.updateNamaPerumahan(_namaPerumahanController.text);
    notifier.updateNpwp(_npwpController.text);
    notifier.updateLuasLahan(double.tryParse(_luasController.text) ?? 0.0);
    notifier.updateJumlahUnit(int.tryParse(_unitController.text) ?? 0);
  }

  void _onNext() {
    _syncState();
    if (_formKey.currentState?.validate() == true &&
        ref.read(pengajuanFormProvider).isStep1Valid) {
      context.push('/pengajuan/step2');
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(pengajuanFormProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: 'Pengajuan Baru (Step 1)',
        showNotifications: false,
        showBackButton: true,
        actions: [
          TextButton(
            onPressed: () {
              ref.read(pengajuanFormProvider.notifier).fillDummyData();
              final updated = ref.read(pengajuanFormProvider);
              setState(() {
                _namaPerumahanController.text = updated.namaPerumahan;
                _npwpController.text = updated.npwpPerusahaan;
                _luasController.text = updated.luasLahan.toString();
                _unitController.text = updated.jumlahUnit.toString();
              });
            },
            child: const Text(
              'Isi Dummy',
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const StepperHeader(currentStep: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Read-only Perusahaan Info
                    const Card(
                      color: AppColors.grey100,
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Informasi Developer (Read-Only)',
                              style: AppTextStyles.titleMedium,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Nama PT: PT. Tasik Indah Sentosa',
                              style: AppTextStyles.bodyMedium,
                            ),
                            Text(
                              'Direktur: H. Tatang Sutisna',
                              style: AppTextStyles.bodyMedium,
                            ),
                            Text(
                              'NIB: 9120304958102',
                              style: AppTextStyles.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    AppTextField(
                      label: 'Nama Perumahan *',
                      hintText: 'Contoh: Green Tasik Residence',
                      controller: _namaPerumahanController,
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'Nama perumahan wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'NPWP Perusahaan *',
                      hintText: 'Contoh: 12.345.678.9-423.000',
                      controller: _npwpController,
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'NPWP wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Luas Lahan (m²) *',
                      hintText: 'Masukkan luas lahan',
                      controller: _luasController,
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        final value = val == null
                            ? null
                            : double.tryParse(val.trim());
                        return value == null || !value.isFinite || value <= 0
                            ? 'Luas lahan harus lebih dari 0'
                            : null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Jumlah Unit Rencana *',
                      hintText: 'Masukkan jumlah unit rencana',
                      controller: _unitController,
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        final value = val == null
                            ? null
                            : int.tryParse(val.trim());
                        return value == null || value <= 0
                            ? 'Jumlah unit harus lebih dari 0'
                            : null;
                      },
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Tipe Perumahan *',
                      style: AppTextStyles.labelLarge,
                    ),
                    RadioGroup<String>(
                      groupValue: formState.tipePerumahan,
                      onChanged: (val) => ref
                          .read(pengajuanFormProvider.notifier)
                          .updateTipe(val!),
                      child: const Row(
                        children: [
                          Radio<String>(
                            value: 'Subsidi',
                            activeColor: AppColors.chilliDust,
                          ),
                          Text('Subsidi'),
                          SizedBox(width: 20),
                          Radio<String>(
                            value: 'Komersil',
                            activeColor: AppColors.chilliDust,
                          ),
                          Text('Komersil'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
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
          child: AppButton.primary(text: 'Selanjutnya', onPressed: _onNext),
        ),
      ),
    );
  }
}
