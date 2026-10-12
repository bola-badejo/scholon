// lib/Kidling/screens/activities/color_shape_activity.dart
//
// Modes (content['mode']): 'colors' | 'shapes' | 'combo'
//   colors : content['items'] = ['red','blue',...]
//   shapes : content['items'] = ['circle','square',...]
//   combo  : content['shapes'] = [...], content['colors'] = [...]  ("the blue triangle")

import 'package:flutter/material.dart';
import 'package:isapp/Kidling/controllers/activity_controller.dart';
import 'package:isapp/Kidling/engine/lesson_engine.dart';
import 'package:isapp/Kidling/models/content_bank.dart';
import 'package:isapp/Kidling/models/kidling_model.dart';
import 'package:isapp/Kidling/theme/magic_theme.dart';
import 'package:isapp/Kidling/widgets/magic_widgets.dart';

class ColorShapeActivity extends StatelessWidget {
  final ActivityController controller;
  final Activity activity;
  const ColorShapeActivity({super.key, required this.controller, required this.activity});

  List<String> _list(String key) => ((activity.content[key] as List?) ?? const []).map((e) => e.toString()).toList();

  @override
  Widget build(BuildContext context) {
    final mode = (activity.content['mode'] ?? 'colors').toString();
    final LessonPlan plan;
    if (mode == 'shapes') {
      plan = _shapes();
    } else if (mode == 'combo') {
      plan = _combo();
    } else {
      plan = _colors();
    }
    return LessonRunner(controller: controller, activity: activity, plan: plan);
  }

  // ------------------------------------------------------------
  LessonPlan _colors() {
    final keys = _list('items').where(Bank.colors.containsKey).toList();
    final all = Bank.colors.keys.toList();
    ColorInfo c(String k) => Bank.colors[k]!;

    final teach = keys.map((k) {
      final i = c(k);
      return TeachCard(
        title: 'This color is ${i.label}',
        subtitle: i.label,
        color: i.color,
        visual: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(color: i.color, shape: BoxShape.circle, border: Border.all(color: Colors.black12, width: 4), boxShadow: Magic.glow(i.color, a: .6)),
          ),
          const SizedBox(width: 16),
          Text(i.emoji, style: const TextStyle(fontSize: 80)),
        ]),
        speech: '${i.label}! ${i.fact}',
        tapSpeech: i.label,
      );
    }).toList();

    List<String> opts(String k, int n) => ([k, ...Bank.others(keys.length > n ? keys : all, k, n)]..shuffle());

    final guided = (List<String>.of(keys)..shuffle()).map((k) {
      final o = opts(k, 1);
      return LessonRound(
        prompt: 'Tap the ${c(k).label} one',
        speech: 'Can you find ${c(k).label}? Tap the ${c(k).label} one.',
        options: o.map((x) => Choice.swatch(c(x).color, id: x)).toList(),
        correct: o.indexOf(k),
        hint: c(k).fact,
        itemKey: k,
      );
    }).toList();

    final challenge = <LessonRound>[];
    for (final k in (List<String>.of(keys)..shuffle())) {
      final o = opts(k, 3);
      challenge.add(LessonRound(
        prompt: 'Which one is ${c(k).label}?',
        speech: 'Which one is ${c(k).label}?',
        options: o.map((x) => Choice.swatch(c(x).color, id: x)).toList(),
        correct: o.indexOf(k),
        hint: c(k).fact,
        itemKey: k,
      ));
      final names = opts(k, 2);
      challenge.add(LessonRound(
        prompt: 'What color is this?',
        speech: 'What color is this?',
        display: Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(color: c(k).color, shape: BoxShape.circle, border: Border.all(color: Colors.black12, width: 4)),
        ),
        options: names.map((x) => Choice.text(c(x).label, color: c(x).color == const Color(0xFFF5F5F5) ? Magic.ink : c(x).color, scale: .24, id: x)).toList(),
        correct: names.indexOf(k),
        hint: c(k).fact,
        itemKey: k,
      ));
    }
    challenge.shuffle();
    return LessonPlan(teach: teach, guided: guided, challenge: challenge.take(8).toList());
  }

  // ------------------------------------------------------------
  Color _shapeColor(String s) {
    const cols = [Color(0xFFFF6F61), Color(0xFF4D96FF), Color(0xFFFFC93C), Color(0xFF2EC98A), Color(0xFFB65CFF), Color(0xFFFF6FB5), Color(0xFF1DC9B8), Color(0xFFFF9F43)];
    return cols[Bank.shapes.keys.toList().indexOf(s).clamp(0, cols.length - 1)];
  }

  LessonPlan _shapes() {
    final keys = _list('items').where(Bank.shapes.containsKey).toList();
    final all = Bank.shapes.keys.toList();
    String label(String k) => Bank.shapes[k]![0];

    final teach = keys.map((k) {
      final d = Bank.shapes[k]!;
      return TeachCard(
        title: 'This is a ${d[0]}',
        subtitle: d[0],
        color: _shapeColor(k),
        visual: Row(mainAxisSize: MainAxisSize.min, children: [
          ShapeIcon(shape: k, color: _shapeColor(k), size: 120),
          const SizedBox(width: 12),
          Text(d[1], style: const TextStyle(fontSize: 70)),
        ]),
        speech: 'A ${d[0]}. ${d[2]}',
        tapSpeech: d[0],
      );
    }).toList();

    List<String> opts(String k, int n) => ([k, ...Bank.others(keys.length > n ? keys : all, k, n)]..shuffle());

    final guided = (List<String>.of(keys)..shuffle()).map((k) {
      final o = opts(k, 1);
      return LessonRound(
        prompt: 'Find the ${label(k)}',
        speech: 'Can you find the ${label(k)}?',
        options: o.map((x) => Choice.shape(x, _shapeColor(x), id: x)).toList(),
        correct: o.indexOf(k),
        hint: Bank.shapes[k]![2],
        itemKey: k,
      );
    }).toList();

    final challenge = <LessonRound>[];
    for (final k in (List<String>.of(keys)..shuffle())) {
      final o = opts(k, 3);
      challenge.add(LessonRound(
        prompt: 'Which one is the ${label(k)}?',
        speech: 'Which one is the ${label(k)}?',
        options: o.map((x) => Choice.shape(x, _shapeColor(x), id: x)).toList(),
        correct: o.indexOf(k),
        hint: Bank.shapes[k]![2],
        itemKey: k,
      ));
      final n = opts(k, 2);
      challenge.add(LessonRound(
        prompt: 'What shape is this?',
        speech: 'What shape is this?',
        display: ShapeIcon(shape: k, color: _shapeColor(k), size: 120),
        options: n.map((x) => Choice.text(label(x), scale: .22, id: x)).toList(),
        correct: n.indexOf(k),
        hint: Bank.shapes[k]![2],
        itemKey: k,
      ));
    }
    challenge.shuffle();
    return LessonPlan(teach: teach, guided: guided, challenge: challenge.take(8).toList());
  }

  // ------------------------------------------------------------
  LessonPlan _combo() {
    final shapes = _list('shapes').where(Bank.shapes.containsKey).toList();
    final colors = _list('colors').where(Bank.colors.containsKey).toList();
    final pairs = <List<String>>[];
    for (var i = 0; i < shapes.length; i++) {
      pairs.add([shapes[i], colors[i % colors.length]]);
    }
    String name(List<String> p) => '${Bank.colors[p[1]]!.label} ${Bank.shapes[p[0]]![0]}';
    Choice ch(String s, String c) => Choice.shape(s, Bank.colors[c]!.color, id: '$s-$c');

    final teach = pairs.map((p) {
      return TeachCard(
        title: 'A ${name(p).toLowerCase()}',
        subtitle: name(p),
        color: Bank.colors[p[1]]!.color,
        visual: ShapeIcon(shape: p[0], color: Bank.colors[p[1]]!.color, size: 140),
        speech: 'This is a ${name(p)}. It is ${Bank.colors[p[1]]!.label}, and it is a ${Bank.shapes[p[0]]![0]}.',
        tapSpeech: name(p),
      );
    }).toList();

    List<List<String>> options(List<String> p, int n) {
      final out = <List<String>>[
        p,
        [p[0], colors.firstWhere((c) => c != p[1], orElse: () => 'red')], // right shape, wrong color
        [shapes.firstWhere((s) => s != p[0], orElse: () => 'circle'), p[1]], // right color, wrong shape
      ];
      final extraS = Bank.others(Bank.shapes.keys.toList(), p[0], 1).first;
      final extraC = Bank.others(Bank.colors.keys.toList(), p[1], 1).first;
      out.add([extraS, extraC]);
      final uniq = <String>{};
      final res = out.where((o) => uniq.add('${o[0]}-${o[1]}')).take(n).toList();
      if (!res.any((o) => o[0] == p[0] && o[1] == p[1])) res[0] = p;
      return res..shuffle();
    }

    LessonRound round(List<String> p, int n) {
      final o = options(p, n);
      return LessonRound(
        prompt: 'Find the ${name(p)}',
        speech: 'Find the ${name(p)}.',
        options: o.map((x) => ch(x[0], x[1])).toList(),
        correct: o.indexWhere((x) => x[0] == p[0] && x[1] == p[1]),
        hint: 'Look for the ${Bank.colors[p[1]]!.label} one. Then check the shape: ${Bank.shapes[p[0]]![0]}.',
        itemKey: p[0],
      );
    }

    final order = List<List<String>>.of(pairs)..shuffle();
    return LessonPlan(
      teach: teach,
      guided: order.map((p) => round(p, 2)).toList(),
      challenge: [...order, ...order.reversed].take(6).map((p) => round(p, 4)).toList(),
    );
  }
}
