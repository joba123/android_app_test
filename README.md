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

| Modul | Themen |
| --- | --- |
| **Mathematik** | Grundrechenarten · Dreisatz & Prozent · Textaufgaben |
| **Logisches Denken** | Zahlenreihen · Analogien & Wortlogik · Muster & Schlussfolgerungen |
| **Sprache** | Rechtschreibung · Grammatik · Wortschatz & Textverständnis |

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
und Rundenzahl je Modul. Der Fortschritt wird lokal auf dem Gerät gespeichert.

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
│   ├── training_module.dart   Module inkl. Farbe/Icon/Beschreibung
│   ├── question.dart          Aufgabe + Schwierigkeitsgrad
│   ├── answer_record.dart     Protokoll einer (Nicht-)Antwort
│   ├── quiz_session.dart      Zustand für Übung & Sprint
│   ├── simulation.dart        Testteile, Simulationszustand, Auswertung
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
Content bleibt gut lesbar. `Question.reordered()` zieht den `correctIndex` dabei
korrekt mit.

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
Befunde, alle 33 Tests laufen durch, Debug- und Release-APK werden erzeugt.
Der Release-Build ist vorerst mit dem Debug-Key signiert, damit er ohne weitere
Einrichtung durchläuft – vor einer Veröffentlichung muss in
`android/app/build.gradle` ein echter Release-Keystore hinterlegt werden.

Die Tests decken den Aufgabenpool (eindeutige IDs, gültige Lösungsindizes,
ausreichend Aufgaben für jede Simulation), das Ziehen und Mischen, beide
Quiz-Modi sowie den mehrteiligen Simulationsablauf inklusive Zeitablauf und
Auswertung ab.

## Stand und nächste Schritte

Der Aufgabenpool ist bewusst als **Startbestand** angelegt (rund 60 Aufgaben,
gleichmäßig über die drei Module und ihre Themen verteilt) – genug, um alle
Modi und Simulationen vollständig durchzuspielen. Für den produktiven Einsatz
muss er deutlich wachsen; die Struktur dafür steht.

Naheliegende nächste Schritte:

- Aufgabenpool ausbauen, ggf. mit Bild-Aufgaben (Matrizen, räumliches Denken)
- Branchen-Profile als Filter über die bestehenden Module legen
- Rückfrage beim Verlassen einer laufenden Runde über die Android-Zurück-Taste
  (`PopScope`)
- Verlaufsstatistik pro Sitzung statt nur Zählerständen – dafür ist der Wechsel
  von SharedPreferences auf eine lokale Datenbank vorgesehen
- Auth/Sync, falls der Fortschritt geräteübergreifend verfügbar sein soll
  (`lib/services/` ist dafür der vorgesehene Ort)
