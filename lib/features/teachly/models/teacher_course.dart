import 'package:isapp/features/teachly/models/course_data.dart' show Course;

enum CourseProgressStatus {
  notStarted,
  inProgress,
  completed,
}

class ChapterProgress {
  final int chapterNumber;
  final String title;
  double progress; // 0.0 to 1.0
  bool isCompleted;
  DateTime? startedAt;
  DateTime? completedAt;
  List<AssessmentResult> assessments;

  ChapterProgress({
    required this.chapterNumber,
    required this.title,
    this.progress = 0.0,
    this.isCompleted = false,
    this.startedAt,
    this.completedAt,
    this.assessments = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'chapterNumber': chapterNumber,
      'title': title,
      'progress': progress,
      'isCompleted': isCompleted,
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'assessments': assessments.map((a) => a.toJson()).toList(),
    };
  }

  factory ChapterProgress.fromJson(Map<String, dynamic> json) {
    return ChapterProgress(
      chapterNumber: json['chapterNumber'] ?? 0,
      title: json['title'] ?? '',
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      isCompleted: json['isCompleted'] ?? false,
      startedAt: json['startedAt'] != null ? DateTime.parse(json['startedAt']) : null,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      assessments: List<Map<String, dynamic>>.from(json['assessments'] ?? [])
          .map((a) => AssessmentResult.fromJson(a))
          .toList(),
    );
  }
}

class AssessmentResult {
  final String type; // quiz, assignment, project, exam
  final String title;
  final double score;
  final double maxScore;
  final bool isPassed;
  final DateTime? completedAt;

  AssessmentResult({
    required this.type,
    required this.title,
    required this.score,
    required this.maxScore,
    required this.isPassed,
    this.completedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'title': title,
      'score': score,
      'maxScore': maxScore,
      'isPassed': isPassed,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory AssessmentResult.fromJson(Map<String, dynamic> json) {
    return AssessmentResult(
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      maxScore: (json['maxScore'] as num?)?.toDouble() ?? 0.0,
      isPassed: json['isPassed'] ?? false,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
    );
  }

  double get percentage => maxScore > 0 ? (score / maxScore) * 100 : 0;
}

class TeacherCourse {
  final String courseId;
  final Course course;
  final String teacherId;
  CourseProgressStatus status;
  double overallProgress; // 0.0 to 1.0
  DateTime enrolledAt;
  DateTime? startedAt;
  DateTime? completedAt;
  List<ChapterProgress> chapterProgress;
  List<AssessmentResult> assessments;
  Map<String, dynamic>? notes;
  Map<String, dynamic>? bookmarks;

  TeacherCourse({
    required this.courseId,
    required this.course,
    required this.teacherId,
    this.status = CourseProgressStatus.notStarted,
    this.overallProgress = 0.0,
    required this.enrolledAt,
    this.startedAt,
    this.completedAt,
    this.chapterProgress = const [],
    this.assessments = const [],
    this.notes,
    this.bookmarks,
  });

  // Update progress based on chapter completion
  void updateProgress() {
    if (chapterProgress.isEmpty) {
      overallProgress = 0.0;
      return;
    }

    final completedChapters = chapterProgress.where((c) => c.isCompleted).length;
    overallProgress = completedChapters / chapterProgress.length;

    // Update status
    if (overallProgress == 0.0) {
      status = CourseProgressStatus.notStarted;
    } else if (overallProgress == 1.0) {
      status = CourseProgressStatus.completed;
      completedAt = DateTime.now();
    } else {
      status = CourseProgressStatus.inProgress;
      startedAt ??= DateTime.now();
    }
  }

  // Add or update chapter progress
  void updateChapterProgress(int chapterNumber, double progress, bool isCompleted) {
    final chapterIndex = chapterProgress.indexWhere((c) => c.chapterNumber == chapterNumber);
    
    if (chapterIndex >= 0) {
      chapterProgress[chapterIndex].progress = progress;
      chapterProgress[chapterIndex].isCompleted = isCompleted;
      if (isCompleted) {
        chapterProgress[chapterIndex].completedAt = DateTime.now();
      }
    } else {
      chapterProgress.add(ChapterProgress(
        chapterNumber: chapterNumber,
        title: 'Chapter $chapterNumber',
        progress: progress,
        isCompleted: isCompleted,
        startedAt: DateTime.now(),
        completedAt: isCompleted ? DateTime.now() : null,
      ));
    }
    
    updateProgress();
  }

  // Add assessment result
  void addAssessmentResult(AssessmentResult result) {
    assessments.add(result);
  }

  // Get formatted progress text
  String get progressText {
    final percentage = (overallProgress * 100).toInt();
    return '$percentage% Complete';
  }

  // Get remaining time estimate
  String? get estimatedTimeRemaining {
    if (overallProgress == 0 || startedAt == null) return null;
    
    final daysSinceStart = DateTime.now().difference(startedAt!).inDays;
    if (daysSinceStart == 0) return null;
    
    final dailyProgress = overallProgress / daysSinceStart;
    if (dailyProgress == 0) return null;
    
    final daysRemaining = ((1 - overallProgress) / dailyProgress).ceil();
    
    if (daysRemaining < 7) {
      return '$daysRemaining day${daysRemaining > 1 ? 's' : ''}';
    } else if (daysRemaining < 30) {
      final weeks = (daysRemaining / 7).ceil();
      return '$weeks week${weeks > 1 ? 's' : ''}';
    } else {
      final months = (daysRemaining / 30).ceil();
      return '$months month${months > 1 ? 's' : ''}';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'courseId': courseId,
      'course': course.toJson(),
      'teacherId': teacherId,
      'status': status.index,
      'overallProgress': overallProgress,
      'enrolledAt': enrolledAt.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'chapterProgress': chapterProgress.map((c) => c.toJson()).toList(),
      'assessments': assessments.map((a) => a.toJson()).toList(),
      'notes': notes,
      'bookmarks': bookmarks,
    };
  }

  factory TeacherCourse.fromJson(Map<String, dynamic> json) {
    return TeacherCourse(
      courseId: json['courseId'] ?? '',
      course: Course.fromJson(json['course']),
      teacherId: json['teacherId'] ?? '',
      status: CourseProgressStatus.values[json['status'] ?? 0],
      overallProgress: (json['overallProgress'] as num?)?.toDouble() ?? 0.0,
      enrolledAt: DateTime.parse(json['enrolledAt']),
      startedAt: json['startedAt'] != null ? DateTime.parse(json['startedAt']) : null,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      chapterProgress: List<Map<String, dynamic>>.from(json['chapterProgress'] ?? [])
          .map((c) => ChapterProgress.fromJson(c))
          .toList(),
      assessments: List<Map<String, dynamic>>.from(json['assessments'] ?? [])
          .map((a) => AssessmentResult.fromJson(a))
          .toList(),
      notes: json['notes'] != null ? Map<String, dynamic>.from(json['notes']) : null,
      bookmarks: json['bookmarks'] != null ? Map<String, dynamic>.from(json['bookmarks']) : null,
    );
  }
}