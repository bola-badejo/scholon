// lib/Kidling/controllers/progress_controller.dart
//
// Parent-facing analytics. Fixes over the old version:
//  * no composite Firestore index needed (sorting is done on the client)
//  * category / skills / missed items come from data saved with each result,
//    so there is no N+1 read per activity
//  * the weekly chart always shows exactly the last 7 days, ending today
//  * skills radar is real (it used a placeholder before)

import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:isapp/features/kidling/models/kidling_model.dart';

class ProgressController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final RxList<ActivityProgress> recentProgress = <ActivityProgress>[].obs;
  final RxMap<String, double> categoryAccuracy = <String, double>{}.obs;
  final RxMap<String, int> activityTypeCounts = <String, int>{}.obs;
  final RxMap<String, int> missedItems = <String, int>{}.obs;
  final RxMap<String, double> skills = <String, double>{}.obs;
  final Rx<ChildProgressSummary> overallSummary = Rx<ChildProgressSummary>(ChildProgressSummary(lastActive: DateTime.now()));
  final RxList<DailyProgress> weeklyProgress = <DailyProgress>[].obs;
  final RxBool isLoading = false.obs;

  static const skillAxes = ['Literacy', 'Numeracy', 'Logic', 'Memory', 'Creativity', 'Feelings'];

  String get userId => _auth.currentUser?.uid ?? '';

  @override
  void onInit() {
    super.onInit();
    loadAllProgress();
  }

  Future<void> loadAllProgress() async {
    try {
      isLoading.value = true;
      await Future.wait([_loadSummary(), _loadProgress(), _loadWeekly()]);
    } catch (e) {
      // ignore: avoid_print
      print('Error loading progress: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadSummary() async {
    final doc = await _firestore.collection('users').doc(userId).collection('progress').doc('summary').get();
    if (doc.exists) overallSummary.value = ChildProgressSummary.fromMap(doc.data()!);
  }

  Future<void> _loadProgress() async {
    final snap = await _firestore.collection('users').doc(userId).collection('progress').get();
    final list = <ActivityProgress>[];
    for (final d in snap.docs) {
      if (d.id == 'summary') continue;
      try {
        final p = ActivityProgress.fromMap(d.data());
        if (p.isCompleted) list.add(p);
      } catch (_) {}
    }
    list.sort((a, b) => (b.completedAt ?? b.lastPlayed).compareTo(a.completedAt ?? a.lastPlayed));
    recentProgress.value = list;

    final byCat = <String, List<double>>{};
    final counts = <String, int>{};
    final misses = <String, int>{};
    final skillScores = <String, List<double>>{for (final a in skillAxes) a: []};

    for (final p in list) {
      final r = p.results;
      final cat = (r['category'] ?? 'Other').toString();
      final acc = ((r['accuracy'] ?? p.accuracy) as num).toDouble();
      byCat.putIfAbsent(cat, () => []).add(acc);
      counts[cat] = (counts[cat] ?? 0) + 1;

      final m = r['itemMisses'];
      if (m is Map) {
        m.forEach((k, v) => misses[k.toString()] = (misses[k.toString()] ?? 0) + (v as num).toInt());
      }
      final axis = _axisFor(r['type']?.toString());
      if (axis != null) skillScores[axis]!.add(acc);
    }

    categoryAccuracy.value = byCat.map((k, v) => MapEntry(k, v.reduce((a, b) => a + b) / v.length));
    activityTypeCounts.value = counts;
    missedItems.value = misses;
    // Mastery = accuracy x (practice, capped at 4 activities)
    skills.value = {
      for (final a in skillAxes)
        a: skillScores[a]!.isEmpty
            ? 0.0
            : (skillScores[a]!.reduce((x, y) => x + y) / skillScores[a]!.length / 100) * math.min(1.0, skillScores[a]!.length / 4),
    };
  }

  String? _axisFor(String? type) {
    switch (type) {
      case 'phonics':
        return 'Literacy';
      case 'counting':
        return 'Numeracy';
      case 'colorShape':
      case 'puzzle':
        return 'Logic';
      case 'memory':
        return 'Memory';
      case 'creativity':
      case 'music':
        return 'Creativity';
      case 'emotion':
        return 'Feelings';
    }
    return null;
  }

  Future<void> _loadWeekly() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
    final snap = await _firestore
        .collection('users')
        .doc(userId)
        .collection('daily_progress')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .get();
    final byDay = <DateTime, DailyProgress>{};
    for (final d in snap.docs) {
      final p = DailyProgress.fromMap(d.data());
      byDay[DateTime(p.date.year, p.date.month, p.date.day)] = p;
    }
    weeklyProgress.value = List.generate(7, (i) {
      final day = start.add(Duration(days: i));
      return byDay[DateTime(day.year, day.month, day.day)] ?? DailyProgress(date: day);
    });
  }

  // ---------------- getters used by the UI ----------------

  int get totalTimeToday => weeklyProgress.isEmpty ? 0 : weeklyProgress.last.timeSpentMinutes;
  int get activitiesToday => weeklyProgress.isEmpty ? 0 : weeklyProgress.last.activitiesCompleted;

  String get favoriteCategory => activityTypeCounts.isEmpty
      ? 'None yet'
      : activityTypeCounts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;

  String get weakestCategory => categoryAccuracy.isEmpty
      ? 'None yet'
      : categoryAccuracy.entries.reduce((a, b) => a.value <= b.value ? a : b).key;

  double get overallAccuracy {
    if (recentProgress.isEmpty) return 0;
    final t = recentProgress.map((p) => ((p.results['accuracy'] ?? p.accuracy) as num).toDouble()).reduce((a, b) => a + b);
    return t / recentProgress.length;
  }

  /// Top things to practise, e.g. [B, seven, scared]
  List<MapEntry<String, int>> get needsPractice {
    final e = missedItems.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return e.take(6).toList();
  }

  List<Map<String, dynamic>> get weeklyChartData {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weeklyProgress
        .map((p) => {'day': days[p.date.weekday - 1], 'minutes': p.timeSpentMinutes, 'activities': p.activitiesCompleted})
        .toList();
  }

  Map<String, double> get skillsProgress => skills.isEmpty ? {for (final a in skillAxes) a: 0.0} : Map<String, double>.from(skills);
}
