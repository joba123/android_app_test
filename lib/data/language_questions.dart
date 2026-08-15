import 'package:einstellungstest_trainer/models/question.dart';
import 'package:einstellungstest_trainer/models/training_module.dart';

/// Feinthemen des Moduls Sprache.
abstract final class LanguageTopics {
  static const spelling = 'Rechtschreibung';
  static const grammar = 'Grammatik';
  static const vocabulary = 'Wortschatz & Textverständnis';

  static const all = [spelling, grammar, vocabulary];
}

/// Startpool Sprache.
const List<Question> languageQuestions = [
  // --- Rechtschreibung ---
  Question(
    id: 'lang_spell_01',
    module: TrainingModule.language,
    topic: LanguageTopics.spelling,
    prompt: 'Welches Wort ist richtig geschrieben?',
    options: ['Rytmus', 'Rhytmus', 'Rhythmus', 'Rythmus'],
    correctIndex: 2,
    explanation: 'Korrekt ist "Rhythmus" – mit "Rh" am Anfang und "th" in der Mitte.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'lang_spell_02',
    module: TrainingModule.language,
    topic: LanguageTopics.spelling,
    prompt: 'Welches Wort ist richtig geschrieben?',
    options: ['Standart', 'Standard', 'Standardt', 'Stantard'],
    correctIndex: 1,
    explanation: 'Korrekt ist "Standard" mit "d" am Ende. '
        'Mit "t" geschrieben ("Standarte") bezeichnet es eine Fahne.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'lang_spell_03',
    module: TrainingModule.language,
    topic: LanguageTopics.spelling,
    prompt: 'Welches Wort ist richtig geschrieben?',
    options: ['vorraussichtlich', 'voraussichtlich', 'vorrausichtlich', 'voraussichtlig'],
    correctIndex: 1,
    explanation: 'Das Wort wird aus "voraus" + "sichtlich" gebildet – '
        'also nur ein "r".',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'lang_spell_04',
    module: TrainingModule.language,
    topic: LanguageTopics.spelling,
    prompt: 'Welches Wort ist richtig geschrieben?',
    options: ['Adresse', 'Addresse', 'Adreße', 'Addreße'],
    correctIndex: 0,
    explanation: 'Korrekt ist "Adresse" – ein "d", zwei "s".',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'lang_spell_05',
    module: TrainingModule.language,
    topic: LanguageTopics.spelling,
    prompt: 'Welches Wort ist richtig geschrieben?',
    options: ['interessant', 'intressant', 'interresant', 'interessannt'],
    correctIndex: 0,
    explanation: 'Korrekt ist "interessant" – ein "r", zwei "s".',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'lang_spell_06',
    module: TrainingModule.language,
    topic: LanguageTopics.spelling,
    prompt: 'Ergänzen Sie richtig:\n"___ ihr schon lange hier?"',
    options: ['Seit', 'Seid', 'Seidt', 'Sait'],
    correctIndex: 1,
    explanation: '"Seid" ist die Verbform von "sein" (ihr seid). '
        '"Seit" bezeichnet dagegen einen Zeitpunkt.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'lang_spell_07',
    module: TrainingModule.language,
    topic: LanguageTopics.spelling,
    prompt: 'Ergänzen Sie richtig:\n"Ich hoffe, ___ du pünktlich kommst."',
    options: ['das', 'dass', 'daß', 'das s'],
    correctIndex: 1,
    explanation: 'Hier leitet die Konjunktion "dass" einen Nebensatz ein. '
        'Die Schreibweise "daß" ist seit der Rechtschreibreform veraltet.',
    difficulty: Difficulty.medium,
  ),

  // --- Grammatik ---
  Question(
    id: 'lang_gram_01',
    module: TrainingModule.language,
    topic: LanguageTopics.grammar,
    prompt: 'Ergänzen Sie richtig:\n"Wegen ___ Wetters fiel das Training aus."',
    options: ['dem schlechten', 'des schlechten', 'das schlechte', 'der schlechte'],
    correctIndex: 1,
    explanation: '"Wegen" verlangt den Genitiv: "wegen des schlechten Wetters".',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'lang_gram_02',
    module: TrainingModule.language,
    topic: LanguageTopics.grammar,
    prompt: 'Ergänzen Sie richtig:\n"Ich erinnere mich ___ den Termin."',
    options: ['auf', 'an', 'über', 'für'],
    correctIndex: 1,
    explanation: '"Sich erinnern" wird mit der Präposition "an" verwendet.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'lang_gram_03',
    module: TrainingModule.language,
    topic: LanguageTopics.grammar,
    prompt: 'Welcher Satz ist grammatikalisch korrekt?',
    options: [
      'Er half mir, den Karton zu tragen.',
      'Er half mich, den Karton zu tragen.',
      'Er half mir den Karton tragen.',
      'Er half mich den Karton tragen.',
    ],
    correctIndex: 0,
    explanation: '"Helfen" verlangt den Dativ ("mir"), und der Infinitiv '
        'wird mit "zu" angeschlossen.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'lang_gram_04',
    module: TrainingModule.language,
    topic: LanguageTopics.grammar,
    prompt: 'Welche Form ist die korrekte indirekte Rede (Konjunktiv I) '
        'zu "Er kommt später"?',
    options: ['er kommt', 'er komme', 'er käme', 'er kam'],
    correctIndex: 1,
    explanation: 'Der Konjunktiv I lautet "er komme". '
        '"Käme" ist Konjunktiv II und wird nur als Ersatzform genutzt.',
    difficulty: Difficulty.hard,
  ),
  Question(
    id: 'lang_gram_05',
    module: TrainingModule.language,
    topic: LanguageTopics.grammar,
    prompt: 'Wie lautet "Die Behörde prüft den Antrag" im Passiv?',
    options: [
      'Der Antrag prüft die Behörde.',
      'Der Antrag wird von der Behörde geprüft.',
      'Der Antrag ist von der Behörde geprüft.',
      'Die Behörde wird den Antrag geprüft.',
    ],
    correctIndex: 1,
    explanation: 'Im Vorgangspassiv wird das Objekt zum Subjekt: '
        '"Der Antrag wird von der Behörde geprüft."',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'lang_gram_06',
    module: TrainingModule.language,
    topic: LanguageTopics.grammar,
    prompt: 'Welcher Satz ist richtig kommasiert?',
    options: [
      'Er nahm den Bus weil sein Auto defekt war.',
      'Er nahm den Bus, weil sein Auto defekt war.',
      'Er nahm, den Bus weil sein Auto defekt war.',
      'Er nahm den Bus weil, sein Auto defekt war.',
    ],
    correctIndex: 1,
    explanation: 'Vor einem mit "weil" eingeleiteten Nebensatz steht ein Komma.',
    difficulty: Difficulty.easy,
  ),

  // --- Wortschatz & Textverständnis ---
  Question(
    id: 'lang_voc_01',
    module: TrainingModule.language,
    topic: LanguageTopics.vocabulary,
    prompt: 'Was bedeutet "obsolet"?',
    options: ['dringend', 'veraltet', 'verbindlich', 'freiwillig'],
    correctIndex: 1,
    explanation: '"Obsolet" bedeutet veraltet bzw. überholt.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'lang_voc_02',
    module: TrainingModule.language,
    topic: LanguageTopics.vocabulary,
    prompt: 'Was bedeutet "kongruent"?',
    options: ['gegensätzlich', 'übereinstimmend', 'unklar', 'vorläufig'],
    correctIndex: 1,
    explanation: '"Kongruent" bedeutet deckungsgleich bzw. übereinstimmend.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'lang_voc_03',
    module: TrainingModule.language,
    topic: LanguageTopics.vocabulary,
    prompt: 'Was bedeutet "Diskrepanz"?',
    options: ['Übereinstimmung', 'Abweichung', 'Entscheidung', 'Zusammenfassung'],
    correctIndex: 1,
    explanation: 'Eine "Diskrepanz" ist ein Widerspruch bzw. eine Abweichung '
        'zwischen zwei Dingen.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'lang_voc_04',
    module: TrainingModule.language,
    topic: LanguageTopics.vocabulary,
    prompt: 'Was bedeutet "Prämisse"?',
    options: ['Schlussfolgerung', 'Voraussetzung', 'Ausnahme', 'Belohnung'],
    correctIndex: 1,
    explanation: 'Eine "Prämisse" ist eine Voraussetzung oder Annahme, '
        'aus der eine Schlussfolgerung gezogen wird.',
    difficulty: Difficulty.hard,
  ),
  Question(
    id: 'lang_voc_05',
    module: TrainingModule.language,
    topic: LanguageTopics.vocabulary,
    prompt: 'Welches Wort ist ein Synonym für "akribisch"?',
    options: ['nachlässig', 'sorgfältig', 'hastig', 'zufällig'],
    correctIndex: 1,
    explanation: '"Akribisch" bedeutet äußerst sorgfältig und genau.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'lang_voc_06',
    module: TrainingModule.language,
    topic: LanguageTopics.vocabulary,
    prompt: 'Was ist das Gegenteil von "transparent"?',
    options: ['durchsichtig', 'undurchsichtig', 'offen', 'nachvollziehbar'],
    correctIndex: 1,
    explanation: '"Transparent" bedeutet durchsichtig bzw. nachvollziehbar – '
        'das Gegenteil ist "undurchsichtig".',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'lang_voc_07',
    module: TrainingModule.language,
    topic: LanguageTopics.vocabulary,
    prompt: 'Lesen Sie den Text:\n'
        '"Anträge werden nur bearbeitet, wenn sie vollständig ausgefüllt und '
        'fristgerecht eingereicht wurden. Unvollständige Anträge werden ohne '
        'weitere Rückfrage zurückgesendet."\n\n'
        'Was geschieht mit einem vollständigen Antrag, der zu spät eingeht?',
    options: [
      'Er wird bearbeitet.',
      'Er wird nicht bearbeitet.',
      'Es wird eine Rückfrage gestellt.',
      'Das geht aus dem Text nicht hervor.',
    ],
    correctIndex: 1,
    explanation: 'Die Bearbeitung setzt beide Bedingungen voraus: vollständig '
        'UND fristgerecht. Fehlt die Frist, wird nicht bearbeitet.',
    difficulty: Difficulty.hard,
  ),
  Question(
    id: 'lang_voc_08',
    module: TrainingModule.language,
    topic: LanguageTopics.vocabulary,
    prompt: 'Lesen Sie den Text:\n'
        '"Mitarbeitende, die an der Schulung teilnehmen, erhalten die Fahrtkosten '
        'erstattet. Eine Erstattung der Übernachtungskosten erfolgt nur bei einer '
        'Anreise von mehr als 200 Kilometern."\n\n'
        'Wer bekommt die Übernachtungskosten erstattet?',
    options: [
      'Alle Teilnehmenden',
      'Nur Teilnehmende mit mehr als 200 km Anreise',
      'Nur Teilnehmende mit weniger als 200 km Anreise',
      'Niemand',
    ],
    correctIndex: 1,
    explanation: 'Die Fahrtkosten bekommen alle Teilnehmenden, die '
        'Übernachtungskosten aber nur bei über 200 km Anreise.',
    difficulty: Difficulty.medium,
  ),
];
