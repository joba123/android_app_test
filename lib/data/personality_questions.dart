import 'package:einstellungstest_trainer/models/question.dart';
import 'package:einstellungstest_trainer/models/sub_category.dart';

/// Startpool Persönlichkeitstest.
///
/// Wichtig: Hier wird **nicht** die Persönlichkeit gemessen. Die App bewertet
/// niemanden – sie erklärt, wie solche Fragebogen aufgebaut sind und woran
/// Auswerter hängenbleiben. Deshalb Wissensfragen mit einer richtigen
/// Antwort, wie im übrigen Bestand.
///
/// Die Aussagen stützen sich auf das, was in Auswahlverfahren gängige Praxis
/// ist: Kontrollskalen gegen Schönfärberei, wiederholte Fragen zur Prüfung
/// der Konsistenz, Verhaltensfragen statt Selbstlob.
const List<Question> personalityQuestions = [
  // ---------------------------------------------------------------
  // Wie Tests gewertet werden
  // ---------------------------------------------------------------
  Question(
    id: 'pers_basic_01',
    subCategory: SubCategory.personalityBasics,
    prompt: 'Wozu dient eine "Lügenskala" (Kontrollskala) im '
        'Persönlichkeitsfragebogen?',
    answer: MultipleChoice(
      options: [
        'Sie erkennt, ob jemand durchgehend sozial erwünscht antwortet',
        'Sie misst die Ehrlichkeit im Lebenslauf',
        'Sie prüft das Fachwissen',
        'Sie bewertet die Schnelligkeit beim Ausfüllen',
      ],
      correctIndex: 0,
    ),
    explanation: 'Kontrollskalen enthalten Aussagen, die praktisch auf '
        'niemanden zutreffen ("Ich habe noch nie gelogen"). Wer sie alle '
        'bejaht, gilt als geschönt – der Fragebogen wird dann entwertet.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'pers_basic_02',
    subCategory: SubCategory.personalityBasics,
    prompt: 'Warum tauchen in Persönlichkeitstests ähnliche Fragen mehrfach '
        'auf?',
    answer: MultipleChoice(
      options: [
        'Um zu prüfen, ob die Antworten in sich stimmig sind',
        'Um die Bearbeitungszeit zu strecken',
        'Weil die Fragebogen fehlerhaft zusammengesetzt sind',
        'Um das Gedächtnis zu testen',
      ],
      correctIndex: 0,
    ),
    explanation: 'Dieselbe Eigenschaft wird aus mehreren Richtungen abgefragt. '
        'Wer sich widerspricht, erzeugt ein unklares Profil.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'pers_basic_03',
    subCategory: SubCategory.personalityBasics,
    prompt: 'Welche fünf Merkmale beschreibt das gängige "Big Five"-Modell?',
    answer: MultipleChoice(
      options: [
        'Offenheit, Gewissenhaftigkeit, Extraversion, Verträglichkeit, '
            'Neurotizismus',
        'Intelligenz, Fleiß, Tempo, Ausdauer, Mut',
        'Führung, Teamgeist, Ehrgeiz, Ordnung, Humor',
        'Wissen, Können, Wollen, Dürfen, Sollen',
      ],
      correctIndex: 0,
    ),
    explanation: 'Die Big Five sind der Standard in der Eignungsdiagnostik. '
        'Viele Fragebogen sind daran angelehnt.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'pers_basic_04',
    subCategory: SubCategory.personalityBasics,
    prompt: 'Gibt es in einem Persönlichkeitsfragebogen "richtige" Antworten?',
    answer: MultipleChoice(
      options: [
        'Nein, aber es gibt Profile, die zur Stelle passen oder nicht',
        'Ja, jede Frage hat genau eine richtige Antwort',
        'Ja, die Antwort in der Mitte ist immer richtig',
        'Nein, das Ergebnis spielt für die Auswahl keine Rolle',
      ],
      correctIndex: 0,
    ),
    explanation: 'Gemessen wird die Passung zum Anforderungsprofil. Für eine '
        'Stelle im Schichtdienst zählt anderes als für den Außendienst.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'pers_basic_05',
    subCategory: SubCategory.personalityBasics,
    prompt: 'Wie geht man mit dem Zeitdruck in Persönlichkeitstests um?',
    answer: MultipleChoice(
      options: [
        'Zügig und spontan antworten – langes Abwägen erzeugt Widersprüche',
        'Jede Frage mehrfach lesen und lange abwägen',
        'Erst alle Fragen lesen, dann rückwärts antworten',
        'Nur die Fragen beantworten, bei denen man sicher ist',
      ],
      correctIndex: 0,
    ),
    explanation: 'Der erste Impuls ist meist der konsistenteste. Wer taktiert, '
        'verliert den roten Faden über hunderte Aussagen.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'pers_basic_06',
    subCategory: SubCategory.personalityBasics,
    prompt: 'Was passiert, wenn Fragen unbeantwortet bleiben?',
    answer: MultipleChoice(
      options: [
        'Das Profil wird unvollständig und kann als nicht auswertbar gelten',
        'Die Fragen werden als "trifft nicht zu" gewertet',
        'Es hat keine Folgen',
        'Die Bearbeitungszeit verlängert sich',
      ],
      correctIndex: 0,
    ),
    explanation: 'Viele Verfahren verlangen eine vollständige Bearbeitung. '
        'Lücken machen das Ergebnis unbrauchbar.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'pers_basic_07',
    subCategory: SubCategory.personalityBasics,
    prompt: 'Was ist ein "situatives Urteilsverfahren" (Situational Judgement '
        'Test)?',
    answer: MultipleChoice(
      options: [
        'Man beurteilt Handlungsmöglichkeiten in geschilderten Situationen',
        'Man schätzt die eigene Stimmung über den Tag ein',
        'Man löst Rechenaufgaben unter Beobachtung',
        'Man beschreibt seinen Lebenslauf frei',
      ],
      correctIndex: 0,
    ),
    explanation: 'Typisch: eine kurze Szene aus dem Arbeitsalltag und vier '
        'Reaktionen, die nach Angemessenheit sortiert werden sollen.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'pers_basic_08',
    subCategory: SubCategory.personalityBasics,
    prompt: 'Was bedeutet "Zustimmungstendenz" (Akquieszenz)?',
    answer: MultipleChoice(
      options: [
        'Die Neigung, Aussagen unabhängig vom Inhalt zuzustimmen',
        'Die Neigung, immer die Mitte anzukreuzen',
        'Die Neigung, Fragen zu überspringen',
        'Die Neigung, sich schlechter darzustellen',
      ],
      correctIndex: 0,
    ),
    explanation: 'Deshalb enthalten gute Fragebogen umgepolte Aussagen: Wer '
        'überall zustimmt, widerspricht sich dort automatisch.',
    difficulty: Difficulty.hard,
  ),
  Question(
    id: 'pers_basic_09',
    subCategory: SubCategory.personalityBasics,
    prompt: 'Dürfen Arbeitgeber in Deutschland beliebige persönliche Fragen '
        'stellen?',
    answer: MultipleChoice(
      options: [
        'Nein, die Fragen müssen einen Bezug zur Stelle haben',
        'Ja, im Auswahlverfahren gilt Vertragsfreiheit',
        'Ja, sofern der Test anonym ausgewertet wird',
        'Nein, Persönlichkeitstests sind generell unzulässig',
      ],
      correctIndex: 0,
    ),
    explanation: 'Fragen ohne Bezug zur Tätigkeit – etwa nach Religion oder '
        'Familienplanung – sind unzulässig.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'pers_basic_10',
    subCategory: SubCategory.personalityBasics,
    prompt: 'Was misst die Skala "Gewissenhaftigkeit" typischerweise?',
    answer: MultipleChoice(
      options: [
        'Sorgfalt, Ordnung und Zuverlässigkeit bei der Arbeit',
        'Das Gewissen im moralischen Sinn',
        'Die Fähigkeit, Regeln zu umgehen',
        'Die Belastbarkeit unter Stress',
      ],
      correctIndex: 0,
    ),
    explanation: 'Gewissenhaftigkeit sagt in Studien am zuverlässigsten den '
        'Berufserfolg voraus – deshalb wird sie fast immer erhoben.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'pers_basic_11',
    subCategory: SubCategory.personalityBasics,
    prompt: 'Was bedeutet die Antwortmöglichkeit "teils, teils" für die '
        'Auswertung?',
    answer: MultipleChoice(
      options: [
        'Sie liefert wenig Information – zu viele Mitten machen das Profil '
            'unscharf',
        'Sie zählt als Zustimmung',
        'Sie zählt als Ablehnung',
        'Sie wird aus der Wertung genommen',
      ],
      correctIndex: 0,
    ),
    explanation: 'Wer überall die Mitte wählt, erzeugt ein flaches Profil ohne '
        'Aussage. Klare Antworten sind aussagekräftiger.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'pers_basic_12',
    subCategory: SubCategory.personalityBasics,
    prompt: 'Wie lange dauert ein typischer Persönlichkeitsfragebogen im '
        'Auswahlverfahren?',
    answer: MultipleChoice(
      options: [
        '20 bis 45 Minuten bei 150 bis 300 Aussagen',
        '5 Minuten bei 20 Aussagen',
        'Mehrere Stunden bei 1.000 Aussagen',
        'Er ist unbegrenzt und wird zu Hause ausgefüllt',
      ],
      correctIndex: 0,
    ),
    explanation: 'Die Länge ist Absicht: Über hunderte Aussagen hinweg lässt '
        'sich ein geschöntes Profil kaum durchhalten.',
    difficulty: Difficulty.easy,
  ),

  // ---------------------------------------------------------------
  // Antworten einschätzen
  // ---------------------------------------------------------------
  Question(
    id: 'pers_ans_01',
    subCategory: SubCategory.personalityAnswers,
    prompt: 'Welche Antwort wirkt in einem Auswahlverfahren am '
        'unglaubwürdigsten?',
    answer: MultipleChoice(
      options: [
        '"Ich habe noch nie einen Fehler gemacht." – trifft voll zu',
        '"Ich arbeite gern im Team." – trifft eher zu',
        '"Ich werde manchmal ungeduldig." – trifft eher zu',
        '"Ordnung ist mir wichtig." – trifft zu',
      ],
      correctIndex: 0,
    ),
    explanation: 'Absolute Aussagen ohne jede Einschränkung schlagen auf die '
        'Kontrollskala an. Kleine Schwächen zuzugeben wirkt glaubwürdiger.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'pers_ans_02',
    subCategory: SubCategory.personalityAnswers,
    prompt: 'Zwei Aussagen im selben Fragebogen: "Ich halte Termine immer '
        'ein" – trifft voll zu. "Ich schiebe Aufgaben manchmal auf" – trifft '
        'voll zu. Was ist das Problem?',
    answer: MultipleChoice(
      options: [
        'Die Antworten widersprechen sich und senken die Konsistenz',
        'Beide Aussagen gehören zu verschiedenen Skalen, das ist unkritisch',
        'Es ist kein Problem, beides kann zutreffen',
        'Die zweite Aussage ist eine Fangfrage ohne Wertung',
      ],
      correctIndex: 0,
    ),
    explanation: 'Beide Aussagen messen Gewissenhaftigkeit, nur umgekehrt '
        'gepolt. Volle Zustimmung zu beidem ist ein Widerspruch.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'pers_ans_03',
    subCategory: SubCategory.personalityAnswers,
    prompt: 'Für eine Stelle im Schichtdienst mit festen Abläufen: Welche '
        'Selbsteinschätzung passt am ehesten zum Anforderungsprofil?',
    answer: MultipleChoice(
      options: [
        '"Ich arbeite gern nach klaren Vorgaben."',
        '"Ich brauche ständig neue Aufgaben, sonst langweile ich mich."',
        '"Ich entscheide lieber allein als im Team."',
        '"Regeln sehe ich eher als Empfehlung."',
      ],
      correctIndex: 0,
    ),
    explanation: 'Nicht die "beste" Persönlichkeit zählt, sondern die Passung. '
        'Im Schichtdienst sind Verlässlichkeit und Routine gefragt.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'pers_ans_04',
    subCategory: SubCategory.personalityAnswers,
    prompt: 'Situation: Ein Kollege macht wiederholt denselben Fehler. Welche '
        'Reaktion wird in situativen Verfahren meist am besten bewertet?',
    answer: MultipleChoice(
      options: [
        'Den Kollegen direkt und sachlich darauf ansprechen',
        'Den Fehler stillschweigend selbst ausbügeln',
        'Sofort die Vorgesetzten informieren',
        'Abwarten, ob es jemandem auffällt',
      ],
      correctIndex: 0,
    ),
    explanation: 'Gefragt ist der direkte, sachliche Weg auf gleicher Ebene – '
        'eskaliert wird erst, wenn das nichts ändert.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'pers_ans_05',
    subCategory: SubCategory.personalityAnswers,
    prompt: 'Situation: Sie bekommen eine Aufgabe, für die Ihnen das Wissen '
        'fehlt. Welche Reaktion wird am besten bewertet?',
    answer: MultipleChoice(
      options: [
        'Nachfragen und sich das Nötige gezielt aneignen',
        'Die Aufgabe ablehnen',
        'So tun, als sei alles klar, und improvisieren',
        'Die Aufgabe an jemand anderen weitergeben',
      ],
      correctIndex: 0,
    ),
    explanation: 'Lernbereitschaft plus Nachfragen gilt als souverän; '
        'Improvisieren ohne Grundlage als Risiko.',
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'pers_ans_06',
    subCategory: SubCategory.personalityAnswers,
    prompt: 'Wie sollte man mit Aussagen umgehen, die offensichtlich auf die '
        'Stelle gemünzt sind ("Ich bleibe auch unter Druck ruhig")?',
    answer: MultipleChoice(
      options: [
        'Ehrlich einschätzen – die Aussage taucht mehrfach umformuliert auf',
        'Immer voll zustimmen, das erwartet der Arbeitgeber',
        'Immer ablehnen, um nicht berechnend zu wirken',
        'Die Frage überspringen',
      ],
      correctIndex: 0,
    ),
    explanation: 'Dieselbe Eigenschaft wird mehrfach abgefragt. Wer taktisch '
        'antwortet, muss sich über den ganzen Bogen erinnern – das geht schief.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'pers_ans_07',
    subCategory: SubCategory.personalityAnswers,
    prompt: 'Situation: Im Team wird eine Entscheidung getroffen, die Sie für '
        'falsch halten. Welche Reaktion wird am besten bewertet?',
    answer: MultipleChoice(
      options: [
        'Bedenken einmal klar äußern und die Entscheidung dann mittragen',
        'Die Entscheidung kommentarlos hinnehmen',
        'Die Umsetzung verzögern, bis sich die Lage ändert',
        'Die Entscheidung außerhalb des Teams kritisieren',
      ],
      correctIndex: 0,
    ),
    explanation: 'Gefragt ist beides: eigene Position vertreten und '
        'Teamentscheidungen mittragen.',
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'pers_ans_08',
    subCategory: SubCategory.personalityAnswers,
    prompt: 'Welche Selbstbeschreibung ist in einem Fragebogen am wenigsten '
        'hilfreich?',
    answer: MultipleChoice(
      options: [
        'Durchgehend die Mitte ("teils, teils") bei allen Aussagen',
        'Eine Mischung aus Zustimmung und Ablehnung',
        'Klare Zustimmung bei Stärken, klare Ablehnung bei Schwächen',
        'Vereinzelte Mitte bei Aussagen, die wirklich unklar sind',
      ],
      correctIndex: 0,
    ),
    explanation: 'Ein durchgehend neutrales Profil ist nicht auswertbar und '
        'wirkt ausweichend.',
    difficulty: Difficulty.easy,
  ),
];
