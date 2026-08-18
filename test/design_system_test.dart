import 'package:einstellungstest_trainer/app.dart';
import 'package:einstellungstest_trainer/models/training_module.dart';
import 'package:einstellungstest_trainer/widgets/answer_option_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ThemeData themeOf(Brightness brightness) => buildAppTheme(brightness);

  group('Tokens', () {
    test('hell und dunkel tragen dieselben Rollen', () {
      const light = ExamTokens.light;
      const dark = ExamTokens.dark;

      // Papier ist hell hell und dunkel dunkel – der Test haelt fest, dass
      // die Rollen nicht versehentlich vertauscht wurden.
      expect(light.paper.computeLuminance(),
          greaterThan(dark.paper.computeLuminance()));
      expect(light.ink.computeLuminance(),
          lessThan(dark.ink.computeLuminance()));
    });

    test('die drei Flaechenstufen sind unterscheidbar', () {
      for (final tokens in [ExamTokens.light, ExamTokens.dark]) {
        expect(tokens.paper, isNot(tokens.raised));
        expect(tokens.paper, isNot(tokens.sunk));
        expect(tokens.raised, isNot(tokens.sunk));
      }
    });

  });

  group('Theme', () {
    test('nutzt IBM Plex und nicht die Systemschrift', () {
      final theme = themeOf(Brightness.light);

      expect(theme.textTheme.bodyMedium?.fontFamily, AppFonts.sans);
      // Alles Gemessene steht in Mono.
      expect(theme.textTheme.displayLarge?.fontFamily, AppFonts.mono);
      expect(MonoText.timer.fontFamily, AppFonts.mono);
    });

    test('Zahlen nutzen Tabellenziffern', () {
      // Sonst zappeln sie beim Hochzaehlen.
      for (final style in [
        MonoText.timer,
        MonoText.sprintTimer,
        MonoText.display,
        MonoText.metric,
        MonoText.inline,
        MonoText.kicker,
      ]) {
        expect(
          style.fontFeatures,
          contains(const FontFeature.tabularFigures()),
        );
      }
    });

    test('die Hauptaktion ist die Tinte, nicht das Mathematik-Blau', () {
      // Blau soll eindeutig "Mathematik" heissen und nicht zugleich
      // Markenfarbe sein.
      final theme = themeOf(Brightness.light);

      expect(theme.colorScheme.primary, ExamTokens.light.ink);
      expect(theme.colorScheme.primary, isNot(ExamTokens.light.math));
    });

    test('Karten werfen keinen Schatten', () {
      // Nur schwebende Dinge tun das.
      for (final brightness in Brightness.values) {
        expect(themeOf(brightness).cardTheme.elevation, 0);
      }
    });

    test('die Hauptaktion ist mindestens 52 dp hoch', () {
      final style = themeOf(Brightness.light).filledButtonTheme.style;
      final size = style?.minimumSize?.resolve({});

      expect(size?.height, greaterThanOrEqualTo(52));
    });

    test('beide Modi bringen ihre Tokens mit', () {
      for (final brightness in Brightness.values) {
        expect(themeOf(brightness).extension<ExamTokens>(), isNotNull);
      }
    });
  });

  group('Modulfarben', () {
    testWidgets('folgen dem Hell-/Dunkelmodus', (tester) async {
      Future<Color> colorIn(Brightness brightness) async {
        late Color captured;
        await tester.pumpWidget(
          // Eigener Key je Modus: Ohne ihn wuerde Flutter den bestehenden
          // Elementbaum weiterverwenden und der zweite Aufruf den alten Wert
          // zurueckgeben.
          MaterialApp(
            key: ValueKey(brightness),
            theme: themeOf(brightness),
            home: Builder(
              builder: (context) {
                captured = TrainingModule.math.resolveColor(context);
                return const SizedBox();
              },
            ),
          ),
        );
        await tester.pump();
        return captured;
      }

      expect(await colorIn(Brightness.light), ExamTokens.light.math);
      expect(await colorIn(Brightness.dark), ExamTokens.dark.math);
    });
  });

  group('Antwortoption', () {
    Future<void> pumpOption(
      WidgetTester tester,
      AnswerOptionState state, {
      Brightness brightness = Brightness.light,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: themeOf(brightness),
          home: Scaffold(
            body: AnswerOptionTile(
              label: 'A',
              text: '390 Anträge',
              state: state,
            ),
          ),
        ),
      );
    }

    testWidgets('richtig traegt Glyphe und Wort, nicht nur Farbe',
        (tester) async {
      await pumpOption(tester, AnswerOptionState.correct);

      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.text('richtig'), findsOneWidget);
    });

    testWidgets('falsch traegt Glyphe und Wort, nicht nur Farbe',
        (tester) async {
      await pumpOption(tester, AnswerOptionState.wrong);

      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.text('deine Antwort'), findsOneWidget);
    });

    testWidgets('gewaehlt wird benannt', (tester) async {
      await pumpOption(tester, AnswerOptionState.selected);

      expect(find.text('gewählt'), findsOneWidget);
      // Ohne Aufdeckung keine Bewertungsglyphe.
      expect(find.byIcon(Icons.check), findsNothing);
      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('unbeantwortet zeigt den Buchstaben und sagt nichts',
        (tester) async {
      await pumpOption(tester, AnswerOptionState.idle);

      expect(find.text('A'), findsOneWidget);
      expect(find.text('richtig'), findsNothing);
      expect(find.text('gewählt'), findsNothing);
    });

    testWidgets('jeder Zustand ist auch im Dunkelmodus lesbar',
        (tester) async {
      for (final state in AnswerOptionState.values) {
        await pumpOption(tester, state, brightness: Brightness.dark);
        expect(tester.takeException(), isNull);
      }
    });

    test('jeder bewertete Zustand hat ein Wort', () {
      expect(AnswerOptionTile.wordFor(AnswerOptionState.correct), isNotNull);
      expect(AnswerOptionTile.wordFor(AnswerOptionState.wrong), isNotNull);
      expect(AnswerOptionTile.wordFor(AnswerOptionState.selected), isNotNull);
      // Neutrale Zustaende sagen nichts.
      expect(AnswerOptionTile.wordFor(AnswerOptionState.idle), isNull);
      expect(AnswerOptionTile.wordFor(AnswerOptionState.dimmed), isNull);
    });
  });

  group('Abstandsraster', () {
    test('der Seitenrand faellt auf schmalen Geraeten', () {
      expect(Gap.screenPadding(320), 16);
      expect(Gap.screenPadding(390), Gap.screen);
    });

    test('die Radien bilden eine Rangfolge', () {
      // Klein heisst "hier wird eingegeben", gross "hier wird gestartet".
      expect(Radii.input, lessThan(Radii.card));
      expect(Radii.card, lessThan(Radii.surface));
      expect(Radii.surface, lessThan(Radii.pill));
    });
  });
}
