import 'package:einstellungstest_trainer/models/question.dart';
import 'package:einstellungstest_trainer/models/sub_category.dart';

/// Startpool Englisch – handgeschrieben, durchgängig Multiple Choice.
///
/// Das Niveau orientiert sich an dem, was in Auswahlverfahren tatsächlich
/// abgefragt wird: solides Schulenglisch (A2 bis B2), keine Literatur. Die
/// Aufgabenstellungen stehen auf Deutsch, damit klar ist, was zu tun ist –
/// geprüft wird das Englische in den Optionen.
const List<Question> englishQuestions = [
  // ---------------------------------------------------------------
  // Vokabeln
  // ---------------------------------------------------------------
  Question(
    id: 'en_voc_01',
    subCategory: SubCategory.englishVocabulary,
    prompt: 'Was bedeutet "to apply for a job"?',
    answer: MultipleChoice(
      options: [
        'sich auf eine Stelle bewerben',
        'eine Stelle kündigen',
        'eine Stelle ausschreiben',
        'eine Stelle antreten',
      ],
      correctIndex: 0,
    ),
    explanation: '"to apply for" heißt "sich bewerben um". Ausschreiben wäre '
        '"to advertise", antreten "to start".',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'en_voc_02',
    subCategory: SubCategory.englishVocabulary,
    prompt: 'Was bedeutet "reliable"?',
    answer: MultipleChoice(
      options: ['zuverlässig', 'nachgiebig', 'erreichbar', 'ersetzbar'],
      correctIndex: 0,
    ),
    explanation: '"reliable" kommt von "to rely on" (sich verlassen auf) und '
        'heißt zuverlässig.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'en_voc_03',
    subCategory: SubCategory.englishVocabulary,
    prompt: 'Was bedeutet "to increase"?',
    answer: MultipleChoice(
      options: ['steigen', 'sinken', 'gleich bleiben', 'schwanken'],
      correctIndex: 0,
    ),
    explanation: '"to increase" heißt steigen oder erhöhen. Das Gegenteil ist '
        '"to decrease".',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'en_voc_04',
    subCategory: SubCategory.englishVocabulary,
    prompt: 'Was bedeutet "staff"?',
    answer: MultipleChoice(
      options: ['Personal', 'Stab aus Holz', 'Stufe', 'Abteilung'],
      correctIndex: 0,
    ),
    explanation: '"staff" bezeichnet die Belegschaft. Achtung: Das Wort steht '
        'im Englischen ohne Plural-s.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'en_voc_05',
    subCategory: SubCategory.englishVocabulary,
    prompt: 'Was bedeutet "to attend a meeting"?',
    answer: MultipleChoice(
      options: [
        'an einer Besprechung teilnehmen',
        'eine Besprechung leiten',
        'eine Besprechung absagen',
        'eine Besprechung vorbereiten',
      ],
      correctIndex: 0,
    ),
    explanation: '"to attend" heißt teilnehmen – nicht "beachten", das wäre '
        '"to pay attention to".',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'en_voc_06',
    subCategory: SubCategory.englishVocabulary,
    prompt: 'Welches Wort passt: "The report is due ___ Friday."',
    answer: MultipleChoice(
      options: ['on', 'in', 'at', 'to'],
      correctIndex: 0,
    ),
    explanation: 'Wochentage stehen mit "on": on Friday, on Monday.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'en_voc_07',
    subCategory: SubCategory.englishVocabulary,
    prompt: 'Was bedeutet "safety"?',
    answer: MultipleChoice(
      options: ['Sicherheit', 'Rettung', 'Vorsicht', 'Gefahr'],
      correctIndex: 0,
    ),
    explanation: '"safety" ist die Sicherheit im Sinn von Unfallschutz. '
        '"security" meint Sicherheit vor Angriffen.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'en_voc_08',
    subCategory: SubCategory.englishVocabulary,
    prompt: 'Was bedeutet "to require"?',
    answer: MultipleChoice(
      options: ['erfordern', 'erwerben', 'erinnern', 'erlauben'],
      correctIndex: 0,
    ),
    explanation: '"to require" heißt verlangen oder erfordern. "to acquire" '
        '(erwerben) sieht ähnlich aus – ein beliebter Stolperstein.',
    difficulty: Difficulty.hard,
  ),
  Question(
    id: 'en_voc_09',
    subCategory: SubCategory.englishVocabulary,
    prompt: 'Was bedeutet "shift" im Arbeitskontext?',
    answer: MultipleChoice(
      options: ['Schicht', 'Vertrag', 'Pause', 'Urlaub'],
      correctIndex: 0,
    ),
    explanation: '"night shift" ist die Nachtschicht. Als Verb heißt "to '
        'shift" verschieben.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'en_voc_10',
    subCategory: SubCategory.englishVocabulary,
    prompt: 'Was bedeutet "to estimate"?',
    answer: MultipleChoice(
      options: ['schätzen', 'schätzen lassen', 'berechnen', 'beweisen'],
      correctIndex: 0,
    ),
    explanation: '"to estimate" heißt schätzen. Exakt berechnen wäre '
        '"to calculate".',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'en_voc_11',
    subCategory: SubCategory.englishVocabulary,
    prompt: 'Was bedeutet "eventually"?',
    answer: MultipleChoice(
      options: ['schließlich', 'eventuell', 'ereignisreich', 'gleichzeitig'],
      correctIndex: 0,
    ),
    explanation: 'Falscher Freund: "eventually" heißt schließlich, nicht '
        'eventuell. "Eventuell" wäre "possibly".',
    difficulty: Difficulty.hard,
  ),
  Question(
    id: 'en_voc_12',
    subCategory: SubCategory.englishVocabulary,
    prompt: 'Was bedeutet "to become"?',
    answer: MultipleChoice(
      options: ['werden', 'bekommen', 'begleiten', 'beginnen'],
      correctIndex: 0,
    ),
    explanation: 'Falscher Freund: "to become" heißt werden. Bekommen ist '
        '"to get" oder "to receive".',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'en_voc_13',
    subCategory: SubCategory.englishVocabulary,
    prompt: 'Was bedeutet "sensible"?',
    answer: MultipleChoice(
      options: ['vernünftig', 'empfindlich', 'sinnlos', 'spürbar'],
      correctIndex: 0,
    ),
    explanation: 'Falscher Freund: "sensible" heißt vernünftig. Empfindlich '
        'wäre "sensitive".',
    difficulty: Difficulty.hard,
  ),
  Question(
    id: 'en_voc_14',
    subCategory: SubCategory.englishVocabulary,
    prompt: 'Was bedeutet "to hand in"?',
    answer: MultipleChoice(
      options: ['abgeben', 'aushändigen lassen', 'einhändig arbeiten', 'holen'],
      correctIndex: 0,
    ),
    explanation: '"to hand in a report" heißt einen Bericht abgeben.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'en_voc_15',
    subCategory: SubCategory.englishVocabulary,
    prompt: 'Was bedeutet "average"?',
    answer: MultipleChoice(
      options: ['Durchschnitt', 'Höchstwert', 'Rest', 'Anteil'],
      correctIndex: 0,
    ),
    explanation: '"on average" heißt im Durchschnitt.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'en_voc_16',
    subCategory: SubCategory.englishVocabulary,
    prompt: 'Was bedeutet "to prevent"?',
    answer: MultipleChoice(
      options: ['verhindern', 'vorbereiten', 'vorstellen', 'bevorzugen'],
      correctIndex: 0,
    ),
    explanation: '"to prevent accidents" heißt Unfälle verhindern.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'en_voc_17',
    subCategory: SubCategory.englishVocabulary,
    prompt: 'Was bedeutet "equipment"?',
    answer: MultipleChoice(
      options: ['Ausrüstung', 'Gleichung', 'Mannschaft', 'Anlage im Sinn von '
          'Talent'],
      correctIndex: 0,
    ),
    explanation: '"equipment" ist die Ausrüstung und steht immer im Singular: '
        '"the equipment is new".',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'en_voc_18',
    subCategory: SubCategory.englishVocabulary,
    prompt: 'Was bedeutet "deadline"?',
    answer: MultipleChoice(
      options: ['Abgabetermin', 'Notausgang', 'Sperrzone', 'Stromleitung'],
      correctIndex: 0,
    ),
    explanation: 'Die "deadline" ist der letzte Termin, zu dem etwas fertig '
        'sein muss.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'en_voc_19',
    subCategory: SubCategory.englishVocabulary,
    prompt: 'Was bedeutet "to improve"?',
    answer: MultipleChoice(
      options: ['verbessern', 'beweisen', 'bewegen', 'einführen'],
      correctIndex: 0,
    ),
    explanation: '"to improve" heißt verbessern. "to prove" (beweisen) sieht '
        'ähnlich aus.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'en_voc_20',
    subCategory: SubCategory.englishVocabulary,
    prompt: 'Was bedeutet "in charge of"?',
    answer: MultipleChoice(
      options: [
        'verantwortlich für',
        'kostenpflichtig',
        'aufgeladen mit',
        'angeklagt wegen',
      ],
      correctIndex: 0,
    ),
    explanation: '"Who is in charge of the project?" – Wer ist für das '
        'Projekt verantwortlich?',
    difficulty: Difficulty.hard,
  ),

  // ---------------------------------------------------------------
  // Grammatik
  // ---------------------------------------------------------------
  Question(
    id: 'en_gram_01',
    subCategory: SubCategory.englishGrammar,
    prompt: 'Welcher Satz ist korrekt?',
    answer: MultipleChoice(
      options: [
        'She works here since 2020.',
        'She has worked here since 2020.',
        'She is working here since 2020.',
        'She worked here since 2020.',
      ],
      correctIndex: 1,
    ),
    explanation: 'Mit "since" und einer bis heute andauernden Handlung steht '
        'das present perfect: has worked.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'en_gram_02',
    subCategory: SubCategory.englishGrammar,
    prompt: 'Welche Form ist richtig: "If it ___ tomorrow, we will cancel."',
    answer: MultipleChoice(
      options: ['rains', 'will rain', 'rained', 'would rain'],
      correctIndex: 0,
    ),
    explanation: 'Im if-Satz Typ 1 steht Präsens, im Hauptsatz "will". Nach '
        '"if" steht kein "will".',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'en_gram_03',
    subCategory: SubCategory.englishGrammar,
    prompt: 'Welcher Satz ist korrekt?',
    answer: MultipleChoice(
      options: [
        'He can to drive a truck.',
        'He cans drive a truck.',
        'He can drive a truck.',
        'He can driving a truck.',
      ],
      correctIndex: 2,
    ),
    explanation: 'Nach Modalverben wie "can" steht der Infinitiv ohne "to" '
        'und ohne Endung.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'en_gram_04',
    subCategory: SubCategory.englishGrammar,
    prompt: 'Was ist die richtige Steigerung von "good"?',
    answer: MultipleChoice(
      options: ['gooder – goodest', 'better – best', 'more good – most good',
          'better – bestest'],
      correctIndex: 1,
    ),
    explanation: '"good" wird unregelmäßig gesteigert: good – better – best.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'en_gram_05',
    subCategory: SubCategory.englishGrammar,
    prompt: 'Welcher Satz ist korrekt?',
    answer: MultipleChoice(
      options: [
        'There is three applicants waiting.',
        'There are three applicants waiting.',
        'It are three applicants waiting.',
        'There have three applicants waiting.',
      ],
      correctIndex: 1,
    ),
    explanation: 'Im Plural steht "there are". "There is" nur im Singular.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'en_gram_06',
    subCategory: SubCategory.englishGrammar,
    prompt: 'Welche Form passt: "I ___ my colleague yesterday."',
    answer: MultipleChoice(
      options: ['have met', 'meet', 'met', 'was meeting'],
      correctIndex: 2,
    ),
    explanation: 'Mit einem abgeschlossenen Zeitpunkt in der Vergangenheit '
        '("yesterday") steht das simple past: met.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'en_gram_07',
    subCategory: SubCategory.englishGrammar,
    prompt: 'Welcher Satz ist korrekt?',
    answer: MultipleChoice(
      options: [
        'The team make a decision.',
        'The team makes a decision.',
        'The team are make a decision.',
        'The team making a decision.',
      ],
      correctIndex: 1,
    ),
    explanation: 'Im amerikanischen wie im Prüfungsenglisch gilt "team" als '
        'Singular: the team makes.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'en_gram_08',
    subCategory: SubCategory.englishGrammar,
    prompt: 'Welches Wort fehlt: "This is the colleague ___ helped me."',
    answer: MultipleChoice(
      options: ['who', 'which', 'what', 'whose'],
      correctIndex: 0,
    ),
    explanation: 'Für Personen steht "who", für Sachen "which".',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'en_gram_09',
    subCategory: SubCategory.englishGrammar,
    prompt: 'Welcher Satz steht korrekt im Passiv?',
    answer: MultipleChoice(
      options: [
        'The report was written by the team.',
        'The report was wrote by the team.',
        'The report has wrote by the team.',
        'The report is write by the team.',
      ],
      correctIndex: 0,
    ),
    explanation: 'Passiv ist "form of be" plus Partizip Perfekt: was written.',
    difficulty: Difficulty.hard,
  ),
  Question(
    id: 'en_gram_10',
    subCategory: SubCategory.englishGrammar,
    prompt: 'Welche Form passt: "There isn\'t ___ time left."',
    answer: MultipleChoice(
      options: ['much', 'many', 'a few', 'several'],
      correctIndex: 0,
    ),
    explanation: '"time" ist unzählbar, deshalb "much". "many" steht bei '
        'zählbaren Dingen.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'en_gram_11',
    subCategory: SubCategory.englishGrammar,
    prompt: 'Welcher Satz ist korrekt?',
    answer: MultipleChoice(
      options: [
        'I am working here since three years.',
        'I work here since three years.',
        'I have been working here for three years.',
        'I have worked here since three years.',
      ],
      correctIndex: 2,
    ),
    explanation: 'Bei einer Zeitspanne steht "for", bei einem Startpunkt '
        '"since": for three years, since 2022.',
    difficulty: Difficulty.hard,
  ),
  Question(
    id: 'en_gram_12',
    subCategory: SubCategory.englishGrammar,
    prompt: 'Welche Frage ist korrekt gebildet?',
    answer: MultipleChoice(
      options: [
        'Where you did put the file?',
        'Where did you put the file?',
        'Where did you putted the file?',
        'Where you put the file?',
      ],
      correctIndex: 1,
    ),
    explanation: 'Fragen im simple past: did + Subjekt + Grundform.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'en_gram_13',
    subCategory: SubCategory.englishGrammar,
    prompt: 'Welches Wort passt: "She is responsible ___ the budget."',
    answer: MultipleChoice(
      options: ['for', 'of', 'about', 'on'],
      correctIndex: 0,
    ),
    explanation: '"responsible for" – die Präposition gehört fest zum '
        'Adjektiv.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'en_gram_14',
    subCategory: SubCategory.englishGrammar,
    prompt: 'Welcher Satz ist korrekt?',
    answer: MultipleChoice(
      options: [
        'He suggested to change the plan.',
        'He suggested changing the plan.',
        'He suggested change the plan.',
        'He suggested to changing the plan.',
      ],
      correctIndex: 1,
    ),
    explanation: 'Nach "suggest" steht das Gerundium: suggested changing.',
    difficulty: Difficulty.hard,
  ),
  Question(
    id: 'en_gram_15',
    subCategory: SubCategory.englishGrammar,
    prompt: 'Welche Form ist richtig: "The meeting ___ at 9 a.m. every '
        'Monday."',
    answer: MultipleChoice(
      options: ['start', 'starts', 'is starting', 'has started'],
      correctIndex: 1,
    ),
    explanation: 'Regelmäßige Handlungen stehen im simple present, dritte '
        'Person Singular mit -s.',
    difficulty: Difficulty.easy,
  ),

  // ---------------------------------------------------------------
  // Textverständnis
  // ---------------------------------------------------------------
  Question(
    id: 'en_read_01',
    subCategory: SubCategory.englishReading,
    prompt: 'Text: "All employees must wear protective gloves in the storage '
        'area. Helmets are only required on the loading ramp."\n\n'
        'Was folgt daraus?',
    answer: MultipleChoice(
      options: [
        'Im Lager sind Handschuhe Pflicht, Helme nicht.',
        'Im Lager sind Helme und Handschuhe Pflicht.',
        'Auf der Laderampe genügen Handschuhe.',
        'Schutzkleidung ist überall freiwillig.',
      ],
      correctIndex: 0,
    ),
    explanation: 'Die Helmpflicht gilt laut Text ausdrücklich nur ("only") '
        'für die Laderampe.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'en_read_02',
    subCategory: SubCategory.englishReading,
    prompt: 'Text: "The office is closed on public holidays. If a holiday '
        'falls on a Sunday, the following Monday is a working day."\n\n'
        'Was folgt daraus?',
    answer: MultipleChoice(
      options: [
        'Fällt ein Feiertag auf einen Sonntag, wird am Montag gearbeitet.',
        'Fällt ein Feiertag auf einen Sonntag, ist der Montag frei.',
        'Das Büro ist sonntags geöffnet.',
        'Feiertage werden immer nachgeholt.',
      ],
      correctIndex: 0,
    ),
    explanation: 'Der zweite Satz sagt genau das: der folgende Montag ist ein '
        'Arbeitstag.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'en_read_03',
    subCategory: SubCategory.englishReading,
    prompt: 'Text: "Applicants who fail the written test may repeat it once '
        'after six months. A second failure ends the application."\n\n'
        'Was folgt daraus?',
    answer: MultipleChoice(
      options: [
        'Nach zwei erfolglosen Versuchen ist die Bewerbung beendet.',
        'Der Test kann beliebig oft wiederholt werden.',
        'Die Wiederholung ist sofort möglich.',
        'Wer durchfällt, darf nie wieder antreten.',
      ],
      correctIndex: 0,
    ),
    explanation: 'Eine Wiederholung ist erlaubt, ein zweites Scheitern beendet '
        'das Verfahren.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'en_read_04',
    subCategory: SubCategory.englishReading,
    prompt: 'Text: "Overtime is paid at 125 % of the normal rate, except on '
        'Sundays, when it is paid at 150 %."\n\n'
        'Wie viel Prozent gibt es für Überstunden am Mittwoch?',
    answer: MultipleChoice(
      options: ['125 %', '150 %', '100 %', '175 %'],
      correctIndex: 0,
    ),
    explanation: 'Der Satz von 150 % gilt nur sonntags, an allen anderen '
        'Tagen bleibt es bei 125 %.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'en_read_05',
    subCategory: SubCategory.englishReading,
    prompt: 'Text: "Visitors must register at the front desk. Contractors '
        'with a valid annual pass do not have to register."\n\n'
        'Wer muss sich anmelden?',
    answer: MultipleChoice(
      options: [
        'Besucher ohne Jahresausweis',
        'Alle, die das Gebäude betreten',
        'Nur Handwerker',
        'Niemand',
      ],
      correctIndex: 0,
    ),
    explanation: 'Die Ausnahme gilt für Handwerker mit gültigem Jahresausweis, '
        'alle übrigen Besucher melden sich an.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'en_read_06',
    subCategory: SubCategory.englishReading,
    prompt: 'Text: "The alarm is tested every first Tuesday of the month at '
        '11 a.m. No action is required during the test."\n\n'
        'Was folgt daraus?',
    answer: MultipleChoice(
      options: [
        'Beim Probealarm muss niemand das Gebäude verlassen.',
        'Der Alarm wird wöchentlich getestet.',
        'Beim Probealarm ist das Gebäude zu räumen.',
        'Der Test findet montags statt.',
      ],
      correctIndex: 0,
    ),
    explanation: '"No action is required" heißt: nichts zu tun, also auch '
        'keine Räumung.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'en_read_07',
    subCategory: SubCategory.englishReading,
    prompt: 'Text: "Travel costs are reimbursed only if the trip was approved '
        'in advance and the receipts are submitted within 30 days."\n\n'
        'Wann gibt es kein Geld zurück?',
    answer: MultipleChoice(
      options: [
        'Wenn die Belege erst nach 40 Tagen eingereicht werden',
        'Wenn die Reise vorher genehmigt wurde',
        'Wenn die Belege nach 20 Tagen eingereicht werden',
        'Wenn die Reise beruflich war',
      ],
      correctIndex: 0,
    ),
    explanation: 'Beide Bedingungen müssen erfüllt sein; 40 Tage überschreiten '
        'die Frist von 30 Tagen.',
    difficulty: Difficulty.hard,
  ),
  Question(
    id: 'en_read_08',
    subCategory: SubCategory.englishReading,
    prompt: 'Text: "Shifts start at 6 a.m., 2 p.m. and 10 p.m. Each shift '
        'lasts eight hours."\n\n'
        'Wann endet die Schicht, die um 14 Uhr beginnt?',
    answer: MultipleChoice(
      options: ['22 Uhr', '20 Uhr', '6 Uhr', '18 Uhr'],
      correctIndex: 0,
    ),
    explanation: '2 p.m. ist 14 Uhr, plus acht Stunden ergibt 22 Uhr – der '
        'Beginn der Nachtschicht.',
    difficulty: Difficulty.medium,
  ),
];
