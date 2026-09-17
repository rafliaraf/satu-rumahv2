import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/auth/role_session.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/route_feedback.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeveloperMainScreen extends StatefulWidget {
  final int initialIndex;

  const DeveloperMainScreen({super.key, this.initialIndex = 0});

  @override
  State<DeveloperMainScreen> createState() => _DeveloperMainScreenState();
}

class _DeveloperMainScreenState extends State<DeveloperMainScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const _DeveloperHomeScreen(),
      const _DeveloperPlaceholderScreen(
        title: 'Pengajuan Site Plan',
        icon: Icons.description_outlined,
      ),
      const _DeveloperPlaceholderScreen(
        title: 'Status Monitoring Pengajuan',
        icon: Icons.analytics_outlined,
      ),
      const _DeveloperPlaceholderScreen(
        title: 'Notifikasi',
        icon: Icons.notifications_none_rounded,
      ),
      const _DeveloperProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: AppColors.chilliDust,
        unselectedItemColor: AppColors.grey600,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 8,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Pengajuan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            activeIcon: Icon(Icons.analytics),
            label: 'Monitoring',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            activeIcon: Icon(Icons.notifications),
            label: 'Notifikasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class _DeveloperHomeScreen extends StatelessWidget {
  const _DeveloperHomeScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SATU RUMAH - Pengembang'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Welcome
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.chilliDust, Color(0xFF8B1209)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Selamat Datang, Pengembang!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Layanan Pengajuan Site Plan & Rekomendasi PSU Perumahan Kota Tasikmalaya.',
                    style: TextStyle(
                      color: AppColors.champagneToast,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Layanan Utama Pengembang', style: AppTextStyles.h3),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildServiceCard(
                    context,
                    Icons.add_home_work_rounded,
                    'Pengajuan Site Plan',
                    'Buat permohonan baru',
                    AppColors.chilliDust,
                    () => context.push('/pengajuan/step1'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildServiceCard(
                    context,
                    Icons.download_rounded,
                    'Format Dokumen',
                    'Unduh template resmi',
                    AppColors.cocoaBeanRoast,
                    () => showUnavailableAction(context, 'Template dokumen'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Status Pengajuan Terakhir', style: AppTextStyles.h3),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.grey300),
              ),
              child: const ListTile(
                leading: Icon(Icons.history_edu, color: AppColors.chilliDust),
                title: Text(
                  'Perumahan Grand Residence Blok B',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                subtitle: Text('Status: Verifikasi Berkas Teknis (DPKP)'),
                trailing: Chip(
                  label: Text(
                    'Proses',
                    style: TextStyle(fontSize: 10, color: Colors.white),
                  ),
                  backgroundColor: AppColors.warning,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(
    BuildContext context,
    IconData icon,
    String title,
    String desc,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.grey300),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              desc,
              style: const TextStyle(fontSize: 11, color: AppColors.grey600),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeveloperProfileScreen extends StatelessWidget {
  const _DeveloperProfileScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Pengembang'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          const ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.chilliDust,
              child: Icon(Icons.business, color: Colors.white),
            ),
            title: Text(
              'PT Contoh Property Sejahtera',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Developer Terverifikasi DPKP'),
          ),
          const Divider(),
          _buildItem(context, 'Profil Perusahaan', Icons.domain_outlined),
          _buildItem(
            context,
            'Berkas Persyaratan (KTP/NIB/NPWP)',
            Icons.folder_shared_outlined,
          ),
          _buildItem(context, 'Riwayat Pengajuan', Icons.history),
          _buildItem(context, 'Bantuan & Syarat Ketentuan', Icons.help_outline),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.chilliDust),
            title: const Text(
              'Logout',
              style: TextStyle(
                color: AppColors.chilliDust,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              ProviderScope.containerOf(
                context,
                listen: false,
              ).read(roleSessionProvider.notifier).signOut();
              context.go('/login');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: AppColors.cocoaBeanRoast),
      title: Text(title, style: AppTextStyles.bodyMedium),
      trailing: const Icon(Icons.chevron_right, color: AppColors.grey600),
      onTap: () => showUnavailableAction(context, title),
    );
  }
}

class _DeveloperPlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;

  const _DeveloperPlaceholderScreen({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), automaticallyImplyLeading: false),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: AppColors.grey400),
            const SizedBox(height: 16),
            Text(
              'Halaman $title (Sisi Pengembang)',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.cocoaBeanRoast,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
