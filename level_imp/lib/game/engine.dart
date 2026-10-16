import 'dart:math' as math;
import 'dart:ui' show Rect, Offset;

/// Physics constants in tile units (1 tile = 1.0 world unit).
class Physics {
  static const double gravity = 45;
  static const double jumpVelocity = 15;
  static const double runSpeed = 7;
  static const double groundAccel = 70;
  static const double airAccel = 50;
  static const double maxFall = 22;
  static const double shortHopGravityFactor = 2.2;
  static const double coyoteTime = 0.1;
  static const double jumpBufferTime = 0.12;
  static const double crumbleDelay = 0.3;
  static const double stepDt = 1 / 120;
}

enum TileKind {
  solid,
  crumble,
  spikeUp,
  spikeDown,
  spikeLeft,
  spikeRight,
  saw,
  door,
  hangingDoor,
  fakeDoor,
}

class TileSpec {
  final TileKind kind;
  final bool hidden;

  /// Draws a faint outline while hidden, so attentive players get a hint.
  final bool hint;

  const TileSpec(this.kind, {this.hidden = false, this.hint = false});
}

// ---------------------------------------------------------------------------
// Trap scripting: conditions and actions.

abstract class Cond {
  const Cond();
  bool test(World w);
}

class PlayerPast extends Cond {
  final double x;
  const PlayerPast(this.x);
  @override
  bool test(World w) => w.player.x > x;
}

class PlayerBefore extends Cond {
  final double x;
  const PlayerBefore(this.x);
  @override
  bool test(World w) => w.player.x < x;
}

class PlayerIn extends Cond {
  final Rect zone;
  const PlayerIn(this.zone);
  @override
  bool test(World w) => _overlaps(w.player.rect, zone);
}

class AfterTime extends Cond {
  final double seconds;
  const AfterTime(this.seconds);
  @override
  bool test(World w) => w.time >= seconds;
}

abstract class Act {
  const Act();
  void run(World w);
}

class Show extends Act {
  final String group;
  const Show(this.group);
  @override
  void run(World w) {
    for (final e in w.groupOf(group)) {
      e.active = true;
      e.appear = 0;
      if (e.isSolid) w._pushPlayerOutOf(e);
    }
  }
}

class Hide extends Act {
  final String group;
  const Hide(this.group);
  @override
  void run(World w) {
    for (final e in w.groupOf(group)) {
      e.active = false;
    }
  }
}

class Fall extends Act {
  final String group;
  const Fall(this.group);
  @override
  void run(World w) {
    for (final e in w.groupOf(group)) {
      e.falling = true;
      e.path = null;
    }
  }
}

class Waypoint {
  /// Offset relative to the entity's original map position.
  final double dx, dy;
  final double speed;
  final double wait;
  const Waypoint(this.dx, this.dy, this.speed, {this.wait = 0});
}

/// Moves a group along waypoints (offsets from the original map position).
class MovePath extends Act {
  final String group;
  final List<Waypoint> points;
  final bool loop;
  const MovePath(this.group, this.points, {this.loop = false});

  @override
  void run(World w) {
    for (final e in w.groupOf(group)) {
      e.path = points;
      e.pathLoop = loop;
      e.pathIndex = 0;
      e.waitLeft = 0;
      e.falling = false;
    }
  }
}

class MoveTo extends MovePath {
  MoveTo(String group, double dx, double dy, double speed)
    : super(group, [Waypoint(dx, dy, speed)]);
}

class SetReversed extends Act {
  final bool reversed;
  const SetReversed(this.reversed);
  @override
  void run(World w) {
    w.reversed = reversed;
    w.flash = 1;
  }
}

class SetGravity extends Act {
  final int dir;
  const SetGravity(this.dir);
  @override
  void run(World w) {
    w.gravityDir = dir;
    w.player.grounded = false;
    w.player.ground = null;
    w.flash = 1;
  }
}

class Trap {
  final String? id;
  final String? requires;
  final Cond when;
  final List<Act> then;
  final double delay;
  const Trap(this.when, this.then, {this.id, this.requires, this.delay = 0});
}

class LevelDef {
  final String title;
  final String subtitle;
  final List<String> map;
  final Map<String, TileSpec> legend;
  final List<Trap> traps;
  final bool reversed;
  final int theme;

  const LevelDef({
    required this.title,
    required this.subtitle,
    required this.map,
    this.legend = const {},
    this.traps = const [],
    this.reversed = false,
    this.theme = 0,
  });

  int get cols => map.first.length;
  int get rows => map.length;
}

const Map<String, TileSpec> defaultLegend = {
  '#': TileSpec(TileKind.solid),
  'c': TileSpec(TileKind.crumble),
  '^': TileSpec(TileKind.spikeUp),
  'v': TileSpec(TileKind.spikeDown),
  '<': TileSpec(TileKind.spikeLeft),
  '>': TileSpec(TileKind.spikeRight),
  'O': TileSpec(TileKind.saw),
  'D': TileSpec(TileKind.door),
  'U': TileSpec(TileKind.hangingDoor),
  'F': TileSpec(TileKind.fakeDoor),
};

// ---------------------------------------------------------------------------
// Runtime objects.

class Entity {
  final TileKind kind;
  final String group;
  final double baseX, baseY;
  double x, y;
  final double w, h;
  double prevX, prevY;
  bool active;
  final bool hint;

  /// 0..1 pop-in animation progress.
  double appear = 1;
  bool falling = false;
  double vy = 0;
  double crumbleTimer = -1;
  double spin = 0;

  List<Waypoint>? path;
  bool pathLoop = false;
  int pathIndex = 0;
  double waitLeft = 0;

  Entity({
    required this.kind,
    required this.group,
    required this.x,
    required this.y,
    required this.w,
    required this.h,
    required this.active,
    this.hint = false,
  }) : baseX = x,
       baseY = y,
       prevX = x,
       prevY = y;

  bool get isSolid => kind == TileKind.solid || kind == TileKind.crumble;
  bool get isDoor => kind == TileKind.door || kind == TileKind.hangingDoor;
  Rect get rect => Rect.fromLTWH(x, y, w, h);
  double get dx => x - prevX;
  double get dy => y - prevY;

  /// The area that kills the player, or null for harmless entities.
  Rect? get hitbox {
    switch (kind) {
      case TileKind.spikeUp:
        return Rect.fromLTRB(x + 0.15, y + 0.45, x + w - 0.15, y + h);
      case TileKind.spikeDown:
        return Rect.fromLTRB(x + 0.15, y, x + w - 0.15, y + 0.55);
      case TileKind.spikeLeft:
        return Rect.fromLTRB(x + 0.45, y + 0.15, x + w, y + h - 0.15);
      case TileKind.spikeRight:
        return Rect.fromLTRB(x, y + 0.15, x + 0.55, y + h - 0.15);
      case TileKind.fakeDoor:
        return Rect.fromLTRB(x + 0.2, y + 0.2, x + w - 0.2, y + h);
      default:
        return null;
    }
  }
}

class Player {
  static const double w = 0.7;
  static const double h = 0.9;
  double x, y;
  double vx = 0, vy = 0;
  bool grounded = false;
  Entity? ground;
  double coyote = 0;
  double jumpBuffer = 0;
  int facing = 1;
  double walkAnim = 0;

  Player(this.x, this.y);

  Rect get rect => Rect.fromLTWH(x, y, w, h);
  Offset get center => Offset(x + w / 2, y + h / 2);
}

class InputState {
  bool left = false;
  bool right = false;
  bool jump = false;
}

class Particle {
  double x, y, vx, vy, life, size;
  Particle(this.x, this.y, this.vx, this.vy, this.life, this.size);
}

enum WorldStatus { playing, dying, won }

bool _overlaps(Rect a, Rect b, [double eps = 1e-6]) =>
    a.left < b.right - eps &&
    a.right > b.left + eps &&
    a.top < b.bottom - eps &&
    a.bottom > b.top + eps;

/// Complete simulation of one level attempt. Rebuild it to restart a level.
class World {
  final LevelDef def;
  final List<Entity> entities = [];
  late final Player player;
  final InputState input = InputState();
  final List<Particle> particles = [];
  final math.Random _rng = math.Random(7);

  double time = 0;
  bool reversed;
  int gravityDir = 1;
  WorldStatus status = WorldStatus.playing;
  double statusTime = 0;
  double shake = 0;

  /// Brief screen flash when a rule (controls, gravity) changes.
  double flash = 0;

  final Set<int> _fired = {};
  final Set<String> _firedIds = {};
  final List<(double, Trap)> _pending = [];
  bool _jumpWasHeld = false;

  World(this.def) : reversed = def.reversed {
    final legend = {...defaultLegend, ...def.legend};
    double? px, py;
    for (var r = 0; r < def.rows; r++) {
      final line = def.map[r];
      for (var c = 0; c < line.length; c++) {
        final ch = line[c];
        if (ch == '.' || ch == ' ') continue;
        if (ch == 'P') {
          px = c + (1 - Player.w) / 2;
          py = r + 1 - Player.h;
          continue;
        }
        final spec = legend[ch];
        if (spec == null) {
          throw ArgumentError('Unknown tile "$ch" in "${def.title}"');
        }
        entities.add(_makeEntity(spec, ch, c.toDouble(), r.toDouble()));
      }
    }
    if (px == null || py == null) {
      throw ArgumentError('Level "${def.title}" has no player start');
    }
    player = Player(px, py);
  }

  static Entity _makeEntity(TileSpec spec, String ch, double c, double r) {
    double x = c, y = r, w = 1, h = 1;
    switch (spec.kind) {
      case TileKind.door:
      case TileKind.fakeDoor:
        x = c + 0.1;
        w = 0.8;
        h = 1.6;
        y = r + 1 - h;
      case TileKind.hangingDoor:
        x = c + 0.1;
        w = 0.8;
        h = 1.6;
      default:
        break;
    }
    return Entity(
      kind: spec.kind,
      group: ch,
      x: x,
      y: y,
      w: w,
      h: h,
      active: !spec.hidden,
      hint: spec.hint,
    );
  }

  int get cols => def.cols;
  int get rows => def.rows;

  Iterable<Entity> groupOf(String g) => entities.where((e) => e.group == g);

  Iterable<Entity> get _solids => entities.where((e) => e.active && e.isSolid);

  void step([double dt = Physics.stepDt]) {
    time += dt;
    shake = math.max(0, shake - dt * 1.5);
    flash = math.max(0, flash - dt * 3);
    _updateParticles(dt);
    for (final e in entities) {
      if (e.appear < 1) e.appear = math.min(1, e.appear + dt / 0.12);
      if (e.kind == TileKind.saw) e.spin += dt * 9;
    }

    if (status != WorldStatus.playing) {
      statusTime += dt;
      return;
    }

    _runTraps(dt);
    _updateEntities(dt);
    _carryAndPush();
    if (status != WorldStatus.playing) return;
    _updatePlayer(dt);
    _checkOutcome();
  }

  void _runTraps(double dt) {
    for (var i = 0; i < def.traps.length; i++) {
      if (_fired.contains(i)) continue;
      final trap = def.traps[i];
      if (trap.requires != null && !_firedIds.contains(trap.requires)) {
        continue;
      }
      if (!trap.when.test(this)) continue;
      _fired.add(i);
      if (trap.id != null) _firedIds.add(trap.id!);
      if (trap.delay > 0) {
        _pending.add((trap.delay, trap));
      } else {
        for (final a in trap.then) {
          a.run(this);
        }
      }
    }
    for (var i = _pending.length - 1; i >= 0; i--) {
      final (left, trap) = _pending[i];
      if (left - dt <= 0) {
        _pending.removeAt(i);
        for (final a in trap.then) {
          a.run(this);
        }
      } else {
        _pending[i] = (left - dt, trap);
      }
    }
  }

  void _updateEntities(double dt) {
    for (final e in entities) {
      e.prevX = e.x;
      e.prevY = e.y;

      if (e.crumbleTimer > 0) {
        e.crumbleTimer -= dt;
        if (e.crumbleTimer <= 0) e.falling = true;
      }

      if (e.falling) {
        e.vy = math.min(e.vy + Physics.gravity * dt, 30);
        e.y += e.vy * dt;
        if (e.y > rows + 4) e.active = false;
        continue;
      }

      final path = e.path;
      if (path == null) continue;
      if (e.waitLeft > 0) {
        e.waitLeft -= dt;
        if (e.waitLeft <= 0) _advancePath(e);
        continue;
      }
      final wp = path[e.pathIndex];
      final tx = e.baseX + wp.dx, ty = e.baseY + wp.dy;
      final ddx = tx - e.x, ddy = ty - e.y;
      final dist = math.sqrt(ddx * ddx + ddy * ddy);
      final stepLen = wp.speed * dt;
      if (dist <= stepLen) {
        e.x = tx;
        e.y = ty;
        if (wp.wait > 0) {
          e.waitLeft = wp.wait;
        } else {
          _advancePath(e);
        }
      } else {
        e.x += ddx / dist * stepLen;
        e.y += ddy / dist * stepLen;
      }
    }
  }

  void _advancePath(Entity e) {
    e.pathIndex++;
    if (e.pathIndex >= e.path!.length) {
      if (e.pathLoop) {
        e.pathIndex = 0;
      } else {
        e.path = null;
      }
    }
  }

  /// Carries the player along with the platform they stand on and pushes
  /// them out of moving solids. Being pushed into a wall squashes them.
  void _carryAndPush() {
    final g = player.ground;
    if (player.grounded && g != null && g.active) {
      player.x += g.dx;
      // Only follow a platform that moves against gravity (lifts the
      // player). Platforms dropping away are left to normal gravity, so the
      // player never sinks into neighbouring tiles.
      if (g.dy * gravityDir < 0) player.y += g.dy;
    }
    var pushed = false;
    for (final e in _solids) {
      if (e.dx == 0 && e.dy == 0) continue;
      if (!_overlaps(player.rect, e.rect)) continue;
      pushed = true;
      if (e.dx.abs() >= e.dy.abs()) {
        player.x = e.dx > 0 ? e.rect.right : e.rect.left - Player.w;
      } else if (e.dy > 0) {
        player.y = e.rect.bottom;
      } else {
        player.y = e.rect.top - Player.h;
      }
    }
    if (pushed && _solids.any((e) => _overlaps(player.rect, e.rect))) die();
  }

  /// Used when a solid appears on top of the player: move the player to the
  /// nearest free side instead of killing them.
  void _pushPlayerOutOf(Entity e) {
    final p = player.rect;
    final r = e.rect;
    if (!_overlaps(p, r)) return;
    final candidates = <(double, void Function())>[
      (p.bottom - r.top, () => player.y = r.top - Player.h),
      (r.bottom - p.top, () => player.y = r.bottom),
      (p.right - r.left, () => player.x = r.left - Player.w),
      (r.right - p.left, () => player.x = r.right),
    ]..sort((a, b) => a.$1.compareTo(b.$1));
    candidates.first.$2();
    final landedOnTop = (player.y + Player.h - r.top).abs() < 1e-6;
    final landedBelow = (player.y - r.bottom).abs() < 1e-6;
    if ((landedOnTop && gravityDir > 0) || (landedBelow && gravityDir < 0)) {
      player.vy = 0;
      player.grounded = true;
      player.ground = e;
    } else if (landedBelow || landedOnTop) {
      player.vy = 0; // bonk
    }
  }

  void _updatePlayer(double dt) {
    final p = player;
    final g = gravityDir.toDouble();

    var dir = (input.right ? 1 : 0) - (input.left ? 1 : 0);
    if (reversed) dir = -dir;
    final target = dir * Physics.runSpeed;
    final accel = (p.grounded ? Physics.groundAccel : Physics.airAccel) * dt;
    if ((target - p.vx).abs() <= accel) {
      p.vx = target;
    } else {
      p.vx += (target - p.vx).sign * accel;
    }
    if (dir != 0) p.facing = dir;
    if (p.grounded && p.vx.abs() > 0.1) {
      p.walkAnim += dt * p.vx.abs() * 2.2;
    }

    final jumpPressed = input.jump && !_jumpWasHeld;
    _jumpWasHeld = input.jump;
    p.jumpBuffer = jumpPressed ? Physics.jumpBufferTime : p.jumpBuffer - dt;
    p.coyote = p.grounded ? Physics.coyoteTime : p.coyote - dt;
    if (p.jumpBuffer > 0 && p.coyote > 0) {
      p.vy = -Physics.jumpVelocity * g;
      p.jumpBuffer = 0;
      p.coyote = 0;
      p.grounded = false;
      p.ground = null;
    }

    var grav = Physics.gravity;
    if (p.vy * g < 0 && !input.jump) grav *= Physics.shortHopGravityFactor;
    p.vy += grav * g * dt;
    if (p.vy * g > Physics.maxFall) p.vy = Physics.maxFall * g;

    // Horizontal movement.
    p.x += p.vx * dt;
    for (final e in _solids) {
      if (!_overlaps(p.rect, e.rect)) continue;
      if (p.vx > 0) {
        p.x = e.rect.left - Player.w;
      } else if (p.vx < 0) {
        p.x = e.rect.right;
      }
      p.vx = 0;
    }
    p.x = p.x.clamp(0, cols - Player.w);

    // Vertical movement.
    p.y += p.vy * dt;
    p.grounded = false;
    p.ground = null;
    for (final e in _solids) {
      if (!_overlaps(p.rect, e.rect)) continue;
      if (p.vy > 0) {
        p.y = e.rect.top - Player.h;
        if (g > 0) {
          p.grounded = true;
          p.ground = e;
        }
      } else if (p.vy < 0) {
        p.y = e.rect.bottom;
        if (g < 0) {
          p.grounded = true;
          p.ground = e;
        }
      }
      p.vy = 0;
    }

    final ground = p.ground;
    if (ground != null &&
        ground.kind == TileKind.crumble &&
        ground.crumbleTimer < 0 &&
        !ground.falling) {
      ground.crumbleTimer = Physics.crumbleDelay;
    }
  }

  void _checkOutcome() {
    final pr = player.rect;

    // Squashed between solids?
    for (final e in _solids) {
      if (_overlaps(pr, e.rect, 0.08)) return die();
    }
    if (player.y > rows + 1 || player.y < -2) return die();

    for (final e in entities) {
      if (!e.active || e.appear < 0.5) continue;
      if (e.kind == TileKind.saw) {
        final c = Offset(e.x + e.w / 2, e.y + e.h / 2);
        final nx = c.dx.clamp(pr.left, pr.right);
        final ny = c.dy.clamp(pr.top, pr.bottom);
        if ((Offset(nx, ny) - c).distance < 0.4) return die();
        continue;
      }
      final hb = e.hitbox;
      if (hb != null && _overlaps(pr, hb)) return die();
    }

    for (final e in entities) {
      if (!e.active || !e.isDoor) continue;
      final inner = e.rect.deflate(0.2);
      if (_overlaps(pr, inner)) {
        status = WorldStatus.won;
        statusTime = 0;
        return;
      }
    }
  }

  void die() {
    if (status != WorldStatus.playing) return;
    status = WorldStatus.dying;
    statusTime = 0;
    shake = 0.35;
    final c = player.center;
    for (var i = 0; i < 26; i++) {
      final a = _rng.nextDouble() * math.pi * 2;
      final s = 3 + _rng.nextDouble() * 9;
      particles.add(
        Particle(
          c.dx,
          c.dy,
          math.cos(a) * s,
          math.sin(a) * s - 4,
          0.6 + _rng.nextDouble() * 0.5,
          0.12 + _rng.nextDouble() * 0.16,
        ),
      );
    }
  }

  void _updateParticles(double dt) {
    for (final p in particles) {
      p.vy += 30 * dt;
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      p.life -= dt;
    }
    particles.removeWhere((p) => p.life <= 0);
  }
}
