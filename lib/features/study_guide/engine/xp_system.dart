import 'package:isapp/features/study_guide/models/student_progress.dart';

class XpSystem {
  XpSystem._();

  /// XP for finishing a plan item: time spent, quality of recall, streak bonus.
  static int award({required int minutes, required int quality, required int streak}) {
    final base = minutes * 2;
    final qualityBonus = quality * 6;
    final streakBonus = (streak.clamp(0, 14)) * 2;
    return base + qualityBonus + streakBonus;
  }

  /// Updates the streak for studying on [today].
  static StudentProgress registerStudyDay(StudentProgress p, DateTime today) {
    final t = DateTime(today.year, today.month, today.day);
    final last = p.lastStudyDay == null ? null : DateTime(p.lastStudyDay!.year, p.lastStudyDay!.month, p.lastStudyDay!.day);
    var streak = p.streak;
    if (last == null) {
      streak = 1;
    } else {
      final diff = t.difference(last).inDays;
      if (diff == 1) {
        streak += 1;
      } else if (diff > 1) {
        streak = 1;
      } else if (streak == 0) {
        streak = 1;
      }
    }
    return p.copyWith(streak: streak, longestStreak: streak > p.longestStreak ? streak : p.longestStreak, lastStudyDay: t);
  }

  static String titleFor(int level) {
    if (level >= 20) return 'Scholon Legend';
    if (level >= 15) return 'Master Scholar';
    if (level >= 10) return 'Deep Thinker';
    if (level >= 6) return 'Rising Scholar';
    if (level >= 3) return 'Curious Mind';
    return 'New Explorer';
  }
}
