import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../../core/auth/role_session.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/route_feedback.dart';
import '../../../dashboard/presentation/providers/admin_dashboard_provider.dart';
import '../widgets/role_profile_view.dart';

class ProfilAdminScreen extends ConsumerStatefulWidget {
  const ProfilAdminScreen({super.key});

  @override
  ConsumerState<ProfilAdminScreen> createState() => _ProfilAdminScreenState();
}

class _ProfilAdminScreenState extends ConsumerState<ProfilAdminScreen> {
  @override
  Widget build(BuildContext context) {
    final metrics = ref.watch(adminDashboardMetricsProvider);

    return RoleProfileView(
      profileTitle: 'Profil Admin',
      displayName: 'Rizki Pratama, S.T.',
      identifier: 'NIP 19930512 202010 1 001',
      roleLabel: 'Verifikator Administrasi',
      initials: 'RP',
      heroVariant: ProfileHeroVariant.authority,
      stats: [
        ProfileStatData('${metrics.pengajuanBaruCount}', 'Pengajuan Baru'),
        ProfileStatData(
          '${metrics.perluTindakLanjutCount}',
          'Perlu Tindak Lanjut',
        ),
        ProfileStatData('${metrics.monitoringTerbaru.length}', 'Monitoring'),
      ],
      accountItems: const [
        ProfileAccountItem(
          icon: PhosphorIconsRegular.envelope,
          label: 'Email Dinas',
          value: 'rizki.pratama@tasikmalayakota.go.id',
        ),
        ProfileAccountItem(
          icon: PhosphorIconsRegular.identificationCard,
          label: 'NIP',
          value: '19930512 202010 1 001',
        ),
        ProfileAccountItem(
          icon: PhosphorIconsRegular.buildings,
          label: 'Instansi',
          value: 'Dinas Perumahan & Permukiman Kota Tasikmalaya',
        ),
      ],
      menuItems: [
        ProfileMenuItem(
          icon: PhosphorIconsRegular.userCircle,
          title: 'Data Diri',
          onTap: () => _showDataDiriDialog(context),
        ),
        ProfileMenuItem(
          icon: PhosphorIconsRegular.gear,
          title: 'Ubah Password',
          onTap: () => _showUbahPasswordModal(context),
        ),
        ProfileMenuItem(
          icon: PhosphorIconsRegular.usersThree,
          title: 'Manajemen Tugas',
          onTap: () => showUnavailableAction(context, 'Manajemen Tugas'),
        ),
        ProfileMenuItem(
          icon: PhosphorIconsRegular.info,
          title: 'Tentang Aplikasi',
          onTap: () => _showTentangAppDialog(context),
        ),
        ProfileMenuItem(
          icon: PhosphorIconsRegular.question,
          title: 'Bantuan',
          onTap: () => showUnavailableAction(context, 'Bantuan'),
        ),
      ],
      onNotifications: () => context.go('/admin/notifikasi'),
      onLogout: _logout,
      footerText: 'SATU RUMAH · Versi 1.0.0',
    );
  }

  void _logout() {
    ref.read(roleSessionProvider.notifier).signOut();
    context.go('/login');
  }

  void _showDataDiriDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Data Diri Pegawai'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nama: Rizki Pratama, S.T.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text('NIP: 19930512 202010 1 001'),
            SizedBox(height: 4),
            Text('Jabatan: Verifikator Administrasi'),
            SizedBox(height: 4),
            Text('Instansi: Dinas Perumahan & Permukiman Kota Tasikmalaya'),
            SizedBox(height: 4),
            Text('Email: rizki.pratama@tasikmalayakota.go.id'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showUbahPasswordModal(BuildContext context) {
    final oldPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Ubah Password Admin', style: AppTextStyles.h3),
                  IconButton(
                    icon: const Icon(PhosphorIconsRegular.x),
                    tooltip: 'Tutup',
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              TextField(
                controller: oldPassController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password Saat Ini',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newPassController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password Baru'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmPassController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Konfirmasi Password Baru',
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    if (newPassController.text != confirmPassController.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Konfirmasi password tidak cocok.'),
                        ),
                      );
                      return;
                    }
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password berhasil diperbarui.'),
                      ),
                    );
                  },
                  child: const Text('Simpan Password Baru'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showTentangAppDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'SATU RUMAH',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(
        PhosphorIconsRegular.buildings,
        size: 48,
        color: AppColors.actionPrimary,
      ),
      children: const [
        Text('Sistem Informasi & Pengawasan Perumahan Kota Tasikmalaya'),
        SizedBox(height: 8),
        Text('© 2026 Dinas Perumahan dan Kawasan Permukiman Kota Tasikmalaya.'),
      ],
    );
  }
}
