import 'package:einstellungstest_trainer/models/exam_date.dart';
import 'package:einstellungstest_trainer/services/auth/account_controller.dart';
import 'package:einstellungstest_trainer/services/auth/auth_service.dart';
import 'package:einstellungstest_trainer/services/sync/sync_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Konto, Cloud-Abgleich und Testtermin.
class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final auth = ref.watch(authServiceProvider);
    final user = ref.watch(authUserProvider).value;
    final account = ref.watch(accountControllerProvider);

    ref.listen(accountControllerProvider, (previous, next) {
      final message = next.error ?? next.notice;
      if (message == null) return;

      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(message)));
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Konto & Sicherung')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: [
            if (user == null)
              _SignedOutCard(available: auth.isAvailable, busy: account.busy)
            else
              _SignedInCard(user: user, busy: account.busy),
            const SizedBox(height: 24),
            Text(
              'Testtermin',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Wird mit deinem Konto abgeglichen und ist damit auf allen '
              'Geräten verfügbar.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            const _ExamDateCard(),
            const SizedBox(height: 24),
            Text(
              'Datenschutz',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            const _PrivacyCard(),
          ],
        ),
      ),
    );
  }
}

/// Zustand ohne Anmeldung – der lokale Modus.
class _SignedOutCard extends ConsumerWidget {
  const _SignedOutCard({required this.available, required this.busy});

  final bool available;
  final bool busy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final controller = ref.read(accountControllerProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.phone_android,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Lokaler Modus',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Dein Fortschritt liegt nur auf diesem Gerät. Die App funktioniert '
            'vollständig ohne Konto – eine Anmeldung sichert den Fortschritt '
            'zusätzlich und macht ihn auf anderen Geräten verfügbar.',
            style: theme.textTheme.bodySmall?.copyWith(height: 1.45),
          ),
          const SizedBox(height: 16),
          if (!available)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Für diese App-Version ist noch kein Firebase-Projekt '
                'hinterlegt. Die Anmeldung wird verfügbar, sobald die '
                'Konfiguration eingespielt ist.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else ...[
            FilledButton.icon(
              onPressed: busy
                  ? null
                  : () => controller.signIn(AuthProviderKind.google),
              icon: const Icon(Icons.account_circle_outlined),
              label: Text(AuthProviderKind.google.label),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: busy
                  ? null
                  : () => controller.signIn(AuthProviderKind.apple),
              icon: const Icon(Icons.apple),
              label: Text(AuthProviderKind.apple.label),
            ),
          ],
          if (busy) ...[
            const SizedBox(height: 14),
            const LinearProgressIndicator(),
          ],
        ],
      ),
    );
  }
}

/// Zustand mit Anmeldung: Abgleich, Abmelden, Löschen.
class _SignedInCard extends ConsumerWidget {
  const _SignedInCard({required this.user, required this.busy});

  final AuthUser user;
  final bool busy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final sync = ref.watch(syncControllerProvider);
    final controller = ref.read(accountControllerProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.cloud_done_outlined,
                color: theme.colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName ?? 'Angemeldet',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    Text(
                      'über ${user.provider == AuthProviderKind.google ? 'Google' : 'Apple'}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer
                            .withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            _describeSync(sync),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: busy || sync.isRunning
                ? null
                : () => ref.read(syncControllerProvider.notifier).syncNow(),
            icon: const Icon(Icons.sync),
            label: const Text('Jetzt abgleichen'),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: busy ? null : controller.signOut,
            child: const Text('Abmelden'),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: busy ? null : () => _confirmDelete(context, ref),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            child: const Text('Konto und Daten löschen'),
          ),
          if (busy || sync.isRunning) ...[
            const SizedBox(height: 10),
            const LinearProgressIndicator(),
          ],
        ],
      ),
    );
  }

  String _describeSync(SyncState sync) {
    return switch (sync.status) {
      SyncStatus.running => 'Abgleich läuft …',
      SyncStatus.failed => sync.error ?? 'Abgleich fehlgeschlagen',
      SyncStatus.success =>
        'Zuletzt abgeglichen: ${_time(sync.lastSyncedAt)} · '
            '${sync.uploaded} hoch, ${sync.downloaded} runter',
      SyncStatus.idle => 'Noch kein Abgleich in dieser Sitzung',
    };
  }

  String _time(DateTime? value) {
    if (value == null) return '–';
    return '${value.hour.toString().padLeft(2, '0')}:'
        '${value.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.delete_forever_outlined),
        title: const Text('Konto wirklich löschen?'),
        content: const Text(
          'Dein Konto und alle in der Cloud gespeicherten Daten werden '
          'unwiderruflich gelöscht – Fortschritt, Sitzungsverlauf und '
          'Testtermin. Auch die lokale Kopie auf diesem Gerät wird entfernt.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            child: const Text('Endgültig löschen'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      await ref.read(accountControllerProvider.notifier).deleteAccount();
    }
  }
}

/// Testtermin setzen, ändern, entfernen.
class _ExamDateCard extends ConsumerWidget {
  const _ExamDateCard();

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
              _formatDate(examDate.date),
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

  String _formatDate(DateTime value) {
    return '${value.day.toString().padLeft(2, '0')}.'
        '${value.month.toString().padLeft(2, '0')}.${value.year}';
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

/// Was gespeichert wird – im Klartext, nicht im Kleingedruckten.
class _PrivacyCard extends StatelessWidget {
  const _PrivacyCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    const stored = [
      'Abgeschlossene Sitzungen als Summen je Thema – ohne einzelne Aufgaben',
      'Fortschritt und Sprint-Bestwerte je Kategorie',
      'Der hinterlegte Testtermin',
    ];
    const notStored = [
      'Keine E-Mail-Adresse und kein Name in der eigenen Datenbank',
      'Keine Aufgabentexte und keine einzelnen Antworten',
      'Keine Geräte-Kennungen und kein Standort',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mit Konto wird gespeichert',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          for (final entry in stored)
            _Bullet(icon: Icons.check, color: const Color(0xFF0E9F6E), text: entry),
          const SizedBox(height: 14),
          Text(
            'Nicht gespeichert',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          for (final entry in notStored)
            _Bullet(
              icon: Icons.close,
              color: theme.colorScheme.outline,
              text: entry,
            ),
          const SizedBox(height: 14),
          Text(
            'Die Daten liegen in der EU-Region von Firestore. Die Kontodaten '
            'selbst verwaltet Firebase Auth; sie werden dort auch außerhalb '
            'der EU verarbeitet. Löschen entfernt beides.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({
    required this.icon,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
