import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

import '../data/database.dart';

/// Palette de couleurs de VoltSuivi.
class VoltColors {
  VoltColors._();

  static const Color porcelaine = Color(0xFFF2F4F7);
  static const Color encre = Color(0xFF111B2B);
  static const Color cuivre = Color(0xFFC25E1E);
  static const Color energie = Color(0xFF1D4FD7);
  static const Color solaire = Color(0xFF2E9862);

  static const Color lieuDomicile = Color(0xFFB4780C);
  static const Color lieuTravail = Color(0xFF7C3AED);
  static const Color lieuAutre = Color(0xFF64748B);

  static Color couleurLieu(Lieu lieu) => switch (lieu) {
        Lieu.domicile => lieuDomicile,
        Lieu.travail => lieuTravail,
        Lieu.autre => lieuAutre,
      };
}

const String voltFontOdometre = 'monospace';

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: VoltColors.cuivre,
      brightness: Brightness.light,
      primary: VoltColors.cuivre,
      surface: VoltColors.porcelaine,
    );
    return _base(scheme, VoltColors.porcelaine, VoltColors.encre);
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: VoltColors.cuivre,
      brightness: Brightness.dark,
      primary: const Color(0xFFE58A4C),
    );
    return _base(scheme, const Color(0xFF0B1220), const Color(0xFFE7EDF6));
  }

  static ThemeData _base(ColorScheme scheme, Color bg, Color fg) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: fg,
        elevation: 0,
        centerTitle: false,
      ),
      textTheme: ThemeData(brightness: scheme.brightness)
          .textTheme
          .apply(bodyColor: fg, displayColor: fg),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: EdgeInsets.zero,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: VoltColors.cuivre,
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  /// Style « compteur » monospace pour les montants et kilométrages.
  static TextStyle styleOdometre(
    BuildContext context, {
    double size = 40,
    Color? color,
    FontWeight weight = FontWeight.w700,
  }) {
    return TextStyle(
      fontFamily: voltFontOdometre,
      fontFeatures: const [FontFeature.tabularFigures()],
      fontSize: size,
      fontWeight: weight,
      color: color ?? Theme.of(context).colorScheme.onSurface,
      letterSpacing: -0.5,
    );
  }
}
