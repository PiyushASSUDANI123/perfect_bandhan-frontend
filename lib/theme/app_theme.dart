import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Premium Light Luxury Palette
  static const Color backgroundLight = Color(0xFFF8F9FA);   // Soft pearl white background
  static const Color backgroundBlack = Color(0xFFF8F9FA);   // Alias to keep existing code working
  static const Color cardGray = Color(0xFFFFFFFF);          // Pure white for cards
  static const Color cardWhite = Color(0xFFFFFFFF);         // Pure white alias
  static const Color accentGold = Color(0xFFD4AF37);        // Premium Gold
  static const Color premiumGold = Color(0xFFF3E5AB);       // Light Gold
  static const Color textWhite = Color(0xFF1A1A1A);         // Deep charcoal (was white, now dark for light theme)
  static const Color textCarbon = Color(0xFF1A1A1A);        // Deep charcoal text
  static const Color textMuted = Color(0xFF757575);         // Muted elegant gray
  static const Color primaryRed = Color(0xFFD44B5E);        // Soft Red/Pink for accents
  static const Color warmIvory = Color(0xFFFDFBF7);         // Warm Ivory for soft accents
  
  // Glassmorphism constants for Light Theme
  static const Color glassColor = Color(0xE6FFFFFF);        // 90% White
  static const Color glassWhite = glassColor;
  static const Color glassBorderColor = Color(0x33D4AF37);  // 20% Gold Border
  static const Color glassBorderGold = Color(0x66D4AF37);   // Gold border opacity
  static const Color glassBorder = glassBorderColor;

  // Custom Gradients
  static const LinearGradient minimalBackgroundGradient = LinearGradient(
    colors: [
      Color(0xFFF8F9FA),
      Color(0xFFE9ECEF),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient darkMinimalBackground = minimalBackgroundGradient;

  static const LinearGradient premiumGoldGradient = LinearGradient(
    colors: [
      Color(0xFFD4AF37),
      Color(0xFFF3E5AB),
      Color(0xFFD4AF37),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient burgundyButtonGradient = LinearGradient(
    colors: [
      Color(0xFFD4AF37),
      Color(0xFFB8860B), // Dark Goldenrod
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: backgroundLight,
      
      colorScheme: const ColorScheme.light(
        primary: Color(0xFFD4AF37),
        secondary: Color(0xFFF3E5AB),
        surface: cardGray,
        onSurface: textCarbon,
        error: Color(0xFFFF3B30), 
      ),

      textTheme: TextTheme(
        displayLarge: GoogleFonts.cormorantGaramond(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: textCarbon,
          letterSpacing: 1.0,
        ),
        displayMedium: GoogleFonts.cormorantGaramond(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: accentGold,
          letterSpacing: 0.5,
        ),
        titleLarge: GoogleFonts.cormorantGaramond(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: textCarbon,
        ),
        bodyLarge: GoogleFonts.montserrat(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textCarbon,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textMuted,
          height: 1.4,
        ),
        labelLarge: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: accentGold,
          letterSpacing: 0.5,
        ),
      ),
      
      dividerTheme: const DividerThemeData(
        color: glassBorderColor,
        thickness: 0.5,
      ),
    );
  }
}
