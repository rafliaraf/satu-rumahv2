import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../monitoring/data/models/monitoring_model.dart';
import '../../../monitoring/presentation/providers/monitoring_form_provider.dart';
import '../../../monitoring/utils/ba_pdf_generator.dart';
import '../../data/models/hasil_survey_model.dart';
import '../../data/models/pengajuan_model.dart';
import '../providers/pengajuan_verifikasi_controller.dart';

class HasilSurveyTab extends ConsumerStatefulWidget {
  final Pengajuan pengajuan;
  final VoidCallback? onUploadBeritaAcara;

  const HasilSurveyTab({
    super.key,
    required this.pengajuan,
    this.onUploadBeritaAcara,
  });

  @override
  ConsumerState<HasilSurveyTab> createState() => _HasilSurveyTabState();
}

class _HasilSurveyTabState extends ConsumerState<HasilSurveyTab> {
  bool _showRiwayat = false;

  @override
  Widget build(BuildContext context) {
    final pengajuan = widget.pengajuan;
    final riwayat = pengajuan.riwayatSurvey;
    final tanggalSurvey = pengajuan.tanggalSurvey;

    // Tentukan survey terbaru (index 0) dan riwayat sebelumnya
    final HasilSurveyItem? surveyTerbaru = riwayat.isNotEmpty
        ? riwayat[0]
        : null;
    final List<HasilSurveyItem> riwayatSebelumnya = riwayat.length > 1
        ? riwayat.sublist(1)
        : [];

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        // ── Header label ──
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'HASIL SURVEY LAPANGAN',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.grey700,
                  letterSpacing: 0.5,
                ),
              ),
              if (surveyTerbaru != null)
                _buildStatusBadge(surveyTerbaru.sudahTerlaksana),
            ],
          ),
        ),

        // ── Jika belum ada survey sama sekali ──
        if (surveyTerbaru == null && tanggalSurvey == null)
          _buildEmptyState()
        // ── Jika ada jadwal tapi belum terlaksana ──
        else if (surveyTerbaru == null && tanggalSurvey != null)
          _buildJadwalCard(tanggalSurvey, pengajuan.catatanSurvey)
        // ── Survey sudah terlaksana ──
        else if (surveyTerbaru != null) ...[
          // Jadwal info card
          _buildJadwalCard(
            surveyTerbaru.tanggalSurvey,
            pengajuan.catatanSurvey,
            pelaksanaNama: surveyTerbaru.pelaksanaNama,
            lokasiPerumahan: surveyTerbaru.lokasiPerumahan,
          ),
          const SizedBox(height: 12),

          // Hasil evaluasi card
          _buildEvaluasiCard(surveyTerbaru),
          const SizedBox(height: 12),

          // Foto evidence card
          if (surveyTerbaru.photoPaths.isNotEmpty) ...[
            _buildFotoEvidenceCard(surveyTerbaru),
            const SizedBox(height: 12),
          ],

          // Berita Acara row
          _buildBeritaAcaraRow(pengajuan, surveyTerbaru),
          const SizedBox(height: 16),

          // Riwayat survey sebelumnya
          if (riwayatSebelumnya.isNotEmpty)
            _buildRiwayatCard(riwayatSebelumnya),
        ],
      ],
    );
  }

  // ─── Empty State ───────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.only(top: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFF0EFEA),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_searching,
              color: AppColors.grey600,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum Ada Survey',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.cocoaBeanRoast,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Survey lapangan belum dijadwalkan.\nGunakan tombol "Jadwalkan Survey" di bawah.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.grey600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Jadwal Card ───────────────────────────────────────────────────────────

  String _formatDate(DateTime date, String pattern) {
    try {
      return DateFormat(pattern, 'id').format(date);
    } catch (_) {
      try {
        return DateFormat(pattern).format(date);
      } catch (_) {
        return '${date.day}/${date.month}/${date.year}';
      }
    }
  }

  Widget _buildJadwalCard(
    DateTime tanggal,
    String? catatan, {
    String? pelaksanaNama,
    String? lokasiPerumahan,
  }) {
    final dateStr = _formatDate(tanggal, "EEEE, d MMMM yyyy '·' HH.mm 'WIB'");

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'JADWAL SURVEY',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.grey600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFF9EAE8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.calendar_month,
                  color: AppColors.chilliDust,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  dateStr,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.cocoaBeanRoast,
                  ),
                ),
              ),
            ],
          ),
          if (pelaksanaNama != null || lokasiPerumahan != null) ...[
            const SizedBox(height: 10),
            const Divider(height: 1, color: AppColors.grey200),
            const SizedBox(height: 10),
            Row(
              children: [
                if (pelaksanaNama != null) ...[
                  const Icon(
                    Icons.person_outline,
                    size: 13,
                    color: AppColors.grey600,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      pelaksanaNama,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.grey700,
                      ),
                    ),
                  ),
                ],
                if (lokasiPerumahan != null) ...[
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.location_on_outlined,
                    size: 13,
                    color: AppColors.grey600,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      lokasiPerumahan,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.grey700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
          if (catatan != null && catatan.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F8F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 13,
                    color: AppColors.grey600,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      catatan,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.grey700,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Hasil Evaluasi Card ───────────────────────────────────────────────────

  Widget _buildEvaluasiCard(HasilSurveyItem survey) {
    final (evalColor, evalBg, evalIcon) = _evalStyle(
      survey.statusHasilEvaluasi,
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'HASIL EVALUASI',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.grey600,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: evalBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(evalIcon, size: 12, color: evalColor),
                    const SizedBox(width: 4),
                    Text(
                      survey.statusLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: evalColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _evalTitle(survey.statusHasilEvaluasi),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.cocoaBeanRoast,
            ),
          ),

          // Temuan lapangan
          if (survey.temuanLapangan.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Text(
              'CATATAN TEMUAN',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.grey600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            ...survey.temuanLapangan.map(
              (t) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 5),
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: AppColors.chilliDust,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        t,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.grey700,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Kesimpulan
          if (survey.kesimpulan.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Divider(height: 1, color: AppColors.grey200),
            const SizedBox(height: 10),
            const Text(
              'KESIMPULAN',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.grey600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            ...survey.kesimpulan.map(
              (k) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  k,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.grey700,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],

          // Rencana tindak lanjut
          if (survey.rencanaTindakLanjut.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Divider(height: 1, color: AppColors.grey200),
            const SizedBox(height: 10),
            const Text(
              'RENCANA TINDAK LANJUT',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.grey600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            ...survey.rencanaTindakLanjut.map(
              (r) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.arrow_right,
                      size: 16,
                      color: AppColors.chilliDust,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        r,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.grey700,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Foto Evidence Card ────────────────────────────────────────────────────

  Widget _buildFotoEvidenceCard(HasilSurveyItem survey) {
    final photos = survey.photoPaths.take(3).toList();
    final photoLabels = [
      'Tampak depan',
      'Fasad bangunan',
      'Lingkungan sekitar',
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FOTO EVIDENCE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.grey600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Dokumentasi lokasi',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.cocoaBeanRoast,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(
                    Icons.photo_library_outlined,
                    size: 14,
                    color: AppColors.grey600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${photos.length} foto',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.grey600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(photos.length, (i) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: i < photos.length - 1 ? 6 : 0,
                  ),
                  child: _buildPhotoItem(photos[i], photoLabels[i]),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoItem(String url, String label) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        children: [
          Image.network(
            url,
            height: 95,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (ctx, _, __) => Container(
              height: 95,
              color: AppColors.grey200,
              child: const Icon(Icons.broken_image, color: AppColors.grey400),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.6),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 9,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Berita Acara Row ──────────────────────────────────────────────────────

  MonitoringModel? _getLinkedMonitoringModel(Pengajuan pengajuan) {
    final repo = ref.read(monitoringRepositoryProvider);
    final allMon = repo.getAllMonitoring();
    for (final monitoring in allMon) {
      if (monitoring.pengajuanId == pengajuan.id && !monitoring.isDraft) {
        return monitoring;
      }
    }
    return null;
  }

  Widget _buildBeritaAcaraRow(Pengajuan pengajuan, HasilSurveyItem survey) {
    final hasBa = ref
        .read(pengajuanVerifikasiControllerProvider.notifier)
        .surveyBaGuard(pengajuan.id)
        .allowed;
    final linkedMonitoring = _getLinkedMonitoringModel(pengajuan);
    final canExport = hasBa && linkedMonitoring != null;

    return InkWell(
      onTap: hasBa
          ? () async {
              if (linkedMonitoring == null) {
                _showSurveyActionMessage(
                  'Data monitoring terhubung belum tersedia untuk ekspor BA.',
                );
                return;
              }
              try {
                await BaPdfGenerator.printAndShare(linkedMonitoring);
              } catch (error) {
                _showSurveyActionMessage('Ekspor BA gagal: $error');
              }
            }
          : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: hasBa ? const Color(0xFFF9EAE8) : const Color(0xFFF0EFEA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasBa
                ? AppColors.chilliDust.withValues(alpha: 0.4)
                : AppColors.grey300,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              canExport ? Icons.picture_as_pdf : Icons.picture_as_pdf_outlined,
              size: 16,
              color: canExport ? AppColors.chilliDust : AppColors.grey500,
            ),
            const SizedBox(width: 8),
            Text(
              canExport
                  ? 'Lihat Berita Acara (PDF)'
                  : hasBa
                  ? 'BA tersedia, ekspor belum terhubung'
                  : 'Berita Acara belum diupload',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: canExport ? AppColors.chilliDust : AppColors.grey500,
              ),
            ),
            if (canExport) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.download_outlined,
                size: 14,
                color: AppColors.chilliDust,
              ),
            ],
            if (survey.nomorSuratBA != null &&
                survey.nomorSuratBA!.isNotEmpty) ...[
              const Spacer(),
              Text(
                survey.nomorSuratBA!,
                style: const TextStyle(fontSize: 10, color: AppColors.grey600),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showSurveyActionMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // ─── Riwayat Card ─────────────────────────────────────────────────────────

  Widget _buildRiwayatCard(List<HasilSurveyItem> riwayat) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _showRiwayat = !_showRiwayat),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.history, size: 18, color: AppColors.grey700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'RIWAYAT SURVEY',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.grey600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          '${riwayat.length} survey sebelumnya · ${_formatDate(riwayat.last.tanggalSurvey, 'd MMMM yyyy')}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.grey700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _showRiwayat ? Icons.expand_less : Icons.chevron_right,
                    color: AppColors.grey600,
                  ),
                ],
              ),
            ),
          ),
          if (_showRiwayat) ...[
            const Divider(height: 1, color: AppColors.grey200),
            ...riwayat.map((item) => _buildRiwayatItem(item)),
          ],
        ],
      ),
    );
  }

  Widget _buildRiwayatItem(HasilSurveyItem item) {
    final (evalColor, evalBg, _) = _evalStyle(item.statusHasilEvaluasi);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: evalBg, shape: BoxShape.circle),
            child: Icon(Icons.location_on_outlined, size: 18, color: evalColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(item.tanggalSurvey, "d MMMM yyyy · HH.mm 'WIB'"),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.cocoaBeanRoast,
                  ),
                ),
                Text(
                  item.pelaksanaNama,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.grey600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: evalBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              item.statusLabel,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: evalColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Status Badge ──────────────────────────────────────────────────────────

  Widget _buildStatusBadge(bool terlaksana) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: terlaksana ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            terlaksana ? Icons.check_circle_outline : Icons.schedule,
            size: 12,
            color: terlaksana
                ? const Color(0xFF2E7D32)
                : const Color(0xFFE65100),
          ),
          const SizedBox(width: 4),
          Text(
            terlaksana ? 'TERLAKSANA' : 'DIJADWALKAN',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: terlaksana
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFFE65100),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Helper: Eval Style ────────────────────────────────────────────────────

  (Color color, Color bg, IconData icon) _evalStyle(String status) {
    switch (status) {
      case 'sesuai':
        return (
          const Color(0xFF2E7D32),
          const Color(0xFFE8F5E9),
          Icons.check_circle_outline,
        );
      case 'tidak_sesuai':
        return (
          AppColors.chilliDust,
          const Color(0xFFF9EAE8),
          Icons.cancel_outlined,
        );
      case 'perlu_perbaikan':
        return (
          const Color(0xFFE65100),
          const Color(0xFFFFF3E0),
          Icons.warning_amber_outlined,
        );
      default:
        return (AppColors.grey600, const Color(0xFFF0EFEA), Icons.help_outline);
    }
  }

  String _evalTitle(String status) {
    switch (status) {
      case 'sesuai':
        return 'Kesesuaian pembangunan';
      case 'tidak_sesuai':
        return 'Ketidaksesuaian ditemukan';
      case 'perlu_perbaikan':
        return 'Diperlukan perbaikan';
      default:
        return 'Hasil evaluasi';
    }
  }
}
