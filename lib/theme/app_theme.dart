import 'package:einstellungstest_trainer/theme/design_tokens.dart';
import 'package:flutter/material.dart';

/// Schriftfamilien. Prosa in Plex Sans, alles Gemessene in Plex Mono.
abstract final class AppFonts {
  static const String sans = 'IBMPlexSans';
  static const String mono = 'IBMPlexMono';

  /// Fallback für den Fall, dass die gebündelte Schrift fehlt.
  static const List<String> sansFallback = ['Roboto', 'sans-serif'];
  static const List<String> monoFallback = ['monospace'];
}

/// Schriftschnitte für Zahlen.
///
/// Zeit, Zähler, Quoten und Aufgabennummern stehen in Mono mit
/// Tabellenziffern, damit sie beim Hochzählen nicht zappeln. Diese Trennung
/// von Prosa ist die eigentliche Handschrift des Entwurfs.
abstract final class MonoText {
  static const List<FontFeature> _tabular = [
    FontFeature.tabularFigures(),
  ];

  /// Überschrift über einem Abschnitt, gesperrt und in Versalien.
  static const TextStyle kicker = TextStyle(
    fontFamily: AppFonts.mono,
    fontFamilyFallback: AppFonts.monoFallback,
    fontSize: 11,
    height: 14 / 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.32,
    fontFeatures: _tabular,
  );

  /// Countdown eines Testteils.
  static const TextStyle timer = TextStyle(
    fontFamily: AppFonts.mono,
    fontFamilyFallback: AppFonts.monoFallback,
    fontSize: 40,
    height: 44 / 40,
    fontWeight: FontWeight.w500,
    fontFeatures: _tabular,
  );

  /// Der Sprint-Countdown ist größer – Hektik über Größe, nicht über Farbe.
  static const TextStyle sprintTimer = TextStyle(
    fontFamily: AppFonts.mono,
    fontFamilyFallback: AppFonts.monoFallback,
    fontSize: 56,
    height: 60 / 56,
    fontWeight: FontWeight.w600,
    fontFeatures: _tabular,
  );

  /// Große Kennzahl, etwa eine Trefferquote in der Auswertung.
  static const TextStyle display = TextStyle(
    fontFamily: AppFonts.mono,
    fontFamilyFallback: AppFonts.monoFallback,
    fontSize: 44,
    height: 48 / 44,
    fontWeight: FontWeight.w600,
    fontFeatures: _tabular,
  );

  /// Zahl in einer Kennzahl-Kachel.
  static const TextStyle metric = TextStyle(
    fontFamily: AppFonts.mono,
    fontFamilyFallback: AppFonts.monoFallback,
    fontSize: 26,
    height: 32 / 26,
    fontWeight: FontWeight.w600,
    fontFeatures: _tabular,
  );

  /// Kleine Zahl im Fließtext, etwa „5/20".
  static const TextStyle inline = TextStyle(
    fontFamily: AppFonts.mono,
    fontFamilyFallback: AppFonts.monoFallback,
    fontSize: 13,
    height: 16 / 13,
    fontWeight: FontWeight.w500,
    fontFeatures: _tabular,
  );
}

TextTheme _buildTextTheme(Color onSurface, Color onSurfaceVariant) {
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
    // display bleibt Mono – grosse Zahlen sind immer Messwerte.
    displayLarge: MonoText.display.copyWith(color: onSurface),
    displayMedium: MonoText.display.copyWith(color: onSurface),
    displaySmall: MonoText.metric.copyWith(color: onSurface),

    headlineLarge: sans(26, 32, FontWeight.w600),
    headlineMedium: sans(26, 32, FontWeight.w600),
    headlineSmall: sans(26, 32, FontWeight.w600),

    titleLarge: sans(20, 26, FontWeight.w600),
    titleMedium: sans(20, 26, FontWeight.w600),
    titleSmall: sans(16, 22, FontWeight.w600),

    bodyLarge: sans(16, 24, FontWeight.w400),
    bodyMedium: sans(16, 24, FontWeight.w400),
    bodySmall: sans(14, 20, FontWeight.w400, color: onSurfaceVariant),

    labelLarge: sans(15, 20, FontWeight.w600),
    labelMedium: sans(13, 16, FontWeight.w500),
    labelSmall: sans(12, 16, FontWeight.w500, color: onSurfaceVariant),
  );
}

ColorScheme _buildScheme(Brightness brightness, ExamTokens tokens) {
  final isLight = brightness == Brightness.light;

  return ColorScheme(
    brightness: brightness,
    // Die Hauptaktion ist die Tinte, nicht das Mathematik-Blau: Blau soll
    // eindeutig „Mathematik" heissen und nicht zugleich Markenfarbe sein.
    primary: tokens.ink,
    onPrimary: tokens.onInk,
    primaryContainer: tokens.ink,
    onPrimaryContainer: tokens.onInk,

    secondary: tokens.interactive,
    onSecondary: isLight ? Colors.white : const Color(0xFF0E1116),
    secondaryContainer: tokens.sunk,
    onSecondaryContainer: isLight
        ? const Color(0xFF14181F)
        : const Color(0xFFEDEFF2),

    tertiary: tokens.logic,
    onTertiary: Colors.white,
    tertiaryContainer: tokens.sunk,
    onTertiaryContainer: isLight
        ? const Color(0xFF14181F)
        : const Color(0xFFEDEFF2),

    error: tokens.wrong,
    onError: Colors.white,
    errorContainer: isLight ? const Color(0xFFF7E4E1) : const Color(0xFF3A1D1A),
    onErrorContainer: isLight
        ? const Color(0xFF5E1010)
        : const Color(0xFFF7D6D0),

    surface: tokens.paper,
    onSurface: isLight ? const Color(0xFF14181F) : const Color(0xFFEDEFF2),
    onSurfaceVariant: isLight
        ? const Color(0xFF4A5260)
        : const Color(0xFFA7B0BC),

    surfaceContainerLowest: tokens.raised,
    surfaceContainerLow: tokens.raised,
    surfaceContainer: tokens.paper,
    surfaceContainerHigh: tokens.sunk,
    surfaceContainerHighest: tokens.sunk,

    outline: isLight ? const Color(0xFFB9B1A5) : const Color(0xFF3D4652),
    outlineVariant: isLight
        ? const Color(0xFFDFD9D0)
        : const Color(0xFF2C333D),

    inverseSurface: isLight ? const Color(0xFF14181F) : const Color(0xFFEDEFF2),
    onInverseSurface: isLight
        ? const Color(0xFFF7F5F1)
        : const Color(0xFF14181F),
    inversePrimary: tokens.interactive,
    shadow: const Color(0xFF000000),
    scrim: const Color(0xFF000000),
  );
}

/// Das Theme der App.
///
/// Entwurfsrichtung „Prüfungsbogen, nicht Spielbrett": amtliche Sachlichkeit,
/// Papierflächen statt Kartenteppich, Mono-Ziffern für alles Gemessene.
/// Rangfolge entsteht über Fläche und Dunkelheit, nicht über Rahmen –
/// deshalb werfen Karten keinen Schatten, sondern tragen eine Haarlinie.
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
      titleTextStyle: textTheme.titleLarge,
      iconTheme: IconThemeData(color: scheme.onSurface),
    ),

    // Karten werfen keinen Schatten – nur schwebende Dinge tun das.
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
        minimumSize: const Size.fromHeight(52),
        shape: const RoundedRectangleBorder(
          borderRadius: Radii.surfaceRadius,
        ),
        textStyle: textTheme.labelLarge,
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: scheme.onSurface,
        minimumSize: const Size.fromHeight(48),
        side: BorderSide(color: scheme.outline),
        shape: const RoundedRectangleBorder(
          borderRadius: Radii.surfaceRadius,
        ),
        textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: tokens.interactive,
        textStyle: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: tokens.raised,
      selectedColor: tokens.ink,
      checkmarkColor: tokens.onInk,
      side: BorderSide(color: scheme.outlineVariant),
      labelStyle: textTheme.labelMedium,
      secondaryLabelStyle: textTheme.labelMedium?.copyWith(
        color: tokens.onInk,
      ),
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      showCheckmark: true,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: tokens.raised,
      border: OutlineInputBorder(
        borderRadius: Radii.inputRadius,
        borderSide: BorderSide(color: scheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: Radii.inputRadius,
        borderSide: BorderSide(color: scheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: Radii.inputRadius,
        borderSide: BorderSide(color: tokens.interactive, width: 2),
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
      shape: const RoundedRectangleBorder(borderRadius: Radii.cardRadius),
      behavior: SnackBarBehavior.floating,
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: tokens.raised,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: Radii.cardRadius),
      titleTextStyle: textTheme.titleMedium,
      contentTextStyle: textTheme.bodyMedium,
    ),

    listTileTheme: ListTileThemeData(
      titleTextStyle: textTheme.bodyLarge,
      subtitleTextStyle: textTheme.bodySmall,
      iconColor: scheme.onSurfaceVariant,
      contentPadding: EdgeInsets.zero,
    ),
  );
}
