import 'package:einstellungstest_trainer/models/exam_plan.dart';
import 'package:einstellungstest_trainer/models/field_of_study.dart';
import 'package:einstellungstest_trainer/services/exam_plan_controller.dart';
import 'package:einstellungstest_trainer/theme/design_tokens.dart';
import 'package:einstellungstest_trainer/widgets/field_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Prüfungen anlegen, umbenennen, terminieren, löschen.
///
/// Der Termin ist überall optional. Wer sich auf gut Glück vorbereitet, soll
/// nicht gezwungen sein, ein Datum zu erfinden.
class ExamPlansScreen extends ConsumerWidget {
  const ExamPlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final plans = ref.watch(examPlansProvider);
    final side = Gap.screenPadding(MediaQuery.sizeOf(context).width);

    return Scaffold(
      appBar: AppBar(title: const Text('Prüfungen')),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(side, Gap.card, side, Gap.header),
          children: [
            Text(
              'Für jede Prüfung führt die App einen eigenen Leitfaden. Die '
              'Fachrichtung bestimmt, welche Themen darin verlangt werden.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: Gap.section),
            for (final plan in plans.plans)
              Padding(
                padding: const EdgeInsets.only(bottom: Gap.md),
                child: _PlanCard(
                  plan: plan,
                  isActive: plan.id == plans.activeId,
                  canDelete: plans.plans.length > 1,
                ),
              ),
            const SizedBox(height: Gap.sm),
            FilledButton(
              onPressed: () => _edit(context, ref, null),
              child: const Text('Prüfung hinzufügen'),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    ExamPlan? existing,
  ) async {
    final result = await Navigator.of(context).push<_PlanDraft>(
      MaterialPageRoute<_PlanDraft>(
        builder: (_) => _PlanEditor(plan: existing),
      ),
    );
    if (result == null) return;

    final controller = ref.read(examPlansProvider.notifier);
    if (existing == null) {
      await controller.add(
        title: result.title,
        field: result.field,
        date: result.date,
      );
    } else {
      await controller.update(
        existing.id,
        title: result.title,
        field: result.field,
        date: result.date,
        clearDate: result.date == null,
      );
    }
  }
}

class _PlanCard extends ConsumerWidget {
  const _PlanCard({
    required this.plan,
    required this.isActive,
    required this.canDelete,
  });

  final ExamPlan plan;
  final bool isActive;
  final bool canDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokens = context.tokens;
    final days = plan.daysUntil(DateTime.now());

    return Container(
      padding: const EdgeInsets.all(Gap.card),
      decoration: BoxDecoration(
        color: tokens.raised,
        borderRadius: Radii.cardRadius,
        border: Border.all(
          color: isActive
              ? theme.colorScheme.onSurface
              : theme.colorScheme.outlineVariant,
          width: isActive ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(plan.title, style: theme.textTheme.titleLarge),
                    const SizedBox(height: 2),
                    Text(
                      plan.field.label,
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
              if (isActive)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: tokens.ink,
                    borderRadius: BorderRadius.circular(Radii.pill),
                  ),
                  child: Text(
                    'aktiv',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: tokens.onInk,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: Gap.md),
          Text(
            days == null
                ? 'Kein Termin hinterlegt'
                : days >= 0
                    ? 'Noch $days ${days == 1 ? 'Tag' : 'Tage'}'
                    : 'Termin liegt zurück',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: Gap.card),
          Row(
            children: [
              if (!isActive) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        ref.read(examPlansProvider.notifier).select(plan.id),
                    child: const Text('Auswählen'),
                  ),
                ),
                const SizedBox(width: Gap.md),
              ],
              Expanded(
                child: OutlinedButton(
                  onPressed: () => ExamPlansScreen._edit(context, ref, plan),
                  child: const Text('Bearbeiten'),
                ),
              ),
              if (canDelete) ...[
                const SizedBox(width: Gap.sm),
                IconButton(
                  tooltip: 'Prüfung entfernen',
                  onPressed: () => _confirmDelete(context, ref),
                  icon: Icon(Icons.delete_outline, color: tokens.wrong),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('„${plan.title}" entfernen?'),
        content: const Text(
          'Der Leitfaden dieser Prüfung verschwindet. Dein Fortschritt in den '
          'Themen bleibt erhalten – er gehört zu dir, nicht zur Prüfung.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Entfernen'),
          ),
        ],
      ),
    );

    if (shouldDelete ?? false) {
      await ref.read(examPlansProvider.notifier).remove(plan.id);
    }
  }
}

/// Was der Editor zurückgibt.
class _PlanDraft {
  const _PlanDraft({required this.title, required this.field, this.date});

  final String title;
  final FieldOfStudy field;
  final DateTime? date;
}

class _PlanEditor extends StatefulWidget {
  const _PlanEditor({this.plan});

  final ExamPlan? plan;

  @override
  State<_PlanEditor> createState() => _PlanEditorState();
}

class _PlanEditorState extends State<_PlanEditor> {
  late final TextEditingController _title =
      TextEditingController(text: widget.plan?.title ?? '');
  late FieldOfStudy _field = widget.plan?.field ?? FieldOfStudy.general;
  late DateTime? _date = widget.plan?.date;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 3)),
      helpText: 'Prüfungstermin wählen',
    );

    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final side = Gap.screenPadding(MediaQuery.sizeOf(context).width);
    final date = _date;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.plan == null ? 'Neue Prüfung' : 'Prüfung'),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(side, Gap.card, side, Gap.header),
          children: [
            TextField(
              controller: _title,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'z. B. Polizei Niedersachsen',
              ),
            ),
            const SizedBox(height: Gap.section),
            Text('Fachrichtung', style: theme.textTheme.titleLarge),
            const SizedBox(height: Gap.sm),
            Text(
              'Sie bestimmt, welche Themen der Leitfaden verlangt.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: Gap.card),
            FieldPicker(
              selected: _field,
              onSelect: (field) => setState(() => _field = field),
            ),
            const SizedBox(height: Gap.section),
            Text('Termin', style: theme.textTheme.titleLarge),
            const SizedBox(height: Gap.sm),
            Text(
              'Optional. Ohne Termin zählt die App nur dein Tagesziel mit.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: Gap.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _pickDate,
                    child: Text(
                      date == null
                          ? 'Termin wählen'
                          : '${date.day.toString().padLeft(2, '0')}.'
                              '${date.month.toString().padLeft(2, '0')}.'
                              '${date.year}',
                    ),
                  ),
                ),
                if (date != null) ...[
                  const SizedBox(width: Gap.sm),
                  TextButton(
                    onPressed: () => setState(() => _date = null),
                    child: const Text('Entfernen'),
                  ),
                ],
              ],
            ),
            const SizedBox(height: Gap.header),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(
                _PlanDraft(
                  title: _title.text.trim().isEmpty
                      ? _field.label
                      : _title.text.trim(),
                  field: _field,
                  date: _date,
                ),
              ),
              child: const Text('Speichern'),
            ),
          ],
        ),
      ),
    );
  }
}
