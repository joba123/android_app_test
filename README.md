# Einstellungstest Trainer

Flutter-App zur Vorbereitung auf Einstellungs- und Eignungstests bei Bewerbungen
(Polizei, Verwaltung, Bahn, Industrie und andere). Die App startet bewusst
**branchenneutral**: Trainiert werden die Aufgabentypen, die in praktisch jedem
Auswahlverfahren vorkommen. Ein Branchen-Filter kann später als zusätzliche
Dimension ergänzt werden, ohne die bestehende Struktur zu verändern.

Zielplattform ist Android, iOS ist perspektivisch vorgesehen. Es wird nichts
verwendet, was einer späteren iOS-Unterstützung im Weg steht.

## Module

Jedes Modul bietet dieselben drei Trainingsmodi.

| Modul (Kategorie) | Unterkategorien | Antwortformat | Quelle |
| --- | --- | --- | --- |
| **Mathematik** | Grundrechenarten · Dreisatz · Prozentrechnung · Textaufgaben | Zahleneingabe | generiert (unbegrenzt) |
| **Logisches Denken** | Zahlenreihen (23) · Figurenanalogien (15) · Schlussfolgerungen (8) | Multiple Choice | statisch |
| **Sprache** | Rechtschreibung (21) · Wortanalogien (15) · Grammatik (6) · Wortschatz & Textverständnis (8) | Multiple Choice | statisch |

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

**Testsimulation** – Realitätsnaher Durchlauf über **mindestens 30 Minuten**,
aufgeteilt in mehrere Testteile mit jeweils fest vorgegebener Bearbeitungszeit.
Vor jedem Teil gibt es ein kurzes Briefing (Aufgabenzahl, Zeit, Ø Zeit pro
Aufgabe) – die Uhr läuft erst nach dem Start. Läuft die Zeit eines Teils ab,
zählen die offenen Aufgaben als nicht beantwortet und es geht automatisch zum
nächsten Teil weiter. Ein Zurück gibt es nicht. Am Ende steht eine Auswertung
pro Testteil und pro Aufgabe.

| Simulation | Aufbau | Dauer |
| --- | --- | --- |
| Mathematik | 8 + 10 + 12 Min | 30 Min |
| Logisches Denken | 10 + 8 + 14 Min | 32 Min |
| Sprache | 8 + 10 + 14 Min | 32 Min |
| **Gesamtsimulation** | 3 × 14 Min (alle Module) | 42 Min |

Zusätzlich gibt es einen Statistik-Screen mit Trefferquote, Sprint-Bestwerten
und Rundenzahl je Modul sowie den zuletzt abgeschlossenen Sitzungen. Beides wird
lokal auf dem Gerät gespeichert; der Verlauf ist auf die letzten 50 Sitzungen
begrenzt.

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
├── main.dart                  App-Start, lädt SharedPreferences vor
├── app.dart                   MaterialApp + Material-3-Theme
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
│   └── module_stats.dart      Persistierter Lernfortschritt
├── screens/                   UI-Screens
│   ├── home_screen.dart       Schnellstart, Module, Gesamtsimulation
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
│   └── storage_service.dart   Lokale Persistenz (SharedPreferences)
├── widgets/                   Wiederverwendbare Bausteine
│   ├── module_card.dart       Modul- und Modus-Kacheln
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

## Einrichtung

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
Build-Tools 35) und JDK 17 benötigt.

### Build & Tests

```bash
flutter analyze
flutter test
flutter build apk --debug
flutter build apk --release
```

Verifiziert mit Flutter 3.35.4 / Dart 3.9.2: `flutter analyze` meldet keine
Befunde, alle 180 Tests laufen durch, Debug- und Release-APK werden erzeugt.
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
- **Oberfläche** – Navigation, Auswahl von Übungsumfang und Sprint-Aufgabentyp,
  Fortschrittsanzeige, sofortige Rückmeldung mit Erklärung, Sprint ohne
  Erklärung bis zum Zeitablauf, Auswertung mit Fehlerquote und Zeiten,
  Zahleneingabefeld inklusive Fehlerfall

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
- Statischen Bestand für Grammatik und Wortschatz aufstocken (aktuell 6 bzw. 8)
- Schwierigkeitswahl in der Oberfläche sichtbar machen – die Generatoren können
  sie bereits, genutzt wird bislang die Mischung
- Branchen-Profile als Filter über die bestehenden Module legen
- Rückfrage beim Verlassen einer laufenden Runde über die Android-Zurück-Taste
  (`PopScope`)
- Auswertung über mehrere Sitzungen hinweg (Verlaufskurven je Unterkategorie) –
  die Daten dafür liegen bereits in `TrainingSession`, ab einer größeren
  Historie lohnt der Wechsel von SharedPreferences auf eine lokale Datenbank
- Auth/Sync, falls der Fortschritt geräteübergreifend verfügbar sein soll
  (`lib/services/` ist dafür der vorgesehene Ort)
