import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class AppColors {
  // Dark Mode Background Gradient
  static const backgroundStart = Color(0xFF141414); // Near Black
  static const backgroundEnd = Color(0xFF0A0A0A);   // True Black
  
  // Accents
  static const accent = Color(0xFFE5B8B8); // Muted Rose/Pink
  static const primary = Color(0xFFE5B8B8); // Muted Rose/Pink
  
  // Text
  static const textPrimary = Colors.white;
  static const textSecondary = Colors.white60;
  static const textTertiary = Colors.white38;
  
  // Glass System
  static const glassFill = Color(0x0DFFFFFF); // White @ 5%
  static const glassBorder = Color(0x26FFFFFF); // White @ 15%
  
  // Specific UI Elements
  static const inputFill = Color(0xFF1E1E1E); // Fallback if glass is too expensive
}

abstract class AppRadius {
  static const small = 12.0;
  static const medium = 20.0;
  static const card = 24.0;
  static const large = 32.0;
  static const pill = 100.0; // Full rounding
}

abstract class AppText {
  static final display = GoogleFonts.poppins(
    fontSize: 32, fontWeight: FontWeight.w600, color: AppColors.textPrimary
  );
  
  static final header = GoogleFonts.poppins(
    fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.textPrimary
  );
  
  static final title = GoogleFonts.poppins(
    fontSize: 20, fontWeight: FontWeight.w500, color: AppColors.textPrimary
  );
  
  static final subtitle = GoogleFonts.poppins(
    fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.accent
  );
  
  static final body = GoogleFonts.poppins(
    fontSize: 14, color: AppColors.textSecondary, height: 1.5
  );
  
  static final bodyBold = GoogleFonts.poppins(
    fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary
  );
  
  static final label = GoogleFonts.poppins(
    fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textTertiary
  );
}
