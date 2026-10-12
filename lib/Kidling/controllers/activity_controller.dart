// lib/Kidling/controllers/activity_controller.dart

import 'dart:async';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isapp/Kidling/controllers/audio_assistant_services.dart';
import 'package:isapp/Kidling/controllers/home_controller.dart';
import 'package:isapp/Kidling/models/kidling_model.dart';
import 'package:isapp/Kidling/screens/completion_overlay.dart';
import 'package:isapp/Kidling/theme/magic_theme.dart';

class ActivityController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final AudioAssistantService _audio = AudioAssistantService.ensure();

  // ---- current session ----
  final Rx<Activity?> currentActivity = Rx<Activity?>(null);
  final Rx<ActivityProgress?> currentProgress = Rx<ActivityProgress?>(null);

  final RxInt sessionId = 0.obs; // bumps on every (re)start so the UI rebuilds fresh
  final RxInt sessionScore = 0.obs; // correct on first try
  final RxInt sessionAttempts = 0.obs; // scored questions
  final RxInt sessionTimeSeconds = 0.obs;
  final RxInt stepsDone = 0.obs;
  final RxInt totalSteps = 0.obs;
  final RxBool isPaused = false.obs;
  final RxBool isCompleted = false.obs;
  final RxMap<String, dynamic> sessionResults = <String, dynamic>{}.obs;
  final RxString formattedTime = '00:00'.obs;

  final Map<String, int> _itemHits = {};
  final Map<String, int> _itemMisses = {};

  /// Activity widgets register these so the lightbulb / speaker buttons in the
  /// top bar do something smart for the current question.
  VoidCallback? onHint;
  VoidCallback? onReplay;

  Timer? _timer;

  String get userId => _auth.currentUser?.uid ?? '';
  HomeController get _home => Get.find<HomeController>();

  double get progressFraction =>
      totalSteps.value <= 0 ? 0.0 : (stepsDone.value / totalSteps.value).clamp(0.0, 1.0);

  /// Kept for older call sites.
  String get progressPercentage => '${(progressFraction * 100).round()}%';

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  // ============================================================
  //  LIFECYCLE
  // ============================================================

  Future<void> startActivity(Activity activity) async {
    _timer?.cancel();
    sessionScore.value = 0;
    sessionAttempts.value = 0;
    sessionTimeSeconds.value = 0;
    stepsDone.value = 0;
    totalSteps.value = 0;
    isPaused.value = false;
    isCompleted.value = false;
    formattedTime.value = '00:00';
    sessionResults.clear();
    _itemHits.clear();
    _itemMisses.clear();
    onHint = null;
    onReplay = null;
    currentProgress.value = _home.progressMap[activity.id];

    sessionId.value++;
    currentActivity.value = activity;

    _startTimer();
    _home.saveLastActivity(activity, 0);
  }

  /// Called by activity widgets (safe to call during build).
  void setTotalSteps(int n) => Future.microtask(() => totalSteps.value = n);
  void addSteps(int n) => Future.microtask(() => totalSteps.value += n);
  void stepDone([int n = 1]) => stepsDone.value = math.min(stepsDone.value + n, totalSteps.value);

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!isPaused.value && !isCompleted.value) {
        sessionTimeSeconds.value++;
        final m = sessionTimeSeconds.value ~/ 60;
        final s = sessionTimeSeconds.value % 60;
        formattedTime.value = '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
      }
    });
  }

  void pauseActivity() => isPaused.value = true;
  void resumeActivity() => isPaused.value = false;

  /// Leaving the page. Safe to call multiple times.
  Future<void> endSession(Activity leaving) async {
    if (currentActivity.value?.id != leaving.id) return; // a newer session already took over
    _timer?.cancel();
    onHint = null;
    onReplay = null;
    await _audio.stop();
    if (!isCompleted.value && stepsDone.value > 0) {
      _home.saveLastActivity(leaving, progressFraction * 100);
    }
  }

  // ============================================================
  //  SCORING
  // ============================================================

  /// Records ONE scored question (the child's first try only).
  void recordAttempt({bool correct = false, String? item, Map<String, dynamic>? data}) {
    sessionAttempts.value++;
    if (correct) sessionScore.value++;
    if (item != null) {
      final m = correct ? _itemHits : _itemMisses;
      m[item] = (m[item] ?? 0) + 1;
    }
    if (data != null) sessionResults.addAll(data);
  }

  /// Older API, still supported.
  void addScore(int points, {Map<String, dynamic>? resultData}) {
    sessionScore.value += points;
    sessionAttempts.value++;
    if (resultData != null) sessionResults.addAll(resultData);
  }

  // ============================================================
  //  HINTS / INSTRUCTIONS
  // ============================================================

  void requestHint() {
    final a = currentActivity.value;
    if (a == null) return;
    if (onHint != null) {
      onHint!();
    } else {
      _audio.giveHint(a.type.name, sessionAttempts.value);
    }
  }

  void playInstruction() {
    final a = currentActivity.value;
    if (a == null) return;
    if (onReplay != null) {
      onReplay!();
    } else {
      _audio.speak(a.description);
    }
  }

  // ============================================================
  //  COMPLETION
  // ============================================================

  /// [accuracyOverride] is 0..100 for activities that are not question based
  /// (drawing, memory, music...).
  Future<void> completeActivity({Map<String, dynamic>? finalResults, double? accuracyOverride}) async {
    if (isCompleted.value) return;
    final activity = currentActivity.value;
    if (activity == null) return;

    isCompleted.value = true;
    _timer?.cancel();
    stepsDone.value = totalSteps.value;
    if (finalResults != null) sessionResults.addAll(finalResults);

    final accuracy = accuracyOverride ??
        (sessionAttempts.value > 0 ? (sessionScore.value / sessionAttempts.value) * 100 : 100.0);
    final stars = _starsFor(accuracy, activity);

    final previous = currentProgress.value;
    final bestStars = math.max(previous?.starsEarned ?? 0, stars);
    final firstCompletion = !(previous?.isCompleted ?? false);

    final progress = ActivityProgress(
      activityId: activity.id,
      childId: userId,
      isCompleted: true,
      score: sessionScore.value,
      timeSpentSeconds: sessionTimeSeconds.value + (previous?.timeSpentSeconds ?? 0),
      attempts: sessionAttempts.value,
      lastPlayed: DateTime.now(),
      completedAt: DateTime.now(),
      starsEarned: bestStars,
      results: {
        ...sessionResults,
        'accuracy': accuracy,
        'sessionStars': stars,
        'category': activity.displayType,
        'type': activity.type.name,
        'level': _levelOf(activity),
        'skills': activity.skillsTargeted,
        'itemHits': _itemHits,
        'itemMisses': _itemMisses,
      },
    );

    await _saveProgress(progress);

    await _home.updateDailyProgress(
      timeSpentMinutes: math.max(1, (sessionTimeSeconds.value / 60).ceil()),
      starsEarned: stars,
      activityId: activity.id,
      category: activity.displayType,
      firstCompletion: firstCompletion,
    );

    _audio.playSfx('complete');
    Get.dialog(
      CompletionOverlay(
        activity: activity,
        stars: stars,
        accuracy: accuracy,
        timeSpent: formattedTime.value,
        firstTryCorrect: sessionScore.value,
        totalQuestions: sessionAttempts.value,
        next: _home.nextInPath(activity),
        isNewBest: stars > (previous?.starsEarned ?? 0),
        onReplay: () {
          Get.back();
          startActivity(activity);
        },
      ),
      barrierDismissible: false,
      barrierColor: Magic.midnight.withOpacity(.7),
    );
  }

  int _levelOf(Activity a) => int.tryParse(a.id.split('_').last) ?? 0;

  /// 85%+ = 3 stars, 60%+ = 2 stars, otherwise 1 "participation" star.
  int _starsFor(double accuracy, Activity a) {
    final s = accuracy >= 85 ? 3 : (accuracy >= 60 ? 2 : 1);
    return math.min(s, math.max(1, a.starReward));
  }

  Future<void> _saveProgress(ActivityProgress progress) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('progress')
          .doc(progress.activityId)
          .set(progress.toMap());
      currentProgress.value = progress;
      _home.progressMap[progress.activityId] = progress;
      _home.progressMap.refresh();
      final a = currentActivity.value;
      if (a != null) await _home.saveLastActivity(a, 100);
    } catch (e) {
      // ignore: avoid_print
      print('Error saving progress: $e');
    }
  }

  // Convenience used by the completion overlay.
  String get summaryLine {
    final a = sessionScore.value;
    final t = sessionAttempts.value;
    return t == 0 ? '' : '$a of $t right the first time';
  }
}
