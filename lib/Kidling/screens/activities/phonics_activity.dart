// lib/Kidling/screens/activities/phonics_activity.dart
//
// LEARN : see the letter + picture, hear "S says sss. S is for sun."
// TRY   : hear a sound -> pick the letter (2 choices, hints)
// STAR  : sound -> letter, picture -> first letter, letter -> picture (3-4 choices)

import 'package:flutter/material.dart';
import 'package:isapp/Kidling/controllers/activity_controller.dart';
import 'package:isapp/Kidling/controllers/audio_assistant_services.dart';
import 'package:isapp/Kidling/engine/lesson_engine.dart';
import 'package:isapp/Kidling/models/kidling_model.dart';
import 'package:isapp/Kidling/theme/magic_theme.dart';

class _L {
  final String word, emoji, sound;
  const _L(this.word, this.emoji, this.sound);
}

// Letter -> (word, picture, sound the voice should say)
const Map<String, _L> _abc = {
  'S': _L('Sun', '☀️', 'sss'), 'A': _L('Apple', '🍎', 'aah'), 'T': _L('Tiger', '🐯', 'tuh'), 'P': _L('Pig', '🐷', 'puh'),
  'I': _L('Igloo', '🧊', 'ih'), 'N': _L('Nest', '🪺', 'nnn'), 'M': _L('Moon', '🌙', 'mmm'), 'D': _L('Dog', '🐶', 'duh'),
  'G': _L('Goat', '🐐', 'guh'), 'O': _L('Octopus', '🐙', 'ah'), 'C': _L('Cat', '🐱', 'kuh'), 'K': _L('Kite', '🪁', 'kuh'),
  'E': _L('Egg', '🥚', 'eh'), 'U': _L('Umbrella', '☂️', 'uh'), 'R': _L('Rabbit', '🐰', 'rrr'), 'H': _L('Hat', '🎩', 'huh'),
  'B': _L('Ball', '⚽', 'buh'), 'F': _L('Fish', '🐟', 'fff'), 'L': _L('Lion', '🦁', 'lll'), 'J': _L('Jelly', '🍮', 'juh'),
  'Q': _L('Queen', '👑', 'kwuh'), 'V': _L('Violin', '🎻', 'vvv'), 'W': _L('Whale', '🐳', 'wuh'), 'X': _L('Box', '📦', 'ks'),
  'Y': _L('Yo-yo', '🪀', 'yuh'), 'Z': _L('Zebra', '🦓', 'zzz'),
};

class PhonicsActivity extends StatelessWidget {
  final ActivityController controller;
  final Activity activity;
  const PhonicsActivity({super.key, required this.controller, required this.activity});

  @override
  Widget build(BuildContext context) {
    final audio = AudioAssistantService.ensure();
    final raw = (activity.content['letters'] as List?)?.map((e) => e.toString().toUpperCase()).toList() ??
        (activity.content['items'] as List?)?.map((e) => (e as Map)['k'].toString().toUpperCase()).toList() ??
        ['A', 'B', 'C'];
    final letters = raw.where(_abc.containsKey).toList();
    final all = _abc.keys.toList();

    String low(String l) => l.toLowerCase();
    Widget letterVisual(String l) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$l${low(l)}', style: TextStyle(fontFamily: Magic.font, fontSize: 120, height: 1, fontWeight: FontWeight.w800, color: activity.world.deep)),
            Text(_abc[l]!.emoji, style: const TextStyle(fontSize: 76)),
          ],
        );

    // ---------- LEARN ----------
    final teach = letters.map((l) {
      final d = _abc[l]!;
      return TeachCard(
        title: 'This is the letter $l',
        subtitle: '$l is for ${d.word}',
        visual: letterVisual(l),
        speech: '$l. $l says ${d.sound}. $l is for ${d.word}.',
        tapSpeech: '$l says ${d.sound}.',
        color: activity.world.color,
      );
    }).toList();

    // ---------- TRY TOGETHER (sound -> letter, two choices) ----------
    final order = List<String>.of(letters)..shuffle();
    final guided = order.map((l) {
      final d = _abc[l]!;
      final other = letters.length > 1 ? (List<String>.of(letters)..remove(l)..shuffle()).first : all.firstWhere((x) => x != l);
      final opts = [l, other]..shuffle();
      return LessonRound(
        prompt: 'Which letter says "${d.sound}"?',
        speech: 'Listen. ${d.sound}. Which letter says ${d.sound}?',
        options: opts.map((x) => Choice.text(x)).toList(),
        correct: opts.indexOf(l),
        hint: '$l says ${d.sound}. $l is for ${d.word}.',
        itemKey: l,
        replay: () => audio.speak(d.sound),
        autoReplay: false,
      );
    }).toList();

    // ---------- STAR CHALLENGE ----------
    List<String> distract(String l, int n) {
      final pool = <String>[...letters.where((x) => x != l), ...(List<String>.of(all)..remove(l)..shuffle())];
      final seen = <String>{};
      return pool.where(seen.add).take(n).toList();
    }

    final challenge = <LessonRound>[];
    for (final l in (List<String>.of(letters)..shuffle())) {
      final d = _abc[l]!;
      final n = letters.length >= 4 ? 3 : 2;
      // picture -> first letter
      final o1 = [l, ...distract(l, n)]..shuffle();
      challenge.add(LessonRound(
        prompt: 'What letter does ${d.word} start with?',
        speech: 'What letter does ${d.word} start with?',
        display: Text(d.emoji, style: const TextStyle(fontSize: 90)),
        options: o1.map((x) => Choice.text(x)).toList(),
        correct: o1.indexOf(l),
        hint: '${d.word}. ${d.sound}. It starts with ${d.sound}, like $l.',
        itemKey: l,
        replay: () => audio.speak(d.word),
      ));
      // letter -> picture
      final pics = [l, ...distract(l, n)]..shuffle();
      challenge.add(LessonRound(
        prompt: 'Which picture starts with $l?',
        speech: 'Which picture starts with the letter $l? $l says ${d.sound}.',
        display: Text(l, style: TextStyle(fontFamily: Magic.font, fontSize: 100, height: 1, fontWeight: FontWeight.w800, color: activity.world.deep)),
        options: pics.map((x) => Choice.emoji(_abc[x]!.emoji, id: x)).toList(),
        correct: pics.indexOf(l),
        hint: '$l is for ${d.word}.',
        itemKey: l,
      ));
    }
    challenge.shuffle();

    return LessonRunner(
      controller: controller,
      activity: activity,
      plan: LessonPlan(teach: teach, guided: guided, challenge: challenge.take(8).toList()),
    );
  }
}
