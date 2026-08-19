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

    test('die Flaechenstufen sind unterscheidbar', () {
      for (final tokens in [ExamTokens.light, ExamTokens.dark]) {
        expect(tokens.paper, isNot(tokens.raised));
        expect(tokens.paper, isNot(tokens.sunk));
        expect(tokens.raised, isNot(tokens.sunk));
        // Das Band ist eine Stufe kraeftiger als die eingelassene Flaeche.
        expect(tokens.band, isNot(tokens.sunk));
      }
    });

    test('jeder Bereich bringt drei Abstufungen mit', () {
      for (final tokens in [ExamTokens.light, ExamTokens.dark]) {
        for (final palette in [tokens.math, tokens.logic, tokens.language]) {
          expect(palette.accent, isNot(palette.soft));
          expect(palette.accent, isNot(palette.deep));
          // Der zarte Untergrund und die Schrift darauf muessen weit
          // auseinanderliegen – in welche Richtung, entscheidet der Modus.
          expect(
            (palette.soft.computeLuminance() -
                    palette.deep.computeLuminance())
                .abs(),
            greaterThan(0.3),
          );
        }
      }
    });

    test('die drei Bereichsfarben sind im Hellmodus klar getrennt', () {
      const tokens = ExamTokens.light;

      // Grün und Orange liegen unter Deuteranopie dicht beieinander; die App
      // nennt deshalb ueberall den Bereichsnamen neben der Farbe. Dass die
      // drei Werte ueberhaupt verschieden sind, gehoert trotzdem geprueft.
      expect(tokens.math.accent, isNot(tokens.logic.accent));
      expect(tokens.logic.accent, isNot(tokens.language.accent));
      expect(tokens.math.accent, isNot(tokens.language.accent));
    });
  });

  group('Theme', () {
    test('nutzt die gebuendelten Schriften und nicht die Systemschrift', () {
      final theme = themeOf(Brightness.light);

      // Prosa in Manrope, alles Grosse und Gezaehlte in Space Grotesk.
      expect(theme.textTheme.bodyMedium?.fontFamily, AppFonts.sans);
      expect(theme.textTheme.displayLarge?.fontFamily, AppFonts.display);
      expect(theme.textTheme.headlineMedium?.fontFamily, AppFonts.display);
      expect(NumText.timer.fontFamily, AppFonts.display);
    });

    test('Zahlen nutzen Tabellenziffern', () {
      // Sonst zappeln sie beim Hochzaehlen.
      for (final style in [
        NumText.timer,
        NumText.display,
        NumText.metric,
        NumText.band,
        NumText.inline,
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
      expect(theme.colorScheme.primary, isNot(ExamTokens.light.math.accent));
    });

    test('Karten werfen keinen Schatten', () {
      // Nur schwebende Dinge tun das.
      for (final brightness in Brightness.values) {
        expect(themeOf(brightness).cardTheme.elevation, 0);
      }
    });

    test('die Hauptaktion ist 56 dp hoch', () {
      final style = themeOf(Brightness.light).filledButtonTheme.style;
      final size = style?.minimumSize?.resolve({});

      expect(size?.height, Gap.control);
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

      expect(await colorIn(Brightness.light), ExamTokens.light.math.accent);
      expect(await colorIn(Brightness.dark), ExamTokens.dark.math.accent);
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

    testWidgets('richtig traegt eine Glyphe, nicht nur Farbe', (tester) async {
      await pumpOption(tester, AnswerOptionState.correct);

      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('falsch traegt eine Glyphe, nicht nur Farbe', (tester) async {
      await pumpOption(tester, AnswerOptionState.wrong);

      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    });

    testWidgets('gewaehlt zeigt noch keine Bewertung', (tester) async {
      await pumpOption(tester, AnswerOptionState.selected);

      expect(find.byIcon(Icons.check_rounded), findsNothing);
      expect(find.byIcon(Icons.close_rounded), findsNothing);
    });

    testWidgets('unbeantwortet zeigt den Buchstaben und sagt nichts',
        (tester) async {
      await pumpOption(tester, AnswerOptionState.idle);

      expect(find.text('A'), findsOneWidget);
    });

    testWidgets('der Zustand steht auch fuer Vorlesehilfen bereit',
        (tester) async {
      // Sichtbar traegt ihn die Flaeche, hoerbar dieser Zusatz.
      final handle = tester.ensureSemantics();
      await pumpOption(tester, AnswerOptionState.correct);

      expect(find.bySemanticsLabel('A. 390 Anträge, richtig'), findsOneWidget);
      handle.dispose();
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
      expect(Gap.screenPadding(320), 12);
      expect(Gap.screenPadding(390), Gap.card);
    });

    test('die Radien bilden eine Rangfolge', () {
      // Klein heisst "hier wird eingegeben", gross "hier liegt eine Karte".
      expect(Radii.input, lessThan(Radii.tile));
      expect(Radii.tile, lessThan(Radii.band));
      expect(Radii.band, lessThan(Radii.card));
      expect(Radii.card, lessThan(Radii.pill));
    });
  });
}
