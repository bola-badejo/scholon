import 'dart:math' as math;
import 'package:isapp/features/study_guide/models/mastery_record.dart';

/// SM-2 style scheduling plus a smoothed mastery estimate.
/// quality: 0 (blackout) .. 5 (perfect recall).
class SpacedRepetition {
  SpacedRepetition._();

  static int qualityFromScore(double percent) {
    if (percent >= 95) return 5;
    if (percent >= 85) return 4;
    if (percent >= 70) return 3;
    if (percent >= 50) return 2;
    if (percent >= 30) return 1;
    return 0;
  }

  static MasteryRecord review(MasteryRecord r, int quality, {DateTime? now}) {
    final at = now ?? DateTime.now();
    final q = quality.clamp(0, 5);

    final ef = math.max(1.3, r.easiness + 0.1 - (5 - q) * (0.08 + (5 - q) * 0.02));
    int reps;
    int interval;
    if (q < 3) {
      reps = 0;
      interval = 1;
    } else {
      reps = r.repetitions + 1;
      if (reps == 1) {
        interval = 1;
      } else if (reps == 2) {
        interval = 3;
      } else {
        interval = math.max(1, (r.intervalDays * ef).round());
      }
    }

    // First attempts move mastery faster; later ones are smoothed.
    final rate = r.attempts < 2 ? 0.55 : 0.35;
    var mastery = r.mastery + (q / 5 - r.mastery) * rate;
    if (q < 3) mastery -= 0.04;

    final day = DateTime(at.year, at.month, at.day);
    return r.copyWith(
      mastery: mastery.clamp(0.0, 1.0),
      easiness: ef,
      repetitions: reps,
      intervalDays: interval,
      attempts: r.attempts + 1,
      lastReviewed: at,
      dueDate: day.add(Duration(days: interval)),
    );
  }

  /// Mastery fades if a topic is not revised.
  static double decayed(MasteryRecord r, DateTime now) {
    if (r.lastReviewed == null || r.intervalDays == 0) return r.mastery;
    final late = r.overdueDays(now);
    if (late <= 0) return r.mastery;
    final penalty = math.min(0.35, late / (r.intervalDays * 3 + 3) * 0.35);
    return (r.mastery - penalty).clamp(0.0, 1.0);
  }
}
