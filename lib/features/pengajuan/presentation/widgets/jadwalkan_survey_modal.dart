import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/pengajuan_model.dart';

class JadwalkanSurveyModal extends StatefulWidget {
  final Pengajuan pengajuan;
  final Function(DateTime tanggal, String catatan) onSubmit;

  const JadwalkanSurveyModal({
    super.key,
    required this.pengajuan,
    required this.onSubmit,
  });

  @override
  State<JadwalkanSurveyModal> createState() => _JadwalkanSurveyModalState();
}

class _JadwalkanSurveyModalState extends State<JadwalkanSurveyModal> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 2));
  String _selectedPerwaskimId = '3';
  final _catatanController = TextEditingController();

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEEE, d MMMM yyyy').format(_selectedDate);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Jadwalkan Survey Lapangan', style: AppTextStyles.h3),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Tanggal Execution Survey *',
              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 90)),
                );
                if (picked != null) {
                  setState(() {
                    _selectedDate = picked;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.grey300),
                  borderRadius: BorderRadius.circular(10),
                  color: AppColors.grey50,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(dateStr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const Icon(Icons.calendar_month, color: AppColors.chilliDust),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Petugas Perwaskim Ditugaskan *',
              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.grey300),
                borderRadius: BorderRadius.circular(10),
                color: AppColors.grey50,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedPerwaskimId,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: '3', child: Text('Drs. Rian Hidayat, M.Si (Ketua Tim Perwaskim)')),
                    DropdownMenuItem(value: '4', child: Text('Budi Santoso, S.T. (Inspektur Lapangan I)')),
                    DropdownMenuItem(value: '5', child: Text('Siti Rahmawati, M.T. (Inspektur Lapangan II)')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedPerwaskimId = val);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Catatan Tambahan & Instruksi Pendampingan',
              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _catatanController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Contoh: Titik kumpul di gerbang utama jam 09:00 WIB. Wajib didampingi Site Manager...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.chilliDust, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.chilliDust,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  widget.onSubmit(_selectedDate, _catatanController.text.trim());
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.event_available, color: Colors.white),
                label: const Text('Jadwalkan & Kirim Notifikasi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
