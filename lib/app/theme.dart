import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Rating color bands — semantic, kept separate from the brand accent.
class RatingColors {
  const RatingColors._();

  static const Color great = Color(0xFF35D68A);
  static const Color good = Color(0xFFE3B341);
  static const Color poor = Color(0xFFE3557A);

  static Color forRating(double rating) {
    if (rating >= 4.0) return great;
    if (rating >= 3.0) return good;
    return poor;
  }
}

const _seed = Color(0xFF7C5CFC);

ThemeData buildQuestlogTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(seedColor: _seed, brightness: brightness);

  final base = TextTheme(
    headlineSmall: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, letterSpacing: 0.2),
    titleLarge: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, letterSpacing: 0.2),
    titleMedium: GoogleFonts.rajdhani(fontWeight: FontWeight.w600),
    titleSmall: GoogleFonts.rajdhani(fontWeight: FontWeight.w600),
    bodyLarge: GoogleFonts.manrope(),
    bodyMedium: GoogleFonts.manrope(),
    labelLarge: GoogleFonts.manrope(fontWeight: FontWeight.w600),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    textTheme: base,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      titleTextStyle: GoogleFonts.rajdhani(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
        letterSpacing: 0.3,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: scheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}
