import 'package:flutter/material.dart';
import 'design_tokens.dart';

/// Tema global de SubScan.
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: DesignTokens.fontFamily,
      colorScheme: ColorScheme.light(
        primary: DesignTokens.primary,
        primaryContainer: DesignTokens.primaryLight,
        secondary: DesignTokens.warning,
        error: DesignTokens.error,
        surface: DesignTokens.surface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: DesignTokens.textPrimary,
      ),
      scaffoldBackgroundColor: DesignTokens.background,

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: DesignTokens.fontFamily,
          fontSize: 20,
          fontWeight: DesignTokens.wBold,
          color: Colors.white,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: DesignTokens.surface,
        elevation: DesignTokens.e2,
        shadowColor: DesignTokens.primary.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.rL),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: DesignTokens.s16,
          vertical: DesignTokens.s8,
        ),
      ),

      // ElevatedButton
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: DesignTokens.primary,
          foregroundColor: Colors.white,
          elevation: DesignTokens.e2,
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.s24,
            vertical: DesignTokens.s12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.rM),
          ),
          textStyle: const TextStyle(
            fontFamily: DesignTokens.fontFamily,
            fontWeight: DesignTokens.wSemibold,
            fontSize: 15,
          ),
        ),
      ),

      // OutlinedButton
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: DesignTokens.primary,
          side: const BorderSide(color: DesignTokens.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.s24,
            vertical: DesignTokens.s12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.rM),
          ),
          textStyle: const TextStyle(
            fontFamily: DesignTokens.fontFamily,
            fontWeight: DesignTokens.wSemibold,
            fontSize: 15,
          ),
        ),
      ),

      // Chips
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.rFull),
        ),
        labelStyle: const TextStyle(
          fontFamily: DesignTokens.fontFamily,
          fontSize: 11,
          fontWeight: DesignTokens.wSemibold,
        ),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: DesignTokens.divider,
        thickness: 1,
        space: 1,
      ),

      // TextTheme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: DesignTokens.fontFamily,
          fontSize: 32,
          fontWeight: DesignTokens.wExtraBold,
          color: DesignTokens.textPrimary,
          height: 1.2,
        ),
        headlineMedium: TextStyle(
          fontFamily: DesignTokens.fontFamily,
          fontSize: 24,
          fontWeight: DesignTokens.wBold,
          color: DesignTokens.textPrimary,
          height: 1.3,
        ),
        titleLarge: TextStyle(
          fontFamily: DesignTokens.fontFamily,
          fontSize: 18,
          fontWeight: DesignTokens.wSemibold,
          color: DesignTokens.textPrimary,
          height: 1.4,
        ),
        titleMedium: TextStyle(
          fontFamily: DesignTokens.fontFamily,
          fontSize: 15,
          fontWeight: DesignTokens.wSemibold,
          color: DesignTokens.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontFamily: DesignTokens.fontFamily,
          fontSize: 15,
          fontWeight: DesignTokens.wRegular,
          color: DesignTokens.textPrimary,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontFamily: DesignTokens.fontFamily,
          fontSize: 13,
          fontWeight: DesignTokens.wRegular,
          color: DesignTokens.textSecondary,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontFamily: DesignTokens.fontFamily,
          fontSize: 11,
          fontWeight: DesignTokens.wMedium,
          color: DesignTokens.textSecondary,
          letterSpacing: 0.3,
        ),
        labelLarge: TextStyle(
          fontFamily: DesignTokens.fontFamily,
          fontSize: 14,
          fontWeight: DesignTokens.wSemibold,
          color: DesignTokens.textPrimary,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}
