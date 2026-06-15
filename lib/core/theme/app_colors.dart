import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand
  static const saffronPrimary = Color(0xFFFF6B35);
  static const saffronLight = Color(0xFFFF8C42);
  static const goldPrimary = Color(0xFFFFB800);
  static const goldLight = Color(0xFFFFD60A);
  static const goldDark = Color(0xFFE69900);

  // Light mode
  static const lightBackground = Color(0xFFFFF8F0);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightCard = Color(0xFFFFF3E0);
  static const lightTextPrimary = Color(0xFF1A0800);
  static const lightTextSecondary = Color(0xFF5C3D1E);
  static const lightDivider = Color(0xFFFFE0B2);

  // Dark mode
  static const darkBackground = Color(0xFF0D0500);
  static const darkSurface = Color(0xFF1A0A00);
  static const darkCard = Color(0xFF2A1500);
  static const darkTextPrimary = Color(0xFFFFF8E7);
  static const darkTextSecondary = Color(0xFFFFCC80);
  static const darkDivider = Color(0xFF3E2000);

  // Status
  static const activeGreen = Color(0xFF4CAF50);
  static const stoppedRed = Color(0xFFE53935);
  static const errorRed = Color(0xFFD32F2F);

  // Gradients
  static const List<Color> saffronGoldGradient = [saffronPrimary, goldPrimary];
  static const List<Color> saffronLightGradient = [saffronLight, goldLight];
  static const List<Color> darkGradient = [Color(0xFF3E1A00), Color(0xFF1A0500)];

  static LinearGradient get primaryGradient => const LinearGradient(
        colors: saffronGoldGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get lightGradient => const LinearGradient(
        colors: saffronLightGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get drawerGradient => const LinearGradient(
        colors: [Color(0xFF5C1A00), Color(0xFF3E1000)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
}
