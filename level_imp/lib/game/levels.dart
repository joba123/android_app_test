import 'dart:ui' show Rect;

import 'engine.dart';

// Map legend (see defaultLegend in engine.dart):
//   #  solid      c  crumbling floor   P  player start
//   ^ v < >  spikes   O  saw   D  door   U  hanging door   F  fake door
// Letters defined in a level's own legend form trap groups.
//
// Every map is 32 columns x 15 rows. Floor surface is usually y = 12.

const _empty = '#..............................#';
const _full = '################################';

final List<LevelDef> levels = [
  // 1 ── The floor gives way.
  LevelDef(
    title: 'Der erste Schritt',
    subtitle: 'Ganz einfach. Wirklich.',
    theme: 0,
    map: [
      _full,
      for (var i = 0; i < 10; i++) _empty,
      '#.P..........................D.#',
      '###############aaa##############',
      '###############aaa##############',
      '###############aaa##############',
    ],
    legend: {'a': const TileSpec(TileKind.solid)},
    traps: [
      Trap(const PlayerPast(12.5), [const Fall('a')]),
    ],
  ),

  // 2 ── Spikes pop up, the door shuffles away.
  LevelDef(
    title: 'Spitze!',
    subtitle: 'Hier gibt es nichts zu sehen.',
    theme: 1,
    map: [
      _full,
      for (var i = 0; i < 10; i++) _empty,
      '#.P......^^........AA....D.....#',
      _full,
      _full,
      _full,
    ],
    legend: {'A': const TileSpec(TileKind.spikeUp, hidden: true)},
    traps: [
      Trap(const PlayerPast(16), [const Show('A')]),
      Trap(const PlayerPast(22), [MoveTo('D', 4, 0, 12)]),
    ],
  ),

  // 3 ── Crushing ceiling blocks.
  LevelDef(
    title: 'Kopf einziehen',
    subtitle: 'Die Decke ist stabil gebaut.',
    theme: 2,
    map: [
      _full,
      for (var i = 0; i < 9; i++) '#............aaaa...bbb........#',
      _empty,
      '#.P..........................D.#',
      _full,
      _full,
      _full,
    ],
    legend: {
      'a': const TileSpec(TileKind.solid),
      'b': const TileSpec(TileKind.solid),
    },
    traps: [
      Trap(const PlayerPast(12), [
        const MovePath('a', [
          Waypoint(0, 2, 16, wait: 0.4),
          Waypoint(0, 0, 2, wait: 0.9),
        ], loop: true),
      ]),
      Trap(const PlayerPast(19), [
        const MovePath('b', [
          Waypoint(0, 2, 16, wait: 0.4),
          Waypoint(0, 0, 2, wait: 0.9),
        ], loop: true),
      ]),
    ],
  ),

  // 4 ── The door runs away to the top.
  LevelDef(
    title: 'Die Tür ist gleich da',
    subtitle: 'Sie läuft bestimmt nicht weg.',
    theme: 3,
    map: [
      _full,
      _empty,
      _empty,
      _empty,
      '#####..........................#',
      _empty,
      '#.......####...................#',
      _empty,
      '#..............####............#',
      _empty,
      '#.....................####.....#',
      '#.P........................D...#',
      _full,
      _full,
      _full,
    ],
    traps: [
      Trap(const PlayerPast(22), [MoveTo('D', -25, -8, 16)]),
    ],
  ),

  // 5 ── Reversed controls… until they aren't.
  LevelDef(
    title: 'Alles wie immer',
    subtitle: 'Wirklich alles.',
    theme: 4,
    reversed: true,
    map: [
      _full,
      for (var i = 0; i < 10; i++) _empty,
      '#.P.......^^^.........^^^....D.#',
      _full,
      _full,
      _full,
    ],
    traps: [
      Trap(const PlayerPast(16), [const SetReversed(false)]),
    ],
  ),

  // 6 ── Invisible blocks that help you up.
  LevelDef(
    title: 'Unsichtbare Hilfe',
    subtitle: 'Manchmal muss man an sich glauben.',
    theme: 5,
    map: [
      _full,
      _empty,
      _empty,
      _empty,
      _empty,
      '#...........................D..#',
      '#...................ii...#######',
      _empty,
      '#..............hh..............#',
      _empty,
      '#.........gg...................#',
      '#.P............................#',
      _full,
      _full,
      _full,
    ],
    legend: {
      'g': const TileSpec(TileKind.solid, hidden: true, hint: true),
      'h': const TileSpec(TileKind.solid, hidden: true, hint: true),
      'i': const TileSpec(TileKind.solid, hidden: true, hint: true),
    },
    traps: [
      Trap(const PlayerIn(Rect.fromLTRB(10, 10, 12, 11.05)), [const Show('g')]),
      Trap(const PlayerIn(Rect.fromLTRB(15, 8, 17, 9.4)), [const Show('h')]),
      Trap(const PlayerIn(Rect.fromLTRB(20, 6, 22, 7.4)), [const Show('i')]),
    ],
  ),

  // 7 ── Saws.
  LevelDef(
    title: 'Sägewerk',
    subtitle: 'Die Sägen sind nur Deko.',
    theme: 0,
    map: [
      _full,
      '#..........................T...#',
      for (var i = 0; i < 9; i++) _empty,
      '#.P......O.......S...........D.#',
      _full,
      _full,
      _full,
    ],
    legend: {
      'S': const TileSpec(TileKind.saw),
      'T': const TileSpec(TileKind.saw, hidden: true),
    },
    traps: [
      Trap(const PlayerPast(12), [
        const MovePath('S', [Waypoint(6, 0, 6), Waypoint(0, 0, 6)], loop: true),
      ]),
      Trap(const PlayerPast(24), [const Show('T'), MoveTo('T', 0, 10, 16)]),
    ],
  ),

  // 8 ── Gravity flips.
  LevelDef(
    title: 'Oben ist unten',
    subtitle: 'Schwerkraft wird überbewertet.',
    theme: 1,
    map: [
      _full,
      '#...............vv.....vvv..U..#',
      for (var i = 0; i < 9; i++) _empty,
      '#.P............................#',
      '##########^^^^^^^^^^^^^^^^^^^^##',
      _full,
      _full,
    ],
    traps: [
      Trap(const PlayerPast(9), [const SetGravity(-1)]),
    ],
  ),

  // 9 ── Crumbling floor.
  LevelDef(
    title: 'Bröselboden',
    subtitle: 'Bloß nicht stehen bleiben.',
    theme: 2,
    map: [
      _full,
      for (var i = 0; i < 10; i++) _empty,
      '#.P..........................D.#',
      '######ccccccccc...cccccccccc####',
      '######......................####',
      '######......................####',
    ],
  ),

  // 10 ── Walls closing in.
  LevelDef(
    title: 'Platzangst',
    subtitle: 'Lass dir ruhig Zeit.',
    theme: 3,
    map: [
      _full,
      for (var i = 0; i < 9; i++) '#ww............................#',
      '#ww...........##...............#',
      '#ww.P...^^....##.............D.#',
      '####################...#########',
      '####################...#########',
      '####################...#########',
    ],
    legend: {'w': const TileSpec(TileKind.solid)},
    traps: [
      Trap(const AfterTime(1.2), [
        const MovePath('w', [Waypoint(13, 0, 2.6), Waypoint(28, 0, 5)]),
      ]),
    ],
  ),

  // 11 ── A door you should not trust.
  LevelDef(
    title: 'Vertrauensfrage',
    subtitle: 'Diese Tür ist echt.',
    theme: 4,
    map: [
      _full,
      for (var i = 0; i < 10; i++) _empty,
      '#.P...........F..........BB..D.#',
      '####################aaa#########',
      '####################aaa#########',
      '####################aaa#########',
    ],
    legend: {
      'a': const TileSpec(TileKind.solid),
      'B': const TileSpec(TileKind.spikeUp, hidden: true),
    },
    traps: [
      Trap(const PlayerPast(17.5), [const Fall('a')]),
      Trap(const PlayerPast(23.6), [const Show('B')]),
    ],
  ),

  // 12 ── The finale: everything at once.
  LevelDef(
    title: 'Das Finale',
    subtitle: 'Letztes Level. Versprochen.',
    theme: 5,
    map: [
      _full,
      _empty,
      _empty,
      _empty,
      _empty,
      _empty,
      '#.............#####............#',
      _empty,
      '#........###...................#',
      _empty,
      '#...###........................#',
      '#.P......^^...AA..........D....#',
      _full,
      _full,
      _full,
    ],
    legend: {'A': const TileSpec(TileKind.spikeUp, hidden: true)},
    traps: [
      Trap(const PlayerPast(22), [
        MoveTo('D', -23, 0, 25),
        const Show('A'),
      ], id: 'back'),
      Trap(const PlayerBefore(8), [
        MoveTo('D', -10, -6, 18),
        const SetReversed(true),
      ], requires: 'back'),
    ],
  ),
];
