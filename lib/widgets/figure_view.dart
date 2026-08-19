import 'dart:math' as math;

import 'package:einstellungstest_trainer/models/figure.dart';
import 'package:einstellungstest_trainer/theme/design_tokens.dart';
import 'package:flutter/material.dart';

/// Zeichnet eine [FigureCell].
///
/// Die Formen entstehen im Code statt als Bild: Sie bleiben damit in jeder
/// Auflösung scharf, folgen dem Hell-/Dunkelmodus und kosten kein Byte
/// Speicher in der App.
class FigureView extends StatelessWidget {
  const FigureView({
    super.key,
    required this.cell,
    this.size = 64,
    this.color,
  });

  final FigureCell cell;
  final double size;

  /// Ohne Angabe die Schriftfarbe – Formen sind Inhalt, keine Deko.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final drawColor = color ?? Theme.of(context).colorScheme.onSurface;

    return Semantics(
      label: cell.describe(),
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _FigurePainter(cell: cell, color: drawColor),
        ),
      ),
    );
  }
}

/// Eine Reihe von Figuren, wie sie eine Aufgabe zeigt – mit einem Fragezeichen
/// als letztem Feld, wenn die Reihe fortgesetzt werden soll.
class FigureRow extends StatelessWidget {
  const FigureRow({
    super.key,
    required this.cells,
    this.showQuestionMark = true,
    this.cellSize = 60,
  });

  final List<FigureCell> cells;

  /// Hängt ein leeres Feld mit „?" an – das gesuchte Glied der Reihe.
  final bool showQuestionMark;

  final double cellSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.tokens;

    Widget frame(Widget child) => Container(
          width: cellSize,
          height: cellSize,
          decoration: BoxDecoration(
            color: tokens.paper,
            borderRadius: Radii.tileRadius,
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          alignment: Alignment.center,
          child: child,
        );

    return Wrap(
      spacing: Gap.sm,
      runSpacing: Gap.sm,
      children: [
        for (final cell in cells)
          frame(FigureView(cell: cell, size: cellSize - 18)),
        if (showQuestionMark)
          frame(
            Text(
              '?',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
      ],
    );
  }
}

class _FigurePainter extends CustomPainter {
  _FigurePainter({required this.cell, required this.color});

  final FigureCell cell;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // Bis zu sechs Formen werden in ein bis zwei Reihen gelegt.
    final columns = cell.count <= 3 ? cell.count : (cell.count / 2).ceil();
    final rows = cell.count <= 3 ? 1 : 2;
    final cellWidth = size.width / columns;
    final cellHeight = size.height / rows;
    final radius = math.min(cellWidth, cellHeight) / 2 * 0.82;

    final paint = Paint()
      ..color = color
      ..style = cell.filled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = math.max(1.6, radius * 0.16)
      ..strokeJoin = StrokeJoin.round;

    for (var index = 0; index < cell.count; index++) {
      final row = index ~/ columns;
      final column = index % columns;
      final center = Offset(
        cellWidth * (column + 0.5),
        cellHeight * (row + 0.5),
      );

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(cell.quarterTurns * math.pi / 2);
      _drawShape(canvas, paint, radius);
      canvas.restore();
    }
  }

  void _drawShape(Canvas canvas, Paint paint, double radius) {
    switch (cell.shape) {
      case FigureShape.circle:
        canvas.drawCircle(Offset.zero, radius, paint);
      case FigureShape.square:
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: radius * 1.7,
            height: radius * 1.7,
          ),
          paint,
        );
      case FigureShape.triangle:
        canvas.drawPath(_polygon(3, radius, -math.pi / 2), paint);
      case FigureShape.diamond:
        canvas.drawPath(_polygon(4, radius, -math.pi / 2), paint);
      case FigureShape.pentagon:
        canvas.drawPath(_polygon(5, radius, -math.pi / 2), paint);
      case FigureShape.star:
        canvas.drawPath(_star(radius), paint);
    }
  }

  Path _polygon(int corners, double radius, double startAngle) {
    final path = Path();
    for (var index = 0; index < corners; index++) {
      final angle = startAngle + index * 2 * math.pi / corners;
      final point = Offset(radius * math.cos(angle), radius * math.sin(angle));
      index == 0 ? path.moveTo(point.dx, point.dy) : path.lineTo(point.dx, point.dy);
    }
    return path..close();
  }

  Path _star(double radius) {
    final path = Path();
    for (var index = 0; index < 10; index++) {
      final isOuter = index.isEven;
      final length = isOuter ? radius : radius * 0.45;
      final angle = -math.pi / 2 + index * math.pi / 5;
      final point = Offset(length * math.cos(angle), length * math.sin(angle));
      index == 0 ? path.moveTo(point.dx, point.dy) : path.lineTo(point.dx, point.dy);
    }
    return path..close();
  }

  @override
  bool shouldRepaint(_FigurePainter oldDelegate) =>
      oldDelegate.cell != cell || oldDelegate.color != color;
}
