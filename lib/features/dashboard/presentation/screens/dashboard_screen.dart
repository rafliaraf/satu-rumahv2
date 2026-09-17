import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../providers/dashboard_provider.dart';
import '../../../notifikasi/presentation/providers/notifikasi_provider.dart';
import 'tab_beranda.dart';
import '../../../pengajuan/presentation/screens/pengajuan_saya_list_screen.dart';
import '../../../notifikasi/presentation/screens/notifikasi_list_screen.dart';
import '../../../profil/presentation/screens/profil_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(dashboardTabProvider);
    final unreadCount = ref.watch(unreadCountProvider);

    const tabs = [
      TabBeranda(),
      PengajuanSayaListScreen(),
      NotifikasiListScreen(),
      ProfilScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: currentIndex, children: tabs),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: currentIndex,
        onTap: (index) => ref.read(dashboardTabProvider.notifier).state = index,
        items: [
          const AppBottomNavigationItem(icon: Icons.home, label: 'Beranda'),
          const AppBottomNavigationItem(
            icon: Icons.list_alt,
            label: 'Pengajuan',
          ),
          AppBottomNavigationItem(
            icon: Icons.notifications_none,
            activeIcon: Icons.notifications,
            label: 'Notifikasi',
            badgeCount: unreadCount,
          ),
          const AppBottomNavigationItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
