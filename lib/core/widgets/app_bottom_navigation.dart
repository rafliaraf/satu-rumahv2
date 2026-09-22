import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/role_session.dart';
import '../theme/app_role_theme.dart';

class AppBottomNavigationItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final int badgeCount;

  const AppBottomNavigationItem({
    required this.icon,
    required this.label,
    this.activeIcon,
    this.badgeCount = 0,
  });
}

/// Shared navigation chrome. Destination lists remain role-specific.
class AppBottomNavigation extends ConsumerWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<AppBottomNavigationItem> items;

  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  Widget _icon(
    AppBottomNavigationItem item, {
    required bool active,
    required Color badgeColor,
  }) {
    final icon = Icon(
      active ? (item.activeIcon ?? item.icon) : item.icon,
      size: 24,
    );
    if (item.badgeCount <= 0) return icon;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        icon,
        Positioned(
          right: -9,
          top: -8,
          child: Container(
            constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
            ),
            child: Text(
              item.badgeCount > 9 ? '9+' : '${item.badgeCount}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRole = ref.watch(roleSessionProvider).role;
    final selectedColor = AppRoleTheme.getPrimaryColor(currentRole);

    return Container(
      decoration: const BoxDecoration(
        color: AppRoleTheme.navBackgroundColor,
        border: Border(
          top: BorderSide(
            color: Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: selectedColor,
          unselectedItemColor: AppRoleTheme.unselectedNavColor,
          backgroundColor: AppRoleTheme.navBackgroundColor,
          elevation: 0,
          iconSize: 24,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          items: [
            for (final item in items)
              BottomNavigationBarItem(
                icon: _icon(item, active: false, badgeColor: selectedColor),
                activeIcon: _icon(item, active: true, badgeColor: selectedColor),
                label: item.label,
              ),
          ],
        ),
      ),
    );
  }
}
