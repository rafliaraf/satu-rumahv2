import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

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
class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<AppBottomNavigationItem> items;

  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  Widget _icon(AppBottomNavigationItem item, {required bool active}) {
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
            decoration: const BoxDecoration(
              color: AppColors.notificationUnread,
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
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.actionPrimary,
        unselectedItemColor: AppColors.textMuted,
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconSize: 24,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: [
          for (final item in items)
            BottomNavigationBarItem(
              icon: _icon(item, active: false),
              activeIcon: _icon(item, active: true),
              label: item.label,
            ),
        ],
      ),
    );
  }
}
