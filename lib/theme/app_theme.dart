import 'package:einstellungstest_trainer/theme/design_tokens.dart';
import 'package:flutter/material.dart';

/// Schriftfamilien.
///
/// Zwei Familien mit klarer Aufgabenteilung: Space Grotesk für alles, was
/// zählt oder überschreibt — Zahlen, Titel, Bereichsnamen. Manrope für alles,
/// was gelesen wird. Die Grotesk ist eng und kantig; sie trägt Zahlen gut und
/// wäre als Fließtext anstrengend.
abstract final class AppFonts {
  static const String sans = 'Manrope';
  static const String display = 'SpaceGrotesk';

  static const List<String> sansFallback = ['Roboto', 'sans-serif'];
  static const List<String> displayFallback = ['Roboto', 'sans-serif'];
}

/// Schriftschnitte für Zahlen.
///
/// Countdown, Quote, Timer und Aufgabennummer stehen in der Grotesk mit
/// Tabellenziffern, damit sie beim Hochzählen nicht zappeln.
abstract final class NumText {
  static const List<FontFeature> _tabular = [FontFeature.tabularFigures()];

  static TextStyle _grotesk(
    double size,
    double lineHeight, {
    FontWeight weight = FontWeight.w700,
    double letterSpacing = 0,
  }) {
    return TextStyle(
      fontFamily: AppFonts.display,
      fontFamilyFallback: AppFonts.displayFallback,
      fontSize: size,
      height: lineHeight / size,
      fontWeight: weight,
      letterSpacing: letterSpacing,
      fontFeatures: _tabular,
    );
  }

  /// Beschriftung über einem Abschnitt, gesperrt und in Versalien.
  static const TextStyle kicker = TextStyle(
    fontFamily: AppFonts.display,
    fontFamilyFallback: AppFonts.displayFallback,
    fontSize: 11,
    height: 14 / 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.54,
  );

  /// Die kleine Beschriftung unter einer Zahl („TAGE").
  static const TextStyle unit = TextStyle(
    fontFamily: AppFonts.sans,
    fontFamilyFallback: AppFonts.sansFallback,
    fontSize: 9,
    height: 11 / 9,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.72,
  );

  /// Sprint- und Simulations-Countdown.
  static TextStyle get timer => _grotesk(40, 44);

  /// Die große Zahl einer Auswertung.
  static TextStyle get display => _grotesk(56, 58, letterSpacing: -1.6);

  /// Kennzahl in einer Kachel.
  static TextStyle get metric => _grotesk(24, 28, letterSpacing: -0.48);

  /// Zahl im Band, etwa die Tage bis zur Prüfung.
  static TextStyle get band => _grotesk(21, 21);

  /// Kleine Zahl in einer Zeile, etwa „64 %".
  static TextStyle get inline =>
      _grotesk(14, 18, weight: FontWeight.w700);
}

TextTheme _buildTextTheme(Color onSurface, Color onSurfaceVariant) {
  TextStyle grotesk(double size, double lineHeight, double tracking) {
    return TextStyle(
      fontFamily: AppFonts.display,
      fontFamilyFallback: AppFonts.displayFallback,
      fontSize: size,
      height: lineHeight / size,
      fontWeight: FontWeight.w700,
      letterSpacing: tracking,
      color: onSurface,
    );
  }

  TextStyle sans(
    double size,
    double lineHeight,
    FontWeight weight, {
    Color? color,
  }) {
    return TextStyle(
      fontFamily: AppFonts.sans,
      fontFamilyFallback: AppFonts.sansFallback,
      fontSize: size,
      height: lineHeight / size,
      fontWeight: weight,
      color: color ?? onSurface,
    );
  }

  return TextTheme(
    // Alles Große ist Grotesk: Titel wie Zahlen.
    displayLarge: grotesk(36, 40, -1.08),
    displayMedium: grotesk(33, 36, -0.99),
    displaySmall: grotesk(30, 33, -0.9),

    headlineLarge: grotesk(26, 30, -0.52),
    headlineMedium: grotesk(23, 25, -0.46),
    headlineSmall: grotesk(21, 24, -0.42),

    titleLarge: sans(17, 24, FontWeight.w600),
    titleMedium: sans(15.5, 21, FontWeight.w600),
    titleSmall: sans(14, 20, FontWeight.w600),

    bodyLarge: sans(16.5, 26, FontWeight.w400),
    bodyMedium: sans(15, 23, FontWeight.w400),
    bodySmall: sans(13.5, 21, FontWeight.w400, color: onSurfaceVariant),

    labelLarge: sans(16, 20, FontWeight.w600),
    labelMedium: sans(13, 17, FontWeight.w500),
    labelSmall: sans(12.5, 16, FontWeight.w500, color: onSurfaceVariant),
  );
}

ColorScheme _buildScheme(Brightness brightness, ExamTokens tokens) {
  final isLight = brightness == Brightness.light;

  return ColorScheme(
    brightness: brightness,
    // Die Hauptaktion ist die Tinte, nicht eine der drei Bereichsfarben:
    // Blau heißt Mathematik, Grün Logik, Orange Sprache – und sonst nichts.
    primary: tokens.ink,
    onPrimary: tokens.onInk,
    primaryContainer: tokens.ink,
    onPrimaryContainer: tokens.onInk,

    secondary: tokens.math.accent,
    onSecondary: Colors.white,
    secondaryContainer: tokens.sunk,
    onSecondaryContainer: isLight
        ? const Color(0xFF1C1B1A)
        : const Color(0xFFFAF7F4),

    tertiary: tokens.language.accent,
    onTertiary: Colors.white,
    tertiaryContainer: tokens.sunk,
    onTertiaryContainer: isLight
        ? const Color(0xFF1C1B1A)
        : const Color(0xFFFAF7F4),

    error: tokens.wrong,
    onError: Colors.white,
    errorContainer: tokens.wrongSoft,
    onErrorContainer: isLight
        ? const Color(0xFF8C2F2A)
        : const Color(0xFFF4C9C5),

    surface: tokens.paper,
    onSurface: isLight ? const Color(0xFF1C1B1A) : const Color(0xFFFAF7F4),
    onSurfaceVariant: isLight
        ? const Color(0xFF6E6A66)
        : const Color(0xFFB4AEA8),

    surfaceContainerLowest: tokens.raised,
    surfaceContainerLow: tokens.raised,
    surfaceContainer: tokens.paper,
    surfaceContainerHigh: tokens.sunk,
    surfaceContainerHighest: tokens.band,

    // Die gedämpfte Schrift des Entwurfs (#8f8a85) – für Beschriftungen,
    // die neben einer Zahl stehen.
    outline: isLight ? const Color(0xFF8F8A85) : const Color(0xFF938D87),
    outlineVariant: isLight
        ? const Color(0xFFE8E4E0)
        : const Color(0xFF34312E),

    inverseSurface: isLight ? const Color(0xFF1C1B1A) : const Color(0xFFFAF7F4),
    onInverseSurface: isLight
        ? const Color(0xFFFAF7F4)
        : const Color(0xFF1C1B1A),
    inversePrimary: tokens.math.accent,
    shadow: const Color(0xFF000000),
    scrim: const Color(0xFF000000),
  );
}

/// Das Theme der App.
///
/// Entwurfsrichtung: Material 3 auf warmem Papier, deutsch, ohne
/// Gamification. Weiße Karten mit großem Radius liegen auf dem Papier, jede
/// Karte trägt die Farbe ihres Bereichs, und die einzige dunkle Fläche ist
/// die Testsimulation – der Ernstfall.
ThemeData buildAppTheme(Brightness brightness) {
  final tokens =
      brightness == Brightness.light ? ExamTokens.light : ExamTokens.dark;
  final scheme = _buildScheme(brightness, tokens);
  final textTheme = _buildTextTheme(scheme.onSurface, scheme.onSurfaceVariant);

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    extensions: [tokens],
    fontFamily: AppFonts.sans,
    fontFamilyFallback: AppFonts.sansFallback,
    textTheme: textTheme,
    scaffoldBackgroundColor: scheme.surface,

    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: textTheme.headlineSmall,
      iconTheme: IconThemeData(color: scheme.onSurface),
    ),

    // Karten werfen keinen Schatten; sie stehen durch ihr Weiß auf dem
    // Papier schon genug ab.
    cardTheme: CardThemeData(
      color: tokens.raised,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: Radii.cardRadius,
        side: BorderSide(color: scheme.outlineVariant),
      ),
    ),

    dividerTheme: DividerThemeData(
      color: scheme.outlineVariant,
      thickness: 1,
      space: 1,
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: tokens.ink,
        foregroundColor: tokens.onInk,
        minimumSize: const Size.fromHeight(Gap.control),
        shape: const RoundedRectangleBorder(
          borderRadius: Radii.buttonRadius,
        ),
        textStyle: textTheme.labelLarge,
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: scheme.onSurface,
        minimumSize: const Size.fromHeight(Gap.control),
        side: BorderSide(color: scheme.outlineVariant),
        shape: const RoundedRectangleBorder(
          borderRadius: Radii.buttonRadius,
        ),
        textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: scheme.onSurfaceVariant,
        textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: tokens.paper,
      surfaceTintColor: Colors.transparent,
      indicatorColor: tokens.sunk,
      indicatorShape: const StadiumBorder(),
      height: 68,
      elevation: 0,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      labelTextStyle: WidgetStatePropertyAll(
        textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: tokens.sunk,
      selectedColor: tokens.ink,
      checkmarkColor: tokens.onInk,
      side: BorderSide.none,
      labelStyle: textTheme.labelMedium,
      secondaryLabelStyle: textTheme.labelMedium?.copyWith(color: tokens.onInk),
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      showCheckmark: true,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: tokens.raised,
      border: OutlineInputBorder(
        borderRadius: Radii.inputRadius,
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: Radii.inputRadius,
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: Radii.inputRadius,
        borderSide: BorderSide(color: scheme.onSurface, width: 2),
      ),
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? tokens.onInk
            : scheme.onSurfaceVariant,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.selected) ? tokens.ink : tokens.sunk,
      ),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    ),

    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: tokens.ink,
      linearTrackColor: tokens.sunk,
      circularTrackColor: tokens.sunk,
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: scheme.inverseSurface,
      contentTextStyle: textTheme.bodySmall?.copyWith(
        color: scheme.onInverseSurface,
      ),
      shape: const RoundedRectangleBorder(borderRadius: Radii.bandRadius),
      behavior: SnackBarBehavior.floating,
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: tokens.raised,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: Radii.cardRadius),
      titleTextStyle: textTheme.headlineSmall,
      contentTextStyle: textTheme.bodyMedium,
    ),

    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: tokens.raised,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.card)),
      ),
    ),

    listTileTheme: ListTileThemeData(
      titleTextStyle: textTheme.bodyLarge,
      subtitleTextStyle: textTheme.bodySmall,
      iconColor: scheme.onSurfaceVariant,
      contentPadding: EdgeInsets.zero,
    ),
  );
}
