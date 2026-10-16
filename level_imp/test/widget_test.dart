import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:level_imp/main.dart';
import 'package:level_imp/progress.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await Progress.init();
  });

  testWidgets('menu opens the first level and the game runs', (tester) async {
    tester.view.physicalSize = const Size(2400, 1080);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const LevelImpApp());
    expect(find.text('LEVEL IMP'), findsOneWidget);

    await tester.tap(find.text('SPIELEN'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('LEVEL 1'), findsOneWidget);
    expect(find.text('Der erste Schritt'), findsOneWidget);

    // Let the simulation run for a bit; nothing should throw.
    for (var i = 0; i < 60; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }

    await tester.tap(find.byIcon(Icons.pause_rounded));
    await tester.pump();
    expect(find.text('Pause'), findsOneWidget);
  });
}
