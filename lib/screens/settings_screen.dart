import 'package:einstellungstest_trainer/models/exam_date.dart';
import 'package:einstellungstest_trainer/models/reminder_settings.dart';
import 'package:einstellungstest_trainer/screens/account_screen.dart';
import 'package:einstellungstest_trainer/services/exam_date_controller.dart';
import 'package:einstellungstest_trainer/services/notifications/reminder_controller.dart';
import 'package:einstellungstest_trainer/services/notifications/reminder_service.dart';
import 'package:einstellungstest_trainer/services/sync/sync_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Testtermin, Erinnerungen und der Weg zum Konto.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authUserProvider).value;

    return Scaffold(
      appBar: AppBar(title: const Text('Einstellungen')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: [
            const _SectionTitle(
              title: 'Testtermin',
              subtitle: 'Dein Termin steuert den Countdown auf der Startseite '
                  'und die Erinnerungen.',
            ),
            const SizedBox(height: 12),
            const ExamDateCard(),
            const SizedBox(height: 26),
            const _SectionTitle(
              title: 'Erinnerungen',
              subtitle: 'Kurze Hinweise vor dem Termin – damit das Üben nicht '
                  'in der Woche davor untergeht.',
            ),
            const SizedBox(height: 12),
            const _ReminderCard(),
            const SizedBox(height: 26),
            const _SectionTitle(
              title: 'Konto',
              subtitle: 'Anmeldung, Cloud-Abgleich und Datenschutz.',
            ),
            const SizedBox(height: 12),
            Material(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const AccountScreen()),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        user == null
                            ? Icons.phone_android
                            : Icons.cloud_done_outlined,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user == null ? 'Lokaler Modus' : 'Angemeldet',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              user == null
                                  ? 'Fortschritt nur auf diesem Gerät'
                                  : 'Fortschritt wird abgeglichen',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: theme.colorScheme.outline,
                      ),
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
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

/// Testtermin setzen, ändern, entfernen.
class ExamDateCard extends ConsumerWidget {
  const ExamDateCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final examDate = ref.watch(examDateProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (examDate == null)
            Text(
              'Noch kein Termin hinterlegt.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          else ...[
            Text(
              formatDate(examDate.date),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              [
                examDate.describe(DateTime.now()),
                if (examDate.label != null) examDate.label!,
              ].join(' · '),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _pick(context, ref, examDate),
                  child: Text(examDate == null ? 'Termin setzen' : 'Ändern'),
                ),
              ),
              if (examDate != null) ...[
                const SizedBox(width: 10),
                TextButton(
                  onPressed: () => ref.read(examDateProvider.notifier).clear(),
                  child: const Text('Entfernen'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pick(
    BuildContext context,
    WidgetRef ref,
    ExamDate? current,
  ) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current?.date ?? now.add(const Duration(days: 30)),
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 730)),
      helpText: 'Wann ist dein Einstellungstest?',
    );

    if (picked == null) return;
    await ref.read(examDateProvider.notifier).set(picked, label: current?.label);
  }
}

String formatDate(DateTime value) {
  return '${value.day.toString().padLeft(2, '0')}.'
      '${value.month.toString().padLeft(2, '0')}.${value.year}';
}

/// Schalter, Vorlaufzeiten, Uhrzeit – und was daraus tatsächlich geplant ist.
class _ReminderCard extends ConsumerWidget {
  const _ReminderCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(reminderControllerProvider);
    final service = ref.watch(reminderServiceProvider);
    final examDate = ref.watch(examDateProvider);
    final planned = ref.watch(plannedRemindersProvider);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Ans Üben erinnern'),
            subtitle: Text(
              service.isAvailable
                  ? 'Lokale Benachrichtigungen, nichts verlässt das Gerät.'
                  : 'Auf dieser Plattform nicht verfügbar.',
              style: theme.textTheme.bodySmall,
            ),
            value: settings.enabled,
            onChanged: service.isAvailable
                ? (value) => _toggle(context, ref, value)
                : null,
          ),
          if (settings.enabled) ...[
            const Divider(height: 24),
            Text(
              'Wann vorher?',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final days in ReminderSettings.selectableLeadDays)
                  FilterChip(
                    label: Text(days == 1 ? '1 Tag' : '$days Tage'),
                    selected: settings.leadDays.contains(days),
                    onSelected: (_) => ref
                        .read(reminderControllerProvider.notifier)
                        .toggleLead(days),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Uhrzeit: ${settings.timeLabel}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                TextButton(
                  onPressed: () => _pickTime(context, ref, settings),
                  child: const Text('Ändern'),
                ),
              ],
            ),
            const Divider(height: 24),
            if (examDate == null)
              Text(
                'Sobald ein Testtermin hinterlegt ist, werden die '
                'Erinnerungen geplant.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            else if (planned.isEmpty)
              Text(
                'Für diesen Termin liegt keine Erinnerung mehr in der '
                'Zukunft.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            else ...[
              Text(
                'Geplant',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              for (final reminder in planned)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Icon(
                        Icons.notifications_active_outlined,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${formatDate(reminder.when)} um '
                          '${_time(reminder.when)} · '
                          '${reminder.leadDays == 1 ? '1 Tag' : '${reminder.leadDays} Tage'} vorher',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ],
      ),
    );
  }

  String _time(DateTime value) {
    return '${value.hour.toString().padLeft(2, '0')}:'
        '${value.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _toggle(BuildContext context, WidgetRef ref, bool value) async {
    final controller = ref.read(reminderControllerProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);

    if (!value) {
      await controller.disable();
      return;
    }

    final outcome = await controller.enable();
    if (outcome == PermissionOutcome.granted) return;

    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            outcome == PermissionOutcome.denied
                ? 'Ohne die Berechtigung für Benachrichtigungen kann die App '
                    'nicht erinnern. Du kannst sie in den Systemeinstellungen '
                    'nachträglich erteilen.'
                : 'Benachrichtigungen sind auf dieser Plattform nicht '
                    'verfügbar.',
          ),
        ),
      );
  }

  Future<void> _pickTime(
    BuildContext context,
    WidgetRef ref,
    ReminderSettings settings,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: settings.hour, minute: settings.minute),
      helpText: 'Wann soll erinnert werden?',
    );

    if (picked == null) return;
    await ref
        .read(reminderControllerProvider.notifier)
        .setTime(hour: picked.hour, minute: picked.minute);
  }
}
