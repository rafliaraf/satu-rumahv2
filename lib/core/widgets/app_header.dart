import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/role_session.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../../features/dashboard/presentation/providers/dashboard_provider.dart';
import '../../features/notifikasi/presentation/providers/notifikasi_provider.dart';

import '../theme/app_role_theme.dart';

enum AppHeaderVariant { light, authority, roleBased }

class AppHeader extends ConsumerWidget implements PreferredSizeWidget {
  final AppHeaderVariant variant;
  final String title;
  final String? subtitle;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final bool showNotifications;
  final List<Widget> actions;

  const AppHeader({
    super.key,
    this.variant = AppHeaderVariant.roleBased,
    required this.title,
    this.subtitle,
    this.showBackButton = false,
    this.onBackPressed,
    this.showNotifications = true,
    this.actions = const [],
  });

  @override
  Size get preferredSize => const Size.fromHeight(70);

  void _goToNotifications(BuildContext context, WidgetRef ref) {
    switch (ref.read(roleSessionProvider).role) {
      case AppRole.admin:
        context.go('/admin/notifikasi');
      case AppRole.developer:
        ref.read(dashboardTabProvider.notifier).state = 2;
        context.go('/dashboard');
      case AppRole.perwaskim:
        context.go('/monitoring/lapangan/notifikasi');
      case AppRole.guest:
        context.go('/login');
    }
  }

  void _goBack(BuildContext context, WidgetRef ref) {
    if (onBackPressed != null) {
      onBackPressed!();
      return;
    }
    if (context.canPop()) {
      context.pop();
      return;
    }
    switch (ref.read(roleSessionProvider).role) {
      case AppRole.admin:
        context.go('/admin');
      case AppRole.developer:
        context.go('/dashboard');
      case AppRole.perwaskim:
        context.go('/monitoring/lapangan');
      case AppRole.guest:
        context.go('/login');
    }
  }

  Widget _notificationAction(
    BuildContext context,
    WidgetRef ref,
    int unreadCount,
    Color iconColor,
    Color badgeBorderColor,
  ) {
    return Semantics(
      button: true,
      label: 'Buka notifikasi',
      child: IconButton(
        tooltip: 'Buka notifikasi',
        onPressed: () => _goToNotifications(context, ref),
        icon: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              color: iconColor,
              size: 22,
            ),
            if (unreadCount > 0)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.notificationUnread,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: badgeBorderColor,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadNotifikasiCountProvider);
    final currentRole = ref.watch(roleSessionProvider).role;

    // Tentukan apakah style header authority (solid dark background)
    final bool isAuthority = switch (variant) {
      AppHeaderVariant.authority => true,
      AppHeaderVariant.light => false,
      AppHeaderVariant.roleBased => AppRoleTheme.isAuthorityHeader(currentRole),
    };

    // Tentukan background dan foreground color
    final Color bgColor = isAuthority
        ? AppRoleTheme.getHeaderBackground(currentRole)
        : AppColors.surface;

    final Color titleColor = isAuthority
        ? Colors.white
        : (currentRole == AppRole.developer
            ? AppRoleTheme.developerHeaderTitle
            : AppColors.textPrimary);

    final Color subtitleColor = isAuthority
        ? (currentRole == AppRole.perwaskim
            ? AppRoleTheme.fieldHeaderSubtitle
            : AppRoleTheme.adminHeaderSubtitle)
        : AppColors.textMuted;

    final Color iconColor = isAuthority ? Colors.white : AppRoleTheme.developerPrimary;

    return Material(
      color: bgColor,
      elevation: isAuthority ? 0 : 0.5,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 70,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                if (showBackButton)
                  IconButton(
                    onPressed: () => _goBack(context, ref),
                    tooltip: 'Kembali',
                    icon: Icon(
                      Icons.arrow_back,
                      color: iconColor,
                    ),
                  )
                else if (isAuthority)
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: AppRadii.pill,
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                if (isAuthority || showBackButton)
                  const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (subtitle != null && subtitle!.isNotEmpty)
                        Text(
                          isAuthority ? subtitle!.toUpperCase() : subtitle!,
                          style: isAuthority
                              ? AppTextStyles.labelSmall.copyWith(
                                  color: subtitleColor.withValues(alpha: 0.9),
                                  letterSpacing: 0.8,
                                )
                              : AppTextStyles.bodySmall.copyWith(
                                  color: subtitleColor,
                                ),
                        ),
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: isAuthority
                            ? AppTextStyles.headlineSmall.copyWith(
                                color: titleColor,
                                fontWeight: FontWeight.bold,
                              )
                            : AppTextStyles.headlineLarge.copyWith(
                                color: titleColor,
                              ),
                      ),
                    ],
                  ),
                ),
                ...actions,
                if (showNotifications)
                  _notificationAction(
                    context,
                    ref,
                    unreadCount,
                    iconColor,
                    bgColor,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
