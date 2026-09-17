import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/pengajuan_model.dart';
import '../../data/models/status_tahap_pengajuan.dart';
import '../providers/pengajuan_form_controller.dart';
import '../providers/pengajuan_verifikasi_controller.dart';
import '../widgets/catatan_perbaikan_modal.dart';
import '../widgets/hasil_survey_tab.dart';
import '../widgets/jadwalkan_survey_modal.dart';
import '../../../../core/utils/file_picker_util.dart';

class PengajuanAdminDetailScreen extends ConsumerStatefulWidget {
  final String id;

  const PengajuanAdminDetailScreen({super.key, required this.id});

  @override
  ConsumerState<PengajuanAdminDetailScreen> createState() =>
      _PengajuanAdminDetailScreenState();
}

class _PengajuanAdminDetailScreenState
    extends ConsumerState<PengajuanAdminDetailScreen> {
  int _selectedTabIndex = 0;

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

  final List<String> _perusahaanKeys = [
    'legalitas',
    'nib',
    'npwp_doc',
    'ktp',
    'asosiasi',
  ];
  final List<String> _perumahanKeys = [
    'surat_permohonan',
    'info_intensitas_ruang',
    'bukti_kepemilikan_lahan',
    'bukti_tpu',
    'kkpr_doc',
    'pbg_induk',
    'rekomendasi_lingkungan',
    'pelepasan_lahan',
    'pernyataan_pelepasan',
    'pernyataan_keabsahan',
    'pernyataan_psu',
  ];
  final List<String> _teknisKeys = ['site_plan_dwg'];

  String _getFileMeta(String? filePath, String fallbackDate) {
    if (filePath == null || filePath.isEmpty) return 'Belum diunggah';
    try {
      final file = File(filePath);
      if (file.existsSync()) {
        final stat = file.statSync();
        final sizeBytes = stat.size;
        final sizeStr = sizeBytes >= 1024 * 1024
            ? '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB'
            : '${(sizeBytes / 1024).toStringAsFixed(0)} KB';
        final dateStr = DateFormat('d MMM yyyy, HH:mm').format(stat.modified);
        final ext = filePath.split('.').last.toUpperCase();
        return '$ext · $sizeStr · Diunggah $dateStr';
      }
    } catch (_) {}

    return 'Berkas tidak tersedia secara lokal';
  }

  @override
  Widget build(BuildContext context) {
    final list = ref.watch(pengajuanListProvider);
    Pengajuan? foundPengajuan;
    for (final item in list) {
      if (item.id == widget.id) {
        foundPengajuan = item;
        break;
      }
    }
    if (foundPengajuan == null) {
      return _buildNotFoundState(context);
    }
    // Keep callbacks and builders on a stable non-null value. A nullable
    // lookup must never leak into nested closures after the not-found branch.
    final Pengajuan pengajuan = foundPengajuan;

    final status = pengajuan.statusTahap;
    final effectiveStatus = status == StatusTahapPengajuan.perluPerbaikan
        ? (pengajuan.tahapAsalPerbaikan ??
              StatusTahapPengajuan.verifikasiAdministrasi)
        : status;

    // Tab Hasil Survey hanya tampil saat survey sudah/sedang dijadwalkan
    final bool showHasilSurveyTab =
        effectiveStatus == StatusTahapPengajuan.surveyLapangan ||
        effectiveStatus == StatusTahapPengajuan.persetujuan ||
        effectiveStatus == StatusTahapPengajuan.selesai;

    // Tab index mapping: 0=Perusahaan, 1=Perumahan, 2=Teknis, 3=Hasil Survey (kondisional)
    // Pastikan index tidak keluar range jika tab Hasil Survey disembunyikan
    final effectiveTabIndex = (!showHasilSurveyTab && _selectedTabIndex == 3)
        ? 2
        : _selectedTabIndex;

    List<String> currentDocKeys;
    if (effectiveTabIndex == 0) {
      currentDocKeys = _perusahaanKeys;
    } else if (effectiveTabIndex == 1) {
      currentDocKeys = _perumahanKeys;
    } else if (effectiveTabIndex == 2) {
      currentDocKeys = _teknisKeys;
    } else {
      currentDocKeys = []; // Tab Hasil Survey - list dokumen tidak ditampilkan
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5EE),
      body: Column(
        children: [
          // Red Header Banner matching Mockup Detail Pengajuan.png
          Container(
            color: AppColors.chilliDust,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/admin');
                            }
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SATU RUMAH',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white.withValues(alpha: 0.8),
                                  letterSpacing: 1.1,
                                ),
                              ),
                              const Text(
                                'Detail Pengajuan',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      pengajuan.id,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.8),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      pengajuan.namaPerumahan,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      pengajuan.namaPt,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8D4A2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status.label.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.cocoaBeanRoast,
                        ),
                      ),
                    ),
                    if (pengajuan.revisionSubmitted) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.rate_review_outlined,
                              color: Colors.white,
                              size: 16,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Revisi baru menunggu keputusan Admin',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),

          // Segmented Tab Switcher (rounded container)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFEBE8DC),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  _buildSegmentTab(0, 'Dok. Perusahaan'),
                  _buildSegmentTab(1, 'Dok. Perumahan'),
                  _buildSegmentTab(2, 'Dok. Teknis'),
                  if (showHasilSurveyTab) _buildSegmentTab(3, 'Hasil Survey'),
                ],
              ),
            ),
          ),

          // Section Subtitle (sembunyikan saat tab Hasil Survey)
          if (effectiveTabIndex != 3)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 4.0,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'DOKUMEN ${effectiveTabIndex + 1} · ${currentDocKeys.length} BERKAS',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.grey700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          if (effectiveTabIndex != 3) const SizedBox(height: 8),

          // Document List, Dokumen Teknis, or Hasil Survey Tab
          Expanded(
            child: effectiveTabIndex == 3
                ? HasilSurveyTab(
                    pengajuan: pengajuan,
                    onUploadBeritaAcara: () async {
                      final file = await FilePickerUtil.pickSingleFile(
                        allowedExtensions: ['pdf'],
                      );
                      if (!context.mounted) return;
                      if (file == null ||
                          file.path == null ||
                          file.path!.trim().isEmpty) {
                        _showActionMessage(
                          context,
                          'Pemilihan Berita Acara dibatalkan; data tidak berubah.',
                        );
                        return;
                      }
                      final result = ref
                          .read(pengajuanVerifikasiControllerProvider.notifier)
                          .uploadBeritaAcara(
                            pengajuan.id,
                            file.path!,
                            hasilSurvey: pengajuan.riwayatSurvey.isNotEmpty
                                ? pengajuan.riwayatSurvey[0]
                                : null,
                          );
                      _showActionMessage(
                        context,
                        result.message,
                        success: result.stateChanged,
                      );
                    },
                  )
                : effectiveTabIndex == 2
                ? _buildDokumenTeknisTab(pengajuan)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: currentDocKeys.length,
                    itemBuilder: (context, index) {
                      final key = currentDocKeys[index];
                      final label = _docLabels[key] ?? key;
                      final fileName = pengajuan.uploadedDocs[key];
                      final isVerified = pengajuan.verifiedDocs[key];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFF9EAE8),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.description,
                                      color: AppColors.chilliDust,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          label,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.cocoaBeanRoast,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        if (fileName != null) ...[
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.attach_file,
                                                size: 12,
                                                color: AppColors.chilliDust,
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  fileName
                                                      .split(RegExp(r'[/\\]'))
                                                      .last,
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.chilliDust,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            _getFileMeta(
                                              fileName,
                                              pengajuan.tanggal,
                                            ),
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: AppColors.grey600,
                                            ),
                                          ),
                                        ] else ...[
                                          const Text(
                                            'Belum diunggah',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: AppColors.grey600,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      _showDocumentPreview(
                                        context,
                                        label,
                                        fileName,
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF2EFE6),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppColors.chilliDust
                                              .withValues(alpha: 0.3),
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.visibility,
                                            size: 13,
                                            color: AppColors.chilliDust,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            'Preview',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: AppColors.chilliDust,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
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
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  // Sesuai Toggle
                                  GestureDetector(
                                    onTap: () {
                                      ref
                                          .read(
                                            pengajuanVerifikasiControllerProvider
                                                .notifier,
                                          )
                                          .verifikasiDokumen(
                                            pengajuan.id,
                                            key,
                                            true,
                                          );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isVerified == true
                                            ? const Color(0xFFE2EED7)
                                            : const Color(0xFFF0EFEA),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isVerified == true
                                              ? const Color(0xFF5D7B38)
                                              : Colors.transparent,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            isVerified == true
                                                ? Icons.check_circle
                                                : Icons.radio_button_unchecked,
                                            size: 14,
                                            color: isVerified == true
                                                ? const Color(0xFF5D7B38)
                                                : AppColors.grey600,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Sesuai',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: isVerified == true
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                              color: isVerified == true
                                                  ? const Color(0xFF5D7B38)
                                                  : AppColors.cocoaBeanRoast,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Tidak Sesuai Toggle
                                  GestureDetector(
                                    onTap: () {
                                      ref
                                          .read(
                                            pengajuanVerifikasiControllerProvider
                                                .notifier,
                                          )
                                          .verifikasiDokumen(
                                            pengajuan.id,
                                            key,
                                            false,
                                          );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isVerified == false
                                            ? const Color(0xFFF9EAE8)
                                            : const Color(0xFFF0EFEA),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isVerified == false
                                              ? AppColors.chilliDust
                                              : Colors.transparent,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            isVerified == false
                                                ? Icons.cancel
                                                : Icons.radio_button_unchecked,
                                            size: 14,
                                            color: isVerified == false
                                                ? AppColors.chilliDust
                                                : AppColors.grey600,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Tidak Sesuai',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: isVerified == false
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                              color: isVerified == false
                                                  ? AppColors.chilliDust
                                                  : AppColors.cocoaBeanRoast,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      bottomNavigationBar: _buildBottomBar(context, pengajuan, status),
    );
  }

  Widget _buildUnavailableFileState(
    String title,
    String cleanName,
    String reason,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.file_present_outlined,
              size: 52,
              color: AppColors.grey600,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.cocoaBeanRoast,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              cleanName,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: AppColors.grey700),
            ),
            const SizedBox(height: 8),
            Text(
              reason,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: AppColors.grey600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocalPdfPreview(File file, String cleanName) {
    return FutureBuilder<Uint8List>(
      future: file.readAsBytes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError ||
            snapshot.data == null ||
            snapshot.data!.isEmpty) {
          return _buildUnavailableFileState(
            'Pratinjau PDF tidak tersedia',
            cleanName,
            'Berkas lokal tidak dapat dibaca.',
          );
        }
        return PdfPreview(
          build: (format) => snapshot.data!,
          allowPrinting: true,
          allowSharing: true,
          canChangeOrientation: false,
          canChangePageFormat: false,
          canDebug: false,
          onError: (context, error) => _buildUnavailableFileState(
            'Pratinjau PDF tidak tersedia',
            cleanName,
            'PDF gagal dirender: $error',
          ),
        );
      },
    );
  }

  void _showDocumentPreview(
    BuildContext context,
    String title,
    String? fileName,
  ) {
    final fileStr = fileName ?? title;
    final cleanName = fileStr.split(RegExp(r'[/\\]')).last;
    final localFile = File(fileStr);
    final isLocalFile = localFile.existsSync();
    final isUrl =
        fileStr.startsWith('http://') || fileStr.startsWith('https://');

    final lower = fileStr.toLowerCase();
    final isImage =
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.heic');
    final isPdf = lower.endsWith('.pdf');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Drag handle & Header
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.chilliDust.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isImage
                          ? Icons.image
                          : (isPdf
                                ? Icons.picture_as_pdf
                                : Icons.insert_drive_file),
                      color: AppColors.chilliDust,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.cocoaBeanRoast,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          cleanName,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.grey600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.grey700),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Content Viewer
            Expanded(
              child: Container(
                color: const Color(0xFFF4F2EB),
                child: Builder(
                  builder: (context) {
                    if (fileName == null ||
                        fileName.trim().isEmpty ||
                        (!isUrl && !isLocalFile)) {
                      return _buildUnavailableFileState(
                        title,
                        cleanName,
                        isLocalFile
                            ? 'Berkas tidak dapat dibaca.'
                            : 'Berkas belum tersedia pada perangkat ini.',
                      );
                    }

                    // 1. Real Local Image File
                    if (isLocalFile && isImage) {
                      return InteractiveViewer(
                        minScale: 0.5,
                        maxScale: 4.0,
                        child: Center(
                          child: Image.file(localFile, fit: BoxFit.contain),
                        ),
                      );
                    }

                    if (isLocalFile && isPdf) {
                      return _buildLocalPdfPreview(localFile, cleanName);
                    }

                    // 2. Remote Image URL
                    if (isUrl && isImage) {
                      return InteractiveViewer(
                        child: Center(
                          child: Image.network(fileStr, fit: BoxFit.contain),
                        ),
                      );
                    }

                    return _buildUnavailableFileState(
                      title,
                      cleanName,
                      isPdf
                          ? 'Pratinjau PDF belum tersedia untuk format ini.'
                          : 'Format berkas ini belum memiliki pratinjau.',
                    );
                  },
                ),
              ),
            ),

            // Bottom Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  if (isLocalFile) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          try {
                            await Share.shareXFiles([XFile(localFile.path)]);
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Gagal membagikan berkas: $e'),
                                ),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.open_in_new, size: 18),
                        label: const Text('Buka di App Luar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ] else ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: null,
                        icon: const Icon(Icons.download, size: 18),
                        label: const Text('Unduh tidak tersedia'),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.chilliDust,
                      ),
                      icon: const Icon(
                        Icons.check,
                        size: 18,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Tutup',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Context-Aware Bottom Bar ─────────────────────────────────────────────

  Widget _buildBottomBar(
    BuildContext context,
    Pengajuan pengajuan,
    StatusTahapPengajuan status,
  ) {
    // Tentukan effective status saat perluPerbaikan
    StatusTahapPengajuan effectiveStatus = status;
    if (status == StatusTahapPengajuan.perluPerbaikan) {
      effectiveStatus =
          pengajuan.tahapAsalPerbaikan ??
          StatusTahapPengajuan.verifikasiAdministrasi;
    }

    // Keep the visible BA status aligned with the controller's authoritative
    // path-or-final-history predicate (approval still applies evaluation guard).
    final baGuard = ref
        .read(pengajuanVerifikasiControllerProvider.notifier)
        .surveyBaGuard(pengajuan.id);
    final bool hasBa = baGuard.allowed;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Row aksi utama ──
            if (status != StatusTahapPengajuan.selesai)
              Row(
                children: [
                  // Tombol kiri: Minta Perbaikan (semua tahap kecuali selesai)
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.chilliDust,
                          side: const BorderSide(
                            color: AppColors.chilliDust,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            builder: (ctx) => CatatanPerbaikanModal(
                              pengajuan: pengajuan,
                              onSubmit: (catatan, docs) {
                                final result = ref
                                    .read(
                                      pengajuanVerifikasiControllerProvider
                                          .notifier,
                                    )
                                    .mintaPerbaikan(
                                      pengajuan.id,
                                      catatan,
                                      docs,
                                    );
                                if (context.mounted) {
                                  _showActionMessage(
                                    context,
                                    result.message,
                                    success: result.stateChanged,
                                  );
                                }
                              },
                            ),
                          );
                        },
                        child: const Text(
                          'Minta Perbaikan',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Tombol kanan: Berbeda per tahap
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: _buildPrimaryActionButton(
                        context,
                        pengajuan,
                        effectiveStatus,
                      ),
                    ),
                  ),
                ],
              )
            else
              // Tahap selesai: satu tombol full-width
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: null,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: Colors.white,
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Pengajuan Selesai',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // ── Aksi sekunder (bawah) per tahap ──
            if (_buildSecondaryAction(
                  context,
                  pengajuan,
                  effectiveStatus,
                  hasBa,
                ) !=
                null) ...[
              const SizedBox(height: 4),
              _buildSecondaryAction(
                context,
                pengajuan,
                effectiveStatus,
                hasBa,
              )!,
            ],

            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryActionButton(
    BuildContext context,
    Pengajuan pengajuan,
    StatusTahapPengajuan effectiveStatus,
  ) {
    // Verifikasi Teknis → tombol Jadwalkan Survey
    if (effectiveStatus == StatusTahapPengajuan.verifikasiTeknis) {
      final scheduleGuard = ref
          .read(pengajuanVerifikasiControllerProvider.notifier)
          .jadwalSurveyGuard(pengajuan.id);
      return Tooltip(
        message: scheduleGuard.allowed
            ? 'Jadwalkan Survey'
            : scheduleGuard.message,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: scheduleGuard.allowed
                ? AppColors.cocoaBeanRoast
                : AppColors.grey300,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          onPressed: scheduleGuard.allowed
              ? () => _showJadwalkanSurveyModal(context, pengajuan)
              : null,
          icon: Icon(
            Icons.event_available,
            color: scheduleGuard.allowed ? Colors.white : AppColors.grey600,
            size: 16,
          ),
          label: Text(
            pengajuan.revisionSubmitted
                ? 'Tugaskan Pemeriksaan'
                : 'Jadwalkan Survey',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: scheduleGuard.allowed ? Colors.white : AppColors.grey600,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      );
    }

    // Survey Lapangan → approve only after linked final BA/evaluation guards.
    if (effectiveStatus == StatusTahapPengajuan.surveyLapangan) {
      final approveGuard = ref
          .read(pengajuanVerifikasiControllerProvider.notifier)
          .approveGuard(pengajuan.id);
      final canApprove = approveGuard.allowed;
      return Tooltip(
        message: canApprove ? 'Approve Tahap' : approveGuard.message,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: canApprove
                ? AppColors.chilliDust
                : AppColors.grey300,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          onPressed: canApprove
              ? () {
                  final result = ref
                      .read(pengajuanVerifikasiControllerProvider.notifier)
                      .approveTahap(pengajuan.id);
                  _showActionMessage(
                    context,
                    result.message,
                    success: result.stateChanged,
                  );
                }
              : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                canApprove ? Icons.check : Icons.lock_outline,
                size: 14,
                color: canApprove ? Colors.white : AppColors.grey600,
              ),
              const SizedBox(width: 6),
              Text(
                canApprove
                    ? (pengajuan.revisionSubmitted
                          ? 'Approve Revisi'
                          : 'Approve Tahap')
                    : 'Belum Siap',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: canApprove ? Colors.white : AppColors.grey600,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Default: Approve Tahap biasa
    final approveGuard = ref
        .read(pengajuanVerifikasiControllerProvider.notifier)
        .approveGuard(pengajuan.id);
    return Tooltip(
      message: approveGuard.allowed ? 'Approve Tahap' : approveGuard.message,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: approveGuard.allowed
              ? AppColors.chilliDust
              : AppColors.grey300,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        onPressed: approveGuard.allowed
            ? () {
                final result = ref
                    .read(pengajuanVerifikasiControllerProvider.notifier)
                    .approveTahap(pengajuan.id);
                _showActionMessage(
                  context,
                  result.message,
                  success: result.stateChanged,
                );
              }
            : null,
        child: Text(
          approveGuard.allowed
              ? (pengajuan.revisionSubmitted
                    ? 'Approve Revisi'
                    : 'Approve Tahap')
              : 'Belum Siap',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: approveGuard.allowed ? Colors.white : AppColors.grey600,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget? _buildSecondaryAction(
    BuildContext context,
    Pengajuan pengajuan,
    StatusTahapPengajuan effectiveStatus,
    bool hasBa,
  ) {
    // Survey Lapangan: Upload Berita Acara + Jadwalkan Survey ulang
    if (effectiveStatus == StatusTahapPengajuan.surveyLapangan) {
      if (hasBa) {
        return Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 14),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Berita Acara Diterbitkan oleh Tim Perwaskim (${_baDisplayLabel(pengajuan)})',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF2E7D32),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      }

      return Row(
        children: [
          Expanded(
            child: TextButton.icon(
              onPressed: () async {
                final file = await FilePickerUtil.pickSingleFile(
                  allowedExtensions: ['pdf'],
                );
                if (!context.mounted) return;
                if (file == null ||
                    file.path == null ||
                    file.path!.trim().isEmpty) {
                  _showActionMessage(
                    context,
                    'Pemilihan Berita Acara dibatalkan; data tidak berubah.',
                  );
                  return;
                }
                final result = ref
                    .read(pengajuanVerifikasiControllerProvider.notifier)
                    .uploadBeritaAcara(pengajuan.id, file.path!);
                _showActionMessage(
                  context,
                  result.message,
                  success: result.stateChanged,
                );
              },
              icon: const Icon(
                Icons.upload_file,
                color: AppColors.chilliDust,
                size: 15,
              ),
              label: const Text(
                'Upload Berita Acara',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.chilliDust,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: TextButton.icon(
              onPressed: () => _showJadwalkanSurveyModal(context, pengajuan),
              icon: const Icon(
                Icons.event_available,
                color: AppColors.cocoaBeanRoast,
                size: 15,
              ),
              label: const Text(
                'Jadwalkan Survey',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.cocoaBeanRoast,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Persetujuan: Upload SK Persetujuan
    if (effectiveStatus == StatusTahapPengajuan.persetujuan) {
      final hasSk =
          pengajuan.skPersetujuanPath != null &&
          pengajuan.skPersetujuanPath!.isNotEmpty;
      return TextButton.icon(
        onPressed: () async {
          final file = await FilePickerUtil.pickSingleFile(
            allowedExtensions: ['pdf', 'doc', 'docx'],
          );
          if (context.mounted) {
            if (file == null ||
                file.path == null ||
                file.path!.trim().isEmpty) {
              _showActionMessage(
                context,
                'Pemilihan SK dibatalkan; data tidak berubah.',
              );
              return;
            }
            final result = ref
                .read(pengajuanVerifikasiControllerProvider.notifier)
                .uploadSkPersetujuan(pengajuan.id, file.path!);
            _showActionMessage(
              context,
              result.message,
              success: result.stateChanged,
            );
          }
        },
        icon: Icon(
          Icons.upload_file,
          color: hasSk ? AppColors.statusApproved : AppColors.grey700,
          size: 15,
        ),
        label: Text(
          hasSk
              ? 'SK Persetujuan Terupload'
              : 'Upload SK Persetujuan ke Pengembang',
          style: TextStyle(
            color: hasSk ? AppColors.statusApproved : AppColors.grey700,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return null;
  }

  String _baDisplayLabel(Pengajuan pengajuan) {
    final directPath = pengajuan.beritaAcaraPath?.trim();
    if (directPath != null && directPath.isNotEmpty) return directPath;
    for (final survey in pengajuan.riwayatSurvey) {
      if (!survey.isDraft && survey.hasBa) {
        return survey.beritaAcaraPath!;
      }
    }
    return 'BA tersedia';
  }

  void _showActionMessage(
    BuildContext context,
    String message, {
    bool success = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success
            ? AppColors.pistachioCream
            : AppColors.chilliDust,
      ),
    );
  }

  void _showJadwalkanSurveyModal(BuildContext context, Pengajuan pengajuan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => JadwalkanSurveyModal(
        pengajuan: pengajuan,
        onSubmit: (tanggal, catatan) {
          final result = ref
              .read(pengajuanVerifikasiControllerProvider.notifier)
              .jadwalkanSurvey(pengajuan.id, tanggal, catatan);
          if (context.mounted) {
            _showActionMessage(
              context,
              result.message,
              success: result.stateChanged,
            );
          }
        },
      ),
    );
  }

  Widget _buildDokumenTeknisTab(Pengajuan pengajuan) {
    final files = pengajuan.technicalFiles.isNotEmpty
        ? pengajuan.technicalFiles
        : (pengajuan.uploadedDocs.containsKey('site_plan_dwg')
              ? [pengajuan.uploadedDocs['site_plan_dwg']!]
              : <String>[]);

    final selectedCakupan = pengajuan.selectedCakupanGambar.isNotEmpty
        ? pengajuan.selectedCakupanGambar
        : <String>[];

    final isVerified = pengajuan.verifiedDocs['site_plan_dwg'];

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        // 1. Berkas Teknis Card
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF9EAE8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.architecture,
                        color: AppColors.chilliDust,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Berkas Gambar Teknis & Site Plan',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.cocoaBeanRoast,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            files.isEmpty
                                ? 'Belum diunggah'
                                : '${files.length} Berkas Terunggah',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.grey600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (files.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Belum ada berkas teknis yang diunggah oleh pengembang.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.grey600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                else
                  Column(
                    children: files.map((fileName) {
                      final isDwg = fileName.toLowerCase().endsWith('.dwg');
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F5EE),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.grey300.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isDwg ? Icons.architecture : Icons.picture_as_pdf,
                              size: 20,
                              color: isDwg
                                  ? AppColors.chilliDust
                                  : AppColors.cocoaBeanRoast,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    fileName.split(RegExp(r'[/\\]')).last,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.cocoaBeanRoast,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    _getFileMeta(fileName, pengajuan.tanggal),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.grey600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () => _showDocumentPreview(
                                context,
                                'Gambar Teknis',
                                fileName,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: AppColors.chilliDust.withValues(
                                      alpha: 0.4,
                                    ),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.visibility,
                                      size: 12,
                                      color: AppColors.chilliDust,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Preview',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.chilliDust,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // 2. Cakupan Gambar Teknis Card (Green Chips & List Display)
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.fact_check_outlined,
                            color: AppColors.chilliDust,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'CAKUPAN GAMBAR TEKNIS (${selectedCakupan.length} / 21 Item)',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                                color: AppColors.cocoaBeanRoast,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: selectedCakupan.isNotEmpty
                            ? const Color(0xFFE2EED7)
                            : const Color(0xFFF9EAE8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        selectedCakupan.isNotEmpty
                            ? '${selectedCakupan.length} Terlampir'
                            : 'Belum Ada',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: selectedCakupan.isNotEmpty
                              ? const Color(0xFF5D7B38)
                              : AppColors.chilliDust,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Daftar rincian gambar teknis yang tercakup di dalam berkas terunggah:',
                  style: TextStyle(fontSize: 11, color: AppColors.grey600),
                ),
                const SizedBox(height: 14),
                if (selectedCakupan.isEmpty)
                  const Text(
                    'Pengembang belum memilih item cakupan gambar teknis.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.grey600,
                      fontStyle: FontStyle.italic,
                    ),
                  )
                else ...[
                  // Green Chips Summary
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: selectedCakupan.map((item) {
                      final maxChipWidth =
                          MediaQuery.of(context).size.width - 80;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        constraints: BoxConstraints(maxWidth: maxChipWidth),
                        decoration: BoxDecoration(
                          color: AppColors.pistachioCream.withValues(
                            alpha: 0.35,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.pistachioCream),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check,
                              size: 14,
                              color: AppColors.cocoaBeanRoast,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                item,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.cocoaBeanRoast,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  const Text(
                    'Rincian Berkas Gambar Teknis Tercentang:',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.cocoaBeanRoast,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Detailed Sequential List for Admin Evaluation
                  Column(
                    children: selectedCakupan.asMap().entries.map((entry) {
                      final idx = entry.key + 1;
                      final itemText = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Color(0xFF5D7B38),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                size: 10,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$idx. ',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.cocoaBeanRoast,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                itemText,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.cocoaBeanRoast,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // 3. Verifikasi Status Card
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'VERIFIKASI KELENGKAPAN TEKNIS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.grey700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        ref
                            .read(
                              pengajuanVerifikasiControllerProvider.notifier,
                            )
                            .verifikasiDokumen(
                              pengajuan.id,
                              'site_plan_dwg',
                              true,
                            );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isVerified == true
                              ? const Color(0xFFE2EED7)
                              : const Color(0xFFF0EFEA),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isVerified == true
                                ? const Color(0xFF5D7B38)
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isVerified == true
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              size: 16,
                              color: isVerified == true
                                  ? const Color(0xFF5D7B38)
                                  : AppColors.grey600,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Sesuai',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isVerified == true
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isVerified == true
                                    ? const Color(0xFF5D7B38)
                                    : AppColors.cocoaBeanRoast,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        ref
                            .read(
                              pengajuanVerifikasiControllerProvider.notifier,
                            )
                            .verifikasiDokumen(
                              pengajuan.id,
                              'site_plan_dwg',
                              false,
                            );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isVerified == false
                              ? const Color(0xFFF9EAE8)
                              : const Color(0xFFF0EFEA),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isVerified == false
                                ? AppColors.chilliDust
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isVerified == false
                                  ? Icons.cancel
                                  : Icons.radio_button_unchecked,
                              size: 16,
                              color: isVerified == false
                                  ? AppColors.chilliDust
                                  : AppColors.grey600,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Tidak Sesuai / Perlu Perbaikan',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isVerified == false
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isVerified == false
                                    ? AppColors.chilliDust
                                    : AppColors.cocoaBeanRoast,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSegmentTab(int index, String label) {
    final isSelected = _selectedTabIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? const [BoxShadow(color: Colors.black12, blurRadius: 4)]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppColors.chilliDust : AppColors.grey700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotFoundState(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5EE),
      appBar: AppBar(
        title: const Text('Detail Pengajuan'),
        backgroundColor: AppColors.chilliDust,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.search_off, size: 56, color: AppColors.grey600),
              const SizedBox(height: 12),
              const Text(
                'Pengajuan tidak ditemukan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.cocoaBeanRoast,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'ID ${widget.id} tidak tersedia pada data lokal ini.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.grey600),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/admin');
                  }
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Kembali ke daftar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
