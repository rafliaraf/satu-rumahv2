import 'package:flutter/material.dart';

class AppColors {
  // Brand Palette - Rustic Indulgence
  static const Color chilliDust = Color(0xFFB92216); // Primary
  static const Color champagneToast = Color(
    0xFFE7E6C2,
  ); // Secondary / Highlight
  static const Color cocoaBeanRoast = Color(0xFF402D18); // Dark Text
  static const Color pistachioCream = Color(0xFFB7C688); // Success / Accent

  // Support / Neutrals
  static const Color background = Color(0xFFFDFDFB); // Warm off-white
  static const Color surface = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFF57C00);
  static const Color info = Color(0xFF1976D2);

  // Greys
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // Semantic aliases keep role screens on one visual contract.
  static const Color brandPrimary = chilliDust;
  static const Color actionPrimary = chilliDust;
  static const Color statusAttention = chilliDust;
  static const Color statusSuccess = Color(0xFF4B6B16);
  static const Color statusInfo = Color(0xFF0288D1);
  static const Color statusTechnical = Color(0xFF7B1FA2);
  static const Color statusSurvey = Color(0xFFE65100);
  static const Color statusApproved = Color(0xFF2E7D32);
  static const Color statusCompleted = Color(0xFF388E3C);
  static const Color notificationUnread = chilliDust;
  static const Color textPrimary = cocoaBeanRoast;
  static const Color textMuted = grey700;
  static const Color surfaceSubtle = grey50;
  static const Color borderSubtle = grey200;
  static const Color surfaceWarm = Color(0xFFF7F5EE);
  static const Color surfaceAttention = Color(0xFFF9EAE8);
  static const Color surfaceSuccess = Color(0xFFE2EED7);
  static const Color surfaceInfo = Color(0xFFE8E3CB);
  static const Color surfaceMuted = Color(0xFFF0EFEA);

  // ─── Role Palettes (Sumber Resmi Palet Warna Per-Peran) ───────────────────
  // Seluruh role menggunakan palet brand RUSTIC yang sama.
  // Ubah chilliDust di atas → otomatis berlaku ke semua role.

  /// Pengembang / Developer — Brand Rustic (sama dengan brand utama)
  static const Color roleDeveloperPrimary = chilliDust;
  static const Color roleDeveloperPrimaryLight = Color(0xFFD62E1F); // chilliDust lighter
  static const Color roleDeveloperAccent = Color(0xFFF9EAE8); // surfaceAttention warm
  static const Color roleDeveloperHeaderTitle = Colors.white;
  static const Color roleDeveloperHeaderSubtitle = champagneToast;

  /// Admin Disperwaskim — Brand Rustic (sama dengan brand utama)
  static const Color roleAdminPrimary = chilliDust;
  static const Color roleAdminPrimaryDark = Color(0xFF8C1A10); // chilliDust darker
  static const Color roleAdminAccent = Color(0xFFF9EAE8); // surfaceAttention warm
  static const Color roleAdminHeaderSubtitle = champagneToast;

  /// Tim Pengawas Lapangan — Brand Rustic (sama dengan brand utama)
  static const Color roleFieldPrimary = chilliDust;
  static const Color roleFieldPrimaryLight = Color(0xFFD62E1F); // chilliDust lighter
  static const Color roleFieldAccent = Color(0xFFF9EAE8); // surfaceAttention warm
  static const Color roleFieldHeaderSubtitle = champagneToast;

  /// BottomNavigationBar unselected (semua role)
  static const Color roleNavUnselected = Color(0xFF94A3B8); // Slate 400
}
