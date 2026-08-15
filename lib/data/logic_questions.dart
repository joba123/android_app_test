import 'package:einstellungstest_trainer/models/question.dart';
import 'package:einstellungstest_trainer/models/training_module.dart';

/// Feinthemen des Moduls Logisches Denken.
abstract final class LogicTopics {
  static const sequences = 'Zahlenreihen';
  static const analogies = 'Analogien & Wortlogik';
  static const patterns = 'Muster & Schlussfolgerungen';

  static const all = [sequences, analogies, patterns];
}

/// Startpool Logisches Denken.
const List<Question> logicQuestions = [
  // --- Zahlenreihen ---
  Question(
    id: 'logic_seq_01',
    module: TrainingModule.logic,
    topic: LogicTopics.sequences,
    prompt: 'Wie geht die Reihe weiter?\n2, 4, 8, 16, ?',
    options: ['24', '30', '32', '64'],
    correctIndex: 2,
    explanation: 'Jede Zahl ist das Doppelte der vorherigen: 16 · 2 = 32.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'logic_seq_02',
    module: TrainingModule.logic,
    topic: LogicTopics.sequences,
    prompt: 'Wie geht die Reihe weiter?\n3, 6, 11, 18, 27, ?',
    options: ['36', '38', '40', '42'],
    correctIndex: 1,
    explanation: 'Die Abstände wachsen: +3, +5, +7, +9, also als Nächstes +11. '
        '27 + 11 = 38.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'logic_seq_03',
    module: TrainingModule.logic,
    topic: LogicTopics.sequences,
    prompt: 'Wie geht die Reihe weiter?\n81, 27, 9, 3, ?',
    options: ['0', '1', '2', '3'],
    correctIndex: 1,
    explanation: 'Jede Zahl wird durch 3 geteilt: 3 : 3 = 1.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'logic_seq_04',
    module: TrainingModule.logic,
    topic: LogicTopics.sequences,
    prompt: 'Wie geht die Reihe weiter?\n1, 1, 2, 3, 5, 8, ?',
    options: ['11', '12', '13', '15'],
    correctIndex: 2,
    explanation: 'Fibonacci-Folge: Jede Zahl ist die Summe der beiden '
        'vorherigen. 5 + 8 = 13.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'logic_seq_05',
    module: TrainingModule.logic,
    topic: LogicTopics.sequences,
    prompt: 'Wie geht die Buchstabenreihe weiter?\nA, C, F, J, ?',
    options: ['M', 'N', 'O', 'P'],
    correctIndex: 2,
    explanation: 'Die Sprünge im Alphabet wachsen: +2, +3, +4, also nun +5. '
        'J (10. Buchstabe) + 5 = 15. Buchstabe = O.',
    difficulty: Difficulty.hard,
  ),
  Question(
    id: 'logic_seq_06',
    module: TrainingModule.logic,
    topic: LogicTopics.sequences,
    prompt: 'Wie geht die Buchstabenreihe weiter?\nZ, X, V, T, ?',
    options: ['Q', 'R', 'S', 'U'],
    correctIndex: 1,
    explanation: 'Rückwärts im Alphabet, immer ein Buchstabe übersprungen: '
        'Z, X, V, T, R.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'logic_seq_07',
    module: TrainingModule.logic,
    topic: LogicTopics.sequences,
    prompt: 'Wie geht die Reihe weiter?\n100, 92, 85, 79, ?',
    options: ['72', '73', '74', '75'],
    correctIndex: 2,
    explanation: 'Die Abstände schrumpfen: −8, −7, −6, also nun −5. '
        '79 − 5 = 74.',
    difficulty: Difficulty.medium,
  ),

  // --- Analogien & Wortlogik ---
  Question(
    id: 'logic_ana_01',
    module: TrainingModule.logic,
    topic: LogicTopics.analogies,
    prompt: 'Arzt verhält sich zu Krankenhaus wie Lehrer zu …?',
    options: ['Klasse', 'Schule', 'Buch', 'Schüler'],
    correctIndex: 1,
    explanation: 'Das Verhältnis ist "Beruf : Arbeitsstätte". '
        'Die Arbeitsstätte einer Lehrkraft ist die Schule.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'logic_ana_02',
    module: TrainingModule.logic,
    topic: LogicTopics.analogies,
    prompt: 'Auge verhält sich zu sehen wie Ohr zu …?',
    options: ['riechen', 'hören', 'sprechen', 'fühlen'],
    correctIndex: 1,
    explanation: 'Das Verhältnis ist "Sinnesorgan : zugehörige Wahrnehmung". '
        'Mit dem Ohr wird gehört.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'logic_ana_03',
    module: TrainingModule.logic,
    topic: LogicTopics.analogies,
    prompt: 'Hand verhält sich zu Finger wie Fuß zu …?',
    options: ['Bein', 'Ferse', 'Zehe', 'Knie'],
    correctIndex: 2,
    explanation: 'Das Verhältnis ist "Körperteil : dessen Endglieder". '
        'Zur Hand gehören Finger, zum Fuß Zehen.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'logic_ana_04',
    module: TrainingModule.logic,
    topic: LogicTopics.analogies,
    prompt: 'Kilometer verhält sich zu Entfernung wie Kilogramm zu …?',
    options: ['Volumen', 'Gewicht', 'Länge', 'Zeit'],
    correctIndex: 1,
    explanation: 'Das Verhältnis ist "Einheit : gemessene Größe". '
        'Kilogramm misst das Gewicht bzw. die Masse.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'logic_ana_05',
    module: TrainingModule.logic,
    topic: LogicTopics.analogies,
    prompt: 'Welcher Begriff passt nicht in die Reihe?',
    options: ['Hammer', 'Zange', 'Schraubendreher', 'Nagel'],
    correctIndex: 3,
    explanation: 'Hammer, Zange und Schraubendreher sind Werkzeuge. '
        'Der Nagel ist Material, das damit verarbeitet wird.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'logic_ana_06',
    module: TrainingModule.logic,
    topic: LogicTopics.analogies,
    prompt: 'Welcher Begriff passt nicht in die Reihe?',
    options: ['Amsel', 'Spatz', 'Fledermaus', 'Meise'],
    correctIndex: 2,
    explanation: 'Amsel, Spatz und Meise sind Vögel. '
        'Die Fledermaus ist ein Säugetier.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'logic_ana_07',
    module: TrainingModule.logic,
    topic: LogicTopics.analogies,
    prompt: 'Welcher Begriff passt nicht in die Reihe?',
    options: ['Deutschland', 'Frankreich', 'Berlin', 'Italien'],
    correctIndex: 2,
    explanation: 'Deutschland, Frankreich und Italien sind Staaten. '
        'Berlin ist eine Stadt.',
    difficulty: Difficulty.easy,
  ),

  // --- Muster & Schlussfolgerungen ---
  Question(
    id: 'logic_pat_01',
    module: TrainingModule.logic,
    topic: LogicTopics.patterns,
    prompt: 'Gegeben: "Alle Rosen sind Blumen." und '
        '"Einige Blumen verwelken schnell."\n'
        'Welche Aussage folgt zwingend?',
    options: [
      'Alle Rosen verwelken schnell.',
      'Einige Rosen verwelken schnell.',
      'Keine Rose verwelkt schnell.',
      'Keine der Aussagen folgt zwingend.',
    ],
    correctIndex: 3,
    explanation: 'Die schnell verwelkenden Blumen müssen keine Rosen sein. '
        'Aus den beiden Sätzen lässt sich über Rosen nichts Zwingendes ableiten.',
    difficulty: Difficulty.hard,
  ),
  Question(
    id: 'logic_pat_02',
    module: TrainingModule.logic,
    topic: LogicTopics.patterns,
    prompt: 'Gegeben: "Alle Mitarbeitenden dieser Abteilung tragen einen '
        'Dienstausweis." und "Herr Müller trägt keinen Dienstausweis."\n'
        'Welche Aussage folgt zwingend?',
    options: [
      'Herr Müller arbeitet nicht in dieser Abteilung.',
      'Herr Müller hat seinen Ausweis vergessen.',
      'Herr Müller ist neu in der Abteilung.',
      'Keine der Aussagen folgt zwingend.',
    ],
    correctIndex: 0,
    explanation: 'Würde Herr Müller zur Abteilung gehören, müsste er laut '
        'erster Aussage einen Ausweis tragen. Da er keinen trägt, gehört er '
        'nicht dazu.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'logic_pat_03',
    module: TrainingModule.logic,
    topic: LogicTopics.patterns,
    prompt: 'Gegeben: "Kein Fahrzeug in der Halle ist rot." und '
        '"Einige Fahrzeuge in der Halle sind Transporter."\n'
        'Welche Aussage folgt zwingend?',
    options: [
      'Alle Transporter sind rot.',
      'Kein Transporter in der Halle ist rot.',
      'Einige Transporter in der Halle sind rot.',
      'Keine der Aussagen folgt zwingend.',
    ],
    correctIndex: 1,
    explanation: 'Transporter in der Halle sind Fahrzeuge in der Halle. '
        'Da kein Fahrzeug dort rot ist, kann auch kein Transporter dort rot sein.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'logic_pat_04',
    module: TrainingModule.logic,
    topic: LogicTopics.patterns,
    prompt: 'Wie setzt sich das Muster fort?\n'
        'Kreis, Dreieck, Quadrat, Kreis, Dreieck, ?',
    options: ['Kreis', 'Dreieck', 'Quadrat', 'Fünfeck'],
    correctIndex: 2,
    explanation: 'Die drei Formen wiederholen sich in fester Reihenfolge. '
        'Nach Dreieck folgt wieder Quadrat.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'logic_pat_05',
    module: TrainingModule.logic,
    topic: LogicTopics.patterns,
    prompt: 'Welcher Buchstabe steht im Wort VERWALTUNG '
        'an vierter Stelle von hinten?',
    options: ['L', 'T', 'U', 'N'],
    correctIndex: 1,
    explanation: 'VERWALTUNG hat 10 Buchstaben. Von hinten gezählt: '
        'G (1), N (2), U (3), T (4).',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'logic_pat_06',
    module: TrainingModule.logic,
    topic: LogicTopics.patterns,
    prompt: 'Fünf Personen stehen in einer Reihe. Anna steht direkt vor Ben, '
        'Ben direkt vor Clara. Dora steht ganz vorne, Emil ganz hinten.\n'
        'An welcher Position steht Ben?',
    options: ['2', '3', '4', 'Nicht bestimmbar'],
    correctIndex: 1,
    explanation: 'Dora belegt Position 1, Emil Position 5. '
        'Anna, Ben und Clara füllen zusammenhängend die Positionen 2, 3 und 4 – '
        'Ben steht damit auf Position 3.',
    difficulty: Difficulty.hard,
  ),
];
