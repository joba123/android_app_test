import 'package:einstellungstest_trainer/data/question_pool.dart';
import 'package:einstellungstest_trainer/models/pro_entitlement.dart';
import 'package:einstellungstest_trainer/services/purchase/entitlement_controller.dart';
import 'package:einstellungstest_trainer/theme/app_theme.dart';
import 'package:einstellungstest_trainer/theme/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Der Kauf-Screen.
///
/// Grundsätze, die hier bewusst eingehalten werden:
///
/// * Kein Countdown, kein „nur heute", keine durchgestrichenen Fantasiepreise.
/// * Kein Tarif ist vorausgewählt oder als „beliebteste Wahl" markiert – die
///   Entscheidung trifft der Nutzer, nicht die Gestaltung.
/// * Was kostenlos bleibt, steht **vor** den Preisen und nicht im
///   Kleingedruckten.
/// * Der Abbrechen-Weg ist eine normale, sichtbare Schaltfläche.
class ProScreen extends ConsumerWidget {
  const ProScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPro = ref.watch(isProProvider);
    final state = ref.watch(purchaseControllerProvider);

    ref.listen(purchaseControllerProvider, (previous, next) {
      final message = next.error ?? next.notice;
      if (message == null) return;

      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(message)));
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Pro')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: [
            if (isPro) const _ActiveCard() else ...[
              const _Intro(),
              const SizedBox(height: 20),
              const _Comparison(),
              const SizedBox(height: 20),
              const _FreePromise(),
              const SizedBox(height: 24),
              _Plans(state: state),
              const SizedBox(height: 16),
              const _LegalNote(),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: state.busy
                      ? null
                      : () => ref
                          .read(purchaseControllerProvider.notifier)
                          .restore(),
                  child: const Text('Früheren Kauf wiederherstellen'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mehr Aufgaben, keine Werbung',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Pro erweitert das Training und finanziert die Weiterentwicklung. '
          'Ob sich das für dich lohnt, hängt davon ab, wie viel du übst – '
          'probier die kostenlose Version ruhig erst aus.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _BenefitList extends StatelessWidget {
  const _BenefitList();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: Radii.bandRadius,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final benefit in ProBenefits.all)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      benefit,
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Text(
              '${QuestionPool.proExtraCount} zusätzliche Aufgaben in Logik '
              'und Sprache, Schwerpunkt auf den schwereren Typen.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Die Zusage, dass nichts weggenommen wird – prominent, nicht versteckt.
class _FreePromise extends StatelessWidget {
  const _FreePromise();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.lock_open_outlined,
          size: 18,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            ProBenefits.promise,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}

class _Plans extends ConsumerWidget {
  const _Plans({required this.state});

  final PurchaseUiState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    if (state.loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.offers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: Radii.bandRadius,
        ),
        child: Text(
          'Die Angebote lassen sich gerade nicht laden. Das liegt meist an '
          'der Verbindung zum Store – die App funktioniert unverändert '
          'weiter.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.45,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Tarif wählen',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        for (final offer in state.offers)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _PlanCard(
              offer: offer,
              busy: state.busyPlan == offer.plan,
              disabled: state.busy && state.busyPlan != offer.plan,
              onTap: () => ref
                  .read(purchaseControllerProvider.notifier)
                  .buy(offer.plan),
            ),
          ),
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.offer,
    required this.busy,
    required this.disabled,
    required this.onTap,
  });

  final ProOffer offer;
  final bool busy;
  final bool disabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final perMonth = offer.pricePerMonth;

    return Opacity(
      opacity: disabled ? 0.5 : 1,
      child: Material(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: Radii.bandRadius,
        child: InkWell(
          borderRadius: Radii.bandRadius,
          onTap: busy || disabled ? null : onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: Radii.bandRadius,
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            offer.plan.label,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            offer.price,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        offer.plan.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                      if (perMonth != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'entspricht $perMonth pro Monat',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                if (busy)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Icon(Icons.chevron_right, color: theme.colorScheme.outline),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LegalNote extends StatelessWidget {
  const _LegalNote();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      'Abrechnung über deinen Google-Play-Account. Abos verlängern sich '
      'automatisch, bis du sie kündigst – das geht jederzeit in den '
      'Play-Store-Einstellungen unter „Abos". Der Einmalkauf verlängert sich '
      'nicht. Preise gelten inklusive Mehrwertsteuer.',
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        height: 1.45,
      ),
    );
  }
}

/// Was zu sehen ist, wenn Pro bereits aktiv ist.
class _ActiveCard extends ConsumerWidget {
  const _ActiveCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final entitlement = ref.watch(entitlementProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: Radii.bandRadius,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.workspace_premium_outlined,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Pro ist aktiv',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                entitlement == null
                    ? 'Danke für deine Unterstützung.'
                    : '${entitlement.plan.label} · seit '
                        '${_formatDate(entitlement.since)}'
                        '${entitlement.expiresAt == null ? '' : '\nLäuft ohne '
                            'Kündigung weiter bis '
                            '${_formatDate(entitlement.expiresAt!)}'}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const _BenefitList(),
        const SizedBox(height: 16),
        Text(
          entitlement?.plan.isSubscription ?? false
              ? 'Dein Abo verwaltest du im Play Store unter „Abos" – dort '
                  'kannst du es jederzeit kündigen.'
              : 'Der Einmalkauf bleibt dauerhaft bestehen. Nach einer '
                  'Neuinstallation stellst du ihn über „Wiederherstellen" '
                  'zurück.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.45,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime value) {
    return '${value.day.toString().padLeft(2, '0')}.'
        '${value.month.toString().padLeft(2, '0')}.${value.year}';
  }
}

/// Free und Pro nebeneinander.
///
/// Die Zeilen nennen echte Unterschiede. Was in der kostenlosen Version
/// heute geht, steht auch in der Free-Spalte – eine Tabelle, die Lücken
/// erfindet, um Pro grösser wirken zu lassen, wäre eine Täuschung.
class _Comparison extends StatelessWidget {
  const _Comparison();

  static const List<({String label, String free, String pro})> rows = [
    (label: 'Werbung', free: 'Banner', pro: 'keine'),
    (label: 'Aufgabenpool', free: 'Grundbestand', pro: 'voller Bestand'),
    (label: 'Schwierigkeit wählbar', free: '–', pro: 'dabei'),
    (label: 'Alle drei Bereiche', free: 'dabei', pro: 'dabei'),
    (label: 'Testsimulationen', free: 'unbegrenzt', pro: 'unbegrenzt'),
    (label: 'Gespeicherte Sitzungen', free: '50', pro: '200'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.tokens;

    return Container(
      decoration: BoxDecoration(
        color: tokens.raised,
        borderRadius: Radii.cardRadius,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: Gap.cardWide,
        vertical: Gap.card,
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Spacer(flex: 4),
              Expanded(
                flex: 3,
                child: Text(
                  'FREE',
                  textAlign: TextAlign.end,
                  style: NumText.kicker.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  'PRO',
                  textAlign: TextAlign.end,
                  style: NumText.kicker.copyWith(color: tokens.language.deep),
                ),
              ),
            ],
          ),
          const SizedBox(height: Gap.sm),
          for (final row in rows) ...[
            Divider(height: 1, color: theme.colorScheme.outlineVariant),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Gap.md),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(row.label, style: theme.textTheme.bodyMedium),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      row.free,
                      textAlign: TextAlign.end,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      row.pro,
                      textAlign: TextAlign.end,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
