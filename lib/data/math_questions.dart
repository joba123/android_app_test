import 'package:einstellungstest_trainer/models/question.dart';
import 'package:einstellungstest_trainer/models/sub_category.dart';

/// Startpool Mathematik.
///
/// Überwiegend als freie Zahleneingabe angelegt: Im echten Einstellungstest
/// wird gerechnet, nicht aus vier Vorschlägen geraten. Wo die Distraktoren
/// selbst lehrreich sind (typische Denkfehler), bleibt Multiple Choice.
///
/// Antwortoptionen sind aufsteigend sortiert notiert – das Mischen übernimmt
/// die QuestionRepository zur Laufzeit.
const List<Question> mathQuestions = [
  // --- Grundrechenarten ---
  Question(
    id: 'math_basics_01',
    subCategory: SubCategory.arithmetic,
    prompt: '17 · 24 = ?',
    answer: NumericInput(correctValue: 408),
    explanation: '17 · 24 = 17 · 20 + 17 · 4 = 340 + 68 = 408.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'math_basics_02',
    subCategory: SubCategory.arithmetic,
    prompt: '144 : 12 + 7 · 3 = ?',
    answer: NumericInput(correctValue: 33),
    explanation: 'Punkt vor Strich: 144 : 12 = 12 und 7 · 3 = 21. '
        'Erst danach addieren: 12 + 21 = 33.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'math_basics_03',
    subCategory: SubCategory.arithmetic,
    prompt: 'Wie viele Sekunden hat 1 Stunde und 15 Minuten?',
    answer: NumericInput(correctValue: 4500, unit: 'Sekunden'),
    explanation: '75 Minuten · 60 Sekunden = 4.500 Sekunden.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'math_basics_04',
    subCategory: SubCategory.arithmetic,
    prompt: 'Wie viel sind drei Viertel von 260?',
    answer: NumericInput(correctValue: 195),
    explanation: '260 : 4 = 65, davon 3 Teile: 65 · 3 = 195.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'math_basics_05',
    subCategory: SubCategory.arithmetic,
    prompt: 'Ein Prüfling erhält die Noten 2, 3, 1, 4 und 2. '
        'Wie hoch ist der Notendurchschnitt?',
    answer: NumericInput(correctValue: 2.4, tolerance: 0.01, decimals: 1),
    explanation: 'Summe = 2 + 3 + 1 + 4 + 2 = 12. '
        'Durchschnitt = 12 : 5 = 2,4.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'math_basics_06',
    subCategory: SubCategory.arithmetic,
    prompt: '(−8) + 15 − (−4) = ?',
    answer: NumericInput(correctValue: 11),
    explanation: 'Minus vor Klammer dreht das Vorzeichen: −8 + 15 + 4 = 11.',
    difficulty: Difficulty.medium,
  ),

  // --- Dreisatz ---
  Question(
    id: 'math_three_01',
    subCategory: SubCategory.ruleOfThree,
    prompt: '3 Maschinen produzieren 120 Teile in 4 Stunden. '
        'Wie viele Teile schaffen 5 Maschinen in 6 Stunden?',
    answer: NumericInput(correctValue: 300, unit: 'Teile'),
    explanation: 'Leistung pro Maschine und Stunde: 120 : (3 · 4) = 10 Teile. '
        'Also 5 · 6 · 10 = 300 Teile.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'math_three_02',
    subCategory: SubCategory.ruleOfThree,
    prompt: '12.000 € werden im Verhältnis 3 : 5 aufgeteilt. '
        'Wie groß ist der kleinere Anteil?',
    answer: NumericInput(correctValue: 4500, unit: '€'),
    explanation: 'Insgesamt 3 + 5 = 8 Teile. Ein Teil = 12.000 € : 8 = 1.500 €. '
        'Kleinerer Anteil = 3 · 1.500 € = 4.500 €.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'math_three_03',
    subCategory: SubCategory.ruleOfThree,
    prompt: '4 Arbeiter benötigen für eine Aufgabe 6 Tage. '
        'Wie lange brauchen 3 Arbeiter bei gleicher Leistung?',
    answer: NumericInput(correctValue: 8, unit: 'Tage'),
    explanation: 'Umgekehrter Dreisatz: Insgesamt sind 4 · 6 = 24 Arbeitstage '
        'nötig. Auf 3 Arbeiter verteilt: 24 : 3 = 8 Tage.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'math_three_04',
    subCategory: SubCategory.ruleOfThree,
    prompt: 'Ein Fahrzeug verbraucht 8 Liter auf 100 Kilometer. '
        'Wie viele Liter braucht es für 250 Kilometer?',
    answer: NumericInput(correctValue: 20, unit: 'Liter'),
    explanation: '8 l : 100 km = 0,08 l pro km. 250 km · 0,08 l = 20 Liter.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'math_three_05',
    subCategory: SubCategory.ruleOfThree,
    prompt: '5 Drucker schaffen 200 Seiten in 10 Minuten. '
        'Wie viele Seiten schaffen 8 Drucker in 15 Minuten?',
    answer: MultipleChoice(
      options: ['320', '400', '480', '600'],
      correctIndex: 2,
    ),
    explanation: 'Pro Drucker und Minute: 200 : (5 · 10) = 4 Seiten. '
        'Also 8 · 15 · 4 = 480 Seiten.',
    difficulty: Difficulty.hard,
  ),

  // --- Prozentrechnung ---
  Question(
    id: 'math_percent_01',
    subCategory: SubCategory.percentage,
    prompt: 'Ein Artikel kostet 80 €. Der Preis wird um 15 % gesenkt. '
        'Wie hoch ist der neue Preis?',
    answer: NumericInput(correctValue: 68, tolerance: 0.01, unit: '€'),
    explanation: '15 % von 80 € = 12 €. Neuer Preis: 80 € − 12 € = 68 €.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'math_percent_02',
    subCategory: SubCategory.percentage,
    prompt: 'Nach einer Erhöhung um 20 % kostet ein Ticket 54 €. '
        'Wie hoch war der ursprüngliche Preis?',
    answer: NumericInput(correctValue: 45, tolerance: 0.01, unit: '€'),
    explanation: 'Der neue Preis entspricht 120 % des alten: 54 € : 1,2 = 45 €. '
        'Achtung: 54 € − 20 % wäre falsch.',
    difficulty: Difficulty.hard,
  ),
  Question(
    id: 'math_percent_03',
    subCategory: SubCategory.percentage,
    prompt: '5.000 € werden mit 3 % pro Jahr verzinst. '
        'Wie hoch sind die Zinsen nach 2 Jahren ohne Zinseszins?',
    answer: NumericInput(correctValue: 300, tolerance: 0.01, unit: '€'),
    explanation: '3 % von 5.000 € = 150 € pro Jahr. Nach 2 Jahren: 300 €.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'math_percent_04',
    subCategory: SubCategory.percentage,
    prompt: 'Ein Laptop kostet 900 €. Es werden 10 % Rabatt gewährt, '
        'auf den Rabattpreis zusätzlich 2 % Skonto. '
        'Wie hoch ist der Endpreis?',
    answer: NumericInput(
      correctValue: 793.80,
      tolerance: 0.01,
      decimals: 2,
      unit: '€',
    ),
    explanation: '900 € − 10 % = 810 €. Davon 2 % Skonto: 810 € · 0,98 = '
        '793,80 €. Die Prozentsätze dürfen nicht addiert werden.',
    difficulty: Difficulty.hard,
  ),
  Question(
    id: 'math_percent_05',
    subCategory: SubCategory.percentage,
    prompt: 'Von 250 Bewerbern bestehen 18 % den Einstellungstest. '
        'Wie viele Bewerber sind das?',
    answer: MultipleChoice(
      options: ['36', '40', '45', '52'],
      correctIndex: 2,
    ),
    explanation: '18 % von 250 = 250 · 0,18 = 45 Bewerber.',
    difficulty: Difficulty.medium,
  ),

  // --- Textaufgaben ---
  Question(
    id: 'math_word_01',
    subCategory: SubCategory.wordProblems,
    prompt: 'Ein Zug legt 210 km in 2,5 Stunden zurück. '
        'Wie hoch ist die Durchschnittsgeschwindigkeit?',
    answer: NumericInput(correctValue: 84, unit: 'km/h'),
    explanation: 'Geschwindigkeit = Strecke : Zeit = 210 km : 2,5 h = 84 km/h.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'math_word_02',
    subCategory: SubCategory.wordProblems,
    prompt: 'Ein Handwerker benötigt 45 Minuten pro Fenster. '
        'Wie viele Fenster schafft er in 6 Stunden?',
    answer: NumericInput(correctValue: 8, unit: 'Fenster'),
    explanation: '6 Stunden = 360 Minuten. 360 : 45 = 8 Fenster.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'math_word_03',
    subCategory: SubCategory.wordProblems,
    prompt: 'Ein rechteckiges Grundstück ist 24 m lang und 15 m breit. '
        'Wie groß ist die Fläche?',
    answer: NumericInput(correctValue: 360, unit: 'm²'),
    explanation: 'Fläche = Länge · Breite = 24 m · 15 m = 360 m². '
        '78 m wäre der Umfang.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'math_word_04',
    subCategory: SubCategory.wordProblems,
    prompt: 'Ein Tank fasst 480 Liter und wird mit 16 Litern pro Minute '
        'befüllt. Wie lange dauert die vollständige Befüllung?',
    answer: NumericInput(correctValue: 30, unit: 'Minuten'),
    explanation: '480 l : 16 l/min = 30 Minuten.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'math_word_05',
    subCategory: SubCategory.wordProblems,
    prompt: 'Drei Kollegen teilen sich eine 24-Stunden-Schicht zu gleichen '
        'Teilen. Einer übernimmt zusätzlich 2 Stunden. Wie lange arbeitet er?',
    answer: MultipleChoice(
      options: ['9 Stunden', '10 Stunden', '11 Stunden', '12 Stunden'],
      correctIndex: 1,
    ),
    explanation: '24 h : 3 = 8 h pro Person. Mit den 2 Zusatzstunden: 10 h.',
    difficulty: Difficulty.medium,
  ),
];
