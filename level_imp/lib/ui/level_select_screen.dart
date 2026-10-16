import 'package:flutter/material.dart';

import '../game/levels.dart';
import '../game/palette.dart';
import '../progress.dart';
import 'game_screen.dart';

class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  Future<void> _play(int index) async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => GameScreen(levelIndex: index)));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: palettes[1].bg,
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Palette.ink,
                    size: 28,
                  ),
                ),
                const Text(
                  'Level wählen',
                  style: TextStyle(
                    color: Palette.ink,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: GridView.count(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(16),
                    crossAxisCount: 6,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    children: [
                      for (var i = 0; i < levels.length; i++) _tile(i),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(int i) {
    final unlocked = i < Progress.unlocked;
    final best = Progress.bestDeaths(i + 1);
    final palette = paletteFor(levels[i].theme);
    return Material(
      color: unlocked ? Palette.ink : Palette.ink.withValues(alpha: 0.25),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: unlocked ? () => _play(i) : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (unlocked)
              Text(
                '${i + 1}',
                style: TextStyle(
                  color: palette.bg,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              )
            else
              const Icon(Icons.lock_rounded, color: Colors.white70),
            if (best != null)
              Text(
                '☠ $best',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }
}
