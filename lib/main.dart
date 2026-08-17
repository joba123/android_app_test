import 'package:einstellungstest_trainer/app.dart';
import 'package:einstellungstest_trainer/firebase_options.dart';
import 'package:einstellungstest_trainer/services/ads/ad_controller.dart';
import 'package:einstellungstest_trainer/services/ads/admob_ad_service.dart';
import 'package:einstellungstest_trainer/services/notifications/local_reminder_service.dart';
import 'package:einstellungstest_trainer/services/notifications/reminder_controller.dart';
import 'package:einstellungstest_trainer/services/providers.dart';
import 'package:einstellungstest_trainer/services/purchase/entitlement_controller.dart';
import 'package:einstellungstest_trainer/services/purchase/store_purchase_service.dart';
import 'package:einstellungstest_trainer/services/sync/sync_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // SharedPreferences werden einmalig vor dem Start geladen, damit der
  // Lernfortschritt synchron verfuegbar ist und die Startseite nicht
  // erst durch einen Ladezustand muss.
  final prefs = await SharedPreferences.getInstance();
  final firebaseReady = await _tryInitializeFirebase();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        firebaseReadyProvider.overrideWithValue(firebaseReady),
        // Der Dienst richtet sich beim ersten Zugriff selbst ein; das Laden
        // der Zeitzonen-Datenbank haelt den App-Start dadurch nicht auf.
        reminderServiceProvider.overrideWithValue(LocalReminderService()),
        // Anzeigen und Kaeufe. Beide Dienste richten sich beim ersten Zugriff
        // selbst ein; scheitert das, laeuft die App ohne Werbung und ohne
        // Kaufmoeglichkeit weiter statt gar nicht.
        adServiceProvider.overrideWithValue(AdMobAdService()),
        purchaseServiceProvider.overrideWithValue(StorePurchaseService()),
      ],
      child: const EinstellungstestTrainerApp(),
    ),
  );
}

/// Versucht, Firebase zu starten.
///
/// Schlaegt das fehl – etwa weil noch keine Konfiguration hinterlegt ist –,
/// laeuft die App im lokalen Modus weiter. Anmeldung und Cloud-Sync sind dann
/// ausgeblendet, alles andere funktioniert unveraendert.
Future<bool> _tryInitializeFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    return true;
  } catch (_) {
    return false;
  }
}
