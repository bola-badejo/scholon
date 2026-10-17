import 'package:flutter/material.dart';
import 'package:isapp/core/theme/scholar_theme.dart';
import 'package:isapp/features/study_guide/models/plan_item.dart';
import 'package:isapp/features/study_guide/widgets/stage_style.dart';

class PlanTile extends StatelessWidget {
  final PlanItem item;
  final int index;
  final bool done;
  final VoidCallback onStart;
  const PlanTile({super.key, required this.item, required this.index, required this.done, required this.onStart});

  @override
  Widget build(BuildContext context) {
    final col = StageStyle.color(item.stage);
    return Opacity(
      opacity: done ? .55 : 1,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: Scholar.glass(tint: done ? Scholar.mint : Colors.white),
        child: Row(children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(color: col.withOpacity(.2), borderRadius: BorderRadius.circular(14)),
            child: Icon(done ? Icons.check_circle_rounded : StageStyle.icon(item.stage), color: done ? Scholar.mint : col),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 4),
              Text(item.topic.subject, maxLines: 1, overflow: TextOverflow.ellipsis, style: Scholar.body()),
              const SizedBox(height: 8),
              Wrap(spacing: 6, runSpacing: 6, children: [
                _tag(StageStyle.reasonIcon(item.reason), item.reason.label, col),
                _tag(Icons.schedule_rounded, '${item.minutes} min', Colors.white70),
              ]),
            ]),
          ),
          const SizedBox(width: 8),
          done
              ? const SizedBox(width: 44)
              : IconButton.filled(
                  style: IconButton.styleFrom(backgroundColor: col, foregroundColor: Scholar.night),
                  onPressed: onStart,
                  icon: const Icon(Icons.play_arrow_rounded, size: 28),
                ),
        ]),
      ),
    );
  }

  Widget _tag(IconData i, String t, Color c) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: Colors.white.withOpacity(.07), borderRadius: BorderRadius.circular(10)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(i, size: 13, color: c),
          const SizedBox(width: 4),
          Text(t, style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w600)),
        ]),
      );
}
