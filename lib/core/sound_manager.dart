part of '../main.dart';

class SoundManager {
  static final SoundManager _i = SoundManager._();
  factory SoundManager() => _i;
  SoundManager._();

  AudioPlayer? _bgm;
  bool _ready = false;
  int _shootTick = 0;

  Future<void> init() async {
    try {
      _bgm = AudioPlayer();
      _ready = true;
    } catch (_) {}
  }

  Future<void> playBgm(GameSettings s) async {
    if (!_ready || !s.musicEnabled) return;
    try {
      await _bgm?.setReleaseMode(ReleaseMode.loop);
      await _bgm?.setVolume(s.volume * 0.35);
      await _bgm?.play(AssetSource('sounds/bgm.mp3'));
    } catch (_) {}
  }

  Future<void> stopBgm() async {
    try { await _bgm?.stop(); } catch (_) {}
  }

  Future<void> pauseBgm() async {
    try { await _bgm?.pause(); } catch (_) {}
  }

  Future<void> resumeBgm(GameSettings s) async {
    if (!s.musicEnabled) return;
    try { await _bgm?.resume(); } catch (_) {}
  }

  void _play(String asset, double vol) {
    if (!_ready) return;
    try {
      final p = AudioPlayer();
      p.setVolume(vol);
      p.play(AssetSource(asset));
      p.onPlayerComplete.listen((_) => p.dispose());
    } catch (_) {}
  }

  void shoot(GameSettings s) {
    if (!s.soundEnabled) return;
    _shootTick++;
    if (_shootTick % 3 != 0) return; // throttle
    _play('sounds/shoot.wav', s.volume * 0.55);
  }

  void explosion(GameSettings s) {
    if (!s.soundEnabled) return;
    _play('sounds/explosion.wav', s.volume * 0.8);
  }

  void powerUp(GameSettings s) {
    if (!s.soundEnabled) return;
    _play('sounds/powerup.wav', s.volume);
  }

  void bomb(GameSettings s) {
    if (!s.soundEnabled) return;
    _play('sounds/bomb.wav', s.volume);
  }

  void gameOver(GameSettings s) {
    if (!s.soundEnabled) return;
    _play('sounds/gameover.wav', s.volume);
  }

  void vibrate(GameSettings s, {bool heavy = false}) {
    if (!s.vibrationEnabled) return;
    try {
      heavy
          ? HapticFeedback.heavyImpact()
          : HapticFeedback.mediumImpact();
    } catch (_) {}
  }
}

// ══════════════════════════════════════════════════════════════
// DATA MODELS
// ══════════════════════════════════════════════════════════════

