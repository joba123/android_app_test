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
    shortLabel: 'Mathe',
    description: 'Grundrechnen, Dreisatz, Prozent- und Textaufgaben',
    icon: Icons.calculate_outlined,
    color: Color(0xFF2F6FED),
  ),
  logic(
    id: 'logic',
    label: 'Logisches Denken',
    shortLabel: 'Logik',
    description: 'Zahlenreihen, Analogien, Muster und Schlussfolgerungen',
    icon: Icons.extension_outlined,
    color: Color(0xFF7A4FE0),
  ),
  language(
    id: 'language',
    label: 'Sprache',
    shortLabel: 'Sprache',
    description: 'Rechtschreibung, Grammatik, Wortschatz und Textverstaendnis',
    icon: Icons.menu_book_outlined,
    color: Color(0xFF0E9F6E),
  );

  const TrainingModule({
    required this.id,
    required this.label,
    required this.shortLabel,
    required this.description,
    required this.icon,
    required this.color,
  });

  final String id;
  final String label;
  final String shortLabel;
  final String description;
  final IconData icon;
  final Color color;

  static TrainingModule fromId(String id) {
    return TrainingModule.values.firstWhere(
      (module) => module.id == id,
      orElse: () => TrainingModule.math,
    );
  }
}
