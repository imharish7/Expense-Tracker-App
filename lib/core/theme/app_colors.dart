import 'package:flutter/material.dart';

class AppColors {
  // Brand & Accent Colors (Champagne Gold & Luxury Emerald)
  static const Color primaryGold = Color(0xFFE5B869);
  static const Color primaryGoldLight = Color(0xFFF3D99C);
  static const Color primaryGoldDark = Color(0xFFB88E3E);

  static const Color emerald = Color(0xFF10B981);
  static const Color emeraldLight = Color(0xFF34D399);
  static const Color emeraldBg = Color(0x1A10B981);

  static const Color roseExpense = Color(0xFFF43F5E);
  static const Color roseExpenseLight = Color(0xFFFB7185);
  static const Color roseExpenseBg = Color(0x1AF43F5E);

  static const Color electricViolet = Color(0xFF8B5CF6);
  static const Color cyberCyan = Color(0xFF06B6D4);
  static const Color oceanBlue = Color(0xFF3B82F6);
  static const Color royalAmber = Color(0xFFF59E0B);

  // Dark Mode Palette (Obsidian & Platinum)
  static const Color darkBackground = Color(0xFF0A0C10);
  static const Color darkSurface = Color(0xFF12151D);
  static const Color darkSurfaceElevated = Color(0xFF191E2A);
  static const Color darkSurfaceCard = Color(0xFF161A24);
  static const Color darkBorder = Color(0xFF262C3D);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);

  // Light Mode Palette (Alabaster & Slate)
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFF1F5F9);
  static const Color lightSurfaceCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF94A3B8);

  // Gradients
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFF7D070), Color(0xFFC59B27)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardDarkGradient = LinearGradient(
    colors: [Color(0xFF1E2433), Color(0xFF11141C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emeraldGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF047857)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient violetGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyberGradient = LinearGradient(
    colors: [Color(0xFF06B6D4), Color(0xFF0284C7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient roseGradient = LinearGradient(
    colors: [Color(0xFFF43F5E), Color(0xFFBE123C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
