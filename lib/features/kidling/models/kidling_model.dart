// lib/Models/kidling_models.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ========== CHILD MODEL ==========
class ChildProfile {
  final String id;
  final String name;
  final int age;
  final String gender;
  final String learningInterest;
  final String preferredLearningTime;
  final String avatarUrl;
  final DateTime createdAt;
  final Map<String, dynamic> preferences;
  final ChildProgressSummary progress;

  ChildProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.learningInterest,
    required this.preferredLearningTime,
    this.avatarUrl = '',
    required this.createdAt,
    this.preferences = const {},
    required this.progress,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'learningInterest': learningInterest,
      'preferredLearningTime': preferredLearningTime,
      'avatarUrl': avatarUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'preferences': preferences,
      'progress': progress.toMap(),
    };
  }

  factory ChildProfile.fromMap(Map<String, dynamic> map) {
    return ChildProfile(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      age: map['age'] ?? 4,
      gender: map['gender'] ?? '',
      learningInterest: map['learningInterest'] ?? '',
      preferredLearningTime: map['preferredLearningTime'] ?? '',
      avatarUrl: map['avatarUrl'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      preferences: Map<String, dynamic>.from(map['preferences'] ?? {}),
      progress: ChildProgressSummary.fromMap(map['progress'] ?? {}),
    );
  }

  String get ageGroup {
    if (age <= 3) return 'toddler';
    if (age <= 5) return 'preschool';
    return 'kindergarten';
  }
}

class ChildProgressSummary {
  final int totalActivitiesCompleted;
  final int totalTimeSpentMinutes;
  final int starsEarned;
  final int currentStreak;
  final Map<String, int> categoryCompletions;
  final DateTime lastActive;

  ChildProgressSummary({
    this.totalActivitiesCompleted = 0,
    this.totalTimeSpentMinutes = 0,
    this.starsEarned = 0,
    this.currentStreak = 0,
    this.categoryCompletions = const {},
    required this.lastActive,
  });

  Map<String, dynamic> toMap() {
    return {
      'totalActivitiesCompleted': totalActivitiesCompleted,
      'totalTimeSpentMinutes': totalTimeSpentMinutes,
      'starsEarned': starsEarned,
      'currentStreak': currentStreak,
      'categoryCompletions': categoryCompletions,
      'lastActive': Timestamp.fromDate(lastActive),
    };
  }

  factory ChildProgressSummary.fromMap(Map<String, dynamic> map) {
    return ChildProgressSummary(
      totalActivitiesCompleted: map['totalActivitiesCompleted'] ?? 0,
      totalTimeSpentMinutes: map['totalTimeSpentMinutes'] ?? 0,
      starsEarned: map['starsEarned'] ?? 0,
      currentStreak: map['currentStreak'] ?? 0,
      categoryCompletions: Map<String, int>.from(
        map['categoryCompletions'] ?? {},
      ),
      lastActive: (map['lastActive'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

// ========== ACTIVITY MODEL ==========
enum KidActivityType {
  phonics,
  colorShape,
  counting,
  memory,
  puzzle,
  creativity,
  emotion,
  music,
}

enum KidDifficulty { easy, medium, hard }

class Activity {
  final String id;
  final String title;
  final KidActivityType type;
  final String ageGroup;
  final KidDifficulty difficulty;
  final String description;
  final Map<String, dynamic> content;
  final String audioUrl;
  final List<String> imageAssets;
  final Map<String, dynamic> expectedOutcome;
  final int estimatedDuration;
  final List<String> skillsTargeted;
  final bool isPremium;
  final int starReward;

  Activity({
    required this.id,
    required this.title,
    required this.type,
    required this.ageGroup,
    required this.difficulty,
    required this.description,
    required this.content,
    required this.audioUrl,
    required this.imageAssets,
    required this.expectedOutcome,
    this.estimatedDuration = 5,
    this.skillsTargeted = const [],
    this.isPremium = false,
    this.starReward = 3,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'type': type.name,
      'ageGroup': ageGroup,
      'difficulty': difficulty.name,
      'description': description,
      'content': content,
      'audioUrl': audioUrl,
      'imageAssets': imageAssets,
      'expectedOutcome': expectedOutcome,
      'estimatedDuration': estimatedDuration,
      'skillsTargeted': skillsTargeted,
      'isPremium': isPremium,
      'starReward': starReward,
    };
  }

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      type: KidActivityType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => KidActivityType.phonics,
      ),
      ageGroup: map['ageGroup'] ?? 'preschool',
      difficulty: KidDifficulty.values.firstWhere(
        (e) => e.name == map['difficulty'],
        orElse: () => KidDifficulty.easy,
      ),
      description: map['description'] ?? '',
      content: Map<String, dynamic>.from(map['content'] ?? {}),
      audioUrl: map['audioUrl'] ?? '',
      imageAssets: List<String>.from(map['imageAssets'] ?? []),
      expectedOutcome: Map<String, dynamic>.from(map['expectedOutcome'] ?? {}),
      estimatedDuration: map['estimatedDuration'] ?? 5,
      skillsTargeted: List<String>.from(map['skillsTargeted'] ?? []),
      isPremium: map['isPremium'] ?? false,
      starReward: map['starReward'] ?? 3,
    );
  }

  String get displayType {
    switch (type) {
      case KidActivityType.phonics:
        return 'Phonics';
      case KidActivityType.colorShape:
        return 'Colors & Shapes';
      case KidActivityType.counting:
        return 'Counting';
      case KidActivityType.memory:
        return 'Memory';
      case KidActivityType.puzzle:
        return 'Puzzle';
      case KidActivityType.creativity:
        return 'Creativity';
      case KidActivityType.emotion:
        return 'Emotions';
      case KidActivityType.music:
        return 'Music';
    }
  }

  IconData get icon {
    switch (type) {
      case KidActivityType.phonics:
        return Icons.abc;
      case KidActivityType.colorShape:
        return Icons.palette;
      case KidActivityType.counting:
        return Icons.calculate;
      case KidActivityType.memory:
        return Icons.psychology;
      case KidActivityType.puzzle:
        return Icons.extension;
      case KidActivityType.creativity:
        return Icons.brush;
      case KidActivityType.emotion:
        return Icons.emoji_emotions;
      case KidActivityType.music:
        return Icons.music_note;
    }
  }

  Color get color {
    switch (type) {
      case KidActivityType.phonics:
        return Colors.blue;
      case KidActivityType.colorShape:
        return Colors.purple;
      case KidActivityType.counting:
        return Colors.green;
      case KidActivityType.memory:
        return Colors.orange;
      case KidActivityType.puzzle:
        return Colors.teal;
      case KidActivityType.creativity:
        return Colors.pink;
      case KidActivityType.emotion:
        return Colors.red;
      case KidActivityType.music:
        return Colors.indigo;
    }
  }
}

// ========== ACTIVITY PROGRESS MODEL ==========
class ActivityProgress {
  final String activityId;
  final String childId;
  final bool isCompleted;
  final int score;
  final int timeSpentSeconds;
  final int attempts;
  final DateTime lastPlayed;
  final DateTime? completedAt;
  final Map<String, dynamic> results;
  final int starsEarned;

  ActivityProgress({
    required this.activityId,
    required this.childId,
    this.isCompleted = false,
    this.score = 0,
    this.timeSpentSeconds = 0,
    this.attempts = 0,
    required this.lastPlayed,
    this.completedAt,
    this.results = const {},
    this.starsEarned = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'activityId': activityId,
      'childId': childId,
      'isCompleted': isCompleted,
      'score': score,
      'timeSpentSeconds': timeSpentSeconds,
      'attempts': attempts,
      'lastPlayed': Timestamp.fromDate(lastPlayed),
      'completedAt': completedAt != null
          ? Timestamp.fromDate(completedAt!)
          : null,
      'results': results,
      'starsEarned': starsEarned,
    };
  }

  factory ActivityProgress.fromMap(Map<String, dynamic> map) {
    return ActivityProgress(
      activityId: map['activityId'] ?? '',
      childId: map['childId'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      score: map['score'] ?? 0,
      timeSpentSeconds: map['timeSpentSeconds'] ?? 0,
      attempts: map['attempts'] ?? 0,
      lastPlayed: (map['lastPlayed'] as Timestamp).toDate(),
      completedAt: map['completedAt'] != null
          ? (map['completedAt'] as Timestamp).toDate()
          : null,
      results: Map<String, dynamic>.from(map['results'] ?? {}),
      starsEarned: map['starsEarned'] ?? 0,
    );
  }

  double get accuracy => attempts > 0 ? (score / attempts) * 100 : 0;
}

// ========== LAST ACTIVITY MODEL ==========
class LastActivity {
  final String activityId;
  final String activityTitle;
  final KidActivityType activityType;
  final double progress;
  final DateTime lastPlayed;
  final int timeSpentSeconds;

  LastActivity({
    required this.activityId,
    required this.activityTitle,
    required this.activityType,
    required this.progress,
    required this.lastPlayed,
    this.timeSpentSeconds = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'activityId': activityId,
      'activityTitle': activityTitle,
      'activityType': activityType.name,
      'progress': progress,
      'lastPlayed': Timestamp.fromDate(lastPlayed),
      'timeSpentSeconds': timeSpentSeconds,
    };
  }

  factory LastActivity.fromMap(Map<String, dynamic> map) {
    return LastActivity(
      activityId: map['activityId'] ?? '',
      activityTitle: map['activityTitle'] ?? '',
      activityType: KidActivityType.values.firstWhere(
        (e) => e.name == map['activityType'],
        orElse: () => KidActivityType.phonics,
      ),
      progress: (map['progress'] ?? 0).toDouble(),
      lastPlayed: (map['lastPlayed'] as Timestamp).toDate(),
      timeSpentSeconds: map['timeSpentSeconds'] ?? 0,
    );
  }
}

// ========== DAILY PROGRESS MODEL ==========
class DailyProgress {
  final DateTime date;
  final int activitiesCompleted;
  final int timeSpentMinutes;
  final int starsEarned;
  final List<String> completedActivityIds;

  DailyProgress({
    required this.date,
    this.activitiesCompleted = 0,
    this.timeSpentMinutes = 0,
    this.starsEarned = 0,
    this.completedActivityIds = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'activitiesCompleted': activitiesCompleted,
      'timeSpentMinutes': timeSpentMinutes,
      'starsEarned': starsEarned,
      'completedActivityIds': completedActivityIds,
    };
  }

  factory DailyProgress.fromMap(Map<String, dynamic> map) {
    return DailyProgress(
      date: (map['date'] as Timestamp).toDate(),
      activitiesCompleted: map['activitiesCompleted'] ?? 0,
      timeSpentMinutes: map['timeSpentMinutes'] ?? 0,
      starsEarned: map['starsEarned'] ?? 0,
      completedActivityIds: List<String>.from(
        map['completedActivityIds'] ?? [],
      ),
    );
  }
}
