import 'package:einstellungstest_trainer/theme/design_tokens.dart';
import 'package:flutter/material.dart';

/// Die fachlichen Trainingsbereiche der App.
///
/// Bewusst branchenneutral gehalten: Die Module bilden ab, was in nahezu
/// jedem Einstellungstest vorkommt (Polizei, Verwaltung, Bahn, Industrie).
/// Ein Branchen-Filter kann später als zusaetzliche Dimension ergaenzt
/// werden, ohne diese Struktur zu veraendern.
enum TrainingModule {
  math(
    id: 'math',
    label: 'Mathematik',
    menuLabel: 'Mathematik',
    shortLabel: 'Mathe',
    description: 'Grundrechnen, Dreisatz, Prozent- und Textaufgaben',
    icon: Icons.calculate_outlined,
    glyph: '×',
    color: Color(0xFF4087DE),
  ),
  logic(
    id: 'logic',
    label: 'Logisches Denken',
    menuLabel: 'Logik',
    shortLabel: 'Logik',
    description: 'Zahlenreihen, Analogien, Muster und Schlussfolgerungen',
    icon: Icons.extension_outlined,
    // Die Raute des Entwurfs fuehrt keine der beiden Schriften; sie wird
    // deshalb gezeichnet, nicht gesetzt (siehe ModuleGlyph).
    glyph: '',
    color: Color(0xFF0FA05C),
  ),
  language(
    id: 'language',
    label: 'Sprache',
    menuLabel: 'Sprache',
    shortLabel: 'Sprache',
    description: 'Rechtschreibung, Grammatik, Wortschatz und Textverstaendnis',
    icon: Icons.menu_book_outlined,
    glyph: 'Aa',
    color: Color(0xFFCD632D),
  ),
  english(
    id: 'english',
    label: 'Englisch',
    menuLabel: 'Englisch',
    shortLabel: 'Englisch',
    description: 'Vokabeln, Grammatik und Textverstaendnis auf Englisch',
    icon: Icons.language_outlined,
    glyph: 'EN',
    color: Color(0xFF00A0A2),
  ),
  concentration(
    id: 'concentration',
    label: 'Konzentration',
    menuLabel: 'Konzentration',
    shortLabel: 'Konzentr.',
    description: 'Durchstreichtest, Zaehlen und Vergleichen unter Zeitdruck',
    icon: Icons.center_focus_strong_outlined,
    // Der Punkt steht fuer das Zeichen, das im Durchstreichtest gesucht wird.
    glyph: '',
    color: Color(0xFFA98000),
  ),
  personality(
    id: 'personality',
    label: 'Persönlichkeitstest',
    menuLabel: 'Persönlichkeit',
    shortLabel: 'Persoenl.',
    description: 'Wie Persoenlichkeitsfragebogen gewertet werden',
    icon: Icons.psychology_outlined,
    glyph: '?',
    color: Color(0xFF956ED2),
  );

  const TrainingModule({
    required this.id,
    required this.label,
    required this.menuLabel,
    required this.shortLabel,
    required this.description,
    required this.icon,
    required this.glyph,
    required this.color,
  });

  final String id;
  final String label;

  /// Der Name im Hauptmenue: kurz genug fuer eine Zeile, aber nicht
  /// abgekuerzt – „Logisches Denken" bricht dort um, „Logik" nicht.
  final String menuLabel;

  final String shortLabel;
  final String description;
  final IconData icon;

  /// Das Zeichen auf der Bereichskachel. Leer heisst: gezeichnet statt
  /// gesetzt.
  final String glyph;

  /// Die Bereichsfarbe im Hellmodus – fuer Stellen ohne BuildContext.
  final Color color;

  static TrainingModule fromId(String id) {
    return TrainingModule.values.firstWhere(
      (module) => module.id == id,
      orElse: () => TrainingModule.math,
    );
  }

  /// Die drei Farben des Bereichs im aktuellen Hell-/Dunkelmodus.
  ModulePalette palette(BuildContext context) {
    final tokens = context.tokens;
    return switch (this) {
      TrainingModule.math => tokens.math,
      TrainingModule.logic => tokens.logic,
      TrainingModule.language => tokens.language,
      TrainingModule.english => tokens.english,
      TrainingModule.concentration => tokens.concentration,
      TrainingModule.personality => tokens.personality,
    };
  }

  /// Die Bereichsfarbe im aktuellen Hell-/Dunkelmodus.
  Color resolveColor(BuildContext context) => palette(context).accent;
}