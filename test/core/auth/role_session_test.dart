import 'package:flutter_test/flutter_test.dart';
import 'package:satu_rumah/core/auth/role_session.dart';
import 'package:satu_rumah/core/router/route_policy.dart';

void main() {
  test('username demo mapping creates and clears a local role session', () {
    final notifier = RoleSessionNotifier();

    expect(notifier.state.role, AppRole.guest);
    expect(notifier.signInFromUsername('  '), AppRole.guest);
    expect(notifier.state.role, AppRole.guest);
    expect(notifier.signInFromUsername('Perwaskim'), AppRole.perwaskim);
    expect(notifier.state.username, 'perwaskim');
    notifier.signOut();
    expect(notifier.signInFromUsername('ADMIN_DPKP'), AppRole.admin);
    expect(notifier.state.isAuthenticated, isTrue);
    expect(notifier.state.username, 'admin_dpkp');

    notifier.signOut();
    expect(notifier.state.role, AppRole.guest);
    expect(notifier.state.isAuthenticated, isFalse);
  });

  test('protected redirects never expose a different role shell', () {
    expect(roleRouteRedirect(role: AppRole.guest, path: '/admin'), '/login');
    expect(
      roleRouteRedirect(role: AppRole.developer, path: '/admin'),
      startsWith('/dashboard?notice='),
    );
    expect(
      roleRouteRedirect(role: AppRole.developer, path: '/monitoring/preview'),
      startsWith('/dashboard?notice='),
    );
    expect(
      roleRouteRedirect(role: AppRole.admin, path: '/monitoring/tambah'),
      startsWith('/admin?notice='),
    );
    expect(
      roleRouteRedirect(role: AppRole.admin, path: '/monitoring/success'),
      startsWith('/admin?notice='),
    );
    expect(roleRouteRedirect(role: AppRole.admin, path: '/monitoring'), isNull);
    expect(
      roleRouteRedirect(role: AppRole.admin, path: '/monitoring/preview'),
      isNull,
    );
    expect(
      roleRouteRedirect(role: AppRole.perwaskim, path: '/monitoring/tambah'),
      isNull,
    );
    expect(
      roleRouteRedirect(role: AppRole.perwaskim, path: '/monitoring/success'),
      isNull,
    );
    expect(
      roleRouteRedirect(role: AppRole.perwaskim, path: '/monitoring/lapangan'),
      isNull,
    );
    expect(roleRouteRedirect(role: AppRole.developer, path: '/login'), isNull);
  });

  test('monitoring failure destinations follow the active role', () {
    expect(monitoringFailureDestination(AppRole.admin), '/monitoring');
    expect(
      monitoringFailureDestination(AppRole.perwaskim),
      '/monitoring/lapangan',
    );
    expect(monitoringFailureDestination(AppRole.developer), '/dashboard');
    expect(monitoringFailureDestination(AppRole.guest), '/login');
  });
}
