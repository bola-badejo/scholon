import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';

/// XP, level, streak and the student's plan preferences.
class StudentProgress {
  final int xp;
  final int streak;
  final int longestStreak;
  final DateTime? lastStudyDay;
  final int dailyMinutes;
  final DateTime? examDate;
  final int totalMinutes;
  final int sessionsCompleted;

  const StudentProgress({
    this.xp = 0,
    this.streak = 0,
    this.longestStreak = 0,
    this.lastStudyDay,
    this.dailyMinutes = 90,
    this.examDate,
    this.totalMinutes = 0,
    this.sessionsCompleted = 0,
  });

  /// Level n needs 100*(n-1)^2 XP.
  int get level => math.sqrt(xp / 100).floor() + 1;
  int get xpForLevel => 100 * (level - 1) * (level - 1);
  int get xpForNext => 100 * level * level;
  double get levelProgress => ((xp - xpForLevel) / (xpForNext - xpForLevel)).clamp(0.0, 1.0);

  int? daysToExam(DateTime now) {
    if (examDate == null) return null;
    return DateTime(examDate!.year, examDate!.month, examDate!.day).difference(DateTime(now.year, now.month, now.day)).inDays;
  }

  StudentProgress copyWith({int? xp, int? streak, int? longestStreak, DateTime? lastStudyDay, int? dailyMinutes, DateTime? examDate, bool clearExam = false, int? totalMinutes, int? sessionsCompleted}) =>
      StudentProgress(
        xp: xp ?? this.xp,
        streak: streak ?? this.streak,
        longestStreak: longestStreak ?? this.longestStreak,
        lastStudyDay: lastStudyDay ?? this.lastStudyDay,
        dailyMinutes: dailyMinutes ?? this.dailyMinutes,
        examDate: clearExam ? null : (examDate ?? this.examDate),
        totalMinutes: totalMinutes ?? this.totalMinutes,
        sessionsCompleted: sessionsCompleted ?? this.sessionsCompleted,
      );

  Map<String, dynamic> toMap() => {
        'xp': xp,
        'streak': streak,
        'longestStreak': longestStreak,
        'lastStudyDay': lastStudyDay == null ? null : Timestamp.fromDate(lastStudyDay!),
        'dailyMinutes': dailyMinutes,
        'examDate': examDate == null ? null : Timestamp.fromDate(examDate!),
        'totalMinutes': totalMinutes,
        'sessionsCompleted': sessionsCompleted,
      };

  factory StudentProgress.fromMap(Map<String, dynamic> m) => StudentProgress(
        xp: (m['xp'] as num?)?.toInt() ?? 0,
        streak: (m['streak'] as num?)?.toInt() ?? 0,
        longestStreak: (m['longestStreak'] as num?)?.toInt() ?? 0,
        lastStudyDay: (m['lastStudyDay'] as Timestamp?)?.toDate(),
        dailyMinutes: (m['dailyMinutes'] as num?)?.toInt() ?? 90,
        examDate: (m['examDate'] as Timestamp?)?.toDate(),
        totalMinutes: (m['totalMinutes'] as num?)?.toInt() ?? 0,
        sessionsCompleted: (m['sessionsCompleted'] as num?)?.toInt() ?? 0,
      );
}
