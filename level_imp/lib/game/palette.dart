import 'package:flutter/material.dart';

/// Flat two-tone look: one pastel background per level, dark ink for
/// everything solid.
class Palette {
  final Color bg;
  const Palette(this.bg);

  static const Color ink = Color(0xFF1E1A2B);

  Color get light => Color.lerp(bg, Colors.white, 0.45)!;
  Color get dim => Color.lerp(bg, ink, 0.12)!;
}

const List<Palette> palettes = [
  Palette(Color(0xFF8FD3BE)), // mint
  Palette(Color(0xFF8EC3EB)), // sky
  Palette(Color(0xFFC6B3E6)), // lilac
  Palette(Color(0xFFF2B07E)), // peach
  Palette(Color(0xFFE8D36A)), // lemon
  Palette(Color(0xFFEF8A80)), // coral
];

Palette paletteFor(int theme) => palettes[theme % palettes.length];
