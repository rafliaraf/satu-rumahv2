import 'package:flutter/material.dart';

import '../../../../core/widgets/app_header.dart';

/// Backwards-compatible Admin wrapper around the shared authority header.
class AdminHeaderWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const AdminHeaderWidget({
    super.key,
    this.title = 'Pemerintah Kota Tasikmalaya',
    this.subtitle = 'SATU RUMAH',
    this.showBackButton = false,
    this.onBackPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    return AppHeader(
      variant: AppHeaderVariant.authority,
      title: title,
      subtitle: subtitle,
      showBackButton: showBackButton,
      onBackPressed: onBackPressed,
    );
  }
}
