import 'package:einstellungstest_trainer/models/question.dart';
import 'package:einstellungstest_trainer/models/sub_category.dart';

/// Startpool Sprache – handgeschrieben, durchgängig Multiple Choice.
const List<Question> languageQuestions = [
  // ---------------------------------------------------------------
  // Rechtschreibung
  // ---------------------------------------------------------------
  Question(
    id: 'lang_spell_01',
    subCategory: SubCategory.spelling,
    prompt: 'Welches Wort ist richtig geschrieben?',
    answer: MultipleChoice(
      options: ['Rytmus', 'Rhytmus', 'Rhythmus', 'Rythmus'],
      correctIndex: 2,
    ),
    explanation: 'Korrekt ist "Rhythmus" – mit "Rh" am Anfang und "th" in der '
        'Mitte.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'lang_spell_02',
    subCategory: SubCategory.spelling,
    prompt: 'Welches Wort ist richtig geschrieben?',
    answer: MultipleChoice(
      options: ['Standart', 'Standard', 'Standardt', 'Stantard'],
      correctIndex: 1,
    ),
    explanation: 'Korrekt ist "Standard" mit "d" am Ende. '
        'Mit "t" geschrieben ("Standarte") bezeichnet es eine Fahne.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'lang_spell_03',
    subCategory: SubCategory.spelling,
    prompt: 'Welches Wort ist richtig geschrieben?',
    answer: MultipleChoice(
      options: [
        'vorraussichtlich',
        'voraussichtlich',
        'vorrausichtlich',
        'voraussichtlig',
      ],
      correctIndex: 1,
    ),
    explanation: 'Das Wort wird aus "voraus" und "sichtlich" gebildet – '
        'also nur ein "r".',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'lang_spell_04',
    subCategory: SubCategory.spelling,
    prompt: 'Welches Wort ist richtig geschrieben?',
    answer: MultipleChoice(
      options: ['Adresse', 'Addresse', 'Adreße', 'Addreße'],
      correctIndex: 0,
    ),
    explanation: 'Korrekt ist "Adresse" – ein "d", zwei "s".',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'lang_spell_05',
    subCategory: SubCategory.spelling,
    prompt: 'Welches Wort ist richtig geschrieben?',
    answer: MultipleChoice(
      options: ['interessant', 'intressant', 'interresant', 'interessannt'],
      correctIndex: 0,
    ),
    explanation: 'Korrekt ist "interessant" – ein "r", zwei "s".',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'lang_spell_06',
    subCategory: SubCategory.spelling,
    prompt: 'Ergänzen Sie richtig:\n"___ ihr schon lange hier?"',
    answer: MultipleChoice(
      options: ['Seit', 'Seid', 'Seidt', 'Sait'],
      correctIndex: 1,
    ),
    explanation: '"Seid" ist die Verbform von "sein" (ihr seid). '
        '"Seit" bezeichnet dagegen einen Zeitpunkt.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'lang_spell_07',
    subCategory: SubCategory.spelling,
    prompt: 'Ergänzen Sie richtig:\n"Ich hoffe, ___ du pünktlich kommst."',
    answer: MultipleChoice(
      options: ['das', 'dass', 'daß', 'das s'],
      correctIndex: 1,
    ),
    explanation: 'Hier leitet die Konjunktion "dass" einen Nebensatz ein. '
        'Die Schreibweise "daß" ist seit der Rechtschreibreform veraltet.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'lang_spell_08',
    subCategory: SubCategory.spelling,
    prompt: 'Welches Wort ist richtig geschrieben?',
    answer: MultipleChoice(
      options: ['Terasse', 'Terrase', 'Terrasse', 'Teraße'],
      correctIndex: 2,
    ),
    explanation: 'Korrekt ist "Terrasse" – doppeltes "r" und doppeltes "s".',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'lang_spell_09',
    subCategory: SubCategory.spelling,
    prompt: 'Welches Wort ist richtig geschrieben?',
    answer: MultipleChoice(
      options: ['Diskusion', 'Diskussion', 'Discussion', 'Diskußion'],
      correctIndex: 1,
    ),
    explanation: 'Korrekt ist "Diskussion" mit "k" und doppeltem "s".',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'lang_spell_10',
    subCategory: SubCategory.spelling,
    prompt: 'Welches Wort ist richtig geschrieben?',
    answer: MultipleChoice(
      options: ['Kompromis', 'Kompromiß', 'Kompromiss', 'Kommpromiss'],
      correctIndex: 2,
    ),
    explanation: 'Nach kurzem Vokal steht "ss": "Kompromiss".',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'lang_spell_11',
    subCategory: SubCategory.spelling,
    prompt: 'Welches Wort ist richtig geschrieben?',
    answer: MultipleChoice(
      options: ['Bibiliothek', 'Biblothek', 'Bibliothek', 'Bibliotek'],
      correctIndex: 2,
    ),
    explanation: 'Korrekt ist "Bibliothek" – mit "bli" und "th".',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'lang_spell_12',
    subCategory: SubCategory.spelling,
    prompt: 'Welches Wort ist richtig geschrieben?',
    answer: MultipleChoice(
      options: ['Katastrofe', 'Kathastrophe', 'Katastrophie', 'Katastrophe'],
      correctIndex: 3,
    ),
    explanation: 'Korrekt ist "Katastrophe" – ohne "h" nach dem "K", '
        'aber mit "ph".',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'lang_spell_13',
    subCategory: SubCategory.spelling,
    prompt: 'Welches Wort ist richtig geschrieben?',
    answer: MultipleChoice(
      options: ['Orginal', 'Original', 'Origenal', 'Originahl'],
      correctIndex: 1,
    ),
    explanation: 'Korrekt ist "Original" – das "i" nach dem "g" wird oft '
        'verschluckt.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'lang_spell_14',
    subCategory: SubCategory.spelling,
    prompt: 'Welches Wort ist richtig geschrieben?',
    answer: MultipleChoice(
      options: ['seperat', 'sepparat', 'separat', 'seprat'],
      correctIndex: 2,
    ),
    explanation: 'Korrekt ist "separat" – mit "a" in der Mitte, '
        'von lateinisch "separare".',
    difficulty: Difficulty.hard,
  ),
  Question(
    id: 'lang_spell_15',
    subCategory: SubCategory.spelling,
    prompt: 'Welches Wort ist richtig geschrieben?',
    answer: MultipleChoice(
      options: ['Ingeneur', 'Ingeniör', 'Injenieur', 'Ingenieur'],
      correctIndex: 3,
    ),
    explanation: 'Korrekt ist "Ingenieur" – die französische Schreibweise '
        'mit "ieur" am Ende.',
    difficulty: Difficulty.hard,
  ),
  Question(
    id: 'lang_spell_16',
    subCategory: SubCategory.spelling,
    prompt: 'Welches Wort ist richtig geschrieben?',
    answer: MultipleChoice(
      options: ['Reperatur', 'Reparatur', 'Repperatur', 'Reparathur'],
      correctIndex: 1,
    ),
    explanation: 'Korrekt ist "Reparatur" – abgeleitet von "reparieren", '
        'also mit "a" in der zweiten Silbe.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'lang_spell_17',
    subCategory: SubCategory.spelling,
    prompt: 'Welches Wort ist richtig geschrieben?',
    answer: MultipleChoice(
      options: ['Machine', 'Maschiene', 'Maschine', 'Masine'],
      correctIndex: 2,
    ),
    explanation: 'Korrekt ist "Maschine" – mit "sch" und ohne "ie".',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'lang_spell_18',
    subCategory: SubCategory.spelling,
    prompt: 'Welches Wort ist richtig geschrieben?',
    answer: MultipleChoice(
      options: [
        'proffessionell',
        'professionel',
        'profesionell',
        'professionell',
      ],
      correctIndex: 3,
    ),
    explanation: 'Korrekt ist "professionell" – ein "f", doppeltes "s", '
        'doppeltes "l".',
    difficulty: Difficulty.hard,
  ),
  Question(
    id: 'lang_spell_19',
    subCategory: SubCategory.spelling,
    prompt: 'Welches Wort ist FALSCH geschrieben?',
    answer: MultipleChoice(
      options: ['Gelegenheit', 'Verantwortung', 'Vorraussetzung', 'Bewerbung'],
      correctIndex: 2,
    ),
    explanation: '"Vorraussetzung" ist falsch. Richtig ist "Voraussetzung" – '
        'aus "voraus" und "Setzung", also nur ein "r".',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'lang_spell_20',
    subCategory: SubCategory.spelling,
    prompt: 'Welches Wort ist FALSCH geschrieben?',
    answer: MultipleChoice(
      options: ['Qualifikation', 'Referenz', 'Zeugniss', 'Anschreiben'],
      correctIndex: 2,
    ),
    explanation: '"Zeugniss" ist falsch. Richtig ist "Zeugnis" – '
        'am Wortende steht hier nur ein "s".',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'lang_spell_21',
    subCategory: SubCategory.spelling,
    prompt: 'Ergänzen Sie richtig:\n'
        '"Das Ergebnis läuft ___ meinen Erwartungen."',
    answer: MultipleChoice(
      options: ['wieder', 'wider', 'widder', 'wiedter'],
      correctIndex: 1,
    ),
    explanation: '"Wider" bedeutet "gegen". "Wieder" heißt dagegen "erneut".',
    difficulty: Difficulty.hard,
  ),

  // ---------------------------------------------------------------
  // Wortanalogien
  // ---------------------------------------------------------------
  Question(
    id: 'lang_ana_01',
    subCategory: SubCategory.wordAnalogies,
    prompt: 'Arzt verhält sich zu Krankenhaus wie Lehrer zu …?',
    answer: MultipleChoice(
      options: ['Klasse', 'Schule', 'Buch', 'Schüler'],
      correctIndex: 1,
    ),
    explanation: 'Das Verhältnis ist "Beruf : Arbeitsstätte". '
        'Die Arbeitsstätte einer Lehrkraft ist die Schule.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'lang_ana_02',
    subCategory: SubCategory.wordAnalogies,
    prompt: 'Auge verhält sich zu sehen wie Ohr zu …?',
    answer: MultipleChoice(
      options: ['riechen', 'hören', 'sprechen', 'fühlen'],
      correctIndex: 1,
    ),
    explanation: 'Das Verhältnis ist "Sinnesorgan : zugehörige Wahrnehmung". '
        'Mit dem Ohr wird gehört.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'lang_ana_03',
    subCategory: SubCategory.wordAnalogies,
    prompt: 'Hand verhält sich zu Finger wie Fuß zu …?',
    answer: MultipleChoice(
      options: ['Bein', 'Ferse', 'Zehe', 'Knie'],
      correctIndex: 2,
    ),
    explanation: 'Das Verhältnis ist "Körperteil : dessen Endglieder". '
        'Zur Hand gehören Finger, zum Fuß Zehen.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'lang_ana_04',
    subCategory: SubCategory.wordAnalogies,
    prompt: 'Kilometer verhält sich zu Entfernung wie Kilogramm zu …?',
    answer: MultipleChoice(
      options: ['Volumen', 'Gewicht', 'Länge', 'Zeit'],
      correctIndex: 1,
    ),
    explanation: 'Das Verhältnis ist "Einheit : gemessene Größe". '
        'Kilogramm misst das Gewicht bzw. die Masse.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'lang_ana_05',
    subCategory: SubCategory.wordAnalogies,
    prompt: 'Buch verhält sich zu Autor wie Gemälde zu …?',
    answer: MultipleChoice(
      options: ['Museum', 'Maler', 'Rahmen', 'Farbe'],
      correctIndex: 1,
    ),
    explanation: 'Das Verhältnis ist "Werk : Urheber". '
        'Ein Gemälde stammt vom Maler.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'lang_ana_06',
    subCategory: SubCategory.wordAnalogies,
    prompt: 'Hund verhält sich zu bellen wie Katze zu …?',
    answer: MultipleChoice(
      options: ['schnurren', 'miauen', 'fauchen', 'jaulen'],
      correctIndex: 1,
    ),
    explanation: 'Das Verhältnis ist "Tier : typischer Laut". '
        'Bellen ist der Ruf des Hundes, Miauen der der Katze.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'lang_ana_07',
    subCategory: SubCategory.wordAnalogies,
    prompt: 'Vogel verhält sich zu Nest wie Biene zu …?',
    answer: MultipleChoice(
      options: ['Blüte', 'Bienenstock', 'Honig', 'Schwarm'],
      correctIndex: 1,
    ),
    explanation: 'Das Verhältnis ist "Tier : Behausung". '
        'Die Biene lebt im Bienenstock.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'lang_ana_08',
    subCategory: SubCategory.wordAnalogies,
    prompt: 'heiß verhält sich zu kalt wie hell zu …?',
    answer: MultipleChoice(
      options: ['grell', 'dunkel', 'warm', 'trüb'],
      correctIndex: 1,
    ),
    explanation: 'Das Verhältnis ist "Gegensatzpaar". '
        'Der Gegensatz zu hell ist dunkel.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'lang_ana_09',
    subCategory: SubCategory.wordAnalogies,
    prompt: 'Messer verhält sich zu schneiden wie Stift zu …?',
    answer: MultipleChoice(
      options: ['spitzen', 'schreiben', 'halten', 'radieren'],
      correctIndex: 1,
    ),
    explanation: 'Das Verhältnis ist "Werkzeug : Zweck". '
        'Ein Stift dient zum Schreiben.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'lang_ana_10',
    subCategory: SubCategory.wordAnalogies,
    prompt: 'Soldat verhält sich zu Armee wie Baum zu …?',
    answer: MultipleChoice(
      options: ['Wurzel', 'Wald', 'Blatt', 'Holz'],
      correctIndex: 1,
    ),
    explanation: 'Das Verhältnis ist "Einzelnes : Gesamtheit". '
        'Viele Bäume bilden einen Wald.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'lang_ana_11',
    subCategory: SubCategory.wordAnalogies,
    prompt: 'Durst verhält sich zu trinken wie Müdigkeit zu …?',
    answer: MultipleChoice(
      options: ['gähnen', 'schlafen', 'ausruhen', 'liegen'],
      correctIndex: 1,
    ),
    explanation: 'Das Verhältnis ist "Bedürfnis : die Handlung, die es '
        'stillt". Durst wird durch Trinken gestillt, Müdigkeit durch Schlafen.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'lang_ana_12',
    subCategory: SubCategory.wordAnalogies,
    prompt: 'Bäcker verhält sich zu Brot wie Schuster zu …?',
    answer: MultipleChoice(
      options: ['Leder', 'Schuh', 'Werkstatt', 'Hammer'],
      correctIndex: 1,
    ),
    explanation: 'Das Verhältnis ist "Handwerker : hergestelltes Produkt". '
        'Der Schuster fertigt Schuhe.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'lang_ana_13',
    subCategory: SubCategory.wordAnalogies,
    prompt: 'Fisch verhält sich zu Wasser wie Vogel zu …?',
    answer: MultipleChoice(
      options: ['Baum', 'Luft', 'Feder', 'Himmel'],
      correctIndex: 1,
    ),
    explanation: 'Das Verhältnis ist "Tier : Element, in dem es sich '
        'fortbewegt". Der Fisch schwimmt im Wasser, der Vogel fliegt in der '
        'Luft.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'lang_ana_14',
    subCategory: SubCategory.wordAnalogies,
    prompt: 'Anfang verhält sich zu Ende wie Geburt zu …?',
    answer: MultipleChoice(
      options: ['Leben', 'Tod', 'Kindheit', 'Alter'],
      correctIndex: 1,
    ),
    explanation: 'Das Verhältnis ist "Beginn : Abschluss". '
        'Die Geburt steht am Anfang des Lebens, der Tod an dessen Ende.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'lang_ana_15',
    subCategory: SubCategory.wordAnalogies,
    prompt: 'Auto verhält sich zu Straße wie Zug zu …?',
    answer: MultipleChoice(
      options: ['Bahnhof', 'Schiene', 'Lokomotive', 'Fahrplan'],
      correctIndex: 1,
    ),
    explanation: 'Das Verhältnis ist "Fahrzeug : Fahrweg". '
        'Der Zug fährt auf Schienen.',
    difficulty: Difficulty.easy,
  ),

  // ---------------------------------------------------------------
  // Grammatik
  // ---------------------------------------------------------------
  Question(
    id: 'lang_gram_01',
    subCategory: SubCategory.grammar,
    prompt: 'Ergänzen Sie richtig:\n"Wegen ___ Wetters fiel das Training aus."',
    answer: MultipleChoice(
      options: [
        'dem schlechten',
        'des schlechten',
        'das schlechte',
        'der schlechte',
      ],
      correctIndex: 1,
    ),
    explanation: '"Wegen" verlangt den Genitiv: "wegen des schlechten Wetters".',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'lang_gram_02',
    subCategory: SubCategory.grammar,
    prompt: 'Ergänzen Sie richtig:\n"Ich erinnere mich ___ den Termin."',
    answer: MultipleChoice(
      options: ['auf', 'an', 'über', 'für'],
      correctIndex: 1,
    ),
    explanation: '"Sich erinnern" wird mit der Präposition "an" verwendet.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'lang_gram_03',
    subCategory: SubCategory.grammar,
    prompt: 'Welcher Satz ist grammatikalisch korrekt?',
    answer: MultipleChoice(
      options: [
        'Er half mir, den Karton zu tragen.',
        'Er half mich, den Karton zu tragen.',
        'Er half mir den Karton tragen.',
        'Er half mich den Karton tragen.',
      ],
      correctIndex: 0,
    ),
    explanation: '"Helfen" verlangt den Dativ ("mir"), und der Infinitiv wird '
        'mit "zu" angeschlossen.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'lang_gram_04',
    subCategory: SubCategory.grammar,
    prompt: 'Welche Form ist die korrekte indirekte Rede (Konjunktiv I) '
        'zu "Er kommt später"?',
    answer: MultipleChoice(
      options: ['er kommt', 'er komme', 'er käme', 'er kam'],
      correctIndex: 1,
    ),
    explanation: 'Der Konjunktiv I lautet "er komme". '
        '"Käme" ist Konjunktiv II und wird nur als Ersatzform genutzt.',
    difficulty: Difficulty.hard,
  ),
  Question(
    id: 'lang_gram_05',
    subCategory: SubCategory.grammar,
    prompt: 'Wie lautet "Die Behörde prüft den Antrag" im Passiv?',
    answer: MultipleChoice(
      options: [
        'Der Antrag prüft die Behörde.',
        'Der Antrag wird von der Behörde geprüft.',
        'Der Antrag ist von der Behörde geprüft.',
        'Die Behörde wird den Antrag geprüft.',
      ],
      correctIndex: 1,
    ),
    explanation: 'Im Vorgangspassiv wird das Objekt zum Subjekt: '
        '"Der Antrag wird von der Behörde geprüft."',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'lang_gram_06',
    subCategory: SubCategory.grammar,
    prompt: 'Welcher Satz ist richtig kommasiert?',
    answer: MultipleChoice(
      options: [
        'Er nahm den Bus weil sein Auto defekt war.',
        'Er nahm den Bus, weil sein Auto defekt war.',
        'Er nahm, den Bus weil sein Auto defekt war.',
        'Er nahm den Bus weil, sein Auto defekt war.',
      ],
      correctIndex: 1,
    ),
    explanation: 'Vor einem mit "weil" eingeleiteten Nebensatz steht ein Komma.',
    difficulty: Difficulty.easy,
  ),

  // ---------------------------------------------------------------
  // Wortschatz & Textverständnis
  // ---------------------------------------------------------------
  Question(
    id: 'lang_voc_01',
    subCategory: SubCategory.vocabulary,
    prompt: 'Was bedeutet "obsolet"?',
    answer: MultipleChoice(
      options: ['dringend', 'veraltet', 'verbindlich', 'freiwillig'],
      correctIndex: 1,
    ),
    explanation: '"Obsolet" bedeutet veraltet bzw. überholt.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'lang_voc_02',
    subCategory: SubCategory.vocabulary,
    prompt: 'Was bedeutet "kongruent"?',
    answer: MultipleChoice(
      options: ['gegensätzlich', 'übereinstimmend', 'unklar', 'vorläufig'],
      correctIndex: 1,
    ),
    explanation: '"Kongruent" bedeutet deckungsgleich bzw. übereinstimmend.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'lang_voc_03',
    subCategory: SubCategory.vocabulary,
    prompt: 'Was bedeutet "Diskrepanz"?',
    answer: MultipleChoice(
      options: [
        'Übereinstimmung',
        'Abweichung',
        'Entscheidung',
        'Zusammenfassung',
      ],
      correctIndex: 1,
    ),
    explanation: 'Eine "Diskrepanz" ist ein Widerspruch bzw. eine Abweichung '
        'zwischen zwei Dingen.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'lang_voc_04',
    subCategory: SubCategory.vocabulary,
    prompt: 'Was bedeutet "Prämisse"?',
    answer: MultipleChoice(
      options: ['Schlussfolgerung', 'Voraussetzung', 'Ausnahme', 'Belohnung'],
      correctIndex: 1,
    ),
    explanation: 'Eine "Prämisse" ist eine Voraussetzung oder Annahme, aus der '
        'eine Schlussfolgerung gezogen wird.',
    difficulty: Difficulty.hard,
  ),
  Question(
    id: 'lang_voc_05',
    subCategory: SubCategory.vocabulary,
    prompt: 'Welches Wort ist ein Synonym für "akribisch"?',
    answer: MultipleChoice(
      options: ['nachlässig', 'sorgfältig', 'hastig', 'zufällig'],
      correctIndex: 1,
    ),
    explanation: '"Akribisch" bedeutet äußerst sorgfältig und genau.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'lang_voc_06',
    subCategory: SubCategory.vocabulary,
    prompt: 'Was ist das Gegenteil von "transparent"?',
    answer: MultipleChoice(
      options: ['durchsichtig', 'undurchsichtig', 'offen', 'nachvollziehbar'],
      correctIndex: 1,
    ),
    explanation: '"Transparent" bedeutet durchsichtig bzw. nachvollziehbar – '
        'das Gegenteil ist "undurchsichtig".',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'lang_voc_07',
    subCategory: SubCategory.vocabulary,
    prompt: 'Lesen Sie den Text:\n'
        '"Anträge werden nur bearbeitet, wenn sie vollständig ausgefüllt und '
        'fristgerecht eingereicht wurden. Unvollständige Anträge werden ohne '
        'weitere Rückfrage zurückgesendet."\n\n'
        'Was geschieht mit einem vollständigen Antrag, der zu spät eingeht?',
    answer: MultipleChoice(
      options: [
        'Er wird bearbeitet.',
        'Er wird nicht bearbeitet.',
        'Es wird eine Rückfrage gestellt.',
        'Das geht aus dem Text nicht hervor.',
      ],
      correctIndex: 1,
    ),
    explanation: 'Die Bearbeitung setzt beide Bedingungen voraus: vollständig '
        'UND fristgerecht. Fehlt die Frist, wird nicht bearbeitet.',
    difficulty: Difficulty.hard,
  ),
  Question(
    id: 'lang_voc_08',
    subCategory: SubCategory.vocabulary,
    prompt: 'Lesen Sie den Text:\n'
        '"Mitarbeitende, die an der Schulung teilnehmen, erhalten die '
        'Fahrtkosten erstattet. Eine Erstattung der Übernachtungskosten '
        'erfolgt nur bei einer Anreise von mehr als 200 Kilometern."\n\n'
        'Wer bekommt die Übernachtungskosten erstattet?',
    answer: MultipleChoice(
      options: [
        'Alle Teilnehmenden',
        'Nur Teilnehmende mit mehr als 200 km Anreise',
        'Nur Teilnehmende mit weniger als 200 km Anreise',
        'Niemand',
      ],
      correctIndex: 1,
    ),
    explanation: 'Die Fahrtkosten bekommen alle Teilnehmenden, die '
        'Übernachtungskosten aber nur bei über 200 km Anreise.',
    difficulty: Difficulty.medium,
  ),
];
