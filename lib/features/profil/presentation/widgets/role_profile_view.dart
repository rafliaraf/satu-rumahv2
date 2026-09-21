import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/prototype_data_banner.dart';

enum ProfileHeroVariant { light, authority }

class ProfileStatData {
  final String value;
  final String label;

  const ProfileStatData(this.value, this.label);
}

class ProfileAccountItem {
  final IconData icon;
  final String label;
  final String value;

  const ProfileAccountItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class ProfileMenuItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });
}

/// Shared profile composition for every role.
///
/// The data and action lists stay role-specific, while the hero, account
/// panels, stat rhythm, icon family, and logout treatment stay shared.
class RoleProfileView extends StatelessWidget {
  final String profileTitle;
  final String displayName;
  final String roleLabel;
  final String initials;
  final String? identifier;
  final ProfileHeroVariant heroVariant;
  final List<ProfileStatData> stats;
  final List<ProfileAccountItem> accountItems;
  final List<ProfileMenuItem> menuItems;
  final VoidCallback onLogout;
  final VoidCallback? onNotifications;
  final String logoutLabel;
  final String footerText;
  final Widget banner;

  const RoleProfileView({
    super.key,
    required this.profileTitle,
    required this.displayName,
    required this.roleLabel,
    required this.initials,
    required this.heroVariant,
    required this.accountItems,
    required this.menuItems,
    required this.onLogout,
    required this.footerText,
    this.identifier,
    this.stats = const [],
    this.onNotifications,
    this.logoutLabel = 'Keluar Akun',
    this.banner = const PrototypeDataBanner(),
  });

  bool get _isAuthority => heroVariant == ProfileHeroVariant.authority;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHero(context),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  banner,
                  if (stats.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.lg),
                    _buildStats(),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  _buildSectionHeader('Data akun'),
                  const SizedBox(height: AppSpacing.sm),
                  _buildPanel(
                    children: [
                      for (var i = 0; i < accountItems.length; i++) ...[
                        _buildAccountItem(accountItems[i]),
                        if (i < accountItems.length - 1)
                          const Divider(
                            height: 1,
                            indent: 56,
                            endIndent: 16,
                            color: AppColors.borderSubtle,
                          ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _buildSectionHeader('Pengaturan & bantuan'),
                  const SizedBox(height: AppSpacing.sm),
                  _buildPanel(
                    children: [
                      for (var i = 0; i < menuItems.length; i++) ...[
                        _buildMenuItem(menuItems[i]),
                        if (i < menuItems.length - 1)
                          const Divider(
                            height: 1,
                            indent: 56,
                            endIndent: 16,
                            color: AppColors.borderSubtle,
                          ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: onLogout,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.actionPrimary,
                        side: const BorderSide(
                          color: AppColors.actionPrimary,
                          width: 1.2,
                        ),
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadii.pill,
                        ),
                      ),
                      icon: const Icon(PhosphorIconsRegular.signOut, size: 18),
                      label: Text(
                        logoutLabel,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.actionPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Center(
                    child: Text(
                      footerText,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textMuted,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    final foreground = _isAuthority ? Colors.white : AppColors.textPrimary;
    final secondary = _isAuthority
        ? Colors.white.withValues(alpha: 0.76)
        : AppColors.textMuted;
    final heroColor = _isAuthority ? AppColors.brandPrimary : AppColors.surface;
    final rolePillColor = _isAuthority
        ? Colors.white.withValues(alpha: 0.18)
        : AppColors.brandPrimary.withValues(alpha: 0.1);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        MediaQuery.paddingOf(context).top + AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: heroColor,
        borderRadius: AppRadii.hero,
        border: _isAuthority
            ? null
            : const Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AKUN SAYA',
                style: AppTextStyles.labelSmall.copyWith(
                  color: secondary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              if (onNotifications != null)
                IconButton(
                  onPressed: onNotifications,
                  tooltip: 'Buka notifikasi',
                  constraints: const BoxConstraints.tightFor(
                    width: 40,
                    height: 40,
                  ),
                  padding: EdgeInsets.zero,
                  icon: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _isAuthority
                          ? Colors.white.withValues(alpha: 0.15)
                          : AppColors.surfaceWarm,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      PhosphorIconsRegular.bell,
                      color: foreground,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            profileTitle,
            style: AppTextStyles.headlineLarge.copyWith(
              color: foreground,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: foreground, width: 2),
                  color: AppColors.champagneToast,
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (identifier != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        identifier!,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: secondary,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: rolePillColor,
                        borderRadius: AppRadii.control,
                      ),
                      child: Text(
                        roleLabel,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: foreground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        for (var i = 0; i < stats.length; i++) ...[
          Expanded(child: _buildStatCard(stats[i])),
          if (i < stats.length - 1) const SizedBox(width: AppSpacing.sm),
        ],
      ],
    );
  }

  Widget _buildStatCard(ProfileStatData stat) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.card,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          Text(
            stat.value,
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.actionPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            stat.label,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textMuted,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 3.5,
          height: 15,
          decoration: const BoxDecoration(
            color: AppColors.actionPrimary,
            borderRadius: AppRadii.tight,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          title,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPanel({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.card,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildAccountItem(ProfileAccountItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.statusAttention.withValues(alpha: 0.08),
              borderRadius: AppRadii.control,
            ),
            child: Icon(item.icon, color: AppColors.actionPrimary, size: 18),
          ),
          const SizedBox(width: AppSpacing.md + 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  item.value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(ProfileMenuItem item) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      leading: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: const BoxDecoration(
          color: AppColors.surfaceSubtle,
          borderRadius: AppRadii.control,
        ),
        child: Icon(item.icon, color: AppColors.textPrimary, size: 18),
      ),
      title: Text(
        item.title,
        style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
      ),
      trailing: const Icon(
        PhosphorIconsRegular.caretRight,
        color: AppColors.textMuted,
        size: 18,
      ),
      onTap: item.onTap,
    );
  }
}
