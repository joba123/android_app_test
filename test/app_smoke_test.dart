import 'package:einstellungstest_trainer/app.dart';
import 'package:einstellungstest_trainer/models/question.dart';
import 'package:einstellungstest_trainer/services/providers.dart';
import 'package:einstellungstest_trainer/widgets/numeric_answer_field.dart';
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
    tester.view.physicalSize = const Size(1000, 2200);
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

  testWidgets('Startseite listet alle Module und die Gesamtsimulation',
      (tester) async {
    await pumpApp(tester);

    expect(find.text('Mathematik'), findsOneWidget);
    expect(find.text('Logisches Denken'), findsOneWidget);
    expect(find.text('Sprache'), findsOneWidget);
    expect(find.text('Gesamtsimulation'), findsOneWidget);
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

  testWidgets('Übungsmodus deckt nach einer Auswahl die Erklärung auf',
      (tester) async {
    await pumpApp(tester);

    // Logik besteht durchgängig aus Auswahlaufgaben.
    await tester.tap(find.text('Logisches Denken'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Übungsmodus'));
    await tester.pumpAndSettle();

    expect(find.text('Aufgabe 1 von 10'), findsOneWidget);

    await tester.tap(find.text('A'));
    await tester.pumpAndSettle();

    expect(find.text('Weiter'), findsOneWidget);
  });

  testWidgets('Mathematik-Übung zeigt ein Eingabefeld statt Optionen',
      (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Mathematik'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Übungsmodus'));
    await tester.pumpAndSettle();

    // Der Pool ist überwiegend numerisch – bis zur ersten Rechenaufgabe
    // notfalls weiterblättern.
    for (var i = 0; i < 10; i++) {
      if (find.byType(NumericAnswerField).evaluate().isNotEmpty) break;
      await tester.tap(find.text('Weiß ich nicht'));
      await tester.pumpAndSettle();
    }

    expect(find.byType(NumericAnswerField), findsOneWidget);
    expect(find.text('Prüfen'), findsOneWidget);
  });

  testWidgets('Testsimulation startet mit einem Briefing statt sofort',
      (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Mathematik'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Testsimulation'));
    await tester.pumpAndSettle();

    expect(find.text('Teil 1 von 3'), findsOneWidget);
    expect(find.text('Teil starten'), findsOneWidget);
    // Vor dem Start läuft noch kein Countdown.
    expect(find.text('Überspringen'), findsNothing);

    await tester.tap(find.text('Teil starten'));
    await tester.pump();

    expect(find.text('Überspringen'), findsOneWidget);
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
