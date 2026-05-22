part of '../main.dart';

class GameScreen extends StatefulWidget {
  final LevelConfig levelCfg;
  final GameSettings settings;
  const GameScreen({super.key, required this.levelCfg, required this.settings});
  @override State<GameScreen> createState() => _GameScreenState();
}

enum GState { playing, paused, gameOver }

class _GameScreenState extends State<GameScreen> {
  late double _w, _h;
  final _snd = SoundManager();

  Timer? _loop;
  DateTime _lastTime = DateTime.now();
  GState _gState = GState.playing;

  int _score = 0, _lives = 3, _wave = 1;

  Vec2 _playerPos = Vec2(0, 0);
  static const double _pSize = 24.0;
  double _playerTarget = 0, _shootCd = 0;
  static const double _shootInterval = 0.18;

  final List<Bullet>   _bullets  = [];
  final List<Enemy>    _enemies  = [];
  final List<Particle> _particles = [];
  final List<StarBg>   _stars    = [];
  final List<PowerUp>  _powerUps = [];

  ActivePowerUp? _activePU;
  int _bombCount = 0;
  String _toast = '';
  double _toastTimer = 0;

  // Difficulty from level config
  late double _spawnInterval;
  double _spawnTimer  = 0;
  double _puSpawnTimer = 0;
  late double _puSpawnInterval;

  // Difficulty scaler (in-game wave)
  double get _speedMult => widget.levelCfg.speedMultiplier * (1.0 + (_wave - 1) * 0.03);
  int    get _hpBonus   => widget.levelCfg.hpBonus + (_wave ~/ 3);

  // Level banner
  bool _showBanner = true;
  double _bannerTimer = 2.5;

  final _rng = Random();

  @override
  void initState() {
    super.initState();
    _lives = widget.levelCfg.lives;
    _spawnInterval = widget.levelCfg.baseSpawnInterval;
    _puSpawnInterval = max(3.5, 10.0 - (widget.levelCfg.level * 1.3));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _w = MediaQuery.of(context).size.width;
      _h = MediaQuery.of(context).size.height;
      _buildStars();
      _playerPos = Vec2(_w / 2, _h - 100);
      _playerTarget = _playerPos.x;
      _lastTime = DateTime.now();
      _loop = Timer.periodic(const Duration(milliseconds: 16), (_) => _tick());
      _snd.playBgm(widget.settings);
    });
  }

  void _buildStars() {
    for (int i = 0; i < 80; i++) {
      _stars.add(StarBg(
          _rng.nextDouble() * _w, _rng.nextDouble() * _h,
          22 + _rng.nextDouble() * 75, 0.5 + _rng.nextDouble() * 2.0, 0.3 + _rng.nextDouble() * 0.7));
    }
  }

  void _stopLoop() { _loop?.cancel(); _loop = null; }

  void _tick() {
    final now = DateTime.now();
    final dt = now.difference(_lastTime).inMicroseconds / 1e6;
    _lastTime = now;
    if (dt > 0.1 || _gState != GState.playing) return;
    setState(() {
      _updateStars(dt);
      _updatePlayer(dt);
      _updateBullets(dt);
      _updateEnemies(dt);
      _updateParticles(dt);
      _updatePowerUps(dt);
      _checkCollisions();
      _spawnEnemies(dt);
      _spawnPowerUp(dt);
      _updateWave();
      _updateToast(dt);
      _updateBanner(dt);
    });
  }

  // ── UPDATE ──────────────────────────────

  void _updateStars(double dt) {
    for (final s in _stars) { s.y += s.speed * dt; if (s.y > _h) { s.y = 0; s.x = _rng.nextDouble() * _w; } }
  }

  void _updatePlayer(double dt) {
    _playerPos.x += (_playerTarget - _playerPos.x) * min(1.0, dt * 13);
    _playerPos.x = _playerPos.x.clamp(_pSize, _w - _pSize);
    _shootCd -= dt;
    if (_shootCd <= 0) { _shootCd = _shootInterval; _fire(); }
    if (_activePU != null) { _activePU!.duration -= dt; if (_activePU!.duration <= 0) _activePU = null; }
  }

  void _fire() {
    final cx = _playerPos.x, cy = _playerPos.y - _pSize;
    final type = _activePU?.type;
    if (type == PowerUpType.tripleShot) {
      _bullets.addAll([Bullet(cx, cy, vx: -130), Bullet(cx, cy), Bullet(cx, cy, vx: 130)]);
    } else if (type == PowerUpType.doubleShot) {
      _bullets.addAll([Bullet(cx - 10, cy), Bullet(cx + 10, cy)]);
    } else {
      _bullets.add(Bullet(cx, cy));
    }
    _snd.shoot(widget.settings);
  }

  void _updateBullets(double dt) {
    for (final b in _bullets) {
      b.pos.y -= Bullet.speed * dt; b.pos.x += b.vx * dt;
      if (b.pos.y < -10 || b.pos.x < -10 || b.pos.x > _w + 10) b.active = false;
    }
    _bullets.removeWhere((b) => !b.active);
  }

  void _updateEnemies(double dt) {
    for (final e in _enemies) {
      e.pos.y += e.speed * dt;
      e.pos.x += sin(e.pos.y * 0.03) * 1.5;
      if (e.pos.y > _h + 20) {
        e.active = false; _lives--;
        _snd.vibrate(widget.settings, heavy: true);
        if (_lives <= 0) _triggerGameOver();
      }
    }
    _enemies.removeWhere((e) => !e.active);
  }

  void _updateParticles(double dt) {
    for (final p in _particles) { p.pos.x += p.vel.x * dt; p.pos.y += p.vel.y * dt; p.life -= dt * 2.0; }
    _particles.removeWhere((p) => p.life <= 0);
  }

  void _updatePowerUps(double dt) {
    for (final p in _powerUps) { p.pos.y += PowerUp.speed * dt; p.animTimer += dt; if (p.pos.y > _h + 30) p.active = false; }
    _powerUps.removeWhere((p) => !p.active);
  }

  void _updateToast(double dt) {
    if (_toastTimer > 0) { _toastTimer -= dt; if (_toastTimer <= 0) _toast = ''; }
  }

  void _updateBanner(double dt) {
    if (_showBanner) { _bannerTimer -= dt; if (_bannerTimer <= 0) _showBanner = false; }
  }

  void _checkCollisions() {
    for (final b in _bullets) {
      if (!b.active) continue;
      for (final e in _enemies) {
        if (!e.active) continue;
        final dx = b.pos.x - e.pos.x, dy = b.pos.y - e.pos.y;
        if (sqrt(dx * dx + dy * dy) < e.size + 5) {
          b.active = false; e.hp--;
          _spawnHit(e.pos.x, e.pos.y, e.color);
          if (e.hp <= 0) {
            e.active = false;
            _score += e.size > 22 ? 50 : (e.size > 14 ? 20 : 10);
            _spawnExplosion(e.pos.x, e.pos.y, e.color);
            _snd.explosion(widget.settings);
            _snd.vibrate(widget.settings);
          }
          break;
        }
      }
    }
    for (final e in _enemies) {
      if (!e.active) continue;
      final dx = _playerPos.x - e.pos.x, dy = _playerPos.y - e.pos.y;
      if (sqrt(dx * dx + dy * dy) < e.size + _pSize * 0.7) {
        e.active = false; _lives--;
        _spawnExplosion(_playerPos.x, _playerPos.y, Colors.cyanAccent);
        _snd.explosion(widget.settings); _snd.vibrate(widget.settings, heavy: true);
        if (_lives <= 0) _triggerGameOver();
      }
    }
    for (final p in _powerUps) {
      if (!p.active) continue;
      final dx = _playerPos.x - p.pos.x, dy = _playerPos.y - p.pos.y;
      if (sqrt(dx * dx + dy * dy) < _pSize + 18) {
        p.active = false; _collectPU(p.type);
      }
    }
  }

  void _spawnEnemies(double dt) {
    _spawnTimer -= dt;
    if (_spawnTimer <= 0) {
      _spawnTimer = _spawnInterval;
      _spawnEnemy();
      // Higher waves spawn 2 enemies at once
      if (_wave >= 4) _spawnEnemy();
    }
  }

  void _spawnEnemy() {
    final roll = _rng.nextDouble();
    double size; Color color; int hp;

    if (roll < 0.5) {
      size = 12; color = Colors.redAccent;    hp = 1 + _hpBonus;
    } else if (roll < 0.8) {
      size = 18; color = Colors.orangeAccent; hp = 2 + _hpBonus;
    } else {
      size = 26; color = Colors.purpleAccent; hp = 4 + _hpBonus;
    }

    // Base speeds scaled down because enemies have high HP
    final baseSpeed = size > 22
        ? (35 + _rng.nextDouble() * 20)  // Big enemies: 35-55 speed
        : size > 14
        ? (55 + _rng.nextDouble() * 25)  // Med enemies: 55-80 speed
        : (85 + _rng.nextDouble() * 35); // Small enemies: 85-120 speed

    _enemies.add(Enemy(
      x: size + _rng.nextDouble() * (_w - size * 2),
      y: -size,
      speed: baseSpeed * _speedMult,
      size: size, color: color, hp: hp,
    ));
  }

  void _spawnPowerUp(double dt) {
    _puSpawnTimer -= dt;
    if (_puSpawnTimer <= 0) {
      _puSpawnTimer = _puSpawnInterval;
      final roll = _rng.nextDouble();
      _powerUps.add(PowerUp(
        x: 30 + _rng.nextDouble() * (_w - 60), y: -30,
        type: roll < 0.35 ? PowerUpType.doubleShot : roll < 0.65 ? PowerUpType.tripleShot : PowerUpType.bomb,
      ));
    }
  }

  void _spawnExplosion(double x, double y, Color c) {
    for (int i = 0; i < 18; i++) {
      final a = _rng.nextDouble() * pi * 2, spd = 60 + _rng.nextDouble() * 200;
      _particles.add(Particle(pos: Vec2(x, y), vel: Vec2(cos(a) * spd, sin(a) * spd), color: c, size: 2 + _rng.nextDouble() * 4));
    }
  }

  void _spawnHit(double x, double y, Color c) {
    for (int i = 0; i < 5; i++) {
      final a = _rng.nextDouble() * pi * 2, spd = 40 + _rng.nextDouble() * 90;
      _particles.add(Particle(pos: Vec2(x, y), vel: Vec2(cos(a) * spd, sin(a) * spd), color: c, size: 1 + _rng.nextDouble() * 2));
    }
  }

  void _collectPU(PowerUpType type) {
    _snd.powerUp(widget.settings);
    if (type == PowerUpType.bomb) {
      _bombCount++; _setToast('BOMB STORED!  Tap 💣 to use');
    } else {
      _activePU = ActivePowerUp(type: type, duration: 8.0);
      _setToast(type == PowerUpType.doubleShot ? '⚡ DOUBLE SHOT  (8s)' : '⚡ TRIPLE SHOT  (8s)');
    }
    _spawnExplosion(_playerPos.x, _playerPos.y - _pSize,
        type == PowerUpType.bomb ? Colors.redAccent : Colors.amberAccent);
  }

  void _useBomb() {
    if (_bombCount <= 0 || _gState != GState.playing) return;
    _bombCount--;
    for (final e in _enemies) {
      if (e.active) {
        _score += e.size > 22 ? 50 : (e.size > 14 ? 20 : 10);
        _spawnExplosion(e.pos.x, e.pos.y, e.color); e.active = false;
      }
    }
    for (int i = 0; i < 40; i++) {
      final a = _rng.nextDouble() * pi * 2, spd = 80 + _rng.nextDouble() * 300;
      _particles.add(Particle(pos: Vec2(_w / 2, _h / 2), vel: Vec2(cos(a) * spd, sin(a) * spd), color: Colors.orangeAccent, size: 3 + _rng.nextDouble() * 6));
    }
    _snd.bomb(widget.settings); _snd.vibrate(widget.settings, heavy: true);
    _setToast('💥 BOMB DETONATED!');
  }

  void _setToast(String msg) { _toast = msg; _toastTimer = 2.5; }

  void _updateWave() {
    final nw = (_score ~/ 300) + 1;
    if (nw != _wave) {
      _wave = nw;
      _spawnInterval = max(0.3, widget.levelCfg.baseSpawnInterval - (_wave - 1) * 0.06);
    }
  }

  void _triggerGameOver() {
    _stopLoop(); _snd.stopBgm(); _snd.gameOver(widget.settings);
    _gState = GState.gameOver;
  }

  void _togglePause() {
    if (_gState == GState.playing) {
      _stopLoop(); _snd.pauseBgm();
      setState(() => _gState = GState.paused);
    } else if (_gState == GState.paused) {
      _snd.resumeBgm(widget.settings);
      setState(() { _gState = GState.playing; _lastTime = DateTime.now(); });
      _loop = Timer.periodic(const Duration(milliseconds: 16), (_) => _tick());
    }
  }

  void _returnToMenu() {
    _stopLoop(); _snd.stopBgm();
    Navigator.of(context).pop(_score);
  }

  @override
  void dispose() { _stopLoop(); _snd.stopBgm(); super.dispose(); }

  // ── BUILD ───────────────────────────────

  @override
  Widget build(BuildContext context) {
    _w = MediaQuery.of(context).size.width;
    _h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF050A14),
      body: GestureDetector(
        onPanUpdate: (d) { if (_gState == GState.playing) _playerTarget = d.localPosition.dx; },
        onTapDown:   (d) { if (_gState == GState.playing) _playerTarget = d.localPosition.dx; },
        child: Stack(children: [
          CustomPaint(painter: _GamePainter(
            stars: _stars, bullets: _bullets, enemies: _enemies,
            particles: _particles, powerUps: _powerUps,
            playerPos: _playerPos, playerSize: _pSize,
            gState: _gState, activePU: _activePU,
          ), size: Size(_w, _h)),

          // HUD
          if (_gState == GState.playing || _gState == GState.paused) _buildHUD(),

          // Level banner
          if (_showBanner) _buildBanner(),

          // Toast
          if (_toast.isNotEmpty)
            Positioned(top: _h * 0.19, left: 0, right: 0,
                child: Center(child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.amberAccent.withOpacity(0.6))),
                  child: Text(_toast, style: const TextStyle(color: Colors.amberAccent, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1)),
                ))),

          // Pause overlay
          if (_gState == GState.paused) _buildPause(),

          // Game Over overlay
          if (_gState == GState.gameOver) _buildGameOver(),
        ]),
      ),
    );
  }

  Widget _buildBanner() {
    final cfg = widget.levelCfg;
    return Positioned(top: _h * 0.38, left: 0, right: 0,
      child: Center(child: AnimatedOpacity(
        opacity: _bannerTimer > 1.5 ? 1.0 : _bannerTimer / 1.5,
        duration: const Duration(milliseconds: 300),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(14),
              border: Border.all(color: cfg.color.withOpacity(0.7), width: 1.5),
              boxShadow: [BoxShadow(color: cfg.color.withOpacity(0.25), blurRadius: 20)]),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('LEVEL ${cfg.level}', style: TextStyle(color: cfg.color, fontSize: 12, letterSpacing: 4, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(cfg.name, style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 4,
                shadows: [Shadow(color: cfg.color.withOpacity(0.8), blurRadius: 16)])),
            const SizedBox(height: 4),
            Text(cfg.subtitle, style: const TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 1)),
          ]),
        ),
      )),
    );
  }

  Widget _buildHUD() {
    return SafeArea(child: Column(children: [
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          // Score + wave
          Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text('SCORE', style: _lbl), Text('$_score', style: _val),
            const SizedBox(height: 1),
            Text('WAVE $_wave', style: _lbl.copyWith(color: widget.levelCfg.color)),
          ]),
          // Pause btn
          GestureDetector(onTap: _togglePause, child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(_gState == GState.paused ? Icons.play_arrow : Icons.pause, color: Colors.white70, size: 22))),
          // Lives
          Column(crossAxisAlignment: CrossAxisAlignment.end, mainAxisSize: MainAxisSize.min, children: [
            Text('LIVES', style: _lbl),
            Row(children: List.generate(widget.levelCfg.lives, (i) => Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(Icons.favorite, size: 18, color: i < _lives ? Colors.redAccent : Colors.white12)))),
          ]),
        ]),
      ),
      // Power-up bar
      if (_gState == GState.playing)
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(children: [
          if (_activePU != null) _puBadge(),
          const Spacer(),
          if (_bombCount > 0)
            GestureDetector(onTap: _useBomb, child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(color: Colors.red.withOpacity(0.2), borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.redAccent, width: 1.5)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Text('💣', style: TextStyle(fontSize: 16)), const SizedBox(width: 4),
                  Text('x$_bombCount  TAP', style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                ]))),
        ])),
    ]));
  }

  Widget _puBadge() {
    final p = _activePU!; final c = p.type == PowerUpType.doubleShot ? Colors.greenAccent : Colors.amberAccent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: c.withOpacity(0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: c.withOpacity(0.6))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(p.type == PowerUpType.doubleShot ? '⚡ DOUBLE' : '⚡ TRIPLE',
            style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(width: 6),
        SizedBox(width: 40, height: 6, child: ClipRRect(borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(value: (p.duration / 8.0).clamp(0, 1), backgroundColor: Colors.white12, valueColor: AlwaysStoppedAnimation(c)))),
      ]),
    );
  }

  Widget _buildPause() => Center(
    child: ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: 300,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.cyanAccent.withOpacity(0.3), width: 1.5),
            boxShadow: [BoxShadow(color: Colors.cyanAccent.withOpacity(0.1), blurRadius: 40)],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.pause_circle_outline_rounded, color: Colors.cyanAccent, size: 48),
            const SizedBox(height: 16),
            const Text('PAUSED', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 6)),
            const SizedBox(height: 8),
            Text('WAVE $_wave  •  SCORE $_score', style: const TextStyle(color: Colors.cyanAccent, fontSize: 11, letterSpacing: 3, fontWeight: FontWeight.bold)),
            const SizedBox(height: 36),
            _btn('RESUME', Colors.cyanAccent, _togglePause),
            const SizedBox(height: 16),
            _btn('MAIN MENU', Colors.redAccent, _returnToMenu),
          ]),
        ),
      ),
    ),
  );

  Widget _buildGameOver() => Center(
    child: ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: 320,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.redAccent.withOpacity(0.4), width: 1.5),
            boxShadow: [BoxShadow(color: Colors.redAccent.withOpacity(0.15), blurRadius: 40)],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 56),
            const SizedBox(height: 16),
            const Text('GAME OVER', style: TextStyle(color: Colors.redAccent, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 6)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(color: widget.levelCfg.color.withOpacity(0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: widget.levelCfg.color.withOpacity(0.5))),
              child: Text('LEVEL  ${widget.levelCfg.name}', style: TextStyle(color: widget.levelCfg.color, fontSize: 12, letterSpacing: 4, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 24),
            Text('SCORE: $_score', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 2)),
            const SizedBox(height: 4),
            Text('WAVE: $_wave', style: const TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 3, fontWeight: FontWeight.bold)),
            const SizedBox(height: 36),
            _btn('PLAY AGAIN', Colors.cyanAccent, () {
              _stopLoop(); _snd.stopBgm();
              Navigator.of(context).pushReplacement(PageRouteBuilder(
                pageBuilder: (_, __, ___) => GameScreen(levelCfg: widget.levelCfg, settings: widget.settings),
                transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
                transitionDuration: const Duration(milliseconds: 400),
              ));
            }),
            const SizedBox(height: 16),
            _btn('MAIN MENU', Colors.white54, _returnToMenu),
          ]),
        ),
      ),
    ),
  );

  Widget _btn(String label, Color color, VoidCallback onTap) =>
      GestureDetector(
        onTap: () { HapticFeedback.mediumImpact(); onTap(); },
        child: Container(
          width: 220,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.6), width: 1.5),
            boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 12)],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 4, height: 16, color: color),
              const SizedBox(width: 12),
              Text(label, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 4)),
              const SizedBox(width: 12),
              Container(width: 4, height: 16, color: color),
            ],
          ),
        ),
      );

  TextStyle get _lbl => const TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w600);
  TextStyle get _val => const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1);
}

// ══════════════════════════════════════════════════════════════
// GAME PAINTER
// ══════════════════════════════════════════════════════════════

