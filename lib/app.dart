import 'package:einstellungstest_trainer/screens/home_screen.dart';
import 'package:einstellungstest_trainer/services/notifications/reminder_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Einstellungstest Trainer',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(Brightness.light),
      darkTheme: buildAppTheme(Brightness.dark),
      home: const HomeScreen(),
    );
  }
}

/// Material-3-Theme der App.
///
/// Bewusst zurueckhaltend: Bei einer Lern-App soll die Aufgabe im Fokus
/// stehen, nicht die Oberflaeche.
ThemeData buildAppTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF2F6FED),
    brightness: brightness,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: scheme.onSurface,
        fontSize: 19,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: IconThemeData(color: scheme.onSurface),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
  );
}
