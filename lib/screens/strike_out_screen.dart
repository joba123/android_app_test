import 'dart:async';
import 'dart:math';

import 'package:einstellungstest_trainer/models/strike_out_test.dart';
import 'package:einstellungstest_trainer/theme/app_theme.dart';
import 'package:einstellungstest_trainer/theme/design_tokens.dart';
import 'package:einstellungstest_trainer/widgets/section_title.dart';
import 'package:flutter/material.dart';

/// Der Durchstreichtest.
///
/// Aufgabe: In einer Fläche gleichartiger Zeichen jedes „d" mit genau zwei
/// Strichen antippen – und zwar zeilenweise von links nach rechts, unter
/// Zeitdruck. Das ist der Testteil, den man ohne Übung reihenweise verhaut,
/// weil er nichts abfragt, was man wissen könnte: Er misst, wie lange man
/// gleichmäßig genau bleibt.
///
/// Der Bildschirm steht bewusst neben dem übrigen Aufgabensystem: Hier gibt
/// es keine Frage und keine Antwortoptionen, sondern eine Fläche und eine Uhr.
class StrikeOutScreen extends StatefulWidget {
  const StrikeOutScreen({super.key, this.seed});

  /// Fester Startwert für Tests; ohne Angabe echter Zufall.
  final int? seed;

  /// Zeit für den ganzen Durchlauf.
  static const Duration duration = Duration(seconds: 100);

  /// Zeilen und Zeichen je Zeile. Zwanzig Zeichen passen auf ein Handy, ohne
  /// dass gescrollt werden muss – seitliches Scrollen würde die Messung
  /// verfälschen.
  static const int rows = 14;
  static const int symbolsPerRow = 20;

  @override
  State<StrikeOutScreen> createState() => _StrikeOutScreenState();
}

class _StrikeOutScreenState extends State<StrikeOutScreen> {
  late final List<StrikeRow> _rows;
  late final DateTime _startedAt;

  /// Angetippte Positionen als „Zeile:Spalte".
  final Set<String> _tapped = {};

  Timer? _timer;
  int _remaining = StrikeOutScreen.duration.inSeconds;

  /// Bis wohin gearbeitet wurde. Die Zeile gilt als begonnen, sobald in ihr
  /// getippt wurde; alles davor zählt als bearbeitet.
  int _lastTouchedRow = -1;
  int _lastTouchedColumn = -1;

  bool _finished = false;
  StrikeResult? _result;

  @override
  void initState() {
    super.initState();
    _rows = const StrikeOutBuilder().build(
      rows: StrikeOutScreen.rows,
      perRow: StrikeOutScreen.symbolsPerRow,
      random: Random(widget.seed),
    );
    _startedAt = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining <= 1) {
        _finish();
      } else {
        setState(() => _remaining -= 1);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggle(int row, int column) {
    if (_finished) return;

    setState(() {
      final key = '$row:$column';
      if (!_tapped.remove(key)) _tapped.add(key);

      // Der Fortschritt geht nur vorwärts: Wer zurückspringt, um zu
      // korrigieren, hat den Bereich davor trotzdem bearbeitet.
      if (row > _lastTouchedRow ||
          (row == _lastTouchedRow && column > _lastTouchedColumn)) {
        _lastTouchedRow = row;
        _lastTouchedColumn = column;
      }
    });
  }

  void _finish() {
    if (_finished) return;
    _timer?.cancel();

    var processed = 0;
    var hits = 0;
    var wrongTaps = 0;
    var missed = 0;

    for (var row = 0; row <= _lastTouchedRow; row++) {
      final isLastRow = row == _lastTouchedRow;
      final upTo =
          isLastRow ? _lastTouchedColumn + 1 : _rows[row].symbols.length;

      for (var column = 0; column < upTo; column++) {
        processed += 1;
        final symbol = _rows[row].symbols[column];
        final isTapped = _tapped.contains('$row:$column');

        if (symbol.isTarget && isTapped) hits += 1;
        if (symbol.isTarget && !isTapped) missed += 1;
        if (!symbol.isTarget && isTapped) wrongTaps += 1;
      }
    }

    setState(() {
      _finished = true;
      _result = StrikeResult(
        processed: processed,
        hits: hits,
        wrongTaps: wrongTaps,
        missed: missed,
        duration: DateTime.now().difference(_startedAt),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    if (_finished && result != null) {
      return _ResultView(result: result);
    }

    final theme = Theme.of(context);
    final tokens = context.tokens;
    final side = Gap.screenPadding(MediaQuery.sizeOf(context).width);
    final progress = 1 - _remaining / StrikeOutScreen.duration.inSeconds;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(side, Gap.sm, side, Gap.sm),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _finish,
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'Beenden',
                  ),
                  const SizedBox(width: Gap.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Jedes d mit zwei Strichen antippen',
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: Gap.sm),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(Radii.pill),
                          child: LinearProgressIndicator(
                            value: progress.clamp(0, 1),
                            minHeight: 4,
                            backgroundColor: tokens.sunk,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              tokens.concentration.accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: Gap.md),
                  Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _remaining <= 10 ? tokens.wrong : tokens.sunk,
                      borderRadius: BorderRadius.circular(Radii.pill),
                    ),
                    child: Text(
                      '$_remaining s',
                      style: NumText.inline.copyWith(
                        fontSize: 15,
                        color: _remaining <= 10
                            ? Colors.white
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: side),
              child: _Legend(),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.fromLTRB(side, Gap.md, side, Gap.section),
                itemCount: _rows.length,
                itemBuilder: (context, row) => _Row(
                  symbols: _rows[row].symbols,
                  isTapped: (column) => _tapped.contains('$row:$column'),
                  onTap: (column) => _toggle(row, column),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Zeigt, wonach gesucht wird – ohne das Beispiel ist die Aufgabe unlösbar.
class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.tokens;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Gap.card,
        vertical: Gap.md,
      ),
      decoration: BoxDecoration(
        color: tokens.concentration.soft,
        borderRadius: Radii.bandRadius,
      ),
      child: Row(
        children: [
          const _SymbolView(
            symbol: StrikeSymbol(letter: 'd', marks: 2),
            highlighted: true,
          ),
          const SizedBox(width: Gap.md),
          Expanded(
            child: Text(
              'Gesucht: d mit zwei Strichen – egal ob oben, unten oder '
              'verteilt.',
              style: theme.textTheme.labelMedium?.copyWith(
                color: tokens.concentration.deep,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.symbols,
    required this.isTapped,
    required this.onTap,
  });

  final List<StrikeSymbol> symbols;
  final bool Function(int column) isTapped;
  final void Function(int column) onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.sm),
      child: Row(
        children: [
          for (var column = 0; column < symbols.length; column++)
            Expanded(
              child: GestureDetector(
                onTap: () => onTap(column),
                behavior: HitTestBehavior.opaque,
                child: _SymbolView(
                  symbol: symbols[column],
                  highlighted: isTapped(column),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Ein Zeichen: Buchstabe mit Strichen darüber und darunter.
class _SymbolView extends StatelessWidget {
  const _SymbolView({required this.symbol, required this.highlighted});

  final StrikeSymbol symbol;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.tokens;
    // Die Striche verteilen sich von oben nach unten: einer oben, zwei
    // oben, dann kommt der untere dazu.
    final above = symbol.marks <= 2 ? symbol.marks : 2;
    final below = symbol.marks - above;

    final color = highlighted
        ? tokens.concentration.deep
        : theme.colorScheme.onSurface;

    Widget dash() => Container(
          width: 2,
          height: 7,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          color: color,
        );

    return Container(
      height: 52,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        color: highlighted ? tokens.concentration.soft : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 9,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [for (var index = 0; index < above; index++) dash()],
            ),
          ),
          Text(
            symbol.letter,
            style: TextStyle(
              fontFamily: AppFonts.display,
              fontFamilyFallback: AppFonts.displayFallback,
              fontSize: 20,
              height: 1.1,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          SizedBox(
            height: 9,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [for (var index = 0; index < below; index++) dash()],
            ),
          ),
        ],
      ),
    );
  }
}

/// Die Auswertung: Tempo, Fehler, Auslassungen.
class _ResultView extends StatelessWidget {
  const _ResultView({required this.result});

  final StrikeResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.tokens;
    final side = Gap.screenPadding(MediaQuery.sizeOf(context).width);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(side, Gap.card, side, Gap.header),
          children: [
            Text(
              '${result.score}',
              style: NumText.display.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: Gap.xs),
            Text(
              'Konzentrationsleistung: bearbeitete Zeichen minus Fehler.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: Gap.card),
            Text(result.verdict, style: theme.textTheme.titleMedium),
            const SizedBox(height: Gap.section),
            Container(
              padding: const EdgeInsets.all(Gap.card),
              decoration: BoxDecoration(
                color: tokens.sunk,
                borderRadius: Radii.bandRadius,
              ),
              child: Column(
                children: [
                  _Line(label: 'Bearbeitet', value: '${result.processed}'),
                  _Line(label: 'Richtig markiert', value: '${result.hits}'),
                  _Line(label: 'Falsch markiert', value: '${result.wrongTaps}'),
                  _Line(label: 'Übersehen', value: '${result.missed}'),
                  _Line(
                    label: 'Fehlerquote',
                    value: '${(result.errorRate * 100).round()} %',
                  ),
                  _Line(
                    label: 'Tempo',
                    value: '${result.pace.round()} Zeichen/min',
                    last: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: Gap.section),
            const SectionTitle('Was die Zahlen sagen'),
            Text(
              'Viele übersehene Ziele bei hohem Tempo heißt: zu schnell '
              'gelesen. Wenige Fehler bei wenig bearbeiteten Zeichen heißt: '
              'zu vorsichtig. Im echten Test zählt beides zusammen.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: Gap.section),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fertig'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value, this.last = false});

  final String label;
  final String value;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: Gap.md),
          child: Row(
            children: [
              Expanded(
                child: Text(label, style: theme.textTheme.bodyMedium),
              ),
              Text(
                value,
                style: NumText.inline.copyWith(
                  fontSize: 15,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        if (!last)
          Divider(height: 1, color: theme.colorScheme.outlineVariant),
      ],
    );
  }
}
