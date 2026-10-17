import 'package:flutter_test/flutter_test.dart';
import 'package:isapp/features/study_guide/engine/plan_builder.dart';
import 'package:isapp/features/study_guide/engine/spaced_repetition.dart';
import 'package:isapp/features/study_guide/engine/xp_system.dart';
import 'package:isapp/features/study_guide/models/mastery_record.dart';
import 'package:isapp/features/study_guide/models/plan_item.dart';
import 'package:isapp/features/study_guide/models/student_progress.dart';
import 'package:isapp/features/study_guide/models/study_topic.dart';

StudyTopic topic(String subject, int n) => StudyTopic(key: '$subject|$n', courseCode: subject, subject: subject, title: '$subject topic $n', order: n);
MasteryRecord rec(StudyTopic t, {double mastery = .3, int attempts = 2, int dueInDays = -1}) => MasteryRecord(
      topicKey: t.key,
      subject: t.subject,
      title: t.title,
      mastery: mastery,
      attempts: attempts,
      intervalDays: 3,
      lastReviewed: DateTime(2026, 10, 1),
      dueDate: DateTime(2026, 10, 13).add(Duration(days: dueInDays)),
    );

void main() {
  final today = DateTime(2026, 10, 13); // Tuesday

  group('SpacedRepetition', () {
    final fresh = const MasteryRecord(topicKey: 'a', subject: 'Maths', title: 'A');

    test('good recall lengthens the interval across reviews', () {
      var r = SpacedRepetition.review(fresh, 5, now: today);
      expect(r.intervalDays, 1);
      r = SpacedRepetition.review(r, 5, now: today);
      expect(r.intervalDays, 3);
      r = SpacedRepetition.review(r, 5, now: today);
      expect(r.intervalDays, greaterThan(3));
      expect(r.mastery, greaterThan(.7));
    });

    test('a lapse resets the interval and lowers mastery', () {
      var r = SpacedRepetition.review(fresh, 5, now: today);
      r = SpacedRepetition.review(r, 5, now: today);
      final lapsed = SpacedRepetition.review(r, 1, now: today);
      expect(lapsed.repetitions, 0);
      expect(lapsed.intervalDays, 1);
      expect(lapsed.mastery, lessThan(r.mastery));
    });

    test('quality bands from score', () {
      expect(SpacedRepetition.qualityFromScore(96), 5);
      expect(SpacedRepetition.qualityFromScore(72), 3);
      expect(SpacedRepetition.qualityFromScore(10), 0);
    });
  });

  group('PlanBuilder', () {
    final topics = [for (var i = 1; i <= 6; i++) topic('Maths', i), for (var i = 1; i <= 6; i++) topic('English', i)];

    test('first day for a new student gets a lesson', () {
      final plan = PlanBuilder.buildDay(day: today, topics: topics, records: {}, dailyMinutes: 90);
      expect(plan, isNotEmpty);
      expect(plan.every((p) => p.stage == TopicStage.learn), isTrue);
      expect(plan.fold<int>(0, (s, p) => s + p.minutes), lessThanOrEqualTo(90));
    });

    test('due reviews come first and respect the time budget', () {
      final records = {for (final t in topics.take(3)) t.key: rec(t, mastery: .7)};
      final plan = PlanBuilder.buildDay(day: today, topics: topics, records: records, dailyMinutes: 60);
      expect(plan.first.reason, PlanReason.dueReview);
      expect(plan.where((p) => p.reason != PlanReason.weeklyReview).fold<int>(0, (s, p) => s + p.minutes), lessThanOrEqualTo(60));
    });

    test('too many half-learned topics blocks new ones', () {
      final records = {for (final t in topics.take(5)) t.key: rec(t, mastery: .2, dueInDays: 3)};
      final plan = PlanBuilder.buildDay(day: today, topics: topics, records: records, dailyMinutes: 120);
      expect(plan.where((p) => p.reason == PlanReason.newTopic), isEmpty);
    });

    test('new topics interleave subjects', () {
      final plan = PlanBuilder.buildDay(day: today, topics: topics, records: {}, dailyMinutes: 120);
      expect(plan.map((p) => p.topic.subject).toSet().length, greaterThan(1));
    });

    test('exam within two weeks limits new learning', () {
      final plan = PlanBuilder.buildDay(day: today, topics: topics, records: {}, dailyMinutes: 120, daysToExam: 7);
      expect(plan.where((p) => p.reason == PlanReason.newTopic).length, lessThanOrEqualTo(1));
    });
  });

  group('XpSystem', () {
    test('streak grows on consecutive days and resets after a gap', () {
      var p = const StudentProgress();
      p = XpSystem.registerStudyDay(p, DateTime(2026, 10, 11));
      p = XpSystem.registerStudyDay(p, DateTime(2026, 10, 12));
      expect(p.streak, 2);
      p = XpSystem.registerStudyDay(p, DateTime(2026, 10, 12));
      expect(p.streak, 2);
      p = XpSystem.registerStudyDay(p, DateTime(2026, 10, 15));
      expect(p.streak, 1);
      expect(p.longestStreak, 2);
    });

    test('levels rise with xp', () {
      expect(const StudentProgress(xp: 0).level, 1);
      expect(const StudentProgress(xp: 400).level, 3);
    });
  });
}
