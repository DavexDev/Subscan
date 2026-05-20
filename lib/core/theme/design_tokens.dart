import 'package:flutter/material.dart';

/// Tokens de diseño centralizados para SubScan.
/// Cambiar aquí afecta toda la app.
class DesignTokens {
  DesignTokens._();

  // ─── Colores ──────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF6366F1);       // Indigo vibrante
  static const Color primaryLight = Color(0xFFA5B4FC);
  static const Color primaryDark = Color(0xFF4338CA);

  static const Color success = Color(0xFF10B981);       // Verde esmeralda
  static const Color successLight = Color(0xFFD1FAE5);

  static const Color warning = Color(0xFFF59E0B);       // Ámbar
  static const Color warningLight = Color(0xFFFEF3C7);

  static const Color error = Color(0xFFEF4444);         // Rojo
  static const Color errorLight = Color(0xFFFEE2E2);

  static const Color background = Color(0xFFF8F7FF);    // Blanco violáceo
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F0FE);

  static const Color textPrimary = Color(0xFF1E1B4B);   // Índigo muy oscuro
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textDisabled = Color(0xFFD1D5DB);

  static const Color divider = Color(0xFFE5E7EB);

  // Gradiente header del dashboard
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
  );

  // Gradiente urgente
  static const LinearGradient urgentGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFEF4444), Color(0xFFF97316)],
  );

  // ─── Espaciado ────────────────────────────────────────────────────────────
  static const double s2 = 2.0;
  static const double s4 = 4.0;
  static const double s6 = 6.0;
  static const double s8 = 8.0;
  static const double s10 = 10.0;
  static const double s12 = 12.0;
  static const double s16 = 16.0;
  static const double s20 = 20.0;
  static const double s24 = 24.0;
  static const double s32 = 32.0;
  static const double s48 = 48.0;
  static const double s64 = 64.0;
  static const double s80 = 80.0;

  // ─── Border Radius ────────────────────────────────────────────────────────
  static const double rXS = 4.0;
  static const double rS = 8.0;
  static const double rM = 12.0;
  static const double rL = 16.0;
  static const double rXL = 24.0;
  static const double rFull = 999.0;

  // ─── Elevación ────────────────────────────────────────────────────────────
  static const double e0 = 0;
  static const double e1 = 1;
  static const double e2 = 2;
  static const double e4 = 4;
  static const double e8 = 8;

  // ─── Tipografía ───────────────────────────────────────────────────────────
  static const String fontFamily = 'Outfit';

  static const FontWeight wRegular = FontWeight.w400;
  static const FontWeight wMedium = FontWeight.w500;
  static const FontWeight wSemibold = FontWeight.w600;
  static const FontWeight wBold = FontWeight.w700;
  static const FontWeight wExtraBold = FontWeight.w800;

  // ─── Duración de animaciones ──────────────────────────────────────────────
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animNormal = Duration(milliseconds: 300);
  static const Duration animSlow = Duration(milliseconds: 500);
}
