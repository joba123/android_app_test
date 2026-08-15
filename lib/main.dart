import 'package:einstellungstest_trainer/app.dart';
import 'package:einstellungstest_trainer/services/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // SharedPreferences werden einmalig vor dem Start geladen, damit der
  // Lernfortschritt synchron verfuegbar ist und die Startseite nicht
  // erst durch einen Ladezustand muss.
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const EinstellungstestTrainerApp(),
    ),
  );
}
