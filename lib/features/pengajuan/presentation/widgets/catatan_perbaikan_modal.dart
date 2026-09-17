import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/pengajuan_model.dart';

class CatatanPerbaikanModal extends StatefulWidget {
  final Pengajuan pengajuan;
  final Function(String catatan, List<String> selectedDocKeys) onSubmit;

  const CatatanPerbaikanModal({
    super.key,
    required this.pengajuan,
    required this.onSubmit,
  });

  @override
  State<CatatanPerbaikanModal> createState() => _CatatanPerbaikanModalState();
}

class _CatatanPerbaikanModalState extends State<CatatanPerbaikanModal> {
  final _catatanController = TextEditingController();
  late Set<String> _selectedDocs;

  final Map<String, String> _docLabels = {
    // Perusahaan (5 Berkas Utama)
    'legalitas': 'Akta Pendirian Perusahaan & Pengesahan',
    'nib': 'Nomor Induk Berusaha (NIB / OSS)',
    'npwp_doc': 'NPWP Perusahaan Wajib Pajak',
    'ktp': 'KTP Direktur / Penanggung Jawab',
    'asosiasi': 'Bukti Keanggotaan Asosiasi Pengembang',
    // Perumahan
    'surat_permohonan': 'Surat Permohonan Pengesahan Site Plan',
    'info_intensitas_ruang': 'Informasi Intensitas Ruang (KRK/ITR)',
    'bukti_kepemilikan_lahan': 'Bukti Kepemilikan & Penguasaan Lahan',
    'bukti_tpu': 'Bukti Penyediaan Lahan Tempat Pemakaman (TPU)',
    'kkpr_doc': 'Kesesuaian Kegiatan Pemanfaatan Ruang (KKPR)',
    'pbg_induk': 'Persetujuan Bangunan Gedung (PBG Induk)',
    'rekomendasi_lingkungan': 'Rekomendasi Dokumen Lingkungan (SPPL/UKL-UPL)',
    'pelepasan_lahan': 'Surat Pelepasan Lahan Kas Desa (bila ada)',
    'pernyataan_pelepasan': 'Surat Pernyataan Pelepasan Hak Lahan',
    'pernyataan_keabsahan': 'Surat Pernyataan Keabsahan Dokumen',
    'pernyataan_psu': 'Surat Pernyataan Penyerahan PSU ke Pemkot',
    // Teknis
    'site_plan_dwg': 'Master Layout Site Plan (File CAD DWG / PDF)',
  };

  @override
  void initState() {
    super.initState();
    // Pre-select documents marked as false (Tidak Sesuai)
    _selectedDocs = widget.pengajuan.verifiedDocs.entries
        .where((e) => e.value == false)
        .map((e) => e.key)
        .toSet();

    // If none marked as false, fallback to any existing revisi list
    if (_selectedDocs.isEmpty &&
        widget.pengajuan.dokumenPerluRevisi.isNotEmpty) {
      _selectedDocs.addAll(widget.pengajuan.dokumenPerluRevisi);
    }
  }

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final availableDocs = widget.pengajuan.uploadedDocs.keys.isNotEmpty
        ? widget.pengajuan.uploadedDocs.keys.toList()
        : _docLabels.keys.toList();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 12,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Drag Handle Indicator
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Minta Perbaikan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.cocoaBeanRoast,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.grey700),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Text(
              'Tinggalkan catatan yang jelas untuk developer.',
              style: TextStyle(fontSize: 12, color: AppColors.grey600),
            ),
            const SizedBox(height: 16),

            // Textarea
            TextField(
              controller: _catatanController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Tulis catatan perbaikan...',
                hintStyle: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
                filled: true,
                fillColor: const Color(0xFFF9F8F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.grey300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppColors.chilliDust,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Label Dokumen yang perlu direvisi
            const Text(
              'Dokumen yang perlu direvisi',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.cocoaBeanRoast,
              ),
            ),
            const SizedBox(height: 6),

            if (availableDocs.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Tidak ada dokumen terunggah.',
                  style: TextStyle(color: AppColors.grey600, fontSize: 12),
                ),
              )
            else
              ...availableDocs.map((key) {
                final label = _docLabels[key] ?? key;
                final isChecked = _selectedDocs.contains(key);

                return CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppColors.chilliDust,
                  dense: true,
                  title: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isChecked
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: AppColors.cocoaBeanRoast,
                    ),
                  ),
                  value: isChecked,
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        _selectedDocs.add(key);
                      } else {
                        _selectedDocs.remove(key);
                      }
                    });
                  },
                );
              }),
            const SizedBox(height: 20),

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.chilliDust,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: () {
                  if (_catatanController.text.trim().isEmpty ||
                      _selectedDocs.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Tulis catatan dan pilih minimal 1 dokumen yang perlu direvisi.',
                        ),
                      ),
                    );
                    return;
                  }
                  widget.onSubmit(
                    _catatanController.text.trim(),
                    _selectedDocs.toList(),
                  );
                  Navigator.pop(context);
                },
                child: const Text(
                  'Kirim Catatan Perbaikan',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
