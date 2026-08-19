import 'package:einstellungstest_trainer/data/question_pool.dart';
import 'package:einstellungstest_trainer/models/practice_scope.dart';
import 'package:einstellungstest_trainer/models/quiz_session.dart';
import 'package:einstellungstest_trainer/models/review_book.dart';
import 'package:einstellungstest_trainer/models/session_mode.dart';
import 'package:einstellungstest_trainer/models/sub_category.dart';
import 'package:einstellungstest_trainer/models/training_module.dart';
import 'package:einstellungstest_trainer/screens/practice_setup_screen.dart';
import 'package:einstellungstest_trainer/screens/quiz_screen.dart';
import 'package:einstellungstest_trainer/screens/strike_out_screen.dart';
import 'package:einstellungstest_trainer/services/providers.dart';
import 'package:einstellungstest_trainer/services/purchase/entitlement_controller.dart';
import 'package:einstellungstest_trainer/theme/app_theme.dart';
import 'package:einstellungstest_trainer/theme/design_tokens.dart';
import 'package:einstellungstest_trainer/widgets/module_glyph.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Die Themen eines Bereichs, mit dem Stand je Thema.
///
/// Antippen startet sofort eine Runde zu genau diesem Thema – das ist der
/// Zweck des Bildschirms. Der Balken daneben sagt, wo es sich lohnt.
class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key, required this.module});

  final TrainingModule module;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final book = ref.watch(reviewBookProvider);
    final isPro = ref.watch(isProProvider);
    final topics = SubCategory.of(module);
    final side = Gap.screenPadding(MediaQuery.sizeOf(context).width);

    return Scaffold(
      appBar: AppBar(
        title: Text(module.menuLabel),
        actions: [
          // Umfang und Schwierigkeit sind selten gebraucht, aber wer sie
          // sucht, sucht sie hier – bei der gezielten Übung.
          IconButton(
            tooltip: 'Umfang und Schwierigkeit',
            icon: const Icon(Icons.tune_rounded),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => PracticeSetupScreen(
                  initialScope: PracticeScope.module(module),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(side, Gap.sm, side, Gap.header),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(Gap.sm, 0, Gap.sm, Gap.card),
              child: Row(
                children: [
                  ModuleGlyph(module: module, size: 44),
                  const SizedBox(width: Gap.md),
                  Expanded(
                    child: Text(
                      'Gezielte Übung nach Thema.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
            for (final topic in topics)
              Padding(
                padding: const EdgeInsets.only(bottom: Gap.sm),
                child: _TopicRow(
                  topic: topic,
                  mastery: book.masteryOf(topic),
                  size: QuestionPool.describeSubCategorySize(
                    topic,
                    proUnlocked: isPro,
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      // Der Durchstreichtest ist keine Folge von Fragen,
                      // sondern eine Flaeche unter Zeitdruck – er bringt
                      // deshalb seinen eigenen Bildschirm mit.
                      builder: (_) => topic.hasOwnScreen
                          ? const StrikeOutScreen()
                          : QuizScreen(
                              mode: SessionMode.practice,
                              scope: PracticeScope.subCategory(topic),
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

class _TopicRow extends StatelessWidget {
  const _TopicRow({
    required this.topic,
    required this.mastery,
    required this.size,
    required this.onTap,
  });

  final SubCategory topic;
  final TopicMastery mastery;
  final String size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.tokens;
    final palette = topic.module.palette(context);
    final hasData = mastery.answered > 0;

    return Material(
      color: tokens.raised,
      borderRadius: Radii.bandRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: Radii.bandRadius,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Gap.card,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            borderRadius: Radii.bandRadius,
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(topic.label, style: theme.textTheme.titleMedium),
                  ),
                  Text(
                    hasData
                        ? '${(mastery.accuracy * 100).round()} %'
                        : 'neu',
                    style: NumText.inline.copyWith(
                      color: hasData
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Gap.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(Radii.pill),
                child: LinearProgressIndicator(
                  value: hasData ? mastery.accuracy.clamp(0, 1) : 0,
                  minHeight: 5,
                  backgroundColor: tokens.sunk,
                  valueColor: AlwaysStoppedAnimation<Color>(palette.accent),
                ),
              ),
              const SizedBox(height: Gap.sm),
              Text(size, style: theme.textTheme.labelSmall),
            ],
          ),
        ),
      ),
    );
  }
}
