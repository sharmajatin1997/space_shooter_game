part of '../main.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});
  @override State<MainMenuScreen> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenuScreen> with TickerProviderStateMixin {
  late AnimationController _glowCtrl, _floatCtrl, _scanCtrl;
  late Animation<double> _glow, _float, _scan;
  late List<AnimationController> _itemCtrls;
  late List<Animation<double>> _itemSlide, _itemFade;

  final List<StarBg> _stars = [];
  final _rng = Random();
  Timer? _starTick;

  GameSettings _settings = GameSettings();
  int _selectedLevel = 1;
  int _highScore = 0;

  static const _menuDefs = [
    ('rocket_launch', 'START GAME',   Colors.cyanAccent,   'start'),
    ('bar_chart',     'LEVEL SELECT', Colors.amberAccent,  'level'),
    ('settings',      'SETTINGS',     Colors.purpleAccent, 'settings'),
    ('power_settings_new', 'QUIT',    Colors.redAccent,    'quit'),
  ];

  @override
  void initState() {
    super.initState();
    _glowCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..repeat(reverse: true);
    _floatCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 3200))..repeat(reverse: true);
    _scanCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 3500))..repeat();

    _glow  = Tween(begin: 0.45, end: 1.0).animate(_glowCtrl);
    _float = Tween(begin: -7.0, end: 7.0).animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));
    _scan  = Tween(begin: -0.05, end: 1.05).animate(_scanCtrl);

    _itemCtrls = List.generate(4, (i) => AnimationController(vsync: this, duration: const Duration(milliseconds: 480)));
    _itemSlide = _itemCtrls.map((c) => Tween(begin: 70.0, end: 0.0).animate(CurvedAnimation(parent: c, curve: Curves.easeOutCubic))).toList();
    _itemFade  = _itemCtrls.map((c) => Tween(begin: 0.0, end: 1.0).animate(c)).toList();

    for (int i = 0; i < 4; i++) {
      Future.delayed(Duration(milliseconds: 250 + i * 110), () { if (mounted) _itemCtrls[i].forward(); });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      for (int i = 0; i < 110; i++) {
        _stars.add(StarBg(_rng.nextDouble() * size.width, _rng.nextDouble() * size.height,
            0.8 + _rng.nextDouble() * 1.5, 0.5 + _rng.nextDouble() * 1.8, 0.1 + _rng.nextDouble() * 0.6));
      }
      _starTick = Timer.periodic(const Duration(milliseconds: 16), (_) {
        if (!mounted) return;
        setState(() { for (final s in _stars) { s.y += s.speed; if (s.y > size.height) { s.y = 0; s.x = _rng.nextDouble() * size.width; } } });
      });
    });
  }

  @override
  void dispose() {
    _glowCtrl.dispose(); _floatCtrl.dispose(); _scanCtrl.dispose();
    for (final c in _itemCtrls) c.dispose();
    _starTick?.cancel();
    super.dispose();
  }

  IconData _icon(String key) => switch (key) {
    'rocket_launch'     => Icons.rocket_launch_rounded,
    'bar_chart'         => Icons.bar_chart_rounded,
    'settings'          => Icons.settings_rounded,
    _                   => Icons.power_settings_new_rounded,
  };

  void _onTap(String tag) {
    HapticFeedback.mediumImpact();
    switch (tag) {
      case 'start':
        final cfg = LevelConfig.all[_selectedLevel - 1];
        Navigator.of(context).push(PageRouteBuilder(
          pageBuilder: (_, __, ___) => GameScreen(levelCfg: cfg, settings: _settings),
          transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
          transitionDuration: const Duration(milliseconds: 600),
        )).then((result) {
          if (result is int && result > _highScore) setState(() => _highScore = result);
        });
        break;
      case 'level':
        showDialog(context: context, barrierColor: Colors.black87,
            builder: (_) => _LevelDialog(selected: _selectedLevel,
                onSelect: (l) => setState(() => _selectedLevel = l)));
        break;
      case 'settings':
        showDialog(context: context, barrierColor: Colors.black87,
            builder: (_) => _SettingsDialog(settings: _settings,
                onChange: (s) => setState(() => _settings = s)));
        break;
      case 'quit':
        showDialog(
          context: context,
          barrierColor: Colors.black87,
          builder: (_) => Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  width: 320,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.redAccent.withOpacity(0.4), width: 1.5),
                    boxShadow: [BoxShadow(color: Colors.redAccent.withOpacity(0.15), blurRadius: 40)],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.exit_to_app_rounded, color: Colors.redAccent, size: 48),
                      const SizedBox(height: 16),
                      const Text('QUIT GAME?', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 4, decoration: TextDecoration.none)),
                      const SizedBox(height: 12),
                      const Text('Are you sure you want to exit?', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1.5, decoration: TextDecoration.none, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () { HapticFeedback.mediumImpact(); Navigator.pop(context); },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white30, width: 1.5),
                                ),
                                child: const Center(child: Text('NO', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2, decoration: TextDecoration.none))),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: GestureDetector(
                              onTap: () { HapticFeedback.mediumImpact(); exit(0); },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.redAccent.withOpacity(0.6), width: 1.5),
                                  boxShadow: [BoxShadow(color: Colors.redAccent.withOpacity(0.2), blurRadius: 12)],
                                ),
                                child: const Center(child: Text('YES', style: TextStyle(color: Colors.redAccent, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2, decoration: TextDecoration.none))),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFF02050F),
      body: AnimatedBuilder(
        animation: Listenable.merge([_glowCtrl, _floatCtrl, _scanCtrl]),
        builder: (_, __) => Stack(children: [
          CustomPaint(painter: _StarPainter(_stars), size: size),
          CustomPaint(painter: _GridPainter(), size: size),
          Positioned(top: -80, left: -80, child: Container(width: 300, height: 300,
              decoration: BoxDecoration(shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [Colors.blue.withOpacity(0.06 * _glow.value), Colors.transparent])))),
          Positioned(bottom: -60, right: -60, child: Container(width: 260, height: 260,
              decoration: BoxDecoration(shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [Colors.purple.withOpacity(0.06 * _glow.value), Colors.transparent])))),
          Positioned(left: 0, right: 0, top: _scan.value * size.height,
              child: Container(height: 1, color: Colors.cyanAccent.withOpacity(0.05))),
          SafeArea(child: Column(children: [
            const SizedBox(height: 20),
            // Header with floating logo
            Transform.translate(offset: Offset(0, _float.value), child: Column(children: [
              Image.asset('assets/ic_logo.png', width: 80, height: 80),
              const SizedBox(height: 12),
              ShaderMask(
                shaderCallback: (b) => const LinearGradient(colors: [Colors.cyanAccent, Colors.white, Colors.blueAccent]).createShader(b),
                child: const Text('SPACE SHOOTER', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 6, color: Colors.white)),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.cyanAccent.withOpacity(0.1),
                  border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('DEFEND  ✦  SURVIVE  ✦  DOMINATE',
                    style: TextStyle(fontSize: 10, color: Colors.cyanAccent, letterSpacing: 3, fontWeight: FontWeight.bold)),
              ),
            ])),
            const SizedBox(height: 24),
            // Stats row inside a glass panel
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Row(children: [
                      _StatCard('HIGH SCORE', '$_highScore', Colors.amberAccent, Icons.emoji_events_rounded),
                      Container(width: 1, height: 36, color: Colors.white.withOpacity(0.1)),
                      _StatCard('LEVEL', LevelConfig.all[_selectedLevel - 1].name, Colors.cyanAccent, Icons.layers_rounded),
                      Container(width: 1, height: 36, color: Colors.white.withOpacity(0.1)),
                      _StatCard('LIVES', '♥' * LevelConfig.all[_selectedLevel - 1].lives, Colors.redAccent, Icons.favorite_rounded),
                    ]),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Menu buttons
            Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) {
                  final (icon, label, color, tag) = _menuDefs[i];
                  return AnimatedBuilder(animation: _itemCtrls[i], builder: (_, __) =>
                      Transform.translate(offset: Offset(_itemSlide[i].value, 0),
                        child: Opacity(opacity: _itemFade[i].value,
                          child: Padding(padding: const EdgeInsets.only(bottom: 12),
                            child: _MenuBtn(
                              icon: _icon(icon), label: label, color: color,
                              glow: _glow.value, onTap: () => _onTap(tag),
                              badge: tag == 'level' ? 'LVL $_selectedLevel' : null,
                            ),
                          ),
                        ),
                      ),
                  );
                }),
              ),
            )),
            const Padding(padding: EdgeInsets.only(bottom: 14),
                child: Text('©2026 Space Shooter •  v1.0.0',
                    style: TextStyle(color: Colors.white24, fontSize: 11, letterSpacing: 4, fontWeight: FontWeight.bold))),
          ])),
          // Corners
          _c(16, null, 16, null, false, false), _c(16, null, null, 16, true, false),
          _c(null, 16, 16, null, false, true),  _c(null, 16, null, 16, true, true),
        ]),
      ),
    );
  }

  Widget _c(double? t, double? b, double? l, double? r, bool fx, bool fy) =>
      Positioned(top: t, bottom: b, left: l, right: r,
          child: Transform.scale(scaleX: fx ? -1 : 1, scaleY: fy ? -1 : 1,
              child: CustomPaint(painter: _CornerPainter(Colors.cyanAccent, 18, 1.5), size: const Size(30, 30))));
}

