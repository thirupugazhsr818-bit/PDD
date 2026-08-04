// lib/core/theme/app_colors.dart

import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette
  static const Color primary = Color(0xFF00D4AA);       // Emerald teal
  static const Color primaryDark = Color(0xFF00A882);
  static const Color primaryLight = Color(0xFF4DFFCF);

  // Background
  static const Color bgDark = Color(0xFF0A0E1A);        // Deep navy black
  static const Color bgCard = Color(0xFF111827);        // Card background
  static const Color bgElevated = Color(0xFF1A2234);    // Elevated card

  // Accent
  static const Color accentGold = Color(0xFFF5C842);
  static const Color accentRed = Color(0xFFFF4D6A);
  static const Color accentBlue = Color(0xFF4D9FFF);
  static const Color accentPurple = Color(0xFF9B6DFF);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8A9BB8);
  static const Color textMuted = Color(0xFF3D4F6B);

  // Border
  static const Color border = Color(0xFF1E2D45);
  static const Color borderGlow = Color(0xFF00D4AA26);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00D4AA), Color(0xFF0094FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1A2234), Color(0xFF111827)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bgGradient = LinearGradient(
    colors: [Color(0xFF0A0E1A), Color(0xFF0D1424)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
