import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isapp/core/theme/scholar_theme.dart';
import 'package:isapp/features/study_guide/controllers/study_guide_controller.dart';
import 'package:isapp/features/study_guide/engine/xp_system.dart';

/// Level ring, XP, streak and the day's completion at a glance.
class ProgressHeader extends StatelessWidget {
  final StudyGuideController c;
  const ProgressHeader({super.key, required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final p = c.progress.value;
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Scholar.violet, Color(0xFF2E6BE6)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [BoxShadow(color: Scholar.violet.withOpacity(.45), blurRadius: 30, offset: const Offset(0, 12))],
        ),
        child: Row(children: [
          SizedBox(
            width: 92,
            height: 92,
            child: Stack(alignment: Alignment.center, children: [
              SizedBox.expand(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(end: p.levelProgress),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, __) => CircularProgressIndicator(value: v, strokeWidth: 8, backgroundColor: Colors.white24, valueColor: const AlwaysStoppedAnimation(Scholar.sun)),
                ),
              ),
              Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('LVL', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
                Text('${p.level}', style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800, height: 1)),
              ]),
            ]),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(XpSystem.titleFor(p.level), style: Scholar.h2()),
              const SizedBox(height: 2),
              Text('${p.xp} XP  -  ${p.xpForNext - p.xp} to level ${p.level + 1}', style: Scholar.body(Colors.white70)),
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, children: [
                _chip(Icons.local_fire_department_rounded, '${p.streak} day streak', Scholar.sun),
                _chip(Icons.timer_rounded, '${c.minutesToday} min today', Scholar.aurora),
              ]),
            ]),
          ),
        ]),
      );
    });
  }

  Widget _chip(IconData i, String t, Color col) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: Colors.black.withOpacity(.22), borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(i, size: 16, color: col),
          const SizedBox(width: 5),
          Text(t, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
        ]),
      );
}
