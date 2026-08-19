import 'package:einstellungstest_trainer/app.dart';
import 'package:einstellungstest_trainer/models/question.dart';
import 'package:einstellungstest_trainer/models/training_module.dart';
import 'package:einstellungstest_trainer/services/notifications/reminder_controller.dart';
import 'package:einstellungstest_trainer/services/notifications/reminder_service.dart';
import 'package:einstellungstest_trainer/services/providers.dart';
import 'package:einstellungstest_trainer/services/purchase/entitlement_controller.dart';
import 'package:einstellungstest_trainer/services/purchase/purchase_service.dart';
import 'package:einstellungstest_trainer/widgets/feedback_sheet.dart';
import 'package:einstellungstest_trainer/widgets/numeric_answer_field.dart';
import 'package:einstellungstest_trainer/widgets/question_card.dart';
import 'package:einstellungstest_trainer/widgets/timer_bar.dart';
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
  Future<void> pumpApp(
    WidgetTester tester, {
    List<Override> overrides = const [],
    bool onboarded = true,
  }) async {
    tester.view.physicalSize = const Size(1000, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    // Die Einfuehrung laeuft nur beim allerersten Start. Fuer die uebrigen
    // Tests wird sie uebersprungen, sonst muesste sich jeder Test erst
    // durchklicken.
    SharedPreferences.setMockInitialValues(
      onboarded ? {'onboarding_done_v1': true} : {},
    );
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          ...overrides,
        ],
        child: const EinstellungstestTrainerApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Zurück-Navigation über die AppBar.
  ///
  /// `tester.pageBack()` sucht nach dem Tooltip „Back" – seit die App
  /// deutsch lokalisiert ist, heißt der „Zurück". Deshalb hier über den
  /// Widget-Typ statt über den Text.
  Future<void> goBack(WidgetTester tester) async {
    await tester.tap(find.byType(BackButton).first);
    await tester.pumpAndSettle();
  }

  /// Tippt etwas an, das weiter unten in einer langen Liste stehen kann.
  ///
  /// Seit es sechs Bereiche gibt, ist der Auswahlbildschirm laenger als jedes
  /// Testdisplay – ohne Scrollen ist das Ziel nicht anklickbar.
  Future<void> scrollTo(WidgetTester tester, Finder finder) async {
    if (finder.evaluate().isNotEmpty) {
      await tester.ensureVisible(finder.first);
    } else {
      // In einer langen Liste ist das Ziel noch gar nicht gebaut – erst
      // scrollen, dann sichtbar machen.
      await tester.scrollUntilVisible(
        finder,
        260,
        scrollable: find.byType(Scrollable).first,
      );
    }
    await tester.pumpAndSettle();
  }

  Future<void> tapItem(WidgetTester tester, Finder finder) async {
    await scrollTo(tester, finder);
    await tester.tap(finder.first);
    await tester.pumpAndSettle();
  }

  /// Klappt eine Bereichskarte im Hauptmenue auf.
  Future<void> openDomain(WidgetTester tester, String name) async {
    await scrollTo(tester, find.text(name));
    await tester.tap(find.text(name));
    await tester.pumpAndSettle();
  }

  /// Bereich aufklappen und den Modus waehlen.
  Future<void> startPractice(
    WidgetTester tester, {
    String domain = 'Mathematik',
  }) async {
    await openDomain(tester, domain);
    await tester.tap(find.text('Üben'));
    await tester.pumpAndSettle();
  }

  Future<void> openCategories(
    WidgetTester tester, {
    String domain = 'Logik',
  }) async {
    await openDomain(tester, domain);
    await tester.tap(find.text('Kategorien'));
    await tester.pumpAndSettle();
  }

  /// Ueber die Kategorien zum Feineinsteller fuer Umfang und Schwierigkeit.
  Future<void> openPracticeSetup(
    WidgetTester tester, {
    String domain = 'Logik',
  }) async {
    await openCategories(tester, domain: domain);
    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pumpAndSettle();
  }

  /// Wechselt auf den Reiter „Einstellungen".
  ///
  /// „Einstellungen" steht auch in der Kopfzeile des Reiters – deshalb der
  /// letzte Treffer, das ist die Leiste unten.
  Future<void> openSettings(WidgetTester tester) async {
    await tester.tap(find.text('Einstellungen').last);
    await tester.pumpAndSettle();
  }

  /// Oeffnet eine Zeile in den Einstellungen.
  Future<void> openSetting(WidgetTester tester, String row) async {
    await openSettings(tester);
    await tester.tap(find.text(row));
    await tester.pumpAndSettle();
  }

  testWidgets('Hauptmenue zeigt die drei Bereiche und den Ernstfall',
      (tester) async {
    await pumpApp(tester);

    expect(find.text('Mathematik'), findsOneWidget);
    expect(find.text('Logik'), findsOneWidget);
    expect(find.text('Sprache'), findsOneWidget);
    expect(find.text('TESTSIMULATION'), findsOneWidget);
    expect(find.text('Gesamtsimulation'), findsOneWidget);
    expect(find.text('Probelauf'), findsOneWidget);

    // Der Modus steht erst in der aufgeklappten Karte.
    expect(find.text('Üben'), findsNothing);
  });

  testWidgets('das Hauptmenue fuehrt alle sechs Bereiche', (tester) async {
    await pumpApp(tester);

    for (final module in TrainingModule.values) {
      await scrollTo(tester, find.text(module.menuLabel));
      expect(find.text(module.menuLabel), findsOneWidget);
    }
  });

  testWidgets('oben stehen Pruefung und Leitfaden', (tester) async {
    await pumpApp(tester);

    // Die Pruefung, auf die hingearbeitet wird – beim ersten Start ohne Ziel.
    expect(find.text('Meine Vorbereitung'), findsOneWidget);
    expect(find.text('Leitfaden'), findsOneWidget);
    expect(find.text('Alle Schritte'), findsOneWidget);
  });

  testWidgets('der Leitfaden nennt die offenen Themen', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Alle Schritte'));
    await tester.pumpAndSettle();

    expect(find.text('DAS FEHLT NOCH'), findsOneWidget);
    expect(find.text('Gesamtsimulation bestehen'), findsOneWidget);
    // Ohne eine einzige Aufgabe steht der Leitfaden bei null.
    expect(find.text('0 %'), findsOneWidget);
  });

  testWidgets('ueber das Menue oben laesst sich die Pruefung wechseln',
      (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Meine Vorbereitung'));
    await tester.pumpAndSettle();
    expect(find.text('Prüfungen verwalten'), findsOneWidget);

    await tester.tap(find.text('Prüfungen verwalten'));
    await tester.pumpAndSettle();
    await tapItem(tester, find.text('Prüfung hinzufügen'));

    await tester.enterText(find.byType(TextField).first, 'Polizei Bremen');
    await tapItem(tester, find.text('Polizei'));
    await tapItem(tester, find.text('Speichern'));

    // Die neue Pruefung ist sofort die aktive.
    await goBack(tester);
    expect(find.text('Polizei Bremen'), findsOneWidget);
  });

  testWidgets('der Durchstreichtest hat einen eigenen Bildschirm',
      (tester) async {
    await pumpApp(tester);
    await openCategories(tester, domain: 'Konzentration');

    await scrollTo(tester, find.text('Durchstreichtest'));
    await tester.tap(find.text('Durchstreichtest'));
    // Kein pumpAndSettle: Im Durchstreichtest laeuft eine Uhr.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Jedes d mit zwei Strichen antippen'), findsOneWidget);
    expect(find.textContaining('Gesucht: d mit zwei Strichen'), findsOneWidget);
  });

  testWidgets('eine Bereichskarte klappt die drei Modi aus', (tester) async {
    await pumpApp(tester);
    await openDomain(tester, 'Mathematik');

    expect(find.text('Üben'), findsOneWidget);
    expect(find.text('Sprint'), findsOneWidget);
    expect(find.text('Kategorien'), findsOneWidget);
    expect(find.text('ohne Zeitdruck'), findsOneWidget);
  });

  testWidgets('„Üben" startet ohne Zwischenbildschirm', (tester) async {
    await pumpApp(tester);
    await startPractice(tester);

    expect(find.textContaining('Aufgabe 1/'), findsOneWidget);
  });

  testWidgets('die untere Leiste fuehrt zu Statistiken und Einstellungen',
      (tester) async {
    await pumpApp(tester);

    expect(find.text('Hauptmenü'), findsOneWidget);
    expect(find.text('Statistiken'), findsWidgets);
    expect(find.text('Einstellungen'), findsWidgets);

    await openSettings(tester);
    expect(find.text('Prüfungen und Termine'), findsOneWidget);
    expect(find.text('Tagesziel'), findsOneWidget);
    expect(find.text('Einführung erneut ansehen'), findsOneWidget);
  });

  group('Einführung', () {
    testWidgets('erscheint beim allerersten Start', (tester) async {
      await pumpApp(tester, onboarded: false);

      expect(find.text('Drei Bereiche, ein Ziel'), findsOneWidget);
      expect(find.text('Weiter'), findsOneWidget);
    });

    testWidgets('fragt nach Name und Termin und endet in einer Runde',
        (tester) async {
      await pumpApp(tester, onboarded: false);

      for (var step = 0; step < 3; step++) {
        await tester.tap(find.text('Weiter'));
        await tester.pumpAndSettle();
      }

      // Vierter Schritt: die Fachrichtung.
      expect(find.text('Worauf übst du hin?'), findsOneWidget);
      await tester.tap(find.text('Polizei'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Weiter'));
      await tester.pumpAndSettle();

      expect(find.text('Damit wir uns kennen'), findsOneWidget);
      expect(find.text('Hast du schon einen Testtermin?'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Lena');
      await tester.tap(find.text('Erste Runde starten'));
      await tester.pumpAndSettle();

      // Direkt in die erste Runde, nicht ins Hauptmenue.
      expect(find.text('Aufgabe 1/10'), findsOneWidget);
    });

    testWidgets('der Name steht danach im Hauptmenue', (tester) async {
      await pumpApp(tester, onboarded: false);

      for (var step = 0; step < 4; step++) {
        await tester.tap(find.text('Weiter'));
        await tester.pumpAndSettle();
      }
      await tester.enterText(find.byType(TextField), 'Lena');
      await tester.tap(find.text('Erste Runde starten'));
      await tester.pumpAndSettle();

      // Die erste Runde liegt auf dem Hauptmenue – zurueck fuehrt dorthin.
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Beenden'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Zum Menü'));
      await tester.pumpAndSettle();

      // Der Name steht jetzt in der Begruessung, die grosse Zeile darunter
      // gehoert der Pruefung.
      expect(find.textContaining('Lena'), findsOneWidget);
    });

    testWidgets('laeuft nach dem Durchlaufen nicht erneut', (tester) async {
      await pumpApp(tester);

      expect(find.text('Drei Bereiche, ein Ziel'), findsNothing);
      expect(find.text('Gesamtsimulation'), findsOneWidget);
    });
  });

  group('Auswahl des Übungsumfangs', () {
    testWidgets('bietet Misch-Modus, Module und einzelne Themen an',
        (tester) async {
      await pumpApp(tester);
      await openPracticeSetup(tester);

      expect(find.text('Alle Kategorien gemischt'), findsOneWidget);
      // Jedes Modul bringt eine "Alle Themen"-Zeile mit.
      expect(
        find.text('Alle Themen'),
        findsNWidgets(TrainingModule.values.length),
      );
      // Beispiele für einzelne Themen aus allen drei Modulen.
      expect(find.text('Prozentrechnung'), findsOneWidget);
      expect(find.text('Zahlenreihen'), findsOneWidget);
      expect(find.text('Wortanalogien'), findsOneWidget);
    });

    testWidgets('uebernimmt den Bereich, aus dem er geoeffnet wurde',
        (tester) async {
      await pumpApp(tester);
      await openPracticeSetup(tester);

      expect(
        find.text('Auswahl: Logisches Denken · alle Themen'),
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

      await tapItem(tester, find.text('10 Aufgaben'));
      await tapItem(tester, find.text('Übung starten'));

      expect(find.text('Aufgabe 1/10'), findsOneWidget);
    });
  });

  group('Übungsrunde', () {
    testWidgets('zeigt Fortschritt und deckt nach einer Auswahl die '
        'Erklärung auf', (tester) async {
      await pumpApp(tester);
      await openPracticeSetup(tester);

      // Zahlenreihen bestehen durchgängig aus Auswahlaufgaben.
      await tapItem(tester, find.text('Zahlenreihen'));
      await tapItem(tester, find.text('Übung starten'));

      expect(find.text('Aufgabe 1/20'), findsOneWidget);

      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();

      // Die Rueckmeldung faehrt von unten hoch: Urteil, Rechenweg, Knopf.
      expect(find.byType(FeedbackSheet), findsOneWidget);
      expect(find.text('Weiter'), findsOneWidget);
      // Die Aufgabe bleibt darueber sichtbar.
      expect(find.byType(QuestionCard), findsOneWidget);

      await tester.tap(find.text('Weiter'));
      await tester.pumpAndSettle();

      expect(find.text('Aufgabe 2/20'), findsOneWidget);
      expect(find.byType(FeedbackSheet), findsNothing);
    });

    testWidgets('die Rückmeldung nennt Urteil, Rechenweg und den nächsten '
        'Schritt', (tester) async {
      await pumpApp(tester);
      await openPracticeSetup(tester);

      await tapItem(tester, find.text('Zahlenreihen'));
      await tapItem(tester, find.text('Übung starten'));

      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();

      final sheet = find.byType(FeedbackSheet);
      // Ob „A" richtig war, entscheidet der Zufall – das Urteil steht so
      // oder so gross oben in der Flaeche.
      expect(
        find.descendant(
          of: sheet,
          matching: find.textContaining(RegExp('Richtig|Falsch')),
        ),
        findsOneWidget,
      );
      // Der Knopf sitzt in der Flaeche, nicht mehr darueber im Bogen.
      expect(
        find.descendant(of: sheet, matching: find.text('Weiter')),
        findsOneWidget,
      );
    });

    testWidgets('Rechenaufgaben zeigen ein Eingabefeld statt Optionen',
        (tester) async {
      await pumpApp(tester);
      await openPracticeSetup(tester);

      await tapItem(tester, find.text('Grundrechenarten'));
      await tapItem(tester, find.text('Übung starten'));

      expect(find.byType(NumericAnswerField), findsOneWidget);
      expect(find.text('Prüfen'), findsOneWidget);
    });

    testWidgets('am Ende steht die Zusammenfassung mit Fehlerquote und Zeit',
        (tester) async {
      await pumpApp(tester);
      await openPracticeSetup(tester);

      await tapItem(tester, find.text('Zahlenreihen'));
      await tapItem(tester, find.text('10 Aufgaben'));
      await tapItem(tester, find.text('Übung starten'));

      for (var i = 0; i < 10; i++) {
        await tester.tap(find.text('A'));
        await tester.pumpAndSettle();
        await tester.tap(
          find.text(i == 9 ? 'Auswertung' : 'Weiter'),
        );
        await tester.pumpAndSettle();
      }

      expect(find.text('Übungsmodus abgeschlossen'), findsOneWidget);
      expect(find.text('Fehlerquote'), findsOneWidget);
      expect(find.text('Ø pro Aufgabe'), findsOneWidget);
      expect(find.text('Gesamtzeit'), findsOneWidget);
      expect(find.text('ZEIT PRO AUFGABE'), findsOneWidget);
      expect(find.text('Nochmal'), findsOneWidget);
    });
  });

  group('Sprint', () {
    /// Route-Wechsel abwarten, ohne auf den laufenden Countdown zu warten –
    /// pumpAndSettle würde bei einem periodischen Timer nie zurückkehren.
    Future<void> settleRoute(WidgetTester tester) async {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
    }

    testWidgets('startet direkt aus der Bereichskarte', (tester) async {
      await pumpApp(tester);
      await openDomain(tester, 'Logik');
      await tester.tap(find.text('Sprint'));
      await settleRoute(tester);

      // Kein Zwischenbildschirm mehr: die Uhr laeuft sofort.
      expect(find.byType(TimerPill), findsOneWidget);
      expect(find.text('Sprint'), findsOneWidget);
      expect(find.text('0 bearbeitet'), findsOneWidget);
    });

    testWidgets('schaltet ohne Erklärung direkt weiter', (tester) async {
      await pumpApp(tester);
      await openDomain(tester, 'Logik');
      await tester.tap(find.text('Sprint'));
      await settleRoute(tester);

      await tester.tap(find.text('A'));
      await tester.pump();

      // Kein Feedback, kein "Weiter" – die nächste Aufgabe steht sofort da.
      expect(find.byType(FeedbackSheet), findsNothing);
      expect(find.text('Weiter'), findsNothing);
      expect(find.text('1 bearbeitet'), findsOneWidget);
    });

    testWidgets('wertet nach Ablauf der Zeit aus', (tester) async {
      await pumpApp(tester);
      await openDomain(tester, 'Logik');
      await tester.tap(find.text('Sprint'));
      await settleRoute(tester);

      await tester.tap(find.text('A'));
      await tester.pump();

      // Die volle Minute im Zeitraffer verstreichen lassen.
      for (var second = 0; second < 61; second++) {
        await tester.pump(const Duration(seconds: 1));
      }
      await tester.pumpAndSettle();

      expect(find.text('Sprint-Modus abgeschlossen'), findsOneWidget);
      expect(find.text('Fehlerquote'), findsOneWidget);
      expect(find.text('Ø pro Aufgabe'), findsOneWidget);
      expect(find.textContaining('Bestwert'), findsWidgets);
    });
  });

  group('Testsimulation', () {
    /// Startseite → Modul → Testsimulation, Briefing des ersten Teils.
    Future<void> openSimulation(WidgetTester tester) async {
      await tester.tap(find.text('Starten'));
      await tester.pumpAndSettle();
    }

    testWidgets('der Probelauf ist ein einzelner, kurzer Teil',
        (tester) async {
      await pumpApp(tester);

      await tester.tap(find.text('Probelauf'));
      await tester.pumpAndSettle();

      // Ein Teil – also keine Teil-Zaehlung, die nichts zu zaehlen hat.
      expect(find.textContaining('Ein Testteil, 10 Minuten'), findsOneWidget);
      expect(find.text('Teil 1 von 1'), findsNothing);

      await tester.tap(find.text('Teil starten'));
      await tester.pump();

      expect(find.text('Aufgabe 1 von 14'), findsOneWidget);
      expect(find.textContaining('Teil 1/'), findsNothing);
    });

    testWidgets('startet mit einem Briefing statt sofort', (tester) async {
      await pumpApp(tester);
      await openSimulation(tester);

      expect(find.text('Teil 1 von 5'), findsOneWidget);
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
      // Teil 1 der Gesamtsimulation: 20 Aufgaben in 15 Minuten.
      expect(find.text('15 Minuten'), findsOneWidget);
      expect(find.text('45 Sekunden'), findsOneWidget);
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

      expect(find.byType(FeedbackSheet), findsNothing);
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

  group('Einstellungen', () {
    /// Einstellungen → Prüfungen → die aktive Prüfung bearbeiten.
    Future<void> openExamDate(WidgetTester tester) async {
      await openSetting(tester, 'Prüfungen und Termine');
      await tester.tap(find.text('Bearbeiten'));
      await tester.pumpAndSettle();
    }

    /// Einstellungen → Kontozeile.
    Future<void> openAccount(WidgetTester tester) async {
      await openSettings(tester);
      await tester.tap(find.text('Ohne Anmeldung'));
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

    testWidgets('der gesetzte Testtermin erscheint im Hauptmenue',
        (tester) async {
      await pumpApp(tester);
      await openExamDate(tester);

      expect(find.text('Termin wählen'), findsOneWidget);

      await tester.tap(find.text('Termin wählen'));
      await tester.pumpAndSettle();
      // Der Kalender steht auf "in 30 Tagen" – bestaetigen genuegt.
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tapItem(tester, find.text('Speichern'));

      // In der Uebersicht steht der Termin als Satz ...
      expect(find.text('Noch 30 Tage'), findsOneWidget);

      await goBack(tester);
      await tester.tap(find.text('Hauptmenü'));
      await tester.pumpAndSettle();

      // ... im Band des Hauptmenues dagegen getrennt: die Zahl gross, die
      // Einheit klein darunter.
      expect(find.text('30'), findsOneWidget);
      expect(find.text('TAGE'), findsOneWidget);
      expect(find.text('bis zum Testtermin'), findsOneWidget);
    });
  });

  group('Erinnerungen', () {
    late InMemoryReminderService reminders;

    setUp(() => reminders = InMemoryReminderService());

    /// Startet die App mit einem Erinnerungsdienst, der ohne
    /// Platform-Channels auskommt, und oeffnet die Erinnerungen.
    Future<void> openReminders(WidgetTester tester, {bool fresh = true}) async {
      if (fresh) {
        await pumpApp(
          tester,
          overrides: [reminderServiceProvider.overrideWithValue(reminders)],
        );
      }
      await openSetting(tester, 'Erinnerungen');
    }

    /// Testtermin auf „in 30 Tagen" setzen – von den Erinnerungen aus ueber
    /// die Einstellungen und wieder zurueck.
    Future<void> setExamDate(WidgetTester tester) async {
      await goBack(tester);
      await tester.tap(find.text('Prüfungen und Termine'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bearbeiten'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Termin wählen'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tapItem(tester, find.text('Speichern'));
      await goBack(tester);
      await tester.tap(find.text('Erinnerungen'));
      await tester.pumpAndSettle();
    }

    testWidgets('sind zunächst aus und zeigen keine Details', (tester) async {
      await openReminders(tester);

      expect(find.text('Ans Üben erinnern'), findsOneWidget);
      expect(find.text('Wann vorher?'), findsNothing);
      expect(reminders.scheduled, isEmpty);
    });

    testWidgets('planen nach dem Einschalten die Erinnerungen',
        (tester) async {
      await openReminders(tester);
      await setExamDate(tester);

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(reminders.permissionRequested, isTrue);
      expect(reminders.scheduled.map((entry) => entry.leadDays), [7, 1]);
      // Die Oberfläche zeigt dieselben Zeitpunkte an.
      expect(find.textContaining('7 Tage vorher'), findsOneWidget);
      expect(find.textContaining('1 Tag vorher'), findsOneWidget);
    });

    testWidgets('erklären ohne Termin, dass noch nichts geplant ist',
        (tester) async {
      await openReminders(tester);

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Sobald ein Testtermin hinterlegt ist'),
        findsOneWidget,
      );
      expect(reminders.scheduled, isEmpty);
    });

    testWidgets('eine weitere Vorlaufzeit wird sofort übernommen',
        (tester) async {
      await openReminders(tester);
      await setExamDate(tester);
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilterChip, '3 Tage'));
      await tester.pumpAndSettle();

      expect(reminders.scheduled.map((entry) => entry.leadDays), [7, 3, 1]);
    });

    testWidgets('bleiben aus, wenn die Berechtigung fehlt', (tester) async {
      reminders.grantPermission = false;
      await openReminders(tester);
      await setExamDate(tester);

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(find.textContaining('Ohne die Berechtigung'), findsOneWidget);
      expect(find.text('Wann vorher?'), findsNothing);
      expect(reminders.scheduled, isEmpty);
    });

    testWidgets('ein entfernter Termin nimmt die Erinnerungen zurück',
        (tester) async {
      await openReminders(tester);
      await setExamDate(tester);
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(reminders.scheduled, isNotEmpty);

      // Termin ueber die Pruefung wieder entfernen.
      await goBack(tester);
      await tester.tap(find.text('Prüfungen und Termine'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bearbeiten'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Entfernen'));
      await tester.pumpAndSettle();
      await tapItem(tester, find.text('Speichern'));
      await tester.pumpAndSettle();

      expect(reminders.scheduled, isEmpty);
    });
  });

  group('Fehler-Wiederholung', () {
    testWidgets('bleibt verborgen, solange nichts falsch war', (tester) async {
      await pumpApp(tester);

      expect(find.text('Deine Fehler wiederholen'), findsNothing);
    });

    testWidgets('erscheint nach einer falsch beantworteten Runde',
        (tester) async {
      await pumpApp(tester);
      await openPracticeSetup(tester);

      // Zahlenreihen sind Auswahlaufgaben – "A" ist meist falsch.
      await tapItem(tester, find.text('Zahlenreihen'));
      await tapItem(tester, find.text('10 Aufgaben'));
      await tapItem(tester, find.text('Übung starten'));

      for (var i = 0; i < 10; i++) {
        await tester.tap(find.text('A'));
        await tester.pumpAndSettle();
        await tester.tap(find.text(i == 9 ? 'Auswertung' : 'Weiter'));
        await tester.pumpAndSettle();
      }

      // Zurueck ueber die Auswertung bis zu den Kategorien: Dort steht der
      // Stand je Thema, und der hat sich jetzt geaendert.
      await tester.tap(find.text('Zum Menü'));
      await tester.pumpAndSettle();
      await goBack(tester);

      // Die Zeile „Zahlenreihen" traegt jetzt eine Quote statt „neu".
      final row = find.ancestor(
        of: find.text('Zahlenreihen'),
        matching: find.byType(Column),
      );
      expect(
        find.descendant(of: row.first, matching: find.textContaining('%')),
        findsWidgets,
      );
    });

    testWidgets('startet eine Runde aus den eigenen Fehlern', (tester) async {
      await pumpApp(tester);
      await openPracticeSetup(tester);

      await tapItem(tester, find.text('Zahlenreihen'));
      await tapItem(tester, find.text('10 Aufgaben'));
      await tapItem(tester, find.text('Übung starten'));

      for (var i = 0; i < 10; i++) {
        await tester.tap(find.text('A'));
        await tester.pumpAndSettle();
        await tester.tap(find.text(i == 9 ? 'Auswertung' : 'Weiter'));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text('Zum Menü'));
      await tester.pumpAndSettle();
      await goBack(tester);
      await goBack(tester);

      // Im Hauptmenue steht jetzt die Zeile mit den offenen Fehlern.
      await tester.tap(find.text('Deine Fehler wiederholen'));
      await tester.pumpAndSettle();

      // Bewusst ohne feste Aufgabenzahl: Wie viele Aufgaben anstehen, haengt
      // davon ab, wie viele der zufaellig angeordneten Optionen zufaellig
      // richtig waren. Der Prueferpunkt ist, dass die Runde ueberhaupt aus
      // dem Fehlerbestand startet.
      expect(find.textContaining('Aufgabe 1/'), findsOneWidget);
    });
  });

  group('Deutsche Beschriftungen', () {
    testWidgets('die Datumsauswahl ist auf Deutsch', (tester) async {
      await pumpApp(tester);
      await openSetting(tester, 'Prüfungen und Termine');
      await tester.tap(find.text('Bearbeiten'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Termin wählen'));
      await tester.pumpAndSettle();

      // Ohne flutter_localizations stuende hier "Cancel" statt "Abbrechen"
      // und "SELECT DATE" statt "Datum auswählen". ("OK" heisst in beiden
      // Sprachen OK und taugt deshalb nicht als Beleg.)
      expect(find.text('Abbrechen'), findsOneWidget);
      expect(find.text('Cancel'), findsNothing);
    });
  });

  group('Pro', () {
    late InMemoryPurchaseService store;

    setUp(() => store = InMemoryPurchaseService());
    tearDown(() => store.dispose());

    Future<void> openPro(WidgetTester tester) async {
      await pumpApp(
        tester,
        overrides: [purchaseServiceProvider.overrideWithValue(store)],
      );
      await openSettings(tester);
      await tester.tap(find.text('Pro freischalten'));
      await tester.pumpAndSettle();
    }

    testWidgets('ist aus den Einstellungen erreichbar', (tester) async {
      await openPro(tester);

      expect(find.text('Mehr Aufgaben, keine Werbung'), findsOneWidget);
    });

    testWidgets('nennt zuerst, was kostenlos bleibt', (tester) async {
      await openPro(tester);

      expect(
        find.textContaining('bleiben kostenlos'),
        findsOneWidget,
      );
      // Die Gegenueberstellung nennt echte Unterschiede – und zeigt in der
      // Free-Spalte, was auch ohne Pro geht.
      expect(find.text('Werbung'), findsOneWidget);
      expect(find.text('Testsimulationen'), findsOneWidget);
      expect(find.text('unbegrenzt'), findsNWidgets(2));
    });

    testWidgets('bietet alle drei Tarife ohne Vorauswahl an', (tester) async {
      await openPro(tester);

      expect(find.text('Einmalkauf'), findsOneWidget);
      expect(find.text('Monatlich'), findsOneWidget);
      expect(find.text('Jährlich'), findsOneWidget);
      // Kein Tarif ist hervorgehoben oder vorausgewaehlt.
      expect(find.textContaining('Beliebteste'), findsNothing);
      expect(find.textContaining('Empfohlen'), findsNothing);
    });

    testWidgets('benennt die Bedingungen des Abos', (tester) async {
      await openPro(tester);

      expect(find.textContaining('verlängern sich'), findsOneWidget);
      expect(find.textContaining('kündigst'), findsOneWidget);
      expect(
        find.text('Früheren Kauf wiederherstellen'),
        findsOneWidget,
      );
    });

    testWidgets('nach dem Kauf ist Pro aktiv und der Hinweis verschwindet',
        (tester) async {
      await openPro(tester);

      await tester.tap(find.text('Einmalkauf'));
      await tester.pumpAndSettle();

      expect(find.text('Pro ist aktiv'), findsOneWidget);

      await goBack(tester);

      // Die Zeile in den Einstellungen meldet den Zustand direkt.
      expect(find.text('Pro ist aktiv'), findsOneWidget);
    });

    testWidgets('die Schwierigkeitswahl ist erst mit Pro bedienbar',
        (tester) async {
      await pumpApp(
        tester,
        overrides: [purchaseServiceProvider.overrideWithValue(store)],
      );
      await openPracticeSetup(tester);

      await scrollTo(tester, find.text('Schwierigkeit'));
      expect(find.text('Schwierigkeit'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Schwer'), findsNothing);
      expect(find.text('Pro ansehen'), findsOneWidget);

      await tapItem(tester, find.text('Pro ansehen'));
      await tester.tap(find.text('Einmalkauf'));
      await tester.pumpAndSettle();
      await goBack(tester);

      expect(find.widgetWithText(ChoiceChip, 'Schwer'), findsOneWidget);
      expect(find.text('Pro ansehen'), findsNothing);
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
