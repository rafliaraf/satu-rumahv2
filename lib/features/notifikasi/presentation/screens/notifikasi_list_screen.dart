import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/auth/role_session.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/route_feedback.dart';
import '../../../../core/widgets/prototype_data_banner.dart';
import '../../data/models/notifikasi_model.dart';
import '../providers/notifikasi_provider.dart';

/// Rewrites a notification's local target into a route valid for the active
/// role. A null result is an explicit unavailable outcome, never a silent
/// navigation to another role's shell.
String? notificationTargetForRole(NotifikasiModel item, AppRole role) {
  final target = item.targetRoute;
  if (target == null || target.trim().isEmpty) return null;

  final pengajuanId = RegExp(
    r'SR-[A-Za-z0-9-]+',
  ).firstMatch(item.deskripsi)?.group(0);
  switch (role) {
    case AppRole.guest:
      return null;
    case AppRole.admin:
      if (target.startsWith('/admin/pengajuan/detail/')) return target;
      if (target.startsWith('/pengajuan/detail/')) {
        return target.replaceFirst(
          '/pengajuan/detail/',
          '/admin/pengajuan/detail/',
        );
      }
      if (target == '/monitoring' ||
          target.startsWith('/monitoring/preview') ||
          target == '/monitoring/tambah') {
        return target;
      }
      if (target.startsWith('/monitoring/lapangan')) return '/monitoring';
      return null;
    case AppRole.developer:
      if (target.startsWith('/pengajuan/detail/')) return target;
      if (target.startsWith('/admin/pengajuan/detail/')) {
        return target.replaceFirst(
          '/admin/pengajuan/detail/',
          '/pengajuan/detail/',
        );
      }
      if (target.startsWith('/monitoring')) {
        return pengajuanId == null ? null : '/pengajuan/detail/$pengajuanId';
      }
      if (target == '/dashboard') return target;
      return null;
    case AppRole.perwaskim:
      if (target.startsWith('/monitoring/lapangan')) return target;
      if (target == '/monitoring') return '/monitoring/lapangan';
      if (target.startsWith('/monitoring/preview')) return target;
      if (target.startsWith('/pengajuan/detail/') ||
          target.startsWith('/admin/pengajuan/detail/')) {
        return '/monitoring/lapangan';
      }
      return null;
  }
}

class NotifikasiListScreen extends ConsumerStatefulWidget {
  const NotifikasiListScreen({super.key});

  @override
  ConsumerState<NotifikasiListScreen> createState() =>
      _NotifikasiListScreenState();
}

class _NotifikasiListScreenState extends ConsumerState<NotifikasiListScreen> {
  String _selectedFilter = 'Semua';

  @override
  Widget build(BuildContext context) {
    final allNotifs = ref.watch(notifikasiProvider);
    final notifier = ref.read(notifikasiProvider.notifier);
    final role = ref.watch(roleSessionProvider).role;

    final filteredNotifs = _selectedFilter == 'Belum Dibaca'
        ? allNotifs.where((e) => !e.isRead).toList()
        : allNotifs;

    return Scaffold(
      appBar: AppHeader(
        variant: role == AppRole.admin
            ? AppHeaderVariant.authority
            : AppHeaderVariant.light,
        title: role == AppRole.admin
            ? 'Pemerintah Kota Tasikmalaya'
            : 'SATU RUMAH',
        subtitle: role == AppRole.admin ? 'SATU RUMAH' : null,
        showNotifications: false,
      ),
      backgroundColor: AppColors.surfaceWarm,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: PrototypeDataBanner(),
          ),
          // Title & Dropdown Filter Row
          Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 8,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Notifikasi',
                      style: AppTextStyles.h2.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.cocoaBeanRoast,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppRadii.pill,
                        border: Border.all(color: AppColors.grey300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedFilter,
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: AppColors.cocoaBeanRoast,
                            size: 18,
                          ),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.cocoaBeanRoast,
                          ),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedFilter = val);
                            }
                          },
                          items: const [
                            DropdownMenuItem(
                              value: 'Semua',
                              child: Text('Semua'),
                            ),
                            DropdownMenuItem(
                              value: 'Belum Dibaca',
                              child: Text('Belum Dibaca'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: allNotifs.any((item) => !item.isRead)
                        ? notifier.markAllAsRead
                        : null,
                    child: const Text('Tandai semua dibaca'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // List Items
          Expanded(
            child: filteredNotifs.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.notifications_off_outlined,
                          size: 64,
                          color: AppColors.grey400,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Tidak ada notifikasi.',
                          style: TextStyle(
                            color: AppColors.grey600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    itemCount: filteredNotifs.length,
                    itemBuilder: (context, index) {
                      final item = filteredNotifs[index];
                      final jenis = item.jenis;
                      final dateStr = _formatWaktu(item.waktu);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 0,
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadii.card,
                        ),
                        color: AppColors.surface,
                        child: InkWell(
                          borderRadius: AppRadii.card,
                          onTap: () {
                            notifier.markAsRead(item.id);
                            final route = notificationTargetForRole(item, role);
                            if (route == null) {
                              showUnavailableAction(
                                context,
                                'Tujuan notifikasi ini',
                              );
                            } else {
                              context.push(route);
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: const BoxDecoration(
                                    color: AppColors.surfaceAttention,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    jenis.icon,
                                    color: AppColors.chilliDust,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.judul,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.cocoaBeanRoast,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item.deskripsi,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.grey700,
                                          height: 1.3,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        dateStr,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: AppColors.grey600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (!item.isRead)
                                  Container(
                                    margin: const EdgeInsets.only(
                                      left: 8,
                                      top: 4,
                                    ),
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppColors.chilliDust,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _formatWaktu(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} menit lalu';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} jam lalu';
    } else {
      return DateFormat('d MMM').format(time);
    }
  }
}
