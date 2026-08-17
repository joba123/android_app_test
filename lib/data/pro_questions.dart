import 'package:einstellungstest_trainer/models/question.dart';
import 'package:einstellungstest_trainer/models/sub_category.dart';

/// Zusätzlicher Aufgabenbestand für Pro.
///
/// **Wichtig für spätere Änderungen:** Diese Aufgaben kommen zum kostenlosen
/// Bestand hinzu, sie ersetzen ihn nicht. Es darf nie eine Aufgabe aus
/// `logic_questions.dart` oder `language_questions.dart` hierher wandern –
/// das wäre eine nachträgliche Bezahlschranke für etwas, das vorher frei war.
///
/// Der Schwerpunkt liegt bewusst auf den schwereren Aufgabentypen: Wer so
/// weit ist, dass der freie Bestand zu leicht wird, ist die Zielgruppe.
const List<Question> proQuestions = [
  // ---------------------------------------------------------------
  // Zahlenreihen – mehrstufige Muster
  // ---------------------------------------------------------------
  Question(
    id: 'pro_logic_seq_01',
    subCategory: SubCategory.numberSequences,
    prompt: 'Wie geht die Reihe weiter?\n1, 2, 6, 24, 120, ?',
    answer: MultipleChoice(
      options: ['600', '720', '840', '960'],
      correctIndex: 1,
    ),
    explanation: 'Multipliziert wird mit 2, 3, 4, 5 – also als Nächstes '
        'mit 6: 120 · 6 = 720.',
    difficulty: Difficulty.hard,
  ),
  Question(
    id: 'pro_logic_seq_02',
    subCategory: SubCategory.numberSequences,
    prompt: 'Wie geht die Reihe weiter?\n2, 3, 5, 8, 13, 21, ?',
    answer: MultipleChoice(
      options: ['29', '31', '34', '42'],
      correctIndex: 2,
    ),
    explanation: 'Jede Zahl ist die Summe der beiden vorherigen: '
        '13 + 21 = 34.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'pro_logic_seq_03',
    subCategory: SubCategory.numberSequences,
    prompt: 'Wie geht die Reihe weiter?\n81, 27, 9, 3, ?',
    answer: MultipleChoice(
      options: ['0', '1', '1,5', '2'],
      correctIndex: 1,
    ),
    explanation: 'Jede Zahl ist ein Drittel der vorherigen: 3 : 3 = 1.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'pro_logic_seq_04',
    subCategory: SubCategory.numberSequences,
    prompt: 'Wie geht die Reihe weiter?\n4, 9, 16, 25, 36, ?',
    answer: MultipleChoice(
      options: ['42', '45', '49', '54'],
      correctIndex: 2,
    ),
    explanation: 'Es sind die Quadratzahlen ab 2: 2², 3², 4², 5², 6², '
        'also 7² = 49.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'pro_logic_seq_05',
    subCategory: SubCategory.numberSequences,
    prompt: 'Wie geht die Reihe weiter?\n7, 14, 12, 24, 22, 44, ?',
    answer: MultipleChoice(
      options: ['40', '42', '46', '88'],
      correctIndex: 1,
    ),
    explanation: 'Abwechselnd wird verdoppelt und 2 abgezogen: '
        '44 − 2 = 42.',
    difficulty: Difficulty.hard,
  ),
  Question(
    id: 'pro_logic_seq_06',
    subCategory: SubCategory.numberSequences,
    prompt: 'Wie geht die Reihe weiter?\n1, 4, 2, 8, 3, 12, 4, ?',
    answer: MultipleChoice(
      options: ['8', '13', '16', '20'],
      correctIndex: 2,
    ),
    explanation: 'Zwei verschachtelte Reihen: 1, 2, 3, 4 … und 4, 8, 12, … '
        'Die zweite Reihe geht mit 16 weiter.',
    difficulty: Difficulty.hard,
  ),

  // ---------------------------------------------------------------
  // Figurenanalogien – sprachlich beschrieben, siehe logic_questions.dart
  // ---------------------------------------------------------------
  Question(
    id: 'pro_logic_fig_01',
    subCategory: SubCategory.figureAnalogies,
    prompt: 'Ein Quadrat mit einem Punkt oben links verhält sich zu einem '
        'Quadrat mit einem Punkt oben rechts wie ein Dreieck mit einem Punkt '
        'unten links zu …?',
    answer: MultipleChoice(
      options: [
        'Dreieck mit Punkt unten rechts',
        'Dreieck mit Punkt oben links',
        'Dreieck ohne Punkt',
        'Quadrat mit Punkt unten rechts',
      ],
      correctIndex: 0,
    ),
    explanation: 'Der Punkt wandert an die gegenüberliegende Seite, die Form '
        'bleibt gleich: unten links wird zu unten rechts.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'pro_logic_fig_02',
    subCategory: SubCategory.figureAnalogies,
    prompt: 'Ein weißer Kreis verhält sich zu einem schwarzen Kreis wie ein '
        'weißes Sechseck zu …?',
    answer: MultipleChoice(
      options: [
        'weißes Sechseck',
        'schwarzes Sechseck',
        'schwarzer Kreis',
        'graues Fünfeck',
      ],
      correctIndex: 1,
    ),
    explanation: 'Nur die Füllung wechselt von weiß nach schwarz; die Form '
        'bleibt unverändert.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'pro_logic_fig_03',
    subCategory: SubCategory.figureAnalogies,
    prompt: 'Ein Pfeil nach oben verhält sich zu einem Pfeil nach rechts wie '
        'ein Pfeil nach links zu …?',
    answer: MultipleChoice(
      options: [
        'Pfeil nach oben',
        'Pfeil nach unten',
        'Pfeil nach rechts',
        'Doppelpfeil',
      ],
      correctIndex: 0,
    ),
    explanation: 'Gedreht wird um 90 Grad im Uhrzeigersinn: oben → rechts, '
        'links → oben.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'pro_logic_fig_04',
    subCategory: SubCategory.figureAnalogies,
    prompt: 'Ein Quadrat mit zwei waagerechten Linien verhält sich zu einem '
        'Quadrat mit vier waagerechten Linien wie ein Kreis mit drei Punkten '
        'zu …?',
    answer: MultipleChoice(
      options: [
        'Kreis mit vier Punkten',
        'Kreis mit fünf Punkten',
        'Kreis mit sechs Punkten',
        'Kreis mit neun Punkten',
      ],
      correctIndex: 2,
    ),
    explanation: 'Die Anzahl der Elemente verdoppelt sich: aus zwei Linien '
        'werden vier, aus drei Punkten also sechs.',
    difficulty: Difficulty.hard,
  ),

  // ---------------------------------------------------------------
  // Schlussfolgerungen
  // ---------------------------------------------------------------
  Question(
    id: 'pro_logic_con_01',
    subCategory: SubCategory.conclusions,
    prompt: 'Alle Mitglieder der Einsatzgruppe haben den Erste-Hilfe-Kurs '
        'absolviert. Frau Berger hat den Erste-Hilfe-Kurs absolviert.\n'
        'Was folgt zwingend?',
    answer: MultipleChoice(
      options: [
        'Frau Berger gehört zur Einsatzgruppe.',
        'Frau Berger gehört nicht zur Einsatzgruppe.',
        'Keine der Aussagen folgt zwingend.',
        'Alle Kursteilnehmer gehören zur Einsatzgruppe.',
      ],
      correctIndex: 2,
    ),
    explanation: 'Aus „alle A sind B" folgt nicht „alle B sind A". Den Kurs '
        'können auch Personen außerhalb der Gruppe absolviert haben.',
    difficulty: Difficulty.hard,
  ),
  Question(
    id: 'pro_logic_con_02',
    subCategory: SubCategory.conclusions,
    prompt: 'Kein Fahrzeug der Werkstatt ist älter als zehn Jahre. Der '
        'Transporter ist zwölf Jahre alt.\nWas folgt zwingend?',
    answer: MultipleChoice(
      options: [
        'Der Transporter gehört nicht zur Werkstatt.',
        'Der Transporter ist repariert worden.',
        'Die Werkstatt hat keine Transporter.',
        'Keine der Aussagen folgt zwingend.',
      ],
      correctIndex: 0,
    ),
    explanation: 'Alle Werkstattfahrzeuge sind höchstens zehn Jahre alt. Ein '
        'zwölf Jahre altes Fahrzeug kann deshalb keines von ihnen sein.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'pro_logic_con_03',
    subCategory: SubCategory.conclusions,
    prompt: 'Wenn die Meldung eingeht, rückt der Wagen aus. Der Wagen ist '
        'nicht ausgerückt.\nWas folgt zwingend?',
    answer: MultipleChoice(
      options: [
        'Die Meldung ist eingegangen.',
        'Die Meldung ist nicht eingegangen.',
        'Der Wagen war defekt.',
        'Keine der Aussagen folgt zwingend.',
      ],
      correctIndex: 1,
    ),
    explanation: 'Umkehrschluss: Wäre die Meldung eingegangen, wäre der Wagen '
        'ausgerückt. Da er es nicht ist, kam keine Meldung.',
    difficulty: Difficulty.hard,
  ),
  Question(
    id: 'pro_logic_con_04',
    subCategory: SubCategory.conclusions,
    prompt: 'Einige Bewerber haben eine Ausbildung abgeschlossen. Alle, die '
        'eine Ausbildung abgeschlossen haben, wurden eingeladen.\n'
        'Was folgt zwingend?',
    answer: MultipleChoice(
      options: [
        'Alle Bewerber wurden eingeladen.',
        'Einige Bewerber wurden eingeladen.',
        'Kein Bewerber wurde eingeladen.',
        'Nur Bewerber mit Ausbildung wurden eingeladen.',
      ],
      correctIndex: 1,
    ),
    explanation: 'Die Bewerber mit Ausbildung wurden eingeladen – das sind '
        '„einige". Über die übrigen sagt der Text nichts.',
    difficulty: Difficulty.medium,
  ),

  // ---------------------------------------------------------------
  // Rechtschreibung
  // ---------------------------------------------------------------
  Question(
    id: 'pro_lang_spell_01',
    subCategory: SubCategory.spelling,
    prompt: 'Welches Wort ist richtig geschrieben?',
    answer: MultipleChoice(
      options: [
        'Vorraussetzung',
        'Voraussetzung',
        'Vorausetzung',
        'Voraußetzung',
      ],
      correctIndex: 1,
    ),
    explanation: '„Voraussetzung" – aus „voraus" und „Setzung", mit nur '
        'einem r und doppeltem s.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'pro_lang_spell_02',
    subCategory: SubCategory.spelling,
    prompt: 'Welches Wort ist richtig geschrieben?',
    answer: MultipleChoice(
      options: ['Rythmus', 'Rhythmus', 'Rhytmus', 'Rytmus'],
      correctIndex: 1,
    ),
    explanation: '„Rhythmus" kommt aus dem Griechischen und behält beide '
        'h: Rh-yth-mus.',
    difficulty: Difficulty.hard,
  ),
  Question(
    id: 'pro_lang_spell_03',
    subCategory: SubCategory.spelling,
    prompt: 'Welches Wort ist richtig geschrieben?',
    answer: MultipleChoice(
      options: ['seperat', 'sepparat', 'separat', 'sepperat'],
      correctIndex: 2,
    ),
    explanation: '„separat" – von lateinisch „separare", mit a in der '
        'zweiten Silbe.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'pro_lang_spell_04',
    subCategory: SubCategory.spelling,
    prompt: 'Welches Wort ist richtig geschrieben?',
    answer: MultipleChoice(
      options: [
        'Gewissenhaftigkeit',
        'Gewißenhaftigkeit',
        'Gewissenhaftikeit',
        'Gewissenhaftikkeit',
      ],
      correctIndex: 0,
    ),
    explanation: 'Nach kurzem Vokal steht ss: „Gewissen". Die Endung lautet '
        '„-igkeit".',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'pro_lang_spell_05',
    subCategory: SubCategory.spelling,
    prompt: 'Welche Schreibweise ist richtig?',
    answer: MultipleChoice(
      options: [
        'Er hat sich sehr angestrengt, um das Ziel zu erreichen.',
        'Er hat sich sehr angestrengt um das Ziel zu erreichen.',
        'Er hat sich sehr angestrengt, um das Ziel zuerreichen.',
        'Er hat sich sehr angestrengt um, das Ziel zu erreichen.',
      ],
      correctIndex: 0,
    ),
    explanation: 'Vor einer Infinitivgruppe mit „um … zu" steht ein Komma, '
        'und „zu erreichen" wird getrennt geschrieben.',
    difficulty: Difficulty.hard,
  ),
  Question(
    id: 'pro_lang_spell_06',
    subCategory: SubCategory.spelling,
    prompt: 'Welches Wort ist richtig geschrieben?',
    answer: MultipleChoice(
      options: ['Bürokratie', 'Bürokrathie', 'Bürockratie', 'Büroggratie'],
      correctIndex: 0,
    ),
    explanation: '„Bürokratie" – ohne h, mit einfachem k.',
    difficulty: Difficulty.easy,
  ),

  // ---------------------------------------------------------------
  // Wortanalogien
  // ---------------------------------------------------------------
  Question(
    id: 'pro_lang_ana_01',
    subCategory: SubCategory.wordAnalogies,
    prompt: 'Antrag verhält sich zu Bescheid wie Frage zu …?',
    answer: MultipleChoice(
      options: ['Zweifel', 'Antwort', 'Thema', 'Gespräch'],
      correctIndex: 1,
    ),
    explanation: 'Auf einen Antrag folgt ein Bescheid, auf eine Frage eine '
        'Antwort – jeweils die Erwiderung.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'pro_lang_ana_02',
    subCategory: SubCategory.wordAnalogies,
    prompt: 'Sparsam verhält sich zu geizig wie selbstbewusst zu …?',
    answer: MultipleChoice(
      options: ['schüchtern', 'überheblich', 'freundlich', 'ruhig'],
      correctIndex: 1,
    ),
    explanation: 'Das zweite Wort ist jeweils die übertriebene, negative Form '
        'des ersten.',
    difficulty: Difficulty.hard,
  ),
  Question(
    id: 'pro_lang_ana_03',
    subCategory: SubCategory.wordAnalogies,
    prompt: 'Kilometer verhält sich zu Entfernung wie Dezibel zu …?',
    answer: MultipleChoice(
      options: ['Lautstärke', 'Musik', 'Frequenz', 'Gehör'],
      correctIndex: 0,
    ),
    explanation: 'Beides sind Maßeinheiten und die Größe, die sie messen.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'pro_lang_ana_04',
    subCategory: SubCategory.wordAnalogies,
    prompt: 'Bibliothek verhält sich zu Buch wie Kartei zu …?',
    answer: MultipleChoice(
      options: ['Schrank', 'Karte', 'Ordner', 'Register'],
      correctIndex: 1,
    ),
    explanation: 'Die Sammlung und ihr einzelnes Element: Bibliothek/Buch, '
        'Kartei/Karte.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'pro_lang_ana_05',
    subCategory: SubCategory.wordAnalogies,
    prompt: 'Zeuge verhält sich zu Aussage wie Gutachter zu …?',
    answer: MultipleChoice(
      options: ['Urteil', 'Gutachten', 'Verfahren', 'Beweis'],
      correctIndex: 1,
    ),
    explanation: 'Jeweils die Person und das, was sie beisteuert. Ein Urteil '
        'spricht das Gericht, nicht der Gutachter.',
    difficulty: Difficulty.hard,
  ),

  // ---------------------------------------------------------------
  // Grammatik
  // ---------------------------------------------------------------
  Question(
    id: 'pro_lang_gram_01',
    subCategory: SubCategory.grammar,
    prompt: 'Welcher Satz ist grammatisch richtig?',
    answer: MultipleChoice(
      options: [
        'Wegen dem Unwetter fiel die Prüfung aus.',
        'Wegen des Unwetters fiel die Prüfung aus.',
        'Wegen dem Unwetter fiel die Prüfung weg.',
        'Wegen der Unwetter fiel die Prüfung aus.',
      ],
      correctIndex: 1,
    ),
    explanation: '„Wegen" verlangt in der Standardsprache den Genitiv: '
        '„wegen des Unwetters".',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'pro_lang_gram_02',
    subCategory: SubCategory.grammar,
    prompt: 'Welcher Satz ist grammatisch richtig?',
    answer: MultipleChoice(
      options: [
        'Er half dem Kollegen, den er gestern kennengelernt hat.',
        'Er half den Kollegen, den er gestern kennengelernt hat.',
        'Er half dem Kollegen, dem er gestern kennengelernt hat.',
        'Er half der Kollege, den er gestern kennengelernt hat.',
      ],
      correctIndex: 0,
    ),
    explanation: '„helfen" verlangt den Dativ („dem Kollegen"), '
        '„kennenlernen" den Akkusativ („den").',
    difficulty: Difficulty.hard,
  ),
  Question(
    id: 'pro_lang_gram_03',
    subCategory: SubCategory.grammar,
    prompt: 'Welche Form ist richtig?',
    answer: MultipleChoice(
      options: [
        'Ich habe den Termin vergessen gehabt.',
        'Ich hatte den Termin vergessen.',
        'Ich habe den Termin vergaß.',
        'Ich hatte den Termin vergessen gehabt.',
      ],
      correctIndex: 1,
    ),
    explanation: 'Das Plusquamperfekt lautet „hatte … vergessen". Die '
        'Doppelformen sind umgangssprachlich.',
    difficulty: Difficulty.medium,
  ),

  // ---------------------------------------------------------------
  // Wortschatz und Textverständnis
  // ---------------------------------------------------------------
  Question(
    id: 'pro_lang_voc_01',
    subCategory: SubCategory.vocabulary,
    prompt: 'Was bedeutet „revidieren"?',
    answer: MultipleChoice(
      options: [
        'wiederholen',
        'überprüfen und ändern',
        'ablehnen',
        'weiterleiten',
      ],
      correctIndex: 1,
    ),
    explanation: '„Revidieren" heißt, eine Entscheidung oder Annahme zu '
        'überprüfen und zu korrigieren.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'pro_lang_voc_02',
    subCategory: SubCategory.vocabulary,
    prompt: 'Was bedeutet „substanziell"?',
    answer: MultipleChoice(
      options: ['nebensächlich', 'wesentlich', 'vorläufig', 'strittig'],
      correctIndex: 1,
    ),
    explanation: '„Substanziell" bezeichnet das, was die Substanz betrifft – '
        'also wesentlich ist.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'pro_lang_voc_03',
    subCategory: SubCategory.vocabulary,
    prompt: 'Ein Bericht stellt fest: „Die Zahl der Anträge ist gegenüber '
        'dem Vorjahr rückläufig, der Bearbeitungsstau hat dennoch '
        'zugenommen."\nWas lässt sich daraus schließen?',
    answer: MultipleChoice(
      options: [
        'Es gehen mehr Anträge ein als früher.',
        'Die Bearbeitung dauert länger als früher.',
        'Der Stau ist durch mehr Anträge entstanden.',
        'Die Anträge sind schwieriger geworden.',
      ],
      correctIndex: 1,
    ),
    explanation: 'Weniger Anträge und trotzdem mehr Stau bedeutet, dass die '
        'Bearbeitung langsamer geworden sein muss. Warum, sagt der Text nicht.',
    difficulty: Difficulty.hard,
  ),
  Question(
    id: 'pro_lang_voc_04',
    subCategory: SubCategory.vocabulary,
    prompt: 'Was bedeutet „konsequent"?',
    answer: MultipleChoice(
      options: [
        'folgerichtig und beharrlich',
        'nachträglich',
        'gelegentlich',
        'nachgiebig',
      ],
      correctIndex: 0,
    ),
    explanation: 'Wer konsequent handelt, bleibt bei dem, was aus seinen '
        'Grundsätzen folgt.',
    difficulty: Difficulty.easy,
  ),
];
