import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_text_styles.dart';

class FilosofiSistemScreen extends StatefulWidget {
  const FilosofiSistemScreen({super.key});

  @override
  State<FilosofiSistemScreen> createState() => _FilosofiSistemScreenState();
}

class _FilosofiSistemScreenState extends State<FilosofiSistemScreen> {
  int _activeSlide = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_activeSlide < 2) {
      _pageController.animateToPage(
        _activeSlide + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevPage() {
    if (_activeSlide > 0) {
      _pageController.animateToPage(
        _activeSlide - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Filosofi & Nilai Sistem'),
        backgroundColor: AppColors.chilliDust,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Indicator Progress Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                _buildIndicator(0, 'Tentang'),
                const SizedBox(width: 8),
                _buildIndicator(1, '3 Filosofi'),
                const SizedBox(width: 8),
                _buildIndicator(2, 'Alur 3 Peran'),
              ],
            ),
          ),

          // Slide Pages
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _activeSlide = index),
              children: [
                _buildSlide1Tentang(),
                _buildSlide2Filosofi(),
                _buildSlide3AlurPeran(),
              ],
            ),
          ),

          // Bottom Navigation Buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_activeSlide > 0)
                  OutlinedButton.icon(
                    onPressed: _prevPage,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Sebelumnya'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.grey700,
                      side: const BorderSide(color: AppColors.grey300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 100),

                Text(
                  'Slide ${_activeSlide + 1} dari 3',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.grey600,
                  ),
                ),

                if (_activeSlide < 2)
                  ElevatedButton.icon(
                    onPressed: _nextPage,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Lanjut'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.chilliDust,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Selesai'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(int index, String title) {
    final isActive = _activeSlide >= index;
    final isCurrent = _activeSlide == index;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: isCurrent
                  ? AppColors.chilliDust
                  : (isActive ? AppColors.chilliDust.withValues(alpha: 0.4) : AppColors.grey200),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              color: isCurrent ? AppColors.chilliDust : AppColors.grey600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // SLIDE 1
  Widget _buildSlide1Tentang() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '🏛️ EKOSISTEM LAYANAN TERPADU',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.chilliDust,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'SATU RUMAH',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppColors.chilliDust,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Sistem Layanan Terpadu Perumahan & PSU Disperwaskim Kota Tasikmalaya',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.cocoaBeanRoast,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppRadii.card,
              border: Border.all(color: AppColors.grey200),
            ),
            child: const Text(
              'SATU RUMAH hadir untuk membangun ekosistem perizinan perumahan yang transparan, akuntabel, dan terintegrasi antara Pemerintah Kota Tasikmalaya dan para Pengembang Perumahan sebagai mitra pembangunan daerah.',
              style: TextStyle(fontSize: 14, color: AppColors.grey700, height: 1.5),
            ),
          ),
          const SizedBox(height: 20),
          _buildInfoRow(Icons.person, 'Project Manager', 'Pemaparan Filosofi & Ekosistem Sistem'),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.domain, 'Instansi', 'Dinas Perumahan dan Kawasan Permukiman (Disperwaskim)'),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.location_city, 'Wilayah', 'Pemerintah Kota Tasikmalaya (Tahun 2026)'),
        ],
      ),
    );
  }

  // SLIDE 2
  Widget _buildSlide2Filosofi() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '💡 LANDASAN FILOSOFIS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.chilliDust,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            '3 Pilar Filosofi Utama',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.cocoaBeanRoast,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Bukan sekadar digitalisasi kertas, melainkan fondasi integritas dan tata kelola:',
            style: TextStyle(fontSize: 13, color: AppColors.grey600),
          ),
          const SizedBox(height: 16),

          _buildFilosofiCard(
            number: '1',
            title: 'Kepastian Layanan (Transparansi Pengembang)',
            content:
                'Menghilangkan ketidakpastian birokrasi. Pengembang mengetahui secara pasti posisi berkas, jadwal survei fisik, dan hasil telaah teknis secara real-time langsung dari genggaman ponsel tanpa ruang gelap.',
          ),
          const SizedBox(height: 12),
          _buildFilosofiCard(
            number: '2',
            title: 'Pembuktian Fakta (Integritas Pengawasan Dinas)',
            content:
                'Memastikan apa yang dijanjikan di atas kertas site plan terbukti nyata sama persis di atas tanah. Tim diterjunkan mencocokkan fisik drainase, jalan, dan PSU secara digital lewat Berita Acara sah.',
          ),
          const SizedBox(height: 12),
          _buildFilosofiCard(
            number: '3',
            title: 'Tata Kelola Satu Pintu (Efisiensi Birokrasi)',
            content:
                'Seluruh arsip dokumen, riwayat pengesahan, dan koordinasi lapangan terpusat pada satu database portal dinas. Mencegah berkas terselip dan mempercepat rekomendasi SK tanpa pungli.',
          ),
        ],
      ),
    );
  }

  // SLIDE 3
  Widget _buildSlide3AlurPeran() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '🔄 INTEGRASI 3 PERAN',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.chilliDust,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Alur Kolaborasi Ekosistem',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.cocoaBeanRoast,
            ),
          ),
          const SizedBox(height: 16),

          _buildRoleCard(
            role: 'ROLE 1: EKSTERNAL',
            name: 'Pengembang (Developer)',
            platform: '📱 Aplikasi Mobile (HP)',
            color: const Color(0xFF1D4ED8),
            bgColor: const Color(0xFFEFF6FF),
            borderColor: const Color(0xFFBFDBFE),
            items: [
              'Mengajukan izin site plan dari genggaman',
              'Upload berkas legalitas & denah DWG/PDF',
              'Mendapat kepastian jadwal survei lokasi',
            ],
          ),
          const SizedBox(height: 12),
          _buildRoleCard(
            role: 'ROLE 2: LAPANGAN',
            name: 'Petugas Survei Disperwaskim',
            platform: '📱 Aplikasi Mobile (HP)',
            color: const Color(0xFFDC2626),
            bgColor: const Color(0xFFFEF2F2),
            borderColor: const Color(0xFFFECACA),
            items: [
              'Inspeksi fisik langsung di tanah proyek',
              'Ceklis kondisi jalan, saluran drainase, & PSU',
              'Upload foto temuan & buat Berita Acara digital',
            ],
          ),
          const SizedBox(height: 12),
          _buildRoleCard(
            role: 'ROLE 3: INTERNAL KANTOR',
            name: 'Verifikator Dinas Disperwaskim',
            platform: '💻 Web Portal Laptop/PC',
            color: const Color(0xFF15803D),
            bgColor: const Color(0xFFF0FDF4),
            borderColor: const Color(0xFFBBF7D0),
            items: [
              'Pemeriksaan berkas teknis resolusi tinggi',
              'Sinkronisasi otomatis Berita Acara dari lapangan',
              'Menerbitkan rekomendasi pengesahan perumahan',
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.chilliDust),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.grey700),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, color: AppColors.grey600),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildFilosofiCard({
    required String number,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.card,
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.chilliDust,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  number,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.cocoaBeanRoast,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.grey700,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard({
    required String role,
    required String name,
    required String platform,
    required Color color,
    required Color bgColor,
    required Color borderColor,
    required List<String> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadii.card,
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                role,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              Text(
                platform,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.grey700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.cocoaBeanRoast,
            ),
          ),
          const SizedBox(height: 8),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('✔ ', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(fontSize: 12, color: AppColors.grey800),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
