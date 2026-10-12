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
enum ActivityType {
  phonics,
  colorShape,
  counting,
  memory,
  puzzle,
  creativity,
  emotion,
  music,
}

enum Difficulty { easy, medium, hard }

class Activity {
  final String id;
  final String title;
  final ActivityType type;
  final String ageGroup;
  final Difficulty difficulty;
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
      type: ActivityType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => ActivityType.phonics,
      ),
      ageGroup: map['ageGroup'] ?? 'preschool',
      difficulty: Difficulty.values.firstWhere(
        (e) => e.name == map['difficulty'],
        orElse: () => Difficulty.easy,
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
      case ActivityType.phonics:
        return 'Phonics';
      case ActivityType.colorShape:
        return 'Colors & Shapes';
      case ActivityType.counting:
        return 'Counting';
      case ActivityType.memory:
        return 'Memory';
      case ActivityType.puzzle:
        return 'Puzzle';
      case ActivityType.creativity:
        return 'Creativity';
      case ActivityType.emotion:
        return 'Emotions';
      case ActivityType.music:
        return 'Music';
    }
  }

  IconData get icon {
    switch (type) {
      case ActivityType.phonics:
        return Icons.abc;
      case ActivityType.colorShape:
        return Icons.palette;
      case ActivityType.counting:
        return Icons.calculate;
      case ActivityType.memory:
        return Icons.psychology;
      case ActivityType.puzzle:
        return Icons.extension;
      case ActivityType.creativity:
        return Icons.brush;
      case ActivityType.emotion:
        return Icons.emoji_emotions;
      case ActivityType.music:
        return Icons.music_note;
    }
  }

  Color get color {
    switch (type) {
      case ActivityType.phonics:
        return Colors.blue;
      case ActivityType.colorShape:
        return Colors.purple;
      case ActivityType.counting:
        return Colors.green;
      case ActivityType.memory:
        return Colors.orange;
      case ActivityType.puzzle:
        return Colors.teal;
      case ActivityType.creativity:
        return Colors.pink;
      case ActivityType.emotion:
        return Colors.red;
      case ActivityType.music:
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
  final ActivityType activityType;
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
      activityType: ActivityType.values.firstWhere(
        (e) => e.name == map['activityType'],
        orElse: () => ActivityType.phonics,
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
