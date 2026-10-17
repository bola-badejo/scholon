import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:isapp/features/study_guide/engine/plan_builder.dart';
import 'package:isapp/features/study_guide/engine/spaced_repetition.dart';
import 'package:isapp/features/study_guide/engine/xp_system.dart';
import 'package:isapp/features/study_guide/models/mastery_record.dart';
import 'package:isapp/features/study_guide/models/plan_item.dart';
import 'package:isapp/features/study_guide/models/student_progress.dart';
import 'package:isapp/features/study_guide/models/study_topic.dart';
import 'package:isapp/features/study_guide/services/curriculum_topic_source.dart';
import 'package:isapp/features/study_guide/services/study_guide_repository.dart';

/// Single source of truth for the study guide: curriculum, mastery, today's
/// adaptive plan, XP/streak and the focus timer.
class StudyGuideController extends GetxController {
  final StudyGuideRepository _repo;
  StudyGuideController({StudyGuideRepository? repo}) : _repo = repo ?? StudyGuideRepository();

  final topics = <StudyTopic>[].obs;
  final records = <String, MasteryRecord>{}.obs;
  final progress = const StudentProgress().obs;
  final plan = <PlanItem>[].obs;
  final doneIds = <String>{}.obs;
  final focusSubjects = <String>{}.obs;
  final weeklyMinutes = List<int>.filled(7, 0).obs; // oldest -> today
  final isLoading = true.obs;
  final error = ''.obs;

  // ---- focus timer (Pomodoro) ----
  final focusSecondsLeft = (25 * 60).obs;
  final focusTotalSeconds = (25 * 60).obs;
  final focusRunning = false.obs;
  final onBreak = false.obs;
  final focusRoundsToday = 0.obs;
  Timer? _ticker;

  DateTime get today {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  @override
  void onInit() {
    super.onInit();
    load();
  }

  @override
  void onClose() {
    _ticker?.cancel();
    super.onClose();
  }

  // ============================================================
  //  LOADING
  // ============================================================

  Future<void> load() async {
    isLoading.value = true;
    error.value = '';
    try {
      final results = await Future.wait([
        CurriculumTopicSource.load(),
        _repo.loadMastery(),
        _repo.loadProgress(),
        _repo.sessionsSince(today.subtract(const Duration(days: 6))),
      ]);
      topics.assignAll(results[0] as List<StudyTopic>);
      records.assignAll(results[1] as Map<String, MasteryRecord>);
      progress.value = results[2] as StudentProgress;
      _digestSessions(results[3] as List<Map<String, dynamic>>);
      rebuildPlan();
      if (topics.isEmpty) error.value = 'No curriculum is available yet.';
    } catch (e) {
      error.value = 'Could not load your study guide. Pull to retry.';
      debugPrint('StudyGuide load error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _digestSessions(List<Map<String, dynamic>> sessions) {
    final mins = List<int>.filled(7, 0);
    final done = <String>{};
    for (final s in sessions) {
      final at = (s['at'] as dynamic)?.toDate() as DateTime?;
      if (at == null) continue;
      final d = DateTime(at.year, at.month, at.day);
      final idx = 6 - today.difference(d).inDays;
      if (idx >= 0 && idx < 7) mins[idx] += (s['minutes'] as num?)?.toInt() ?? 0;
      if (d == today && s['itemId'] != null) done.add(s['itemId'] as String);
    }
    weeklyMinutes.assignAll(mins);
    doneIds.assignAll(done);
  }

  // ============================================================
  //  PLAN
  // ============================================================

  void rebuildPlan() {
    final items = PlanBuilder.buildDay(
      day: today,
      topics: topics,
      records: records,
      dailyMinutes: progress.value.dailyMinutes,
      daysToExam: progress.value.daysToExam(DateTime.now()),
      focusSubjects: focusSubjects.toSet(),
    );
    plan.assignAll(items);
  }

  int get plannedMinutes => plan.fold(0, (s, i) => s + i.minutes);
  int get doneCount => plan.where((i) => doneIds.contains(i.id)).length;
  double get dayProgress => plan.isEmpty ? 0 : doneCount / plan.length;
  bool get dayComplete => plan.isNotEmpty && doneCount == plan.length;
  int get minutesToday => weeklyMinutes.last;

  Future<void> setDailyMinutes(int m) async {
    progress.value = progress.value.copyWith(dailyMinutes: m);
    rebuildPlan();
    await _repo.saveProgress(progress.value);
  }

  Future<void> setExamDate(DateTime? d) async {
    progress.value = d == null ? progress.value.copyWith(clearExam: true) : progress.value.copyWith(examDate: d);
    rebuildPlan();
    await _repo.saveProgress(progress.value);
  }

  void toggleFocusSubject(String s) {
    focusSubjects.contains(s) ? focusSubjects.remove(s) : focusSubjects.add(s);
    rebuildPlan();
  }

  // ============================================================
  //  RESULTS
  // ============================================================

  /// [quality] 0..5. Use [qualityFromScore] when a quiz percentage exists,
  /// or the student's own rating from the rate sheet.
  Future<int> completeItem(PlanItem item, {required int quality, int? minutesSpent}) async {
    final minutes = minutesSpent ?? item.minutes;
    final current = records[item.topic.key] ??
        MasteryRecord(topicKey: item.topic.key, subject: item.topic.subject, title: item.topic.title);
    final updated = SpacedRepetition.review(current, quality);
    records[item.topic.key] = updated;

    var p = XpSystem.registerStudyDay(progress.value, DateTime.now());
    final xp = XpSystem.award(minutes: minutes, quality: quality, streak: p.streak);
    p = p.copyWith(xp: p.xp + xp, totalMinutes: p.totalMinutes + minutes, sessionsCompleted: p.sessionsCompleted + 1);
    progress.value = p;

    doneIds.add(item.id);
    weeklyMinutes[6] = weeklyMinutes[6] + minutes;
    weeklyMinutes.refresh();

    try {
      await Future.wait([
        _repo.saveMastery(updated),
        _repo.saveProgress(p),
        _repo.addSession(itemId: item.id, topicKey: item.topic.key, subject: item.topic.subject, minutes: minutes, quality: quality, xp: xp),
      ]);
    } catch (e) {
      debugPrint('StudyGuide save error: $e');
    }
    return xp;
  }

  int qualityFromScore(double percent) => SpacedRepetition.qualityFromScore(percent);

  // ============================================================
  //  INSIGHTS
  // ============================================================

  List<String> get subjects => (topics.map((t) => t.subject).toSet().toList()..sort());

  double subjectMastery(String subject) {
    final rs = records.values.where((r) => r.subject == subject).toList();
    final total = topics.where((t) => t.subject == subject).length;
    if (total == 0) return 0;
    return rs.fold<double>(0, (s, r) => s + SpacedRepetition.decayed(r, DateTime.now())) / total;
  }

  double get overallMastery {
    if (topics.isEmpty) return 0;
    return records.values.fold<double>(0, (s, r) => s + SpacedRepetition.decayed(r, DateTime.now())) / topics.length;
  }

  List<MasteryRecord> get weakSpots {
    final l = records.values.where((r) => r.attempts > 0).toList()..sort((a, b) => a.mastery.compareTo(b.mastery));
    return l.where((r) => r.mastery < .6).take(5).toList();
  }

  int get dueCount => records.values.where((r) => r.attempts > 0 && r.isDue(DateTime.now())).length;

  TopicStage stageOf(StudyTopic t) {
    final r = records[t.key];
    return r == null ? TopicStage.learn : r.stage;
  }

  // ============================================================
  //  FOCUS TIMER
  // ============================================================

  void setFocusLength(int minutes) {
    _ticker?.cancel();
    focusRunning.value = false;
    onBreak.value = false;
    focusTotalSeconds.value = minutes * 60;
    focusSecondsLeft.value = minutes * 60;
  }

  void toggleFocus() {
    if (focusRunning.value) {
      _ticker?.cancel();
      focusRunning.value = false;
      return;
    }
    focusRunning.value = true;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (focusSecondsLeft.value > 0) {
        focusSecondsLeft.value--;
      } else {
        _onFocusFinished();
      }
    });
  }

  void resetFocus() => setFocusLength(onBreak.value ? 5 : focusTotalSeconds.value ~/ 60);

  void _onFocusFinished() {
    _ticker?.cancel();
    focusRunning.value = false;
    if (!onBreak.value) {
      focusRoundsToday.value++;
      onBreak.value = true;
      final breakMinutes = focusRoundsToday.value % 4 == 0 ? 15 : 5;
      focusTotalSeconds.value = breakMinutes * 60;
      focusSecondsLeft.value = breakMinutes * 60;
      Get.snackbar('Focus round done', 'Take a ${breakMinutes}-minute break. Stand up, drink water.', snackPosition: SnackPosition.BOTTOM);
    } else {
      onBreak.value = false;
      focusTotalSeconds.value = 25 * 60;
      focusSecondsLeft.value = 25 * 60;
      Get.snackbar('Break over', 'Ready for the next focus round?', snackPosition: SnackPosition.BOTTOM);
    }
  }
}
