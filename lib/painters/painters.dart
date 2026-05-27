part of '../main.dart';

class _StarPainter extends CustomPainter {
  final List<StarBg> stars;
  _StarPainter(this.stars);
  @override
  void paint(Canvas c, Size s) {
    final p = Paint();
    for (final st in stars) {
      p.color = Colors.white.withOpacity(st.opacity * 0.8);
      c.drawCircle(Offset(st.x, st.y), st.size, p);
    }
  }
  @override bool shouldRepaint(covariant _StarPainter o) => true;
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final p = Paint()..color = Colors.cyanAccent.withOpacity(0.025)..strokeWidth = 0.5;
    for (double y = 0; y < s.height; y += 42) c.drawLine(Offset(0, y), Offset(s.width, y), p);
    for (double x = 0; x < s.width; x += 42) c.drawLine(Offset(x, 0), Offset(x, s.height), p);
  }
  @override bool shouldRepaint(covariant _GridPainter o) => false;
}

class _CornerPainter extends CustomPainter {
  final Color color; final double len; final double th;
  _CornerPainter(this.color, this.len, this.th);
  @override
  void paint(Canvas c, Size s) {
    final p = Paint()..color = color.withOpacity(0.55)..strokeWidth = th
      ..style = PaintingStyle.stroke..strokeCap = StrokeCap.square;
    c.drawLine(Offset.zero, Offset(len, 0), p);
    c.drawLine(Offset.zero, Offset(0, len), p);
  }
  @override bool shouldRepaint(covariant CustomPainter o) => false;
}

class _HexLogoPainter extends CustomPainter {
  final double glow;
  _HexLogoPainter(this.glow);
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    void hex(double r, Paint p) {
      final path = Path();
      for (int i = 0; i < 6; i++) {
        final a = pi / 3 * i - pi / 6;
        final pt = Offset(cx + r * cos(a), cy + r * sin(a));
        i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
      }
      path.close(); canvas.drawPath(path, p);
    }
    hex(46, Paint()..color = Colors.cyanAccent.withOpacity(0.07));
    hex(48, Paint()..color = Colors.cyanAccent.withOpacity(glow * 0.75)
      ..style = PaintingStyle.stroke..strokeWidth = 2);
    const s = 22.0;
    final body = Path()
      ..moveTo(cx, cy - s)
      ..lineTo(cx + s * 0.55, cy + s * 0.5)
      ..lineTo(cx - s * 0.55, cy + s * 0.5)..close();
    canvas.drawPath(body, Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Colors.cyanAccent, Color(0xFF006699)],
      ).createShader(Rect.fromCenter(center: Offset(cx, cy), width: s * 2, height: s * 2)));
    canvas.drawCircle(Offset(cx, cy - s), 4,
        Paint()..color = Colors.white.withOpacity(glow)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
  }
  @override bool shouldRepaint(covariant _HexLogoPainter o) => o.glow != glow;
}

class _SplashShipPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final cx = s.width / 2, cy = s.height / 2;
    const r = 14.0;
    c.drawCircle(Offset(cx, cy + 2), 10, Paint()..color = Colors.blue.withOpacity(0.5)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
    final body = Path()..moveTo(cx + r, cy)..lineTo(cx - r * 0.45, cy - r * 0.5)..lineTo(cx - r * 0.45, cy + r * 0.5)..close();
    c.drawPath(body, Paint()..shader = const LinearGradient(colors: [Colors.cyanAccent, Color(0xFF0088AA)])
        .createShader(Rect.fromCenter(center: Offset(cx, cy), width: r * 2, height: r)));
    c.drawCircle(Offset(cx, cy), r, Paint()..color = Colors.cyanAccent.withOpacity(0.15)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));
  }
  @override bool shouldRepaint(covariant CustomPainter o) => false;
}

class _TrailPainter extends CustomPainter {
  final List<Offset> trail;
  _TrailPainter(this.trail);
  @override
  void paint(Canvas c, Size s) {
    if (trail.length < 2) return;
    for (int i = 1; i < trail.length; i++) {
      final t = i / trail.length;
      c.drawLine(trail[i - 1], trail[i],
          Paint()..color = Colors.cyanAccent.withOpacity(t * 0.45)
            ..strokeWidth = t * 3..strokeCap = StrokeCap.round);
    }
  }
  @override bool shouldRepaint(covariant _TrailPainter o) => true;
}

class _GamePainter extends CustomPainter {
  final List<StarBg>  stars; final List<MeteorBg> meteors; final List<Bullet>   bullets;
  final List<Enemy>   enemies; final List<Particle> particles;
  final List<PowerUp> powerUps; final Vec2 playerPos;
  final double playerSize; final GState gState; final ActivePowerUp? activePU;

  _GamePainter({required this.stars, required this.meteors, required this.bullets, required this.enemies,
    required this.particles, required this.powerUps, required this.playerPos,
    required this.playerSize, required this.gState, required this.activePU});

  @override
  void paint(Canvas canvas, Size size) {
    _drawStars(canvas);
    _drawMeteors(canvas);
    _drawPowerUps(canvas);
    _drawBullets(canvas);
    _drawEnemies(canvas);
    _drawParticles(canvas);
    if (gState == GState.playing || gState == GState.paused) _drawPlayer(canvas);
  }

  void _drawStars(Canvas canvas) {
    final p = Paint();
    for (final s in stars) { p.color = Colors.white.withOpacity(s.opacity * 0.8); canvas.drawCircle(Offset(s.x, s.y), s.size, p); }
  }

  void _drawMeteors(Canvas canvas) {
    for (final m in meteors) {
      final speed = sqrt(m.speedX * m.speedX + m.speedY * m.speedY);
      final dx = (m.speedX / speed) * m.length;
      final dy = (m.speedY / speed) * m.length;
      
      canvas.drawLine(
        Offset(m.x, m.y), 
        Offset(m.x - dx, m.y - dy), 
        Paint()..color = m.color..strokeWidth = m.size..strokeCap = StrokeCap.round
      );
    }
  }

  void _drawPowerUps(Canvas canvas) {
    for (final p in powerUps) {
      if (!p.active) continue;
      final cx = p.pos.x, cy = p.pos.y;
      final pulse = sin(p.animTimer * 4) * 0.5 + 0.5;
      canvas.drawCircle(Offset(cx, cy), 22 + pulse * 4,
          Paint()..color = p.color.withOpacity(0.18 + pulse * 0.18)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14));
      
      if (p.type == PowerUpType.bomb) {
        // Draw proper Bomb asset
        final bs = 12.0;
        canvas.drawCircle(Offset(cx, cy), bs, Paint()..color = const Color(0xFF111111));
        canvas.drawCircle(Offset(cx, cy), bs, Paint()..color = p.color..style = PaintingStyle.stroke..strokeWidth = 2);
        // Highlight
        canvas.drawCircle(Offset(cx - bs*0.3, cy - bs*0.3), bs*0.3, Paint()..color = Colors.white38);
        // Fuse
        final fuse = Path()..moveTo(cx, cy - bs)..quadraticBezierTo(cx + bs*0.5, cy - bs*1.5, cx + bs*0.8, cy - bs*1.2);
        canvas.drawPath(fuse, Paint()..color = Colors.white54..style = PaintingStyle.stroke..strokeWidth = 2);
        // Spark
        canvas.drawCircle(Offset(cx + bs*0.8, cy - bs*1.2), bs*0.4, Paint()..color = Colors.orangeAccent);
        canvas.drawCircle(Offset(cx + bs*0.8, cy - bs*1.2), bs*0.2, Paint()..color = Colors.yellow);
      } else {
        canvas.drawCircle(Offset(cx, cy), 18,
            Paint()..color = p.color.withOpacity(0.7)..style = PaintingStyle.stroke..strokeWidth = 2);
        canvas.drawCircle(Offset(cx, cy), 16, Paint()..color = p.color.withOpacity(0.22));
        final tp = TextPainter(
          text: TextSpan(text: p.label, style: TextStyle(color: p.color, fontSize: 14, fontWeight: FontWeight.bold)),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
      }
    }
  }

  void _drawBullets(Canvas canvas) {
    final puType = activePU?.type;
    final bc = puType == PowerUpType.tripleShot ? Colors.amberAccent
        : puType == PowerUpType.doubleShot  ? Colors.greenAccent
        : Colors.cyanAccent;
    for (final b in bullets) {
      if (!b.active) continue;
      canvas.drawCircle(Offset(b.pos.x, b.pos.y), 6,
          Paint()..color = bc.withOpacity(0.4)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
      canvas.drawRRect(RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(b.pos.x, b.pos.y), width: 3, height: 14),
          const Radius.circular(2)), Paint()..color = Colors.white);
    }
  }

  void _drawEnemies(Canvas canvas) {
    for (final e in enemies) {
      if (!e.active) continue;
      final cx = e.pos.x, cy = e.pos.y, s = e.size;
      canvas.drawCircle(Offset(cx, cy), s * 1.4,
          Paint()..color = e.color.withOpacity(0.25)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));
      
      // Draw Alien Bug instead of polygon
      _drawBug(canvas, cx, cy, s, e.color);
    }
  }

  void _drawBug(Canvas canvas, double cx, double cy, double s, Color color) {
    // Wings
    final wingP = Paint()..color = Colors.white.withOpacity(0.4);
    canvas.save();
    canvas.translate(cx - s*0.75, cy - s*0.1);
    canvas.rotate(-0.3);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: s*0.7, height: s*1.4), wingP);
    canvas.restore();
    
    canvas.save();
    canvas.translate(cx + s*0.75, cy - s*0.1);
    canvas.rotate(0.3);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: s*0.7, height: s*1.4), wingP);
    canvas.restore();

    // Body
    final bodyP = Paint()..color = color;
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: s*1.2, height: s*1.5), bodyP);
    // Body outline/detail
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: s*1.2, height: s*1.5), 
        Paint()..color = Colors.black45..style = PaintingStyle.stroke..strokeWidth = 2);

    // Core (gem)
    final gemColor = color == Colors.redAccent ? Colors.yellow : Colors.redAccent;
    canvas.drawCircle(Offset(cx, cy + s*0.2), s*0.35, Paint()..color = gemColor);
    canvas.drawCircle(Offset(cx, cy + s*0.2), s*0.15, Paint()..color = Colors.white.withOpacity(0.8));

    // Head
    canvas.drawCircle(Offset(cx, cy - s*0.65), s*0.45, Paint()..color = color.withOpacity(0.9));

    // Eyes
    final eyeP = Paint()..color = Colors.redAccent;
    canvas.drawCircle(Offset(cx - s*0.2, cy - s*0.75), s*0.15, eyeP);
    canvas.drawCircle(Offset(cx + s*0.2, cy - s*0.75), s*0.15, eyeP);

    // Antennas
    final antP = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 1.5;
    canvas.drawLine(Offset(cx - s*0.15, cy - s*0.9), Offset(cx - s*0.5, cy - s*1.3), antP);
    canvas.drawLine(Offset(cx + s*0.15, cy - s*0.9), Offset(cx + s*0.5, cy - s*1.3), antP);
    canvas.drawCircle(Offset(cx - s*0.5, cy - s*1.3), 2, Paint()..color = gemColor);
    canvas.drawCircle(Offset(cx + s*0.5, cy - s*1.3), 2, Paint()..color = gemColor);
  }



  void _drawParticles(Canvas canvas) {
    for (final p in particles) {
      if (p.life <= 0) continue;
      canvas.drawCircle(Offset(p.pos.x, p.pos.y), p.size * p.life,
          Paint()..color = p.color.withOpacity(p.life.clamp(0.0, 1.0)));
    }
  }

  void _drawPlayer(Canvas canvas) {
    final cx = playerPos.x, cy = playerPos.y;
    final type = activePU?.type;

    if (type == PowerUpType.tripleShot) {
      _drawTripleShip(canvas, cx, cy, playerSize * 1.4); // Bigger ship
    } else if (type == PowerUpType.doubleShot) {
      _drawDoubleShip(canvas, cx, cy, playerSize * 1.15); // Medium ship
    } else {
      _drawNormalShip(canvas, cx, cy, playerSize); // Base ship
    }
  }

  void _drawNormalShip(Canvas canvas, double cx, double cy, double s) {
    // Engine flame
    final flameP = Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Colors.yellow, Colors.redAccent, Colors.transparent]).createShader(
        Rect.fromCenter(center: Offset(cx, cy + s), width: s, height: s*1.5));
    canvas.drawPath(Path()..moveTo(cx - s*0.25, cy + s*0.4)..lineTo(cx, cy + s*1.8)..lineTo(cx + s*0.25, cy + s*0.4)..close(), flameP);

    // Main Body
    canvas.drawPath(Path()..moveTo(cx, cy - s*1.2)..lineTo(cx + s*0.35, cy - s*0.2)..lineTo(cx + s*0.45, cy + s*0.6)..lineTo(cx - s*0.45, cy + s*0.6)..lineTo(cx - s*0.35, cy - s*0.2)..close(), Paint()..color = Colors.grey[200]!);

    // Wings
    final wingP = Paint()..color = Colors.cyanAccent[700]!;
    canvas.drawPath(Path()..moveTo(cx - s*0.3, cy)..lineTo(cx - s*1.4, cy + s*0.3)..lineTo(cx - s*1.2, cy + s*0.8)..lineTo(cx - s*0.45, cy + s*0.5)..close(), wingP);
    canvas.drawPath(Path()..moveTo(cx + s*0.3, cy)..lineTo(cx + s*1.4, cy + s*0.3)..lineTo(cx + s*1.2, cy + s*0.8)..lineTo(cx + s*0.45, cy + s*0.5)..close(), wingP);

    // Cannons
    final gunP = Paint()..color = Colors.grey[800]!;
    canvas.drawRect(Rect.fromCenter(center: Offset(cx - s*1.2, cy + s*0.2), width: s*0.2, height: s*0.8), gunP);
    canvas.drawRect(Rect.fromCenter(center: Offset(cx + s*1.2, cy + s*0.2), width: s*0.2, height: s*0.8), gunP);
    canvas.drawCircle(Offset(cx - s*1.2, cy - s*0.2), s*0.1, Paint()..color = Colors.cyanAccent);
    canvas.drawCircle(Offset(cx + s*1.2, cy - s*0.2), s*0.1, Paint()..color = Colors.cyanAccent);

    // Cockpit
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy - s*0.2), width: s*0.4, height: s*0.8), Paint()..color = Colors.lightBlueAccent);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + s*0.05, cy - s*0.3), width: s*0.15, height: s*0.3), Paint()..color = Colors.white.withOpacity(0.6));
    
    // Details
    canvas.drawRect(Rect.fromCenter(center: Offset(cx - s*0.25, cy + s*0.65), width: s*0.25, height: s*0.2), Paint()..color = Colors.grey[700]!);
    canvas.drawRect(Rect.fromCenter(center: Offset(cx + s*0.25, cy + s*0.65), width: s*0.25, height: s*0.2), Paint()..color = Colors.grey[700]!);
  }

  void _drawDoubleShip(Canvas canvas, double cx, double cy, double s) {
    // Twin engine flames
    final flameP = Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.greenAccent, Colors.yellow, Colors.transparent]).createShader(Rect.fromCenter(center: Offset(cx, cy + s), width: s*2, height: s*1.5));
    canvas.drawPath(Path()..moveTo(cx - s*0.6, cy + s*0.4)..lineTo(cx - s*0.35, cy + s*1.8)..lineTo(cx - s*0.1, cy + s*0.4)..close(), flameP);
    canvas.drawPath(Path()..moveTo(cx + s*0.1, cy + s*0.4)..lineTo(cx + s*0.35, cy + s*1.8)..lineTo(cx + s*0.6, cy + s*0.4)..close(), flameP);

    // Sleeker double-pronged body
    final bodyP = Paint()..color = Colors.grey[300]!;
    canvas.drawPath(Path()..moveTo(cx - s*0.3, cy - s*1.2)..lineTo(cx - s*0.1, cy - s*0.4)..lineTo(cx + s*0.1, cy - s*0.4)..lineTo(cx + s*0.3, cy - s*1.2)..lineTo(cx + s*0.5, cy + s*0.6)..lineTo(cx - s*0.5, cy + s*0.6)..close(), bodyP);

    // Wide swept wings
    final wingP = Paint()..color = Colors.green[600]!;
    canvas.drawPath(Path()..moveTo(cx - s*0.4, cy - s*0.2)..lineTo(cx - s*1.6, cy + s*0.5)..lineTo(cx - s*1.4, cy + s*0.9)..lineTo(cx - s*0.5, cy + s*0.5)..close(), wingP);
    canvas.drawPath(Path()..moveTo(cx + s*0.4, cy - s*0.2)..lineTo(cx + s*1.6, cy + s*0.5)..lineTo(cx + s*1.4, cy + s*0.9)..lineTo(cx + s*0.5, cy + s*0.5)..close(), wingP);

    // Twin huge Cannons
    final gunP = Paint()..color = Colors.grey[900]!;
    canvas.drawRect(Rect.fromCenter(center: Offset(cx - s*1.4, cy + s*0.3), width: s*0.3, height: s*1.2), gunP);
    canvas.drawRect(Rect.fromCenter(center: Offset(cx + s*1.4, cy + s*0.3), width: s*0.3, height: s*1.2), gunP);
    canvas.drawCircle(Offset(cx - s*1.4, cy - s*0.3), s*0.15, Paint()..color = Colors.greenAccent);
    canvas.drawCircle(Offset(cx + s*1.4, cy - s*0.3), s*0.15, Paint()..color = Colors.greenAccent);

    // Cockpit
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: s*0.5, height: s*0.6), Paint()..color = Colors.greenAccent.withOpacity(0.8));
    
    // Core Engine Block
    canvas.drawRect(Rect.fromCenter(center: Offset(cx, cy + s*0.5), width: s*1.1, height: s*0.3), Paint()..color = Colors.grey[800]!);
  }

  void _drawTripleShip(Canvas canvas, double cx, double cy, double s) {
    // 3 engine flames
    final flameP = Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.orange, Colors.red, Colors.transparent]).createShader(Rect.fromCenter(center: Offset(cx, cy + s), width: s*2, height: s*1.8));
    canvas.drawPath(Path()..moveTo(cx - s*0.8, cy + s*0.2)..lineTo(cx - s*0.6, cy + s*1.6)..lineTo(cx - s*0.4, cy + s*0.2)..close(), flameP);
    canvas.drawPath(Path()..moveTo(cx - s*0.2, cy + s*0.4)..lineTo(cx, cy + s*2.0)..lineTo(cx + s*0.2, cy + s*0.4)..close(), flameP);
    canvas.drawPath(Path()..moveTo(cx + s*0.4, cy + s*0.2)..lineTo(cx + s*0.6, cy + s*1.6)..lineTo(cx + s*0.8, cy + s*0.2)..close(), flameP);

    // Heavy Bomber Body
    final bodyP = Paint()..color = Colors.grey[900]!;
    canvas.drawPath(Path()..moveTo(cx, cy - s*1.3)..lineTo(cx + s*0.6, cy - s*0.2)..lineTo(cx + s*0.8, cy + s*0.6)..lineTo(cx - s*0.8, cy + s*0.6)..lineTo(cx - s*0.6, cy - s*0.2)..close(), bodyP);
    
    // Golden Armor plates
    final armorP = Paint()..color = Colors.amber;
    canvas.drawPath(Path()..moveTo(cx, cy - s*1.1)..lineTo(cx + s*0.4, cy - s*0.3)..lineTo(cx + s*0.5, cy + s*0.4)..lineTo(cx - s*0.5, cy + s*0.4)..lineTo(cx - s*0.4, cy - s*0.3)..close(), armorP);

    // Giant Delta Wings
    final wingP = Paint()..color = Colors.grey[850]!;
    canvas.drawPath(Path()..moveTo(cx - s*0.6, cy - s*0.2)..lineTo(cx - s*1.8, cy + s*0.6)..lineTo(cx - s*1.6, cy + s*1.0)..lineTo(cx - s*0.7, cy + s*0.6)..close(), wingP);
    canvas.drawPath(Path()..moveTo(cx + s*0.6, cy - s*0.2)..lineTo(cx + s*1.8, cy + s*0.6)..lineTo(cx + s*1.6, cy + s*1.0)..lineTo(cx + s*0.7, cy + s*0.6)..close(), wingP);

    // 3 Cannons
    final gunP = Paint()..color = Colors.grey[300]!;
    // Center big cannon
    canvas.drawRect(Rect.fromCenter(center: Offset(cx, cy - s*1.1), width: s*0.25, height: s*1.0), gunP);
    canvas.drawCircle(Offset(cx, cy - s*1.6), s*0.15, Paint()..color = Colors.orangeAccent);
    // Side cannons
    canvas.drawRect(Rect.fromCenter(center: Offset(cx - s*1.5, cy + s*0.4), width: s*0.2, height: s*1.2), gunP);
    canvas.drawRect(Rect.fromCenter(center: Offset(cx + s*1.5, cy + s*0.4), width: s*0.2, height: s*1.2), gunP);
    canvas.drawCircle(Offset(cx - s*1.5, cy - s*0.2), s*0.1, Paint()..color = Colors.orangeAccent);
    canvas.drawCircle(Offset(cx + s*1.5, cy - s*0.2), s*0.1, Paint()..color = Colors.orangeAccent);

    // Wide Cockpit
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: s*0.8, height: s*0.4), Paint()..color = Colors.deepOrangeAccent);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy - s*0.05), width: s*0.4, height: s*0.15), Paint()..color = Colors.white.withOpacity(0.5));
  }

  @override bool shouldRepaint(covariant CustomPainter o) => true;
}