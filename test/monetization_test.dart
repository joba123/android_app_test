import 'package:einstellungstest_trainer/data/pro_questions.dart';
import 'package:einstellungstest_trainer/data/question_pool.dart';
import 'package:einstellungstest_trainer/data/question_validation.dart';
import 'package:einstellungstest_trainer/models/ad_frequency.dart';
import 'package:einstellungstest_trainer/models/pro_entitlement.dart';
import 'package:einstellungstest_trainer/models/sub_category.dart';
import 'package:einstellungstest_trainer/models/training_module.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Berechtigung', () {
    test('ein Einmalkauf läuft nicht ab', () {
      final entitlement = ProEntitlement(
        plan: ProPlan.lifetime,
        since: DateTime(2026, 1, 1),
      );

      expect(entitlement.isActive(DateTime(2099, 1, 1)), isTrue);
    });

    test('ein Abo gilt bis zum Ablaufdatum', () {
      final entitlement = ProEntitlement(
        plan: ProPlan.monthly,
        since: DateTime(2026, 1, 1),
        expiresAt: DateTime(2026, 2, 1),
      );

      expect(entitlement.isActive(DateTime(2026, 1, 20)), isTrue);
      expect(entitlement.isActive(DateTime(2026, 2, 2)), isFalse);
    });

    test('übersteht die Serialisierung', () {
      final entitlement = ProEntitlement(
        plan: ProPlan.yearly,
        since: DateTime(2026, 3, 5),
        expiresAt: DateTime(2027, 3, 5),
      );

      expect(ProEntitlement.fromJson(entitlement.toJson()), entitlement);
    });

    test('meldet einen beschädigten Eintrag als null', () {
      expect(ProEntitlement.fromJson(const {'plan': 'pro_unbekannt'}), isNull);
      expect(ProEntitlement.fromJson(const {'since': 'gestern'}), isNull);
    });

    test('jede Produkt-Kennung ist eindeutig und auffindbar', () {
      expect(ProPlan.productIds, hasLength(ProPlan.values.length));

      for (final plan in ProPlan.values) {
        expect(ProPlan.tryFromProductId(plan.productId), plan);
      }
    });
  });

  group('Taktung der Unterbrecher-Werbung', () {
    AdFrequencyState after(int sprints, {DateTime? lastAd}) {
      var state = AdFrequencyState(lastShownAt: lastAd);
      for (var index = 0; index < sprints; index++) {
        state = state.afterSprint();
      }
      return state;
    }

    final now = DateTime(2026, 5, 1, 12);

    test('die erste Runde bleibt frei', () {
      expect(
        InterstitialPolicy.shouldShow(state: after(1), now: now),
        isFalse,
      );
    });

    test('erst ab der dritten Runde nach der letzten Anzeige', () {
      expect(
        InterstitialPolicy.shouldShow(state: after(2), now: now),
        isFalse,
      );
      expect(
        InterstitialPolicy.shouldShow(state: after(3), now: now),
        isTrue,
      );
    });

    test('nie zweimal innerhalb weniger Minuten', () {
      // Drei Runden geschafft, aber die letzte Anzeige ist zwei Minuten her.
      final state = after(
        3,
        lastAd: now.subtract(const Duration(minutes: 2)),
      );

      expect(InterstitialPolicy.shouldShow(state: state, now: now), isFalse);

      expect(
        InterstitialPolicy.shouldShow(
          state: state,
          now: now.add(const Duration(minutes: 4)),
        ),
        isTrue,
      );
    });

    test('der Zähler beginnt nach einer Anzeige von vorn', () {
      final state = after(3).afterAd(now);

      expect(state.sprintsSinceLastAd, 0);
      expect(state.completedSprints, 3);
      expect(
        InterstitialPolicy.shouldShow(
          state: state.afterSprint(),
          now: now.add(const Duration(hours: 1)),
        ),
        isFalse,
      );
    });

    test('übersteht die Serialisierung', () {
      final state = after(4).afterAd(now);

      expect(AdFrequencyState.fromJson(state.toJson()), state);
    });

    test('fängt beschädigte Zählerstände ab', () {
      final restored = AdFrequencyState.fromJson(const {
        'completedSprints': -5,
        'sprintsSinceLastAd': 'viele',
      });

      expect(restored.completedSprints, 0);
      expect(restored.sprintsSinceLastAd, 0);
    });
  });

  group('Pro-Aufgabenbestand', () {
    test('erweitert den kostenlosen Bestand, ohne ihn anzutasten', () {
      // Die Zusage aus dem Kauf-Screen, als Test formuliert: Jede kostenlose
      // Aufgabe muss auch mit Pro noch da sein.
      for (final question in QuestionPool.all) {
        expect(
          QuestionPool.allWithPro.contains(question),
          isTrue,
          reason: '${question.id} fehlt im Pro-Bestand',
        );
      }

      expect(
        QuestionPool.allWithPro.length,
        QuestionPool.all.length + proQuestions.length,
      );
    });

    test('keine Pro-Aufgabe taucht im kostenlosen Bestand auf', () {
      final freeIds = QuestionPool.all.map((question) => question.id).toSet();

      for (final question in proQuestions) {
        expect(freeIds.contains(question.id), isFalse);
      }
    });

    test('alle Kennungen bleiben eindeutig', () {
      final ids = QuestionPool.allWithPro.map((question) => question.id);

      expect(ids.toSet(), hasLength(QuestionPool.allWithPro.length));
    });

    test('jede Pro-Aufgabe besteht die Qualitätssicherung', () {
      // Dieselbe Messlatte wie für den kostenlosen Bestand – bezahlte
      // Aufgaben duerfen nicht schlechter sein.
      for (final question in proQuestions) {
        expect(
          validateQuestion(question),
          isEmpty,
          reason: 'Aufgabe ${question.id}',
        );
      }
    });

    test('deckt Logik und Sprache ab', () {
      final modules = proQuestions.map((question) => question.module).toSet();

      expect(modules, contains(TrainingModule.logic));
      expect(modules, contains(TrainingModule.language));
      // Mathematik wird generiert – dort waere ein statischer Zusatz sinnlos.
      expect(modules, isNot(contains(TrainingModule.math)));
    });

    test('jede Unterkategorie von Logik und Sprache wächst', () {
      for (final subCategory in [
        ...SubCategory.of(TrainingModule.logic),
        ...SubCategory.of(TrainingModule.language),
      ]) {
        // Generierte Themen haben keinen festen Bestand, der wachsen koennte.
        if (QuestionPool.isGeneratedTopic(subCategory)) continue;

        expect(
          QuestionPool.countForSubCategory(subCategory, proUnlocked: true),
          greaterThan(QuestionPool.countForSubCategory(subCategory)),
          reason: '${subCategory.label} bekommt mit Pro nichts dazu',
        );
      }
    });

    test('die Umfangsbeschreibung nennt mit Pro die höhere Zahl', () {
      final free = QuestionPool.describeSize(TrainingModule.logic);
      final pro = QuestionPool.describeSize(
        TrainingModule.logic,
        proUnlocked: true,
      );

      expect(free, isNot(pro));
      // Mathematik ist generiert und bleibt unverändert.
      expect(
        QuestionPool.describeSize(TrainingModule.math),
        QuestionPool.describeSize(TrainingModule.math, proUnlocked: true),
      );
    });
  });

  group('Angebot', () {
    test('nennt beim Jahresabo den Monatspreis zur Einordnung', () {
      const offer = ProOffer(
        plan: ProPlan.yearly,
        price: '24,00 €',
        rawPrice: 24,
        currency: 'EUR',
      );

      expect(offer.pricePerMonth, '2,00 EUR');
    });

    test('rechnet nur beim Jahresabo um', () {
      const offer = ProOffer(
        plan: ProPlan.monthly,
        price: '2,99 €',
        rawPrice: 2.99,
        currency: 'EUR',
      );

      expect(offer.pricePerMonth, isNull);
    });

    test('ohne Rohpreis wird nichts gerechnet', () {
      const offer = ProOffer(plan: ProPlan.yearly, price: '19,99 €');

      expect(offer.pricePerMonth, isNull);
    });
  });
}
