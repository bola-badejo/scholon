// lib/Kidling/engine/lesson_engine.dart
//
// THE LEARNING PROCEDURE (gradual release of responsibility)
//
//   1. LEARN            "I do"      Luma shows and says each item. No pressure.
//   2. TRY TOGETHER     "We do"     Few choices, hints, wrong answers fade out
//                                   so the child can never get stuck.
//   3. STAR CHALLENGE   "You do"    More choices, no help, mixed question types.
//
// Mistakes are not punished: a missed question comes back once at the end
// (spaced repetition inside the session) and the item is logged so parents can
// see exactly which letters / numbers / feelings need more practice.
// Only the FIRST try counts toward the score and the stars.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isapp/features/kidling/controllers/activity_controller.dart';
import 'package:isapp/features/kidling/controllers/audio_assistant_services.dart';
import 'package:isapp/features/kidling/models/kidling_model.dart';
import 'package:isapp/features/kidling/theme/magic_theme.dart';
import 'package:isapp/features/kidling/widgets/magic_widgets.dart';

// ============================================================
//  DATA
// ============================================================

/// Something to show and say in the LEARN phase.
class TeachCard {
  final String title;
  final String? subtitle;
  final Widget visual;
  final String speech;
  final String? tapSpeech;
  final Color color;
  final Future<void> Function()? play; // optional sound played after the speech
  const TeachCard({required this.title, this.subtitle, required this.visual, required this.speech, this.tapSpeech, this.color = Magic.sun, this.play});
}

/// One answer button.
class Choice {
  final String id;
  final Widget Function(double size) builder;
  const Choice(this.id, this.builder);

  factory Choice.emoji(String e, {String? id}) =>
      Choice(id ?? e, (s) => Text(e, style: TextStyle(fontSize: s * .52)));

  factory Choice.text(String t, {Color color = Magic.ink, double scale = .5, String? id}) => Choice(
        id ?? t,
        (s) => Padding(
          padding: const EdgeInsets.all(6),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(t, style: TextStyle(fontFamily: Magic.font, fontSize: s * scale, fontWeight: FontWeight.w700, color: color)),
          ),
        ),
      );

  factory Choice.swatch(Color c, {String? id}) => Choice(
        id ?? c.value.toString(),
        (s) => Container(
          width: s * .68,
          height: s * .68,
          decoration: BoxDecoration(
            color: c,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black.withOpacity(.12), width: 3),
            boxShadow: [BoxShadow(color: c.withOpacity(.5), blurRadius: 12)],
          ),
        ),
      );

  factory Choice.shape(String shape, Color color, {String? id}) =>
      Choice(id ?? '$shape-${color.value}', (s) => ShapeIcon(shape: shape, color: color, size: s * .72));

  factory Choice.emojiLabel(String e, String label, {String? id}) => Choice(
        id ?? label,
        (s) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(e, style: TextStyle(fontSize: s * .4)),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(label, style: TextStyle(fontFamily: Magic.font, fontSize: s * .15, fontWeight: FontWeight.w700, color: Magic.ink)),
            ),
          ],
        ),
      );
}

/// One question.
class LessonRound {
  final String prompt; // written in Luma's bubble
  final String speech; // spoken
  final Widget? display; // big picture above the answers
  final List<Choice> options;
  final int correct;
  final String? hint;
  final String? itemKey; // logged for parent insights ("B", "seven", "scared")
  final Future<void> Function()? replay; // replays a sound for listening questions
  final Widget Function(BuildContext context, void Function(bool firstTry) resolve)? custom;
  final bool isRetry;
  final bool autoReplay; // play [replay] automatically after the question is spoken

  const LessonRound({
    required this.prompt,
    required this.speech,
    this.display,
    this.options = const [],
    this.correct = 0,
    this.hint,
    this.itemKey,
    this.replay,
    this.custom,
    this.isRetry = false,
    this.autoReplay = false,
  });

  LessonRound retry() => LessonRound(
        prompt: prompt,
        speech: speech,
        display: display,
        options: options,
        correct: correct,
        hint: hint,
        itemKey: itemKey,
        replay: replay,
        custom: custom,
        isRetry: true,
        autoReplay: autoReplay,
      );
}

class LessonPlan {
  final List<TeachCard> teach;
  final List<LessonRound> guided;
  final List<LessonRound> challenge;
  const LessonPlan({this.teach = const [], this.guided = const [], this.challenge = const []});
  int get totalSteps => teach.length + guided.length + challenge.length;
}

// ============================================================
//  RUNNER
// ============================================================

class LessonRunner extends StatefulWidget {
  final ActivityController controller;
  final Activity activity;
  final LessonPlan plan;
  const LessonRunner({super.key, required this.controller, required this.activity, required this.plan});

  @override
  State<LessonRunner> createState() => _LessonRunnerState();
}

class _LessonRunnerState extends State<LessonRunner> {
  late final AudioAssistantService _audio = AudioAssistantService.ensure();
  ActivityController get _c => widget.controller;

  late final List<List<dynamic>> _lists; // [teach, guided, challenge]
  int _phase = 0;
  int _i = 0;
  bool _banner = true;
  bool _finished = false;
  int _gen = 0; // cancels stale delayed callbacks

  // per-question state
  int _misses = 0;
  bool _locked = false;
  final Set<int> _wrong = {};
  final Map<int, int> _shakes = {};
  int? _correctIdx;
  bool _glow = false;
  LumaMood _mood = LumaMood.happy;
  String _bubble = '';

  static const _phaseNames = ['Learn', 'Try', 'Star'];
  static const _bannerText = [
    ['Let us learn!', 'Look and listen. Tap Next when you are ready.'],
    ['Let us try together!', 'I will help you. Pick the right one.'],
    ['Star challenge!', 'Show me what you know!'],
  ];

  @override
  void initState() {
    super.initState();
    _lists = [List<TeachCard>.of(widget.plan.teach), List<LessonRound>.of(widget.plan.guided), List<LessonRound>.of(widget.plan.challenge)];
    _c.setTotalSteps(widget.plan.totalSteps);
    _c.onHint = _hint;
    _c.onReplay = _replay;
    final first = _firstPhaseFrom(0);
    _phase = first < 0 ? 0 : first;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (first < 0) {
        _finish();
      } else {
        _enterPhase(first);
      }
    });
  }

  @override
  void dispose() {
    _gen++;
    super.dispose();
  }

  int _firstPhaseFrom(int p) {
    for (var k = p; k < 3; k++) {
      if (_lists[k].isNotEmpty) return k;
    }
    return -1;
  }

  // ---------------- flow ----------------

  void _enterPhase(int p) {
    final g = ++_gen;
    setState(() {
      _phase = p;
      _i = 0;
      _banner = true;
      _mood = p == 2 ? LumaMood.cheer : LumaMood.happy;
    });
    _audio.speakSequence([_bannerText[p][0], _bannerText[p][1]]);
    Future.delayed(const Duration(milliseconds: 3300), () {
      if (!mounted || g != _gen) return;
      setState(() => _banner = false);
      _present();
    });
  }

  void _present() {
    _misses = 0;
    _locked = false;
    _wrong.clear();
    _correctIdx = null;
    _glow = false;
    _mood = LumaMood.happy;
    final g = _gen;
    if (_phase == 0) {
      final card = _lists[0][_i] as TeachCard;
      _bubble = card.title;
      _audio.speak(card.speech).then((_) {
        if (mounted && g == _gen) card.play?.call();
      });
    } else {
      final r = _lists[_phase][_i] as LessonRound;
      _bubble = r.prompt;
      _audio.speak(r.isRetry ? 'Let us try this one again. ${r.speech}' : r.speech).then((_) {
        if (mounted && g == _gen && r.autoReplay) r.replay?.call();
      });
    }
    if (mounted) setState(() {});
  }

  void _next() {
    _c.stepDone();
    _gen++;
    if (_i + 1 < _lists[_phase].length) {
      setState(() => _i++);
      _present();
    } else {
      final np = _firstPhaseFrom(_phase + 1);
      if (np < 0) {
        _finish();
      } else {
        _enterPhase(np);
      }
    }
  }

  Future<void> _finish() async {
    if (_finished) return;
    _finished = true;
    setState(() {
      _mood = LumaMood.cheer;
      _bubble = 'You did it!';
    });
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    await _c.completeActivity();
  }

  // ---------------- answering ----------------

  void _requeue(LessonRound r) {
    if (r.isRetry) return;
    _lists[_phase].add(r.retry());
    _c.addSteps(1);
  }

  Future<void> _choose(int idx, LessonRound r) async {
    if (_locked || _wrong.contains(idx)) return;
    if (idx == r.correct) {
      _locked = true;
      if (_misses == 0 && !r.isRetry) _c.recordAttempt(correct: true, item: r.itemKey);
      setState(() {
        _correctIdx = idx;
        _mood = LumaMood.cheer;
        _bubble = _audio.praiseLine();
      });
      _audio.playSfx('correct');
      MagicFx.confetti(context, count: 34);
      _audio.speak(_bubble);
      final g = _gen;
      await Future.delayed(const Duration(milliseconds: 1900));
      if (!mounted || g != _gen) return;
      _next();
    } else {
      _misses++;
      _wrong.add(idx);
      _shakes[idx] = (_shakes[idx] ?? 0) + 1;
      if (_misses == 1 && !r.isRetry) {
        _c.recordAttempt(correct: false, item: r.itemKey);
        _requeue(r);
      }
      _audio.playSfx('wrong');
      setState(() {
        _mood = LumaMood.oops;
        _glow = _misses >= 2 || (_phase == 1 && _misses >= 1 && r.options.length <= 2);
        _bubble = _misses == 1 ? _audio.oopsLine() : (r.hint ?? 'Look again!');
      });
      _audio.speak(_misses >= 2 ? (r.hint ?? 'Try the glowing one!') : _bubble);
    }
  }

  Future<void> _customResolved(bool firstTry, LessonRound r) async {
    if (_locked) return;
    _locked = true;
    if (!r.isRetry) _c.recordAttempt(correct: firstTry, item: r.itemKey);
    if (!firstTry) _requeue(r);
    setState(() {
      _mood = LumaMood.cheer;
      _bubble = _audio.praiseLine();
    });
    _audio.playSfx('correct');
    MagicFx.confetti(context, count: 34);
    _audio.speak(_bubble);
    final g = _gen;
    await Future.delayed(const Duration(milliseconds: 1900));
    if (!mounted || g != _gen) return;
    _next();
  }

  void _hint() {
    if (_banner || _finished) return;
    if (_phase == 0) {
      _replay();
      return;
    }
    final r = _lists[_phase][_i] as LessonRound;
    setState(() {
      _glow = true;
      _mood = LumaMood.think;
    });
    _audio.speak(r.hint ?? 'Look carefully. You can do it!');
  }

  void _replay() {
    if (_banner || _finished) return;
    if (_phase == 0) {
      final t = _lists[0][_i] as TeachCard;
      _audio.speak(t.tapSpeech ?? t.speech).then((_) => t.play?.call());
    } else {
      final r = _lists[_phase][_i] as LessonRound;
      if (r.replay != null) {
        r.replay!();
      } else {
        _audio.speak(r.speech);
      }
    }
  }

  // ---------------- build ----------------

  @override
  Widget build(BuildContext context) {
    final accent = widget.activity.world.color;
    return Column(
      children: [
        _phaseDots(accent),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 420),
            switchInCurve: Curves.easeOutBack,
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(.25, 0), end: Offset.zero).animate(anim),
                child: child,
              ),
            ),
            child: _banner ? _bannerView() : _content(accent),
          ),
        ),
      ],
    );
  }

  Widget _phaseDots(Color accent) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (k) {
          final active = k == _phase;
          final done = k < _phase;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: EdgeInsets.symmetric(horizontal: active ? 18 : 12, vertical: 6),
            decoration: BoxDecoration(
              color: active ? Magic.sun : Colors.white.withOpacity(done ? .45 : .18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (done) const Icon(Icons.check_rounded, size: 16, color: Magic.ink),
                if (k == 2) Icon(Icons.star_rounded, size: 16, color: active ? Magic.ink : Colors.white70),
                const SizedBox(width: 2),
                Text(_phaseNames[k], style: Magic.body(active || done ? Magic.ink : Colors.white70, 14)),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _bannerView() {
    return Center(
      key: ValueKey('banner$_phase'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Luma(size: 190, mood: _phase == 2 ? LumaMood.cheer : LumaMood.happy),
          const SizedBox(height: 18),
          PopIn(child: Text(_bannerText[_phase][0], style: Magic.title(Colors.white, 34), textAlign: TextAlign.center)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: Text(_bannerText[_phase][1], style: Magic.body(Colors.white70, 18), textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }

  Widget _content(Color accent) {
    if (_finished) {
      return Center(key: const ValueKey('done'), child: Luma(size: 200, mood: LumaMood.cheer));
    }
    final key = ValueKey('$_phase-$_i-${_lists[_phase].length}');
    return KeyedSubtree(
      key: key,
      child: _phase == 0 ? _teachView(_lists[0][_i] as TeachCard, accent) : _roundView(_lists[_phase][_i] as LessonRound, accent),
    );
  }

  // ---------------- teach ----------------

  Widget _teachView(TeachCard card, Color accent) {
    final last = _i == _lists[0].length - 1;
    return LayoutBuilder(builder: (context, box) {
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: box.maxHeight - 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LumaSays(text: card.title, mood: _mood, onTap: _replay),
              const SizedBox(height: 18),
              Bouncy(
                onTap: () => _audio.speak(card.tapSpeech ?? card.speech).then((_) => card.play?.call()),
                sound: false,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.white, card.color.withOpacity(.35)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: Magic.glow(card.color, blur: 30, a: .5),
                  ),
                  child: Column(
                    children: [
                      Floaty(amplitude: 12, child: card.visual),
                      if (card.subtitle != null) ...[
                        const SizedBox(height: 16),
                        Text(card.subtitle!, style: Magic.title(Magic.ink, 24), textAlign: TextAlign.center),
                      ],
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.volume_up_rounded, color: Magic.ink.withOpacity(.5)),
                          const SizedBox(width: 6),
                          Text('Tap to hear again', style: Magic.body(Magic.ink.withOpacity(.5), 14)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              BigButton(
                label: last ? 'Let us play!' : 'Next',
                icon: Icons.arrow_forward_rounded,
                color: Magic.candy,
                onTap: _next,
              ),
            ],
          ),
        ),
      );
    });
  }

  // ---------------- question ----------------

  Widget _roundView(LessonRound r, Color accent) {
    return LayoutBuilder(builder: (context, box) {
      final w = box.maxWidth;
      final n = r.options.length;
      double size;
      if (n <= 3) {
        size = ((w - 40 - 16 * (n - 1)) / (n == 0 ? 1 : n)).clamp(84.0, 150.0);
      } else {
        size = ((w - 40 - 16) / 2).clamp(90.0, 150.0);
      }

      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: box.maxHeight - 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LumaSays(text: _bubble.isEmpty ? r.prompt : _bubble, mood: _mood, onTap: _replay),
              if (r.replay != null) ...[
                const SizedBox(height: 10),
                BigButton(label: 'Listen', icon: Icons.volume_up_rounded, color: Magic.sky, onTap: () => r.replay!()),
              ],
              if (r.display != null) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.94),
                    borderRadius: BorderRadius.circular(36),
                    boxShadow: Magic.glow(accent, blur: 24, a: .35),
                  ),
                  child: Center(child: r.display!),
                ),
              ],
              const SizedBox(height: 18),
              if (r.custom != null)
                r.custom!(context, (first) => _customResolved(first, r))
              else
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  runSpacing: 16,
                  children: List.generate(n, (i) => _optionCard(i, r, size, accent)),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _optionCard(int i, LessonRound r, double size, Color accent) {
    final isWrong = _wrong.contains(i);
    final isCorrect = _correctIdx == i;
    final glow = _glow && i == r.correct && !isWrong && _correctIdx == null;
    return Shake(
      trigger: _shakes[i] ?? 0,
      child: AnimatedScale(
        scale: isCorrect ? 1.1 : 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.elasticOut,
        child: AnimatedOpacity(
          opacity: isWrong ? .3 : 1,
          duration: const Duration(milliseconds: 250),
          child: Bouncy(
            sound: false,
            onTap: isWrong ? null : () => _choose(i, r),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: isCorrect ? const Color(0xFFD9FFEE) : Colors.white,
                borderRadius: BorderRadius.circular(size * .28),
                border: Border.all(
                  color: isCorrect ? Magic.mint : (glow ? Magic.sun : Colors.white),
                  width: isCorrect || glow ? 5 : 2,
                ),
                boxShadow: isCorrect
                    ? Magic.glow(Magic.mint, blur: 28, a: .8)
                    : (glow ? Magic.glow(Magic.sun, blur: 30, a: .9) : [BoxShadow(color: Colors.black.withOpacity(.18), blurRadius: 10, offset: const Offset(0, 5))]),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Center(child: r.options[i].builder(size)),
                  if (isCorrect) const Positioned(top: 6, right: 8, child: Icon(Icons.check_circle_rounded, color: Magic.mint, size: 26)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
