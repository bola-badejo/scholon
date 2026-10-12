// lib/Kidling/screens/activities/emotion_activity.dart
//
// Modes (content['mode']):
//   'faces'     content['emotions'] = ['happy','sad']        learn faces, then match situations
//   'scenarios' content['emotions'] = [...]                  situations -> feeling (no teaching cards)
//   'helping'   empathy: "Mia is sad. What can you do?"
//   'breathing' guided calm-down bubble (self regulation)

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:isapp/Kidling/controllers/activity_controller.dart';
import 'package:isapp/Kidling/controllers/audio_assistant_services.dart';
import 'package:isapp/Kidling/engine/lesson_engine.dart';
import 'package:isapp/Kidling/models/content_bank.dart';
import 'package:isapp/Kidling/models/kidling_model.dart';
import 'package:isapp/Kidling/theme/magic_theme.dart';
import 'package:isapp/Kidling/widgets/magic_widgets.dart';

class EmotionActivity extends StatelessWidget {
  final ActivityController controller;
  final Activity activity;
  const EmotionActivity({super.key, required this.controller, required this.activity});

  @override
  Widget build(BuildContext context) {
    final mode = (activity.content['mode'] ?? 'faces').toString();
    if (mode == 'breathing') return BreathingBubble(controller: controller, activity: activity);

    if (mode == 'helping') {
      final rounds = List<HelpScenario>.of(Bank.helping)..shuffle();
      LessonRound r(HelpScenario s, {bool first = false}) => LessonRound(
            prompt: s.text,
            speech: '${s.text} What can you do to help?',
            itemKey: 'kindness',
            hint: 'Think about how your friend feels. Be kind.',
            custom: (ctx, resolve) => _HelpChoices(scenario: s, onDone: resolve),
          );
      return LessonRunner(
        controller: controller,
        activity: activity,
        plan: LessonPlan(
          teach: [
            TeachCard(
              title: 'Being kind',
              subtitle: 'We help our friends feel better',
              color: Bank.feelings['happy']!.color,
              visual: const Text('🤝', style: TextStyle(fontSize: 96)),
              speech: 'When a friend feels sad or hurt, we can be kind. We can give a hug, say sorry, or help them. That is called empathy.',
            ),
          ],
          guided: rounds.take(2).map(r).toList(),
          challenge: rounds.skip(2).take(3).map(r).toList(),
        ),
      );
    }

    final keys = ((activity.content['emotions'] as List?) ?? ['happy', 'sad']).map((e) => e.toString()).where(Bank.feelings.containsKey).toList();
    final allKeys = Bank.feelings.keys.toList();
    FeelingInfo f(String k) => Bank.feelings[k]!;
    Choice face(String k) => Choice.emojiLabel(f(k).emoji, f(k).label, id: k);

    final teach = mode == 'scenarios'
        ? <TeachCard>[]
        : keys
            .map((k) => TeachCard(
                  title: 'This is a ${f(k).label.toLowerCase()} face',
                  subtitle: f(k).label,
                  color: f(k).color,
                  visual: Text(f(k).emoji, style: const TextStyle(fontSize: 120)),
                  speech: '${f(k).label}. ${f(k).when} ${f(k).tip} Can you make a ${f(k).label.toLowerCase()} face too?',
                  tapSpeech: f(k).label,
                ))
            .toList();

    List<String> opts(String k, int n) {
      final pool = keys.length > n ? keys : allKeys;
      return [k, ...Bank.others(pool, k, n)]..shuffle();
    }

    LessonRound scenario(String k, int idx, int n) {
      final s = f(k).situations[idx % f(k).situations.length];
      final o = opts(k, n);
      return LessonRound(
        prompt: 'How would you feel?',
        speech: '$s How would you feel?',
        display: Text(s, textAlign: TextAlign.center, style: Magic.title(Magic.ink, 24)),
        options: o.map(face).toList(),
        correct: o.indexOf(k),
        hint: f(k).when,
        itemKey: k,
      );
    }

    final order = List<String>.of(keys)..shuffle();
    final guided = order.map((k) => scenario(k, 0, 1)).toList();
    final challenge = <LessonRound>[];
    for (final k in order) {
      challenge.add(scenario(k, 1, 3));
      final o = opts(k, 3);
      challenge.add(LessonRound(
        prompt: 'Find the ${f(k).label.toLowerCase()} face',
        speech: 'Which face looks ${f(k).label.toLowerCase()}?',
        options: o.map(face).toList(),
        correct: o.indexOf(k),
        hint: f(k).tip,
        itemKey: k,
      ));
    }
    challenge.shuffle();

    return LessonRunner(
      controller: controller,
      activity: activity,
      plan: LessonPlan(teach: teach, guided: mode == 'scenarios' ? [...guided, ...order.map((k) => scenario(k, 1, 2))] : guided, challenge: challenge.take(7).toList()),
    );
  }
}

/// Wide answer buttons for the empathy questions.
class _HelpChoices extends StatefulWidget {
  final HelpScenario scenario;
  final void Function(bool firstTry) onDone;
  const _HelpChoices({required this.scenario, required this.onDone});

  @override
  State<_HelpChoices> createState() => _HelpChoicesState();
}

class _HelpChoicesState extends State<_HelpChoices> {
  bool _missed = false;
  int? _right;
  final Set<int> _wrong = {};

  void _tap(int i) {
    final audio = AudioAssistantService.ensure();
    if (_right != null || _wrong.contains(i)) return;
    if (i == widget.scenario.correct) {
      setState(() => _right = i);
      widget.onDone(!_missed);
    } else {
      _missed = true;
      audio.playSfx('wrong');
      audio.speak('Hmm. Is that kind? Try another one.');
      setState(() => _wrong.add(i));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(widget.scenario.options.length, (i) {
        final text = widget.scenario.options[i];
        final isRight = _right == i;
        final isWrong = _wrong.contains(i);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Bouncy(
            sound: false,
            onTap: () => _tap(i),
            child: AnimatedOpacity(
              opacity: isWrong ? .3 : 1,
              duration: const Duration(milliseconds: 250),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                decoration: BoxDecoration(
                  color: isRight ? const Color(0xFFD9FFEE) : Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: isRight ? Magic.mint : Colors.white, width: 4),
                ),
                child: Text(text, style: Magic.title(Magic.ink, 22)),
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ============================================================
//  BREATHING BUBBLE
// ============================================================

class BreathingBubble extends StatefulWidget {
  final ActivityController controller;
  final Activity activity;
  const BreathingBubble({super.key, required this.controller, required this.activity});

  @override
  State<BreathingBubble> createState() => _BreathingBubbleState();
}

class _BreathingBubbleState extends State<BreathingBubble> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 4));
  final AudioAssistantService _audio = AudioAssistantService.ensure();
  static const int _rounds = 4;
  int _round = 0;
  String _label = 'Get ready...';
  bool _started = false;
  bool _stopped = false;

  @override
  void initState() {
    super.initState();
    widget.controller.setTotalSteps(_rounds);
    widget.controller.onReplay = () => _audio.speak('Breathe in slowly through your nose. Then blow out like a candle.');
    widget.controller.onHint = widget.controller.onReplay;
    WidgetsBinding.instance.addPostFrameCallback((_) => _audio.speak('Let us calm our bodies. Breathe in as the bubble grows. Breathe out as it shrinks. Tap the bubble to start.'));
  }

  Future<void> _run() async {
    if (_started) return;
    _started = true;
    for (var i = 0; i < _rounds && !_stopped && mounted; i++) {
      setState(() {
        _round = i;
        _label = 'Breathe in...';
      });
      _audio.speak('Breathe in');
      await _c.forward(from: 0);
      if (_stopped || !mounted) return;
      setState(() => _label = 'Hold...');
      await Future.delayed(const Duration(milliseconds: 1200));
      if (_stopped || !mounted) return;
      setState(() => _label = 'Breathe out...');
      _audio.speak('Breathe out slowly');
      await _c.reverse();
      if (_stopped || !mounted) return;
      widget.controller.stepDone();
    }
    if (!mounted || _stopped) return;
    setState(() => _label = 'Calm and happy!');
    _audio.speak('Wonderful. You feel calm now. Great breathing!');
    MagicFx.confetti(context, count: 40);
    await Future.delayed(const Duration(milliseconds: 2500));
    if (mounted && !_stopped) widget.controller.completeActivity(accuracyOverride: 100);
  }

  @override
  void dispose() {
    _stopped = true;
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Bank.feelings['sleepy']!.color;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_label, style: Magic.title(Colors.white, 34)),
          const SizedBox(height: 8),
          Text(_started ? 'Breath ${math.min(_round + 1, _rounds)} of $_rounds' : 'Tap the bubble', style: Magic.body(Colors.white70, 18)),
          const SizedBox(height: 30),
          GestureDetector(
            onTap: _run,
            child: AnimatedBuilder(
              animation: _c,
              builder: (_, __) {
                final s = 120 + 150 * Curves.easeInOut.transform(_c.value);
                return Container(
                  width: s,
                  height: s,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [Colors.white.withOpacity(.9), color.withOpacity(.7), color.withOpacity(.25)]),
                    boxShadow: Magic.glow(color, blur: 40 + 30 * _c.value, a: .6),
                  ),
                  child: Center(child: Luma(size: s * .6, mood: _c.value > .5 ? LumaMood.happy : LumaMood.sleepy)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
