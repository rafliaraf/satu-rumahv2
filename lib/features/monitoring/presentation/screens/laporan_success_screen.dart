import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/monitoring_model.dart';
import '../../data/models/status_hasil_evaluasi.dart';
import '../../utils/ba_pdf_generator.dart';

class LaporanSuccessScreen extends StatelessWidget {
  final MonitoringModel monitoring;

  const LaporanSuccessScreen({super.key, required this.monitoring});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              Container(
                width: 84,
                height: 84,
                decoration: const BoxDecoration(
                  color: AppColors.pistachioCream,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 48, color: Colors.white),
              ),
              const SizedBox(height: 24),
              const Text(
                'Laporan Berhasil Disubmit!',
                style: AppTextStyles.h2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Hasil monitoring perumahan ${monitoring.namaPerumahan} telah tersimpan di sistem.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.grey600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),

              // Export Actions (2 main buttons)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.chilliDust,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                    Icons.picture_as_pdf,
                    color: Colors.white,
                    size: 20,
                  ),
                  label: const Text(
                    'Download / Cetak PDF',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: AppColors.cocoaBeanRoast,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final teks =
                        'BERITA ACARA MONITORING LAPANGAN\n'
                        'Perumahan: ${monitoring.namaPerumahan}\n'
                        'Nomor BA: ${monitoring.nomorSuratBA}\n'
                        'Status: ${monitoring.statusHasilEvaluasi.label}';
                    try {
                      await SharePlus.instance.share(ShareParams(text: teks));
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
                    Icons.share,
                    color: AppColors.cocoaBeanRoast,
                    size: 20,
                  ),
                  label: const Text(
                    'Bagikan via WhatsApp',
                    style: TextStyle(
                      color: AppColors.cocoaBeanRoast,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Primary Nav: Lihat Riwayat Monitoring
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cocoaBeanRoast,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    context.go('/monitoring/lapangan/riwayat');
                  },
                  icon: const Icon(Icons.list_alt, color: Colors.white),
                  label: const Text(
                    'Lihat Riwayat Monitoring',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Secondary Nav: Kembali ke Beranda
              SizedBox(
                width: double.infinity,
                height: 48,
                child: TextButton.icon(
                  onPressed: () {
                    context.go('/monitoring/lapangan');
                  },
                  icon: const Icon(Icons.home, color: AppColors.cocoaBeanRoast),
                  label: const Text(
                    'Kembali ke Beranda',
                    style: TextStyle(
                      color: AppColors.cocoaBeanRoast,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
