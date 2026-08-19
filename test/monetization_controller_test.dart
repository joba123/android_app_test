import 'package:einstellungstest_trainer/models/practice_scope.dart';
import 'package:einstellungstest_trainer/models/pro_entitlement.dart';
import 'package:einstellungstest_trainer/models/question.dart';
import 'package:einstellungstest_trainer/models/session_mode.dart';
import 'package:einstellungstest_trainer/models/sub_category.dart';
import 'package:einstellungstest_trainer/models/training_module.dart';
import 'package:einstellungstest_trainer/models/training_session.dart';
import 'package:einstellungstest_trainer/services/ads/ad_controller.dart';
import 'package:einstellungstest_trainer/services/ads/ad_service.dart';
import 'package:einstellungstest_trainer/services/providers.dart';
import 'package:einstellungstest_trainer/services/purchase/entitlement_controller.dart';
import 'package:einstellungstest_trainer/services/purchase/purchase_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';


/// Wartet, bis eine Bedingung zutrifft.
///
/// Das Verbuchen einer Runde laeuft asynchron ueber mehrere Stufen
/// (Statistik, Verlauf, Fehlerbuch). Ein einzelnes `Future.delayed(zero)`
/// trifft mal die eine, mal die andere – unter Last wird der Test dadurch
/// unzuverlaessig. Deshalb hier warten, bis das Ergebnis tatsaechlich da ist.
Future<void> waitUntil(
  bool Function() condition, {
  Duration timeout = const Duration(seconds: 2),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) {
      throw StateError('Bedingung trat nicht innerhalb von $timeout ein');
    }
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
}

void main() {
  late InMemoryPurchaseService store;
  late InMemoryAdService ads;
  late ProviderContainer container;

  Future<ProviderContainer> build() async {
    final prefs = await SharedPreferences.getInstance();
    return ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        purchaseServiceProvider.overrideWithValue(store),
        adServiceProvider.overrideWithValue(ads),
      ],
    );
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    store = InMemoryPurchaseService();
    ads = InMemoryAdService();
    container = await build();
  });

  tearDown(() {
    container.dispose();
    store.dispose();
  });

  PurchaseController purchases() =>
      container.read(purchaseControllerProvider.notifier);

  AdController adController() => container.read(adControllerProvider.notifier);

  /// Wartet, bis der Store-Stream verarbeitet ist.
  Future<void> settle() => Future<void>.delayed(Duration.zero);

  group('Kauf', () {
    test('schaltet Pro frei', () async {
      // Der Entitlement-Provider muss leben, damit er dem Store zuhoert.
      expect(container.read(isProProvider), isFalse);

      await purchases().buy(ProPlan.lifetime);
      await settle();

      expect(store.lastPurchased, ProPlan.lifetime);
      expect(container.read(isProProvider), isTrue);
      expect(container.read(entitlementProvider)?.plan, ProPlan.lifetime);
    });

    test('überdauert einen Neustart der App', () async {
      container.read(isProProvider);
      await purchases().buy(ProPlan.yearly);
      await settle();

      container.dispose();
      container = await build();

      expect(container.read(isProProvider), isTrue);
      expect(container.read(entitlementProvider)?.plan, ProPlan.yearly);
    });

    test('ein abgelaufenes Abo gilt beim Start nicht mehr', () async {
      final expired = ProEntitlement(
        plan: ProPlan.monthly,
        since: DateTime(2026, 1, 1),
        expiresAt: DateTime(2026, 2, 1),
      );
      await container.read(storageServiceProvider).saveEntitlement(expired);

      container.dispose();
      container = await build();

      expect(container.read(isProProvider), isFalse);
    });

    test('ein Abbruch ändert nichts', () async {
      container.read(isProProvider);
      store.nextOutcome = (_) => const PurchaseCancelled();

      await purchases().buy(ProPlan.monthly);
      await settle();

      expect(container.read(isProProvider), isFalse);
      expect(container.read(purchaseControllerProvider).error, isNull);
      expect(container.read(purchaseControllerProvider).busy, isFalse);
    });

    test('ein Fehlschlag wird gemeldet, ohne freizuschalten', () async {
      container.read(isProProvider);
      store.nextOutcome = (_) => const PurchaseFailed('Zahlung abgelehnt');

      await purchases().buy(ProPlan.lifetime);
      await settle();

      expect(container.read(isProProvider), isFalse);
      expect(container.read(purchaseControllerProvider).error,
          'Zahlung abgelehnt');
    });

    test('stellt einen früheren Kauf wieder her', () async {
      container.read(isProProvider);
      store.restorable = ProEntitlement(
        plan: ProPlan.lifetime,
        since: DateTime(2026, 1, 1),
      );

      await purchases().restore();
      await settle();

      expect(store.restoreCalls, 1);
      expect(container.read(isProProvider), isTrue);
    });

    test('ohne früheren Kauf gibt es eine Auskunft, keinen Fehler', () async {
      container.read(isProProvider);

      await purchases().restore();
      await settle();

      final state = container.read(purchaseControllerProvider);
      expect(state.error, isNull);
      expect(state.notice, contains('kein früherer Kauf'));
    });

    test('die Angebote werden beim Öffnen geladen', () async {
      await purchases().loadOffers();

      final state = container.read(purchaseControllerProvider);
      expect(state.loading, isFalse);
      expect(state.offers.map((offer) => offer.plan), ProPlan.values);
    });
  });

  group('Werbung', () {
    test('läuft im kostenlosen Modus', () {
      expect(container.read(adsAllowedProvider), isTrue);
    });

    test('endet mit dem Kauf sofort', () async {
      container.read(isProProvider);

      await purchases().buy(ProPlan.lifetime);
      await settle();

      expect(container.read(adsAllowedProvider), isFalse);
    });

    test('bleibt ohne Einwilligung aus', () async {
      container.dispose();
      ads = InMemoryAdService(consent: AdConsentStatus.denied);
      container = await build();

      expect(container.read(adsAllowedProvider), isFalse);
    });

    test('unterbricht nicht nach der ersten Sprint-Runde', () async {
      final shown = await adController().onSprintFinished();

      expect(shown, isFalse);
      expect(ads.interstitialsShown, 0);
      expect(container.read(adControllerProvider).completedSprints, 1);
    });

    test('unterbricht ab der dritten Runde genau einmal', () async {
      await adController().onSprintFinished();
      await adController().onSprintFinished();
      final third = await adController().onSprintFinished();

      expect(third, isTrue);
      expect(ads.interstitialsShown, 1);

      // Direkt danach wieder Ruhe.
      await adController().onSprintFinished();
      expect(ads.interstitialsShown, 1);
    });

    test('unterbricht mit Pro nie', () async {
      container.read(isProProvider);
      await purchases().buy(ProPlan.lifetime);
      await settle();

      for (var round = 0; round < 6; round++) {
        expect(await adController().onSprintFinished(), isFalse);
      }
      expect(ads.interstitialsShown, 0);
    });

    test('der Zählerstand übersteht einen Neustart', () async {
      await adController().onSprintFinished();
      await adController().onSprintFinished();

      container.dispose();
      container = await build();

      expect(container.read(adControllerProvider).completedSprints, 2);
      expect(await adController().onSprintFinished(), isTrue);
    });

    test('lädt nur vor, wenn Werbung überhaupt laufen darf', () async {
      adController().preload();
      expect(ads.preloads, 1);

      container.read(isProProvider);
      await purchases().buy(ProPlan.lifetime);
      await settle();

      adController().preload();
      expect(ads.preloads, 1);
    });
  });

  group('Freigeschaltete Inhalte', () {
    test('das Repository zieht mit Pro aus dem größeren Bestand', () async {
      expect(container.read(questionRepositoryProvider).proUnlocked, isFalse);

      container.read(isProProvider);
      await purchases().buy(ProPlan.lifetime);
      await settle();

      expect(container.read(questionRepositoryProvider).proUnlocked, isTrue);
    });

    test('der Verlauf wird mit Pro länger', () async {
      expect(container.read(historyLimitProvider),
          ProBenefits.freeHistoryLimit);

      container.read(isProProvider);
      await purchases().buy(ProPlan.monthly);
      await settle();

      expect(container.read(historyLimitProvider), ProBenefits.proHistoryLimit);
    });

    test('der längere Verlauf wird auch tatsächlich gespeichert', () async {
      container.read(isProProvider);
      await purchases().buy(ProPlan.lifetime);
      await settle();

      final history = container.read(sessionHistoryProvider.notifier);
      for (var index = 0; index < ProBenefits.freeHistoryLimit + 5; index++) {
        await history.add(
          TrainingSession(
            id: 'session_$index',
            mode: SessionMode.practice,
            module: TrainingModule.math,
            startedAt: DateTime(2026, 1, 1),
            finishedAt: DateTime(2026, 1, 1, 0, 5),
            results: [
              QuestionResult(
                questionId: 'q$index',
                subCategory: SubCategory.arithmetic,
                answered: true,
                correct: true,
                timeSpent: const Duration(seconds: 5),
              ),
            ],
          ),
        );
      }

      expect(
        container.read(sessionHistoryProvider),
        hasLength(ProBenefits.freeHistoryLimit + 5),
      );
    });

    test('eine Übungsrunde kann mit Pro schwere Aufgaben anfordern', () async {
      container.read(isProProvider);
      await purchases().buy(ProPlan.lifetime);
      await settle();

      final questions = container.read(questionRepositoryProvider).drawForScope(
            PracticeScope.subCategory(SubCategory.numberSequences),
            count: 5,
            difficulty: Difficulty.hard,
          );

      expect(questions, isNotEmpty);
      expect(
        questions.every((question) => question.difficulty == Difficulty.hard),
        isTrue,
      );
    });
  });

  group('Ohne Store', () {
    test('bleibt alles nutzbar, nur eben ohne Kauf', () async {
      final prefs = await SharedPreferences.getInstance();
      final local = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(local.dispose);

      expect(local.read(purchaseServiceProvider).isAvailable, isFalse);
      expect(local.read(isProProvider), isFalse);
      // Ohne Anzeigendienst gibt es auch keine Werbung.
      expect(local.read(adsAllowedProvider), isFalse);

      await local.read(purchaseControllerProvider.notifier).loadOffers();
      expect(local.read(purchaseControllerProvider).offers, isEmpty);
    });
  });
}
