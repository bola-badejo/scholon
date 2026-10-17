import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:isapp/core/theme/scholar_theme.dart';
import 'package:isapp/features/study_guide/controllers/study_guide_controller.dart';

/// Daily time budget and exam date. Both change the plan immediately.
class PlanSettingsCard extends StatelessWidget {
  final StudyGuideController c;
  const PlanSettingsCard({super.key, required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final p = c.progress.value;
      final days = p.daysToExam(DateTime.now());
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.schedule_rounded, color: Scholar.aurora, size: 20),
          const SizedBox(width: 8),
          Text('Daily study time', style: Scholar.h2()),
          const Spacer(),
          Text('${p.dailyMinutes} min', style: const TextStyle(color: Scholar.sun, fontWeight: FontWeight.w800, fontSize: 16)),
        ]),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(activeTrackColor: Scholar.aurora, thumbColor: Scholar.aurora, inactiveTrackColor: Colors.white12),
          child: Slider(
            min: 30,
            max: 240,
            divisions: 14,
            value: p.dailyMinutes.clamp(30, 240).toDouble(),
            onChanged: (v) => c.progress.value = p.copyWith(dailyMinutes: v.round()),
            onChangeEnd: (v) => c.setDailyMinutes(v.round()),
          ),
        ),
        const SizedBox(height: 8),
        Row(children: [
          const Icon(Icons.event_rounded, color: Scholar.coral, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              p.examDate == null ? 'No exam date set' : '${DateFormat('d MMM yyyy').format(p.examDate!)}  -  ${days! >= 0 ? '$days days left' : 'passed'}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: p.examDate ?? DateTime.now().add(const Duration(days: 30)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 730)),
              );
              if (d != null) await c.setExamDate(d);
            },
            child: Text(p.examDate == null ? 'Set date' : 'Change'),
          ),
          if (p.examDate != null) IconButton(onPressed: () => c.setExamDate(null), icon: const Icon(Icons.close_rounded, color: Colors.white38, size: 18)),
        ]),
        if (days != null && days >= 0 && days <= 14)
          Container(
            margin: const EdgeInsets.only(top: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Scholar.coral.withOpacity(.15), borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              const Icon(Icons.local_fire_department_rounded, color: Scholar.coral),
              const SizedBox(width: 8),
              Expanded(child: Text('Exam mode: more quizzes and mocks, fewer new topics.', style: Scholar.body(Colors.white))),
            ]),
          ),
      ]);
    });
  }
}
