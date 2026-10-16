import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../game/levels.dart';
import '../game/painter.dart';
import '../game/palette.dart';
import '../progress.dart';
import 'game_screen.dart';
import 'level_select_screen.dart';
import 'widgets.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bob = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _bob.dispose();
    super.dispose();
  }

  Future<void> _open(Widget screen) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
    if (mounted) setState(() {}); // refresh progress
  }

  @override
  Widget build(BuildContext context) {
    final next = math.min(Progress.unlocked, levels.length) - 1;
    return Scaffold(
      backgroundColor: palettes[0].bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 70,
                  height: 70,
                  child: AnimatedBuilder(
                    animation: _bob,
                    builder: (context, _) =>
                        CustomPaint(painter: _ImpPainter(_bob.value)),
                  ),
                ),
                const Text(
                  'LEVEL IMP',
                  style: TextStyle(
                    color: Palette.ink,
                    fontSize: 54,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Ein total faires Spiel™',
                  style: TextStyle(
                    color: Palette.ink.withValues(alpha: 0.7),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 26),
                Wrap(
                  spacing: 14,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    InkButton(
                      label: next == 0
                          ? 'SPIELEN'
                          : 'WEITER · LEVEL ${next + 1}',
                      icon: Icons.play_arrow_rounded,
                      big: true,
                      onTap: () => _open(GameScreen(levelIndex: next)),
                    ),
                    InkButton(
                      label: 'LEVEL',
                      icon: Icons.grid_view_rounded,
                      onTap: () => _open(const LevelSelectScreen()),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  'Tode insgesamt: ${Progress.totalDeaths}',
                  style: const TextStyle(
                    color: Palette.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ImpPainter extends CustomPainter {
  final double t;
  _ImpPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.height / 1.3;
    final hop = math.max(0.0, math.sin(t * math.pi * 2)) * 0.25;
    canvas.translate(size.width / 2, size.height / 2 + s * (0.1 - hop));
    canvas.scale(s);
    drawImp(canvas, facing: t < 0.5 ? 1 : -1);
  }

  @override
  bool shouldRepaint(_ImpPainter old) => old.t != t;
}
