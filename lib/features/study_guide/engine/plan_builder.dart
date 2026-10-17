import 'dart:math' as math;
import 'package:isapp/features/study_guide/engine/spaced_repetition.dart';
import 'package:isapp/features/study_guide/models/activity_type.dart';
import 'package:isapp/features/study_guide/models/mastery_record.dart';
import 'package:isapp/features/study_guide/models/plan_item.dart';
import 'package:isapp/features/study_guide/models/study_topic.dart';

/// Builds ONE day of study from what the student knows and what is due.
///
///  * Spaced retrieval first: due reviews open the session as a warm-up.
///  * Weak topics before new ones, and never more than [maxOpenTopics] topics
///    "in flight" so the student is not buried under half-learned material.
///  * Interleaving: new topics rotate across subjects.
///  * Testing effect: quizzes (check) close the session.
///  * Exam proximity shifts the mix from learning toward testing.
///  * Sunday (or every 3rd day near the exam): a mock on the weakest topic.
class PlanBuilder {
  static const int maxOpenTopics = 4;

  static List<PlanItem> buildDay({
    required DateTime day,
    required List<StudyTopic> topics,
    required Map<String, MasteryRecord> records,
    required int dailyMinutes,
    int? daysToExam,
    Set<String> focusSubjects = const {},
  }) {
    final dayKey = '${day.year}-${day.month}-${day.day}';
    final byKey = {for (final t in topics) t.key: t};
    final items = <PlanItem>[];
    var budget = dailyMinutes;
    final used = <String>{};

    final examSoon = daysToExam != null && daysToExam >= 0 && daysToExam <= 14;
    final reviewCap = (dailyMinutes * (examSoon ? 0.30 : 0.40)).round();
    final checkShare = examSoon ? 0.30 : 0.15;

    PlanItem make(StudyTopic t, TopicStage s, PlanReason r, ActivityType a, int mins) =>
        PlanItem(id: '${dayKey}_${t.key}_${s.name}', topic: t, stage: s, reason: r, activityType: a, minutes: mins);

    bool add(PlanItem it) {
      if (it.minutes > budget || used.contains(it.topic.key)) return false;
      items.add(it);
      used.add(it.topic.key);
      budget -= it.minutes;
      return true;
    }

    // 1. due reviews (most overdue, then weakest)
    final due = records.values.where((r) => r.attempts > 0 && r.isDue(day) && byKey.containsKey(r.topicKey)).toList()
      ..sort((a, b) {
        final c = b.overdueDays(day).compareTo(a.overdueDays(day));
        return c != 0 ? c : a.mastery.compareTo(b.mastery);
      });
    var reviewSpent = 0;
    for (final r in due) {
      if (reviewSpent >= reviewCap) break;
      const mins = 12;
      if (add(make(byKey[r.topicKey]!, TopicStage.master, PlanReason.dueReview, ActivityType.revisionSession, mins))) reviewSpent += mins;
    }

    // 2. weak spots
    final weak = records.values.where((r) => r.attempts > 0 && SpacedRepetition.decayed(r, day) < .55 && byKey.containsKey(r.topicKey)).toList()
      ..sort((a, b) {
        final fa = focusSubjects.contains(a.subject) ? -1 : 0;
        final fb = focusSubjects.contains(b.subject) ? -1 : 0;
        if (fa != fb) return fa.compareTo(fb);
        return a.mastery.compareTo(b.mastery);
      });
    final weakCap = (dailyMinutes * 0.30).round();
    var weakSpent = 0;
    for (final r in weak) {
      if (weakSpent >= weakCap) break;
      final stage = r.stage == TopicStage.learn ? TopicStage.learn : TopicStage.practice;
      if (add(make(byKey[r.topicKey]!, stage, PlanReason.weakSpot, ActivityType.practiceSession, 20))) weakSpent += 20;
    }

    // 3. new topics, interleaved across subjects
    final open = records.values.where((r) => r.attempts > 0 && r.mastery < .4).length;
    var slots = math.max(0, maxOpenTopics - open);
    if (examSoon) slots = math.min(slots, 1);
    final bySubject = <String, List<StudyTopic>>{};
    for (final t in topics) {
      final rec = records[t.key];
      if (rec != null && rec.attempts > 0) continue;
      bySubject.putIfAbsent(t.subject, () => []).add(t);
    }
    for (final l in bySubject.values) {
      l.sort((a, b) => a.order.compareTo(b.order));
    }
    double avg(String s) {
      final rs = records.values.where((r) => r.subject == s);
      return rs.isEmpty ? 0 : rs.map((r) => r.mastery).reduce((x, y) => x + y) / rs.length;
    }

    final subjects = bySubject.keys.toList()
      ..sort((a, b) {
        final fa = focusSubjects.contains(a) ? 0 : 1;
        final fb = focusSubjects.contains(b) ? 0 : 1;
        if (fa != fb) return fa.compareTo(fb);
        return avg(a).compareTo(avg(b));
      });
    var i = 0;
    while (slots > 0 && subjects.isNotEmpty && i < subjects.length * 4) {
      final list = bySubject[subjects[i % subjects.length]]!;
      if (list.isNotEmpty) {
        final t = list.first;
        final mins = math.min(t.estimatedMinutes, 30);
        if (add(make(t, TopicStage.learn, PlanReason.newTopic, ActivityType.dailyLesson, mins))) {
          list.removeAt(0);
          slots--;
        } else {
          break;
        }
      }
      i++;
    }

    // 4. checkpoints (quizzes)
    final checkCap = (dailyMinutes * checkShare).round();
    final checks = records.values.where((r) => r.attempts > 0 && r.stage == TopicStage.check && byKey.containsKey(r.topicKey)).toList()
      ..sort((a, b) => (a.lastReviewed ?? DateTime(2000)).compareTo(b.lastReviewed ?? DateTime(2000)));
    var checkSpent = 0;
    for (final r in checks) {
      if (checkSpent >= checkCap) break;
      if (r.lastReviewed != null && day.difference(r.lastReviewed!).inDays < 2) continue;
      if (add(make(byKey[r.topicKey]!, TopicStage.check, PlanReason.checkpoint, ActivityType.dailyQuiz, 15))) checkSpent += 15;
    }

    // 5. mock test
    final mockDay = day.weekday == DateTime.sunday || (examSoon && day.difference(DateTime(2024)).inDays % 3 == 0);
    if (mockDay) {
      final lowest = records.values.where((r) => r.attempts > 0 && byKey.containsKey(r.topicKey)).toList()
        ..sort((a, b) => a.mastery.compareTo(b.mastery));
      if (lowest.isNotEmpty) {
        items.add(PlanItem(
          id: '${dayKey}_mock',
          topic: byKey[lowest.first.topicKey]!,
          stage: TopicStage.check,
          reason: examSoon ? PlanReason.examPrep : PlanReason.weeklyReview,
          activityType: ActivityType.weeklyMockTest,
          minutes: 30,
        ));
      }
    }

    int rank(PlanItem p) {
      switch (p.reason) {
        case PlanReason.dueReview:
          return 0;
        case PlanReason.newTopic:
          return 1;
        case PlanReason.weakSpot:
          return 2;
        case PlanReason.checkpoint:
          return 3;
        case PlanReason.weeklyReview:
        case PlanReason.examPrep:
          return 4;
      }
    }

    items.sort((a, b) => rank(a).compareTo(rank(b)));

    if (items.isEmpty && topics.isNotEmpty) {
      final t = (topics.toList()..sort((a, b) => a.order.compareTo(b.order))).first;
      items.add(make(t, TopicStage.learn, PlanReason.newTopic, ActivityType.dailyLesson, math.min(t.estimatedMinutes, dailyMinutes)));
    }
    return items;
  }
}
