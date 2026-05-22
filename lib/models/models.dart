part of '../main.dart';

class GameSettings {
  bool soundEnabled;
  bool musicEnabled;
  bool vibrationEnabled;
  double volume;

  GameSettings({
    this.soundEnabled = true,
    this.musicEnabled = true,
    this.vibrationEnabled = true,
    this.volume = 0.8,
  });

  GameSettings copyWith({
    bool? soundEnabled,
    bool? musicEnabled,
    bool? vibrationEnabled,
    double? volume,
  }) =>
      GameSettings(
        soundEnabled: soundEnabled ?? this.soundEnabled,
        musicEnabled: musicEnabled ?? this.musicEnabled,
        vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
        volume: volume ?? this.volume,
      );
}

// ══════════════════════════════════════════════════════════════
// LEVEL CONFIG  (difficulty per level)
// ══════════════════════════════════════════════════════════════

class LevelConfig {
  final int level;
  final String name;
  final String subtitle;
  final Color color;
  final double baseSpawnInterval; // initial enemy spawn gap (seconds)
  final double speedMultiplier;   // enemy speed ×
  final int hpBonus;              // extra HP on all enemies
  final int lives;                // player lives
  final bool unlocked;

  const LevelConfig({
    required this.level,
    required this.name,
    required this.subtitle,
    required this.color,
    required this.baseSpawnInterval,
    required this.speedMultiplier,
    required this.hpBonus,
    required this.lives,
    required this.unlocked,
  });

  static const all = [
    LevelConfig(
      level: 1, name: 'ROOKIE',  subtitle: 'Learn the ropes',
      color: Colors.greenAccent,  baseSpawnInterval: 1.5,
      speedMultiplier: 1.0, hpBonus: 0, lives: 3, unlocked: true,
    ),
    LevelConfig(
      level: 2, name: 'PILOT',   subtitle: 'Tougher enemies',
      color: Colors.cyanAccent,   baseSpawnInterval: 1.5,
      speedMultiplier: 1.0, hpBonus: 2, lives: 3, unlocked: true,
    ),
    LevelConfig(
      level: 3, name: 'ACE',     subtitle: 'Heavy armor',
      color: Colors.amberAccent,  baseSpawnInterval: 1.4,
      speedMultiplier: 1.0, hpBonus: 5, lives: 3, unlocked: true,
    ),
    LevelConfig(
      level: 4, name: 'LEGEND',  subtitle: 'Maximum pressure',
      color: Colors.redAccent,    baseSpawnInterval: 1.3,
      speedMultiplier: 1.0, hpBonus: 8, lives: 3, unlocked: true,
    ),
    LevelConfig(
      level: 5, name: 'DEITY',   subtitle: 'God-mode chaos',
      color: Colors.purpleAccent, baseSpawnInterval: 1.2,
      speedMultiplier: 1.0, hpBonus: 12, lives: 3, unlocked: true,
    ),
  ];
}

// ══════════════════════════════════════════════════════════════
// SOUND MANAGER  (singleton, all calls wrapped in try/catch)
// ══════════════════════════════════════════════════════════════

class Vec2 { double x, y; Vec2(this.x, this.y); }

class Bullet {
  Vec2 pos; double vx; bool active = true;
  static const double speed = 600;
  Bullet(double x, double y, {this.vx = 0}) : pos = Vec2(x, y);
}

class Enemy {
  Vec2 pos; double speed; double size; Color color; int hp; bool active = true;
  Enemy({required double x, required double y, required this.speed,
    required this.size, required this.color, required this.hp})
      : pos = Vec2(x, y);
}

class Particle {
  Vec2 pos, vel; double life = 1.0; Color color; double size;
  Particle({required this.pos, required this.vel,
    required this.color, required this.size});
}

class StarBg {
  double x, y, speed, size, opacity;
  StarBg(this.x, this.y, this.speed, this.size, this.opacity);
}

enum PowerUpType { doubleShot, tripleShot, bomb }

class PowerUp {
  Vec2 pos; PowerUpType type; bool active = true;
  double animTimer = 0;
  static const double speed = 130;

  PowerUp({required double x, required double y, required this.type})
      : pos = Vec2(x, y);

  Color get color => const {
    PowerUpType.doubleShot: Colors.greenAccent,
    PowerUpType.tripleShot: Colors.amberAccent,
    PowerUpType.bomb:       Colors.redAccent,
  }[type]!;

  String get label => const {
    PowerUpType.doubleShot: '2x',
    PowerUpType.tripleShot: '3x',
    PowerUpType.bomb:       '💣',
  }[type]!;
}

class ActivePowerUp {
  PowerUpType type; double duration;
  ActivePowerUp({required this.type, required this.duration});
}

// ══════════════════════════════════════════════════════════════
// SHARED PAINTERS  (stars, corners, hex-logo, grid)
// ══════════════════════════════════════════════════════════════

