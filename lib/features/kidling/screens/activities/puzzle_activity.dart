// lib/Kidling/screens/activities/puzzle_activity.dart
//
// Modes (content['mode']):
//   'jigsaw'  rows, cols, pictures:[emoji,...]   round 1 has a ghost guide, round 2 does not
//   'pattern' kinds:['AB','AAB','ABC']           what comes next?
//   'odd'     groups:[['🍎','🚗'],...]           which one is different?

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:isapp/features/kidling/controllers/activity_controller.dart';
import 'package:isapp/features/kidling/controllers/audio_assistant_services.dart';
import 'package:isapp/features/kidling/engine/lesson_engine.dart';
import 'package:isapp/features/kidling/models/content_bank.dart';
import 'package:isapp/features/kidling/models/kidling_model.dart';
import 'package:isapp/features/kidling/theme/magic_theme.dart';
import 'package:isapp/features/kidling/widgets/magic_widgets.dart';

class _Pat {
  final List<String> shown;
  final String answer;
  final List<String> pool;
  _Pat(this.shown, this.answer, this.pool);
}

class PuzzleActivity extends StatelessWidget {
  final ActivityController controller;
  final Activity activity;
  const PuzzleActivity({super.key, required this.controller, required this.activity});

  @override
  Widget build(BuildContext context) {
    final mode = (activity.content['mode'] ?? 'jigsaw').toString();
    if (mode == 'pattern') return LessonRunner(controller: controller, activity: activity, plan: _patternPlan());
    if (mode == 'odd') return LessonRunner(controller: controller, activity: activity, plan: _oddPlan());
    return JigsawGame(controller: controller, activity: activity);
  }

  // ------------------------------------------------------------
  //  PATTERNS
  // ------------------------------------------------------------
  Widget _row(List<String> seq, {bool hideLast = false, String? reveal}) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final e in seq) Text(e, style: const TextStyle(fontSize: 46)),
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: reveal != null ? Colors.white : Magic.sun.withOpacity(.35),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Magic.sun, width: 3),
          ),
          alignment: Alignment.center,
          child: reveal != null ? Text(reveal, style: const TextStyle(fontSize: 40)) : Text('?', style: Magic.title(Magic.dusk, 36)),
        ),
      ],
    );
  }

  /// Builds the visible part of a pattern and its answer.
  _Pat _make(String kind) {
    final pools = List<List<String>>.of(Bank.patternPools)..shuffle();
    final pool = List<String>.of(pools.first)..shuffle();
    final a = pool[0], b = pool[1], c = pool[2];
    switch (kind) {
      case 'AAB':
        return _Pat([a, a, b, a, a], b, pool);
      case 'ABC':
        return _Pat([a, b, c, a, b], c, pool);
      default:
        return _Pat([a, b, a, b], a, pool);
    }
  }

  LessonPlan _patternPlan() {
    final kinds = ((activity.content['kinds'] as List?) ?? const ['AB']).map((e) => e.toString()).toList();
    final color = activity.world.color;

    final teach = kinds.map((k) {
      final p = _make(k);
      return TeachCard(
        title: 'A pattern repeats',
        subtitle: 'It goes round and round',
        color: color,
        visual: _row(p.shown, reveal: p.answer),
        speech: 'Look at this pattern. It repeats, again and again. What comes next? The answer is shown in the box.',
        tapSpeech: 'The pattern repeats.',
      );
    }).toList();

    LessonRound round(String kind, int n) {
      final p = _make(kind);
      final distract = <String>[...p.pool.where((x) => x != p.answer), ...Bank.patternPools.expand((x) => x).where((x) => x != p.answer && !p.pool.contains(x))];
      final opts = [p.answer, ...distract.take(n)]..shuffle();
      return LessonRound(
        prompt: 'What comes next?',
        speech: 'Look at the pattern. What comes next?',
        display: _row(p.shown),
        options: opts.map((e) => Choice.emoji(e)).toList(),
        correct: opts.indexOf(p.answer),
        hint: 'Say the pattern out loud. Then say what comes after the last one.',
        itemKey: 'pattern-$kind',
      );
    }

    return LessonPlan(
      teach: teach,
      guided: [for (var i = 0; i < 3; i++) round(kinds[i % kinds.length], 1)],
      challenge: [for (var i = 0; i < 5; i++) round(kinds[i % kinds.length], 3)],
    );
  }

  // ------------------------------------------------------------
  //  ODD ONE OUT
  // ------------------------------------------------------------
  LessonPlan _oddPlan() {
    final groups = ((activity.content['groups'] as List?) ?? const [])
        .map((g) => (g as List).map((e) => e.toString()).toList())
        .toList();
    if (groups.isEmpty) return const LessonPlan();
    final color = activity.world.color;

    LessonRound round(List<String> g, int total) {
      final odd = g[1];
      final same = g[0];
      final opts = [for (var i = 0; i < total - 1; i++) same, odd]..shuffle();
      return LessonRound(
        prompt: 'Which one is different?',
        speech: 'Look carefully. Which one is different from the others?',
        options: opts.map((e) => Choice.emoji(e)).toList(),
        correct: opts.indexOf(odd),
        hint: 'Most of them are the same. Find the one that is not.',
        itemKey: 'odd',
      );
    }

    final order = List<List<String>>.of(groups)..shuffle();
    return LessonPlan(
      teach: [
        TeachCard(
          title: 'Odd one out',
          subtitle: 'One of them is different',
          color: color,
          visual: Row(mainAxisSize: MainAxisSize.min, children: [
            for (final e in [groups.first[0], groups.first[0], groups.first[1], groups.first[0]]) Text(e, style: const TextStyle(fontSize: 50)),
          ]),
          speech: 'Three are the same, and one is different. That one is the odd one out. Can you spot it?',
        ),
      ],
      guided: order.take(3).map((g) => round(g, 3)).toList(),
      challenge: [for (var i = 0; i < 5; i++) round(order[i % order.length], 4)],
    );
  }
}

// ============================================================
//  JIGSAW
// ============================================================

class JigsawGame extends StatefulWidget {
  final ActivityController controller;
  final Activity activity;
  const JigsawGame({super.key, required this.controller, required this.activity});

  @override
  State<JigsawGame> createState() => _JigsawGameState();
}

class _JigsawGameState extends State<JigsawGame> {
  final AudioAssistantService _audio = AudioAssistantService.ensure();
  late final int rows = (widget.activity.content['rows'] ?? widget.activity.content['gridSize'] ?? 2) as int;
  late final int cols = (widget.activity.content['cols'] ?? widget.activity.content['gridSize'] ?? 2) as int;
  late final List<String> pictures = ((widget.activity.content['pictures'] as List?) ?? const ['🐮', '🐷'])
      .map((e) => e.toString())
      .toList();

  int _round = 0; // 0 = with ghost guide, 1 = without
  late List<int> _tray;
  late Set<int> _placed;
  int? _selected;
  int _shake = 0;
  int _wrongDrops = 0;
  bool _busy = false;

  int get pieces => rows * cols;
  String get picture => pictures[_round % pictures.length];

  @override
  void initState() {
    super.initState();
    widget.controller.setTotalSteps(pieces * 2);
    widget.controller.onReplay = () => _audio.speak('Drag each piece to the right place to make the picture.');
    widget.controller.onHint = () {
      setState(_showHintFlash);
      _audio.speak('Look at the small picture. Where does this piece go?');
    };
    _startRound();
  }

  bool _hintFlash = false;
  void _showHintFlash() {
    _hintFlash = true;
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _hintFlash = false);
    });
  }

  void _startRound() {
    _tray = List<int>.generate(pieces, (i) => i)..shuffle();
    _placed = {};
    _selected = null;
    _busy = false;
    WidgetsBinding.instance.addPostFrameCallback((_) => _audio.speak(_round == 0
        ? 'Let us build a puzzle! Drag each piece to the faded picture.'
        : 'Now try the next puzzle. This time there is no faded picture. Use the small picture to help you!'));
  }

  Future<void> _drop(int piece, int slot) async {
    if (_busy || _placed.contains(slot)) return;
    if (piece == slot) {
      widget.controller.recordAttempt(correct: true, item: 'jigsaw');
      widget.controller.stepDone();
      _audio.playSfx('pop');
      setState(() {
        _placed.add(slot);
        _tray.remove(piece);
        _selected = null;
      });
      if (_placed.length == pieces) {
        _busy = true;
        MagicFx.confetti(context, count: 50);
        _audio.playSfx('correct');
        if (_round == 0) {
          await _audio.speak('You built it! Amazing!');
          if (!mounted) return;
          setState(() {
            _round = 1;
            _startRound();
          });
        } else {
          _audio.speak(_audio.praiseLine());
          await Future.delayed(const Duration(milliseconds: 1800));
          if (mounted) widget.controller.completeActivity();
        }
      }
    } else {
      _wrongDrops++;
      widget.controller.recordAttempt(correct: false, item: 'jigsaw');
      _audio.playSfx('wrong');
      _audio.speak('Not there. Try another spot.');
      setState(() => _shake++);
    }
  }

  Widget _tile(int index, double pw, double ph, {double opacity = 1}) {
    final r = index ~/ cols, c = index % cols;
    final ax = cols == 1 ? 0.0 : -1 + 2 * c / (cols - 1);
    final ay = rows == 1 ? 0.0 : -1 + 2 * r / (rows - 1);
    final full = Size(pw * cols, ph * rows);
    return Opacity(
      opacity: opacity,
      child: SizedBox(
        width: pw,
        height: ph,
        child: ClipRect(
          child: OverflowBox(
            alignment: Alignment(ax, ay),
            minWidth: full.width,
            maxWidth: full.width,
            minHeight: full.height,
            maxHeight: full.height,
            child: SizedBox(
              width: full.width,
              height: full.height,
              child: Center(child: Text(picture, style: TextStyle(fontSize: math.min(full.width, full.height) * .78))),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      final boardW = math.min(box.maxWidth - 48, 320.0);
      final pw = boardW / cols;
      final ph = pw; // square pieces
      final boardH = ph * rows;
      final trayPiece = math.min(pw, 84.0);
      final tpw = trayPiece, tph = trayPiece;

      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          children: [
            LumaSays(
              text: _round == 0 ? 'Drag the pieces to the faded picture' : 'Now without the faded picture!',
              mood: LumaMood.happy,
              onTap: widget.controller.playInstruction,
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // preview
                Column(
                  children: [
                    Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: _hintFlash ? Magic.sun : Colors.white, width: _hintFlash ? 5 : 2)),
                      alignment: Alignment.center,
                      child: Text(picture, style: const TextStyle(fontSize: 38)),
                    ),
                    const SizedBox(height: 4),
                    Text('Goal', style: Magic.body(Colors.white70, 12)),
                  ],
                ),
                const SizedBox(width: 14),
                // board
                Shake(
                  trigger: _shake,
                  child: Container(
                    width: boardW + 12,
                    height: boardH + 12,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(.95), borderRadius: BorderRadius.circular(24), boxShadow: Magic.glow(widget.activity.world.color, blur: 28, a: .5)),
                    child: Stack(
                      children: [
                        for (var i = 0; i < pieces; i++)
                          Positioned(
                            left: (i % cols) * pw,
                            top: (i ~/ cols) * ph,
                            child: DragTarget<int>(
                              onWillAccept: (_) => true,
                              onAccept: (d) => _drop(d, i),
                              builder: (ctx, cand, rej) {
                                final placed = _placed.contains(i);
                                return GestureDetector(
                                  onTap: () {
                                    if (_selected != null) _drop(_selected!, i);
                                  },
                                  child: Container(
                                    width: pw,
                                    height: ph,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: cand.isNotEmpty ? Magic.sun : Colors.black12, width: cand.isNotEmpty ? 3 : 1),
                                      color: cand.isNotEmpty ? Magic.sun.withOpacity(.25) : Colors.transparent,
                                    ),
                                    child: placed ? _tile(i, pw - 2, ph - 2) : (_round == 0 ? _tile(i, pw - 2, ph - 2, opacity: .22) : null),
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white.withOpacity(.16), borderRadius: BorderRadius.circular(28), border: Border.all(color: Colors.white38)),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final p in _tray)
                    Draggable<int>(
                      data: p,
                      onDragStarted: () => setState(() => _selected = p),
                      feedback: Material(color: Colors.transparent, child: Transform.scale(scale: 1.15, child: _pieceCard(p, tpw, tph))),
                      childWhenDragging: Opacity(opacity: .25, child: _pieceCard(p, tpw, tph)),
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _selected = _selected == p ? null : p);
                          _audio.playSfx('tap');
                        },
                        child: _pieceCard(p, tpw, tph, selected: _selected == p),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text('Tip: drag a piece, or tap a piece and then tap its place.', style: Magic.body(Colors.white70, 13), textAlign: TextAlign.center),
          ],
        ),
      );
    });
  }

  Widget _pieceCard(int p, double w, double h, {bool selected = false}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: selected ? Magic.sun : Colors.white, width: selected ? 4 : 2),
        color: Colors.white,
        boxShadow: selected ? Magic.glow(Magic.sun, blur: 16, a: .8) : null,
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(8), child: _tile(p, w, h)),
    );
  }
}
