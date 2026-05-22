part of '../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override State<SplashScreen> createState() => _SplashState();
}

class _SplashState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoCtrl, _glowCtrl, _scanCtrl, _exitCtrl, _shipCtrl;
  late Animation<double> _logoScale, _logoOpacity, _subOpacity,
      _glow, _scan, _exitOpacity, _ship;

  final List<StarBg> _stars = [];
  final List<Offset> _trail = [];
  double _shipX = 0, _shipY = 0;
  final _rng = Random();
  Timer? _starTick;

  @override
  void initState() {
    super.initState();
    SoundManager().init();

    _logoCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _glowCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat(reverse: true);
    _scanCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))..repeat();
    _exitCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _shipCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200));

    _logoScale   = Tween(begin: 0.3, end: 1.0).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));
    _logoOpacity = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _logoCtrl, curve: const Interval(0.0, 0.4)));
    _subOpacity  = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _logoCtrl, curve: const Interval(0.55, 1.0)));
    _glow        = Tween(begin: 0.45, end: 1.0).animate(_glowCtrl);
    _scan        = Tween(begin: -0.05, end: 1.05).animate(_scanCtrl);
    _exitOpacity = Tween(begin: 1.0, end: 0.0).animate(CurvedAnimation(parent: _exitCtrl, curve: Curves.easeIn));
    _ship        = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _shipCtrl, curve: Curves.easeInOut));

    _shipCtrl.addListener(() {
      if (!mounted) return;
      final w = MediaQuery.of(context).size.width;
      setState(() {
        _shipX = w * 1.15 - _ship.value * w * 2.3;
        _trail.add(Offset(_shipX, _shipY));
        if (_trail.length > 35) _trail.removeAt(0);
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      _shipY = size.height * 0.34;
      _shipX = size.width * 1.15;
      _buildStars(size);
      _starTick = Timer.periodic(const Duration(milliseconds: 16), (_) {
        if (!mounted) return;
        setState(() { for (final s in _stars) { s.y += s.speed; if (s.y > size.height) { s.y = 0; s.x = _rng.nextDouble() * size.width; } } });
      });
      _runSequence();
    });
  }

  void _buildStars(Size size) {
    for (int i = 0; i < 120; i++) {
      _stars.add(StarBg(
        _rng.nextDouble() * size.width, _rng.nextDouble() * size.height,
        0.8 + _rng.nextDouble() * 1.6,  0.5 + _rng.nextDouble() * 1.8,
        0.2 + _rng.nextDouble() * 0.8,
      ));
    }
  }

  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _shipCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 700));
    _logoCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 3400));
    if (!mounted) return;
    _exitCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 550));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      pageBuilder: (_, __, ___) => const MainMenuScreen(),
      transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
      transitionDuration: const Duration(milliseconds: 700),
    ));
  }

  @override
  void dispose() {
    _logoCtrl.dispose(); _glowCtrl.dispose(); _scanCtrl.dispose();
    _exitCtrl.dispose(); _shipCtrl.dispose(); _starTick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFF02050F),
      body: AnimatedBuilder(
        animation: Listenable.merge([_logoCtrl, _glowCtrl, _scanCtrl, _exitCtrl, _shipCtrl]),
        builder: (_, __) => Stack(children: [
          CustomPaint(painter: _StarPainter(_stars), size: size),
          CustomPaint(painter: _GridPainter(), size: size),
          // Nebula glows
          Positioned(top: -60, left: -60, child: _nebulaCircle(280, Colors.blue, _glow.value * 0.07)),
          Positioned(bottom: -40, right: -40, child: _nebulaCircle(220, Colors.purple, _glow.value * 0.07)),
          // Ship trail
          CustomPaint(painter: _TrailPainter(_trail), size: size),
          // Ship
          Positioned(left: _shipX - 28, top: _shipY - 18,
              child: CustomPaint(painter: _SplashShipPainter(), size: const Size(56, 36))),
          // Scan line
          Positioned(left: 0, right: 0, top: _scan.value * size.height,
              child: Container(height: 1.5, color: Colors.cyanAccent.withOpacity(0.08))),
          // Center content
          FadeTransition(opacity: _exitOpacity, child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              FadeTransition(opacity: _subOpacity,
                  child: _tag('MADE BY JATIN', Colors.white38, 11, 4)),
              const SizedBox(height: 18),
              ScaleTransition(scale: _logoScale, child: FadeTransition(opacity: _logoOpacity,
                child: Stack(alignment: Alignment.center, children: [
                  Container(width: 200, height: 200, decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.cyanAccent.withOpacity(_glow.value * 0.28), blurRadius: 60, spreadRadius: 20)],
                  )),
                  Image.asset('assets/ic_logo.png', width: 150, height: 150),
                ]),
              )),
              ScaleTransition(scale: _logoScale, child: FadeTransition(opacity: _logoOpacity,
                child: Column(children: [
                  _glowTitle('ULTIMATE', _glow.value), _glowTitle('SPACE WAR', _glow.value),
                ]),
              )),
              const SizedBox(height: 14),
              FadeTransition(opacity: _subOpacity,
                  child: _tag('DEFEND  ✦  SURVIVE  ✦  DOMINATE', Colors.cyanAccent.withOpacity(0.65), 11, 2.5)),
              const SizedBox(height: 36),
              FadeTransition(opacity: _subOpacity, child: _LoadingBar(progress: _logoCtrl.value)),
            ]),
          )),
          // Corners
          ..._corners(size, 22, 1.5),
          Positioned(bottom: 20, right: 18,
              child: FadeTransition(opacity: _subOpacity, child: _tag('v2.0.0', Colors.white24, 10, 2))),
        ]),
      ),
    );
  }

  Widget _nebulaCircle(double r, Color c, double opacity) => Container(
    width: r, height: r,
    decoration: BoxDecoration(shape: BoxShape.circle,
        gradient: RadialGradient(colors: [c.withOpacity(opacity), Colors.transparent])),
  );

  Widget _glowTitle(String text, double glow) => Text(text, style: TextStyle(
    fontSize: 42, fontWeight: FontWeight.w900, letterSpacing: 6, height: 1.05,
    foreground: Paint()..shader = const LinearGradient(
        colors: [Colors.cyanAccent, Colors.white, Colors.blueAccent])
        .createShader(const Rect.fromLTWH(0, 0, 280, 60)),
    shadows: [
      Shadow(color: Colors.cyanAccent.withOpacity(glow * 0.8), blurRadius: 18),
      Shadow(color: Colors.blue.withOpacity(glow * 0.5), blurRadius: 36),
    ],
  ));

  Widget _tag(String t, Color c, double fs, double ls) =>
      Text(t, style: TextStyle(color: c, fontSize: fs, letterSpacing: ls, fontWeight: FontWeight.w500));

  List<Widget> _corners(Size size, double len, double th) {
    Widget c(double? top, double? bot, double? left, double? right, bool fx, bool fy) =>
        Positioned(top: top, bottom: bot, left: left, right: right,
            child: Transform.scale(scaleX: fx ? -1 : 1, scaleY: fy ? -1 : 1,
                child: CustomPaint(painter: _CornerPainter(Colors.cyanAccent, len, th), size: const Size(36, 36))));
    return [c(20,null,18,null,false,false), c(20,null,null,18,true,false),
      c(null,20,18,null,false,true), c(null,20,null,18,true,true)];
  }
}

