import 'package:einstellungstest_trainer/models/reminder_settings.dart';
import 'package:einstellungstest_trainer/screens/account_screen.dart';
import 'package:einstellungstest_trainer/screens/pro_screen.dart';
import 'package:einstellungstest_trainer/services/ads/ad_config.dart';
import 'package:einstellungstest_trainer/services/ads/ad_controller.dart';
import 'package:einstellungstest_trainer/services/exam_date_controller.dart';
import 'package:einstellungstest_trainer/services/exam_plan_controller.dart';
import 'package:einstellungstest_trainer/services/notifications/reminder_controller.dart';
import 'package:einstellungstest_trainer/services/notifications/reminder_service.dart';
import 'package:einstellungstest_trainer/services/purchase/entitlement_controller.dart';
import 'package:einstellungstest_trainer/services/sync/sync_controller.dart';
import 'package:einstellungstest_trainer/models/user_profile.dart';
import 'package:einstellungstest_trainer/services/auth/auth_service.dart';
import 'package:einstellungstest_trainer/screens/exam_plans_screen.dart';
import 'package:einstellungstest_trainer/screens/onboarding_screen.dart';
import 'package:einstellungstest_trainer/services/appearance_controller.dart';
import 'package:einstellungstest_trainer/services/profile_controller.dart';
import 'package:einstellungstest_trainer/theme/app_theme.dart';
import 'package:einstellungstest_trainer/theme/design_tokens.dart';
import 'package:einstellungstest_trainer/widgets/section_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Testtermin, Erinnerungen und der Weg zum Konto.

/// Alles, was nicht Üben ist: Konto, Pro, Vorbereitung, App.
///
/// Flache Zeilen statt Karten. Jede Zeile trägt ihren aktuellen Wert rechts,
/// damit man nicht hineingehen muss, um zu sehen, wie etwas steht. Was
/// eingestellt wird, öffnet sich als eigener Bildschirm – so bleibt diese
/// Liste kurz genug, um sie zu überblicken.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key, this.embedded = false});

  /// Als Reiter eingebettet gibt es keinen Zurück-Pfeil.
  final bool embedded;

  static const String appVersion = '0.1.0';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokens = context.tokens;
    final user = ref.watch(authUserProvider).value;
    final profile = ref.watch(profileProvider);
    final examDate = ref.watch(examDateProvider);
    final examCount = ref.watch(examPlansProvider).plans.length;
    final reminders = ref.watch(reminderControllerProvider);
    final isPro = ref.watch(isProProvider);
    final mode = ref.watch(themeModeProvider);
    final side = Gap.screenPadding(MediaQuery.sizeOf(context).width);

    void open(Widget screen) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => screen),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Einstellungen'),
        automaticallyImplyLeading: !embedded,
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(side, Gap.sm, side, Gap.header),
          children: [
            _AccountRow(
              user: user,
              profile: profile,
              onTap: () => open(const AccountScreen()),
            ),
            const SizedBox(height: Gap.card),
            _ProRow(isPro: isPro, onTap: () => open(const ProScreen())),
            const SizedBox(height: Gap.section),
            const SectionTitle('Vorbereitung'),
            // Der Termin haengt an der Pruefung, nicht am Nutzer – deshalb
            // fuehrt auch der Weg dorthin ueber die Pruefungen.
            _Row(
              label: 'Prüfungen und Termine',
              value: examDate == null
                  ? (examCount == 1 ? 'ohne Termin' : '$examCount Prüfungen')
                  : examDate.describe(DateTime.now()),
              onTap: () => open(const ExamPlansScreen()),
            ),
            _Row(
              label: 'Tagesziel',
              value: '${profile.dailyGoal} Aufgaben',
              onTap: () => _pickGoal(context, ref, profile.dailyGoal),
            ),
            _Row(
              label: 'Erinnerungen',
              value: reminders.enabled ? 'an · ${reminders.timeLabel}' : 'aus',
              onTap: () => open(
                const _DetailScreen(
                  title: 'Erinnerungen',
                  child: _ReminderCard(),
                ),
              ),
              last: true,
            ),
            const SizedBox(height: Gap.section),
            const SectionTitle('App'),
            _Row(
              label: 'Darstellung',
              value: AppearanceController.label(mode),
              onTap: () => _pickTheme(context, ref, mode),
            ),
            _Row(
              label: 'Einführung erneut ansehen',
              value: '',
              onTap: () => open(const OnboardingScreen(replayOnly: true)),
            ),
            _Row(
              label: 'Datenschutz und Werbung',
              value: '',
              onTap: () => open(
                const _DetailScreen(
                  title: 'Datenschutz',
                  child: _AdPrivacySection(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Gap.sm,
                vertical: Gap.card,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Version', style: theme.textTheme.bodyLarge),
                  ),
                  Text(appVersion, style: theme.textTheme.labelSmall),
                ],
              ),
            ),
            const SizedBox(height: Gap.sm),
            Text(
              'Dein Fortschritt liegt auf diesem Gerät. Erst mit einer '
              'Anmeldung wird er zusätzlich in der Cloud gesichert.',
              style: theme.textTheme.labelSmall?.copyWith(color: tokens.ink
                  .withValues(alpha: 0.45)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickGoal(
    BuildContext context,
    WidgetRef ref,
    int current,
  ) async {
    final picked = await showModalBottomSheet<int>(
      context: context,
      builder: (sheetContext) => _ChoiceSheet<int>(
        title: 'Tagesziel',
        subtitle: 'Wie viele Aufgaben willst du dir am Tag vornehmen?',
        options: [
          for (final goal in UserProfile.goalChoices)
            (value: goal, label: '$goal Aufgaben'),
        ],
        current: current,
      ),
    );

    if (picked != null) {
      await ref.read(profileProvider.notifier).setDailyGoal(picked);
    }
  }

  Future<void> _pickTheme(
    BuildContext context,
    WidgetRef ref,
    ThemeMode current,
  ) async {
    final picked = await showModalBottomSheet<ThemeMode>(
      context: context,
      builder: (sheetContext) => _ChoiceSheet<ThemeMode>(
        title: 'Darstellung',
        subtitle: 'Gilt für die ganze App. Die Testsimulation bleibt in '
            'jedem Fall dunkel.',
        options: [
          for (final mode in ThemeMode.values)
            (value: mode, label: AppearanceController.label(mode)),
        ],
        current: current,
      ),
    );

    if (picked != null) {
      await ref.read(themeModeProvider.notifier).set(picked);
    }
  }
}

/// Eine Einstellungszeile: Name links, Zustand rechts, Trennlinie darunter.
class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    required this.onTap,
    this.last = false,
  });

  final String label;
  final String value;
  final VoidCallback onTap;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Gap.sm,
              vertical: Gap.card,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(label, style: theme.textTheme.bodyLarge),
                ),
                if (value.isNotEmpty)
                  Text(value, style: theme.textTheme.labelSmall),
                const SizedBox(width: Gap.sm),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: theme.colorScheme.outline,
                ),
              ],
            ),
          ),
        ),
        if (!last) Divider(height: 1, color: theme.colorScheme.outlineVariant),
      ],
    );
  }
}

/// Die Kontozeile mit Initialen.
class _AccountRow extends StatelessWidget {
  const _AccountRow({
    required this.user,
    required this.profile,
    required this.onTap,
  });

  final AuthUser? user;
  final UserProfile profile;
  final VoidCallback onTap;

  /// Höchstens zwei Buchstaben – aus dem Namen, sonst aus der Mailadresse.
  String get _initials {
    final source = profile.name ?? user?.displayName ?? '';
    final parts = source
        .trim()
        .split(RegExp(r'[\s@._-]+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) return '–';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.tokens;

    return Material(
      color: tokens.raised,
      borderRadius: Radii.cardRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: Radii.cardRadius,
        child: Container(
          padding: const EdgeInsets.all(Gap.card),
          decoration: BoxDecoration(
            borderRadius: Radii.cardRadius,
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: tokens.sunk,
                  borderRadius: Radii.tileRadius,
                ),
                alignment: Alignment.center,
                child: Text(
                  _initials,
                  style: NumText.metric.copyWith(
                    fontSize: 19,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: Gap.card),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name ?? user?.displayName ?? 'Ohne Anmeldung',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user == null
                          ? 'Fortschritt nur auf diesem Gerät'
                          : 'Fortschritt wird abgeglichen',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Text(
                user == null ? 'Anmelden' : 'Konto',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: Gap.xs),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: theme.colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Der Hinweis auf Pro – eine Zeile, kein Werbeblock.
class _ProRow extends StatelessWidget {
  const _ProRow({required this.isPro, required this.onTap});

  final bool isPro;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.tokens;
    final palette = tokens.language;

    return Material(
      color: isPro ? tokens.sunk : palette.soft,
      borderRadius: Radii.cardRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: Radii.cardRadius,
        child: Padding(
          padding: const EdgeInsets.all(Gap.card),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPro ? 'Pro ist aktiv' : 'Pro freischalten',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: isPro
                            ? theme.colorScheme.onSurface
                            : palette.deep,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isPro
                          ? 'Werbefrei, voller Aufgabenpool, Lösungswege.'
                          : 'Werbefrei üben, mehr Aufgaben, Lösungswege.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isPro
                            ? theme.colorScheme.onSurfaceVariant
                            : palette.deep.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: isPro ? theme.colorScheme.outline : palette.deep,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Rahmen für eine einzelne Einstellung, die mehr als eine Zeile braucht.
class _DetailScreen extends StatelessWidget {
  const _DetailScreen({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final side = Gap.screenPadding(MediaQuery.sizeOf(context).width);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(side, Gap.card, side, Gap.header),
          children: [child],
        ),
      ),
    );
  }
}

/// Auswahl aus wenigen Möglichkeiten, von unten eingeblendet.
class _ChoiceSheet<T> extends StatelessWidget {
  const _ChoiceSheet({
    required this.title,
    required this.subtitle,
    required this.options,
    required this.current,
  });

  final String title;
  final String subtitle;
  final List<({T value, String label})> options;
  final T current;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.tokens;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Gap.cardWide,
          Gap.cardWide,
          Gap.cardWide,
          Gap.card,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: theme.textTheme.headlineSmall),
            const SizedBox(height: Gap.xs),
            Text(subtitle, style: theme.textTheme.bodySmall),
            const SizedBox(height: Gap.card),
            for (final option in options)
              Padding(
                padding: const EdgeInsets.only(bottom: Gap.sm),
                child: Material(
                  color: option.value == current ? tokens.ink : tokens.sunk,
                  borderRadius: Radii.buttonRadius,
                  child: InkWell(
                    borderRadius: Radii.buttonRadius,
                    onTap: () => Navigator.of(context).pop(option.value),
                    child: Container(
                      height: Gap.control,
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              option.label,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: option.value == current
                                    ? tokens.onInk
                                    : theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          if (option.value == current)
                            Icon(
                              Icons.check_rounded,
                              size: 20,
                              color: tokens.onInk,
                            ),
                        ],
                      ),
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

/// Datum in deutscher Schreibweise.
String formatDate(DateTime value) {
  return '${value.day.toString().padLeft(2, '0')}.'
      '${value.month.toString().padLeft(2, '0')}.${value.year}';
}

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
        borderRadius: Radii.bandRadius,
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


/// Einstieg zu Pro – im Free-Tier ein Hinweis, mit Pro eine Bestätigung.
class _AdPrivacySection extends ConsumerWidget {
  const _AdPrivacySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final service = ref.watch(adServiceProvider);

    // Mit Pro gibt es keine Werbung und damit nichts einzustellen.
    if (ref.watch(isProProvider) || !service.isAvailable) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Werbung'),
        Text(
          'Die kostenlose Version zeigt Anzeigen. Deine Einwilligung dazu '
          'kannst du jederzeit ändern.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: Gap.card),
        OutlinedButton.icon(
          onPressed: () => service.showPrivacyOptions(),
          icon: const Icon(Icons.privacy_tip_outlined),
          label: const Text('Datenschutzeinstellungen für Werbung'),
        ),
        if (AdConfig.usesTestUnits) ...[
          const SizedBox(height: 8),
          Text(
            'Testbuild: Es werden Googles Test-Anzeigen ausgeliefert.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: 26),
      ],
    );
  }
}
