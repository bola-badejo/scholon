// lib/Kidling/controllers/home_controller.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:isapp/features/kidling/models/kidling_model.dart';
import 'package:isapp/features/kidling/theme/magic_theme.dart';
import 'package:isapp/features/auth/models/user.dart';
import 'package:isapp/features/auth/controllers/authentication_controller.dart';

class HomeController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ---- reactive state ----
  final Rx<ChildProfile?> currentChild = Rx<ChildProfile?>(null);
  final RxList<Activity> allActivities = <Activity>[].obs;
  final RxList<Activity> recommendedActivities = <Activity>[].obs; // today's quests
  final RxList<Activity> recentActivities = <Activity>[].obs;
  final Rx<LastActivity?> lastActivity = Rx<LastActivity?>(null);
  final Rx<DailyProgress> todayProgress = Rx<DailyProgress>(DailyProgress(date: DateTime.now()));
  final RxMap<String, List<Activity>> activitiesByCategory = <String, List<Activity>>{}.obs;
  final RxMap<String, ActivityProgress> progressMap = <String, ActivityProgress>{}.obs;

  final RxBool isLoading = true.obs;
  final RxBool isRefreshing = false.obs;
  final RxString error = ''.obs;

  /// How many activities make a "perfect day".
  static const int dailyGoal = 3;

  String get userId => _auth.currentUser?.uid ?? '';

  ParentUser? get parentUser {
    final authService = Get.find<AuthService>();
    final user = authService.currentUser.value;
    if (user is ParentUser) return user;
    return null;
  }

  @override
  void onInit() {
    super.onInit();
    loadHomeData();
  }

  // ============================================================
  //  LOADING
  // ============================================================

  Future<void> loadHomeData() async {
    try {
      isLoading.value = true;
      error.value = '';
      await _loadChildProfile();
      await Future.wait([_loadTodayProgress(), _loadLastActivity(), _loadProgressDocs()]);
      await _loadActivities();
      _buildQuests();
      _buildRecent();
    } catch (e) {
      error.value = 'Failed to load data: $e';
      // ignore: avoid_print
      print('Error loading home data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshHomeData() async {
    isRefreshing.value = true;
    await loadHomeData();
    isRefreshing.value = false;
  }

  Future<void> _loadChildProfile() async {
    try {
      final parent = parentUser;
      if (parent == null) return;
      final childData = parent.metadata;
      if (childData != null && childData.containsKey('childName')) {
        final progressDoc =
            await _firestore.collection('users').doc(userId).collection('progress').doc('summary').get();
        final progress = progressDoc.exists
            ? ChildProgressSummary.fromMap(progressDoc.data()!)
            : ChildProgressSummary(lastActive: DateTime.now());

        currentChild.value = ChildProfile(
          id: userId,
          name: childData['childName'] ?? 'Little Learner',
          age: childData['childAge'] is int
              ? childData['childAge']
              : int.tryParse(childData['childAge']?.toString() ?? '4') ?? 4,
          gender: childData['childGender'] ?? 'Not specified',
          learningInterest: childData['learningInterest'] ?? 'General',
          preferredLearningTime: childData['preferredLearningTime'] ?? 'Flexible',
          createdAt: parent.createdAt,
          preferences: {},
          progress: progress,
        );
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error loading child profile: $e');
    }
  }

  String get _todayKey {
    final t = DateTime.now();
    return '${t.year}-${t.month}-${t.day}';
  }

  Future<void> _loadTodayProgress() async {
    try {
      final doc =
          await _firestore.collection('users').doc(userId).collection('daily_progress').doc(_todayKey).get();
      todayProgress.value = doc.exists ? DailyProgress.fromMap(doc.data()!) : DailyProgress(date: DateTime.now());
    } catch (e) {
      // ignore: avoid_print
      print('Error loading today progress: $e');
    }
  }

  Future<void> _loadLastActivity() async {
    try {
      final doc = await _firestore.collection('users').doc(userId).collection('metadata').doc('last_activity').get();
      if (doc.exists) lastActivity.value = LastActivity.fromMap(doc.data()!);
    } catch (e) {
      // ignore: avoid_print
      print('Error loading last activity: $e');
    }
  }

  /// One read for every activity the child has ever played (<= ~50 docs).
  Future<void> _loadProgressDocs() async {
    try {
      final snap = await _firestore.collection('users').doc(userId).collection('progress').get();
      final map = <String, ActivityProgress>{};
      for (final d in snap.docs) {
        if (d.id == 'summary') continue;
        try {
          final p = ActivityProgress.fromMap(d.data());
          if (p.activityId.isNotEmpty) map[p.activityId] = p;
        } catch (_) {}
      }
      progressMap.value = map;
    } catch (e) {
      // ignore: avoid_print
      print('Error loading progress docs: $e');
    }
  }

  Future<void> _loadActivities() async {
    try {
      final snapshot = await _firestore.collection('activities').get();
      if (snapshot.docs.isEmpty) {
        // ignore: avoid_print
        print('No activities in Firestore. Run SeedActivities.seedAllActivities()');
        return;
      }
      final list = <Activity>[];
      for (final doc in snapshot.docs) {
        try {
          list.add(Activity.fromMap(doc.data()));
        } catch (e) {
          // ignore: avoid_print
          print('Error parsing activity ${doc.id}: $e');
        }
      }
      list.sort((a, b) {
        final t = a.type.index.compareTo(b.type.index);
        return t != 0 ? t : a.level.compareTo(b.level);
      });
      allActivities.value = list;

      final grouped = <String, List<Activity>>{};
      for (final a in list) {
        grouped.putIfAbsent(a.displayType, () => []).add(a);
      }
      activitiesByCategory.value = grouped;
    } catch (e) {
      // ignore: avoid_print
      print('Error loading activities: $e');
    }
  }

  // ============================================================
  //  LEARNING PATH
  // ============================================================

  List<Activity> pathFor(KidActivityType type) =>
      allActivities.where((a) => a.type == type).toList()..sort((a, b) => a.level.compareTo(b.level));

  /// Older children start further along the path (levels 1..N are open).
  int get headStart {
    switch (currentChild.value?.ageGroup) {
      case 'kindergarten':
        return 3;
      case 'preschool':
        return 2;
      default:
        return 1;
    }
  }

  bool isCompleted(Activity a) => progressMap[a.id]?.isCompleted ?? false;
  int starsFor(Activity a) => progressMap[a.id]?.starsEarned ?? 0;

  /// A level opens when the one before it was finished (gentle, gradual).
  bool isUnlocked(Activity a) {
    if (a.level <= headStart) return true;
    final path = pathFor(a.type);
    final i = path.indexWhere((x) => x.id == a.id);
    if (i <= 0) return true;
    return isCompleted(path[i - 1]);
  }

  Activity? nextInPath(Activity a) {
    final path = pathFor(a.type);
    final i = path.indexWhere((x) => x.id == a.id);
    if (i < 0 || i + 1 >= path.length) return null;
    return path[i + 1];
  }

  /// First level in this world that is open but not yet finished.
  Activity? nextUp(KidActivityType type) {
    for (final a in pathFor(type)) {
      if (isUnlocked(a) && !isCompleted(a)) return a;
    }
    return null;
  }

  int completedIn(KidActivityType type) => pathFor(type).where(isCompleted).length;
  double worldProgress(KidActivityType type) {
    final p = pathFor(type);
    return p.isEmpty ? 0 : completedIn(type) / p.length;
  }

  int get totalStars => progressMap.values.fold(0, (s, p) => s + p.starsEarned);

  /// Today's quests: the next step from three different worlds, favouring the
  /// child's interest and the worlds they have practised least.
  void _buildQuests() {
    final interest = (currentChild.value?.learningInterest ?? '').toLowerCase();
    final candidates = <Activity>[];
    for (final t in KidActivityType.values) {
      final n = nextUp(t);
      if (n != null) candidates.add(n);
    }
    candidates.sort((a, b) {
      int score(Activity x) {
        var s = completedIn(x.type) * 10;
        final name = x.world.name.toLowerCase() + x.displayType.toLowerCase();
        if (interest.isNotEmpty && (name.contains(interest) || interest.contains(x.type.name.toLowerCase()))) s -= 25;
        return s;
      }

      return score(a).compareTo(score(b));
    });
    recommendedActivities.value = candidates.take(dailyGoal).toList();
  }

  void _buildRecent() {
    final played = progressMap.values.toList()..sort((a, b) => b.lastPlayed.compareTo(a.lastPlayed));
    final ids = played.take(8).map((p) => p.activityId).toList();
    recentActivities.value = ids
        .map((id) => allActivities.firstWhereOrNull((a) => a.id == id))
        .whereType<Activity>()
        .toList();
  }

  Activity? get resumeCandidate {
    final last = lastActivity.value;
    if (last == null) return null;
    final a = allActivities.firstWhereOrNull((x) => x.id == last.activityId);
    if (a == null) return null;
    if (isCompleted(a)) return nextInPath(a) ?? a;
    return a;
  }

  // ============================================================
  //  WRITES
  // ============================================================

  Future<void> saveLastActivity(Activity activity, double progress) async {
    try {
      final last = LastActivity(
        activityId: activity.id,
        activityTitle: activity.title,
        activityType: activity.type,
        progress: progress,
        lastPlayed: DateTime.now(),
      );
      await _firestore.collection('users').doc(userId).collection('metadata').doc('last_activity').set(last.toMap());
      lastActivity.value = last;
    } catch (e) {
      // ignore: avoid_print
      print('Error saving last activity: $e');
    }
  }

  Future<void> updateDailyProgress({
    required int timeSpentMinutes,
    required int starsEarned,
    String? activityId,
    String? category,
    bool firstCompletion = true,
  }) async {
    try {
      final current = todayProgress.value;
      final updated = DailyProgress(
        date: DateTime.now(),
        activitiesCompleted: current.activitiesCompleted + 1,
        timeSpentMinutes: current.timeSpentMinutes + timeSpentMinutes,
        starsEarned: current.starsEarned + starsEarned,
        completedActivityIds:
            activityId != null ? [...current.completedActivityIds, activityId] : current.completedActivityIds,
      );
      await _firestore.collection('users').doc(userId).collection('daily_progress').doc(_todayKey).set(updated.toMap());
      todayProgress.value = updated;
      await _updateChildProgressSummary(timeSpentMinutes, starsEarned, category, firstCompletion);
      _buildQuests();
      _buildRecent();
    } catch (e) {
      // ignore: avoid_print
      print('Error updating daily progress: $e');
    }
  }

  Future<void> _updateChildProgressSummary(int timeSpent, int stars, String? category, bool first) async {
    try {
      final child = currentChild.value;
      if (child == null) return;
      final s = child.progress;
      final cats = Map<String, int>.from(s.categoryCompletions);
      if (category != null && first) cats[category] = (cats[category] ?? 0) + 1;

      final updated = ChildProgressSummary(
        totalActivitiesCompleted: s.totalActivitiesCompleted + (first ? 1 : 0),
        totalTimeSpentMinutes: s.totalTimeSpentMinutes + timeSpent,
        starsEarned: s.starsEarned + stars,
        currentStreak: _calculateStreak(s),
        categoryCompletions: cats,
        lastActive: DateTime.now(),
      );
      await _firestore.collection('users').doc(userId).collection('progress').doc('summary').set(updated.toMap());
      currentChild.value = child._copyWith(progress: updated);
    } catch (e) {
      // ignore: avoid_print
      print('Error updating child progress: $e');
    }
  }

  /// Calendar-day based, so month ends work (the old code compared day numbers).
  int _calculateStreak(ChildProgressSummary s) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final last = DateTime(s.lastActive.year, s.lastActive.month, s.lastActive.day);
    final diff = today.difference(last).inDays;
    if (s.currentStreak == 0) return 1;
    if (diff == 0) return s.currentStreak;
    if (diff == 1) return s.currentStreak + 1;
    return 1;
  }

  // ============================================================
  //  TEXT
  // ============================================================

  String get childName => currentChild.value?.name ?? 'Little Learner';

  String get greetingMessage {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning, $childName!';
    if (hour < 17) return 'Good afternoon, $childName!';
    return 'Good evening, $childName!';
  }

  /// What Luma says out loud when the home screen opens.
  String get welcomeSpeech {
    final done = todayProgress.value.activitiesCompleted;
    final streak = currentChild.value?.progress.currentStreak ?? 0;
    final buf = StringBuffer('$greetingMessage ');
    if (done == 0) {
      buf.write(streak > 1
          ? 'You have played $streak days in a row. Wow! Ready for today\'s adventure?'
          : 'I am so happy to see you! Pick an adventure.');
    } else if (done < dailyGoal) {
      buf.write('You finished $done today. Let us find more stars!');
    } else {
      buf.write('You reached your daily goal. You are a superstar!');
    }
    return buf.toString();
  }
}

extension ChildProfileCopyWith on ChildProfile {
  ChildProfile _copyWith({ChildProgressSummary? progress}) {
    return ChildProfile(
      id: id,
      name: name,
      age: age,
      gender: gender,
      learningInterest: learningInterest,
      preferredLearningTime: preferredLearningTime,
      avatarUrl: avatarUrl,
      createdAt: createdAt,
      preferences: preferences,
      progress: progress ?? this.progress,
    );
  }
}
