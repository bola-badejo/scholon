import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isapp/core/theme/scholar_theme.dart';
import 'package:isapp/features/study_guide/controllers/study_guide_controller.dart';
import 'package:isapp/features/study_guide/models/mastery_record.dart';
import 'package:isapp/features/study_guide/widgets/stage_style.dart';

/// Per-subject mastery bars with a topic heat-map underneath.
class MasteryMap extends StatelessWidget {
  final StudyGuideController c;
  const MasteryMap({super.key, required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final subjects = c.subjects;
      if (subjects.isEmpty) return Text('Your subjects will appear here.', style: Scholar.body());
      return Column(children: [
        for (final s in subjects) _subject(s),
        const SizedBox(height: 4),
        _legend(),
      ]);
    });
  }

  Widget _subject(String subject) {
    final m = c.subjectMastery(subject);
    final focus = c.focusSubjects.contains(subject);
    final topics = c.topics.where((t) => t.subject == subject).toList()..sort((a, b) => a.order.compareTo(b.order));
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(subject, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
          Text('${(m * 100).round()}%', style: const TextStyle(color: Scholar.aurora, fontWeight: FontWeight.w800)),
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: 'Prioritise this subject',
            onPressed: () => c.toggleFocusSubject(subject),
            icon: Icon(focus ? Icons.push_pin_rounded : Icons.push_pin_outlined, size: 18, color: focus ? Scholar.sun : Colors.white38),
          ),
        ]),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: m),
            duration: const Duration(milliseconds: 700),
            builder: (_, v, __) => LinearProgressIndicator(value: v, minHeight: 8, backgroundColor: Colors.white12, valueColor: const AlwaysStoppedAnimation(Scholar.aurora)),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            for (final t in topics)
              Tooltip(
                message: '${t.title} - ${c.stageOf(t).label}',
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: c.records[t.key] == null ? Colors.white10 : StageStyle.color(c.stageOf(t)).withOpacity(.35 + .65 * (c.records[t.key]!.mastery)),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
          ],
        ),
      ]),
    );
  }

  Widget _legend() => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        for (final s in TopicStage.values)
          Row(children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: StageStyle.color(s), borderRadius: BorderRadius.circular(3))),
            const SizedBox(width: 5),
            Text(s.label, style: Scholar.body()),
          ]),
      ]);
}
