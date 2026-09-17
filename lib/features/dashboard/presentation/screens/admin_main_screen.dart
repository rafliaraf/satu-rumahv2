import 'package:flutter/material.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../../monitoring/presentation/screens/monitoring_list_screen.dart';
import '../../../notifikasi/presentation/screens/notifikasi_list_screen.dart';
import '../../../pengajuan/presentation/screens/pengajuan_admin_list_screen.dart';
import '../../../profil/presentation/screens/profil_admin_screen.dart';
import 'tab_beranda_admin.dart';

class AdminMainScreen extends StatefulWidget {
  final int initialIndex;

  const AdminMainScreen({super.key, this.initialIndex = 0});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const TabBerandaAdmin(),
      const PengajuanAdminListScreen(),
      const MonitoringListScreen(showBottomNav: false),
      const NotifikasiListScreen(),
      const ProfilAdminScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          AppBottomNavigationItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: 'Beranda',
          ),
          AppBottomNavigationItem(
            icon: Icons.description_outlined,
            activeIcon: Icons.description,
            label: 'Pengajuan',
          ),
          AppBottomNavigationItem(
            icon: Icons.assignment_turned_in_outlined,
            activeIcon: Icons.assignment_turned_in,
            label: 'Monitoring',
          ),
          AppBottomNavigationItem(
            icon: Icons.notifications_none_outlined,
            activeIcon: Icons.notifications,
            label: 'Notifikasi',
          ),
          AppBottomNavigationItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
