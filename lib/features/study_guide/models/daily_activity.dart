import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:isapp/features/study_guide/models/activity_type.dart';

// Daily Activity Model
class DailyActivity {
  final String id;
  final DateTime date;
  final String title;
  final String description;
  final ActivityType type;
  final Duration estimatedDuration;
  final List<String> courseCodes;
  final double progress;
  final bool isCompleted;
  final DateTime? completedAt;
  final Map<String, dynamic> metadata;
  final DateTime? createdAt;

  DailyActivity({
    required this.id,
    required this.date,
    required this.title,
    required this.description,
    required this.type,
    required this.estimatedDuration,
    required this.courseCodes,
    this.progress = 0.0,
    this.isCompleted = false,
    this.completedAt,
    this.metadata = const {},
    this.createdAt,
  });

  DailyActivity copyWith({
    String? id,
    DateTime? date,
    String? title,
    String? description,
    ActivityType? type,
    Duration? estimatedDuration,
    List<String>? courseCodes,
    double? progress,
    bool? isCompleted,
    DateTime? completedAt,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
  }) {
    return DailyActivity(
      id: id ?? this.id,
      date: date ?? this.date,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      courseCodes: courseCodes ?? this.courseCodes,
      progress: progress ?? this.progress,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': Timestamp.fromDate(date),
      'title': title,
      'description': description,
      'type': type.name,
      'estimatedMinutes': estimatedDuration.inMinutes,
      'courseCodes': courseCodes,
      'progress': progress,
      'isCompleted': isCompleted,
      'completedAt': completedAt != null
          ? Timestamp.fromDate(completedAt!)
          : null,
      'metadata': metadata,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
    };
  }

  factory DailyActivity.fromJson(Map<String, dynamic> json) {
    return DailyActivity(
      id: json['id'] ?? '',
      date: (json['date'] as Timestamp).toDate(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: ActivityType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ActivityType.dailyLesson,
      ),
      estimatedDuration: Duration(minutes: json['estimatedMinutes'] ?? 30),
      courseCodes: List<String>.from(json['courseCodes'] ?? []),
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      isCompleted: json['isCompleted'] ?? false,
      completedAt: json['completedAt'] != null
          ? (json['completedAt'] as Timestamp).toDate()
          : null,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : null,
    );
  }
}
