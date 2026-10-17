// lib/Kidling/screens/activities/creativity_activity.dart
//
// Modes (content['mode']):
//   'free'   draw with normal or rainbow brush
//   'color'  content['template'] = house | flower | fish | butterfly
//            Luma guides zone by zone ("color the roof red"), teaching color names
//   'stamps' decorate a meadow with stickers

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:isapp/features/kidling/controllers/activity_controller.dart';
import 'package:isapp/features/kidling/controllers/audio_assistant_services.dart';
import 'package:isapp/features/kidling/models/content_bank.dart';
import 'package:isapp/features/kidling/models/kidling_model.dart';
import 'package:isapp/features/kidling/theme/magic_theme.dart';
import 'package:isapp/features/kidling/widgets/magic_widgets.dart';

class CreativityActivity extends StatelessWidget {
  final ActivityController controller;
  final Activity activity;
  const CreativityActivity({super.key, required this.controller, required this.activity});

  @override
  Widget build(BuildContext context) {
    switch ((activity.content['mode'] ?? activity.content['canvasType'] ?? 'free').toString()) {
      case 'color':
      case 'coloring':
        return _ColoringPage(controller: controller, activity: activity);
      case 'stamps':
        return _StampScene(controller: controller, activity: activity);
      default:
        return _FreeDraw(controller: controller, activity: activity);
    }
  }
}

const List<String> _paletteKeys = ['red', 'orange', 'yellow', 'green', 'blue', 'purple', 'pink', 'brown', 'black', 'white'];

class _Palette extends StatelessWidget {
  final String selected;
  final void Function(String key) onPick;
  const _Palette({required this.selected, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: _paletteKeys.map((k) {
          final sel = k == selected;
          final col = Bank.colors[k]!.color;
          return Bouncy(
            sound: false,
            onTap: () {
              onPick(k);
              AudioAssistantService.ensure().speak(Bank.colors[k]!.label);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.symmetric(horizontal: 5, vertical: sel ? 0 : 6),
              width: sel ? 52 : 40,
              height: sel ? 52 : 40,
              decoration: BoxDecoration(
                color: col,
                shape: BoxShape.circle,
                border: Border.all(color: sel ? Colors.white : Colors.white54, width: sel ? 5 : 2),
                boxShadow: sel ? Magic.glow(col, blur: 16, a: .9) : null,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ============================================================
//  FREE DRAW
// ============================================================

class _Stroke {
  final List<Offset> pts = [];
  final Color color;
  final double width;
  final bool rainbow;
  _Stroke(this.color, this.width, this.rainbow);
}

class _FreeDraw extends StatefulWidget {
  final ActivityController controller;
  final Activity activity;
  const _FreeDraw({required this.controller, required this.activity});

  @override
  State<_FreeDraw> createState() => _FreeDrawState();
}

class _FreeDrawState extends State<_FreeDraw> {
  final _audio = AudioAssistantService.ensure();
  final List<_Stroke> _strokes = [];
  String _color = 'purple';
  double _width = 12;
  bool _rainbow = false;

  @override
  void initState() {
    super.initState();
    widget.controller.setTotalSteps(4);
    widget.controller.onReplay = () => _audio.speak('Draw anything you imagine. There are no mistakes in art!');
    widget.controller.onHint = () => _audio.speak('Try the rainbow brush! Or draw a sun, a house, or your family.');
    WidgetsBinding.instance.addPostFrameCallback((_) => _audio.speak('Draw anything you imagine. There are no mistakes in art!'));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), boxShadow: Magic.glow(Magic.candy, blur: 26, a: .35)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: GestureDetector(
                onPanStart: (d) => setState(() => _strokes.add(_Stroke(Bank.colors[_color]!.color, _width, _rainbow)..pts.add(d.localPosition))),
                onPanUpdate: (d) => setState(() => _strokes.last.pts.add(d.localPosition)),
                onPanEnd: (_) {
                  widget.controller.stepDone();
                  if (_strokes.length == 5) _audio.speak('Beautiful! Keep going!');
                },
                child: CustomPaint(painter: _DrawPainter(_strokes), size: Size.infinite),
              ),
            ),
          ),
        ),
        _Palette(selected: _color, onPick: (k) => setState(() {
              _color = k;
              _rainbow = false;
            })),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _tool(Icons.brush_rounded, 'Thin', _width < 10, () => setState(() => _width = 6)),
              _tool(Icons.brush_rounded, 'Thick', _width >= 10, () => setState(() => _width = 16), big: true),
              _tool(Icons.auto_awesome_rounded, 'Rainbow', _rainbow, () => setState(() => _rainbow = !_rainbow)),
              _tool(Icons.undo_rounded, 'Undo', false, () => setState(() => _strokes.isNotEmpty ? _strokes.removeLast() : null)),
              BigButton(
                label: 'Done',
                color: Magic.mint,
                icon: Icons.check_rounded,
                onTap: () {
                  if (_strokes.length < 2) {
                    _audio.speak('Draw a little more first!');
                    return;
                  }
                  widget.controller.completeActivity(accuracyOverride: 100, finalResults: {'strokes': _strokes.length});
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tool(IconData i, String label, bool on, VoidCallback t, {bool big = false}) => Bouncy(
        onTap: t,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(big ? 11 : 9),
              decoration: BoxDecoration(color: on ? Magic.sun : Colors.white24, shape: BoxShape.circle),
              child: Icon(i, color: on ? Magic.ink : Colors.white, size: big ? 24 : 20),
            ),
            Text(label, style: Magic.body(Colors.white70, 11)),
          ],
        ),
      );
}

class _DrawPainter extends CustomPainter {
  final List<_Stroke> strokes;
  _DrawPainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in strokes) {
      final p = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = s.width
        ..color = s.color;
      if (s.pts.length == 1) {
        canvas.drawCircle(s.pts.first, s.width / 2, p..style = PaintingStyle.fill);
        continue;
      }
      if (!s.rainbow) {
        final path = Path()..moveTo(s.pts.first.dx, s.pts.first.dy);
        for (var i = 1; i < s.pts.length; i++) {
          path.lineTo(s.pts[i].dx, s.pts[i].dy);
        }
        canvas.drawPath(path, p);
      } else {
        for (var i = 1; i < s.pts.length; i++) {
          p.color = HSVColor.fromAHSV(1, (i * 9.0) % 360, .75, 1).toColor();
          canvas.drawLine(s.pts[i - 1], s.pts[i], p);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DrawPainter old) => true;
}

// ============================================================
//  COLORING PAGE (tap zones)
// ============================================================

class _Zone {
  final String name;
  final String suggested;
  final Path Function(Rect r) build;
  _Zone(this.name, this.suggested, this.build);
}

Path _oval(Rect r, double x, double y, double w, double h) =>
    Path()..addOval(Rect.fromLTWH(r.left + r.width * x, r.top + r.height * y, r.width * w, r.height * h));
Path _rect(Rect r, double x, double y, double w, double h) =>
    Path()..addRect(Rect.fromLTWH(r.left + r.width * x, r.top + r.height * y, r.width * w, r.height * h));
Path _poly(Rect r, List<List<double>> p) {
  final path = Path();
  for (var i = 0; i < p.length; i++) {
    final x = r.left + r.width * p[i][0], y = r.top + r.height * p[i][1];
    i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
  }
  return path..close();
}

Path _union(List<Path> ps) => ps.reduce((a, b) => Path.combine(PathOperation.union, a, b));

final Map<String, List<_Zone>> _templates = {
  'house': [
    _Zone('sky', 'blue', (r) => _rect(r, 0, 0, 1, .7)),
    _Zone('grass', 'green', (r) => _rect(r, 0, .7, 1, .3)),
    _Zone('wall', 'yellow', (r) => _rect(r, .22, .42, .56, .42)),
    _Zone('roof', 'red', (r) => _poly(r, [[.16, .43], [.5, .14], [.84, .43]])),
    _Zone('door', 'brown', (r) => _rect(r, .44, .6, .13, .24)),
    _Zone('window', 'blue', (r) => _rect(r, .29, .5, .12, .12)),
    _Zone('sun', 'orange', (r) => _oval(r, .74, .06, .18, .12)),
  ],
  'flower': [
    _Zone('sky', 'blue', (r) => _rect(r, 0, 0, 1, .8)),
    _Zone('stem', 'green', (r) => _rect(r, .47, .45, .06, .4)),
    _Zone('leaf', 'green', (r) => _union([_oval(r, .3, .62, .17, .09), _oval(r, .53, .55, .17, .09)])),
    _Zone('petals', 'pink', (r) => _union([_oval(r, .38, .12, .24, .16), _oval(r, .38, .4, .24, .16), _oval(r, .24, .26, .16, .24), _oval(r, .6, .26, .16, .24)])),
    _Zone('middle', 'yellow', (r) => _oval(r, .41, .27, .18, .18)),
    _Zone('pot', 'brown', (r) => _poly(r, [[.36, .83], [.64, .83], [.6, .97], [.4, .97]])),
  ],
  'fish': [
    _Zone('water', 'blue', (r) => _rect(r, 0, 0, 1, 1)),
    _Zone('tail', 'yellow', (r) => _poly(r, [[.66, .5], [.92, .28], [.92, .72]])),
    _Zone('body', 'orange', (r) => _oval(r, .12, .3, .6, .4)),
    _Zone('fin', 'red', (r) => _poly(r, [[.35, .32], [.5, .14], [.55, .34]])),
    _Zone('eye', 'white', (r) => _oval(r, .2, .4, .08, .08)),
    _Zone('bubbles', 'purple', (r) => _union([_oval(r, .08, .16, .06, .06), _oval(r, .14, .08, .05, .05), _oval(r, .06, .26, .04, .04)])),
  ],
  'butterfly': [
    _Zone('sky', 'blue', (r) => _rect(r, 0, 0, 1, 1)),
    _Zone('top wings', 'purple', (r) => _union([_oval(r, .1, .15, .38, .34), _oval(r, .52, .15, .38, .34)])),
    _Zone('bottom wings', 'pink', (r) => _union([_oval(r, .18, .5, .3, .28), _oval(r, .52, .5, .3, .28)])),
    _Zone('body', 'brown', (r) => _oval(r, .46, .2, .08, .6)),
    _Zone('spots', 'yellow', (r) => _union([_oval(r, .22, .26, .1, .1), _oval(r, .68, .26, .1, .1)])),
  ],
};

class _ColoringPage extends StatefulWidget {
  final ActivityController controller;
  final Activity activity;
  const _ColoringPage({required this.controller, required this.activity});

  @override
  State<_ColoringPage> createState() => _ColoringPageState();
}

class _ColoringPageState extends State<_ColoringPage> with SingleTickerProviderStateMixin {
  final _audio = AudioAssistantService.ensure();
  late final String _name = (widget.activity.content['template'] ?? 'house').toString();
  late final List<_Zone> _zones = _templates[_name] ?? _templates['house']!;
  late final List<String?> _fills = List.filled(_zones.length, null);
  late final AnimationController _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);
  String _color = 'red';
  bool _done = false;
  Rect _rect = Rect.zero;

  int get _next => _fills.indexWhere((f) => f == null);

  @override
  void initState() {
    super.initState();
    widget.controller.setTotalSteps(_zones.length);
    widget.controller.onReplay = _instruct;
    widget.controller.onHint = _instruct;
    WidgetsBinding.instance.addPostFrameCallback((_) => _instruct());
  }

  void _instruct() {
    final i = _next;
    if (i < 0) return;
    final z = _zones[i];
    _audio.speak('Let us color the ${z.name} ${Bank.colors[z.suggested]!.label}. Pick the ${Bank.colors[z.suggested]!.label} paint, then tap the ${z.name}.');
    if (mounted && _color != z.suggested) setState(() {});
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  void _tapAt(Offset p) {
    if (_done) return;
    for (var i = _zones.length - 1; i >= 0; i--) {
      if (_zones[i].build(_rect).contains(p)) {
        final wasEmpty = _fills[i] == null;
        final z = _zones[i];
        setState(() => _fills[i] = _color);
        _audio.playSfx('pop');
        if (wasEmpty) widget.controller.stepDone();
        final matches = _color == z.suggested;
        widget.controller.recordAttempt(correct: matches || !wasEmpty, item: z.suggested);
        _audio.speak(matches ? 'Yes! A ${Bank.colors[_color]!.label} ${z.name}!' : 'Nice! A ${Bank.colors[_color]!.label} ${z.name}. Pretty!');
        if (_fills.every((f) => f != null)) _finish();
        return;
      }
    }
  }

  Future<void> _finish() async {
    _done = true;
    MagicFx.confetti(context, count: 70);
    _audio.speak('Wow! What a beautiful picture. You are an artist!');
    await Future.delayed(const Duration(milliseconds: 2800));
    if (mounted) widget.controller.completeActivity(accuracyOverride: 100);
  }

  @override
  Widget build(BuildContext context) {
    final nxt = _next;
    return Column(
      children: [
        if (nxt >= 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LumaSays(
              text: 'Color the ${_zones[nxt].name} ${Bank.colors[_zones[nxt].suggested]!.label}!',
              lumaSize: 66,
              onTap: _instruct,
            ),
          ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), boxShadow: Magic.glow(Magic.candy, blur: 26, a: .35)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: LayoutBuilder(builder: (context, box) {
                final side = math.min(box.maxWidth, box.maxHeight) - 24;
                _rect = Rect.fromLTWH((box.maxWidth - side) / 2, (box.maxHeight - side) / 2, side, side);
                return GestureDetector(
                  onTapDown: (d) => _tapAt(d.localPosition),
                  child: AnimatedBuilder(
                    animation: _pulse,
                    builder: (_, __) => CustomPaint(
                      size: Size(box.maxWidth, box.maxHeight),
                      painter: _ZonePainter(_zones, _fills, _rect, nxt, _pulse.value),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        _Palette(selected: _color, onPick: (k) => setState(() => _color = k)),
        const SizedBox(height: 14),
      ],
    );
  }
}

class _ZonePainter extends CustomPainter {
  final List<_Zone> zones;
  final List<String?> fills;
  final Rect rect;
  final int highlight;
  final double pulse;
  _ZonePainter(this.zones, this.fills, this.rect, this.highlight, this.pulse);

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < zones.length; i++) {
      final path = zones[i].build(rect);
      final f = fills[i];
      canvas.drawPath(path, Paint()..color = f == null ? const Color(0xFFFAF7F2) : Bank.colors[f]!.color);
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeJoin = StrokeJoin.round
          ..color = Magic.ink.withOpacity(.55),
      );
      if (i == highlight) {
        canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4 + 5 * pulse
            ..color = Magic.sun.withOpacity(.5 + .5 * pulse),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ZonePainter old) => true;
}

// ============================================================
//  STAMP SCENE
// ============================================================

class _Stamp {
  final String emoji;
  final Offset pos;
  final double size;
  _Stamp(this.emoji, this.pos, this.size);
}

class _StampScene extends StatefulWidget {
  final ActivityController controller;
  final Activity activity;
  const _StampScene({required this.controller, required this.activity});

  @override
  State<_StampScene> createState() => _StampSceneState();
}

class _StampSceneState extends State<_StampScene> {
  final _audio = AudioAssistantService.ensure();
  static const _stickers = [
    ['🌳', 'tree'], ['🌸', 'flower'], ['🦋', 'butterfly'], ['🐝', 'bee'], ['☀️', 'sun'], ['🐇', 'rabbit'], ['🍄', 'mushroom'], ['🌈', 'rainbow'],
  ];
  static const int _goal = 6;
  final List<_Stamp> _stamps = [];
  int _sel = 0;
  final _rnd = math.Random();

  @override
  void initState() {
    super.initState();
    widget.controller.setTotalSteps(_goal);
    widget.controller.onReplay = () => _audio.speak('Pick a sticker, then tap the picture to place it. Place $_goal stickers.');
    widget.controller.onHint = widget.controller.onReplay;
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.controller.playInstruction());
  }

  void _place(Offset p) {
    setState(() => _stamps.add(_Stamp(_stickers[_sel][0], p, 44 + _rnd.nextDouble() * 30)));
    _audio.playSfx('pop');
    _audio.speak(_stickers[_sel][1]);
    if (_stamps.length <= _goal) widget.controller.stepDone();
    if (_stamps.length == _goal) {
      MagicFx.confetti(context, count: 50);
      _audio.speak('Great job! You can add more, or tap Done.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: LumaSays(text: _stamps.length < _goal ? 'Place $_goal stickers (${_stamps.length}/$_goal)' : 'Lovely! Tap Done when ready.', lumaSize: 66),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFBFE8FF), Color(0xFFE9F9D2), Color(0xFF8EDB7C)], stops: [0, .6, 1]),
              boxShadow: Magic.glow(Magic.mint, blur: 26, a: .35),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: GestureDetector(
                onTapDown: (d) => _place(d.localPosition),
                child: Stack(
                  children: [
                    const SizedBox.expand(),
                    for (final s in _stamps)
                      Positioned(
                        left: s.pos.dx - s.size / 2,
                        top: s.pos.dy - s.size / 2,
                        child: PopIn(duration: const Duration(milliseconds: 450), child: Text(s.emoji, style: TextStyle(fontSize: s.size))),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 66,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _stickers.length,
            itemBuilder: (_, i) => Bouncy(
              onTap: () {
                setState(() => _sel = i);
                _audio.speak(_stickers[i][1]);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                width: 56,
                decoration: BoxDecoration(
                  color: i == _sel ? Magic.sun : Colors.white24,
                  borderRadius: BorderRadius.circular(18),
                ),
                alignment: Alignment.center,
                child: Text(_stickers[i][0], style: const TextStyle(fontSize: 32)),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 14, top: 4),
          child: BigButton(
            label: 'Done',
            icon: Icons.check_rounded,
            color: Magic.mint,
            onTap: () {
              if (_stamps.length < 3) {
                _audio.speak('Place a few more stickers first!');
                return;
              }
              widget.controller.completeActivity(accuracyOverride: 100, finalResults: {'stamps': _stamps.length});
            },
          ),
        ),
      ],
    );
  }
}
