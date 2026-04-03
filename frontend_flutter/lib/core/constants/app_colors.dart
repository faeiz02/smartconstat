import 'package:flutter/material.dart';

class AppColors {
  // ─── Primary Palette ───
  static const Color primaryBlue    = Color(0xFF0F2B5B);
  static const Color secondaryBlue  = Color(0xFF2563EB);
  static const Color accentCyan     = Color(0xFF06B6D4);

  // ─── Surfaces ───
  static const Color scaffold       = Color(0xFFF0F4FA);
  static const Color cardWhite      = Color(0xFFFFFFFF);
  static const Color surfaceGlass   = Color(0xB3FFFFFF); // 70 % white
  static const Color lightBlue      = Color(0xFFF0F4FA);

  // ─── Semantic ───
  static const Color greenSuccess   = Color(0xFF059669);
  static const Color redDanger      = Color(0xFFDC2626);
  static const Color orangeWarning  = Color(0xFFF59E0B);

  // ─── Feature Accents ───
  static const Color purpleAssistance = Color(0xFF7C3AED);
  static const Color tealSoins        = Color(0xFF0D9488);
  static const Color brownFactures    = Color(0xFF92400E);
  static const Color pinkDevis        = Color(0xFFDB2777);

  // ─── Neutrals ───
  static const Color darkGrey   = Color(0xFF111827);
  static const Color mediumGrey = Color(0xFF6B7280);
  static const Color lightGrey  = Color(0xFFE5E7EB);
  static const Color borderGrey = Color(0xFFD1D5DB);

  // ─── Gradients ───
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0F2B5B), Color(0xFF2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient dangerGradient = LinearGradient(
    colors: [Color(0xFFDC2626), Color(0xFFF87171)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF059669), Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}