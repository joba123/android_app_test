import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'engine.dart';
import 'palette.dart';

class GamePainter extends CustomPainter {
  final World Function() world;
  final Palette palette;

  GamePainter({
    required this.world,
    required this.palette,
    required Listenable repaint,
  }) : super(repaint: repaint);

  static final Paint _ink = Paint()..color = Palette.ink;

  @override
  void paint(Canvas canvas, Size size) {
    final w = world();
    final scale = math.min(size.width / w.cols, size.height / w.rows);
    final ox = (size.width - w.cols * scale) / 2;
    final oy = (size.height - w.rows * scale) / 2;

    // Letterbox margins continue the walls; below the level stays open so
    // pits still read as bottomless.
    canvas.drawRect(Offset.zero & size, _ink);
    canvas.drawRect(
      Rect.fromLTRB(ox, oy, ox + w.cols * scale, size.height),
      Paint()..color = palette.bg,
    );

    canvas.save();
    canvas.translate(ox, oy);
    if (w.shake > 0) {
      final s = w.shake * scale * 0.5;
      canvas.translate(math.sin(w.time * 90) * s, math.cos(w.time * 77) * s);
    }
    canvas.scale(scale);

    // All solid tiles go into one path so anti-aliasing leaves no seams.
    final solids = Path();
    for (final e in w.entities) {
      if (e.active && e.kind == TileKind.solid) solids.addRect(e.rect);
    }
    canvas.drawPath(solids, _ink);

    for (final e in w.entities) {
      if (!e.active) {
        if (e.hint) _drawHint(canvas, e);
        continue;
      }
      switch (e.kind) {
        case TileKind.solid:
          break;
        case TileKind.crumble:
          _drawCrumble(canvas, e, w.time);
        case TileKind.spikeUp:
        case TileKind.spikeDown:
        case TileKind.spikeLeft:
        case TileKind.spikeRight:
          _drawSpikes(canvas, e);
        case TileKind.saw:
          _drawSaw(canvas, e);
        case TileKind.door:
        case TileKind.hangingDoor:
        case TileKind.fakeDoor:
          _drawDoor(canvas, e, w.status == WorldStatus.won && e.isDoor);
      }
    }

    if (w.status != WorldStatus.dying) _drawPlayer(canvas, w);

    for (final p in w.particles) {
      final paint = Paint()
        ..color = Palette.ink.withValues(alpha: p.life.clamp(0.0, 1.0));
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(p.x, p.y),
          width: p.size,
          height: p.size,
        ),
        paint,
      );
    }
    canvas.restore();

    if (w.flash > 0) {
      canvas.drawRect(
        Offset.zero & size,
        Paint()..color = Colors.white.withValues(alpha: w.flash * 0.35),
      );
    }
  }

  void _drawHint(Canvas canvas, Entity e) {
    final paint = Paint()
      ..color = Palette.ink.withValues(alpha: 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.05;
    canvas.drawRect(e.rect.deflate(0.1), paint);
  }

  void _drawCrumble(Canvas canvas, Entity e, double time) {
    var r = e.rect;
    if (e.crumbleTimer > 0 && !e.falling) {
      r = r.shift(Offset(math.sin(time * 70) * 0.05, 0));
    }
    canvas.drawRect(r.inflate(0.01), _ink);
    final crack = Paint()
      ..color = palette.dim.withValues(alpha: 0.6)
      ..strokeWidth = 0.05
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(r.left + 0.2, r.top + 0.15)
      ..lineTo(r.left + 0.45, r.top + 0.45)
      ..lineTo(r.left + 0.35, r.top + 0.75)
      ..moveTo(r.left + 0.45, r.top + 0.45)
      ..lineTo(r.left + 0.8, r.top + 0.55);
    canvas.drawPath(path, crack);
  }

  void _drawSpikes(Canvas canvas, Entity e) {
    final a = Curves.easeOutBack.transform(e.appear.clamp(0.0, 1.0));
    final len = 0.7 * a;
    final path = Path();
    final x = e.x, y = e.y;
    for (var i = 0; i < 2; i++) {
      final s = i * 0.5;
      switch (e.kind) {
        case TileKind.spikeUp:
          path
            ..moveTo(x + s, y + 1)
            ..lineTo(x + s + 0.25, y + 1 - len)
            ..lineTo(x + s + 0.5, y + 1);
        case TileKind.spikeDown:
          path
            ..moveTo(x + s, y)
            ..lineTo(x + s + 0.25, y + len)
            ..lineTo(x + s + 0.5, y);
        case TileKind.spikeLeft:
          path
            ..moveTo(x + 1, y + s)
            ..lineTo(x + 1 - len, y + s + 0.25)
            ..lineTo(x + 1, y + s + 0.5);
        default:
          path
            ..moveTo(x, y + s)
            ..lineTo(x + len, y + s + 0.25)
            ..lineTo(x, y + s + 0.5);
      }
      path.close();
    }
    canvas.drawPath(path, _ink);
  }

  void _drawSaw(Canvas canvas, Entity e) {
    final c = Offset(e.x + e.w / 2, e.y + e.h / 2);
    final r = 0.48 * e.appear.clamp(0.0, 1.0);
    const teeth = 10;
    final path = Path();
    for (var i = 0; i < teeth * 2; i++) {
      final ang = e.spin + i * math.pi / teeth;
      final rr = i.isEven ? r : r * 0.74;
      final p = c + Offset(math.cos(ang) * rr, math.sin(ang) * rr);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(path, _ink);
    canvas.drawCircle(c, r * 0.22, Paint()..color = palette.bg);
  }

  void _drawDoor(Canvas canvas, Entity e, bool open) {
    final r = e.rect;
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        r,
        topLeft: const Radius.circular(0.3),
        topRight: const Radius.circular(0.3),
      ),
      _ink,
    );
    final inner = r.deflate(0.12);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        inner,
        topLeft: const Radius.circular(0.22),
        topRight: const Radius.circular(0.22),
      ),
      Paint()..color = open ? Palette.ink : palette.light,
    );
    if (!open) {
      canvas.drawCircle(
        Offset(inner.right - 0.14, inner.center.dy + 0.1),
        0.06,
        _ink,
      );
    }
  }

  void _drawPlayer(Canvas canvas, World w) {
    final p = w.player;
    var scale = 1.0;
    if (w.status == WorldStatus.won) {
      scale = (1 - w.statusTime * 2).clamp(0.0, 1.0);
      if (scale == 0) return;
    }
    canvas.save();
    canvas.translate(p.x + Player.w / 2, p.y + Player.h / 2);
    canvas.scale(scale, scale * w.gravityDir);

    // Slight squash & stretch based on vertical speed.
    final stretch = (p.vy.abs() / Physics.maxFall).clamp(0.0, 1.0) * 0.12;
    canvas.scale(1 - stretch, 1 + stretch);
    drawImp(
      canvas,
      facing: p.facing,
      step: p.grounded ? math.sin(p.walkAnim * math.pi) : 0,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant GamePainter old) => old.palette != palette;
}

/// Draws the player character centred on the origin, in tile units.
/// [step] in -1..1 animates the feet.
void drawImp(Canvas canvas, {int facing = 1, double step = 0}) {
  final ink = GamePainter._ink;
  const hw = Player.w / 2, hh = Player.h / 2;
  // Horns.
  final horns = Path()
    ..moveTo(-hw + 0.06, -hh + 0.12)
    ..lineTo(-hw + 0.02, -hh - 0.14)
    ..lineTo(-hw + 0.24, -hh + 0.04)
    ..close()
    ..moveTo(hw - 0.06, -hh + 0.12)
    ..lineTo(hw - 0.02, -hh - 0.14)
    ..lineTo(hw - 0.24, -hh + 0.04)
    ..close();
  canvas.drawPath(horns, ink);
  // Body.
  canvas.drawRRect(
    RRect.fromLTRBR(-hw, -hh, hw, hh - 0.1, const Radius.circular(0.16)),
    ink,
  );
  // Feet.
  final s = step * 0.07;
  canvas.drawRect(Rect.fromLTWH(-hw + 0.08 + s, hh - 0.14, 0.18, 0.14), ink);
  canvas.drawRect(Rect.fromLTWH(hw - 0.26 - s, hh - 0.14, 0.18, 0.14), ink);
  // Eyes.
  final look = facing * 0.07;
  final white = Paint()..color = Colors.white;
  for (final ex in [-0.13, 0.13]) {
    final c = Offset(ex + look, -0.1);
    canvas.drawCircle(c, 0.095, white);
    canvas.drawCircle(c + Offset(facing * 0.035, 0.01), 0.045, ink);
  }
}
