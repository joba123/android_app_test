import 'package:einstellungstest_trainer/app.dart';
import 'package:einstellungstest_trainer/services/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  /// Startet die App auf einer hohen Testflaeche.
  ///
  /// Die Standardgroesse von 800x600 ist niedriger als ein echtes Handy-
  /// Display: Die ListView wuerde die unteren Karten gar nicht erst bauen und
  /// die Assertions liefen ins Leere.
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
  });

  testWidgets('Übungsmodus zeigt nach einer Antwort die Erklärung',
      (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Mathematik'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Übungsmodus'));
    await tester.pumpAndSettle();

    expect(find.text('Aufgabe 1 von 10'), findsOneWidget);

    // Option A antippen - richtig oder falsch, aufgedeckt wird in jedem Fall.
    await tester.tap(find.text('A'));
    await tester.pumpAndSettle();

    expect(find.text('Weiter'), findsOneWidget);
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
    // Vor dem Start laeuft noch kein Countdown.
    expect(find.text('Überspringen'), findsNothing);

    await tester.tap(find.text('Teil starten'));
    await tester.pump();

    expect(find.text('Überspringen'), findsOneWidget);
  });
}
