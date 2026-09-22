import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../../core/auth/role_session.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_role_theme.dart';
import '../../../../core/widgets/route_feedback.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../../pengajuan/data/models/status_tahap_pengajuan.dart';
import '../../../pengajuan/presentation/providers/pengajuan_form_controller.dart';
import '../widgets/role_profile_view.dart';

class ProfilScreen extends ConsumerWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pengajuan = ref.watch(pengajuanListProvider);
    final selesai = pengajuan
        .where((item) => item.statusTahap == StatusTahapPengajuan.selesai)
        .length;

    return RoleProfileView(
      profileTitle: 'Profil Pengembang',
      displayName: 'PT. Tasik Indah Sentosa',
      roleLabel: 'Developer Perumahan',
      initials: 'TI',
      heroVariant: ProfileHeroVariant.authority,
      customPrimaryColor: AppRoleTheme.developerPrimary,
      stats: [
        ProfileStatData('${pengajuan.length}', 'Total Pengajuan'),
        ProfileStatData('${pengajuan.length - selesai}', 'Dalam Proses'),
        ProfileStatData('$selesai', 'Selesai'),
      ],
      accountItems: const [
        ProfileAccountItem(
          icon: PhosphorIconsRegular.buildings,
          label: 'Perusahaan',
          value: 'PT. Tasik Indah Sentosa',
        ),
        ProfileAccountItem(
          icon: PhosphorIconsRegular.envelope,
          label: 'Email akun',
          value: 'tasikindah@developer.com',
        ),
      ],
      menuItems: [
        ProfileMenuItem(
          icon: PhosphorIconsRegular.briefcase,
          title: 'Profil Perusahaan',
          onTap: () => showUnavailableAction(context, 'Profil Perusahaan'),
        ),
        ProfileMenuItem(
          icon: PhosphorIconsRegular.lock,
          title: 'Ubah Kata Sandi',
          onTap: () => showUnavailableAction(context, 'Ubah Kata Sandi'),
        ),
        ProfileMenuItem(
          icon: PhosphorIconsRegular.question,
          title: 'Pusat Bantuan',
          onTap: () => showUnavailableAction(context, 'Pusat Bantuan'),
        ),
        ProfileMenuItem(
          icon: PhosphorIconsRegular.info,
          title: 'Tentang Aplikasi',
          onTap: () => showUnavailableAction(context, 'Tentang Aplikasi'),
        ),
      ],
      onNotifications: () {
        ref.read(dashboardTabProvider.notifier).state = 2;
        context.go('/dashboard');
      },
      onLogout: () => _logout(context, ref),
      footerText:
          'SATU RUMAH v1.0.0\nDinas Perumahan Rakyat dan Kawasan Permukiman\nKota Tasikmalaya',
    );
  }

  void _logout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Keluar Aplikasi'),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari akun Pengembang ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ref.read(roleSessionProvider.notifier).signOut();
              context.go('/login');
            },
            child: const Text(
              'Keluar',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
