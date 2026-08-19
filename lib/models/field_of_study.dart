import 'package:einstellungstest_trainer/models/sub_category.dart';

/// Wie stark ein Thema für eine Fachrichtung zählt.
enum TopicWeight {
  /// Kommt im Auswahlverfahren mit Sicherheit vor und wird umfangreich
  /// geprüft.
  core(requiredAnswers: 30, label: 'Kernthema'),

  /// Kommt vor, aber in kleinerem Umfang.
  supporting(requiredAnswers: 15, label: 'Nebenthema');

  const TopicWeight({required this.requiredAnswers, required this.label});

  /// So viele beantwortete Aufgaben braucht es, bevor die Trefferquote in
  /// diesem Thema als belastbar gilt.
  final int requiredAnswers;

  final String label;
}

/// Die Fachrichtung, auf die jemand hinarbeitet.
///
/// Die Gewichtung ist keine Wissenschaft, sondern eine begründete Setzung aus
/// den veröffentlichten Testbeschreibungen der jeweiligen Verfahren. Wo ein
/// Bereich dort regelmäßig als eigener Testteil auftaucht, steht er hier als
/// [TopicWeight.core]; wo er nur mitläuft, als [TopicWeight.supporting].
/// Themen, die gar nicht auftauchen, fehlen – der Leitfaden verlangt sie dann
/// auch nicht.
///
/// Üben lässt sich immer alles. Die Fachrichtung steuert nur, was der
/// Leitfaden einfordert.
enum FieldOfStudy {
  general(
    id: 'general',
    label: 'Allgemein',
    description: 'Breite Vorbereitung ohne festes Ziel',
    weights: {
      SubCategory.arithmetic: TopicWeight.core,
      SubCategory.percentage: TopicWeight.core,
      SubCategory.ruleOfThree: TopicWeight.supporting,
      SubCategory.wordProblems: TopicWeight.supporting,
      SubCategory.numberSequences: TopicWeight.core,
      SubCategory.shapes: TopicWeight.supporting,
      SubCategory.conclusions: TopicWeight.supporting,
      SubCategory.spelling: TopicWeight.core,
      SubCategory.wordAnalogies: TopicWeight.supporting,
      SubCategory.grammar: TopicWeight.supporting,
      SubCategory.vocabulary: TopicWeight.supporting,
      SubCategory.strikeOut: TopicWeight.supporting,
      SubCategory.counting: TopicWeight.supporting,
      SubCategory.personalityBasics: TopicWeight.supporting,
    },
  ),
  it(
    id: 'it',
    label: 'Informatik & IT',
    description: 'Logik, Zahlenverständnis und Fachenglisch',
    weights: {
      SubCategory.numberSequences: TopicWeight.core,
      SubCategory.shapes: TopicWeight.core,
      SubCategory.conclusions: TopicWeight.core,
      SubCategory.arithmetic: TopicWeight.supporting,
      SubCategory.percentage: TopicWeight.supporting,
      SubCategory.englishVocabulary: TopicWeight.core,
      SubCategory.englishGrammar: TopicWeight.supporting,
      SubCategory.englishReading: TopicWeight.core,
      SubCategory.strikeOut: TopicWeight.supporting,
      SubCategory.personalityBasics: TopicWeight.supporting,
    },
  ),
  police(
    id: 'police',
    label: 'Polizei',
    description: 'Sprache, Konzentration und Merkfähigkeit',
    weights: {
      SubCategory.spelling: TopicWeight.core,
      SubCategory.grammar: TopicWeight.core,
      SubCategory.vocabulary: TopicWeight.core,
      SubCategory.wordAnalogies: TopicWeight.supporting,
      SubCategory.strikeOut: TopicWeight.core,
      SubCategory.counting: TopicWeight.core,
      SubCategory.comparison: TopicWeight.core,
      SubCategory.numberSequences: TopicWeight.supporting,
      SubCategory.shapes: TopicWeight.supporting,
      SubCategory.conclusions: TopicWeight.supporting,
      SubCategory.arithmetic: TopicWeight.supporting,
      SubCategory.percentage: TopicWeight.supporting,
      SubCategory.personalityBasics: TopicWeight.core,
      SubCategory.personalityAnswers: TopicWeight.core,
    },
  ),
  business(
    id: 'business',
    label: 'BWL & Kaufmännisch',
    description: 'Rechnen, Textverständnis und Wirtschaftsenglisch',
    weights: {
      SubCategory.percentage: TopicWeight.core,
      SubCategory.ruleOfThree: TopicWeight.core,
      SubCategory.wordProblems: TopicWeight.core,
      SubCategory.arithmetic: TopicWeight.supporting,
      SubCategory.vocabulary: TopicWeight.core,
      SubCategory.spelling: TopicWeight.supporting,
      SubCategory.englishVocabulary: TopicWeight.core,
      SubCategory.englishReading: TopicWeight.supporting,
      SubCategory.conclusions: TopicWeight.supporting,
      SubCategory.personalityBasics: TopicWeight.supporting,
    },
  ),
  fireBrigade(
    id: 'fire_brigade',
    label: 'Feuerwehr & Rettungsdienst',
    description: 'Konzentration, Technikverständnis und Rechnen',
    weights: {
      SubCategory.strikeOut: TopicWeight.core,
      SubCategory.counting: TopicWeight.core,
      SubCategory.comparison: TopicWeight.supporting,
      SubCategory.arithmetic: TopicWeight.core,
      SubCategory.ruleOfThree: TopicWeight.core,
      SubCategory.shapes: TopicWeight.core,
      SubCategory.numberSequences: TopicWeight.supporting,
      SubCategory.spelling: TopicWeight.supporting,
      SubCategory.personalityBasics: TopicWeight.core,
    },
  ),
  humanResources(
    id: 'hr',
    label: 'Personal & HR',
    description: 'Sprache, Menschenkenntnis und Textverständnis',
    weights: {
      SubCategory.vocabulary: TopicWeight.core,
      SubCategory.grammar: TopicWeight.core,
      SubCategory.spelling: TopicWeight.core,
      SubCategory.wordAnalogies: TopicWeight.core,
      SubCategory.conclusions: TopicWeight.core,
      SubCategory.personalityBasics: TopicWeight.core,
      SubCategory.personalityAnswers: TopicWeight.core,
      SubCategory.percentage: TopicWeight.supporting,
      SubCategory.englishVocabulary: TopicWeight.supporting,
    },
  ),
  engineering(
    id: 'engineering',
    label: 'Ingenieurwesen',
    description: 'Rechnen, räumliches Denken und Technikenglisch',
    weights: {
      SubCategory.arithmetic: TopicWeight.core,
      SubCategory.ruleOfThree: TopicWeight.core,
      SubCategory.percentage: TopicWeight.core,
      SubCategory.wordProblems: TopicWeight.core,
      SubCategory.shapes: TopicWeight.core,
      SubCategory.numberSequences: TopicWeight.core,
      SubCategory.conclusions: TopicWeight.supporting,
      SubCategory.englishVocabulary: TopicWeight.supporting,
      SubCategory.englishReading: TopicWeight.supporting,
    },
  ),
  publicService(
    id: 'public_service',
    label: 'Verwaltung & Öffentlicher Dienst',
    description: 'Rechtschreibung, Textverständnis und Sorgfalt',
    weights: {
      SubCategory.spelling: TopicWeight.core,
      SubCategory.grammar: TopicWeight.core,
      SubCategory.vocabulary: TopicWeight.core,
      SubCategory.percentage: TopicWeight.core,
      SubCategory.ruleOfThree: TopicWeight.supporting,
      SubCategory.comparison: TopicWeight.core,
      SubCategory.strikeOut: TopicWeight.supporting,
      SubCategory.conclusions: TopicWeight.supporting,
      SubCategory.personalityBasics: TopicWeight.supporting,
    },
  ),
  banking(
    id: 'banking',
    label: 'Bank & Versicherung',
    description: 'Prozent- und Zinsrechnen, Sorgfalt, Kundensprache',
    weights: {
      SubCategory.percentage: TopicWeight.core,
      SubCategory.ruleOfThree: TopicWeight.core,
      SubCategory.arithmetic: TopicWeight.core,
      SubCategory.wordProblems: TopicWeight.supporting,
      SubCategory.comparison: TopicWeight.core,
      SubCategory.vocabulary: TopicWeight.core,
      SubCategory.spelling: TopicWeight.supporting,
      SubCategory.englishVocabulary: TopicWeight.supporting,
      SubCategory.personalityBasics: TopicWeight.supporting,
    },
  ),
  transport(
    id: 'transport',
    label: 'Bahn & Verkehr',
    description: 'Konzentration, Reaktion und technisches Rechnen',
    weights: {
      SubCategory.strikeOut: TopicWeight.core,
      SubCategory.counting: TopicWeight.core,
      SubCategory.comparison: TopicWeight.core,
      SubCategory.arithmetic: TopicWeight.core,
      SubCategory.ruleOfThree: TopicWeight.supporting,
      SubCategory.shapes: TopicWeight.supporting,
      SubCategory.numberSequences: TopicWeight.supporting,
      SubCategory.personalityBasics: TopicWeight.core,
    },
  ),
  health(
    id: 'health',
    label: 'Pflege & Gesundheit',
    description: 'Rechnen mit Einheiten, Sprache und Belastbarkeit',
    weights: {
      SubCategory.arithmetic: TopicWeight.core,
      SubCategory.ruleOfThree: TopicWeight.core,
      SubCategory.percentage: TopicWeight.supporting,
      SubCategory.spelling: TopicWeight.core,
      SubCategory.vocabulary: TopicWeight.core,
      SubCategory.strikeOut: TopicWeight.supporting,
      SubCategory.personalityBasics: TopicWeight.core,
      SubCategory.personalityAnswers: TopicWeight.supporting,
      SubCategory.englishVocabulary: TopicWeight.supporting,
    },
  ),
  trades(
    id: 'trades',
    label: 'Handwerk & Technik',
    description: 'Rechnen, räumliches Vorstellungsvermögen, Sorgfalt',
    weights: {
      SubCategory.arithmetic: TopicWeight.core,
      SubCategory.ruleOfThree: TopicWeight.core,
      SubCategory.wordProblems: TopicWeight.supporting,
      SubCategory.shapes: TopicWeight.core,
      SubCategory.numberSequences: TopicWeight.supporting,
      SubCategory.counting: TopicWeight.supporting,
      SubCategory.spelling: TopicWeight.supporting,
    },
  ),
  aviation(
    id: 'aviation',
    label: 'Luftfahrt',
    description: 'Konzentration unter Druck, räumliches Denken, Englisch',
    weights: {
      SubCategory.strikeOut: TopicWeight.core,
      SubCategory.counting: TopicWeight.core,
      SubCategory.comparison: TopicWeight.core,
      SubCategory.shapes: TopicWeight.core,
      SubCategory.numberSequences: TopicWeight.core,
      SubCategory.arithmetic: TopicWeight.core,
      SubCategory.englishVocabulary: TopicWeight.core,
      SubCategory.englishReading: TopicWeight.core,
      SubCategory.personalityBasics: TopicWeight.supporting,
    },
  );

  const FieldOfStudy({
    required this.id,
    required this.label,
    required this.description,
    required this.weights,
  });

  /// Stabiler Schlüssel für die Persistenz.
  final String id;

  final String label;
  final String description;

  /// Welche Themen der Leitfaden verlangt – und wie streng.
  final Map<SubCategory, TopicWeight> weights;

  /// Die geforderten Themen in fester Reihenfolge: erst die Kernthemen, dann
  /// die Nebenthemen, innerhalb der Gruppen nach Modul sortiert.
  List<SubCategory> get topics {
    final core = <SubCategory>[];
    final supporting = <SubCategory>[];

    for (final topic in SubCategory.values) {
      switch (weights[topic]) {
        case TopicWeight.core:
          core.add(topic);
        case TopicWeight.supporting:
          supporting.add(topic);
        case null:
          break;
      }
    }

    return [...core, ...supporting];
  }

  static FieldOfStudy fromId(String id) {
    return values.firstWhere(
      (field) => field.id == id,
      orElse: () => FieldOfStudy.general,
    );
  }
}
