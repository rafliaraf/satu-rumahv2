import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The local prototype's authenticated role. This is intentionally process
/// local: it models the current demo session without implying API auth or
/// persistence.
enum AppRole { guest, developer, admin, perwaskim }

extension AppRoleX on AppRole {
  bool get isAuthenticated => this != AppRole.guest;

  String get label {
    switch (this) {
      case AppRole.guest:
        return 'Tamu';
      case AppRole.developer:
        return 'Pengembang';
      case AppRole.admin:
        return 'Admin Disperwaskim';
      case AppRole.perwaskim:
        return 'Tim Perwaskim';
    }
  }

  String get homeRoute {
    switch (this) {
      case AppRole.guest:
        return '/login';
      case AppRole.developer:
        return '/dashboard';
      case AppRole.admin:
        return '/admin';
      case AppRole.perwaskim:
        return '/monitoring/lapangan';
    }
  }
}

class RoleSessionState {
  final AppRole role;
  final String? username;

  const RoleSessionState({this.role = AppRole.guest, this.username});

  bool get isAuthenticated => role.isAuthenticated;

  RoleSessionState copyWith({AppRole? role, String? username}) {
    return RoleSessionState(
      role: role ?? this.role,
      username: username ?? this.username,
    );
  }
}

class RoleSessionNotifier extends StateNotifier<RoleSessionState> {
  RoleSessionNotifier() : super(const RoleSessionState());

  void signIn(AppRole role, {String? username}) {
    if (role == AppRole.guest) {
      signOut();
      return;
    }
    state = RoleSessionState(role: role, username: username);
  }

  AppRole signInFromUsername(String username) {
    final normalized = username.trim().toLowerCase();
    final role = roleForUsername(normalized);
    signIn(role, username: normalized.isEmpty ? null : normalized);
    return role;
  }

  void signOut() {
    state = const RoleSessionState();
  }

  static AppRole roleForUsername(String username) {
    final normalized = username.trim().toLowerCase();
    if (normalized.isEmpty) return AppRole.guest;
    if (normalized == 'admin_disperwaskim' ||
        normalized.startsWith('admin')) {
      return AppRole.admin;
    }
    if (normalized == 'monitoring_perwaskim' ||
        normalized == 'perwaskim' ||
        normalized == 'petugas_lapangan' ||
        normalized.startsWith('tim_')) {
      return AppRole.perwaskim;
    }
    // The local prototype intentionally treats other non-empty usernames as
    // the developer/fallback demo role.
    return AppRole.developer;
  }
}

final roleSessionProvider =
    StateNotifierProvider<RoleSessionNotifier, RoleSessionState>((ref) {
      return RoleSessionNotifier();
    });
