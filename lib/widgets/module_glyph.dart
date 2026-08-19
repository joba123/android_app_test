import 'dart:math' as math;

import 'package:einstellungstest_trainer/models/training_module.dart';
import 'package:einstellungstest_trainer/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Die Kachel, die für einen Bereich steht.
///
/// Ein Zeichen auf zartem Untergrund in der Bereichsfarbe: „×" für
/// Mathematik, eine Raute für Logik, „Aa" für Sprache. Die Raute führt keine
/// der beiden Schriften, sie wird deshalb gezeichnet – ein gedrehtes Quadrat
/// mit Kontur.
class ModuleGlyph extends StatelessWidget {
  const ModuleGlyph({super.key, required this.module, this.size = 52});

  final TrainingModule module;
  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = module.palette(context);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: palette.soft,
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      alignment: Alignment.center,
      child: module.glyph.isEmpty
          ? Transform.rotate(
              angle: math.pi / 4,
              child: Container(
                width: size * 0.34,
                height: size * 0.34,
                decoration: BoxDecoration(
                  border: Border.all(color: palette.deep, width: size * 0.05),
                  borderRadius: BorderRadius.circular(size * 0.04),
                ),
              ),
            )
          : Text(
              module.glyph,
              style: TextStyle(
                fontFamily: AppFonts.display,
                fontFamilyFallback: AppFonts.displayFallback,
                fontSize: size * 0.46,
                height: 1,
                fontWeight: FontWeight.w700,
                color: palette.deep,
              ),
            ),
    );
  }
}
