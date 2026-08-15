import 'package:einstellungstest_trainer/models/question.dart';
import 'package:einstellungstest_trainer/models/sub_category.dart';

/// Startpool Logisches Denken – handgeschrieben, durchgängig Multiple Choice.
///
/// Zu den Figurenanalogien: Im echten Test sind das Bildaufgaben. Solange
/// keine Grafiken vorliegen, sind die Figuren hier sprachlich beschrieben. Die
/// Aufgabenlogik ist dieselbe; sobald Bilder da sind, wird bei der jeweiligen
/// Aufgabe `imageAsset` gesetzt und der beschreibende Teil des Aufgabentextes
/// gekürzt.
const List<Question> logicQuestions = [
  // ---------------------------------------------------------------
  // Zahlenreihen
  // ---------------------------------------------------------------
  Question(
    id: 'logic_seq_01',
    subCategory: SubCategory.numberSequences,
    prompt: 'Wie geht die Reihe weiter?\n2, 4, 8, 16, ?',
    answer: MultipleChoice(options: ['24', '30', '32', '64'], correctIndex: 2),
    explanation: 'Jede Zahl ist das Doppelte der vorherigen: 16 · 2 = 32.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'logic_seq_02',
    subCategory: SubCategory.numberSequences,
    prompt: 'Wie geht die Reihe weiter?\n3, 6, 11, 18, 27, ?',
    answer: MultipleChoice(options: ['36', '38', '40', '42'], correctIndex: 1),
    explanation: 'Die Abstände wachsen: +3, +5, +7, +9, also als Nächstes +11. '
        '27 + 11 = 38.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'logic_seq_03',
    subCategory: SubCategory.numberSequences,
    prompt: 'Wie geht die Reihe weiter?\n81, 27, 9, 3, ?',
    answer: MultipleChoice(options: ['0', '1', '2', '3'], correctIndex: 1),
    explanation: 'Jede Zahl wird durch 3 geteilt: 3 : 3 = 1.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'logic_seq_04',
    subCategory: SubCategory.numberSequences,
    prompt: 'Wie geht die Reihe weiter?\n1, 1, 2, 3, 5, 8, ?',
    answer: MultipleChoice(options: ['11', '12', '13', '15'], correctIndex: 2),
    explanation: 'Fibonacci-Folge: Jede Zahl ist die Summe der beiden '
        'vorherigen. 5 + 8 = 13.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'logic_seq_05',
    subCategory: SubCategory.numberSequences,
    prompt: 'Wie geht die Reihe weiter?\n100, 92, 85, 79, ?',
    answer: MultipleChoice(options: ['72', '73', '74', '75'], correctIndex: 2),
    explanation: 'Die Abstände schrumpfen: −8, −7, −6, also nun −5. '
        '79 − 5 = 74.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'logic_seq_06',
    subCategory: SubCategory.numberSequences,
    prompt: 'Wie geht die Reihe weiter?\n7, 14, 21, 28, ?',
    answer: MultipleChoice(options: ['32', '35', '36', '42'], correctIndex: 1),
    explanation: 'Es wird jeweils 7 addiert: 28 + 7 = 35.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'logic_seq_07',
    subCategory: SubCategory.numberSequences,
    prompt: 'Wie geht die Reihe weiter?\n2, 5, 11, 23, ?',
    answer: MultipleChoice(options: ['35', '41', '46', '47'], correctIndex: 3),
    explanation: 'Jede Zahl wird verdoppelt und um 1 erhöht: '
        '23 · 2 + 1 = 47.',
    difficulty: Difficulty.hard,
  ),
  Question(
    id: 'logic_seq_08',
    subCategory: SubCategory.numberSequences,
    prompt: 'Wie geht die Reihe weiter?\n1, 4, 9, 16, 25, ?',
    answer: MultipleChoice(options: ['30', '32', '36', '49'], correctIndex: 2),
    explanation: 'Das sind die Quadratzahlen: 1², 2², 3², 4², 5². '
        'Als Nächstes 6² = 36.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'logic_seq_09',
    subCategory: SubCategory.numberSequences,
    prompt: 'Wie geht die Reihe weiter?\n1, 8, 27, 64, ?',
    answer: MultipleChoice(options: ['81', '100', '125', '216'], correctIndex: 2),
    explanation: 'Das sind die Kubikzahlen: 1³, 2³, 3³, 4³. '
        'Als Nächstes 5³ = 125.',
    difficulty: Difficulty.hard,
  ),
  Question(
    id: 'logic_seq_10',
    subCategory: SubCategory.numberSequences,
    prompt: 'Wie geht die Reihe weiter?\n720, 360, 120, 30, ?',
    answer: MultipleChoice(options: ['5', '6', '10', '15'], correctIndex: 1),
    explanation: 'Die Teiler wachsen: : 2, : 3, : 4, also nun : 5. '
        '30 : 5 = 6.',
    difficulty: Difficulty.hard,
  ),
  Question(
    id: 'logic_seq_11',
    subCategory: SubCategory.numberSequences,
    prompt: 'Wie geht die Reihe weiter?\n2, 6, 12, 20, 30, ?',
    answer: MultipleChoice(options: ['36', '40', '42', '44'], correctIndex: 2),
    explanation: 'Die Abstände wachsen um jeweils 2: +4, +6, +8, +10, '
        'also nun +12. 30 + 12 = 42.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'logic_seq_12',
    subCategory: SubCategory.numberSequences,
    prompt: 'Wie geht die Reihe weiter?\n2, 3, 5, 7, 11, ?',
    answer: MultipleChoice(options: ['12', '13', '14', '15'], correctIndex: 1),
    explanation: 'Das sind die Primzahlen der Reihe nach. '
        'Nach 11 folgt 13.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'logic_seq_13',
    subCategory: SubCategory.numberSequences,
    prompt: 'Wie geht die Reihe weiter?\n12, 10, 13, 11, 14, ?',
    answer: MultipleChoice(options: ['11', '12', '15', '17'], correctIndex: 1),
    explanation: 'Es wechseln sich −2 und +3 ab. Nach dem +3 auf 14 folgt '
        'wieder −2: 14 − 2 = 12.',
    difficulty: Difficulty.hard,
  ),
  Question(
    id: 'logic_seq_14',
    subCategory: SubCategory.numberSequences,
    prompt: 'Wie geht die Reihe weiter?\n1, 2, 6, 24, ?',
    answer: MultipleChoice(options: ['48', '96', '120', '144'], correctIndex: 2),
    explanation: 'Die Faktoren wachsen: · 2, · 3, · 4, also nun · 5. '
        '24 · 5 = 120.',
    difficulty: Difficulty.hard,
  ),
  Question(
    id: 'logic_seq_15',
    subCategory: SubCategory.numberSequences,
    prompt: 'Wie geht die Reihe weiter?\n64, 32, 16, 8, ?',
    answer: MultipleChoice(options: ['2', '4', '6', '0'], correctIndex: 1),
    explanation: 'Jede Zahl wird halbiert: 8 : 2 = 4.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'logic_seq_16',
    subCategory: SubCategory.numberSequences,
    prompt: 'Wie geht die Reihe weiter?\n3, 9, 27, 81, ?',
    answer: MultipleChoice(options: ['162', '216', '243', '324'], correctIndex: 2),
    explanation: 'Jede Zahl wird mit 3 multipliziert: 81 · 3 = 243.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'logic_seq_17',
    subCategory: SubCategory.numberSequences,
    prompt: 'Wie geht die Reihe weiter?\n17, 20, 24, 29, ?',
    answer: MultipleChoice(options: ['33', '34', '35', '36'], correctIndex: 2),
    explanation: 'Die Abstände wachsen: +3, +4, +5, also nun +6. '
        '29 + 6 = 35.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'logic_seq_18',
    subCategory: SubCategory.numberSequences,
    prompt: 'Wie geht die Reihe weiter?\n50, 47, 41, 32, ?',
    answer: MultipleChoice(options: ['18', '20', '22', '24'], correctIndex: 1),
    explanation: 'Die Abstände wachsen um jeweils 3: −3, −6, −9, '
        'also nun −12. 32 − 12 = 20.',
    difficulty: Difficulty.hard,
  ),
  Question(
    id: 'logic_seq_19',
    subCategory: SubCategory.numberSequences,
    prompt: 'Wie geht die Reihe weiter?\n6, 12, 11, 22, 21, ?',
    answer: MultipleChoice(options: ['20', '31', '42', '43'], correctIndex: 2),
    explanation: 'Es wechseln sich · 2 und − 1 ab. Nach der −1 auf 21 folgt '
        'wieder · 2: 21 · 2 = 42.',
    difficulty: Difficulty.hard,
  ),
  Question(
    id: 'logic_seq_20',
    subCategory: SubCategory.numberSequences,
    prompt: 'Wie geht die Reihe weiter?\n100, 50, 52, 26, 28, ?',
    answer: MultipleChoice(options: ['13', '14', '26', '30'], correctIndex: 1),
    explanation: 'Es wechseln sich : 2 und + 2 ab. Nach dem +2 auf 28 folgt '
        'wieder : 2: 28 : 2 = 14.',
    difficulty: Difficulty.hard,
  ),
  Question(
    id: 'logic_seq_21',
    subCategory: SubCategory.numberSequences,
    prompt: 'Wie geht die Buchstabenreihe weiter?\nA, C, F, J, ?',
    answer: MultipleChoice(options: ['M', 'N', 'O', 'P'], correctIndex: 2),
    explanation: 'Die Sprünge im Alphabet wachsen: +2, +3, +4, also nun +5. '
        'J ist der 10. Buchstabe, der 15. ist O.',
    difficulty: Difficulty.hard,
  ),
  Question(
    id: 'logic_seq_22',
    subCategory: SubCategory.numberSequences,
    prompt: 'Wie geht die Buchstabenreihe weiter?\nZ, X, V, T, ?',
    answer: MultipleChoice(options: ['Q', 'R', 'S', 'U'], correctIndex: 1),
    explanation: 'Rückwärts im Alphabet, immer ein Buchstabe übersprungen: '
        'Z, X, V, T, R.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'logic_seq_23',
    subCategory: SubCategory.numberSequences,
    prompt: 'Wie geht die Buchstabenreihe weiter?\nB, D, G, K, ?',
    answer: MultipleChoice(options: ['N', 'O', 'P', 'Q'], correctIndex: 2),
    explanation: 'B ist der 2., D der 4., G der 7., K der 11. Buchstabe. '
        'Die Sprünge wachsen: +2, +3, +4, also nun +5 auf den 16. '
        'Buchstaben: P.',
    difficulty: Difficulty.hard,
  ),

  // ---------------------------------------------------------------
  // Figurenanalogien (sprachlich beschrieben, Bilder folgen)
  // ---------------------------------------------------------------
  Question(
    id: 'logic_fig_01',
    subCategory: SubCategory.figureAnalogies,
    prompt: 'Wie setzt sich das Muster fort?\n'
        'Kreis, Dreieck, Quadrat, Kreis, Dreieck, ?',
    answer: MultipleChoice(
      options: ['Kreis', 'Dreieck', 'Quadrat', 'Fünfeck'],
      correctIndex: 2,
    ),
    explanation: 'Die drei Formen wiederholen sich in fester Reihenfolge. '
        'Nach Dreieck folgt wieder Quadrat.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'logic_fig_02',
    subCategory: SubCategory.figureAnalogies,
    prompt: 'Quadrat verhält sich zu Würfel wie Kreis zu …?',
    answer: MultipleChoice(
      options: ['Ellipse', 'Kugel', 'Zylinder', 'Kegel'],
      correctIndex: 1,
    ),
    explanation: 'Das Verhältnis ist "flache Figur : zugehöriger Körper". '
        'Der Körper zum Kreis ist die Kugel.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'logic_fig_03',
    subCategory: SubCategory.figureAnalogies,
    prompt: 'Dreieck verhält sich zu Sechseck wie Viereck zu …?',
    answer: MultipleChoice(
      options: ['Fünfeck', 'Sechseck', 'Achteck', 'Zehneck'],
      correctIndex: 2,
    ),
    explanation: 'Die Eckenzahl verdoppelt sich: 3 wird zu 6, also 4 zu 8. '
        'Das Achteck hat acht Ecken.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'logic_fig_04',
    subCategory: SubCategory.figureAnalogies,
    prompt: 'Ein Pfeil zeigt nach oben. Er wird zuerst um 90° im '
        'Uhrzeigersinn gedreht, danach um weitere 180°.\n'
        'In welche Richtung zeigt er jetzt?',
    answer: MultipleChoice(
      options: ['nach oben', 'nach rechts', 'nach unten', 'nach links'],
      correctIndex: 3,
    ),
    explanation: '90° im Uhrzeigersinn: aus "oben" wird "rechts". '
        'Weitere 180°: aus "rechts" wird "links".',
    difficulty: Difficulty.hard,
  ),
  Question(
    id: 'logic_fig_05',
    subCategory: SubCategory.figureAnalogies,
    prompt: 'Ein Quadrat wird entlang einer Diagonale durchgeschnitten.\n'
        'Welche Figuren entstehen?',
    answer: MultipleChoice(
      options: ['zwei Rechtecke', 'zwei Dreiecke', 'zwei Trapeze', 'zwei Rauten'],
      correctIndex: 1,
    ),
    explanation: 'Die Diagonale verbindet zwei gegenüberliegende Ecken. '
        'Es entstehen zwei rechtwinklige Dreiecke.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'logic_fig_06',
    subCategory: SubCategory.figureAnalogies,
    prompt: 'Eine Bilderreihe zeigt Felder mit Punkten:\n'
        '1 Punkt, 2 Punkte, 4 Punkte, 8 Punkte, ?\n'
        'Wie viele Punkte hat das nächste Feld?',
    answer: MultipleChoice(
      options: ['10', '12', '16', '24'],
      correctIndex: 2,
    ),
    explanation: 'Die Punktzahl verdoppelt sich von Feld zu Feld: '
        '8 · 2 = 16.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'logic_fig_07',
    subCategory: SubCategory.figureAnalogies,
    prompt: 'Die Reihe zeigt Viereck, Fünfeck, Sechseck.\n'
        'Welche Figur folgt?',
    answer: MultipleChoice(
      options: ['Dreieck', 'Siebeneck', 'Achteck', 'Kreis'],
      correctIndex: 1,
    ),
    explanation: 'Die Eckenzahl steigt um jeweils eins: 4, 5, 6, also 7. '
        'Es folgt das Siebeneck.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'logic_fig_08',
    subCategory: SubCategory.figureAnalogies,
    prompt: 'Wie viele Diagonalen hat ein Viereck?',
    answer: MultipleChoice(
      options: ['1', '2', '3', '4'],
      correctIndex: 1,
    ),
    explanation: 'Diagonalen verbinden nicht benachbarte Ecken. '
        'Im Viereck sind das genau zwei.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'logic_fig_09',
    subCategory: SubCategory.figureAnalogies,
    prompt: 'Ein gleichseitiges Dreieck wird um 120° gedreht.\n'
        'Wie sieht es danach aus?',
    answer: MultipleChoice(
      options: [
        'unverändert',
        'auf dem Kopf stehend',
        'gespiegelt',
        'zu einem Viereck verzerrt',
      ],
      correctIndex: 0,
    ),
    explanation: 'Ein gleichseitiges Dreieck geht bei einer Drehung um 120° '
        'genau in sich selbst über.',
    difficulty: Difficulty.hard,
  ),
  Question(
    id: 'logic_fig_10',
    subCategory: SubCategory.figureAnalogies,
    prompt: 'Ein Pfeil zeigt nach rechts oben. Er wird an einer senkrechten '
        'Achse gespiegelt.\nIn welche Richtung zeigt er danach?',
    answer: MultipleChoice(
      options: ['rechts oben', 'links oben', 'rechts unten', 'links unten'],
      correctIndex: 1,
    ),
    explanation: 'Eine senkrechte Spiegelachse vertauscht links und rechts, '
        'oben und unten bleiben gleich. Aus "rechts oben" wird "links oben".',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'logic_fig_11',
    subCategory: SubCategory.figureAnalogies,
    prompt: 'Wie viele Kanten hat ein Würfel?',
    answer: MultipleChoice(
      options: ['6', '8', '12', '16'],
      correctIndex: 2,
    ),
    explanation: 'Ein Würfel hat 6 Flächen, 8 Ecken und 12 Kanten.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'logic_fig_12',
    subCategory: SubCategory.figureAnalogies,
    prompt: 'Ein Würfel wird aufgeschnitten und flach ausgebreitet.\n'
        'Aus wie vielen Quadraten besteht das Netz?',
    answer: MultipleChoice(
      options: ['4', '5', '6', '8'],
      correctIndex: 2,
    ),
    explanation: 'Das Netz enthält jede Würfelfläche genau einmal – '
        'also 6 Quadrate.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'logic_fig_13',
    subCategory: SubCategory.figureAnalogies,
    prompt: 'Der Großbuchstabe N wird um 90° gedreht.\n'
        'Welchem Buchstaben ähnelt er dann?',
    answer: MultipleChoice(
      options: ['M', 'W', 'Z', 'H'],
      correctIndex: 2,
    ),
    explanation: 'Aus den beiden senkrechten Strichen des N werden waagerechte. '
        'Die Figur entspricht dann einem Z.',
    difficulty: Difficulty.hard,
  ),
  Question(
    id: 'logic_fig_14',
    subCategory: SubCategory.figureAnalogies,
    prompt: 'Welche Figur hat die meisten Symmetrieachsen?',
    answer: MultipleChoice(
      options: ['Rechteck', 'gleichseitiges Dreieck', 'Quadrat', 'Kreis'],
      correctIndex: 3,
    ),
    explanation: 'Rechteck 2, gleichseitiges Dreieck 3, Quadrat 4 – '
        'der Kreis hat unendlich viele Symmetrieachsen.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'logic_fig_15',
    subCategory: SubCategory.figureAnalogies,
    prompt: 'Eine Reihe zeigt schwarze und weiße Felder:\n'
        'schwarz, weiß, schwarz, schwarz, weiß, schwarz, schwarz, schwarz, '
        'weiß, ?\nWelche Farbe hat das nächste Feld?',
    answer: MultipleChoice(
      options: ['schwarz', 'weiß', 'grau', 'nicht bestimmbar'],
      correctIndex: 0,
    ),
    explanation: 'Die schwarzen Blöcke werden immer länger: 1, 2, 3 – '
        'jeweils durch ein weißes Feld getrennt. Nach dem dritten weißen Feld '
        'beginnt der Block aus vier schwarzen Feldern.',
    difficulty: Difficulty.hard,
  ),

  // ---------------------------------------------------------------
  // Schlussfolgerungen
  // ---------------------------------------------------------------
  Question(
    id: 'logic_con_01',
    subCategory: SubCategory.conclusions,
    prompt: 'Gegeben: "Alle Rosen sind Blumen." und '
        '"Einige Blumen verwelken schnell."\n'
        'Welche Aussage folgt zwingend?',
    answer: MultipleChoice(
      options: [
        'Alle Rosen verwelken schnell.',
        'Einige Rosen verwelken schnell.',
        'Keine Rose verwelkt schnell.',
        'Keine der Aussagen folgt zwingend.',
      ],
      correctIndex: 3,
    ),
    explanation: 'Die schnell verwelkenden Blumen müssen keine Rosen sein. '
        'Aus den beiden Sätzen lässt sich über Rosen nichts Zwingendes '
        'ableiten.',
    difficulty: Difficulty.hard,
  ),
  Question(
    id: 'logic_con_02',
    subCategory: SubCategory.conclusions,
    prompt: 'Gegeben: "Alle Mitarbeitenden dieser Abteilung tragen einen '
        'Dienstausweis." und "Herr Müller trägt keinen Dienstausweis."\n'
        'Welche Aussage folgt zwingend?',
    answer: MultipleChoice(
      options: [
        'Herr Müller arbeitet nicht in dieser Abteilung.',
        'Herr Müller hat seinen Ausweis vergessen.',
        'Herr Müller ist neu in der Abteilung.',
        'Keine der Aussagen folgt zwingend.',
      ],
      correctIndex: 0,
    ),
    explanation: 'Würde Herr Müller zur Abteilung gehören, müsste er laut '
        'erster Aussage einen Ausweis tragen. Da er keinen trägt, gehört er '
        'nicht dazu.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'logic_con_03',
    subCategory: SubCategory.conclusions,
    prompt: 'Gegeben: "Kein Fahrzeug in der Halle ist rot." und '
        '"Einige Fahrzeuge in der Halle sind Transporter."\n'
        'Welche Aussage folgt zwingend?',
    answer: MultipleChoice(
      options: [
        'Alle Transporter sind rot.',
        'Kein Transporter in der Halle ist rot.',
        'Einige Transporter in der Halle sind rot.',
        'Keine der Aussagen folgt zwingend.',
      ],
      correctIndex: 1,
    ),
    explanation: 'Transporter in der Halle sind Fahrzeuge in der Halle. '
        'Da kein Fahrzeug dort rot ist, kann auch kein Transporter dort rot '
        'sein.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'logic_con_04',
    subCategory: SubCategory.conclusions,
    prompt: 'Welcher Buchstabe steht im Wort VERWALTUNG '
        'an vierter Stelle von hinten?',
    answer: MultipleChoice(options: ['L', 'T', 'U', 'N'], correctIndex: 1),
    explanation: 'VERWALTUNG hat 10 Buchstaben. Von hinten gezählt: '
        'G (1), N (2), U (3), T (4).',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'logic_con_05',
    subCategory: SubCategory.conclusions,
    prompt: 'Fünf Personen stehen in einer Reihe. Anna steht direkt vor Ben, '
        'Ben direkt vor Clara. Dora steht ganz vorne, Emil ganz hinten.\n'
        'An welcher Position steht Ben?',
    answer: MultipleChoice(
      options: ['2', '3', '4', 'Nicht bestimmbar'],
      correctIndex: 1,
    ),
    explanation: 'Dora belegt Position 1, Emil Position 5. '
        'Anna, Ben und Clara füllen zusammenhängend die Positionen 2, 3 und 4 – '
        'Ben steht damit auf Position 3.',
    difficulty: Difficulty.hard,
  ),
  Question(
    id: 'logic_con_06',
    subCategory: SubCategory.conclusions,
    prompt: 'Welcher Begriff passt nicht in die Reihe?',
    answer: MultipleChoice(
      options: ['Hammer', 'Zange', 'Schraubendreher', 'Nagel'],
      correctIndex: 3,
    ),
    explanation: 'Hammer, Zange und Schraubendreher sind Werkzeuge. '
        'Der Nagel ist Material, das damit verarbeitet wird.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'logic_con_07',
    subCategory: SubCategory.conclusions,
    prompt: 'Welcher Begriff passt nicht in die Reihe?',
    answer: MultipleChoice(
      options: ['Amsel', 'Spatz', 'Fledermaus', 'Meise'],
      correctIndex: 2,
    ),
    explanation: 'Amsel, Spatz und Meise sind Vögel. '
        'Die Fledermaus ist ein Säugetier.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'logic_con_08',
    subCategory: SubCategory.conclusions,
    prompt: 'Welcher Begriff passt nicht in die Reihe?',
    answer: MultipleChoice(
      options: ['Deutschland', 'Frankreich', 'Berlin', 'Italien'],
      correctIndex: 2,
    ),
    explanation: 'Deutschland, Frankreich und Italien sind Staaten. '
        'Berlin ist eine Stadt.',
    difficulty: Difficulty.easy,
  ),
];
