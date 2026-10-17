import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isapp/core/theme/scholar_theme.dart';
import 'package:isapp/features/study_guide/controllers/study_guide_controller.dart';

/// Pomodoro timer: 25 min focus, then a short break (long break every 4th).
class FocusTimerCard extends StatelessWidget {
  final StudyGuideController c;
  const FocusTimerCard({super.key, required this.c});

  String _fmt(int s) => '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final left = c.focusSecondsLeft.value;
      final total = c.focusTotalSeconds.value;
      final brk = c.onBreak.value;
      final col = brk ? Scholar.mint : Scholar.aurora;
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: Scholar.glass(),
        child: Row(children: [
          SizedBox(
            width: 104,
            height: 104,
            child: Stack(alignment: Alignment.center, children: [
              SizedBox.expand(child: CircularProgressIndicator(value: total == 0 ? 0 : left / total, strokeWidth: 9, backgroundColor: Colors.white12, valueColor: AlwaysStoppedAnimation(col))),
              Text(_fmt(left), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
            ]),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(brk ? 'Break time' : 'Focus round', style: Scholar.h2()),
              const SizedBox(height: 2),
              Text(brk ? 'Rest your eyes. Walk. Water.' : '${c.focusRoundsToday.value} rounds finished today', style: Scholar.body()),
              const SizedBox(height: 10),
              Row(children: [
                FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: col, foregroundColor: Scholar.night),
                  onPressed: c.toggleFocus,
                  icon: Icon(c.focusRunning.value ? Icons.pause_rounded : Icons.play_arrow_rounded),
                  label: Text(c.focusRunning.value ? 'Pause' : 'Start'),
                ),
                const SizedBox(width: 8),
                IconButton(onPressed: c.resetFocus, icon: const Icon(Icons.restart_alt_rounded, color: Colors.white70)),
                if (!brk && !c.focusRunning.value)
                  PopupMenuButton<int>(
                    icon: const Icon(Icons.tune_rounded, color: Colors.white70),
                    onSelected: c.setFocusLength,
                    itemBuilder: (_) => [15, 25, 40, 50].map((m) => PopupMenuItem(value: m, child: Text('$m minutes'))).toList(),
                  ),
              ]),
            ]),
          ),
        ]),
      );
    });
  }
}
