import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/dashboard/presentation/screens/admin_main_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/monitoring/data/models/monitoring_model.dart';
import '../../features/monitoring/presentation/screens/laporan_preview_screen.dart';
import '../../features/monitoring/presentation/screens/laporan_success_screen.dart';
import '../../features/monitoring/presentation/screens/monitoring_list_screen.dart';
import '../../features/monitoring/presentation/screens/monitoring_main_screen.dart';
import '../../features/monitoring/presentation/screens/tambah_monitoring_stepper_screen.dart';
import '../../features/notifikasi/presentation/screens/notifikasi_list_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/pengajuan/presentation/screens/pengajuan_admin_detail_screen.dart';
import '../../features/pengajuan/presentation/screens/pengajuan_detail_screen.dart';
import '../../features/pengajuan/presentation/screens/pengajuan_step1_screen.dart';
import '../../features/pengajuan/presentation/screens/pengajuan_step2_screen.dart';
import '../../features/pengajuan/presentation/screens/pengajuan_step3_screen.dart';
import '../../features/pengajuan/presentation/screens/pengajuan_step4_screen.dart';
import '../../features/pengajuan/presentation/screens/pengajuan_step5_review_screen.dart';
import '../../features/pengajuan/presentation/screens/pengajuan_success_screen.dart';
import '../auth/role_session.dart';
import 'route_policy.dart';
import '../widgets/route_feedback.dart';

export 'route_policy.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen<RoleSessionState>(roleSessionProvider, (_, __) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) {
      final path = state.uri.path;
      if (path == '/') {
        return '/splash';
      }
      return roleRouteRedirect(
        role: ref.read(roleSessionProvider).role,
        path: path,
      );
    },
    errorBuilder: (context, state) {
      final session = ref.read(roleSessionProvider);
      return RouteUnavailableScreen(
        title: 'Halaman tidak ditemukan',
        message: 'Tautan yang dibuka tidak tersedia atau sudah berubah.',
        safeDestination: session.isAuthenticated
            ? session.role.homeRoute
            : '/login',
        destinationLabel: session.isAuthenticated
            ? 'Kembali ke Beranda'
            : 'Ke Halaman Login',
      );
    },
    routes: [
      GoRoute(path: '/', redirect: (_, __) => '/splash'),
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (_, state) => _withNotice(state, const DashboardScreen()),
      ),
      GoRoute(
        path: '/admin',
        builder: (_, state) =>
            _withNotice(state, const AdminMainScreen(initialIndex: 0)),
      ),
      GoRoute(
        path: '/admin/pengajuan',
        builder: (_, state) =>
            _withNotice(state, const AdminMainScreen(initialIndex: 1)),
      ),
      GoRoute(
        path: '/admin/pengajuan/detail/:id',
        builder: (_, state) =>
            PengajuanAdminDetailScreen(id: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: '/admin/notifikasi',
        builder: (_, state) =>
            _withNotice(state, const AdminMainScreen(initialIndex: 3)),
      ),
      GoRoute(
        path: '/admin/profil',
        builder: (_, state) =>
            _withNotice(state, const AdminMainScreen(initialIndex: 4)),
      ),
      GoRoute(
        path: '/monitoring',
        builder: (_, state) =>
            _withNotice(state, const AdminMainScreen(initialIndex: 2)),
      ),
      GoRoute(
        path: '/monitoring/lapangan',
        builder: (_, state) =>
            _withNotice(state, const MonitoringMainScreen(initialIndex: 0)),
      ),
      GoRoute(
        path: '/monitoring/lapangan/riwayat',
        builder: (_, __) => const MonitoringListScreen(showBottomNav: false),
      ),
      GoRoute(
        path: '/monitoring/lapangan/profil',
        builder: (_, state) =>
            _withNotice(state, const MonitoringMainScreen(initialIndex: 2)),
      ),
      GoRoute(
        path: '/monitoring/lapangan/notifikasi',
        builder: (_, state) => _withNotice(state, const NotifikasiListScreen()),
      ),
      GoRoute(
        path: '/monitoring/tambah',
        builder: (_, __) => const TambahMonitoringStepperScreen(),
      ),
      GoRoute(
        path: '/monitoring/success',
        builder: (_, state) {
          final item = state.extra;
          if (item is! MonitoringModel) {
            final role = ref.read(roleSessionProvider).role;
            return RouteUnavailableScreen(
              title: 'Laporan monitoring tidak tersedia',
              message:
                  'Laporan tidak dapat ditampilkan karena data hasil survey tidak ditemukan.',
              safeDestination: monitoringFailureDestination(role),
              destinationLabel: monitoringFailureDestinationLabel(role),
            );
          }
          return LaporanSuccessScreen(monitoring: item);
        },
      ),
      GoRoute(
        path: '/monitoring/preview',
        builder: (_, state) {
          final extra = state.extra;
          if (extra is MonitoringModel) {
            return LaporanPreviewScreen(
              monitoring: extra,
              isDraft: extra.isDraft,
            );
          }
          if (extra is Map) {
            final model = extra['model'];
            final draft = extra['isDraft'];
            if (model is MonitoringModel && (draft == null || draft is bool)) {
              return LaporanPreviewScreen(
                monitoring: model,
                isDraft: draft as bool? ?? model.isDraft,
              );
            }
          }
          final role = ref.read(roleSessionProvider).role;
          return RouteUnavailableScreen(
            title: 'Preview laporan tidak tersedia',
            message:
                'Data draft atau laporan monitoring tidak ditemukan. Silakan buka kembali dari daftar monitoring.',
            safeDestination: monitoringFailureDestination(role),
            destinationLabel: monitoringFailureDestinationLabel(role),
          );
        },
      ),
      GoRoute(
        path: '/pengajuan/step1',
        builder: (_, __) => const PengajuanStep1Screen(),
      ),
      GoRoute(
        path: '/pengajuan/step2',
        builder: (_, __) => const PengajuanStep2Screen(),
      ),
      GoRoute(
        path: '/pengajuan/step3',
        builder: (_, __) => const PengajuanStep3Screen(),
      ),
      GoRoute(
        path: '/pengajuan/step4',
        builder: (_, __) => const PengajuanStep4Screen(),
      ),
      GoRoute(
        path: '/pengajuan/step5',
        builder: (_, __) => const PengajuanStep5ReviewScreen(),
      ),
      GoRoute(
        path: '/pengajuan/success',
        builder: (_, state) {
          final id = state.extra;
          if (id is! String || id.trim().isEmpty) {
            return const RouteUnavailableScreen(
              title: 'Pengajuan tidak tersedia',
              message:
                  'Nomor pengajuan tidak ditemukan. Buka daftar pengajuan untuk melanjutkan.',
              safeDestination: '/dashboard',
              destinationLabel: 'Kembali ke Pengajuan',
            );
          }
          return PengajuanSuccessScreen(pengajuanId: id);
        },
      ),
      GoRoute(
        path: '/pengajuan/detail/:id',
        builder: (_, state) =>
            PengajuanDetailScreen(id: state.pathParameters['id'] ?? ''),
      ),
    ],
  );
});

Widget _withNotice(GoRouterState state, Widget child) {
  return RouteNotice(
    message: state.uri.queryParameters['notice'],
    child: child,
  );
}
