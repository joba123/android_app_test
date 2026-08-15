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

| Modul (Kategorie) | Unterkategorien | Antwortformat |
| --- | --- | --- |
| **Mathematik** | Grundrechenarten · Dreisatz · Prozentrechnung · Textaufgaben | überwiegend Zahleneingabe |
| **Logisches Denken** | Zahlenreihen · Wortanalogien · Figurenanalogien · Schlussfolgerungen | Multiple Choice |
| **Sprache** | Rechtschreibung · Grammatik · Wortschatz & Textverständnis | Multiple Choice |

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

### Trainingsmodi

**Übungsmodus** – Lernen ohne Zeitdruck. Nach jeder Antwort wird die Lösung
sofort aufgedeckt und erklärt. Standardumfang sind 10 Aufgaben pro Runde.

**Sprint-Modus** – 60 Sekunden, so viele richtige Antworten wie möglich. Kein
Feedback zwischendurch, direktes Weiterschalten nach jedem Tipp. Pro Modul wird
ein Bestwert gespeichert.

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
│   ├── quiz_session.dart      Zustand für Übung & Sprint
│   ├── simulation.dart        Testteile, Simulationszustand, Auswertung
│   ├── training_session.dart  Abgeschlossene Sitzung für den Verlauf
│   └── module_stats.dart      Persistierter Lernfortschritt
├── screens/                   UI-Screens
│   ├── home_screen.dart       Modulübersicht + Gesamtsimulation
│   ├── module_screen.dart     Modus-Auswahl innerhalb eines Moduls
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
│   ├── question_card.dart     Aufgabenkarte + Erklärungsbox
│   ├── answer_option_tile.dart  Antwortoption mit Zustandsfarben
│   ├── timer_bar.dart         Countdown-Anzeige
│   └── stat_tile.dart         Kennzahl-Kachel
└── data/                      Aufgabenpools / Content
    ├── math_questions.dart
    ├── logic_questions.dart
    ├── language_questions.dart
    ├── question_pool.dart     Zentraler Zugriff & Themenfilter
    └── simulation_blueprints.dart  Baupläne der Testsimulationen
```

### Zwei Entwurfsentscheidungen, die beim Erweitern relevant sind

**Antwortoptionen werden zur Laufzeit gemischt.** Im Content stehen die Optionen
in sinnvoller Reihenfolge (z. B. Zahlen aufsteigend); das Mischen übernimmt die
`QuestionRepository`. So kann sich niemand eine Antwortposition merken, und der
Content bleibt gut lesbar. `MultipleChoice.reordered()` zieht den `correctIndex`
dabei korrekt mit; Aufgaben mit Zahleneingabe bleiben unangetastet.

**Zwei Modelle für eine Sitzung.** `AnswerRecord` lebt nur während einer Runde
und kennt die vollständige `Question` – die Auswertung braucht Aufgabentext und
Erklärung. Für den dauerhaften Verlauf wird daraus eine `TrainingSession` mit
schlanken `QuestionResult`-Einträgen (nur ID, Unterkategorie, richtig/falsch,
Zeit). So bleibt der Verlauf auch dann lesbar, wenn eine Aufgabe später aus dem
Pool entfernt oder umformuliert wird.

**Content ist austauschbar.** Aktuell liegen die Aufgaben als `const`-Listen im
Code. Kommt später ein Backend oder eine lokale Datenbank dazu, wird nur die
`QuestionRepository` ersetzt – Screens und Controller bleiben unverändert.

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
Befunde, alle 96 Tests laufen durch, Debug- und Release-APK werden erzeugt.
Der Release-Build ist vorerst mit dem Debug-Key signiert, damit er ohne weitere
Einrichtung durchläuft – vor einer Veröffentlichung muss in
`android/app/build.gradle` ein echter Release-Keystore hinterlegt werden.

Die Tests decken ab:

- **Aufgabenmodell** – Auswertung beider Antwortformate, Einlesen deutscher
  Zahleneingaben, Toleranzen, Umsortieren der Optionen, sowie das Verhalten bei
  Antworten, die nicht zum Format der Aufgabe passen
- **Sitzungsmodell** – Kennzahlen (richtig/falsch/übersprungen, Trefferquote,
  Zeit pro Aufgabe), Gruppierung nach Unterkategorie und JSON-Zyklus inklusive
  defekter Datensätze
- **Aufgabenpool** – eindeutige IDs, stimmige Antwortformate, jede
  Unterkategorie gefüllt, ausreichend Aufgaben für jede Simulation
- **Ablauf** – beide Quiz-Modi, der mehrteilige Simulationsablauf mit
  Zeitablauf und Auswertung, Persistenz von Fortschritt und Verlauf
- **Oberfläche** – Navigation, Zahleneingabefeld inklusive Fehlerfall

## Stand und nächste Schritte

Der Aufgabenpool ist bewusst als **Startbestand** angelegt (rund 60 Aufgaben,
gleichmäßig über die drei Module und ihre Themen verteilt) – genug, um alle
Modi und Simulationen vollständig durchzuspielen. Für den produktiven Einsatz
muss er deutlich wachsen; die Struktur dafür steht.

Die Figurenanalogien sind aktuell **sprachlich beschrieben** statt gezeichnet –
im echten Test sind das Bildaufgaben. Die Aufgabenlogik stimmt, die Darstellung
ist ein Zwischenschritt, bis Grafik-Assets vorliegen.

Naheliegende nächste Schritte:

- Aufgabenpool ausbauen, insbesondere echte Bild-Aufgaben für Figurenanalogien,
  Matrizen und räumliches Denken
- Branchen-Profile als Filter über die bestehenden Module legen
- Rückfrage beim Verlassen einer laufenden Runde über die Android-Zurück-Taste
  (`PopScope`)
- Auswertung über mehrere Sitzungen hinweg (Verlaufskurven je Unterkategorie) –
  die Daten dafür liegen bereits in `TrainingSession`, ab einer größeren
  Historie lohnt der Wechsel von SharedPreferences auf eine lokale Datenbank
- Auth/Sync, falls der Fortschritt geräteübergreifend verfügbar sein soll
  (`lib/services/` ist dafür der vorgesehene Ort)
