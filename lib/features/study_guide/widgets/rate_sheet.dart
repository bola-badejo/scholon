import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isapp/core/theme/scholar_theme.dart';
import 'package:isapp/features/study_guide/models/plan_item.dart';

/// After each session the student rates their own recall. This is real
/// metacognition AND the signal that drives spaced repetition.
class RateSheet {
  static Future<int?> show(PlanItem item) {
    const options = [
      (5, 'Nailed it', 'I could teach this', Icons.rocket_launch_rounded, Scholar.mint),
      (4, 'Got it', 'Small slips only', Icons.thumb_up_alt_rounded, Scholar.aurora),
      (3, 'Mostly', 'I needed a few hints', Icons.sentiment_satisfied_rounded, Scholar.sun),
      (2, 'Shaky', 'I forgot a lot', Icons.sentiment_neutral_rounded, Color(0xFFFFA24D)),
      (1, 'Lost', 'Show me again', Icons.sentiment_very_dissatisfied_rounded, Scholar.coral),
    ];
    return Get.bottomSheet<int>(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
        decoration: const BoxDecoration(color: Scholar.indigo, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
        child: SafeArea(
          top: false,
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 44, height: 5, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(3)))),
            const SizedBox(height: 16),
            Text('How did that go?', style: Scholar.h1()),
            const SizedBox(height: 4),
            Text(item.topic.title, style: Scholar.body()),
            const SizedBox(height: 16),
            for (final o in options)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => Get.back(result: o.$1),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: o.$5.withOpacity(.14), borderRadius: BorderRadius.circular(18), border: Border.all(color: o.$5.withOpacity(.5))),
                    child: Row(children: [
                      Icon(o.$4, color: o.$5),
                      const SizedBox(width: 12),
                      Text(o.$2, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                      const Spacer(),
                      Text(o.$3, style: Scholar.body()),
                    ]),
                  ),
                ),
              ),
          ]),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
