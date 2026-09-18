import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/doc_upload_tile.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../core/utils/file_picker_util.dart';
import '../../../monitoring/data/models/monitoring_model.dart';
import '../../../monitoring/presentation/providers/monitoring_form_provider.dart';
import '../../../monitoring/utils/ba_pdf_generator.dart';
import '../../data/models/hasil_survey_model.dart';
import '../../data/models/pengajuan_model.dart';
import '../../data/models/status_tahap_pengajuan.dart';
import '../providers/pengajuan_form_controller.dart';
import '../providers/pengajuan_verifikasi_controller.dart';

/// Returns a real linked final monitoring record with an available BA path.
/// A developer detail must never synthesize a report for export.
MonitoringModel? findLinkedFinalMonitoring(
  Iterable<MonitoringModel> reports,
  String pengajuanId, {
  String? beritaAcaraPath,
}) {
  final normalizedId = pengajuanId.trim();
  if (normalizedId.isEmpty || beritaAcaraPath?.trim().isNotEmpty != true)
    return null;

  for (final report in reports) {
    if (!report.isDraft && report.pengajuanId?.trim() == normalizedId) {
      return report;
    }
  }
  return null;
}

class PengajuanDetailScreen extends ConsumerStatefulWidget {
  final String id;

  const PengajuanDetailScreen({super.key, required this.id});

  @override
  ConsumerState<PengajuanDetailScreen> createState() =>
      _PengajuanDetailScreenState();
}

class _PengajuanDetailScreenState extends ConsumerState<PengajuanDetailScreen> {
  Map<String, String> localDocs = {};
  Set<String> clearedDocs = {};
  bool _isSubmittingRevision = false;

  @override
  Widget build(BuildContext context) {
    final list = ref.watch(pengajuanListProvider);
    Pengajuan? match;
    for (final candidate in list) {
      if (candidate.id == widget.id) {
        match = candidate;
        break;
      }
    }
    if (match == null) return _buildNotFound(context);
    final item = match;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(item.id)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            item.namaPerumahan,
                            style: AppTextStyles.headlineMedium,
                          ),
                        ),
                        StatusBadge(status: item.status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.namaPt,
                      style: AppTextStyles.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 12),
                    _buildDetailRow('Luas Lahan', '${item.luasLahan} m²'),
                    _buildDetailRow('Jumlah Unit', '${item.jumlahUnit} Unit'),
                    _buildDetailRow('Tipe Perumahan', item.tipePerumahan),
                    _buildDetailRow('Tanggal Pengajuan', item.tanggal),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Perlu Perbaikan Section
            if (item.status == 'Perlu Perbaikan') ...[
              Builder(
                builder: (context) {
                  final Map<String, String> docLabels = {
                    'legalitas': 'Akta Pendirian Perusahaan & Pengesahan',
                    'nib': 'Nomor Induk Berusaha (NIB / OSS)',
                    'npwp_doc': 'NPWP Perusahaan Wajib Pajak',
                    'ktp': 'KTP Direktur / Penanggung Jawab',
                    'asosiasi': 'Bukti Keanggotaan Asosiasi Pengembang',
                    'surat_permohonan': 'Surat Permohonan Pengesahan Site Plan',
                    'info_intensitas_ruang':
                        'Informasi Intensitas Ruang (KRK/ITR)',
                    'bukti_kepemilikan_lahan':
                        'Bukti Kepemilikan & Penguasaan Lahan',
                    'bukti_tpu':
                        'Bukti Penyediaan Lahan Tempat Pemakaman (TPU)',
                    'kkpr_doc': 'Kesesuaian Kegiatan Pemanfaatan Ruang (KKPR)',
                    'pbg_induk': 'Persetujuan Bangunan Gedung (PBG Induk)',
                    'rekomendasi_lingkungan':
                        'Rekomendasi Dokumen Lingkungan (SPPL/UKL-UPL)',
                    'pelepasan_lahan': 'Surat Pelepasan Lahan Kas Desa',
                    'pernyataan_pelepasan':
                        'Surat Pernyataan Pelepasan Hak Lahan',
                    'pernyataan_keabsahan':
                        'Surat Pernyataan Keabsahan Dokumen',
                    'pernyataan_psu': 'Surat Pernyataan Penyerahan PSU',
                    'site_plan_dwg':
                        'Master Layout Site Plan (File CAD DWG / PDF)',
                    'tata_ruang': 'Dokumen Tata Ruang / KKPR',
                  };

                  final revKeys = List<String>.from(item.dokumenPerluRevisi);
                  final hasRevisionOrigin = item.tahapAsalPerbaikan != null;
                  final hasRevisionNote =
                      item.catatanPerbaikan?.trim().isNotEmpty == true;
                  final canSubmitRevision =
                      revKeys.isNotEmpty &&
                      hasRevisionOrigin &&
                      hasRevisionNote;

                  return Card(
                    color: AppColors.warning.withValues(alpha: 0.08),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.warning,
                                color: AppColors.warning,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Catatan Perbaikan Verifikator',
                                style: AppTextStyles.titleMedium.copyWith(
                                  color: AppColors.warning,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.catatanPerbaikan ??
                                'Harap unggah ulang dokumen yang tidak valid.',
                            style: AppTextStyles.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 12),
                          Text(
                            'Upload Ulang Dokumen Terkait (${revKeys.length} Dokumen):',
                            style: AppTextStyles.titleSmall.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (!canSubmitRevision) ...[
                            const SizedBox(height: 8),
                            Text(
                              revKeys.isEmpty
                                  ? 'Belum ada dokumen bernama yang diminta untuk direvisi.'
                                  : !hasRevisionOrigin
                                  ? 'Tahap asal perbaikan belum tersedia. Hubungi Admin sebelum mengirim revisi.'
                                  : 'Catatan perbaikan belum tersedia. Hubungi Admin sebelum mengirim revisi.',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),

                          // Render DocUploadTile for each document requiring revision
                          ...revKeys.map((key) {
                            final label = docLabels[key] ?? key;
                            final currentVal = clearedDocs.contains(key)
                                ? localDocs[key]
                                : (localDocs[key] ?? item.uploadedDocs[key]);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: DocUploadTile(
                                title: label,
                                subtitle:
                                    'Pilih file revisi baru dari aplikasi Files HP (PDF / Gambar / DWG)',
                                fileName: currentVal,
                                onUpload: () async {
                                  final file =
                                      await FilePickerUtil.pickSingleFile(
                                        allowedExtensions:
                                            key == 'site_plan_dwg'
                                            ? ['dwg', 'pdf', 'zip']
                                            : ['pdf', 'jpg', 'jpeg', 'png'],
                                      );
                                  if (!context.mounted) return;
                                  if (file != null) {
                                    setState(() {
                                      localDocs[key] = file.path ?? file.name;
                                      clearedDocs.remove(key);
                                    });
                                  } else if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Tidak ada berkas dipilih. Revisi belum berubah.',
                                        ),
                                      ),
                                    );
                                  }
                                },
                                onDelete: () {
                                  setState(() {
                                    localDocs.remove(key);
                                    clearedDocs.add(key);
                                  });
                                },
                              ),
                            );
                          }),

                          const SizedBox(height: 12),
                          AppButton.primary(
                            text: 'Kirim Revisi Dokumen',
                            onPressed:
                                canSubmitRevision && !_isSubmittingRevision
                                ? () {
                                    final missing = revKeys
                                        .where(
                                          (key) =>
                                              localDocs[key]
                                                  ?.trim()
                                                  .isNotEmpty !=
                                              true,
                                        )
                                        .toList();
                                    if (missing.isNotEmpty) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Pilih berkas revisi untuk: ${missing.join(', ')}.',
                                          ),
                                        ),
                                      );
                                      return;
                                    }
                                    setState(
                                      () => _isSubmittingRevision = true,
                                    );
                                    final result = ref
                                        .read(
                                          pengajuanVerifikasiControllerProvider
                                              .notifier,
                                        )
                                        .kirimRevisi(item.id, localDocs);
                                    if (!result.stateChanged) {
                                      setState(
                                        () => _isSubmittingRevision = false,
                                      );
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(result.message)),
                                      );
                                      return;
                                    }

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(result.message)),
                                    );
                                    if (context.mounted) context.pop();
                                  }
                                : null,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],

            // Detail Informasi Survey Lapangan & Berita Acara (jika ada survey)
            if (item.tanggalSurvey != null ||
                item.riwayatSurvey.isNotEmpty ||
                item.statusTahap == StatusTahapPengajuan.surveyLapangan ||
                item.statusTahap == StatusTahapPengajuan.persetujuan ||
                item.statusTahap == StatusTahapPengajuan.selesai)
              _buildHasilSurveyCard(context, item),

            const SizedBox(height: 20),

            // Dynamic Timeline Progress
            const Text(
              'Timeline Pengajuan',
              style: AppTextStyles.headlineSmall,
            ),
            const SizedBox(height: 12),
            _buildDynamicTimelineCard(item),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFound(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Pengajuan Tidak Ditemukan')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.search_off, size: 64, color: AppColors.grey500),
              const SizedBox(height: 16),
              const Text(
                'Pengajuan tidak ditemukan',
                style: AppTextStyles.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Nomor ${widget.id} tidak ada di daftar pengajuan lokal.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.grey600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/dashboard');
                      }
                    },
                    child: const Text('Kembali'),
                  ),
                  ElevatedButton(
                    onPressed: () => context.go('/dashboard'),
                    child: const Text('Lihat Daftar Pengajuan'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicTimelineCard(Pengajuan item) {
    final status = item.statusTahap;

    // Helper logic per tahap
    final bool step1Passed =
        status != StatusTahapPengajuan.pengajuanBaru &&
        status != StatusTahapPengajuan.verifikasiAdministrasi;
    final bool step1Current =
        status == StatusTahapPengajuan.verifikasiAdministrasi ||
        status == StatusTahapPengajuan.pengajuanBaru;

    final bool step2Passed =
        status == StatusTahapPengajuan.persetujuan ||
        status == StatusTahapPengajuan.selesai;
    final bool step2Current =
        status == StatusTahapPengajuan.verifikasiTeknis ||
        status == StatusTahapPengajuan.surveyLapangan ||
        status == StatusTahapPengajuan.perluPerbaikan;

    final bool step3Passed =
        status == StatusTahapPengajuan.persetujuan ||
        status == StatusTahapPengajuan.selesai;
    final bool step3Current =
        status == StatusTahapPengajuan.surveyLapangan &&
        item.beritaAcaraPath != null;

    final bool step4Passed = status == StatusTahapPengajuan.selesai;
    final bool step4Current =
        status == StatusTahapPengajuan.persetujuan ||
        status == StatusTahapPengajuan.selesai;

    String step2Desc = 'Belum dijadwalkan';
    if (item.tanggalSurvey != null) {
      try {
        step2Desc =
            'Dijadwalkan: ${DateFormat("d MMM yyyy, HH:mm", "id").format(item.tanggalSurvey!)} WIB';
      } catch (_) {
        step2Desc =
            'Survey dijadwalkan (${item.tanggalSurvey!.day}/${item.tanggalSurvey!.month}/${item.tanggalSurvey!.year})';
      }
    } else if (status == StatusTahapPengajuan.verifikasiTeknis) {
      step2Desc = 'Penjadwalan survey oleh Tim Disperwaskim';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTimelineItem(
              'Verifikasi Administrasi',
              step1Passed
                  ? 'Dokumen terverifikasi sah'
                  : 'Pemeriksaan berkas kelengkapan',
              step1Passed,
              step1Current,
            ),
            _buildTimelineItem(
              'Verifikasi Teknis & Lapangan',
              step2Desc,
              step2Passed,
              step2Current,
            ),
            _buildTimelineItem(
              'Rekomendasi Tim Teknis & BA',
              item.beritaAcaraPath != null
                  ? 'Berita Acara diterbitkan (${item.beritaAcaraPath})'
                  : 'Menunggu pelaksanaan survey',
              step3Passed,
              step3Current,
            ),
            _buildTimelineItem(
              'Persetujuan Site Plan Terbit',
              status == StatusTahapPengajuan.selesai
                  ? 'Persetujuan disahkan (SK Terbit)'
                  : 'Tahap akhir penerbitan SK',
              step4Passed,
              step4Current,
            ),
          ],
        ),
      ),
    );
  }

  MonitoringModel? _getMonitoringModelForPengajuan(Pengajuan item) {
    final repo = ref.read(monitoringRepositoryProvider);
    return findLinkedFinalMonitoring(
      repo.getAllMonitoring(),
      item.id,
      beritaAcaraPath: item.beritaAcaraPath,
    );
  }

  Widget _buildHasilSurveyCard(BuildContext context, Pengajuan item) {
    final riwayat = item.riwayatSurvey;
    final HasilSurveyItem? surveyTerbaru = riwayat.isNotEmpty
        ? riwayat[0]
        : null;
    final finalMonitoring = _getMonitoringModelForPengajuan(item);
    final hasBa = finalMonitoring != null;
    final hasSk =
        item.skPersetujuanPath != null && item.skPersetujuanPath!.isNotEmpty;

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.chilliDust.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF9EAE8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified_outlined,
                    color: AppColors.chilliDust,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SURVEY LAPANGAN & BERITA ACARA',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.grey700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'Hasil Evaluasi Teknis Disperwaskim',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.cocoaBeanRoast,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Info Jadwal
            if (item.tanggalSurvey != null) ...[
              Row(
                children: [
                  const Icon(
                    Icons.event,
                    size: 14,
                    color: AppColors.chilliDust,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Jadwal Survey: ',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.grey700,
                    ),
                  ),
                  Text(
                    '${item.tanggalSurvey!.day}/${item.tanggalSurvey!.month}/${item.tanggalSurvey!.year} ${item.tanggalSurvey!.hour.toString().padLeft(2, '0')}:${item.tanggalSurvey!.minute.toString().padLeft(2, '0')} WIB',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.cocoaBeanRoast,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (item.catatanSurvey != null &&
                  item.catatanSurvey!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Catatan Tim: ${item.catatanSurvey}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.grey600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              const SizedBox(height: 12),
            ],

            // Rincian Hasil Survey terbaru dari Tim Perwaskim
            if (surveyTerbaru != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F8F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Pelaksana: ${surveyTerbaru.pelaksanaNama}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.cocoaBeanRoast,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: surveyTerbaru.statusHasilEvaluasi == 'sesuai'
                                ? const Color(0xFFE8F5E9)
                                : const Color(0xFFF9EAE8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            surveyTerbaru.statusLabel,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color:
                                  surveyTerbaru.statusHasilEvaluasi == 'sesuai'
                                  ? const Color(0xFF2E7D32)
                                  : AppColors.chilliDust,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (surveyTerbaru.temuanLapangan.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'CATATAN TEMUAN:',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.grey600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      ...surveyTerbaru.temuanLapangan.map(
                        (t) => Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            '• $t',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.grey700,
                            ),
                          ),
                        ),
                      ),
                    ],
                    if (surveyTerbaru.kesimpulan.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'KESIMPULAN:',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.grey600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      ...surveyTerbaru.kesimpulan.map(
                        (k) => Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            '• $k',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.grey700,
                            ),
                          ),
                        ),
                      ),
                    ],
                    if (surveyTerbaru.kesepakatan.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'KESEPAKATAN:',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.grey600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      ...surveyTerbaru.kesepakatan.map(
                        (ks) => Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            '• $ks',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.grey700,
                            ),
                          ),
                        ),
                      ),
                    ],
                    if (surveyTerbaru.rencanaTindakLanjut.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'RENCANA TINDAK LANJUT:',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.grey600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      ...surveyTerbaru.rencanaTindakLanjut.map(
                        (r) => Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            '• $r',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.grey700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Tombol Lihat / Download Berita Acara PDF (In-App Preview)
            SizedBox(
              width: double.infinity,
              height: 42,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: hasBa
                      ? AppColors.chilliDust
                      : AppColors.grey600,
                  side: BorderSide(
                    color: hasBa ? AppColors.chilliDust : AppColors.grey300,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: hasBa
                    ? () async {
                        final monitoringModel = _getMonitoringModelForPengajuan(
                          item,
                        );
                        if (monitoringModel == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Berita Acara belum tersedia untuk diekspor.',
                              ),
                            ),
                          );
                          return;
                        }
                        try {
                          await BaPdfGenerator.printAndShare(monitoringModel);
                        } catch (_) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Berita Acara tidak dapat diekspor saat ini.',
                                ),
                              ),
                            );
                          }
                        }
                      }
                    : null,
                icon: Icon(
                  hasBa ? Icons.picture_as_pdf : Icons.picture_as_pdf_outlined,
                  size: 16,
                ),
                label: Text(
                  hasBa
                      ? 'Lihat Berita Acara Survey (PDF)'
                      : 'Berita Acara Belum Diterbitkan',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),

            // Tombol Dokumen SK Persetujuan jika terbit
            if (hasSk) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Membuka SK Persetujuan Site Plan: ${item.skPersetujuanPath}',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.card_membership,
                    color: Colors.white,
                    size: 16,
                  ),
                  label: const Text(
                    'Unduh SK Persetujuan Site Plan (PDF)',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.grey600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    String title,
    String desc,
    bool isPassed,
    bool isCurrent,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: isPassed
                    ? AppColors.pistachioCream
                    : isCurrent
                    ? AppColors.chilliDust
                    : AppColors.grey300,
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 2,
              height: 40,
              color: isPassed ? AppColors.pistachioCream : AppColors.grey300,
            ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  color: isCurrent
                      ? AppColors.chilliDust
                      : AppColors.cocoaBeanRoast,
                ),
              ),
              Text(
                desc,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.grey600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
