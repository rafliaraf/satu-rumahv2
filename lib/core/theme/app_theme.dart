import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_role_theme.dart';
import 'app_text_styles.dart';
import '../auth/role_session.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.chilliDust,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.chilliDust,
        secondary: AppColors.champagneToast,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: AppColors.cocoaBeanRoast,
        onSurface: AppColors.cocoaBeanRoast,
        onError: Colors.white,
      ),

      // Card Theme (Standard rounded corners ~16px)
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: AppColors.grey200, width: 1),
        ),
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.displayMedium,
        displaySmall: AppTextStyles.displaySmall,
        headlineLarge: AppTextStyles.headlineLarge,
        headlineMedium: AppTextStyles.headlineMedium,
        headlineSmall: AppTextStyles.headlineSmall,
        titleLarge: AppTextStyles.titleLarge,
        titleMedium: AppTextStyles.titleMedium,
        titleSmall: AppTextStyles.titleSmall,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.labelLarge,
        labelMedium: AppTextStyles.labelMedium,
        labelSmall: AppTextStyles.labelSmall,
      ),

      // Elevated Button Theme (PrimaryButton)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.chilliDust,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          textStyle: AppTextStyles.labelLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // Outlined Button Theme (SecondaryButton)
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.chilliDust,
          side: const BorderSide(color: AppColors.chilliDust, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          textStyle: AppTextStyles.labelLarge.copyWith(
            color: AppColors.chilliDust,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // Input Decoration Theme (Text Field styles)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.grey50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: AppColors.grey300, width: 1),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: AppColors.grey300, width: 1),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: AppColors.chilliDust, width: 2),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textMuted,
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textMuted,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  /// Mengembalikan [ThemeData] yang sudah disesuaikan dengan warna peran aktif.
  ///
  /// Fungsi ini mengambil [lightTheme] sebagai basis, kemudian menimpa
  /// [AppBarTheme] dan [BottomNavigationBarThemeData] dengan warna primer
  /// dari peran yang diberikan — sehingga seluruh app otomatis berubah warna
  /// cukup dengan mengganti [role] tanpa menyentuh widget individual.
  ///
  /// Contoh penggunaan di [MaterialApp]:
  /// ```dart
  /// theme: AppTheme.getThemeByRole(ref.watch(roleSessionProvider).role),
  /// ```
  static ThemeData getThemeByRole(AppRole role) {
    final primary = AppRoleTheme.getPrimaryColor(role);
    final headerBg = AppRoleTheme.getHeaderBackground(role);
    final headerTitle = AppRoleTheme.getHeaderTitleColor(role);
    final headerSubtitle = AppRoleTheme.getHeaderSubtitleColor(role);
    final isAuthority = AppRoleTheme.isAuthorityHeader(role);

    return lightTheme.copyWith(
      // Warna skema primer mengikuti role
      colorScheme: lightTheme.colorScheme.copyWith(primary: primary),

      // AppBar: background & foreground sesuai role
      appBarTheme: AppBarTheme(
        backgroundColor: headerBg,
        foregroundColor: headerTitle,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        iconTheme: IconThemeData(color: headerTitle),
        actionsIconTheme: IconThemeData(color: headerTitle),
        titleTextStyle: AppTextStyles.titleLarge.copyWith(
          color: headerTitle,
          fontWeight: FontWeight.bold,
        ),
        toolbarTextStyle: AppTextStyles.labelMedium.copyWith(
          color: isAuthority ? headerSubtitle : AppColors.textMuted,
        ),
      ),

      // BottomNavigationBar: selected item mengikuti primary role
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppRoleTheme.navBackgroundColor,
        selectedItemColor: primary,
        unselectedItemColor: AppRoleTheme.unselectedNavColor,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: AppTextStyles.labelSmall.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTextStyles.labelSmall,
      ),
    );
  }
}
