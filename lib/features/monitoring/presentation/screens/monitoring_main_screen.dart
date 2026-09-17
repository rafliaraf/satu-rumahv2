import 'package:flutter/material.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../widgets/tab_beranda_monitoring.dart';
import '../widgets/tab_profil_monitoring.dart';
import 'monitoring_list_screen.dart';

class MonitoringMainScreen extends StatefulWidget {
  final int initialIndex;

  const MonitoringMainScreen({super.key, this.initialIndex = 0});

  @override
  State<MonitoringMainScreen> createState() => _MonitoringMainScreenState();
}

class _MonitoringMainScreenState extends State<MonitoringMainScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const TabBerandaMonitoring(),
      const MonitoringListScreen(showBottomNav: false),
      const TabProfilMonitoring(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          AppBottomNavigationItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: 'Beranda',
          ),
          AppBottomNavigationItem(
            icon: Icons.assignment_turned_in_outlined,
            activeIcon: Icons.assignment_turned_in,
            label: 'Riwayat',
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
