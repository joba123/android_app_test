import 'dart:async';

import 'package:einstellungstest_trainer/screens/app_shell.dart';
import 'package:einstellungstest_trainer/theme/app_theme.dart';
import 'package:einstellungstest_trainer/services/ads/ad_controller.dart';
import 'package:einstellungstest_trainer/services/appearance_controller.dart';
import 'package:einstellungstest_trainer/services/notifications/reminder_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Das Theme lebt in `lib/theme/app_theme.dart`; hier nur weitergereicht,
/// damit bestehende Importe von `app.dart` weiter funktionieren.
export 'package:einstellungstest_trainer/theme/app_theme.dart'
    show buildAppTheme, AppFonts, NumText;
export 'package:einstellungstest_trainer/theme/design_tokens.dart'
    show ExamTokens, ExamTokensAccess, ModulePalette, Radii, Gap;


class EinstellungstestTrainerApp extends ConsumerStatefulWidget {
  const EinstellungstestTrainerApp({super.key});

  @override
  ConsumerState<EinstellungstestTrainerApp> createState() =>
      _EinstellungstestTrainerAppState();
}

class _EinstellungstestTrainerAppState
    extends ConsumerState<EinstellungstestTrainerApp> {
  @override
  void initState() {
    super.initState();

    // Beim Start einmal neu planen. Android verwirft geplante Alarme unter
    // anderem beim Neustart des Geraets; ausserdem koennen Erinnerungen
    // inzwischen in der Vergangenheit liegen oder der Termin auf einem
    // anderen Geraet verschoben worden sein.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reminderControllerProvider.notifier).reschedule();

      // Anzeigen erst nach dem ersten Frame starten: Der Einwilligungsdialog
      // gehoert nicht vor die Startseite, und ohne Einwilligung wird ohnehin
      // nichts angefordert.
      unawaited(ref.read(adServiceProvider).initialize());
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Einstellungstest Trainer',
      debugShowCheckedModeBanner: false,
      // Die App ist durchgaengig deutsch. Ohne diese Angaben zeigen die
      // Material-Dialoge - vor allem Datums- und Uhrzeitauswahl - englische
      // Beschriftungen und Monatsnamen.
      locale: const Locale('de'),
      supportedLocales: const [Locale('de')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: buildAppTheme(Brightness.light),
      darkTheme: buildAppTheme(Brightness.dark),
      themeMode: ref.watch(themeModeProvider),
      home: const AppShell(),
    );
  }
}
