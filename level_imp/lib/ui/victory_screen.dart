import 'package:flutter/material.dart';

import '../game/levels.dart';
import '../game/palette.dart';
import '../progress.dart';
import 'widgets.dart';

class VictoryScreen extends StatelessWidget {
  const VictoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: palettes[4].bg,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Geschafft!',
                style: TextStyle(
                  color: Palette.ink,
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Alle ${levels.length} Level überlebt.\n'
                'Tode insgesamt: ${Progress.totalDeaths}. Völlig fair, oder?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Palette.ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              InkButton(
                label: 'ZUM MENÜ',
                icon: Icons.home_rounded,
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
