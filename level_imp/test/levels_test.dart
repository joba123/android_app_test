import 'package:flutter_test/flutter_test.dart';
import 'package:level_imp/game/engine.dart';
import 'package:level_imp/game/levels.dart';

/// One scripted bot instruction: hold [press] (-1 left, 0 none, 1 right),
/// optionally with jump held, until [until] is true.
class BotStep {
  final int press;
  final bool jump;
  final bool Function(World w, double elapsed) until;
  const BotStep(this.press, this.until, {this.jump = false});
}

BotStep toX(int press, double x) =>
    BotStep(press, (w, _) => press >= 0 ? w.player.x >= x : w.player.x <= x);
BotStep until(int press, bool Function(World w) f) =>
    BotStep(press, (w, _) => f(w));
BotStep jump(int press) =>
    BotStep(press, jump: true, (w, t) => t > 0.05 && w.player.grounded);
BotStep wait(double s, [int press = 0]) => BotStep(press, (_, t) => t >= s);
BotStep win(int press) => BotStep(press, (w, _) => w.status == WorldStatus.won);

World play(LevelDef def, List<BotStep> steps) {
  final w = World(def);
  var simTime = 0.0;
  for (final s in steps) {
    w.input
      ..left = s.press < 0
      ..right = s.press > 0
      ..jump = false;
    if (s.jump) {
      w.step(); // release frame, so the next press is a fresh edge
      w.input.jump = true;
    }
    var t = 0.0;
    while (!s.until(w, t)) {
      w.step();
      t += Physics.stepDt;
      simTime += Physics.stepDt;
      if (w.status != WorldStatus.playing || simTime > 40) return w;
    }
  }
  return w;
}

Entity saw(World w, String g) => w.groupOf(g).first;

final Map<int, List<BotStep>> solutions = {
  1: [toX(1, 13.6), jump(1), win(1)],
  2: [toX(1, 7.3), jump(1), toX(1, 17.3), jump(1), win(1)],
  // Sneak up to each crusher, nudge it into dropping, pass while it rises.
  3: [
    toX(1, 11.3),
    wait(0.5),
    wait(0.09, 1),
    wait(1.2),
    toX(1, 18.3),
    wait(0.5),
    wait(0.09, 1),
    wait(1.2),
    win(1),
  ],
  4: [
    toX(1, 26.3),
    jump(-1),
    toX(-1, 22.1),
    jump(-1),
    toX(-1, 15.1),
    jump(-1),
    toX(-1, 8.1),
    jump(-1),
    win(-1),
  ],
  5: [
    until(-1, (w) => w.player.x >= 9.0),
    jump(-1),
    until(-1, (w) => !w.reversed),
    toX(1, 21.0),
    jump(1),
    win(1),
  ],
  6: [
    // Bonk the hidden block into existence, then climb it from the side.
    toX(1, 10.4), jump(0),
    toX(-1, 8.8), jump(1),
    toX(1, 11.2), jump(1),
    toX(1, 16.2), jump(1),
    toX(1, 21.2), jump(1),
    win(1),
  ],
  7: [
    toX(1, 7.3),
    jump(1),
    toX(1, 13.5),
    until(0, (w) => saw(w, 'S').x >= 22.8),
    until(1, (w) => saw(w, 'S').x - (w.player.x + Player.w) < 2.5),
    jump(1),
    toX(1, 24.1),
    wait(1.0),
    toX(1, 25.3),
    jump(1),
    win(1),
  ],
  8: [
    toX(1, 9.2),
    until(1, (w) => w.player.grounded),
    toX(1, 15.0),
    jump(1),
    toX(1, 22.0),
    jump(1),
    win(1),
  ],
  9: [toX(1, 13.5), jump(1), win(1)],
  10: [
    toX(1, 6.2),
    jump(1),
    toX(1, 11.5),
    jump(1),
    toX(1, 18.5),
    jump(1),
    win(1),
  ],
  11: [toX(1, 12.0), jump(1), toX(1, 18.6), jump(1), jump(1), win(1)],
  12: [
    toX(1, 7.5), jump(1),
    toX(1, 22.1),
    toX(-1, 17.0), jump(-1),
    toX(-1, 11.7), jump(-1),
    // Controls are reversed from here on.
    until(-1, (w) => w.player.x >= 8.0), jump(1),
    toX(-1, 6.2), jump(-1),
    toX(-1, 11.2), jump(-1),
    win(-1),
  ],
};

void main() {
  test('all maps are 32x15 and parse', () {
    for (final def in levels) {
      expect(def.map.length, 15, reason: def.title);
      for (final row in def.map) {
        expect(row.length, 32, reason: '${def.title}: "$row"');
      }
      final w = World(def);
      expect(w.entities.where((e) => e.isDoor), isNotEmpty, reason: def.title);
    }
  });

  test('every level has a scripted solution', () {
    expect(solutions.keys.toSet(), {
      for (var i = 1; i <= levels.length; i++) i,
    });
  });

  for (var i = 0; i < levels.length; i++) {
    final n = i + 1;
    test('level $n "${levels[i].title}" is solvable', () {
      final w = play(levels[i], solutions[n]!);
      expect(
        w.status,
        WorldStatus.won,
        reason:
            'player at (${w.player.x.toStringAsFixed(2)}, '
            '${w.player.y.toStringAsFixed(2)}) t=${w.time.toStringAsFixed(2)}',
      );
    });
  }

  group('traps actually kill a naive player', () {
    // Simply running right should not finish these levels.
    for (final n in [1, 2, 3, 7, 9, 11]) {
      test('level $n', () {
        final w = play(levels[n - 1], [win(1)]);
        expect(w.status, isNot(WorldStatus.won));
      });
    }
  });

  test('player lands on the floor and stays put', () {
    final w = World(levels[0]);
    for (var i = 0; i < 120; i++) {
      w.step();
    }
    expect(w.player.grounded, isTrue);
    expect(w.player.y + Player.h, closeTo(12, 1e-6));
    expect(w.status, WorldStatus.playing);
  });
}
