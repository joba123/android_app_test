import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../game/engine.dart';
import '../game/levels.dart';
import '../game/painter.dart';
import '../game/palette.dart';
import '../progress.dart';
import 'victory_screen.dart';
import 'widgets.dart';

const _taunts = [
  'Das war Absicht.',
  'Hast du das kommen sehen?',
  'Fast!',
  'Nochmal. Ganz fair.',
  'Die Tür lacht dich aus.',
  'Kein Troll. Ehrlich.',
  'Zufall. Bestimmt.',
  'Das Level mag dich.',
];

class GameScreen extends StatefulWidget {
  final int levelIndex;
  const GameScreen({super.key, required this.levelIndex});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late int _level = widget.levelIndex;
  late World _world = World(levels[_level]);
  late final Ticker _ticker = createTicker(_tick);
  final ValueNotifier<int> _frame = ValueNotifier(0);
  final _rng = math.Random();
  final FocusNode _focus = FocusNode();

  double _last = 0;
  double _acc = 0;
  int _deaths = 0;
  bool _paused = false;
  bool _deathHandled = false;
  bool _winHandled = false;
  String? _taunt;

  bool _touchLeft = false, _touchRight = false, _touchJump = false;
  bool _keyLeft = false, _keyRight = false, _keyJump = false;

  @override
  void initState() {
    super.initState();
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _frame.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _tick(Duration elapsed) {
    final now = elapsed.inMicroseconds / 1e6;
    final dt = math.min(now - _last, 0.1);
    _last = now;
    if (_paused) return;

    _world.input
      ..left = _touchLeft || _keyLeft
      ..right = _touchRight || _keyRight
      ..jump = _touchJump || _keyJump;

    _acc += dt;
    while (_acc >= Physics.stepDt) {
      _world.step();
      _acc -= Physics.stepDt;
    }

    if (_world.status == WorldStatus.dying) {
      if (!_deathHandled) {
        _deathHandled = true;
        HapticFeedback.mediumImpact();
      }
      if (_world.statusTime > 0.8) _restart(died: true);
    } else if (_world.status == WorldStatus.won &&
        !_winHandled &&
        _world.statusTime > 0.6) {
      _winHandled = true;
      _completeLevel();
    }
    _frame.value++;
  }

  void _restart({bool died = false}) {
    setState(() {
      if (died) {
        _deaths++;
        Progress.addDeath();
        _taunt = _taunts[_rng.nextInt(_taunts.length)];
      }
      _world = World(levels[_level]);
      _deathHandled = false;
      _winHandled = false;
    });
  }

  Future<void> _completeLevel() async {
    await Progress.completeLevel(_level + 1, _deaths);
    if (!mounted) return;
    if (_level + 1 >= levels.length) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const VictoryScreen()),
      );
      return;
    }
    setState(() {
      _level++;
      _deaths = 0;
      _taunt = null;
      _world = World(levels[_level]);
      _deathHandled = false;
      _winHandled = false;
    });
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    final keys = HardwareKeyboard.instance.logicalKeysPressed;
    _keyLeft =
        keys.contains(LogicalKeyboardKey.arrowLeft) ||
        keys.contains(LogicalKeyboardKey.keyA);
    _keyRight =
        keys.contains(LogicalKeyboardKey.arrowRight) ||
        keys.contains(LogicalKeyboardKey.keyD);
    _keyJump =
        keys.contains(LogicalKeyboardKey.space) ||
        keys.contains(LogicalKeyboardKey.arrowUp) ||
        keys.contains(LogicalKeyboardKey.keyW);
    if (event is KeyDownEvent &&
        (event.logicalKey == LogicalKeyboardKey.escape ||
            event.logicalKey == LogicalKeyboardKey.keyP)) {
      setState(() => _paused = !_paused);
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final def = levels[_level];
    final palette = paletteFor(def.theme);
    return Scaffold(
      backgroundColor: palette.bg,
      body: Focus(
        focusNode: _focus,
        autofocus: true,
        onKeyEvent: _onKey,
        child: Stack(
          children: [
            Positioned.fill(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: GamePainter(
                    world: () => _world,
                    palette: palette,
                    repaint: _frame,
                  ),
                ),
              ),
            ),
            SafeArea(child: _buildHud(palette)),
            SafeArea(child: _buildBanner(def)),
            SafeArea(child: _buildControls()),
            if (_paused) _buildPause(palette),
          ],
        ),
      ),
    );
  }

  /// Compact HUD that sits on the dark ceiling row of every level.
  Widget _buildHud(Palette palette) {
    final style = TextStyle(
      color: palette.light,
      fontWeight: FontWeight.w800,
      fontSize: 14,
      letterSpacing: 1,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => _paused = true),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 2, 10, 8),
              child: Icon(Icons.pause_rounded, color: palette.light, size: 22),
            ),
          ),
          Text('LEVEL ${_level + 1}', style: style),
          const Spacer(),
          Icon(
            Icons.sentiment_very_dissatisfied_rounded,
            color: palette.light,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text('$_deaths', style: style),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget _buildBanner(LevelDef def) {
    return ValueListenableBuilder<int>(
      valueListenable: _frame,
      builder: (context, _, _) {
        final t = _world.time;
        final firstTry = _deaths == 0;
        final showFor = firstTry ? 2.4 : 1.4;
        final opacity = (1 - (t - showFor + 0.4) / 0.4).clamp(0.0, 1.0);
        if (opacity <= 0) return const SizedBox.shrink();
        return Align(
          alignment: const Alignment(0, -0.55),
          child: Opacity(
            opacity: opacity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (firstTry) ...[
                  Text(
                    def.title,
                    style: const TextStyle(
                      color: Palette.ink,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    def.subtitle,
                    style: TextStyle(
                      color: Palette.ink.withValues(alpha: 0.7),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ] else
                  Text(
                    _taunt ?? '',
                    style: const TextStyle(
                      color: Palette.ink,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Touch buttons sized to fit inside the 3-tile floor strip, so they never
  /// cover the door or the player.
  Widget _buildControls() {
    final screen = MediaQuery.sizeOf(context);
    final tile = math.min(
      screen.width / _world.cols,
      screen.height / _world.rows,
    );
    final letterbox = (screen.height - tile * _world.rows) / 2;
    final moveSize = (tile * 2.3).clamp(48.0, 84.0);
    final jumpSize = (tile * 2.6).clamp(54.0, 92.0);
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, letterbox + tile * 0.25),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            HoldButton(
              icon: Icons.arrow_back_rounded,
              size: moveSize,
              onChanged: (v) => _touchLeft = v,
            ),
            const SizedBox(width: 14),
            HoldButton(
              icon: Icons.arrow_forward_rounded,
              size: moveSize,
              onChanged: (v) => _touchRight = v,
            ),
            const Spacer(),
            HoldButton(
              icon: Icons.arrow_upward_rounded,
              size: jumpSize,
              onChanged: (v) => _touchJump = v,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPause(Palette palette) {
    return Positioned.fill(
      child: Container(
        color: palette.bg.withValues(alpha: 0.85),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Pause',
                style: TextStyle(
                  color: Palette.ink,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  InkButton(
                    label: 'Weiter',
                    icon: Icons.play_arrow_rounded,
                    onTap: () => setState(() => _paused = false),
                  ),
                  InkButton(
                    label: 'Neustart',
                    icon: Icons.refresh_rounded,
                    onTap: () {
                      _paused = false;
                      _restart();
                    },
                  ),
                  InkButton(
                    label: 'Menü',
                    icon: Icons.home_rounded,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
