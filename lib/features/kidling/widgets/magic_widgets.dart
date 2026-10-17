// lib/Kidling/widgets/magic_widgets.dart

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:isapp/features/kidling/controllers/audio_assistant_services.dart';
import 'package:isapp/features/kidling/theme/magic_theme.dart';

// ============================================================
//  SKY BACKGROUND  (twinkling stars, drifting clouds, hills)
// ============================================================

class MagicBackground extends StatefulWidget {
  final Widget child;
  final List<Color>? colors;
  const MagicBackground({super.key, required this.child, this.colors});

  @override
  State<MagicBackground> createState() => _MagicBackgroundState();
}

class _MagicBackgroundState extends State<MagicBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 48))
        ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(
          child: AnimatedBuilder(
            animation: _c,
            builder: (_, __) => CustomPaint(
              painter: _SkyPainter(_c.value, widget.colors ?? Magic.skyColors),
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _Star {
  final double x, y, r, phase;
  final int speed;
  _Star(this.x, this.y, this.r, this.phase, this.speed);
}

class _SkyPainter extends CustomPainter {
  final double t;
  final List<Color> colors;
  static final List<_Star> _stars = () {
    final rnd = math.Random(11);
    return List.generate(
      70,
      (_) => _Star(rnd.nextDouble(), rnd.nextDouble() * .75,
          1 + rnd.nextDouble() * 2.2, rnd.nextDouble(), 6 + rnd.nextInt(12)),
    );
  }();

  _SkyPainter(this.t, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
          stops: const [0, .45, .82, 1],
        ).createShader(rect),
    );

    // moon glow
    final moon = Offset(size.width * .82, size.height * .1);
    canvas.drawCircle(
      moon,
      size.width * .3,
      Paint()
        ..shader = RadialGradient(colors: [
          Colors.white.withOpacity(.22),
          Colors.white.withOpacity(0),
        ]).createShader(Rect.fromCircle(center: moon, radius: size.width * .3)),
    );
    canvas.drawCircle(moon, 18, Paint()..color = Colors.white.withOpacity(.9));

    // stars
    final p = Paint();
    for (final s in _stars) {
      final tw = .5 + .5 * math.sin(2 * math.pi * (t * s.speed + s.phase));
      p.color = Colors.white.withOpacity(.25 + .75 * tw);
      canvas.drawCircle(Offset(s.x * size.width, s.y * size.height), s.r * (.7 + .3 * tw), p);
    }

    // clouds
    for (var i = 0; i < 4; i++) {
      final base = (i * .31 + t) % 1.4 - .2;
      final cx = base * size.width;
      final cy = size.height * (.2 + i * .13);
      final w = 60.0 + i * 14;
      final cp = Paint()..color = Colors.white.withOpacity(.10 + i * .015);
      canvas.drawCircle(Offset(cx, cy), w * .5, cp);
      canvas.drawCircle(Offset(cx + w * .45, cy + 6), w * .38, cp);
      canvas.drawCircle(Offset(cx - w * .45, cy + 8), w * .34, cp);
    }

    // hills
    final h1 = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * .9)
      ..quadraticBezierTo(size.width * .25, size.height * .82, size.width * .5, size.height * .9)
      ..quadraticBezierTo(size.width * .78, size.height * .98, size.width, size.height * .88)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(h1, Paint()..color = Magic.dusk.withOpacity(.35));
    final h2 = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * .95)
      ..quadraticBezierTo(size.width * .4, size.height * .88, size.width * .7, size.height * .96)
      ..quadraticBezierTo(size.width * .9, size.height * 1.0, size.width, size.height * .94)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(h2, Paint()..color = Magic.midnight.withOpacity(.35));
  }

  @override
  bool shouldRepaint(covariant _SkyPainter old) => old.t != t;
}

// ============================================================
//  MOTION HELPERS
// ============================================================

/// Squishes on touch, gives haptic + soft tap sound.
class Bouncy extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final bool sound;
  const Bouncy({super.key, required this.child, this.onTap, this.scale = .92, this.sound = true});

  @override
  State<Bouncy> createState() => _BouncyState();
}

class _BouncyState extends State<Bouncy> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 110), lowerBound: 0, upperBound: 1);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _c.forward(),
      onTapCancel: () => _c.reverse(),
      onTap: () {
        _c.reverse();
        if (widget.onTap == null) return;
        HapticFeedback.lightImpact();
        if (widget.sound) AudioAssistantService.ensure().playSfx('tap');
        widget.onTap!();
      },
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, child) => Transform.scale(scale: 1 - (1 - widget.scale) * _c.value, child: child),
        child: widget.child,
      ),
    );
  }
}

/// Gentle endless bobbing.
class Floaty extends StatefulWidget {
  final Widget child;
  final double amplitude;
  final Duration duration;
  final double phase;
  const Floaty({super.key, required this.child, this.amplitude = 8, this.duration = const Duration(seconds: 3), this.phase = 0});

  @override
  State<Floaty> createState() => _FloatyState();
}

class _FloatyState extends State<Floaty> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: widget.duration)
    ..value = widget.phase % 1
    ..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (_, child) => Transform.translate(
          offset: Offset(0, Curves.easeInOut.transform(_c.value) * widget.amplitude - widget.amplitude / 2),
          child: child,
        ),
        child: widget.child,
      );
}

/// Shakes sideways whenever [trigger] changes ("no, try again").
class Shake extends StatefulWidget {
  final int trigger;
  final Widget child;
  const Shake({super.key, required this.trigger, required this.child});

  @override
  State<Shake> createState() => _ShakeState();
}

class _ShakeState extends State<Shake> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));

  @override
  void didUpdateWidget(covariant Shake old) {
    super.didUpdateWidget(old);
    if (old.trigger != widget.trigger) _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (_, child) => Transform.translate(
          offset: Offset(math.sin(_c.value * math.pi * 6) * 10 * (1 - _c.value), 0),
          child: child,
        ),
        child: widget.child,
      );
}

/// Pops in with an elastic bounce.
class PopIn extends StatelessWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  const PopIn({super.key, required this.child, this.delay = Duration.zero, this.duration = const Duration(milliseconds: 600)});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: Future.delayed(delay, () => true),
      builder: (_, snap) => AnimatedScale(
        scale: snap.data == true ? 1 : 0,
        duration: duration,
        curve: Curves.elasticOut,
        child: child,
      ),
    );
  }
}

// ============================================================
//  PRIMITIVES
// ============================================================

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final Color? tint;
  const GlassCard({super.key, required this.child, this.padding = const EdgeInsets.all(18), this.radius = 30, this.tint});

  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
          color: (tint ?? Colors.white).withOpacity(.16),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: Colors.white.withOpacity(.35), width: 1.5),
        ),
        child: child,
      );
}

class BigButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  final Color color;
  final Color? textColor;
  final bool outlined;
  const BigButton({super.key, required this.label, required this.onTap, this.icon, this.color = Magic.candy, this.textColor, this.outlined = false});

  @override
  Widget build(BuildContext context) {
    return Bouncy(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : color,
          borderRadius: BorderRadius.circular(40),
          border: outlined ? Border.all(color: Colors.white.withOpacity(.7), width: 2.5) : null,
          boxShadow: outlined ? null : Magic.glow(color, blur: 18, a: .55),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: Magic.title(textColor ?? Colors.white, 22)),
            if (icon != null) ...[
              const SizedBox(width: 8),
              Icon(icon, color: textColor ?? Colors.white, size: 26),
            ],
          ],
        ),
      ),
    );
  }
}

class StarsRow extends StatelessWidget {
  final int earned;
  final int total;
  final double size;
  const StarsRow({super.key, required this.earned, this.total = 3, this.size = 22});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          total,
          (i) => Icon(i < earned ? Icons.star_rounded : Icons.star_outline_rounded,
              size: size, color: i < earned ? Magic.sun : Colors.white38),
        ),
      );
}

// ============================================================
//  SHAPES  (drawn, so every device renders them crisply)
// ============================================================

class ShapeIcon extends StatelessWidget {
  final String shape;
  final Color color;
  final double size;
  const ShapeIcon({super.key, required this.shape, required this.color, this.size = 80});

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size(size, size), painter: _ShapePainter(shape, color));
}

class _ShapePainter extends CustomPainter {
  final String shape;
  final Color color;
  _ShapePainter(this.shape, this.color);

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width, h = s.height;
    final fill = Paint()..color = color;
    final edge = Paint()
      ..color = Colors.white.withOpacity(.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * .035;
    Path path = Path();
    switch (shape) {
      case 'circle':
        path.addOval(Rect.fromCircle(center: Offset(w / 2, h / 2), radius: w * .42));
        break;
      case 'square':
        path.addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * .1, h * .1, w * .8, h * .8), Radius.circular(w * .08)));
        break;
      case 'rectangle':
        path.addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * .04, h * .24, w * .92, h * .52), Radius.circular(w * .06)));
        break;
      case 'oval':
        path.addOval(Rect.fromLTWH(w * .04, h * .2, w * .92, h * .6));
        break;
      case 'triangle':
        path
          ..moveTo(w * .5, h * .1)
          ..lineTo(w * .92, h * .86)
          ..lineTo(w * .08, h * .86)
          ..close();
        break;
      case 'diamond':
        path
          ..moveTo(w * .5, h * .04)
          ..lineTo(w * .88, h * .5)
          ..lineTo(w * .5, h * .96)
          ..lineTo(w * .12, h * .5)
          ..close();
        break;
      case 'star':
        for (var i = 0; i < 10; i++) {
          final r = (i.isEven ? .46 : .2) * w;
          final a = -math.pi / 2 + i * math.pi / 5;
          final pt = Offset(w / 2 + r * math.cos(a), h / 2 + r * math.sin(a) + h * .02);
          i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
        }
        path.close();
        break;
      case 'heart':
        path
          ..moveTo(w * .5, h * .9)
          ..cubicTo(w * .02, h * .55, w * .1, h * .08, w * .5, h * .32)
          ..cubicTo(w * .9, h * .08, w * .98, h * .55, w * .5, h * .9)
          ..close();
        break;
      default:
        path.addOval(Rect.fromCircle(center: Offset(w / 2, h / 2), radius: w * .4));
    }
    canvas.drawShadow(path, Colors.black.withOpacity(.35), 4, false);
    canvas.drawPath(path, fill);
    canvas.drawPath(path, edge);
  }

  @override
  bool shouldRepaint(covariant _ShapePainter old) => old.shape != shape || old.color != color;
}

// ============================================================
//  LUMA - the little star guide
// ============================================================

enum LumaMood { happy, cheer, think, oops, sleepy }

class Luma extends StatefulWidget {
  final double size;
  final LumaMood mood;
  final VoidCallback? onTap;
  const Luma({super.key, this.size = 120, this.mood = LumaMood.happy, this.onTap});

  @override
  State<Luma> createState() => _LumaState();
}

class _LumaState extends State<Luma> with TickerProviderStateMixin {
  late final AnimationController _t =
      AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  late final AnimationController _blink =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 140));
  late final AnimationController _mouth =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 170));
  late final AudioAssistantService _audio = AudioAssistantService.ensure();
  Worker? _worker;
  Timer? _blinkTimer;

  @override
  void initState() {
    super.initState();
    _worker = ever<bool>(_audio.isSpeaking, (speaking) {
      if (!mounted) return;
      if (speaking) {
        _mouth.repeat(reverse: true);
      } else {
        _mouth.stop();
        _mouth.value = 0;
      }
    });
    if (_audio.isSpeaking.value) _mouth.repeat(reverse: true);
    _scheduleBlink();
  }

  void _scheduleBlink() {
    _blinkTimer = Timer(Duration(milliseconds: 1800 + math.Random().nextInt(2800)), () async {
      if (!mounted) return;
      await _blink.forward();
      if (!mounted) return;
      await _blink.reverse();
      _scheduleBlink();
    });
  }

  @override
  void dispose() {
    _worker?.dispose();
    _blinkTimer?.cancel();
    _t.dispose();
    _blink.dispose();
    _mouth.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_t, _blink, _mouth]),
        builder: (_, __) {
          final bob = math.sin(_t.value * 2 * math.pi) * widget.size * .04;
          final tilt = math.sin(_t.value * 2 * math.pi + 1) * .05;
          return Transform.translate(
            offset: Offset(0, bob),
            child: Transform.rotate(
              angle: tilt + (widget.mood == LumaMood.cheer ? math.sin(_t.value * 8 * math.pi) * .08 : 0),
              child: CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _LumaPainter(_blink.value, _mouth.value, widget.mood, _t.value),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LumaPainter extends CustomPainter {
  final double blink, mouth, t;
  final LumaMood mood;
  _LumaPainter(this.blink, this.mouth, this.mood, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width * .36;

    // glow
    canvas.drawCircle(
      c,
      r * 1.5,
      Paint()
        ..shader = RadialGradient(colors: [Magic.sun.withOpacity(.55), Magic.sun.withOpacity(0)])
            .createShader(Rect.fromCircle(center: c, radius: r * 1.5)),
    );

    // body (rounded star)
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final rad = i.isEven ? r : r * .66;
      final a = -math.pi / 2 + i * math.pi / 5;
      final p = Offset(c.dx + rad * math.cos(a), c.dy + rad * math.sin(a));
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    path.close();
    final body = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFE680), Color(0xFFFFB84D)],
      ).createShader(Rect.fromCircle(center: c, radius: r));
    final round = Paint()
      ..color = const Color(0xFFFFCB57)
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = r * .32;
    canvas.drawPath(path, round);
    canvas.drawPath(path, body);

    // face
    final face = c + Offset(0, r * .08);
    final eyeDx = r * .26;
    final eyeY = face.dy - r * .06;
    final dark = Paint()..color = Magic.ink;
    final white = Paint()..color = Colors.white;

    if (mood == LumaMood.cheer) {
      final arc = Paint()
        ..color = Magic.ink
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = r * .09;
      for (final s in [-1, 1]) {
        canvas.drawArc(Rect.fromCenter(center: Offset(face.dx + s * eyeDx, eyeY + r * .03), width: r * .26, height: r * .26), math.pi, math.pi, false, arc);
      }
    } else if (mood == LumaMood.sleepy) {
      final line = Paint()
        ..color = Magic.ink
        ..strokeCap = StrokeCap.round
        ..strokeWidth = r * .08;
      for (final s in [-1, 1]) {
        canvas.drawLine(Offset(face.dx + s * eyeDx - r * .1, eyeY), Offset(face.dx + s * eyeDx + r * .1, eyeY), line);
      }
    } else {
      final eh = r * .32 * (1 - blink * .92);
      for (final s in [-1, 1]) {
        final e = Offset(face.dx + s * eyeDx, eyeY);
        canvas.drawOval(Rect.fromCenter(center: e, width: r * .24, height: eh), dark);
        if (blink < .5) canvas.drawCircle(e + Offset(-r * .04, -r * .05), r * .04, white);
      }
    }

    // cheeks
    final cheek = Paint()..color = Magic.candy.withOpacity(.45);
    canvas.drawCircle(Offset(face.dx - r * .46, face.dy + r * .14), r * .1, cheek);
    canvas.drawCircle(Offset(face.dx + r * .46, face.dy + r * .14), r * .1, cheek);

    // mouth
    final my = face.dy + r * .2;
    if (mouth > .02) {
      final m = Rect.fromCenter(center: Offset(face.dx, my + r * .04), width: r * .3, height: r * (.1 + .24 * mouth));
      canvas.drawOval(m, Paint()..color = const Color(0xFF7A2036));
    } else if (mood == LumaMood.oops) {
      final p = Path()
        ..moveTo(face.dx - r * .14, my + r * .06)
        ..quadraticBezierTo(face.dx, my - r * .06, face.dx + r * .14, my + r * .06);
      canvas.drawPath(p, Paint()..color = Magic.ink..style = PaintingStyle.stroke..strokeWidth = r * .07..strokeCap = StrokeCap.round);
    } else if (mood == LumaMood.think) {
      canvas.drawCircle(Offset(face.dx + r * .06, my + r * .04), r * .05, dark);
    } else {
      final p = Path()
        ..moveTo(face.dx - r * .18, my - r * .02)
        ..quadraticBezierTo(face.dx, my + r * .2, face.dx + r * .18, my - r * .02);
      canvas.drawPath(p, Paint()..color = Magic.ink..style = PaintingStyle.stroke..strokeWidth = r * .07..strokeCap = StrokeCap.round);
    }

    // orbiting sparkles
    for (var i = 0; i < 3; i++) {
      final a = (t + i / 3) * 2 * math.pi;
      final sp = Offset(c.dx + math.cos(a) * r * 1.35, c.dy + math.sin(a) * r * 1.1);
      final tw = .5 + .5 * math.sin(a * 3);
      canvas.drawCircle(sp, r * (.05 + .05 * tw), Paint()..color = Colors.white.withOpacity(.5 + .5 * tw));
    }
  }

  @override
  bool shouldRepaint(covariant _LumaPainter o) =>
      o.blink != blink || o.mouth != mouth || o.mood != mood || o.t != t;
}

/// Luma with a speech bubble. Tap Luma to hear the line again.
class LumaSays extends StatelessWidget {
  final String text;
  final LumaMood mood;
  final double lumaSize;
  final VoidCallback? onTap;
  const LumaSays({super.key, required this.text, this.mood = LumaMood.happy, this.lumaSize = 78, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Luma(size: lumaSize, mood: mood, onTap: onTap),
        const SizedBox(width: 6),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Container(
              key: ValueKey(text),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(24),
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(.18), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Text(text, style: Magic.title(Magic.ink, 20)),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
//  CONFETTI
// ============================================================

class MagicFx {
  static void confetti(BuildContext? context, {int count = 60}) {
    final ctx = context ?? Get.overlayContext;
    if (ctx == null) return;
    final overlay = Overlay.maybeOf(ctx, rootOverlay: true);
    if (overlay == null) return;
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => IgnorePointer(child: _ConfettiBurst(count: count, onDone: () => entry.remove())),
    );
    overlay.insert(entry);
  }
}

class _Particle {
  final double x, vx, vy, spin, size;
  final Color color;
  final int shape;
  _Particle(this.x, this.vx, this.vy, this.spin, this.size, this.color, this.shape);
}

class _ConfettiBurst extends StatefulWidget {
  final int count;
  final VoidCallback onDone;
  const _ConfettiBurst({required this.count, required this.onDone});

  @override
  State<_ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<_ConfettiBurst> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))
        ..forward().whenComplete(widget.onDone);
  late final List<_Particle> _ps;

  @override
  void initState() {
    super.initState();
    final rnd = math.Random();
    const colors = [Magic.sun, Magic.candy, Magic.sky, Magic.mint, Colors.white, Color(0xFFFF9F43)];
    _ps = List.generate(
      widget.count,
      (_) => _Particle(
        .5 + (rnd.nextDouble() - .5) * .3,
        (rnd.nextDouble() - .5) * 900,
        -500 - rnd.nextDouble() * 650,
        (rnd.nextDouble() - .5) * 14,
        6 + rnd.nextDouble() * 8,
        colors[rnd.nextInt(colors.length)],
        rnd.nextInt(3),
      ),
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (_, __) => CustomPaint(size: Size.infinite, painter: _ConfettiPainter(_ps, _c.value * 2.4)),
      );
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> ps;
  final double t;
  _ConfettiPainter(this.ps, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in ps) {
      final x = p.x * size.width + p.vx * t;
      final y = size.height * .72 + p.vy * t + 0.5 * 1500 * t * t;
      if (y > size.height + 40) continue;
      final paint = Paint()..color = p.color.withOpacity((1 - t / 2.6).clamp(0.0, 1.0));
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.spin * t);
      switch (p.shape) {
        case 0:
          canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * .55), paint);
          break;
        case 1:
          canvas.drawCircle(Offset.zero, p.size * .45, paint);
          break;
        default:
          final path = Path();
          for (var i = 0; i < 10; i++) {
            final r = (i.isEven ? p.size : p.size * .45);
            final a = -math.pi / 2 + i * math.pi / 5;
            final pt = Offset(r * math.cos(a), r * math.sin(a));
            i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
          }
          path.close();
          canvas.drawPath(path, paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter o) => o.t != t;
}
