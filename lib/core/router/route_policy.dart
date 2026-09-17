import '../auth/role_session.dart';

/// Returns the redirect for an authenticated role and path. Keeping this
/// pure makes role access easy to verify without booting a Flutter app.
String? roleRouteRedirect({required AppRole role, required String path}) {
  if (_isPublicPath(path)) return null;
  if (!role.isAuthenticated) return '/login';

  final requiredRole = _requiredRole(path);
  final previewMonitoring = _isPreviewMonitoringPath(path);
  if (requiredRole == null &&
      (!previewMonitoring ||
          role == AppRole.admin ||
          role == AppRole.perwaskim)) {
    return null;
  }
  if (requiredRole != null && role == requiredRole) return null;

  final requiredLabel = requiredRole?.label ?? 'Admin DPKP atau Tim Perwaskim';
  final notice = Uri.encodeComponent(
    'Halaman ini hanya tersedia untuk $requiredLabel. Anda dialihkan ke area ${role.label}.',
  );
  return '${role.homeRoute}?notice=$notice';
}

bool _isPublicPath(String path) =>
    path == '/login' || path == '/splash' || path == '/onboarding';

bool _isPreviewMonitoringPath(String path) => path == '/monitoring/preview';

AppRole? _requiredRole(String path) {
  if (path == '/dashboard' || path.startsWith('/pengajuan/')) {
    return AppRole.developer;
  }
  if (path == '/admin' || path.startsWith('/admin/')) return AppRole.admin;
  if (path == '/monitoring') return AppRole.admin;
  if (path.startsWith('/monitoring/lapangan')) return AppRole.perwaskim;
  if (path == '/monitoring/tambah' || path == '/monitoring/success') {
    return AppRole.perwaskim;
  }
  // Admin may inspect a final-report preview; only Perwaskim can create or
  // submit the monitoring report.
  if (_isPreviewMonitoringPath(path)) return null;
  return null;
}

String monitoringFailureDestination(AppRole role) {
  switch (role) {
    case AppRole.admin:
      return '/monitoring';
    case AppRole.perwaskim:
      return '/monitoring/lapangan';
    case AppRole.developer:
      return '/dashboard';
    case AppRole.guest:
      return '/login';
  }
}

String monitoringFailureDestinationLabel(AppRole role) {
  switch (role) {
    case AppRole.admin:
      return 'Kembali ke Monitoring';
    case AppRole.perwaskim:
      return 'Kembali ke Monitoring Lapangan';
    case AppRole.developer:
      return 'Kembali ke Beranda';
    case AppRole.guest:
      return 'Ke Halaman Login';
  }
}
