import 'package:flutter/material.dart';

import '../game/palette.dart';

class InkButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  final bool big;
  final Color textColor;

  const InkButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.big = false,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Palette.ink,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: big ? 36 : 22,
            vertical: big ? 16 : 12,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, color: textColor, size: big ? 26 : 20),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: big ? 22 : 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A touch button that reports press/release, supporting multi-touch.
class HoldButton extends StatefulWidget {
  final IconData icon;
  final ValueChanged<bool> onChanged;
  final double size;

  const HoldButton({
    super.key,
    required this.icon,
    required this.onChanged,
    this.size = 76,
  });

  @override
  State<HoldButton> createState() => _HoldButtonState();
}

class _HoldButtonState extends State<HoldButton> {
  final Set<int> _pointers = {};

  void _update() {
    setState(() {});
    widget.onChanged(_pointers.isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    final pressed = _pointers.isNotEmpty;
    return Listener(
      onPointerDown: (e) {
        _pointers.add(e.pointer);
        _update();
      },
      onPointerUp: (e) {
        _pointers.remove(e.pointer);
        _update();
      },
      onPointerCancel: (e) {
        _pointers.remove(e.pointer);
        _update();
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: pressed ? 0.3 : 0.12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        ),
        child: Icon(
          widget.icon,
          size: widget.size * 0.5,
          color: Colors.white.withValues(alpha: pressed ? 1 : 0.85),
        ),
      ),
    );
  }
}
