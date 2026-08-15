import 'package:einstellungstest_trainer/models/question.dart';
import 'package:einstellungstest_trainer/models/training_module.dart';

/// Feinthemen des Moduls Mathematik. Die Testsimulation baut ihre Teile
/// aus genau diesen Themen auf.
abstract final class MathTopics {
  static const basics = 'Grundrechenarten';
  static const percentage = 'Dreisatz & Prozent';
  static const wordProblems = 'Textaufgaben';

  static const all = [basics, percentage, wordProblems];
}

/// Startpool Mathematik.
///
/// Antwortoptionen sind bewusst aufsteigend sortiert notiert - das Mischen
/// uebernimmt die QuestionRepository zur Laufzeit, damit keine Positions-
/// gewohnheiten entstehen.
const List<Question> mathQuestions = [
  // --- Grundrechenarten ---
  Question(
    id: 'math_basics_01',
    module: TrainingModule.math,
    topic: MathTopics.basics,
    prompt: '17 · 24 = ?',
    options: ['388', '398', '408', '418'],
    correctIndex: 2,
    explanation: '17 · 24 = 17 · 20 + 17 · 4 = 340 + 68 = 408.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'math_basics_02',
    module: TrainingModule.math,
    topic: MathTopics.basics,
    prompt: '144 : 12 + 7 · 3 = ?',
    options: ['29', '31', '33', '35'],
    correctIndex: 2,
    explanation: 'Punkt vor Strich: 144 : 12 = 12 und 7 · 3 = 21. '
        'Erst danach addieren: 12 + 21 = 33.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'math_basics_03',
    module: TrainingModule.math,
    topic: MathTopics.basics,
    prompt: 'Wie viele Sekunden hat 1 Stunde und 15 Minuten?',
    options: ['4.200', '4.500', '4.800', '5.400'],
    correctIndex: 1,
    explanation: '75 Minuten · 60 Sekunden = 4.500 Sekunden.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'math_basics_04',
    module: TrainingModule.math,
    topic: MathTopics.basics,
    prompt: 'Wie viel sind drei Viertel von 260?',
    options: ['180', '190', '195', '205'],
    correctIndex: 2,
    explanation: '260 : 4 = 65, davon 3 Teile: 65 · 3 = 195.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'math_basics_05',
    module: TrainingModule.math,
    topic: MathTopics.basics,
    prompt: 'Ein Prüfling erhält die Noten 2, 3, 1, 4 und 2. '
        'Wie hoch ist der Notendurchschnitt?',
    options: ['2,2', '2,4', '2,6', '2,8'],
    correctIndex: 1,
    explanation: 'Summe = 2 + 3 + 1 + 4 + 2 = 12. '
        'Durchschnitt = 12 : 5 = 2,4.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'math_basics_06',
    module: TrainingModule.math,
    topic: MathTopics.basics,
    prompt: '(−8) + 15 − (−4) = ?',
    options: ['3', '7', '11', '19'],
    correctIndex: 2,
    explanation: 'Minus vor Klammer dreht das Vorzeichen: '
        '−8 + 15 + 4 = 11.',
    difficulty: Difficulty.medium,
  ),

  // --- Dreisatz & Prozent ---
  Question(
    id: 'math_percent_01',
    module: TrainingModule.math,
    topic: MathTopics.percentage,
    prompt: '3 Maschinen produzieren 120 Teile in 4 Stunden. '
        'Wie viele Teile schaffen 5 Maschinen in 6 Stunden?',
    options: ['240', '280', '300', '360'],
    correctIndex: 2,
    explanation: 'Leistung pro Maschine und Stunde: '
        '120 : (3 · 4) = 10 Teile. '
        'Also 5 · 6 · 10 = 300 Teile.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'math_percent_02',
    module: TrainingModule.math,
    topic: MathTopics.percentage,
    prompt: 'Ein Artikel kostet 80 €. Der Preis wird um 15 % gesenkt. '
        'Wie hoch ist der neue Preis?',
    options: ['65 €', '68 €', '72 €', '75 €'],
    correctIndex: 1,
    explanation: '15 % von 80 € = 12 €. '
        'Neuer Preis: 80 € − 12 € = 68 €.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'math_percent_03',
    module: TrainingModule.math,
    topic: MathTopics.percentage,
    prompt: 'Nach einer Erhöhung um 20 % kostet ein Ticket 54 €. '
        'Wie hoch war der ursprüngliche Preis?',
    options: ['43,20 €', '45,00 €', '46,50 €', '48,00 €'],
    correctIndex: 1,
    explanation: 'Der neue Preis entspricht 120 % des alten. '
        '54 € : 1,2 = 45 €. '
        'Achtung: 54 € − 20 % wäre falsch.',
    difficulty: Difficulty.hard,
  ),
  Question(
    id: 'math_percent_04',
    module: TrainingModule.math,
    topic: MathTopics.percentage,
    prompt: '5.000 € werden mit 3 % pro Jahr verzinst. '
        'Wie hoch sind die Zinsen nach 2 Jahren ohne Zinseszins?',
    options: ['150 €', '300 €', '309 €', '450 €'],
    correctIndex: 1,
    explanation: '3 % von 5.000 € = 150 € pro Jahr. '
        'Nach 2 Jahren: 2 · 150 € = 300 €.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'math_percent_05',
    module: TrainingModule.math,
    topic: MathTopics.percentage,
    prompt: 'Ein Laptop kostet 900 €. Es werden 10 % Rabatt gewährt, '
        'auf den Rabattpreis zusätzlich 2 % Skonto. Wie hoch ist der Endpreis?',
    options: ['792,00 €', '793,80 €', '795,60 €', '810,00 €'],
    correctIndex: 1,
    explanation: '900 € − 10 % = 810 €. '
        'Davon 2 % Skonto: 810 € · 0,98 = 793,80 €. '
        'Die Prozentsätze dürfen nicht addiert werden.',
    difficulty: Difficulty.hard,
  ),
  Question(
    id: 'math_percent_06',
    module: TrainingModule.math,
    topic: MathTopics.percentage,
    prompt: '12.000 € werden im Verhältnis 3 : 5 aufgeteilt. '
        'Wie groß ist der kleinere Anteil?',
    options: ['3.600 €', '4.000 €', '4.500 €', '4.800 €'],
    correctIndex: 2,
    explanation: 'Insgesamt 3 + 5 = 8 Teile. '
        'Ein Teil = 12.000 € : 8 = 1.500 €. '
        'Kleinerer Anteil = 3 · 1.500 € = 4.500 €.',
    difficulty: Difficulty.medium,
  ),

  // --- Textaufgaben ---
  Question(
    id: 'math_word_01',
    module: TrainingModule.math,
    topic: MathTopics.wordProblems,
    prompt: 'Ein Zug legt 210 km in 2,5 Stunden zurück. '
        'Wie hoch ist die Durchschnittsgeschwindigkeit?',
    options: ['78 km/h', '82 km/h', '84 km/h', '88 km/h'],
    correctIndex: 2,
    explanation: 'Geschwindigkeit = Strecke : Zeit = 210 km : 2,5 h = 84 km/h.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'math_word_02',
    module: TrainingModule.math,
    topic: MathTopics.wordProblems,
    prompt: 'Ein Handwerker benötigt 45 Minuten pro Fenster. '
        'Wie viele Fenster schafft er in 6 Stunden?',
    options: ['6', '7', '8', '9'],
    correctIndex: 2,
    explanation: '6 Stunden = 360 Minuten. '
        '360 : 45 = 8 Fenster.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'math_word_03',
    module: TrainingModule.math,
    topic: MathTopics.wordProblems,
    prompt: 'Ein rechteckiges Grundstück ist 24 m lang und 15 m breit. '
        'Wie groß ist die Fläche?',
    options: ['78 m²', '320 m²', '360 m²', '380 m²'],
    correctIndex: 2,
    explanation: 'Fläche = Länge · Breite = 24 m · 15 m = 360 m². '
        '78 m wäre der Umfang.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'math_word_04',
    module: TrainingModule.math,
    topic: MathTopics.wordProblems,
    prompt: 'Ein Tank fasst 480 Liter und wird mit 16 Litern pro Minute befüllt. '
        'Wie lange dauert die vollständige Befüllung?',
    options: ['24 Minuten', '28 Minuten', '30 Minuten', '32 Minuten'],
    correctIndex: 2,
    explanation: '480 l : 16 l/min = 30 Minuten.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'math_word_05',
    module: TrainingModule.math,
    topic: MathTopics.wordProblems,
    prompt: 'Drei Kollegen teilen sich eine 24-Stunden-Schicht zu gleichen Teilen. '
        'Einer übernimmt zusätzlich 2 Stunden. Wie lange arbeitet er?',
    options: ['9 Stunden', '10 Stunden', '11 Stunden', '12 Stunden'],
    correctIndex: 1,
    explanation: '24 h : 3 = 8 h pro Person. '
        'Mit den 2 Zusatzstunden: 8 h + 2 h = 10 h.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'math_word_06',
    module: TrainingModule.math,
    topic: MathTopics.wordProblems,
    prompt: 'Von 250 Bewerbern bestehen 18 % den Einstellungstest. '
        'Wie viele Bewerber sind das?',
    options: ['36', '40', '45', '52'],
    correctIndex: 2,
    explanation: '18 % von 250 = 250 · 0,18 = 45 Bewerber.',
    difficulty: Difficulty.medium,
  ),
];
