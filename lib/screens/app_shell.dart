import 'package:einstellungstest_trainer/screens/home_screen.dart';
import 'package:einstellungstest_trainer/screens/more_screen.dart';
import 'package:einstellungstest_trainer/screens/onboarding_screen.dart';
import 'package:einstellungstest_trainer/screens/stats_screen.dart';
import 'package:einstellungstest_trainer/theme/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Der Rahmen der App: drei Reiter und die Weiche zur Einführung.
///
/// Solange die Einführung aussteht, gibt es keine Navigationsleiste – wer
/// die App zum ersten Mal öffnet, soll nicht zwischen Reitern wählen, sondern
/// eine Frage nach der anderen beantworten.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _tab = 0;

  static const _tabs = [
    (icon: Icons.home_outlined, active: Icons.home, label: 'Start'),
    (
      icon: Icons.insights_outlined,
      active: Icons.insights,
      label: 'Statistik'
    ),
    (icon: Icons.more_horiz, active: Icons.more_horiz, label: 'Mehr'),
  ];

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(onboardingDoneProvider)) {
      return const OnboardingScreen();
    }

    final theme = Theme.of(context);
    final tokens = context.tokens;

    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: const [
          HomeScreen(),
          StatsScreen(),
          MoreScreen(),
        ],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _tab,
          onDestinationSelected: (index) => setState(() => _tab = index),
          backgroundColor: tokens.paper,
          surfaceTintColor: Colors.transparent,
          indicatorColor: tokens.sunk,
          elevation: 0,
          height: 64,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            for (final tab in _tabs)
              NavigationDestination(
                icon: Icon(tab.icon),
                selectedIcon: Icon(tab.active),
                label: tab.label,
              ),
          ],
        ),
      ),
    );
  }
}
