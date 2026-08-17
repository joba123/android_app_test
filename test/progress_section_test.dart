import 'package:einstellungstest_trainer/app.dart';
import 'package:einstellungstest_trainer/models/progress_trend.dart';
import 'package:einstellungstest_trainer/models/session_mode.dart';
import 'package:einstellungstest_trainer/models/sub_category.dart';
import 'package:einstellungstest_trainer/models/training_module.dart';
import 'package:einstellungstest_trainer/models/training_session.dart';
import 'package:einstellungstest_trainer/services/providers.dart';
import 'package:einstellungstest_trainer/widgets/progress_section.dart';
import 'package:einstellungstest_trainer/widgets/trend_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TrainingSession sessionOn(
    DateTime finishedAt, {
    int total = 10,
    int correct = 7,
  }) {
    return TrainingSession(
      id: 'session_${finishedAt.millisecondsSinceEpoch}',
      mode: SessionMode.practice,
      module: TrainingModule.logic,
      startedAt: finishedAt.subtract(const Duration(minutes: 5)),
      finishedAt: finishedAt,
      results: [
        for (var index = 0; index < total; index++)
          QuestionResult(
            questionId: 'q$index',
            subCategory: SubCategory.numberSequences,
            answered: true,
            correct: index < correct,
            timeSpent: const Duration(seconds: 10),
          ),
      ],
    );
  }

  /// Baut nur den Abschnitt, mit vorgegebenem Verlauf.
  Future<void> pumpSection(
    WidgetTester tester, {
    required List<TrainingSession> sessions,
    Brightness brightness = Brightness.light,
    Size size = const Size(400, 900),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          sessionHistoryProvider.overrideWith(() => _FixedHistory(sessions)),
        ],
        child: MaterialApp(
          theme: buildAppTheme(brightness),
          home: const Scaffold(
            body: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: ProgressSection(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  final now = DateTime.now();

  group('Sichtbarkeit', () {
    testWidgets('bleibt ohne Verlauf verborgen', (tester) async {
      await pumpSection(tester, sessions: const []);

      expect(find.text('Entwicklung'), findsNothing);
      expect(find.byType(TrendChart), findsNothing);
    });

    testWidgets('bleibt nach einer einzelnen Runde verborgen', (tester) async {
      // Aus einer Runde eine Entwicklung abzuleiten waere erfunden.
      await pumpSection(tester, sessions: [sessionOn(now)]);

      expect(find.text('Entwicklung'), findsNothing);
    });

    testWidgets('erscheint ab zwei Wochen mit genug Aufgaben', (tester) async {
      await pumpSection(tester, sessions: [
        sessionOn(now),
        sessionOn(now.subtract(const Duration(days: 7))),
      ]);

      expect(find.text('Entwicklung'), findsOneWidget);
      expect(find.byType(TrendChart), findsOneWidget);
      expect(find.text('Trefferquote je Woche'), findsOneWidget);
    });
  });

  group('Vergleich', () {
    testWidgets('benennt eine Verbesserung im Klartext', (tester) async {
      await pumpSection(tester, sessions: [
        sessionOn(now.subtract(const Duration(days: 1)),
            total: 10, correct: 9),
        sessionOn(now.subtract(const Duration(days: 9)),
            total: 10, correct: 4),
      ]);

      expect(find.text('Du bist besser geworden'), findsOneWidget);
      expect(find.textContaining('Punkte mehr'), findsOneWidget);
      expect(find.textContaining('Letzte 7 Tage'), findsOneWidget);
    });

    testWidgets('beschönigt eine Verschlechterung nicht', (tester) async {
      await pumpSection(tester, sessions: [
        sessionOn(now.subtract(const Duration(days: 1)),
            total: 10, correct: 3),
        sessionOn(now.subtract(const Duration(days: 9)),
            total: 10, correct: 9),
      ]);

      expect(find.text('Zuletzt lief es schwächer'), findsOneWidget);
      expect(find.textContaining('Punkte weniger'), findsOneWidget);
    });

    testWidgets('bleibt beim Vergleich still, wenn er nicht möglich ist',
        (tester) async {
      // Beide Runden im selben Zeitfenster: kein Vorzeitraum zum Vergleichen.
      await pumpSection(tester, sessions: [
        sessionOn(now.subtract(const Duration(days: 1))),
        sessionOn(now.subtract(const Duration(days: 8))),
        sessionOn(now.subtract(const Duration(days: 2))),
      ]);

      // Das Diagramm steht trotzdem, nur der Vergleichssatz fehlt, falls
      // der Vorzeitraum leer ist.
      expect(find.byType(TrendChart), findsOneWidget);
    });
  });

  group('Serie', () {
    testWidgets('nennt aufeinanderfolgende Übungstage', (tester) async {
      await pumpSection(tester, sessions: [
        for (var back = 0; back < 3; back++)
          sessionOn(now.subtract(Duration(days: back))),
        sessionOn(now.subtract(const Duration(days: 8))),
      ]);

      expect(find.textContaining('3 Tage in Folge'), findsOneWidget);
    });

    testWidgets('erwähnt eine Serie von einem Tag nicht', (tester) async {
      await pumpSection(tester, sessions: [
        sessionOn(now),
        sessionOn(now.subtract(const Duration(days: 9))),
      ]);

      expect(find.textContaining('in Folge'), findsNothing);
    });
  });

  group('Darstellung', () {
    testWidgets('zeigt genau so viele Balken wie Wochen', (tester) async {
      await pumpSection(tester, sessions: [
        sessionOn(now),
        sessionOn(now.subtract(const Duration(days: 7))),
      ]);

      final chart = tester.widget<TrendChart>(find.byType(TrendChart));
      expect(chart.points, hasLength(ProgressTrend.weeksShown));
      // Die jüngste Woche ist beschriftet.
      expect(find.text('jetzt'), findsOneWidget);
    });

    testWidgets('beschriftet nur einen Balken mit einem Wert', (tester) async {
      // Eine Zahl ueber jedem Balken waere Rauschen.
      await pumpSection(tester, sessions: [
        sessionOn(now, total: 10, correct: 8),
        sessionOn(now.subtract(const Duration(days: 7)), total: 10, correct: 5),
        sessionOn(now.subtract(const Duration(days: 14)),
            total: 10, correct: 6),
      ]);

      // Nur im Diagramm zaehlen – der Vergleichssatz nennt ebenfalls Prozente.
      expect(
        find.descendant(
          of: find.byType(TrendChart),
          matching: find.textContaining('%'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(TrendChart),
          matching: find.text('80 %'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('läuft im Dunkelmodus nicht über', (tester) async {
      await pumpSection(
        tester,
        brightness: Brightness.dark,
        sessions: [
          sessionOn(now),
          sessionOn(now.subtract(const Duration(days: 7))),
        ],
      );

      expect(find.byType(TrendChart), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('läuft auf einem schmalen Display nicht über', (tester) async {
      // Acht Balken samt Datumsbeschriftung auf 320 Punkten Breite.
      await pumpSection(
        tester,
        size: const Size(320, 900),
        sessions: [
          sessionOn(now),
          sessionOn(now.subtract(const Duration(days: 7))),
          sessionOn(now.subtract(const Duration(days: 21))),
        ],
      );

      expect(find.byType(TrendChart), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

/// Verlauf mit fest vorgegebenen Sitzungen.
class _FixedHistory extends SessionHistoryController {
  _FixedHistory(this.sessions);

  final List<TrainingSession> sessions;

  @override
  List<TrainingSession> build() => sessions;
}
