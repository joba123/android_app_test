import 'package:einstellungstest_trainer/app.dart';
import 'package:einstellungstest_trainer/models/question.dart';
import 'package:einstellungstest_trainer/services/providers.dart';
import 'package:einstellungstest_trainer/widgets/numeric_answer_field.dart';
import 'package:einstellungstest_trainer/widgets/question_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  /// Startet die App auf einer hohen Testfläche.
  ///
  /// Die Standardgröße von 800x600 ist niedriger als ein echtes Handy-Display:
  /// Die ListView würde die unteren Karten gar nicht erst bauen und die
  /// Assertions liefen ins Leere.
  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1000, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const EinstellungstestTrainerApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Startseite → Übungsmodus → Auswahlbildschirm.
  Future<void> openPracticeSetup(WidgetTester tester) async {
    await tester.tap(find.text('Übungsmodus'));
    await tester.pumpAndSettle();
  }

  testWidgets('Startseite listet Schnellstart, Module und Gesamtsimulation',
      (tester) async {
    await pumpApp(tester);

    expect(find.text('Übungsmodus'), findsOneWidget);
    expect(find.text('Mathematik'), findsOneWidget);
    expect(find.text('Logisches Denken'), findsOneWidget);
    expect(find.text('Sprache'), findsOneWidget);
    expect(find.text('Gesamtsimulation'), findsOneWidget);
  });

  group('Auswahl des Übungsumfangs', () {
    testWidgets('bietet Misch-Modus, Module und einzelne Themen an',
        (tester) async {
      await pumpApp(tester);
      await openPracticeSetup(tester);

      expect(find.text('Alle Kategorien gemischt'), findsOneWidget);
      // Jedes Modul bringt eine "Alle Themen"-Zeile mit.
      expect(find.text('Alle Themen'), findsNWidgets(3));
      // Beispiele für einzelne Themen aus allen drei Modulen.
      expect(find.text('Prozentrechnung'), findsOneWidget);
      expect(find.text('Zahlenreihen'), findsOneWidget);
      expect(find.text('Wortanalogien'), findsOneWidget);
    });

    testWidgets('startet standardmäßig im Misch-Modus', (tester) async {
      await pumpApp(tester);
      await openPracticeSetup(tester);

      expect(
        find.text('Auswahl: Alle Kategorien gemischt'),
        findsOneWidget,
      );
    });

    testWidgets('übernimmt die Auswahl eines einzelnen Themas', (tester) async {
      await pumpApp(tester);
      await openPracticeSetup(tester);

      await tester.tap(find.text('Zahlenreihen'));
      await tester.pumpAndSettle();

      expect(
        find.text('Auswahl: Logisches Denken · Zahlenreihen'),
        findsOneWidget,
      );
    });

    testWidgets('der gewählte Umfang bestimmt die Fortschrittsanzeige',
        (tester) async {
      await pumpApp(tester);
      await openPracticeSetup(tester);

      await tester.tap(find.text('10 Aufgaben'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Übung starten'));
      await tester.pumpAndSettle();

      expect(find.text('Aufgabe 1/10'), findsOneWidget);
    });
  });

  group('Übungsrunde', () {
    testWidgets('zeigt Fortschritt und deckt nach einer Auswahl die '
        'Erklärung auf', (tester) async {
      await pumpApp(tester);
      await openPracticeSetup(tester);

      // Zahlenreihen bestehen durchgängig aus Auswahlaufgaben.
      await tester.tap(find.text('Zahlenreihen'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Übung starten'));
      await tester.pumpAndSettle();

      expect(find.text('Aufgabe 1/20'), findsOneWidget);

      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();

      // Rückmeldung samt Erklärung, erst danach geht es weiter.
      expect(find.text('Weiter'), findsOneWidget);
      expect(find.byType(ExplanationBox), findsOneWidget);

      await tester.tap(find.text('Weiter'));
      await tester.pumpAndSettle();

      expect(find.text('Aufgabe 2/20'), findsOneWidget);
      expect(find.byType(ExplanationBox), findsNothing);
    });

    testWidgets('Rechenaufgaben zeigen ein Eingabefeld statt Optionen',
        (tester) async {
      await pumpApp(tester);
      await openPracticeSetup(tester);

      await tester.tap(find.text('Grundrechenarten'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Übung starten'));
      await tester.pumpAndSettle();

      expect(find.byType(NumericAnswerField), findsOneWidget);
      expect(find.text('Prüfen'), findsOneWidget);
    });

    testWidgets('am Ende steht die Zusammenfassung mit Fehlerquote und Zeit',
        (tester) async {
      await pumpApp(tester);
      await openPracticeSetup(tester);

      await tester.tap(find.text('Zahlenreihen'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('10 Aufgaben'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Übung starten'));
      await tester.pumpAndSettle();

      for (var i = 0; i < 10; i++) {
        await tester.tap(find.text('A'));
        await tester.pumpAndSettle();
        await tester.tap(
          find.text(i == 9 ? 'Auswertung' : 'Weiter'),
        );
        await tester.pumpAndSettle();
      }

      expect(find.text('Auswertung'), findsOneWidget); // AppBar-Titel
      expect(find.text('Fehlerquote'), findsOneWidget);
      expect(find.text('Ø pro Aufgabe'), findsOneWidget);
      expect(find.text('Gesamtdauer'), findsOneWidget);
      expect(find.text('Noch eine Runde'), findsOneWidget);
    });
  });

  group('Sprint', () {
    /// Startseite → Sprint-Modus → Auswahl des Aufgabentyps.
    Future<void> openSprintSetup(WidgetTester tester) async {
      await tester.tap(find.text('Sprint-Modus'));
      await tester.pumpAndSettle();
    }

    /// Route-Wechsel abwarten, ohne auf den laufenden Countdown zu warten –
    /// pumpAndSettle würde bei einem periodischen Timer nie zurückkehren.
    Future<void> settleRoute(WidgetTester tester) async {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
    }

    testWidgets('lässt den Aufgabentyp wählen, aber nicht mischen',
        (tester) async {
      await pumpApp(tester);
      await openSprintSetup(tester);

      expect(find.text('Welchen Aufgabentyp?'), findsOneWidget);
      expect(find.text('Grundrechenarten'), findsOneWidget);
      expect(find.text('Zahlenreihen'), findsOneWidget);
      // Ein Sprint misst das Tempo in einer Disziplin – kein Misch-Modus.
      expect(find.text('Alle Kategorien gemischt'), findsNothing);
      // Ohne Umfangswahl: die Runde dauert immer 60 Sekunden.
      expect(find.text('10 Aufgaben'), findsNothing);
    });

    testWidgets('zeigt den Aufgabentyp im Titel der Runde', (tester) async {
      await pumpApp(tester);
      await openSprintSetup(tester);

      await tester.tap(find.text('Zahlenreihen'));
      await tester.pumpAndSettle();
      expect(find.text('Zahlenreihen Sprint'), findsOneWidget);

      await tester.tap(find.text('Sprint starten'));
      await settleRoute(tester);

      expect(find.text('Zahlenreihen Sprint'), findsOneWidget);
      expect(find.text('Sprint läuft'), findsOneWidget);
    });

    testWidgets('schaltet ohne Erklärung direkt weiter', (tester) async {
      await pumpApp(tester);
      await openSprintSetup(tester);

      await tester.tap(find.text('Zahlenreihen'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sprint starten'));
      await settleRoute(tester);

      expect(find.text('0 richtig · 0 bearbeitet'), findsOneWidget);

      await tester.tap(find.text('A'));
      await tester.pump();

      // Kein Feedback, kein "Weiter" – die nächste Aufgabe steht sofort da.
      expect(find.byType(ExplanationBox), findsNothing);
      expect(find.text('Weiter'), findsNothing);
      expect(find.textContaining('1 bearbeitet'), findsOneWidget);
    });

    testWidgets('wertet nach Ablauf der Zeit aus', (tester) async {
      await pumpApp(tester);
      await openSprintSetup(tester);

      await tester.tap(find.text('Zahlenreihen'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sprint starten'));
      await settleRoute(tester);

      await tester.tap(find.text('A'));
      await tester.pump();

      // Die volle Minute im Zeitraffer verstreichen lassen.
      for (var second = 0; second < 61; second++) {
        await tester.pump(const Duration(seconds: 1));
      }
      await tester.pumpAndSettle();

      expect(find.text('bearbeitet'), findsOneWidget);
      expect(find.text('Fehlerquote'), findsOneWidget);
      expect(find.text('Ø pro Aufgabe'), findsOneWidget);
      expect(find.textContaining('Bestwert'), findsWidgets);
    });
  });

  testWidgets('Modul-Screen bietet alle drei Trainingsmodi an', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Mathematik'));
    await tester.pumpAndSettle();

    expect(find.text('Übungsmodus'), findsOneWidget);
    expect(find.text('Sprint-Modus'), findsOneWidget);
    expect(find.text('Testsimulation'), findsOneWidget);
    // Die Unterkategorien des Moduls werden als Themenchips gezeigt.
    expect(find.text('Dreisatz'), findsOneWidget);
    expect(find.text('Prozentrechnung'), findsOneWidget);
  });

  group('Testsimulation', () {
    /// Startseite → Modul → Testsimulation, Briefing des ersten Teils.
    Future<void> openSimulation(WidgetTester tester) async {
      await tester.tap(find.text('Mathematik'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Testsimulation'));
      await tester.pumpAndSettle();
    }

    testWidgets('startet mit einem Briefing statt sofort', (tester) async {
      await pumpApp(tester);
      await openSimulation(tester);

      expect(find.text('Teil 1 von 3'), findsOneWidget);
      expect(find.text('Teil starten'), findsOneWidget);
      // Vor dem Start läuft noch kein Countdown.
      expect(find.text('Überspringen'), findsNothing);

      await tester.tap(find.text('Teil starten'));
      await tester.pump();

      expect(find.text('Überspringen'), findsOneWidget);
    });

    testWidgets('nennt im Briefing Aufgabenzahl, Zeit und Taktung',
        (tester) async {
      await pumpApp(tester);
      await openSimulation(tester);

      expect(find.text('Bearbeitungszeit'), findsOneWidget);
      expect(find.text('Ø pro Aufgabe'), findsOneWidget);
      expect(find.text('Bereiche'), findsOneWidget);
      expect(find.text('10 Minuten'), findsOneWidget);
      expect(find.text('30 Sekunden'), findsOneWidget);
    });

    testWidgets('zeigt während des Laufs keine Lösung', (tester) async {
      await pumpApp(tester);
      await openSimulation(tester);
      await tester.tap(find.text('Teil starten'));
      await tester.pump();

      // Grundrechenarten sind Zahleneingaben.
      await tester.enterText(find.byType(TextField), '12345');
      await tester.tap(find.text('Prüfen'));
      await tester.pump();

      expect(find.byType(ExplanationBox), findsNothing);
      expect(find.textContaining('Richtig wäre'), findsNothing);
      // Die nächste Aufgabe steht sofort da.
      expect(find.text('Aufgabe 2 von 20'), findsOneWidget);
    });

    testWidgets('warnt deutlich, bevor pausiert wird', (tester) async {
      await pumpApp(tester);
      await openSimulation(tester);
      await tester.tap(find.text('Teil starten'));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.pause_circle_outline));
      await tester.pump();

      expect(find.text('Wirklich pausieren?'), findsOneWidget);
      expect(
        find.textContaining('kannst du nicht pausieren'),
        findsOneWidget,
      );

      // Ablehnen lässt den Test weiterlaufen.
      await tester.tap(find.text('Weitermachen'));
      await tester.pump();
      expect(find.text('Überspringen'), findsOneWidget);

      // Bestätigen führt in den Pausenzustand.
      await tester.tap(find.byIcon(Icons.pause_circle_outline));
      await tester.pump();
      await tester.tap(find.text('Trotzdem pausieren'));
      await tester.pump();

      expect(find.text('Simulation pausiert'), findsOneWidget);
      expect(find.text('Weiter im Test'), findsOneWidget);
    });

    testWidgets('die Zurück-Taste bricht nicht still ab', (tester) async {
      await pumpApp(tester);
      await openSimulation(tester);
      await tester.tap(find.text('Teil starten'));
      await tester.pump();

      // Android-Zurück auslösen.
      await tester.binding.handlePopRoute();
      await tester.pump();

      expect(find.text('Simulation verlassen?'), findsOneWidget);

      await tester.tap(find.text('Weitermachen'));
      await tester.pump();
      // Immer noch im laufenden Teil.
      expect(find.text('Überspringen'), findsOneWidget);
    });

    testWidgets('wertet nach dem Abbruch vollständig aus', (tester) async {
      await pumpApp(tester);
      await openSimulation(tester);
      await tester.tap(find.text('Teil starten'));
      await tester.pump();

      await tester.tap(find.text('Beenden'));
      await tester.pump();
      await tester.tap(find.text('Abbrechen'));
      await tester.pumpAndSettle();

      expect(find.text('Testergebnis'), findsOneWidget);
      expect(find.text('Fehlerquote nach Kategorie'), findsOneWidget);
      expect(find.text('Ergebnis nach Testteilen'), findsOneWidget);
      expect(find.text('Fehlerquote'), findsOneWidget);
      expect(find.text('Ø pro Aufgabe'), findsOneWidget);
      expect(find.text('nicht bearbeitet'), findsOneWidget);
    });

    testWidgets('vermerkt eine Unterbrechung in der Auswertung',
        (tester) async {
      await pumpApp(tester);
      await openSimulation(tester);
      await tester.tap(find.text('Teil starten'));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.pause_circle_outline));
      await tester.pump();
      await tester.tap(find.text('Trotzdem pausieren'));
      await tester.pump();

      await tester.tap(find.text('Simulation abbrechen'));
      await tester.pump();
      await tester.tap(find.text('Abbrechen'));
      await tester.pumpAndSettle();

      expect(find.textContaining('einmal unterbrochen'), findsOneWidget);
      expect(
        find.textContaining('nur eingeschränkt vergleichbar'),
        findsOneWidget,
      );
    });
  });

  group('Konto & Sicherung', () {
    /// Startseite → Konto.
    Future<void> openAccount(WidgetTester tester) async {
      await tester.tap(find.byIcon(Icons.account_circle_outlined));
      await tester.pumpAndSettle();
    }

    testWidgets('erklärt den lokalen Modus, solange niemand angemeldet ist',
        (tester) async {
      await pumpApp(tester);
      await openAccount(tester);

      expect(find.text('Konto & Sicherung'), findsOneWidget);
      expect(find.text('Lokaler Modus'), findsOneWidget);
      // Ohne Firebase-Konfiguration wird gar keine Anmeldung angeboten.
      expect(find.text('Mit Google anmelden'), findsNothing);
      expect(
        find.textContaining('kein Firebase-Projekt'),
        findsOneWidget,
      );
    });

    testWidgets('nennt im Klartext, was gespeichert wird und was nicht',
        (tester) async {
      await pumpApp(tester);
      await openAccount(tester);

      expect(find.text('Mit Konto wird gespeichert'), findsOneWidget);
      expect(find.text('Nicht gespeichert'), findsOneWidget);
      expect(find.textContaining('EU-Region'), findsOneWidget);
    });

    testWidgets('der gesetzte Testtermin erscheint auf der Startseite',
        (tester) async {
      await pumpApp(tester);
      await openAccount(tester);

      expect(find.text('Noch kein Termin hinterlegt.'), findsOneWidget);

      await tester.tap(find.text('Termin setzen'));
      await tester.pumpAndSettle();
      // Der Kalender steht auf "in 30 Tagen" – bestaetigen genuegt.
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.text('Noch 30 Tage'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.text('Noch 30 Tage'), findsOneWidget);
    });
  });

  group('Eingabefeld für Zahlen', () {
    Future<void> pumpField(
      WidgetTester tester, {
      required bool Function(String) onSubmit,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NumericAnswerField(
              format: const NumericInput(correctValue: 84, unit: 'km/h'),
              onSubmit: onSubmit,
            ),
          ),
        ),
      );
    }

    testWidgets('reicht die Eingabe beim Tippen auf "Prüfen" weiter',
        (tester) async {
      String? received;
      await pumpField(tester, onSubmit: (input) {
        received = input;
        return true;
      });

      await tester.enterText(find.byType(TextField), '84');
      await tester.tap(find.text('Prüfen'));
      await tester.pump();

      expect(received, '84');
    });

    testWidgets('zeigt einen Hinweis, wenn die Eingabe unlesbar ist',
        (tester) async {
      await pumpField(tester, onSubmit: (_) => false);

      // Buchstaben filtert der inputFormatter schon weg – "1.2.3" kommt
      // dagegen durch und scheitert erst beim Einlesen.
      await tester.enterText(find.byType(TextField), '1.2.3');
      await tester.tap(find.text('Prüfen'));
      await tester.pump();

      expect(find.text('Bitte eine Zahl eingeben'), findsOneWidget);
    });

    testWidgets('der Formatter lässt nur Ziffern und Trennzeichen zu',
        (tester) async {
      await pumpField(tester, onSubmit: (_) => true);

      await tester.enterText(find.byType(TextField), 'a1b2,5c');

      expect(
        tester.widget<TextField>(find.byType(TextField)).controller?.text,
        '12,5',
      );
    });

    testWidgets('leert das Feld nach einer angenommenen Eingabe',
        (tester) async {
      await pumpField(tester, onSubmit: (_) => true);

      await tester.enterText(find.byType(TextField), '84');
      await tester.tap(find.text('Prüfen'));
      await tester.pump();

      expect(
        tester.widget<TextField>(find.byType(TextField)).controller?.text,
        isEmpty,
      );
    });
  });
}
