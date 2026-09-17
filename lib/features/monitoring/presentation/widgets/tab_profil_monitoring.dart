import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../../core/auth/role_session.dart';
import '../../../profil/presentation/widgets/role_profile_view.dart';
import '../providers/monitoring_list_provider.dart';
import '../../../../core/widgets/route_feedback.dart';

class TabProfilMonitoring extends ConsumerWidget {
  const TabProfilMonitoring({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monitoring = ref.watch(monitoringListProvider);
    final now = DateTime.now();
    final thisMonth = monitoring
        .where(
          (item) =>
              item.tanggalMonitoring.year == now.year &&
              item.tanggalMonitoring.month == now.month,
        )
        .length;
    final draftCount = monitoring.where((item) => item.isDraft).length;

    return RoleProfileView(
      profileTitle: 'Profil Perwaskim',
      displayName: 'Budi Santoso, S.T.',
      identifier: 'NIP. 19880512 201503 1 002',
      roleLabel: 'Tim Perwaskim Lapangan',
      initials: 'BS',
      heroVariant: ProfileHeroVariant.authority,
      stats: [
        ProfileStatData('$thisMonth', 'Monitoring Bulan Ini'),
        ProfileStatData('${monitoring.length}', 'Total Laporan'),
        ProfileStatData('$draftCount', 'Draft Offline'),
      ],
      accountItems: const [
        ProfileAccountItem(
          icon: PhosphorIconsRegular.envelope,
          label: 'Email Dinas',
          value: 'budi.perwaskim@tasikmalayakota.go.id',
        ),
        ProfileAccountItem(
          icon: PhosphorIconsRegular.phone,
          label: 'No. WhatsApp',
          value: '0812-3456-7890',
        ),
        ProfileAccountItem(
          icon: PhosphorIconsRegular.mapPin,
          label: 'Instansi',
          value: 'Dinas Perumahan & Kawasan Permukiman',
        ),
      ],
      menuItems: [
        ProfileMenuItem(
          icon: PhosphorIconsRegular.key,
          title: 'Ubah Password',
          onTap: () => showUnavailableAction(context, 'Ubah Password'),
        ),
        ProfileMenuItem(
          icon: PhosphorIconsRegular.question,
          title: 'Kontak Admin Kantor / Verifikator',
          onTap: () => showUnavailableAction(
            context,
            'Kontak Admin Kantor / Verifikator',
          ),
        ),
        ProfileMenuItem(
          icon: PhosphorIconsRegular.bookOpen,
          title: 'Panduan SOP Monitoring',
          onTap: () => showUnavailableAction(context, 'Panduan SOP Monitoring'),
        ),
      ],
      onNotifications: () => context.go('/monitoring/lapangan/notifikasi'),
      onLogout: () {
        ref.read(roleSessionProvider.notifier).signOut();
        context.go('/login');
      },
      footerText: 'SATU RUMAH · Versi 1.0.0 (Build 2026)',
    );
  }
}
