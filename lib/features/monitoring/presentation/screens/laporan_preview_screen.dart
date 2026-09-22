import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../data/models/monitoring_model.dart';
import '../../data/models/status_hasil_evaluasi.dart';
import '../providers/monitoring_form_provider.dart';
import '../../utils/ba_pdf_generator.dart';

class LaporanPreviewScreen extends ConsumerStatefulWidget {
  final MonitoringModel monitoring;
  final bool isDraft;

  const LaporanPreviewScreen({
    super.key,
    required this.monitoring,
    this.isDraft = false,
  });

  @override
  ConsumerState<LaporanPreviewScreen> createState() =>
      _LaporanPreviewScreenState();
}

class _LaporanPreviewScreenState extends ConsumerState<LaporanPreviewScreen> {
  String _formatFullIndonesianDate(DateTime dt) {
    const hariList = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    const bulanList = [
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
    final hari = hariList[dt.weekday - 1];
    final bulan = bulanList[dt.month - 1];
    return 'hari $hari tanggal ${dt.day} bulan $bulan tahun ${dt.year}';
  }

  String _sanitizePerumahan(String name) {
    if (name.toLowerCase().startsWith('perumahan ')) {
      return name;
    }
    return 'Perumahan $name';
  }

  @override
  Widget build(BuildContext context) {
    final monitoring = widget.monitoring;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/monitoring/lapangan');
            }
          },
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.cocoaBeanRoast,
          ),
        ),
        title: const Text(
          'Preview Berita Acara',
          style: TextStyle(
            color: AppColors.cocoaBeanRoast,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: _buildBeritaAcaraDocument(monitoring),
            ),
          ),
          _buildBottomActions(context, monitoring),
        ],
      ),
    );
  }

  Widget _buildBeritaAcaraDocument(MonitoringModel item) {
    final fullDateSentence = _formatFullIndonesianDate(item.tanggalMonitoring);
    final perumahanFormatted = _sanitizePerumahan(
      item.namaPerumahan.isNotEmpty ? item.namaPerumahan : 'Perumahan Contoh',
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Kop Surat Disperwaskim
          const Text(
            'PEMERINTAH KOTA TASIKMALAYA',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          const Text(
            'DINAS PERUMAHAN DAN KAWASAN PERMUKIMAN',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Judul Dokumen & Nomor BA
          const Text(
            'BERITA ACARA MONITORING\nDAN EVALUASI LAPANGAN',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.cocoaBeanRoast,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Nomor: ${item.nomorSuratBA}',
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.grey700,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          const Divider(thickness: 1.5, color: AppColors.cocoaBeanRoast),
          const SizedBox(height: 16),

          // Paragraf Pembuka
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Pada hari ini, $fullDateSentence, telah dilakukan monitoring pada $perumahanFormatted.',
              style: const TextStyle(fontSize: 11, height: 1.5),
            ),
          ),
          const SizedBox(height: 14),

          // Poin I: Temuan di Lapangan
          _buildSectionTitle('I. Temuan di Lapangan'),
          _buildBulletList(item.temuanLapangan),
          const SizedBox(height: 12),

          // Poin II: Kesimpulan
          _buildSectionTitle('II. Kesimpulan'),
          _buildBulletList(item.kesimpulan),
          const SizedBox(height: 12),

          // Poin III: Kesepakatan
          _buildSectionTitle('III. Kesepakatan'),
          _buildBulletList(item.kesepakatan),
          const SizedBox(height: 12),

          // Poin IV: Rencana Tindak Lanjut
          _buildSectionTitle('IV. Rencana Tindak Lanjut'),
          _buildBulletList(item.rencanaTindakLanjut),
          const SizedBox(height: 16),

          // Grid Foto Evidence
          if (item.photoPaths.isNotEmpty) ...[
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
              ),
              itemCount: item.photoPaths.length,
              itemBuilder: (context, index) {
                final path = item.photoPaths[index];
                final isUrl = path.startsWith('http');
                return ClipRRect(
                  borderRadius: AppRadii.small,
                  child: isUrl
                      ? Image.network(
                          path,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => Container(
                            color: AppColors.grey200,
                            child: const Icon(
                              Icons.image,
                              color: AppColors.textMuted,
                            ),
                          ),
                        )
                      : Image.asset(
                          path,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => Container(
                            color: AppColors.grey200,
                            child: const Icon(
                              Icons.image,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],

          const Divider(thickness: 1, color: AppColors.grey300),
          const SizedBox(height: 16),

          // Kolom Tanda Tangan Fisik (2 Kolom Sejajar)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Yang Melaksanakan\nObservasi',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 36),
                    Text(
                      item.pelaksanaNama.isNotEmpty
                          ? item.pelaksanaNama
                          : '( _________________ )',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (item.pelaksanaJabatan.isNotEmpty)
                      Text(
                        item.pelaksanaJabatan,
                        style: const TextStyle(
                          fontSize: 9,
                          color: AppColors.grey700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Yang Ditemui\ndi Lapangan',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 36),
                    Text(
                      item.ditemuiNama.isNotEmpty
                          ? item.ditemuiNama
                          : '( _________________ )',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (item.ditemuiJabatan.isNotEmpty)
                      Text(
                        item.ditemuiJabatan,
                        style: const TextStyle(
                          fontSize: 9,
                          color: AppColors.grey700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 11,
            color: AppColors.cocoaBeanRoast,
          ),
        ),
      ),
    );
  }

  Widget _buildBulletList(List<String> items) {
    final validItems = items.where((e) => e.trim().isNotEmpty).toList();
    if (validItems.isEmpty) {
      return const Align(
        alignment: Alignment.centerLeft,
        child: Text('• -', style: TextStyle(fontSize: 11)),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: validItems
          .map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 3.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '• ',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: Text(
                      e,
                      style: const TextStyle(fontSize: 11, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildBottomActions(BuildContext context, MonitoringModel monitoring) {
    final formState = ref.watch(monitoringFormProvider);
    if (widget.isDraft) {
      // Mode Draft (Before submit)
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(color: Colors.white),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.actionPrimary,
                    shape: const RoundedRectangleBorder(borderRadius: AppRadii.pill),
                  ),
                  onPressed: formState.isSubmitting
                      ? null
                      : () {
                          final result = ref
                              .read(monitoringFormProvider.notifier)
                              .submitFinal(monitoring);
                          if (!context.mounted) return;
                          if (result.isSuccess && result.model != null) {
                            context.go(
                              '/monitoring/success',
                              extra: result.model,
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  result.errorMessage ??
                                      'Laporan gagal dikirim.',
                                ),
                                backgroundColor: AppColors.actionPrimary,
                              ),
                            );
                          }
                        },
                  icon: formState.isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send, size: 18, color: Colors.white),
                  label: const Text(
                    'SUBMIT LAPORAN SEKARANG',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 42,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.grey400),
                    shape: const RoundedRectangleBorder(borderRadius: AppRadii.pill),
                  ),
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/monitoring/tambah');
                    }
                  },
                  icon: const Icon(
                    Icons.edit,
                    color: AppColors.cocoaBeanRoast,
                    size: 16,
                  ),
                  label: const Text(
                    'Kembali & Edit Form',
                    style: TextStyle(
                      color: AppColors.cocoaBeanRoast,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // Mode Final / Preview (Mockup 2 buttons layout)
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(color: Colors.white),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Button 1: Download / print the locally generated PDF.
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.actionPrimary,
                    shape: const RoundedRectangleBorder(borderRadius: AppRadii.pill),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    try {
                      await BaPdfGenerator.printAndShare(monitoring);
                    } catch (_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Gagal menyiapkan PDF. Coba lagi.'),
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(
                    Icons.file_download,
                    size: 18,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Download / Cetak PDF',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Button 2 & 3: Side by Side (Bagikan via WA | Kirim via Email)
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: AppColors.statusSuccess,
                            width: 1.2,
                          ),
                          shape: const RoundedRectangleBorder(
                            borderRadius: AppRadii.pill,
                          ),
                        ),
                        onPressed: () async {
                          final teks =
                              'BERITA ACARA MONITORING LAPANGAN\n'
                              'Perumahan: ${monitoring.namaPerumahan}\n'
                              'Nomor BA: ${monitoring.nomorSuratBA}\n'
                              'Status: ${monitoring.statusHasilEvaluasi.label}';
                          try {
                            await SharePlus.instance.share(
                              ShareParams(text: teks),
                            );
                          } catch (_) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Gagal membuka menu berbagi.'),
                                ),
                              );
                            }
                          }
                        },
                        icon: const Icon(
                          Icons.near_me,
                          color: AppColors.statusSuccess,
                          size: 16,
                        ),
                        label: const Text(
                          'Bagikan via WhatsApp',
                          style: TextStyle(
                            color: AppColors.statusSuccess,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: AppColors.grey400,
                            width: 1.2,
                          ),
                          shape: const RoundedRectangleBorder(
                            borderRadius: AppRadii.pill,
                          ),
                        ),
                        onPressed: null,
                        icon: const Icon(
                          Icons.email_outlined,
                          color: AppColors.cocoaBeanRoast,
                          size: 16,
                        ),
                        label: const Text(
                          'Email: Belum tersedia',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Button 4: Simpan ke Arsip Sistem (Red Outlined Pill)
              SizedBox(
                width: double.infinity,
                height: 42,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: AppColors.actionPrimary,
                      width: 1.2,
                    ),
                    shape: const RoundedRectangleBorder(borderRadius: AppRadii.pill),
                  ),
                  onPressed: null,
                  icon: const Icon(
                    Icons.archive_outlined,
                    color: AppColors.textMuted,
                    size: 16,
                  ),
                  label: const Text(
                    'Arsip Sistem: Belum tersedia',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
