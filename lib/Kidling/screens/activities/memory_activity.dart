// lib/Kidling/screens/activities/memory_activity.dart
//
// content: {'cards':[{'e':'🐶','n':'dog'},...], 'peek': 4}
// Gradual: more pairs and a shorter "peek" at the cards on each level.
// Luma says the name of every card you flip, which builds vocabulary too.

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:isapp/Kidling/controllers/activity_controller.dart';
import 'package:isapp/Kidling/controllers/audio_assistant_services.dart';
import 'package:isapp/Kidling/models/kidling_model.dart';
import 'package:isapp/Kidling/theme/magic_theme.dart';
import 'package:isapp/Kidling/widgets/magic_widgets.dart';

class _MCard {
  final String emoji, name;
  final int pair;
  bool up = false;
  bool matched = false;
  _MCard(this.emoji, this.name, this.pair);
}

class MemoryActivity extends StatefulWidget {
  final ActivityController controller;
  final Activity activity;
  const MemoryActivity({super.key, required this.controller, required this.activity});

  @override
  State<MemoryActivity> createState() => _MemoryActivityState();
}

class _MemoryActivityState extends State<MemoryActivity> {
  final AudioAssistantService _audio = AudioAssistantService.ensure();
  late final List<_MCard> _cards;
  late final int _pairs;
  late final int _peek;
  int _moves = 0;
  int _found = 0;
  int? _first;
  bool _busy = true;
  int _countdown = 0;
  String _msg = 'Remember the cards!';
  Timer? _timer;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    final raw = ((widget.activity.content['cards'] as List?) ?? const [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    final fallback = [
      {'e': '🐶', 'n': 'dog'}, {'e': '🐱', 'n': 'cat'}, {'e': '🐸', 'n': 'frog'}, {'e': '🐥', 'n': 'chick'},
    ];
    final src = raw.isEmpty ? fallback : raw;
    _pairs = src.length;
    _peek = (widget.activity.content['peek'] ?? 4) as int;
    _cards = [];
    for (var i = 0; i < src.length; i++) {
      _cards.add(_MCard(src[i]['e'].toString(), src[i]['n'].toString(), i));
      _cards.add(_MCard(src[i]['e'].toString(), src[i]['n'].toString(), i));
    }
    _cards.shuffle();
    widget.controller.setTotalSteps(_pairs);
    widget.controller.onReplay = () => _audio.speak('Find two cards that look the same.');
    widget.controller.onHint = _hint;
    WidgetsBinding.instance.addPostFrameCallback((_) => _startPeek());
  }

  Future<void> _startPeek() async {
    if (_disposed) return;
    setState(() {
      for (final c in _cards) {
        c.up = true;
      }
      _countdown = _peek;
    });
    _audio.speak('Look carefully and remember where everyone is hiding!');
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_disposed) return t.cancel();
      setState(() => _countdown--);
      if (_countdown <= 0) {
        t.cancel();
        setState(() {
          for (final c in _cards) {
            c.up = false;
          }
          _busy = false;
          _msg = 'Find the matching pairs!';
        });
        _audio.speak('Now find the matching pairs!');
      }
    });
  }

  void _hint() {
    // briefly show an unmatched pair's first card
    final idx = _cards.indexWhere((c) => !c.matched && !c.up);
    if (idx < 0 || _busy) return;
    final p = _cards[idx].pair;
    final other = _cards.indexWhere((c) => c.pair == p && !c.matched && !c.up && _cards.indexOf(c) != idx);
    _audio.speak('Here is a hint. Two of these are friends!');
    setState(() {
      _cards[idx].up = true;
      if (other >= 0) _cards[other].up = true;
      _busy = true;
    });
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (_disposed) return;
      setState(() {
        _cards[idx].up = false;
        if (other >= 0) _cards[other].up = false;
        _busy = false;
      });
    });
  }

  Future<void> _tap(int i) async {
    final c = _cards[i];
    if (_busy || c.up || c.matched) return;
    _audio.playSfx('flip');
    setState(() => c.up = true);
    _audio.speak(c.name);
    if (_first == null) {
      _first = i;
      return;
    }
    final a = _cards[_first!];
    _first = null;
    _moves++;
    _busy = true;
    await Future.delayed(const Duration(milliseconds: 900));
    if (_disposed) return;
    if (a.pair == c.pair) {
      setState(() {
        a.matched = true;
        c.matched = true;
        _found++;
        _msg = _audio.praiseLine();
      });
      widget.controller.recordAttempt(correct: true, item: c.name);
      widget.controller.stepDone();
      _audio.playSfx('correct');
      MagicFx.confetti(context, count: 24);
      _audio.speak('A match! ${c.name}!');
      if (_found == _pairs) {
        await Future.delayed(const Duration(milliseconds: 1800));
        if (_disposed) return;
        // Perfect = one move per pair. Up to 2 moves per pair still earns 3 stars.
        final acc = (math.min(1.0, (2.0 * _pairs) / _moves) * 100);
        widget.controller.completeActivity(accuracyOverride: acc, finalResults: {'moves': _moves});
        return;
      }
    } else {
      widget.controller.recordAttempt(correct: false, item: c.name);
      _audio.playSfx('wrong');
      setState(() {
        a.up = false;
        c.up = false;
        _msg = 'So close! Try again.';
      });
    }
    _busy = false;
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final n = _cards.length;
    const colsFor = {4: 2, 6: 3, 8: 4, 10: 5, 12: 4, 16: 4, 20: 5};
    final cols = colsFor[n] ?? 4;
    final rows = (n / cols).ceil();
    final color = widget.activity.world.color;

    return LayoutBuilder(builder: (context, box) {
      const gap = 10.0;
      final byW = (box.maxWidth - 40 - gap * (cols - 1)) / cols;
      final byH = (box.maxHeight - 150 - gap * (rows - 1)) / rows;
      final s = math.max(48.0, math.min(math.min(byW, byH), 130.0));
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
        child: Column(
          children: [
            LumaSays(text: _countdown > 0 ? '$_msg  $_countdown' : _msg, mood: _countdown > 0 ? LumaMood.think : LumaMood.happy),
            const SizedBox(height: 14),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: gap,
              runSpacing: gap,
              children: List.generate(n, (i) => _card(i, s, color)),
            ),
          ],
        ),
      );
    });
  }

  Widget _card(int i, double s, Color color) {
    final c = _cards[i];
    return GestureDetector(
      onTap: () => _tap(i),
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: c.up || c.matched ? 1 : 0),
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOut,
        builder: (_, v, __) {
          final showFront = v > .5;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, .0012)
              ..rotateY(math.pi * v),
            child: SizedBox(
              width: s,
              height: s,
              child: showFront
                  ? Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(math.pi),
                      child: Container(
                        decoration: BoxDecoration(
                          color: c.matched ? const Color(0xFFD9FFEE) : Colors.white,
                          borderRadius: BorderRadius.circular(s * .24),
                          border: Border.all(color: c.matched ? Magic.mint : Colors.white, width: 4),
                          boxShadow: c.matched ? Magic.glow(Magic.mint, blur: 18, a: .7) : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(c.emoji, style: TextStyle(fontSize: s * .55)),
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [color, Magic.dusk], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(s * .24),
                        border: Border.all(color: Colors.white.withOpacity(.7), width: 3),
                      ),
                      alignment: Alignment.center,
                      child: Text('⭐', style: TextStyle(fontSize: s * .38)),
                    ),
            ),
          );
        },
      ),
    );
  }
}
