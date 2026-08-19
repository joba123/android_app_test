import 'package:einstellungstest_trainer/models/question.dart';
import 'package:einstellungstest_trainer/theme/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Eingabefeld für Aufgaben mit freier Zahleneingabe.
///
/// Nimmt Komma und Punkt als Dezimaltrennzeichen an – geprüft wird die
/// Eingabe von [NumericResponse.tryParse]. Lässt sich daraus keine Zahl
/// lesen, meldet das Feld das zurück, statt die Aufgabe als falsch zu werten.
class NumericAnswerField extends StatefulWidget {
  const NumericAnswerField({
    super.key,
    required this.format,
    required this.onSubmit,
    this.autofocus = false,
  });

  final NumericInput format;

  /// Wird mit der Roheingabe aufgerufen und gibt zurück, ob sie verwertbar
  /// war. Bei `false` zeigt das Feld einen Hinweis an.
  final bool Function(String input) onSubmit;

  final bool autofocus;

  @override
  State<NumericAnswerField> createState() => _NumericAnswerFieldState();
}

class _NumericAnswerFieldState extends State<NumericAnswerField> {
  final TextEditingController _controller = TextEditingController();
  bool _showError = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final accepted = widget.onSubmit(_controller.text);
    if (accepted) {
      _controller.clear();
      setState(() => _showError = false);
    } else {
      setState(() => _showError = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                autofocus: widget.autofocus,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9,.\-]')),
                ],
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                onChanged: (_) {
                  if (_showError) setState(() => _showError = false);
                },
                decoration: InputDecoration(
                  hintText: 'Ergebnis eingeben',
                  suffixText: widget.format.unit,
                  errorText: _showError ? 'Bitte eine Zahl eingeben' : null,
                  border: const OutlineInputBorder(
                    borderRadius: Radii.bandRadius,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 58,
              child: FilledButton(
                onPressed: _submit,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(96, 58),
                  shape: const RoundedRectangleBorder(
                    borderRadius: Radii.bandRadius,
                  ),
                ),
                child: const Text('Prüfen'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Komma oder Punkt als Trennzeichen, Einheit muss nicht mit eingetippt '
          'werden.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Zeigt nach dem Aufdecken, was eingetippt wurde und was richtig gewesen
/// wäre.
class NumericAnswerSummary extends StatelessWidget {
  const NumericAnswerSummary({
    super.key,
    required this.format,
    required this.givenText,
    required this.isCorrect,
  });

  final NumericInput format;
  final String givenText;
  final bool isCorrect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isCorrect ? context.tokens.correct : theme.colorScheme.error;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: Radii.bandRadius,
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(isCorrect ? Icons.check_circle : Icons.cancel, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Deine Eingabe: $givenText',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (!isCorrect) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Richtig wäre: ${format.formattedValue}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
