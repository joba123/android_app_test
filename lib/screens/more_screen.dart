import 'package:einstellungstest_trainer/screens/account_screen.dart';
import 'package:einstellungstest_trainer/screens/onboarding_screen.dart';
import 'package:einstellungstest_trainer/screens/pro_screen.dart';
import 'package:einstellungstest_trainer/screens/settings_screen.dart';
import 'package:einstellungstest_trainer/services/exam_date_controller.dart';
import 'package:einstellungstest_trainer/services/notifications/reminder_controller.dart';
import 'package:einstellungstest_trainer/services/purchase/entitlement_controller.dart';
import 'package:einstellungstest_trainer/services/sync/sync_controller.dart';
import 'package:einstellungstest_trainer/theme/design_tokens.dart';
import 'package:einstellungstest_trainer/widgets/section_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Alles, was nicht Üben ist.
///
/// Verwaltungskram wird flach: Listenzeilen auf Papier, keine Karten. Karten
/// bekommt nur, was Daten trägt oder eine Handlung auslöst — eine
/// Einstellung tut beides nicht.
class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final side = Gap.screenPadding(MediaQuery.sizeOf(context).width);
    final examDate = ref.watch(examDateProvider);
    final reminders = ref.watch(reminderControllerProvider);
    final isPro = ref.watch(isProProvider);
    final user = ref.watch(authUserProvider).value;

    void open(Widget screen) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => screen),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mehr')),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(side, Gap.sm, side, Gap.section),
          children: [
            const SectionTitle('Vorbereitung'),
            _Row(
              title: 'Prüfungstermin',
              value: examDate == null
                  ? 'nicht gesetzt'
                  : examDate.describe(DateTime.now()),
              onTap: () => open(const SettingsScreen()),
            ),
            _Row(
              title: 'Erinnerungen',
              value: reminders.enabled
                  ? 'an · ${reminders.timeLabel}'
                  : 'aus',
              onTap: () => open(const SettingsScreen()),
            ),
            const SizedBox(height: Gap.section),
            const SectionTitle('Konto'),
            _Row(
              title: 'Anmeldung und Abgleich',
              value: user == null ? 'lokaler Modus' : 'angemeldet',
              onTap: () => open(const AccountScreen()),
            ),
            _Row(
              title: 'Pro',
              value: isPro ? 'aktiv' : 'ansehen',
              onTap: () => open(const ProScreen()),
            ),
            const SizedBox(height: Gap.section),
            const SectionTitle('Hilfe'),
            _Row(
              title: 'So funktioniert die App',
              value: 'Einführung',
              onTap: () => open(const OnboardingScreen(replayOnly: true)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Eine Einstellungszeile: Name links, Zustand rechts, Trennlinie darunter.
///
/// Der Zustand steht direkt in der Zeile, damit man nicht erst hineingehen
/// muss, um zu sehen, wie etwas eingestellt ist.
class _Row extends StatelessWidget {
  const _Row({
    required this.title,
    required this.value,
    required this.onTap,
  });

  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Gap.card),
            child: Row(
              children: [
                Expanded(
                  child: Text(title, style: theme.textTheme.bodyLarge),
                ),
                Text(value, style: theme.textTheme.labelSmall),
                const SizedBox(width: Gap.sm),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: theme.colorScheme.outline,
                ),
              ],
            ),
          ),
        ),
        Divider(height: 1, color: theme.colorScheme.outlineVariant),
      ],
    );
  }
}
