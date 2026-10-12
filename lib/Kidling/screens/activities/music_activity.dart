// lib/Kidling/screens/activities/music_activity.dart
//
// Modes (content['mode']):
//   'sounds' / 'instruments'  content['items'] = [{'k':'Dog','emoji':'🐶','sound':'Woof woof'}]
//   'pitch'                   high or low? (auditory discrimination)
//   'piano'                   follow the glowing keys of a song, then free play
//   'simon'                   copy the colorful note pattern (content['length'])

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:isapp/Kidling/controllers/activity_controller.dart';
import 'package:isapp/Kidling/controllers/audio_assistant_services.dart';
import 'package:isapp/Kidling/engine/lesson_engine.dart';
import 'package:isapp/Kidling/models/kidling_model.dart';
import 'package:isapp/Kidling/theme/magic_theme.dart';
import 'package:isapp/Kidling/widgets/magic_widgets.dart';

const List<Color> _padColors = [
  Color(0xFFFF6F61), Color(0xFFFF9F43), Color(0xFFFFD66B), Color(0xFF5BE3A8),
  Color(0xFF5CC8FF), Color(0xFF7C83FF), Color(0xFFB65CFF), Color(0xFFFF6FB5),
];

class MusicActivity extends StatelessWidget {
  final ActivityController controller;
  final Activity activity;
  const MusicActivity({super.key, required this.controller, required this.activity});

  @override
  Widget build(BuildContext context) {
    final mode = (activity.content['mode'] ?? 'sounds').toString();
    switch (mode) {
      case 'piano':
        return PianoPlay(controller: controller, activity: activity);
      case 'simon':
        return SimonNotes(controller: controller, activity: activity);
      case 'pitch':
        return LessonRunner(controller: controller, activity: activity, plan: _pitchPlan());
      default:
        return LessonRunner(controller: controller, activity: activity, plan: _soundsPlan());
    }
  }

  // ------------------------------------------------------------
  LessonPlan _soundsPlan() {
    final audio = AudioAssistantService.ensure();
    final items = ((activity.content['items'] as List?) ?? const [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    if (items.isEmpty) return const LessonPlan();
    final color = activity.world.color;
    final instruments = (activity.content['mode'] ?? '') == 'instruments';
    String name(Map<String, dynamic> m) => m['k'].toString();

    final teach = items
        .map((m) => TeachCard(
              title: instruments ? 'This is a ${name(m).toLowerCase()}' : 'The ${name(m).toLowerCase()} says...',
              subtitle: m['sound'].toString(),
              color: color,
              visual: Text(m['emoji'].toString(), style: const TextStyle(fontSize: 120)),
              speech: instruments
                  ? 'A ${name(m).toLowerCase()}! It goes ${m['sound']}.'
                  : 'The ${name(m).toLowerCase()} says ${m['sound']}!',
              tapSpeech: m['sound'].toString(),
            ))
        .toList();

    LessonRound round(Map<String, dynamic> m, int n) {
      final others = (List<Map<String, dynamic>>.of(items)..removeWhere((x) => x['k'] == m['k'])..shuffle()).take(n).toList();
      final opts = [m, ...others]..shuffle();
      return LessonRound(
        prompt: instruments ? 'Which one makes this sound?' : 'Who makes this sound?',
        speech: 'Listen carefully.',
        options: opts.map((o) => Choice.emojiLabel(o['emoji'].toString(), name(o), id: name(o))).toList(),
        correct: opts.indexWhere((o) => o['k'] == m['k']),
        hint: 'Listen again. It goes ${m['sound']}. Which one goes ${m['sound']}?',
        itemKey: name(m),
        replay: () => audio.speak('${m['sound']}!'),
        autoReplay: true,
      );
    }

    final order = List<Map<String, dynamic>>.of(items)..shuffle();
    return LessonPlan(
      teach: teach,
      guided: order.map((m) => round(m, 1)).toList(),
      challenge: [...order, ...order.reversed].take(6).map((m) => round(m, 3)).toList(),
    );
  }

  // ------------------------------------------------------------
  LessonPlan _pitchPlan() {
    final audio = AudioAssistantService.ensure();
    final color = activity.world.color;
    final rnd = math.Random();

    Future<void> twoNotes(int a, int b) async {
      await audio.playNote(a, ms: 700);
      await Future.delayed(const Duration(milliseconds: 900));
      await audio.playNote(b, ms: 700);
    }

    final teach = [
      TeachCard(
        title: 'High sounds',
        subtitle: 'Like a little bird',
        color: color,
        visual: const Text('🐦', style: TextStyle(fontSize: 110)),
        speech: 'Some sounds are high, like a little bird. Listen.',
        play: () => audio.playNote(7, ms: 900),
      ),
      TeachCard(
        title: 'Low sounds',
        subtitle: 'Like a big elephant',
        color: color,
        visual: const Text('🐘', style: TextStyle(fontSize: 110)),
        speech: 'Some sounds are low, like a big elephant. Listen.',
        play: () => audio.playNote(0, ms: 900),
      ),
    ];

    LessonRound round(int lo, int hi, bool askHigher) {
      final highFirst = rnd.nextBool();
      final first = highFirst ? hi : lo;
      final second = highFirst ? lo : hi;
      final correct = askHigher ? (highFirst ? 0 : 1) : (highFirst ? 1 : 0);
      return LessonRound(
        prompt: askHigher ? 'Which sound was higher?' : 'Which sound was lower?',
        speech: askHigher ? 'Listen to two sounds. Which one is higher?' : 'Listen to two sounds. Which one is lower?',
        options: [Choice.emojiLabel('1️⃣', 'First', id: 'first'), Choice.emojiLabel('2️⃣', 'Second', id: 'second')],
        correct: correct,
        hint: 'High sounds are like a bird. Low sounds are like an elephant. Listen again.',
        itemKey: 'pitch',
        replay: () => twoNotes(first, second),
        autoReplay: true,
      );
    }

    return LessonPlan(
      teach: teach,
      guided: [round(0, 7, true), round(0, 7, false), round(1, 7, true)],
      challenge: [round(2, 6, true), round(1, 5, false), round(3, 5, true), round(0, 4, false), round(2, 4, true)],
    );
  }
}

// ============================================================
//  PIANO
// ============================================================

class PianoPlay extends StatefulWidget {
  final ActivityController controller;
  final Activity activity;
  const PianoPlay({super.key, required this.controller, required this.activity});

  @override
  State<PianoPlay> createState() => _PianoPlayState();
}

class _PianoPlayState extends State<PianoPlay> {
  final AudioAssistantService _audio = AudioAssistantService.ensure();
  // "Twinkle twinkle little star" (first line) in scale degrees
  static const List<int> _song = [0, 0, 4, 4, 5, 5, 4];
  static const List<String> _words = ['Twin', 'kle', 'twin', 'kle', 'lit', 'tle', 'star'];
  int _step = 0;
  int? _pressed;
  bool _free = false;
  int _freeNotes = 0;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    widget.controller.setTotalSteps(_song.length + 4);
    widget.controller.onReplay = () => _audio.speak('Press the glowing key.');
    widget.controller.onHint = widget.controller.onReplay;
    WidgetsBinding.instance.addPostFrameCallback((_) => _audio.speak('Let us play a song! Press the glowing keys.'));
  }

  Future<void> _press(int k) async {
    if (_finished) return;
    setState(() => _pressed = k);
    _audio.playNote(k);
    Future.delayed(const Duration(milliseconds: 220), () {
      if (mounted) setState(() => _pressed = null);
    });
    if (!_free) {
      if (k == _song[_step]) {
        widget.controller.recordAttempt(correct: true, item: 'piano');
        widget.controller.stepDone();
        _step++;
        if (_step >= _song.length) {
          setState(() => _free = true);
          MagicFx.confetti(context, count: 50);
          _audio.speakSequence(['You played Twinkle Twinkle Little Star!', 'Now play anything you like. Make your own song!']);
        } else {
          setState(() {});
        }
      } else {
        widget.controller.recordAttempt(correct: false, item: 'piano');
        _audio.speak('Try the glowing key.');
      }
    } else {
      _freeNotes++;
      if (_freeNotes <= 4) widget.controller.stepDone();
      setState(() {});
      if (_freeNotes == 8 && !_finished) {
        _finished = true;
        _audio.speak('What a beautiful song!');
        MagicFx.confetti(context, count: 60);
        await Future.delayed(const Duration(milliseconds: 1800));
        if (mounted) widget.controller.completeActivity();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final target = _free ? null : _song[_step];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        children: [
          LumaSays(
            text: _free ? 'Play your own song! (${math.min(_freeNotes, 8)}/8)' : 'Press the glowing key: ${_words[_step]}',
            mood: _free ? LumaMood.cheer : LumaMood.happy,
          ),
          const Spacer(),
          SizedBox(
            height: 300,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: List.generate(8, (k) {
                final glow = target == k;
                final down = _pressed == k;
                return Expanded(
                  child: GestureDetector(
                    onTapDown: (_) => _press(k),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      margin: EdgeInsets.only(left: 2, right: 2, top: down ? 10 : 0),
                      decoration: BoxDecoration(
                        color: down ? _padColors[k] : (glow ? _padColors[k].withOpacity(.85) : Colors.white),
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
                        border: Border.all(color: glow ? Magic.sun : Colors.white54, width: glow ? 4 : 1.5),
                        boxShadow: glow ? Magic.glow(_padColors[k], blur: 26, a: .9) : null,
                      ),
                      alignment: Alignment.bottomCenter,
                      padding: const EdgeInsets.only(bottom: 12),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(AudioAssistantService.noteNames[k], style: Magic.title(glow || down ? Colors.white : Magic.ink, 15)),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

// ============================================================
//  SIMON NOTES (copy the pattern)
// ============================================================

class SimonNotes extends StatefulWidget {
  final ActivityController controller;
  final Activity activity;
  const SimonNotes({super.key, required this.controller, required this.activity});

  @override
  State<SimonNotes> createState() => _SimonNotesState();
}

class _SimonNotesState extends State<SimonNotes> {
  final AudioAssistantService _audio = AudioAssistantService.ensure();
  final math.Random _rnd = math.Random();
  static const int _pads = 4;
  late final int _maxLen = (widget.activity.content['length'] ?? 3) as int;
  late final int _startLen = math.max(2, _maxLen - 2);
  final List<int> _seq = [];
  int _input = 0;
  int? _lit;
  bool _listening = false; // Luma is playing
  bool _finished = false;
  bool _missedThisRound = false;
  String _msg = 'Watch and listen!';
  int _gen = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.setTotalSteps(_maxLen - _startLen + 1);
    widget.controller.onReplay = _playSequence;
    widget.controller.onHint = _playSequence;
    WidgetsBinding.instance.addPostFrameCallback((_) => _newRound(_startLen));
  }

  @override
  void dispose() {
    _gen++;
    super.dispose();
  }

  Future<void> _newRound(int len) async {
    _seq
      ..clear()
      ..addAll(List.generate(len, (_) => _rnd.nextInt(_pads)));
    _missedThisRound = false;
    await _audio.speak('Listen to my song. Then copy it!');
    await _playSequence();
  }

  Future<void> _playSequence() async {
    final g = ++_gen;
    setState(() {
      _listening = true;
      _input = 0;
      _msg = 'Watch and listen!';
    });
    await Future.delayed(const Duration(milliseconds: 500));
    for (final k in _seq) {
      if (!mounted || g != _gen) return;
      setState(() => _lit = k);
      _audio.playNote(k * 2, ms: 500);
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted || g != _gen) return;
      setState(() => _lit = null);
      await Future.delayed(const Duration(milliseconds: 180));
    }
    if (!mounted || g != _gen) return;
    setState(() {
      _listening = false;
      _msg = 'Your turn! Copy the song.';
    });
    _audio.speak('Your turn!');
  }

  Future<void> _tap(int k) async {
    if (_listening || _finished) return;
    setState(() => _lit = k);
    _audio.playNote(k * 2, ms: 450);
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) setState(() => _lit = null);
    });
    if (k == _seq[_input]) {
      _input++;
      if (_input >= _seq.length) {
        widget.controller.recordAttempt(correct: !_missedThisRound, item: 'rhythm');
        widget.controller.stepDone();
        MagicFx.confetti(context, count: 40);
        _audio.speak(_audio.praiseLine());
        await Future.delayed(const Duration(milliseconds: 2000));
        if (!mounted) return;
        if (_seq.length >= _maxLen) {
          _finished = true;
          widget.controller.completeActivity();
        } else {
          _newRound(_seq.length + 1);
        }
      }
    } else {
      _missedThisRound = true;
      _audio.playSfx('wrong');
      _audio.speak('Oops! Listen again.');
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) _playSequence();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        children: [
          LumaSays(text: _msg, mood: _listening ? LumaMood.think : LumaMood.happy, onTap: _playSequence),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _seq.length,
              (i) => Container(
                margin: const EdgeInsets.all(4),
                width: 14,
                height: 14,
                decoration: BoxDecoration(shape: BoxShape.circle, color: i < _input ? Magic.sun : Colors.white30),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                physics: const NeverScrollableScrollPhysics(),
                children: List.generate(_pads, (k) {
                  final lit = _lit == k;
                  final c = _padColors[k * 2];
                  return GestureDetector(
                    onTapDown: (_) => _tap(k),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      decoration: BoxDecoration(
                        color: lit ? c : c.withOpacity(.45),
                        borderRadius: BorderRadius.circular(36),
                        border: Border.all(color: Colors.white.withOpacity(lit ? 1 : .4), width: lit ? 6 : 3),
                        boxShadow: lit ? Magic.glow(c, blur: 40, a: 1) : null,
                      ),
                      child: Center(
                        child: AnimatedScale(
                          scale: lit ? 1.3 : 1,
                          duration: const Duration(milliseconds: 150),
                          child: const Text('🎵', style: TextStyle(fontSize: 44)),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
