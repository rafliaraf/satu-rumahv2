import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_text_styles.dart';

/// Reusable shortcut card widget untuk menu pintasan dashboard.
///
/// Menggunakan [Flexible] + [mainAxisSize: MainAxisSize.min] pada Column
/// untuk mencegah RenderFlex bottom overflow pada card yang disabled
/// (menampilkan teks tambahan "Segera hadir").
class ShortcutCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final bool disabled;

  const ShortcutCard({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: !disabled,
      label: disabled ? '$title, segera hadir' : title,
      child: Card(
        color: disabled ? AppColors.surfaceSubtle : Colors.white,
        child: InkWell(
          onTap: disabled ? null : onTap,
          borderRadius: AppRadii.card,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  color: disabled
                      ? AppColors.textMuted
                      : AppColors.actionPrimary,
                  size: 28,
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: Text(
                    title,
                    style: AppTextStyles.titleSmall.copyWith(
                      color: disabled
                          ? AppColors.textMuted
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (disabled) ...[
                  const SizedBox(height: 4),
                  Flexible(
                    child: Text(
                      'Segera hadir',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
