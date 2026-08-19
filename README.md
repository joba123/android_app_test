# Einstellungstest Trainer

Flutter-App zur Vorbereitung auf Einstellungs- und Eignungstests bei Bewerbungen
(Polizei, Verwaltung, Bahn, Industrie und andere). Die App startet bewusst
**branchenneutral**: Trainiert werden die Aufgabentypen, die in praktisch jedem
Auswahlverfahren vorkommen. Ein Branchen-Filter kann später als zusätzliche
Dimension ergänzt werden, ohne die bestehende Struktur zu verändern.

Zielplattform ist Android, iOS ist perspektivisch vorgesehen. Es wird nichts
verwendet, was einer späteren iOS-Unterstützung im Weg steht.

## Fachrichtung, Prüfungen und Leitfaden

Beim ersten Start wird eine **Fachrichtung** gewählt (Polizei, Informatik,
BWL, Feuerwehr, Personal, Ingenieurwesen, Verwaltung, Bank, Bahn, Pflege,
Handwerk, Luftfahrt – oder Allgemein). Sie legt fest, welche Themen der
**Leitfaden** verlangt und wie streng: Kernthemen brauchen 30 beantwortete
Aufgaben, Nebenthemen 15, beide eine Trefferquote von 80 Prozent. Dazu kommt
eine bestandene Gesamtsimulation (70 Prozent). Erst dann gilt die
Vorbereitung als abgeschlossen.

Es können **mehrere Prüfungen** nebeneinander laufen – wer sich bei Polizei
und Bahn bewirbt, bereitet zwei Verfahren mit verschiedenen Anforderungen
vor. Oben im Hauptmenü wird gewechselt; jede Prüfung hat ihre eigene
Fachrichtung, ihren eigenen Leitfaden und einen **optionalen** Termin. Ohne
Termin zählt die App das Tagesziel mit, statt einen Countdown zu zeigen.

Der Fortschritt in den Themen gehört dabei zum Nutzer, nicht zur Prüfung:
Wer eine Prüfung löscht, verliert nichts von dem, was er geübt hat.

## Module

Jedes Modul bietet dieselben drei Trainingsmodi.

| Modul (Kategorie) | Unterkategorien | Antwortformat | Quelle |
| --- | --- | --- | --- |
| **Mathematik** | Grundrechenarten · Dreisatz · Prozentrechnung · Textaufgaben | Zahleneingabe | generiert (unbegrenzt) |
| **Logisches Denken** | Zahlenreihen (23 +6) · Figurenanalogien (15 +4) · Schlussfolgerungen (8 +4) · Formen & Muster | Multiple Choice | statisch, Formen generiert |
| **Sprache** | Rechtschreibung (21 +6) · Wortanalogien (15 +5) · Grammatik (6 +3) · Wortschatz & Textverständnis (8 +4) | Multiple Choice | statisch |
| **Englisch** | Vokabeln (20) · Grammatik (15) · Textverständnis (8) | Multiple Choice | statisch |
| **Konzentration** | Durchstreichtest · Zählen & Erfassen · Reihen vergleichen | eigener Bildschirm bzw. gemischt | generiert (unbegrenzt) |
| **Persönlichkeitstest** | Wie Tests gewertet werden (12) · Antworten einschätzen (8) | Multiple Choice | statisch |

**Formen & Muster** werden gezeichnet, nicht als Bild geliefert: `FigureCell`
beschreibt Form, Anzahl, Füllung und Drehung, ein `CustomPainter` malt sie.
Dadurch bleiben sie in jeder Auflösung scharf und folgen dem Hell-/Dunkelmodus.

**Der Durchstreichtest** ist der einzige Aufgabentyp mit eigenem Bildschirm:
Er stellt keine Frage, sondern eine Fläche voller Zeichen unter Zeitdruck.
Gewertet wird wie im d2 – bearbeitete Zeichen, Verwechslungen und
Auslassungen getrennt, daraus die Konzentrationsleistung.

**Der Persönlichkeitstest misst nichts.** Er erklärt, wie solche Fragebogen
aufgebaut sind und woran Auswerter hängenbleiben (Kontrollskalen,
Konsistenz, Zustimmungstendenz) – als Wissensfragen mit einer richtigen
Antwort. Eine App, die Persönlichkeit bewertet, wäre eine andere App.

Die Zahlen in Klammern mit Plus sind der Zusatzbestand für Pro – siehe
[Monetarisierung](#monetarisierung).

Eine Aufgabe wird entweder per **Multiple Choice** oder per **freier
Zahleneingabe** beantwortet. Beides steckt in einer versiegelten Hierarchie
(`AnswerFormat` mit `MultipleChoice` und `NumericInput`), sodass es keine
Aufgabe geben kann, die gleichzeitig Antwortoptionen und einen Zahlenwert
trägt. Die Zahleneingabe akzeptiert deutsche Schreibweise (Komma als
Dezimaltrennzeichen), ignoriert mitgetippte Einheiten und erlaubt pro Aufgabe
eine Toleranz für Rundungen.

Die **Kategorie einer Aufgabe wird aus ihrer Unterkategorie abgeleitet** und
nicht zusätzlich gespeichert – eine Aufgabe kann damit nicht im Modul
Mathematik liegen und „Rechtschreibung" als Unterkategorie tragen.

## Aufgabenquellen

Der Content liegt vollständig in der App; ein Backend gibt es im MVP nicht.

**Mathematik wird algorithmisch erzeugt.** Vier Generatoren in
`lib/data/generators/` liefern beliebig viele Aufgaben samt berechneter Lösung
und Rechenweg. Grundregel aller Generatoren: **rückwärts konstruieren.** Erst
steht das Ergebnis fest (bzw. die Größe, aus der es exakt folgt), dann wird die
Aufgabenstellung daraus abgeleitet. Divisionen werden aus Quotient und Divisor
aufgebaut, Geld wird in Cent gerechnet, Prozent-Grundwerte sind Vielfache von
20 bzw. 100. So kann kein krummes Ergebnis und keine nie endende Division
entstehen. Die Schwierigkeit (`easy`/`medium`/`hard`) steuert Zahlenbereiche
und Anzahl der Rechenschritte; ohne Vorgabe wird gemischt.

**Logik und Sprache kommen aus statischen Listen** – handgeschrieben, weil sich
Zahlenreihen-Muster, Figurenbeschreibungen und Rechtschreibfallen nicht sinnvoll
generieren lassen.

### Qualitätssicherung

`lib/data/question_validation.dart` ist die gemeinsame Messlatte für beide
Quellen. Geprüft wird unter anderem:

- Aufgabentext, Lösungsweg und ID sind gefüllt
- Auswahlaufgaben haben mindestens zwei **eindeutige** Optionen und einen
  gültigen Lösungsindex
- der Lösungswert lässt sich mit den vorgesehenen Nachkommastellen **exakt**
  darstellen – das fängt `1/3` und Gleitkomma-Unfälle ab, bevor sie in einer
  Aufgabe landen
- der Lösungsweg **nennt das Ergebnis** (ein Rechenweg ohne Resultat ist keiner)

Die Fabrik ruft den Validator bei jeder erzeugten Aufgabe in einem `assert` auf:
greift in Debug- und Testläufen, kostet im Release nichts. Die Tests schicken
zusätzlich mehrere tausend generierte Aufgaben hindurch und rechnen die
Grundrechen-Aufgaben mit einem unabhängigen Parser nach – geprüft wird also
nicht, ob der Generator in sich stimmig ist, sondern ob die angegebene Lösung
zur gestellten Aufgabe passt.

### Trainingsmodi

**Übungsmodus** – Lernen ohne Zeitdruck. Vor dem Start wird gewählt, **was**
geübt wird und **wie viel**:

- ein einzelnes Thema (z. B. nur Prozentrechnung)
- ein ganzes Modul mit allen seinen Themen
- alle Kategorien gemischt – Mathematik, Logik und Sprache im Wechsel

Dazu 10, 20 oder 30 Aufgaben; gibt ein Thema weniger her, wird die Runde
entsprechend kürzer. Nach jeder Antwort erscheint sofort die Rückmeldung samt
Rechenweg, erst danach geht es per „Weiter" zur nächsten Aufgabe. Der
Fortschritt steht durchgehend im Kopfbereich („Aufgabe 5/20"). Am Ende folgt die
Auswertung mit Trefferquote, **Fehlerquote**, **Ø Zeit pro Aufgabe**,
Gesamtdauer und – bei gemischten Runden – einer Aufschlüsselung nach Thema.

**Sprint-Modus** – 60 Sekunden auf **einen Aufgabentyp**, der vorher gewählt
wird („Grundrechenarten Sprint", „Zahlenreihen Sprint", …). Der Countdown läuft
sichtbar mit, Aufgaben kommen automatisch nacheinander. Bewusst **keine
Erklärung während des Sprints** – das Feedback kommt erst in der Auswertung, mit
bearbeiteten Aufgaben, Fehlerquote und Ø Zeit pro Aufgabe.

Jeder Aufgabentyp führt seinen **eigenen Bestwert**: Ein Sprint über
Grundrechenarten und einer über das ganze Modul Mathematik sind nicht dieselbe
Disziplin und teilen sich deshalb keinen Rekord. Einen Misch-Modus gibt es hier
absichtlich nicht – Kopfrechnen und Textverständnis in einer Runde wären nicht
vergleichbar.

**Testsimulation** – das Kernfeature. Fester Ablauf über mehrere Testteile mit
je eigenem Zeitlimit. Vor jedem Teil ein kurzes Briefing (Aufgabenzahl, Zeit,
Ø Zeit pro Aufgabe, abgedeckte Bereiche) – die Uhr läuft erst nach dem Start.
Läuft die Zeit eines Teils ab, zählen die offenen Aufgaben als nicht
beantwortet und es geht automatisch weiter.

Während des Laufs gibt es **keine Lösungen und keine Zwischenauswertung** –
genau wie im echten Test. Die Zahlen erscheinen erst, wenn alle Teile durch
sind.

Die Taktung orientiert sich an realen Auswahlverfahren, wo die Testteile kurz
und scharf gestellt sind:

| Gesamtsimulation | Themen | Aufgaben | Zeit | pro Aufgabe |
| --- | --- | --- | --- | --- |
| Teil 1 Mathematik | Grundrechnen, Dreisatz, Prozent | 20 | 15 Min | 45 s |
| Teil 2 Sprache | Rechtschreibung, Wortanalogien | 26 | 9 Min | 20 s |
| Teil 3 Logisches Denken | Zahlenreihen, Figurenanalogien | 20 | 15 Min | 45 s |
| Teil 4 Konzentration | Zählen, Reihen vergleichen | 12 | 6 Min | 30 s |
| Teil 5 Textverständnis | Schlussfolgerungen, Wortschatz | 8 | 6 Min | 45 s |
| **Gesamt** | | **86** | **51 Min** | |

Dazu drei kürzere Simulationen für einzelne Module (je 30 Minuten): Mathematik
46 Aufgaben, Logik 36, Sprache 39.

**Unterbrechen** ist bewusst unbequem: Die Zurück-Taste wird abgefangen und
fragt nach. Pausieren geht, aber nur nach einer ausdrücklichen Warnung, dass
das im echten Test nicht möglich ist – und die Auswertung vermerkt jede
Unterbrechung samt Pausendauer, damit ein pausierter Durchlauf nicht mit einem
durchgezogenen verwechselt wird. Die Pausenzeit wird aus der gemessenen
Bearbeitungszeit der laufenden Aufgabe herausgerechnet.

Die **Auswertung am Ende** zeigt Gesamtergebnis und Fehlerquote,
**Fehlerquote je Kategorie** mit Ø Zeit pro Aufgabe, eine Aufschlüsselung nach
Thema, das Ergebnis je Testteil (Fehlerquote, Ø Zeit, Zeitlimit) sowie jede
einzelne Aufgabe mit gegebener Antwort, Musterlösung und Rechenweg.

Zusätzlich gibt es einen Statistik-Screen mit Trefferquote, Sprint-Bestwerten
und Rundenzahl je Modul sowie den zuletzt abgeschlossenen Sitzungen. Beides wird
lokal auf dem Gerät gespeichert; der Verlauf ist auf die letzten 50 Sitzungen
begrenzt (mit Pro 200). Wer sich anmeldet, bekommt denselben Stand zusätzlich in der Cloud –
siehe [Konto und Cloud-Sync](#konto-und-cloud-sync).

## State-Management: Riverpod

Die App nutzt **Riverpod** (`flutter_riverpod`) statt Provider. Gründe, die
konkret an diesem Projekt hängen:

1. **Timer-Logik ohne `BuildContext`.** Sprint-Countdown und die Teil-Countdowns
   der Simulation leben in `Notifier`-Klassen und laufen unabhängig von
   Widget-Rebuilds weiter. Aufräumen passiert zuverlässig über `ref.onDispose`.
2. **Abgeleiteter Zustand kostet nichts.** Fortschritt, Trefferquote und
   Auswertung pro Testteil sind Ableitungen aus dem Session-State, keine manuell
   gepflegten Felder.
3. **Testbarkeit ohne Widget-Tree.** Aufgabenauswahl, Bewertung und
   Zeitablauf-Logik werden mit `ProviderContainer` und `overrideWithValue` als
   reine Dart-Tests geprüft – bei einer Trainings-App ist die Bewertungslogik
   der Teil, der zwingend korrekt sein muss.

Provider wäre bei deutlich kleinerem Umfang die einfachere Wahl. Sobald jedoch
mehrere parallele Zustandsmaschinen mit Timern dazukommen, trägt Riverpod
klar weiter.

## Projektstruktur

```
lib/
├── main.dart                  App-Start, SharedPreferences + Firebase (optional)
├── firebase_options.dart      Platzhalter, wird von flutterfire erzeugt
├── app.dart                   MaterialApp + Material-3-Theme
├── theme/                     Gestaltung
│   ├── design_tokens.dart     Farbrollen, Radien, Abstandsraster
│   └── app_theme.dart         Theme, Typo-Skala, Mono-Schnitte
├── models/                    Datenmodelle (unveränderlich)
│   ├── training_module.dart   Kategorien inkl. Farbe/Icon/Beschreibung
│   ├── sub_category.dart      Unterkategorien, je fest einem Modul zugeordnet
│   ├── question.dart          Aufgabe, Antwortformate, gegebene Antworten
│   ├── answer_record.dart     Protokoll einer (Nicht-)Antwort zur Laufzeit
│   ├── session_mode.dart      Übung / Sprint / Simulation
│   ├── practice_scope.dart    Thema, ganzes Modul oder alles gemischt
│   ├── quiz_session.dart      Zustand für Übung & Sprint
│   ├── simulation.dart        Testteile, Simulationszustand, Auswertung
│   ├── training_session.dart  Abgeschlossene Sitzung für den Verlauf
│   ├── exam_date.dart         Hinterlegter Testtermin inkl. Countdown
│   ├── review_book.dart       Fehler-Gedaechtnis und Themenstaerke
│   ├── progress_trend.dart    Verlauf, Wochenraster, Serie, Vergleich
│   ├── pro_entitlement.dart   Tarife, Berechtigung, Pro-Leistungen
│   ├── ad_frequency.dart      Taktung der Unterbrecher-Werbung
│   ├── reminder_settings.dart Erinnerungen: Einstellungen + Terminberechnung
│   └── module_stats.dart      Persistierter Lernfortschritt
├── screens/                   UI-Screens
│   ├── home_screen.dart       Schnellstart, Module, Gesamtsimulation
│   ├── settings_screen.dart   Pro, Testtermin, Erinnerungen, Werbung, Konto
│   ├── pro_screen.dart        Kauf-Screen (Tarife, Leistungen, Bedingungen)
│   ├── account_screen.dart    Anmeldung, Abgleich, Datenschutz
│   ├── module_screen.dart     Modus-Auswahl innerhalb eines Moduls
│   ├── practice_setup_screen.dart  Thema/Misch-Modus und Umfang wählen
│   ├── sprint_setup_screen.dart    Aufgabentyp für den Sprint wählen
│   ├── quiz_screen.dart       Übungs- und Sprint-Modus
│   ├── simulation_screen.dart Briefing → Bearbeitung → Ergebnis
│   ├── result_screen.dart     Auswertungen (Runde und Simulation)
│   └── stats_screen.dart      Fortschritt je Modul
├── services/                  Business-Logik
│   ├── providers.dart         Riverpod-Verdrahtung + Statistik-Controller
│   ├── question_repository.dart  Ziehen und Mischen von Aufgaben
│   ├── quiz_controller.dart   Übung & Sprint inkl. 60-Sek-Timer
│   ├── simulation_controller.dart  Mehrteilige Simulation mit Teil-Timern
│   ├── storage_service.dart   Lokale Persistenz (SharedPreferences)
│   ├── exam_date_controller.dart  Testtermin (Cloud und Erinnerungen)
│   ├── ads/                   Werbung
│   │   ├── ad_service.dart            Schnittstelle + Attrappen
│   │   ├── ad_config.dart             Anzeigenblöcke (Test/Release)
│   │   ├── admob_ad_service.dart      AdMob inkl. UMP-Einwilligung
│   │   └── ad_controller.dart         Taktung und Freigabe
│   ├── purchase/              Käufe
│   │   ├── purchase_service.dart      Schnittstelle + Attrappen
│   │   ├── store_purchase_service.dart in_app_purchase
│   │   └── entitlement_controller.dart Freischaltung und Kauf-Screen
│   ├── notifications/         Lokale Erinnerungen
│   │   ├── reminder_service.dart       Schnittstelle + Ersatz für Tests
│   │   ├── local_reminder_service.dart flutter_local_notifications
│   │   └── reminder_controller.dart    Einstellungen und Planung
│   ├── auth/                  Anmeldung
│   │   ├── auth_service.dart          Schnittstelle + lokaler Modus
│   │   ├── firebase_auth_service.dart Google/Apple über Firebase Auth
│   │   └── account_controller.dart    An-/Abmelden, Konto löschen
│   └── sync/                  Cloud-Abgleich
│       ├── cloud_models.dart          Cloud-Darstellung (Profil, Sitzung)
│       ├── cloud_sync_service.dart    Schnittstelle + In-Memory-Ersatz
│       ├── firestore_sync_service.dart Firestore-Anbindung
│       ├── sync_merge.dart            Zusammenführen lokal ↔ Cloud
│       └── sync_controller.dart       Ablauf, Zustand, Testtermin
├── widgets/                   Wiederverwendbare Bausteine
│   ├── module_card.dart       Modul- und Modus-Kacheln
│   ├── review_card.dart       Einstieg in die Fehler-Wiederholung
│   ├── exam_header.dart       Dunkle Kopffläche mit Countdown
│   ├── section_title.dart     Abschnittsüberschrift in Mono-Versalien
│   ├── progress_section.dart  Vergleich, Serie und Verlauf
│   ├── trend_chart.dart       Wochenbalken der Trefferquote
│   ├── scope_selector.dart    Auswahlliste, geteilt von Übung und Sprint
│   ├── question_card.dart     Aufgabenkarte + Erklärungsbox
│   ├── answer_option_tile.dart  Antwortoption mit Zustandsfarben
│   ├── timer_bar.dart         Countdown-Anzeige
│   └── stat_tile.dart         Kennzahl-Kachel
└── data/                      Aufgabenpools / Content
    ├── generators/            Mathematik-Generatoren
    │   ├── question_generator.dart      Basisklasse + Rechen-/Formathilfen
    │   ├── arithmetic_generator.dart    Grundrechenarten
    │   ├── rule_of_three_generator.dart Dreisatz (auch antiproportional)
    │   ├── percentage_generator.dart    Prozentrechnung
    │   ├── word_problem_generator.dart  Textaufgaben mit Alltagsbezug
    │   └── math_question_factory.dart   Registry, IDs, Validierung
    ├── question_validation.dart   Qualitätssicherung für alle Aufgaben
    ├── logic_questions.dart       Statischer Content Logik
    ├── language_questions.dart    Statischer Content Sprache
    ├── pro_questions.dart         Zusatzbestand für Pro
    ├── question_pool.dart         Zugriff auf den statischen Bestand
    └── simulation_blueprints.dart Baupläne der Testsimulationen
```

### Zwei Entwurfsentscheidungen, die beim Erweitern relevant sind

**Antwortoptionen werden zur Laufzeit gemischt.** Im Content stehen die Optionen
in sinnvoller Reihenfolge (z. B. Zahlen aufsteigend); das Mischen übernimmt die
`QuestionRepository`. So kann sich niemand eine Antwortposition merken, und der
Content bleibt gut lesbar. `MultipleChoice.reordered()` zieht den `correctIndex`
dabei korrekt mit; Aufgaben mit Zahleneingabe bleiben unangetastet.

**Der Übungsumfang ist ein eigener Typ.** `PracticeScope` kennt drei benannte
Konstruktoren – `mixed()`, `module()` und `subCategory()`. Wer ein Thema wählt,
bekommt dessen Modul automatisch mitgesetzt; Modul und Thema können also nicht
auseinanderlaufen. Der Typ dient zugleich als Schlüssel des Session-Providers
und hat dafür `==` und `hashCode`.

**Zwei Modelle für eine Sitzung.** `AnswerRecord` lebt nur während einer Runde
und kennt die vollständige `Question` – die Auswertung braucht Aufgabentext und
Erklärung. Für den dauerhaften Verlauf wird daraus eine `TrainingSession` mit
schlanken `QuestionResult`-Einträgen (nur ID, Unterkategorie, richtig/falsch,
Zeit). So bleibt der Verlauf auch dann lesbar, wenn eine Aufgabe später aus dem
Pool entfernt oder umformuliert wird.

**Content ist austauschbar.** Die `QuestionRepository` ist der einzige Ort, an
dem der Unterschied zwischen generierter und handgeschriebener Quelle eine
Rolle spielt. Kommt später ein Backend oder eine lokale Datenbank dazu, wird nur
sie ersetzt – Screens und Controller bleiben unverändert.

**Bilder sind vorbereitet.** `Question.imageAsset` nimmt einen Asset-Pfad auf;
ist er gesetzt, zeigt die `QuestionCard` das Bild über dem Aufgabentext. Für die
Figurenanalogien muss dann nur das Asset hinterlegt, das Feld gesetzt und der
beschreibende Teil des Aufgabentextes gekürzt werden. Der Asset-Ordner braucht
zusätzlich einen Eintrag in `pubspec.yaml`.

## Gestaltung: „Prüfungsbogen, nicht Spielbrett"

Die Oberfläche folgt einem Entwurf aus Claude Design. Leitgedanke: amtliche
Sachlichkeit als Handschrift — Papierflächen statt Kartenteppich, Mono-Ziffern
für alles Gemessene, Modulfarbe nur als Datenmarke. **Rangfolge entsteht über
Fläche und Dunkelheit, nicht über Rahmen.**

Drei Annahmen tragen den Entwurf:

1. **Der Termin ist der Anker.** Wer einen Prüfungstermin hinterlegt hat,
   öffnet die App wegen des Countdowns. Er sitzt darum in der dunklen
   Kopffläche der Startseite, nicht in einer Karte unter anderen.
2. **Zwei Register: Üben und Prüfen.** Üben ist hell, erklärend, unterbrechbar.
   Die Testsimulation ist **immer dunkel — auch im Hellmodus**, ohne Karten,
   ohne Rückmeldung. Der Moduswechsel ist der Vorhang vor der Prüfung.
3. **Verwaltungskram wird flach.** Karten bekommt nur, was Daten trägt oder
   eine Handlung auslöst.

### Tokens

`lib/theme/design_tokens.dart` trägt die Rollen, die Material 3 nicht kennt —
Papier, erhabene Datenkarte, eingelassene Rille — als `ThemeExtension`.
Material bietet dafür keine Begriffe, und eine erzwungene Zuordnung auf
`surfaceContainer*` hätte den Unterschied verwischt.

| Rolle | hell | dunkel |
| --- | --- | --- |
| Papier | `#F7F5F1` | `#0E1116` |
| Datenkarte | `#FFFFFF` | `#171B22` |
| Rille, Balkengrund | `#EFEBE4` | `#1F242C` |
| Tinte / Hauptaktion | `#16233A` | `#E7EAEF` |
| Link, Fokus | `#2F6FED` | `#6C9BFF` |
| richtig | `#146B45` | `#2FA875` |
| falsch | `#A61B1B` | `#F1705F` |

Die Modulfarben bleiben (Mathematik `#2F6FED`, Logik `#C2410C`, Sprache
`#0E9F6E`) und bekommen helle Gegenstücke für den Dunkelmodus.

**Die Seed-Farbe wandert von `#2F6FED` auf die Tinte `#16233A`.** Blau soll
eindeutig „Mathematik" heißen und nicht gleichzeitig Markenfarbe sein — sonst
konkurriert die Datenmarke mit der Hauptaktion.

### Schrift

**IBM Plex Sans für Prosa, IBM Plex Mono für alles Gemessene** — Zeit, Zähler,
Quoten, Aufgabennummern. Immer mit Tabellenziffern, damit Zahlen beim
Hochzählen nicht zappeln. Diese Trennung ist die eigentliche Handschrift und
ersetzt Roboto vollständig.

Die Schriften sind **gebündelt statt zur Laufzeit geladen** (`assets/fonts/`,
Latin-Subset, OFL 1.1, zusammen 355 KB). Die App wird unterwegs und offline
benutzt; eine Schrift, die beim ersten Start erst nachgeladen werden muss,
wäre dort nicht da.

**Ein Fund beim Einbinden:** Umlaute, ß und € sind im Latin-Subset enthalten,
aber **✓, ✕ und → fehlen** — genau die Zeichen, die der Entwurf für die
Rückmeldung vorsieht. Als Textzeichen wären sie auf eine Systemschrift
zurückgefallen. Sie sind deshalb Material-Icons (`Icons.check`,
`Icons.close`), was die Absicht ohnehin besser trifft: gemeint ist eine
Glyphe, kein bestimmter Unicode-Codepunkt.

### Radien und Abstände

Vier Radien statt eines: **4** (Eingabe, Antwortoption), **10** (Datenkarte),
**20** (Kopffläche, Hauptknopf), **999** (Chip). Ein kleiner Radius heißt
„hier wird eingegeben", ein großer „hier wird gestartet" — das ersetzt die
gleichförmigen Material-Karten als Rangordnung.

Abstände im 4er-Raster (4/8/12/16/20/24/32). Unter 360 dp fällt der Seitenrand
auf 16 und die zweispaltigen Kennzahlen brechen auf eine Spalte um.

Karten werfen **keinen Schatten**, nur eine Haarlinie — nur schwebende Dinge
werfen Schatten. Im Dunkelmodus ersetzt Flächenhelligkeit den Schatten.

### Rückmeldung ist vierfach unterschieden

Jeder Zustand einer Antwortoption trägt **Farbe, Glyphe, Wort und
Textauszeichnung**. Farbe allein bedeutet hier nie etwas — damit bleibt die
Rückmeldung bei Farbfehlsichtigkeit und im Sonnenlicht lesbar. Tests halten
das fest: `richtig` ohne Häkchen oder ohne Wort lässt die Suite fehlschlagen.

### Was aus dem Entwurf **nicht** übernommen wurde

Der Entwurf zeigt die App teils reicher, als sie ist. Nicht umgesetzt, weil es
Funktionen wären und nicht Gestaltung:

- Aufgabentypen **Matrizen** und **Konzentration** (gibt es noch nicht)
- „Typischer Fehler"-Hinweis im Rechenweg (dafür fehlen die Daten)
- **Zurück/Weiter** innerhalb eines Testteils und „Später fortsetzen"
- Filter „nur Fehler" in der Auswertung
- Die Zahlen der Simulation im Entwurf (4 Teile, 96 Minuten) sind
  Platzhalter; die App zeigt ihre tatsächlichen 74 Aufgaben in 45 Minuten.

## Fortschritt über Zeit

„Bin ich besser geworden?" ist die Frage, die vor einer Prüfung zählt – nicht
„wie gut bin ich". Der Statistik-Screen beantwortet sie in drei Stufen:

**Der direkte Vergleich.** Letzte 7 Tage gegen die 7 davor, als Satz statt als
Zahlenkolonne: „Du bist besser geworden – Letzte 7 Tage: 78 % · die 7 davor:
61 % (17 Punkte mehr)."

**Die Serie.** Wie viele Tage in Folge geübt wurde. Gestern zählt noch mit: Wer
abends übt und morgens nachsieht, hat seine Serie nicht verloren, nur weil ein
neuer Tag angebrochen ist.

**Der Verlauf.** Trefferquote je Woche über die letzten acht Wochen.

### Was der Abschnitt nicht behauptet

Drei Regeln stehen gegen die Versuchung, aus dünnen Daten eine Entwicklung zu
machen:

- **Unter zwei aussagekräftigen Wochen bleibt der Abschnitt ganz aus.** Ein
  einzelner Balken ist kein Verlauf.
- **Wochen unter fünf Antworten zählen nicht mit.** Eine Quote aus zwei
  Aufgaben ist Zufall, kein Messwert.
- **Unter drei Prozentpunkten Unterschied heißt es „stabil".** Eine Aufgabe
  mehr richtig ist kein Trend.
- **Ohne Daten im Vorzeitraum gibt es keinen Vergleich** – sonst würde aus dem
  Nichts eine Verbesserung behauptet.

Wochen ohne Übung bleiben als leere Lücke im Diagramm stehen. Sie zu
überspringen würde den Verlauf schöner aussehen lassen, als er war.

### Zur Gestaltung des Diagramms

Eine einzelne Messreihe über die Zeit – deshalb **eine** Farbe statt einer
Palette und keine Legende: Die Überschrift benennt, was gezeigt wird. Balken
mit abgerundetem oberem Ende, an der Grundlinie verankert, 4 px Radius,
2 px Abstand. Beschriftet wird **nur der jüngste aussagekräftige Balken** –
eine Zahl über jedem wäre Rauschen. Zahlen tragen Textfarben, nie die Farbe
des Balkens.

Die Höhe bezieht sich auf die beste Woche statt starr auf 100 %: Bei durchweg
hohen Quoten wäre eine 0–100-Skala flach und nichtssagend.

### Ein Befund zur Barrierefreiheit

Beim Prüfen der Modulfarben mit dem Paletten-Validator fiel auf, dass
Mathematik-Blau (`#2F6FED`) und das frühere Logik-Lila (`#7A4FE0`) für
Rot-Grün-Blinde praktisch identisch waren: ΔE 2,3 unter Deuteranopie, und
selbst mit vollem Farbsehen nur 10,7 – unter der Schwelle von 15. Das betraf
nicht nur das neue Diagramm, sondern die bestehenden Modulkarten.

Logik trägt jetzt Rostrot (`#C2410C`). Die Palette besteht alle sechs
Prüfungen in hell **und** dunkel; der schlechteste Nachbarabstand liegt bei
ΔE 10,2 unter Deuteranopie und 28,0 bei normalem Farbsehen.

## Fehler-Wiederholung

Eine Trainings-App, die immer nur zufällig zieht, lässt den größten Hebel
liegen: Wer eine Aufgabe dreimal falsch hatte, soll sie öfter sehen als eine,
die er immer kann. `lib/models/review_book.dart` hält dafür fest, was
schiefging – und die Startseite bietet daraus eine Runde an.

### Zwei Ebenen, weil es zwei Aufgabenquellen gibt

**Einzelne Aufgaben** (`QuestionMemory`) für den statischen Bestand aus Logik
und Sprache. Dort kehrt dieselbe Aufgabe wieder, also lohnt es, sie zu merken.
Nach jeder richtigen Antwort wächst der Abstand – 1, 3, 7, 16 Tage –, ein
Fehler setzt den Fortschritt auf null und macht sie sofort wieder fällig. Nach
vier richtigen Antworten in Folge gilt sie als gekonnt und verschwindet.

Die Intervalle sind bewusst kurz. Wer sich auf einen Test in vier Wochen
vorbereitet, hat von einem Abstand über sechs Monate nichts.

**Aufgabentypen** (`TopicMastery`) für alle Module, auch Mathematik. Dort wird
jede Aufgabe erzeugt und existiert kein zweites Mal – die Kennung zu merken
brächte nichts. Stattdessen wird die Trefferquote je Thema beobachtet: Wer bei
Dreisatz bei 45 % liegt, bekommt mehr Dreisatz-Aufgaben, mit neuen Zahlen.

Zwei Schutzregeln stecken darin:

- **Übersprungene Aufgaben zählen nicht.** Wer nicht geantwortet hat, hat
  weder Können noch Nichtkönnen gezeigt.
- **Unter acht Antworten gibt es kein Urteil.** Zwei Fehlversuche machen noch
  keine Schwäche. Erst darüber gilt ein Thema unter 70 % als Schwachstelle.

### Wie eine Wiederholungsrunde entsteht

`QuestionRepository.drawReview()` füllt die Runde in dieser Reihenfolge:

1. **Fällige Einzelaufgaben**, dringendste zuerst – was oft falsch war und
   lange liegt.
2. **Schwache Themen**, aufgefüllt mit frisch gezogenen Aufgaben. Gibt es
   mehrere Schwachstellen, wird verteilt statt die größte auszureizen.

Ist noch nichts bekannt, kommt eine gemischte Runde zurück – eine leere Runde
wäre die schlechtere Antwort.

Der Umfang ist ein eigener `PracticeScope.review()`. Dadurch läuft die Runde
durch denselben Übungs-Screen wie jede andere, mit sofortiger Rückmeldung und
Rechenweg.

### Auf der Startseite

Die Karte „Deine Fehler wiederholen" erscheint **nur, wenn es etwas zu tun
gibt**, und nennt konkret was: „7 Aufgaben stehen an · Dreisatz liegt bei
45 %". Wer noch nie geübt hat, wird nicht auf seine Fehler hingewiesen.

## Monetarisierung

Die App ist kostenlos nutzbar und finanziert sich über Werbung; **Pro**
entfernt die Werbung und erweitert das Training.

### Der Leitsatz: Pro nimmt nichts weg

Alle drei Module, alle Rundenlängen und alle Testsimulationen bleiben
kostenlos – auch die 45-Minuten-Gesamtsimulation. Pro kommt obendrauf:

| | Kostenlos | Pro |
| --- | --- | --- |
| Module, Rundenlängen, Simulationen | alle | alle |
| Werbung | Banner im Übungsmodus, gelegentliche Unterbrechung nach dem Sprint | keine |
| Aufgabenbestand Logik/Sprache | 96 | 96 + 30 |
| Schwierigkeit gezielt wählbar | – | ja |
| Sitzungsverlauf | 50 | 200 |

Das ist keine bloße Absichtserklärung, sondern ein Test: `monetization_test`
prüft, dass **jede** kostenlose Aufgabe auch im Pro-Bestand enthalten ist und
dass keine Pro-Aufgabe je aus dem freien Bestand stammt. Wandert später eine
Aufgabe in die falsche Datei, schlägt der Test fehl.

Die Pro-Aufgaben durchlaufen dieselbe Qualitätssicherung wie der freie
Bestand – bezahlte Aufgaben dürfen nicht schlechter sein.

### Warum `in_app_purchase` und nicht RevenueCat

**Empfehlung: `in_app_purchase`** – aus drei Gründen, die konkret an diesem
Projekt hängen:

1. **Eine Plattform.** RevenueCats größter Nutzen ist das Vereinheitlichen von
   Play- und App-Store-Belegen. Solange nur Android ausgeliefert wird, zahlt
   man für ein Problem, das man nicht hat.
2. **Datenschutz.** Die App hat eine sehr explizite Haltung dazu (EU-Region,
   keine überflüssigen Daten). RevenueCat wäre ein weiterer Auftragsverarbeiter,
   der Kauf- und Gerätedaten erhält – mit AV-Vertrag und einem zusätzlichen
   Punkt in der Datenschutzerklärung.
3. **Kosten.** RevenueCat nimmt oberhalb einer Umsatzschwelle einen Anteil.
   Für eine App, die gerade erst startet, ist das vermeidbar.

Der ehrliche Gegenpunkt: **Abo-Status ist mit `in_app_purchase` allein nicht
zuverlässig abbildbar.** Kündigungen, Rückerstattungen, Zahlungsprobleme und
Kulanzzeiträume sieht man nur über die Play Developer API auf einem Server.
Genau das nimmt RevenueCat einem ab.

Deshalb liegt alles hinter der Schnittstelle `PurchaseService`: Wird die
Abo-Verwaltung zum Problem, ist RevenueCat eine neue Implementierung dieser
einen Datei – Screens, Controller und Sperren bleiben unverändert.

Bis dahin gilt lokal eine großzügige Regel: Ein Abo läuft rechnerisch 31 bzw.
366 Tage, und solange der Store nichts Gegenteiliges meldet, bleibt die
Freischaltung bestehen. **Im Zweifel zugunsten dessen, der bezahlt hat** – der
Store korrigiert beim nächsten Abgleich.

### Tarife

| Tarif | Produkt-Kennung | Art |
| --- | --- | --- |
| Einmalkauf | `pro_lifetime` | Einmalzahlung, kein Ablauf |
| Monatlich | `pro_monthly` | Abo |
| Jährlich | `pro_yearly` | Abo |

Die Kennungen müssen genauso in der Play Console angelegt werden. **Preise
kommen ausschließlich vom Store** und werden nie in der App zusammengebaut –
Währung, Format und Steuersatz hängen vom Land ab. Beim Jahresabo wird
zusätzlich der rechnerische Monatspreis genannt, damit der Vergleich möglich
ist, ohne dass jemand im Kopf teilen muss.

### Der Kauf-Screen

Vorgabe war „klar und nicht aggressiv". Konkret heißt das hier:

- Kein Countdown, kein „nur heute", keine durchgestrichenen Fantasiepreise.
- **Kein Tarif ist vorausgewählt** oder als „beliebteste Wahl" markiert. Ein
  Test prüft, dass die Wörter „Empfohlen" und „Beliebteste" dort nicht
  vorkommen.
- Was kostenlos bleibt, steht **vor** den Preisen, nicht im Kleingedruckten.
- Die Abo-Bedingungen (automatische Verlängerung, Kündigung im Play Store)
  stehen im Klartext auf derselben Seite.
- Der Einstieg auf der Startseite ist eine Textzeile ganz unten – kein Dialog,
  der beim Start aufgeht, und keine Sperre mitten in einer Übungsrunde.
- Gesperrte Funktionen zeigen keinen Schalter, der beim Antippen einen
  Kaufdialog aufreißt, sondern einen ruhigen Hinweis mit normalem Link.

### Werbung: wo, wann und wie oft

**Banner** erscheinen ausschließlich im **Übungsmodus** am unteren Rand – und
erst, wenn tatsächlich eine Anzeige geladen ist. Ein reservierter Leerraum
würde die Aufgabe nach oben drücken, ohne dass etwas zu sehen wäre.

Bewusst **kein** Banner im Sprint und in der Testsimulation: Dort läuft eine
Uhr, und eine Anzeige neben einem Countdown wäre gegenüber dem Nutzer unfair.

**Unterbrecher-Anzeigen** laufen nur nach einer abgeschlossenen
**Sprint-Runde**, nie im Übungsmodus (dort folgt auf die Antwort die Erklärung,
die nichts verdecken soll) und nie in der Simulation. Die Taktung steckt in
`InterstitialPolicy` – drei Regeln, alle drei müssen erfüllt sein:

- Die **allererste** Runde bleibt frei. Der erste Eindruck einer Lern-App soll
  keine Anzeige sein.
- Danach höchstens **jede dritte** Runde.
- Und nie zweimal innerhalb von **fünf Minuten**, egal wie schnell geübt wird.

Der Zählerstand wird gespeichert und übersteht einen Neustart – sonst wäre die
Regel durch Schließen und Öffnen der App auszuhebeln.

### Einwilligung (DSGVO)

Im EWR dürfen ohne Einwilligung keine Anzeigen ausgeliefert werden. Die App
nutzt dafür Googles **User Messaging Platform**: `canRequestAds` wird von UMP
beantwortet, nicht von der App geraten. Ohne Einwilligung wird schlicht nichts
angefordert.

Der Einwilligungsdialog erscheint **nach** dem ersten Frame, nicht vor der
Startseite. In den Einstellungen gibt es „Datenschutzeinstellungen für
Werbung", weil eine Einwilligung jederzeit widerrufbar sein muss. Mit Pro
verschwindet der Abschnitt – dann gibt es nichts einzustellen.

### AdMob und Play Console einrichten

Voreingestellt sind **Googles offizielle Test-Kennungen**, auch im Manifest.
Sie liefern echte Test-Anzeigen; auf eigenen Anzeigenblöcken zu testen führt
zur Sperrung des AdMob-Kontos.

Für ein Release:

```bash
flutter build apk --release \
  --dart-define=ADMOB_BANNER_ANDROID=ca-app-pub-…/… \
  --dart-define=ADMOB_INTERSTITIAL_ANDROID=ca-app-pub-…/…
```

Zusätzlich nötig:

- Die **AdMob-App-ID** in `android/app/src/main/AndroidManifest.xml` ersetzen
  (`com.google.android.gms.ads.APPLICATION_ID`). Fehlt der Eintrag ganz,
  stürzt die App beim Start des Ad-SDK ab – deshalb steht dort auch im
  Testbuild eine gültige ID.
- In der AdMob-Konsole unter **Privacy & messaging** eine
  DSGVO-Einwilligungsnachricht anlegen, sonst zeigt UMP kein Formular.
- Die drei Produkte in der **Play Console** anlegen (Kennungen siehe oben) und
  die App mindestens in einen Testtrack hochladen – vorher liefert der Store
  keine Preise aus.

Ohne all das bleibt die App vollständig nutzbar: Ohne Store gibt es keine
Kaufmöglichkeit, ohne Einwilligung keine Anzeigen. Beides ist ein
Ausbleiben von Funktionen, kein Fehlerfall.

## Testtermin und Erinnerungen

In den **Einstellungen** lässt sich der Termin des anstehenden Einstellungstests
hinterlegen (optional mit Beschriftung, z. B. „Polizei NRW"). Er hat zwei
Wirkungen: Auf der Startseite steht ein Countdown („Noch 23 Tage"), und die App
kann rechtzeitig ans Üben erinnern.

**Erinnerungen sind voreingestellt aus.** Ungefragt Benachrichtigungen zu
schicken wäre übergriffig – und unter Android 13+ müsste ohnehin erst die
Berechtigung erfragt werden. Beim Einschalten fragt die App danach; wird sie
verweigert, bleibt der Schalter aus, statt ein Versprechen zu geben, das die App
nicht halten kann.

Voreingestellt sind **7 Tage vorher** und **1 Tag vorher**, jeweils um 18 Uhr.
Beides ist änderbar: Vorlaufzeiten aus 30/14/7/3/1 Tagen (mindestens eine bleibt
gesetzt) und eine frei wählbare Uhrzeit. Der Einstellungen-Bildschirm zeigt
dabei nicht nur die Schalter, sondern auch die konkreten Zeitpunkte, die daraus
folgen.

Der Text richtet sich nach dem Abstand: eine Woche vorher „Eine Übungsrunde am
Tag hält dich im Rhythmus", drei Tage vorher der Hinweis auf eine
Testsimulation, am Vortag „Morgen ist dein Einstellungstest".

### Wie die Planung aufgebaut ist

`planReminders()` in `lib/models/reminder_settings.dart` ist eine **reine
Funktion**: Termin + Einstellungen + „jetzt" ergeben die Liste der Erinnerungen,
fertig formuliert. Das ist der Teil, der stimmen muss, und er lässt sich ohne
Emulator prüfen. Die Bibliothek kommt erst danach ins Spiel.

Zwei Regeln stecken darin:

- **Vergangenes wird übersprungen.** Wer den Termin drei Tage vorher einträgt,
  bekommt keine „Noch 7 Tage"-Meldung mehr – die würde sonst beim Planen
  entweder abgelehnt oder sofort ausgelöst.
- **Die Kennung hängt an der Vorlaufzeit, nicht am Datum.** Erneutes Planen
  ersetzt damit den bestehenden Eintrag, statt einen zweiten anzulegen.

Jede Änderung – am Termin, an den Vorlaufzeiten, an der Uhrzeit – baut die
geplanten Benachrichtigungen vollständig neu auf. Punktuelle Änderungen wären
der Fall, in dem ein verschobener Termin eine alte Erinnerung zurücklässt.
Das gilt auch für einen Termin, den der **Cloud-Abgleich von einem anderen
Gerät mitbringt**: `ExamDateController` plant danach ebenso neu.

Beim App-Start wird einmal neu geplant. Android verwirft geplante Alarme unter
anderem beim Neustart des Geräts; dafür ist zusätzlich der Boot-Receiver von
`flutter_local_notifications` im Manifest eingetragen.

### Warum diese Bibliothek und diese Einstellungen

`flutter_local_notifications` (19.5) ist der De-facto-Standard für lokale
Benachrichtigungen in Flutter. Dazu kommen `timezone` und `flutter_timezone`:
Ein geplanter Zeitpunkt braucht eine echte Zonenangabe, sonst läge die
Erinnerung im Sommer eine Stunde daneben und auf Reisen mehr.

Geplant wird bewusst **ungenau** (`inexactAllowWhileIdle`). Ein exakter Alarm
braucht seit Android 13 die Sonderberechtigung `SCHEDULE_EXACT_ALARM`, die
Google im Play Store nur für Wecker- und Kalender-Apps freigibt. Für eine
Erinnerung am Abend sind ein paar Minuten Abweichung ohne Belang.

Alles bleibt **auf dem Gerät**: Es gibt keinen Push-Dienst, keinen Server und
keine Gerätekennung. Die einzige Verbindung nach außen ist der optionale
Cloud-Abgleich des Termins selbst.

## Konto und Cloud-Sync

Die App ist **ohne Konto vollständig nutzbar**. Fortschritt, Verlauf und
Testtermin liegen dann ausschließlich auf dem Gerät. Eine Anmeldung mit Google
oder Apple sichert denselben Stand zusätzlich in der Cloud und macht ihn auf
weiteren Geräten verfügbar.

Ist keine Firebase-Konfiguration hinterlegt, blendet die Oberfläche die
Anmeldung aus, statt eine Schaltfläche anzubieten, die nur scheitern kann:
`main()` versucht `Firebase.initializeApp()` und setzt bei einem Fehlschlag
`firebaseReadyProvider` auf `false`. Genau dieser Zustand ist auch der
Testmodus – die Tests laufen dadurch ohne Platform-Channels.

### Struktur in Firestore

```
users/{uid}
├── schemaVersion, updatedAt
├── examDate, examLabel, examUpdatedAt      hinterlegter Testtermin
├── progress: { math|logic|language: { answered, correct, sessions } }
├── sprintBests: { "topic:arithmetic": 14, "module:math": 11, … }
└── sessions/{sessionId}
    ├── mode, moduleId, startedAt, finishedAt, durationMs
    ├── total, answered, correct
    └── bySubCategory: { arithmetic: { t, a, c, ms }, … }
```

Drei Entscheidungen prägen diese Struktur:

**Sitzungen sind eine Unterkollektion, kein Array im Profil.** Ein
Firestore-Dokument ist auf 1 MB begrenzt und wird bei jedem Schreiben komplett
übertragen. Als Unterkollektion wächst der Verlauf unbegrenzt, und ein neuer
Eintrag kostet genau einen kleinen Schreibvorgang.

**Die Dokument-ID einer Sitzung ist ihre lokale Kennung.** Ein erneuter Upload
derselben Sitzung überschreibt sie damit, statt eine Dublette anzulegen. Das ist
die Grundlage der Idempotenz: Zweimaliges Anmelden kann den Fortschritt nicht
verdoppeln.

**In der Cloud liegen nur Summen je Thema, keine einzelnen Aufgaben.**
Gesamtzahlen, Trefferquote, Zeiten und die Aufschlüsselung nach Thema kommen
verlustfrei zurück – die Auswertung zeigt nichts anderes. Was bewusst nicht
gespeichert wird, ist die Zuordnung zu einzelnen Aufgaben.

### Zusammenführen

`mergeForSync()` in `lib/services/sync/sync_merge.dart` ist der Kern. Leitsatz:
**Die Sitzungen sind die Quelle der Wahrheit, die Zähler sind abgeleitet.**

- Hochgeladen wird nur, was der Cloud fehlt (Vergleich über die Kennungen).
- Die Zähler wachsen um genau diese Sitzungen – ein zweiter Abgleich findet
  nichts Neues und ändert deshalb auch nichts.
- Beim **ersten** Abgleich (noch kein Profil in der Cloud) werden die lokalen
  Zähler unverändert übernommen: Der Verlauf ist auf 50 Einträge begrenzt, die
  Zähler laufen dagegen über die gesamte Nutzungsdauer.
- Sprint-Bestwerte: je Aufgabentyp gewinnt der höhere Wert.
- Testtermin: die jüngere Änderung gewinnt (`examUpdatedAt`).

### Datenschutz

Gespeichert wird nur, was die Auswertung tatsächlich anzeigt. Es gibt **keine**
E-Mail-Adresse und keinen Namen in der eigenen Datenbank – beides liegt bereits
bei Firebase Auth, eine zweite Kopie wäre unnötige Datenhaltung. Ebenso keine
Aufgabentexte, keine einzelnen Antworten, keine Geräte-Kennungen, kein
Standort. Der Konto-Bildschirm nennt das im Klartext statt im Kleingedruckten.

„Konto und Daten löschen“ setzt Art. 17 DSGVO um: erst die Firestore-Daten
(inklusive Unterkollektion), dann das Konto beim Anbieter, dann die lokale
Kopie. Die Reihenfolge ist load-bearing – nach dem Löschen des Kontos fehlt die
Berechtigung für die eigenen Dokumente.

Die Firestore-Datenbank muss in einer **EU-Region** angelegt werden
(`eur3` oder `europe-west3`); die Region lässt sich nachträglich nicht ändern.
Die Kontodaten selbst verwaltet Firebase Auth und verarbeitet sie auch außerhalb
der EU – das steht so auch in der App.

`firestore.rules` beschränkt den Zugriff auf das jeweils eigene Konto; alles
außerhalb von `users/{uid}` ist gesperrt.

### Firebase einrichten

`lib/firebase_options.dart` ist im Repository ein Platzhalter, der bewusst
wirft. Für einen echten Build:

```bash
dart pub global activate flutterfire_cli
flutterfire configure --project <projekt-id>   # überschreibt firebase_options.dart
firebase deploy --only firestore:rules
```

Zusätzlich nötig:

- **Firestore** in einer EU-Region anlegen (siehe oben).
- **Google Sign-In:** die SHA-1- und SHA-256-Fingerprints des Signaturschlüssels
  in der Firebase-Konsole hinterlegen, sonst schlägt die Anmeldung auf dem Gerät
  fehl (`flutter build apk` nutzt vorerst den Debug-Key).
- **Apple Sign-In:** erfordert ein Apple-Developer-Konto und ist auf Android nur
  als Web-Flow verfügbar. Für den Android-Build muss in der Firebase-Konsole der
  Apple-Anbieter mit Service-ID und Redirect-URL konfiguriert sein.
- `google-services.json` gehört **nicht** ins Repository.

Ohne diese Schritte bleibt alles lauffähig – die App startet im lokalen Modus.

## Einrichtung

Die App ist durchgaengig deutsch: `flutter_localizations` ist eingebunden und
die Locale fest auf `de` gesetzt, damit auch die Material-Dialoge (Datums- und
Uhrzeitauswahl) deutsche Beschriftungen und Monatsnamen zeigen.

Vorausgesetzt wird Flutter **3.27 oder neuer** (wegen `Color.withValues` und der
Material-3-Surface-Rollen) mit JDK 17.

```bash
flutter pub get
flutter run
```

Der Android-Ordner ist im Repository enthalten, ein zusätzliches
`flutter create` ist nicht nötig. Der Gradle-Wrapper (`gradlew`,
`gradle-wrapper.jar`) ist wie bei `flutter create` **nicht** eingecheckt – das
Flutter-Tool legt ihn beim ersten Build selbst an. Deshalb sollte der
Android-Build immer über `flutter build` laufen und nicht über ein direkt
aufgerufenes `gradle`.

Für den Android-Build werden zusätzlich das Android SDK (Platform 35,
Build-Tools 35) und JDK 17 benötigt. `flutter_local_notifications` verlangt
**Core Library Desugaring**; es ist in `android/app/build.gradle` bereits
aktiviert, zusammen mit den Berechtigungen `POST_NOTIFICATIONS` und
`RECEIVE_BOOT_COMPLETED` im Manifest.

### Build & Tests

```bash
flutter analyze
flutter test
flutter build apk --debug
flutter build apk --release
```

Verifiziert mit Flutter 3.35.4 / Dart 3.9.2: `flutter analyze` meldet keine
Befunde, alle 407 Tests laufen durch, Debug- und Release-APK werden erzeugt.
Der Android-Build gelingt auch **ohne** `google-services.json`: Das
google-services-Gradle-Plugin wird nicht angewandt, die Konfiguration kommt aus
Dart.
Der Release-Build ist vorerst mit dem Debug-Key signiert, damit er ohne weitere
Einrichtung durchläuft – vor einer Veröffentlichung muss in
`android/app/build.gradle` ein echter Release-Keystore hinterlegt werden.

Die Tests decken ab:

- **Generatoren** – mehrere tausend erzeugte Aufgaben gegen den Validator,
  unabhängiges Nachrechnen der Grundrechen-, Prozent- und
  Geschwindigkeitsaufgaben, centgenaue Geldbeträge, eindeutige IDs,
  Reproduzierbarkeit bei festem Seed, Steuerung von Schwierigkeit und
  Unterkategorien
- **Qualitätssicherung selbst** – dass der Validator kaputte Aufgaben
  tatsächlich erkennt (doppelte Optionen, ungültiger Lösungsindex, nicht
  darstellbare Ergebnisse, Lösungsweg ohne Resultat)
- **Aufgabenmodell** – Auswertung beider Antwortformate, Einlesen deutscher
  Zahleneingaben, Toleranzen, Umsortieren der Optionen, sowie das Verhalten bei
  Antworten, die nicht zum Format der Aufgabe passen
- **Sitzungsmodell** – Kennzahlen (richtig/falsch/übersprungen, Trefferquote,
  Zeit pro Aufgabe), Gruppierung nach Unterkategorie und JSON-Zyklus inklusive
  defekter Datensätze
- **Aufgabenpool** – eindeutige IDs, stimmige Antwortformate, jede
  Unterkategorie gefüllt, Mindestumfang je Unterkategorie, ausreichend Aufgaben
  für jede Simulation
- **Ablauf** – beide Quiz-Modi, der mehrteilige Simulationsablauf mit
  Zeitablauf und Auswertung, Persistenz von Fortschritt und Verlauf
- **Cloud-Abgleich** – Idempotenz (ein zweiter Abgleich lädt nichts hoch und
  verdoppelt den Fortschritt nicht), erster Abgleich gegen eine leere Cloud,
  Herunterladen auf ein frisch installiertes Gerät, Kappen des Verlaufs,
  Sprint-Bestwerte, Testtermin nach jüngster Änderung, verlustfreier
  Cloud-Zyklus einer Sitzung
- **Konto** – Anmelden mit sofortigem Abgleich, abgebrochene Anmeldung ohne
  Fehlermeldung, Abmelden ohne Datenverlust, Löschen von Cloud, Konto und
  Gerät, sowie der lokale Modus ohne Firebase
- **Fortschritt über Zeit** – Wochenraster inklusive Montagsgrenze und
  Luecken, Vergleich zweier Zeitfenster ohne Ueberschneidung, kleine
  Schwankungen als „stabil", kein Vergleich ohne Vorzeitraum, Serie mit
  Kulanz fuer gestern, Darstellung erst ab genug Verlauf, kein Ueberlauf im
  Dunkelmodus und auf 320 Punkten Breite
- **Fehler-Wiederholung** – wachsende Abstaende und Ruecksetzen bei einem
  Fehler, gekonnte Aufgaben verschwinden, uebersprungene zaehlen nicht,
  generierte Mathe-Aufgaben landen nur auf der Themen-Ebene, Schwachstellen
  erst ab genug Daten, Ziehen aus faelligen Aufgaben und schwachen Themen,
  Fortschreiben ueber Neustarts hinweg
- **Monetarisierung** – Berechtigung (Einmalkauf ohne Ablauf, Abo mit Ablauf,
  abgelaufenes Abo gilt beim Start nicht mehr), Kauf/Abbruch/Fehlschlag/
  Wiederherstellung, Werbung endet mit dem Kauf sofort, Taktung der
  Unterbrechungen inklusive Neustart, Pro-Bestand als echte Erweiterung des
  freien Bestands, längerer Verlauf, Schwierigkeitswahl
- **Erinnerungen** – Berechnung der Zeitpunkte inklusive übersprungener
  Vergangenheit und stabiler Kennungen, Vorlaufzeiten und Uhrzeit, verweigerte
  Berechtigung lässt den Schalter aus, ein verschobener Termin verschiebt die
  Erinnerungen mit, ein entfernter Termin räumt sie ab, ein aus der Cloud
  übernommener Termin plant neu, ein unveränderter plant nicht erneut
- **Oberfläche** – Navigation, Auswahl von Übungsumfang und Sprint-Aufgabentyp,
  Fortschrittsanzeige, sofortige Rückmeldung mit Erklärung, Sprint ohne
  Erklärung bis zum Zeitablauf, Auswertung mit Fehlerquote und Zeiten,
  Zahleneingabefeld inklusive Fehlerfall, Konto-Bildschirm, Testtermin,
  der Erinnerungs-Abschnitt der Einstellungen sowie der Kauf-Screen
  (Tarife ohne Vorauswahl, Abo-Bedingungen sichtbar, Freischaltung nach dem
  Kauf)

## Stand und nächste Schritte

Mathematik ist durch die Generatoren unbegrenzt. Der handgeschriebene Bestand
für Logik und Sprache umfasst 96 Aufgaben und erfüllt die MVP-Vorgaben; ein Test
hält die Mindestzahlen je Unterkategorie fest, damit sie beim Umbauen nicht
unbemerkt unterschritten werden.

Die Figurenanalogien sind aktuell **sprachlich beschrieben** statt gezeichnet –
im echten Test sind das Bildaufgaben. Die Aufgabenlogik stimmt, die Darstellung
ist ein Zwischenschritt, bis Grafik-Assets vorliegen; `Question.imageAsset` ist
dafür bereits vorgesehen.

Naheliegende nächste Schritte:

- Bild-Assets für Figurenanalogien hinterlegen, danach Matrizen und räumliches
  Denken ergänzen
- Statischen Bestand für Grammatik und Wortschatz aufstocken (aktuell 6 bzw. 8,
  mit Pro 9 bzw. 12)
- Abo-Status serverseitig über die Play Developer API prüfen – oder auf
  RevenueCat wechseln, falls die Abo-Verwaltung zum Problem wird
  (`PurchaseService` ist dafür die einzige zu ersetzende Datei)
- Branchen-Profile als Filter über die bestehenden Module legen
- Verlaufskurven je Unterkategorie (bisher nur gesamt und je Modul); ab einer
  größeren Historie lohnt der Wechsel von SharedPreferences auf eine lokale
  Datenbank
- Firebase-Projekt anlegen und `firebase_options.dart` erzeugen – die
  Anmeldung ist fertig verdrahtet und wartet nur auf die Konfiguration
- Abgleich im Hintergrund anstoßen (nach jeder Sitzung, nicht nur beim
  Anmelden und auf Knopfdruck)
- Antippen einer Erinnerung direkt in die passende Übungsrunde führen lassen
  (die Benachrichtigung öffnet bislang nur die App)
