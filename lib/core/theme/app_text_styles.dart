import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle headingLarge(Color color) => GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: color,
      );

  static TextStyle headingMedium(Color color) => GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle headingSmall(Color color) => GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle bodyLarge(Color color) => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: color,
      );

  static TextStyle bodyMedium(Color color) => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: color,
      );

  static TextStyle caption(Color color) => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w300,
        color: color,
      );

  static TextStyle labelBold(Color color) => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: color,
      );

  // Hindi text uses Hind font
  static TextStyle hindiBodyLarge(Color color) => GoogleFonts.hind(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: color,
      );

  static TextStyle hindiHeading(Color color) => GoogleFonts.hind(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: color,
      );
}
