import 'package:flutter/material.dart';
import '../auth/role_session.dart';
import 'app_colors.dart';

/// Standarisasi Tema Warna dan Tipografi Visual Resmi Per-Role.
/// Sesuai Business Requirements Document (BRD) & Architecture Guide SATU RUMAH.
///
/// Semua nilai warna **direferensikan dari [AppColors]** — tidak ada hex literal
/// di sini. Ini memastikan satu sumber kebenaran: ubah warna cukup di [AppColors].
class AppRoleTheme {
  // ─── PENGEMBANG (Developer) ────────────────────────────────────────────────
  static const Color developerPrimary = AppColors.roleDeveloperPrimary;
  static const Color developerPrimaryLight = AppColors.roleDeveloperPrimaryLight;
  static const Color developerAccent = AppColors.roleDeveloperAccent;
  static const Color developerHeaderBg = AppColors.roleDeveloperPrimary; // solid brand red
  static const Color developerHeaderTitle = AppColors.roleDeveloperHeaderTitle;
  static const Color developerHeaderSubtitle = AppColors.roleDeveloperHeaderSubtitle;

  // ─── ADMIN DISPERWASKIM ────────────────────────────────────────────────────
  static const Color adminPrimary = AppColors.roleAdminPrimary;
  static const Color adminPrimaryDark = AppColors.roleAdminPrimaryDark;
  static const Color adminAccent = AppColors.roleAdminAccent;
  static const Color adminHeaderBg = AppColors.roleAdminPrimary;
  static const Color adminHeaderTitle = Colors.white;
  static const Color adminHeaderSubtitle = AppColors.roleAdminHeaderSubtitle;

  // ─── TIM PENGAWAS LAPANGAN ─────────────────────────────────────────────────
  static const Color fieldPrimary = AppColors.roleFieldPrimary;
  static const Color fieldPrimaryLight = AppColors.roleFieldPrimaryLight;
  static const Color fieldAccent = AppColors.roleFieldAccent;
  static const Color fieldHeaderBg = AppColors.roleFieldPrimary;
  static const Color fieldHeaderTitle = Colors.white;
  static const Color fieldHeaderSubtitle = AppColors.roleFieldHeaderSubtitle;

  // ─── NAVIGASI (semua role) ─────────────────────────────────────────────────
  static const Color unselectedNavColor = AppColors.roleNavUnselected;
  static const Color navBackgroundColor = Colors.white;

  // ─── Fungsi Resolver ───────────────────────────────────────────────────────

  /// Warna primer sesuai peran aktif — dipakai oleh BottomNavigationBar.
  static Color getPrimaryColor(AppRole role) {
    switch (role) {
      case AppRole.developer:
        return developerPrimary;
      case AppRole.admin:
        return adminPrimary;
      case AppRole.perwaskim:
        return fieldPrimary;
      case AppRole.guest:
        return developerPrimary;
    }
  }

  /// Accent / surface badge color sesuai peran aktif.
  static Color getAccentColor(AppRole role) {
    switch (role) {
      case AppRole.developer:
        return developerAccent;
      case AppRole.admin:
        return adminAccent;
      case AppRole.perwaskim:
        return fieldAccent;
      case AppRole.guest:
        return developerAccent;
    }
  }

  /// Warna background AppBar sesuai peran aktif.
  static Color getHeaderBackground(AppRole role) {
    switch (role) {
      case AppRole.developer:
        return developerHeaderBg;
      case AppRole.admin:
        return adminHeaderBg;
      case AppRole.perwaskim:
        return fieldHeaderBg;
      case AppRole.guest:
        return developerHeaderBg;
    }
  }

  /// Warna teks judul AppBar sesuai peran aktif.
  static Color getHeaderTitleColor(AppRole role) {
    switch (role) {
      case AppRole.developer:
        return developerHeaderTitle;
      case AppRole.admin:
        return adminHeaderTitle;
      case AppRole.perwaskim:
        return fieldHeaderTitle;
      case AppRole.guest:
        return developerHeaderTitle;
    }
  }

  /// Warna teks subjudul AppBar sesuai peran aktif.
  static Color getHeaderSubtitleColor(AppRole role) {
    switch (role) {
      case AppRole.developer:
        return developerHeaderSubtitle;
      case AppRole.admin:
        return adminHeaderSubtitle;
      case AppRole.perwaskim:
        return fieldHeaderSubtitle;
      case AppRole.guest:
        return developerHeaderSubtitle;
    }
  }

  /// Semua peran menggunakan header bergaya authority solid (teks putih).
  static bool isAuthorityHeader(AppRole role) => true;
}
