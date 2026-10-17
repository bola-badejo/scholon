// lib/Kidling/screens/activities/counting_activity.dart
//
// content: {'min':1, 'max':5, 'object':'🍎', 'task':'count'|'give'|'mixed'}
//
// LEARN : tap each object, hear 1, 2, 3 ... (one-to-one correspondence)
// TRY   : "How many?" with two number choices; touching objects helps
// STAR  : "How many?" with four choices and "Give me N" (child builds the set)

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:isapp/features/kidling/controllers/activity_controller.dart';
import 'package:isapp/features/kidling/controllers/audio_assistant_services.dart';
import 'package:isapp/features/kidling/engine/lesson_engine.dart';
import 'package:isapp/features/kidling/models/content_bank.dart';
import 'package:isapp/features/kidling/models/kidling_model.dart';
import 'package:isapp/features/kidling/theme/magic_theme.dart';
import 'package:isapp/features/kidling/widgets/magic_widgets.dart';

class CountingActivity extends StatelessWidget {
  final ActivityController controller;
  final Activity activity;
  const CountingActivity({super.key, required this.controller, required this.activity});

  @override
  Widget build(BuildContext context) {
    final min = (activity.content['min'] ?? 1) as int;
    final max = (activity.content['maxNumber'] ?? activity.content['max'] ?? 5) as int;
    final obj = (activity.content['object'] ?? '🍎').toString();
    final task = (activity.content['task'] ?? 'count').toString();
    final name = Bank.objectNames[obj] ?? 'thing';
    final rnd = math.Random();
    final color = activity.world.color;

    String plural(int n) => n == 1 ? name : '${name}s';
    String say(int n) => '${Bank.numberWords[n]} ${plural(n)}';

    List<int> spread(int count) {
      final range = [for (var i = min; i <= max; i++) i];
      if (range.length <= count) return range;
      final out = <int>{min, max};
      while (out.length < count) {
        out.add(range[rnd.nextInt(range.length)]);
      }
      return out.toList()..sort();
    }

    // ---------- LEARN ----------
    final teachNums = (max - min + 1) <= 5 ? [for (var i = min; i <= max; i++) i] : spread(4);
    final teach = teachNums.map((n) {
      final counted = List.generate(n, (i) => Bank.numberWords[i + 1]).join(', ');
      return TeachCard(
        title: 'Let us count to $n',
        subtitle: '$n',
        color: color,
        visual: CountObjects(emoji: obj, n: n, size: n > 10 ? 36 : 52, showNumber: true),
        speech: 'Let us count. Touch each one. $counted. ${say(n)}!',
        tapSpeech: '${Bank.numberWords[n]}',
      );
    }).toList();

    // ---------- helpers ----------
    List<int> numberOptions(int n, int count) {
      final pool = <int>{n};
      var d = 1;
      while (pool.length < count && d < 12) {
        if (n - d >= math.max(1, min - 1)) pool.add(n - d);
        if (pool.length < count && n + d <= max + 2) pool.add(n + d);
        d++;
      }
      return pool.toList()..shuffle();
    }

    LessonRound howMany(int n, int options) {
      final o = numberOptions(n, options);
      return LessonRound(
        prompt: 'How many ${plural(2)}?',
        speech: 'How many ${plural(2)} can you see? Touch each one and count.',
        display: CountObjects(emoji: obj, n: n, size: n > 10 ? 34 : 50, showNumber: false),
        options: o.map((x) => Choice.text('$x', color: color, scale: .6, id: '$x')).toList(),
        correct: o.indexOf(n),
        hint: 'Touch each one and count. One, two, three... Keep going!',
        itemKey: Bank.numberWords[n],
        replay: () => AudioAssistantService.ensure().speak('How many ${plural(2)}?'),
      );
    }

    LessonRound giveMe(int n) => LessonRound(
          prompt: 'Give me ${Bank.numberWords[n]}!',
          speech: 'Give me ${say(n)}. Tap the ${plural(2)} to put them in the basket.',
          itemKey: Bank.numberWords[n],
          hint: 'Count as you tap. I need ${Bank.numberWords[n]}.',
          custom: (ctx, resolve) => GiveMe(emoji: obj, target: n, spokenName: plural(2), onDone: resolve),
        );

    final nums = [for (var i = min; i <= max; i++) i]..shuffle();
    List<int> take(int k) => [for (var i = 0; i < k; i++) nums[i % nums.length]];

    final guided = take(math.min(4, nums.length + 1)).map((n) => howMany(n, 2)).toList();

    final challenge = <LessonRound>[];
    final targets = take(5);
    for (var i = 0; i < targets.length; i++) {
      final giveTurn = task == 'give' || (task == 'mixed' && i.isOdd);
      challenge.add(giveTurn ? giveMe(targets[i]) : howMany(targets[i], 4));
    }

    return LessonRunner(controller: controller, activity: activity, plan: LessonPlan(teach: teach, guided: guided, challenge: challenge));
  }
}

/// Objects the child can tap to count out loud. Shows a number badge on each.
class CountObjects extends StatefulWidget {
  final String emoji;
  final int n;
  final double size;
  final bool showNumber;
  const CountObjects({super.key, required this.emoji, required this.n, this.size = 50, this.showNumber = false});

  @override
  State<CountObjects> createState() => _CountObjectsState();
}

class _CountObjectsState extends State<CountObjects> {
  final Set<int> _counted = {};
  int _count = 0;

  void _tap(int i) {
    if (_counted.contains(i)) return;
    final audio = AudioAssistantService.ensure();
    setState(() {
      _counted.add(i);
      _count++;
    });
    audio.playSfx('pop');
    audio.speak(Bank.numberWords[_count]);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 6,
          runSpacing: 6,
          children: List.generate(widget.n, (i) {
            final done = _counted.contains(i);
            return GestureDetector(
              onTap: () => _tap(i),
              child: AnimatedScale(
                scale: done ? 1.15 : 1,
                duration: const Duration(milliseconds: 300),
                curve: Curves.elasticOut,
                child: SizedBox(
                  width: widget.size + 10,
                  height: widget.size + 14,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Opacity(opacity: done ? 1 : .85, child: Text(widget.emoji, style: TextStyle(fontSize: widget.size))),
                      if (done)
                        Positioned(
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                            decoration: BoxDecoration(color: Magic.candy, borderRadius: BorderRadius.circular(12)),
                            child: Text('${_counted.toList().indexOf(i) + 1}', style: Magic.title(Colors.white, 14)),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
        if (widget.showNumber) ...[
          const SizedBox(height: 10),
          Text('${widget.n}', style: TextStyle(fontFamily: Magic.font, fontSize: 70, fontWeight: FontWeight.w800, color: Magic.dusk, height: 1)),
        ],
      ],
    );
  }
}

/// "Give me 4!" - the child fills a basket with exactly N objects.
class GiveMe extends StatefulWidget {
  final String emoji;
  final int target;
  final String spokenName;
  final void Function(bool firstTry) onDone;
  const GiveMe({super.key, required this.emoji, required this.target, required this.spokenName, required this.onDone});

  @override
  State<GiveMe> createState() => _GiveMeState();
}

class _GiveMeState extends State<GiveMe> {
  late final int _pile = math.min(14, widget.target + 4);
  final Set<int> _inBasket = {};
  bool _mistake = false;
  bool _done = false;

  void _toggle(int i) {
    if (_done) return;
    final audio = AudioAssistantService.ensure();
    setState(() => _inBasket.contains(i) ? _inBasket.remove(i) : _inBasket.add(i));
    audio.playSfx('pop');
    if (_inBasket.isNotEmpty && _inBasket.contains(i)) audio.speak(Bank.numberWords[_inBasket.length]);
  }

  void _check() {
    final audio = AudioAssistantService.ensure();
    if (_inBasket.length == widget.target) {
      _done = true;
      widget.onDone(!_mistake);
    } else {
      _mistake = true;
      final have = _inBasket.length;
      audio.playSfx('wrong');
      audio.speak(have > widget.target
          ? 'You put $have. I asked for ${widget.target}. Take some out.'
          : 'You put $have. I need ${widget.target}. Add some more.');
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GlassCard(
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: List.generate(_pile, (i) {
              final inside = _inBasket.contains(i);
              return GestureDetector(
                onTap: () => _toggle(i),
                child: AnimatedOpacity(
                  opacity: inside ? .25 : 1,
                  duration: const Duration(milliseconds: 250),
                  child: Text(widget.emoji, style: const TextStyle(fontSize: 46)),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 12),
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFE3B3),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFC98A3C), width: 4),
          ),
          child: Column(
            children: [
              Text('🧺  ${_inBasket.length}', style: Magic.title(const Color(0xFF7A4A12), 30)),
              const SizedBox(height: 4),
              Wrap(
                alignment: WrapAlignment.center,
                children: _inBasket.map((_) => Text(widget.emoji, style: const TextStyle(fontSize: 28))).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        BigButton(label: 'Done!', icon: Icons.check_rounded, color: Magic.mint, onTap: _check),
      ],
    );
  }
}
