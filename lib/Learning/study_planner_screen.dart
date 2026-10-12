// lib/Screens/activity/study_planner_screen.dart
import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:isapp/Learning/components/activity_gateway.dart';
import 'package:isapp/Learning/controllers/scholon_curriculum_planner_adapter.dart';
import 'package:isapp/Learning/learning_profile.dart';
import 'package:isapp/Models/user.dart';
import 'package:isapp/Screens/authentication/controllers/authentication_controller.dart';
import 'package:isapp/Utils/library/new_courses.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:intl/intl.dart';
import 'package:iconsax/iconsax.dart';
import 'package:isapp/Utils/debouncer.dart';

// Activity types based on Scholon curriculum
enum ActivityType {
  dailyLesson,
  dailyQuiz,
  weeklyMockTest,
  monthlyExam,
  practiceSession,
  revisionSession,
  projectWork,
  readingSession,
  researchWork,
  problemSolving,
  experimentLab,
  groupDiscussion,
}

// Curriculum content types
enum CurriculumContentType {
  note,
  quiz,
  assignment,
  exam,
  activity,
  project,
  research,
  practice,
  lab,
}

// Data class for curriculum content item
class CurriculumContentItem {
  final CurriculumContentType type;
  final String id;
  final String title;
  final String description;
  final String courseCode;
  final Map<String, dynamic> metadata;
  final Duration estimatedDuration;

  CurriculumContentItem({
    required this.type,
    required this.id,
    required this.title,
    required this.description,
    required this.courseCode,
    required this.metadata,
    required this.estimatedDuration,
  });
}

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

// Study Schedule Model
class StudySchedule {
  final String studentId;
  final LearningProfile profile;
  final DateTime startDate;
  final DateTime endDate;
  final Map<DateTime, List<DailyActivity>> dailyActivities;
  final Map<String, double> subjectWeights;
  final int totalStudyDays;
  final int completedDays;
  final double overallProgress;

  StudySchedule({
    required this.studentId,
    required this.profile,
    required this.startDate,
    required this.endDate,
    required this.dailyActivities,
    required this.subjectWeights,
    this.totalStudyDays = 0,
    this.completedDays = 0,
    this.overallProgress = 0.0,
  });

  double get completionRate =>
      totalStudyDays > 0 ? completedDays / totalStudyDays : 0.0;

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'profile': profile.toString().split('.').last,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'subjectWeights': subjectWeights,
      'totalStudyDays': totalStudyDays,
      'completedDays': completedDays,
      'overallProgress': overallProgress,
    };
  }
}

// ==============================================
// ENHANCED ACTIVITY PLANNER WITH ADAPTER SUPPORT
// ==============================================

class ScholonActivityPlanner {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const Map<LearningProfile, Map<String, dynamic>> _profileConfigs = {
    LearningProfile.pacedLearner: {
      'dailyActivities': 6,
      'dailyLessons': 3,
      'dailyQuizzes': 1,
      'practiceSessions': 1,
      'weeklyProjects': 1,
      'dailyHours': 2.5,
      'topicsPerDay': 4,
    },
    LearningProfile.balancedStudent: {
      'dailyActivities': 8,
      'dailyLessons': 4,
      'dailyQuizzes': 2,
      'practiceSessions': 1,
      'weeklyProjects': 1,
      'dailyHours': 3.5,
      'topicsPerDay': 6,
    },
    LearningProfile.acceleratedLearner: {
      'dailyActivities': 10,
      'dailyLessons': 5,
      'dailyQuizzes': 2,
      'practiceSessions': 1,
      'weeklyProjects': 1,
      'researchWork': 1,
      'dailyHours': 5.0,
      'topicsPerDay': 8,
    },
  };

  // Load curriculum using adapter
  Future<AdaptedScholonCurriculum?> loadCurriculum() async {
    try {
      final curriculumJson = Courses.ss3Curriculum;
      if (curriculumJson == null || curriculumJson.trim().isEmpty) {
        print('❌ Curriculum JSON is null or empty');
        return null;
      }

      print('📝 Loading curriculum with adapter...');
      final parsed = jsonDecode(curriculumJson.trim());

      // Use the adapter class
      final adaptedCurriculum = ScholonCurriculumAdapter.adaptFromJson(parsed);

      print('✅ Curriculum loaded successfully via adapter');
      print('   Name: ${adaptedCurriculum.curriculum}');
      print('   Year: ${adaptedCurriculum.academicYear}');
      print('   Courses: ${adaptedCurriculum.courses.length}');
      print('   Total Weeks: ${adaptedCurriculum.schedule.totalWeeks}');

      return adaptedCurriculum;
    } catch (e) {
      print('❌ Error loading curriculum: $e');
      print('Stack trace: $e');
      return null;
    }
  }

  // Main method to extract all content from adapted curriculum
  Future<List<CurriculumContentItem>> _extractCurriculumContent(
    AdaptedScholonCurriculum curriculum,
    LearningProfile profile,
  ) async {
    final contentItems = <CurriculumContentItem>[];

    print('📚 Extracting content from ${curriculum.courses.length} courses');

    for (final course in curriculum.courses) {
      print('   📖 Processing ${course.name} (${course.courseCode})');

      for (final term in course.terms) {
        for (final week in term.weeks) {
          // 1. NOTES - Each note as separate activity
          for (final note in week.notes) {
            contentItems.add(
              CurriculumContentItem(
                type: CurriculumContentType.note,
                id: note.id,
                title: '${course.name}: ${note.title}',
                description: note.content.length > 100
                    ? note.content.substring(0, 100) + '...'
                    : note.content,
                courseCode: course.courseCode,
                metadata: {
                  'courseName': course.name,
                  'courseCode': course.courseCode,
                  'term': term.term,
                  'week': week.weekNumber,
                  'topic': week.topic,
                  'duration': note.duration,
                  'difficulty': note.difficulty,
                  'contentType': note.contentType,
                  'fullContent': note.content,
                  'keyConcepts': note.keyConcepts,
                  'references': note.references
                      .map((ref) => ref.toJson())
                      .toList(),
                },
                estimatedDuration: _parseDuration(note.duration),
              ),
            );
          }

          // 2. QUIZZES - Each quiz as separate activity
          for (final quiz in week.quizzes) {
            contentItems.add(
              CurriculumContentItem(
                type: CurriculumContentType.quiz,
                id: quiz.id,
                title: '${course.name}: ${quiz.title}',
                description: quiz.description,
                courseCode: course.courseCode,
                metadata: {
                  'courseName': course.name,
                  'courseCode': course.courseCode,
                  'term': term.term,
                  'week': week.weekNumber,
                  'topic': week.topic,
                  'questionsCount': quiz.questions.length,
                  'duration': quiz.duration,
                  'passingScore': quiz.passingScore,
                  'maxAttempts': quiz.maxAttempts,
                  'quizType': quiz.quizType,
                  'questions': quiz.questions.map((q) => q.toJson()).toList(),
                },
                estimatedDuration: Duration(minutes: quiz.duration),
              ),
            );
          }
        }
      }
    }

    print('✅ Extracted ${contentItems.length} content items');
    return contentItems;
  }

  Duration _parseDuration(String durationStr) {
    try {
      if (durationStr.toLowerCase().contains('min')) {
        final minutes =
            int.tryParse(durationStr.replaceAll(RegExp(r'[^0-9]'), '')) ?? 30;
        return Duration(minutes: minutes);
      }
    } catch (e) {
      print('Error parsing duration: $durationStr');
    }
    return Duration(minutes: 30); // Default
  }

  // Schedule generation that works with AdaptedScholonCurriculum
  Future<StudySchedule> createStudySchedule({
    required StudentUser student,
    required LearningProfile profile,
    required AdaptedScholonCurriculum curriculum,
  }) async {
    final config = _profileConfigs[profile]!;
    final startDate = DateTime.now();

    // Check if we have courses
    if (curriculum.courses.isEmpty) {
      print('⚠️ No courses found in curriculum! Creating demo schedule...');
      return _createDemoSchedule(
        student: student,
        profile: profile,
        startDate: startDate,
      );
    }

    // Calculate end date based on curriculum schedule
    final totalWeeks = curriculum.schedule.totalWeeks;
    if (totalWeeks == 0) {
      print('⚠️ No total weeks specified, using 12 weeks default');
      final endDate = startDate.add(Duration(days: 12 * 7));

      // Calculate subject weights
      final subjectWeights = _calculateSubjectWeights(curriculum);

      // Generate activities with fallback
      final dailyActivities = await _generateDailyActivitiesWithFallback(
        student: student,
        profile: profile,
        config: config,
        curriculum: curriculum,
        subjectWeights: subjectWeights,
        startDate: startDate,
        endDate: endDate,
      );

      return StudySchedule(
        studentId: student.uid,
        profile: profile,
        startDate: startDate,
        endDate: endDate,
        dailyActivities: dailyActivities,
        subjectWeights: subjectWeights,
        totalStudyDays: dailyActivities.length,
      );
    }

    final endDate = startDate.add(Duration(days: totalWeeks * 7));

    print('🎯 Creating schedule for ${student.name}');
    print('   Profile: $profile');
    print('   Start: $startDate, End: $endDate');
    print('   Total weeks: $totalWeeks');
    print('   Courses: ${curriculum.courses.length}');

    // Calculate subject weights
    final subjectWeights = _calculateSubjectWeights(curriculum);

    // Extract content from curriculum
    final allContentItems = await _extractCurriculumContent(
      curriculum,
      profile,
    );

    if (allContentItems.isEmpty) {
      print('⚠️ No content items extracted! Using fallback generation');
      final dailyActivities = await _generateFallbackActivities(
        student: student,
        profile: profile,
        config: config,
        curriculum: curriculum,
        startDate: startDate,
        endDate: endDate,
      );

      return StudySchedule(
        studentId: student.uid,
        profile: profile,
        startDate: startDate,
        endDate: endDate,
        dailyActivities: dailyActivities,
        subjectWeights: subjectWeights,
        totalStudyDays: dailyActivities.length,
      );
    }

    // Distribute content across the schedule
    final dailyActivities = await _distributeContentAcrossSchedule(
      allContentItems: allContentItems,
      profile: profile,
      config: config,
      subjectWeights: subjectWeights,
      startDate: startDate,
      endDate: endDate,
      curriculum: curriculum,
    );

    return StudySchedule(
      studentId: student.uid,
      profile: profile,
      startDate: startDate,
      endDate: endDate,
      dailyActivities: dailyActivities,
      subjectWeights: subjectWeights,
      totalStudyDays: dailyActivities.length,
    );
  }

  // Fallback activity generation for adapted curriculum
  Future<Map<DateTime, List<DailyActivity>>> _generateFallbackActivities({
    required StudentUser student,
    required LearningProfile profile,
    required Map<String, dynamic> config,
    required AdaptedScholonCurriculum curriculum,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final activities = <DateTime, List<DailyActivity>>{};

    DateTime currentDate = startDate;
    final skipWeekends = profile != LearningProfile.acceleratedLearner;

    // Use courses from adapted curriculum or create demo ones
    final courses = curriculum.courses.isNotEmpty
        ? curriculum.courses.take(3).toList()
        : [
            _createAdaptedDemoCourse('MAT', 'Mathematics'),
            _createAdaptedDemoCourse('PHY', 'Physics'),
            _createAdaptedDemoCourse('CHE', 'Chemistry'),
          ];

    while (currentDate.isBefore(endDate)) {
      if (skipWeekends &&
          (currentDate.weekday == DateTime.saturday ||
              currentDate.weekday == DateTime.sunday)) {
        currentDate = currentDate.add(Duration(days: 1));
        continue;
      }

      final dailyList = <DailyActivity>[];

      // Add activities for each course
      for (var course in courses) {
        // Add a lesson
        dailyList.add(
          DailyActivity(
            id: '${course.courseCode}_${currentDate.millisecondsSinceEpoch}_lesson',
            date: currentDate,
            title: '${course.name} Fundamentals',
            description: 'Basic concepts and principles of ${course.name}',
            type: ActivityType.dailyLesson,
            estimatedDuration: Duration(minutes: 45),
            courseCodes: [course.courseCode],
            metadata: {
              'courseName': course.name,
              'courseCode': course.courseCode,
              'isDemo': curriculum.courses.isEmpty,
            },
          ),
        );

        // Add a quiz
        dailyList.add(
          DailyActivity(
            id: '${course.courseCode}_${currentDate.millisecondsSinceEpoch}_quiz',
            date: currentDate,
            title: '${course.name} Practice Quiz',
            description: 'Test your understanding of ${course.name} concepts',
            type: ActivityType.dailyQuiz,
            estimatedDuration: Duration(minutes: 20),
            courseCodes: [course.courseCode],
            metadata: {
              'courseName': course.name,
              'courseCode': course.courseCode,
              'isDemo': curriculum.courses.isEmpty,
              'questions': 5,
            },
          ),
        );
      }

      activities[currentDate] = dailyList;
      currentDate = currentDate.add(Duration(days: 1));
    }

    return activities;
  }

  AdaptedCourse _createAdaptedDemoCourse(String courseCode, String name) {
    return AdaptedCourse(
      id: 'demo_$courseCode',
      courseCode: courseCode,
      name: name,
      description: 'Demo course for $name',
      strand: 'STEM',
      credits: 1.0,
      scholonLevel: 'Beginner',
      metadata: {},
      terms: _createDemoTerms(courseCode),
    );
  }

  List<AdaptedTerm> _createDemoTerms(String courseCode) {
    return [
      AdaptedTerm(
        id: 'demo_term_1',
        term: 'Term 1',
        duration: '12 weeks',
        focus: 'Fundamentals',
        objectives: AdaptedLearningObjectives(
          knowledgeObjectives: ['Understand basic concepts'],
          skillObjectives: ['Apply fundamental principles'],
          attitudeObjectives: ['Develop interest in subject'],
        ),
        weeks: _createDemoWeeks(courseCode),
      ),
    ];
  }

  List<AdaptedWeek> _createDemoWeeks(String courseCode) {
    return [
      AdaptedWeek(
        weekNumber: 1,
        topic: 'Introduction',
        overview: 'Basic concepts introduction',
        coreCompetencies: ['Understanding', 'Application'],
        scholonStandard: 'Beginner',
        notes: [
          AdaptedNote(
            id: 'demo_note_1',
            title: 'Introduction to $courseCode',
            content: 'This is a demo note for $courseCode',
            duration: '30 min',
            difficulty: 'Beginner',
            keyConcepts: ['Basic concepts'],
            learningTags: ['foundation'],
            contentType: 'theory',
            references: [],
          ),
        ],
        quizzes: [
          AdaptedQuiz(
            id: 'demo_quiz_1',
            title: 'Basic Concepts Quiz',
            description: 'Test your understanding of basic concepts',
            questions: [
              AdaptedQuestion(
                id: 'q1',
                question: 'What is the basic concept?',
                options: [
                  AdaptedQuestionOption(
                    id: 'A',
                    text: 'Option A',
                    isCorrect: true,
                  ),
                  AdaptedQuestionOption(
                    id: 'B',
                    text: 'Option B',
                    isCorrect: false,
                  ),
                ],
                correctAnswer: 0,
                explanation: 'Explanation here',
                scholonBloomLevel: 'Remember',
                points: 10,
                questionType: 'multiple_choice',
                tags: ['basic'],
              ),
            ],
            duration: 15,
            passingScore: 70,
            maxAttempts: 3,
            isTimed: true,
            quizType: 'formative',
          ),
        ],
        assignments: [],
        exams: AdaptedExamStructure(
          id: 'demo_exam',
          papers: [],
          metadata: AdaptedExamMetadata(
            totalPapers: 0,
            totalQuestions: 0,
            totalMarks: 0,
            examFormat: '',
            gradingPolicy: '',
          ),
        ),
        activities: [],
      ),
    ];
  }

  // Create demo schedule with adapted curriculum
  Future<StudySchedule> _createDemoSchedule({
    required StudentUser student,
    required LearningProfile profile,
    required DateTime startDate,
  }) async {
    final config = _profileConfigs[profile]!;
    final endDate = startDate.add(Duration(days: 12 * 7)); // 12 weeks

    final demoCourses = [
      _createAdaptedDemoCourse('MAT', 'Mathematics'),
      _createAdaptedDemoCourse('PHY', 'Physics'),
      _createAdaptedDemoCourse('CHE', 'Chemistry'),
      _createAdaptedDemoCourse('ENG', 'English'),
      _createAdaptedDemoCourse('BIO', 'Biology'),
    ];

    final demoCurriculum = AdaptedScholonCurriculum(
      curriculum: 'Demo Curriculum',
      academicYear: '2024',
      schoolLevel: 'SS3',
      courses: demoCourses,
      assessmentStructure: AdaptedAssessmentStructure(
        continuousAssessment: 40,
        termlyExaminations: 60,
        gradingScale: {},
        weightDistribution: {},
      ),
      learningOutcomes: AdaptedLearningOutcomes(
        cognitiveSkills: [],
        practicalSkills: [],
        softSkills: [],
        scholonCompetencies: [],
      ),
      resources: AdaptedScholonResources(
        textbooks: [],
        digitalResources: [],
        laboratoryEquipment: [],
        softwareTools: [],
      ),
      schedule: AdaptedSchedule(
        terms: [],
        totalWeeks: 12,
        totalHours: 0,
        contactHoursPerWeek: 0,
        startDate: startDate,
        endDate: endDate,
      ),
    );

    final dailyActivities = await _generateFallbackActivities(
      student: student,
      profile: profile,
      config: config,
      curriculum: demoCurriculum,
      startDate: startDate,
      endDate: endDate,
    );

    final subjectWeights = {
      'MAT': 0.2,
      'PHY': 0.2,
      'CHE': 0.2,
      'ENG': 0.2,
      'BIO': 0.2,
    };

    return StudySchedule(
      studentId: student.uid,
      profile: profile,
      startDate: startDate,
      endDate: endDate,
      dailyActivities: dailyActivities,
      subjectWeights: subjectWeights,
      totalStudyDays: dailyActivities.length,
    );
  }

  Future<Map<DateTime, List<DailyActivity>>>
  _generateDailyActivitiesWithFallback({
    required StudentUser student,
    required LearningProfile profile,
    required Map<String, dynamic> config,
    required AdaptedScholonCurriculum curriculum,
    required Map<String, double> subjectWeights,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Try to extract content first
      final allContentItems = await _extractCurriculumContent(
        curriculum,
        profile,
      );

      if (allContentItems.isNotEmpty) {
        return await _distributeContentAcrossSchedule(
          allContentItems: allContentItems,
          profile: profile,
          config: config,
          subjectWeights: subjectWeights,
          startDate: startDate,
          endDate: endDate,
          curriculum: curriculum,
        );
      }

      // Fallback to demo activities
      return await _generateFallbackActivities(
        student: student,
        profile: profile,
        config: config,
        curriculum: curriculum,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      print('Error in activity generation: $e');
      return await _generateFallbackActivities(
        student: student,
        profile: profile,
        config: config,
        curriculum: curriculum,
        startDate: startDate,
        endDate: endDate,
      );
    }
  }

  Future<Map<DateTime, List<DailyActivity>>> _distributeContentAcrossSchedule({
    required List<CurriculumContentItem> allContentItems,
    required LearningProfile profile,
    required Map<String, dynamic> config,
    required Map<String, double> subjectWeights,
    required DateTime startDate,
    required DateTime endDate,
    required AdaptedScholonCurriculum curriculum,
  }) async {
    final activities = <DateTime, List<DailyActivity>>{};

    // Group content by course
    final contentByCourse = <String, List<CurriculumContentItem>>{};
    for (var item in allContentItems) {
      contentByCourse.putIfAbsent(item.courseCode, () => []).add(item);
    }

    // Sort courses by weight
    final sortedCourseCodes = contentByCourse.keys.toList()
      ..sort(
        (a, b) => (subjectWeights[b] ?? 0).compareTo(subjectWeights[a] ?? 0),
      );

    DateTime currentDate = startDate;
    final skipWeekends = profile != LearningProfile.acceleratedLearner;

    // Track which content items have been scheduled
    final scheduledContentIds = <String>{};

    while (currentDate.isBefore(endDate)) {
      if (skipWeekends &&
          (currentDate.weekday == DateTime.saturday ||
              currentDate.weekday == DateTime.sunday)) {
        currentDate = currentDate.add(Duration(days: 1));
        continue;
      }

      final dailyList = <DailyActivity>[];

      // Calculate how many activities per day based on profile
      final targetDailyCount = config['dailyActivities'] as int;
      final activitiesPerSubject = (targetDailyCount / sortedCourseCodes.length)
          .ceil();

      print('\n📅 ${DateFormat('EEEE, MMMM d').format(currentDate)}');
      print(
        '   Target: $targetDailyCount activities, ~$activitiesPerSubject per subject',
      );

      for (var courseCode in sortedCourseCodes) {
        final courseContent = contentByCourse[courseCode] ?? [];
        final course = curriculum.courses.firstWhere(
          (c) => c.courseCode == courseCode,
        );

        // Get unscheduled content for this course
        final unscheduledContent = courseContent
            .where((item) => !scheduledContentIds.contains(item.id))
            .toList();

        if (unscheduledContent.isEmpty) {
          print('   📭 No more content for ${course.name}');
          continue;
        }

        print(
          '   📚 Scheduling ${course.name}: ${unscheduledContent.length} items remaining',
        );

        // Schedule a mix of content types
        final scheduledToday = <CurriculumContentItem>[];
        var scheduledCount = 0;

        // Try to schedule one of each type per day
        final contentTypes = [
          CurriculumContentType.note,
          CurriculumContentType.quiz,
        ];

        for (var contentType in contentTypes) {
          if (scheduledCount >= activitiesPerSubject) break;

          final contentOfType = unscheduledContent
              .where((item) => item.type == contentType)
              .toList();

          if (contentOfType.isNotEmpty) {
            final content = contentOfType.first;
            scheduledToday.add(content);
            scheduledContentIds.add(content.id);
            scheduledCount++;

            print('     ✅ ${content.type.name}: ${content.title}');
          }
        }

        // Convert to DailyActivities
        for (var content in scheduledToday) {
          final dailyActivity = _contentItemToDailyActivity(
            content: content,
            date: currentDate,
            profile: profile,
          );

          if (dailyActivity != null) {
            dailyList.add(dailyActivity);
          }
        }
      }

      // Add special activities based on day
      if (currentDate.weekday == DateTime.friday) {
        // Weekly review/project
        dailyList.add(
          _createSpecialActivity(
            type: ActivityType.projectWork,
            date: currentDate,
            profile: profile,
            title: 'Weekly Review & Integration',
            description:
                'Integrate learning from the week and prepare projects',
          ),
        );
      }

      if (currentDate.day >= 28) {
        // End of month review
        dailyList.add(
          _createSpecialActivity(
            type: ActivityType.monthlyExam,
            date: currentDate,
            profile: profile,
            title: 'Monthly Progress Assessment',
            description: 'Comprehensive review of monthly learning objectives',
          ),
        );
      }

      if (dailyList.isNotEmpty) {
        final dailyListSorted = dailyList.toList()
          ..sort(
            (a, b) => _getActivityPriority(
              a.type,
            ).compareTo(_getActivityPriority(b.type)),
          );
        activities[currentDate] = dailyListSorted;
        print('   📋 Scheduled ${dailyListSorted.length} activities');
      }

      currentDate = currentDate.add(Duration(days: 1));

      final dailyListSorted = dailyList
        ..sort(
          (a, b) => _getActivityPriority(
            a.type,
          ).compareTo(_getActivityPriority(b.type)),
        );
      activities[currentDate] = dailyListSorted;
    }

    print('\n🎉 Schedule complete!');
    print('   Total days: ${activities.length}');
    print(
      'Total activities: ${activities.values.fold(0, (sum, list) => sum + list.length)}',
    );
    print(
      'Scheduled content: ${scheduledContentIds.length}/${allContentItems.length}',
    );

    return activities;
  }

  DailyActivity? _contentItemToDailyActivity({
    required CurriculumContentItem content,
    required DateTime date,
    required LearningProfile profile,
  }) {
    // Map curriculum content type to activity type
    final activityType = switch (content.type) {
      CurriculumContentType.note => ActivityType.dailyLesson,
      CurriculumContentType.quiz => ActivityType.dailyQuiz,
      CurriculumContentType.assignment => ActivityType.projectWork,
      CurriculumContentType.exam => ActivityType.monthlyExam,
      CurriculumContentType.activity => ActivityType.practiceSession,
      CurriculumContentType.project => ActivityType.projectWork,
      CurriculumContentType.research => ActivityType.researchWork,
      CurriculumContentType.practice => ActivityType.practiceSession,
      CurriculumContentType.lab => ActivityType.experimentLab,
    };

    // Get appropriate duration
    final duration = content.estimatedDuration.inMinutes > 0
        ? content.estimatedDuration
        : Duration(minutes: _getDefaultDuration(activityType, profile));

    return DailyActivity(
      id: '${content.courseCode}_${content.id}_${date.millisecondsSinceEpoch}',
      date: date,
      title: content.title,
      description: content.description,
      type: activityType,
      estimatedDuration: duration,
      courseCodes: [content.courseCode],
      metadata: {
        ...content.metadata,
        'originalContentType': content.type.name,
        'originalContentId': content.id,
        'scheduledAt': date.toIso8601String(),
      },
    );
  }

  DailyActivity _createSpecialActivity({
    required ActivityType type,
    required DateTime date,
    required LearningProfile profile,
    required String title,
    required String description,
  }) {
    return DailyActivity(
      id: 'special_${type.name}_${date.millisecondsSinceEpoch}',
      date: date,
      title: title,
      description: description,
      type: type,
      estimatedDuration: Duration(
        minutes: _getSpecialActivityDuration(type, profile),
      ),
      courseCodes: [], // Comprehensive activity
      metadata: {'activityType': 'special', 'createdAt': DateTime.now()},
    );
  }

  Map<String, double> _calculateSubjectWeights(
    AdaptedScholonCurriculum curriculum,
  ) {
    final weights = <String, double>{};
    double totalCredits = 0;

    for (var course in curriculum.courses) {
      weights[course.courseCode] = course.credits;
      totalCredits += course.credits;
    }

    // If no credits or all credits are 0, use equal distribution
    if (totalCredits == 0) {
      final equalWeight = 1.0 / curriculum.courses.length;
      for (var course in curriculum.courses) {
        weights[course.courseCode] = equalWeight;
      }
      return weights;
    }

    for (var key in weights.keys) {
      weights[key] = weights[key]! / totalCredits;
    }

    return weights;
  }

  int _getDefaultDuration(ActivityType type, LearningProfile profile) {
    return switch (type) {
      ActivityType.dailyLesson => switch (profile) {
        LearningProfile.pacedLearner => 45,
        LearningProfile.balancedStudent => 60,
        LearningProfile.acceleratedLearner => 75,
      },
      ActivityType.dailyQuiz => switch (profile) {
        LearningProfile.pacedLearner => 20,
        LearningProfile.balancedStudent => 25,
        LearningProfile.acceleratedLearner => 30,
      },
      ActivityType.practiceSession => switch (profile) {
        LearningProfile.pacedLearner => 30,
        LearningProfile.balancedStudent => 40,
        LearningProfile.acceleratedLearner => 50,
      },
      ActivityType.projectWork => switch (profile) {
        LearningProfile.pacedLearner => 60,
        LearningProfile.balancedStudent => 90,
        LearningProfile.acceleratedLearner => 120,
      },
      _ => 45,
    };
  }

  int _getSpecialActivityDuration(ActivityType type, LearningProfile profile) {
    return switch (type) {
      ActivityType.monthlyExam => switch (profile) {
        LearningProfile.pacedLearner => 90,
        LearningProfile.balancedStudent => 120,
        LearningProfile.acceleratedLearner => 150,
      },
      ActivityType.projectWork => switch (profile) {
        LearningProfile.pacedLearner => 120,
        LearningProfile.balancedStudent => 150,
        LearningProfile.acceleratedLearner => 180,
      },
      _ => 60,
    };
  }

  int _getActivityPriority(ActivityType type) {
    return switch (type) {
      ActivityType.monthlyExam => 1,
      ActivityType.weeklyMockTest => 2,
      ActivityType.projectWork => 3,
      ActivityType.researchWork => 4,
      ActivityType.dailyQuiz => 5,
      ActivityType.dailyLesson => 6,
      ActivityType.practiceSession => 7,
      ActivityType.revisionSession => 8,
      ActivityType.readingSession => 9,
      ActivityType.groupDiscussion => 10,
      ActivityType.experimentLab => 11,
      ActivityType.problemSolving => 12,
    };
  }
}

// ==============================================
// ENHANCED FIREBASE SERVICE
// ==============================================

class StudyPlannerFirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _schedulesCollection = 'studentSchedules';
  static const String _activitiesCollection = 'dailyActivities';
  static const String _progressCollection = 'studentProgress';
  static const String _analyticsCollection = 'studentAnalytics';

  Future<void> saveSchedule({
    required String studentId,
    required StudySchedule schedule,
    required AdaptedScholonCurriculum curriculum,
  }) async {
    try {
      print('💾 Saving schedule to Firebase for student: $studentId');

      final batch = _firestore.batch();
      final scheduleRef = _firestore
          .collection(_schedulesCollection)
          .doc(studentId);

      batch.set(scheduleRef, {
        'studentId': studentId,
        'profile': schedule.profile.toString().split('.').last,
        'startDate': Timestamp.fromDate(schedule.startDate),
        'endDate': Timestamp.fromDate(schedule.endDate),
        'subjectWeights': schedule.subjectWeights,
        'totalStudyDays': schedule.totalStudyDays,
        'completedDays': schedule.completedDays,
        'overallProgress': schedule.overallProgress,
        'scholonCurriculum': true,
        'curriculumVersion': curriculum.academicYear,
        'curriculumName': curriculum.curriculum,
        'totalCourses': curriculum.courses.length,
        'totalWeeks': curriculum.schedule.totalWeeks,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'status': 'active',
      });

      int activityCount = 0;
      for (final entry in schedule.dailyActivities.entries) {
        final date = entry.key;
        final activities = entry.value;

        for (final activity in activities) {
          final activityRef = scheduleRef
              .collection(_activitiesCollection)
              .doc(activity.id);

          batch.set(activityRef, {
            'date': Timestamp.fromDate(date),
            'title': activity.title,
            'description': activity.description,
            'type': activity.type.name,
            'estimatedMinutes': activity.estimatedDuration.inMinutes,
            'courseCodes': activity.courseCodes,
            'progress': activity.progress,
            'isCompleted': false,
            'metadata': activity.metadata,
            'scholonEnhanced': true,
            'createdAt': FieldValue.serverTimestamp(),
            'status': 'scheduled',
            'priority': _calculateActivityPriority(activity.type),
            'requiresAttention':
                activity.type == ActivityType.monthlyExam ||
                activity.type == ActivityType.projectWork,
          });
          activityCount++;
        }
      }

      await batch.commit();
      print('✅ Schedule saved with $activityCount activities');

      await _initializeProgressTracking(studentId, activityCount);
    } catch (e, stackTrace) {
      print('❌ Error saving schedule: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  int _calculateActivityPriority(ActivityType type) {
    return switch (type) {
      ActivityType.monthlyExam => 1,
      ActivityType.weeklyMockTest => 2,
      ActivityType.projectWork => 3,
      ActivityType.researchWork => 4,
      ActivityType.dailyQuiz => 5,
      ActivityType.dailyLesson => 6,
      ActivityType.practiceSession => 7,
      ActivityType.revisionSession => 8,
      ActivityType.readingSession => 9,
      ActivityType.groupDiscussion => 10,
      ActivityType.experimentLab => 11,
      ActivityType.problemSolving => 12,
    };
  }

  Future<void> _initializeProgressTracking(
    String studentId,
    int totalActivities,
  ) async {
    try {
      await _firestore.collection(_progressCollection).doc(studentId).set({
        'studentId': studentId,
        'totalActivities': totalActivities,
        'completedActivities': 0,
        'averageScore': 0.0,
        'streak': 0,
        'weeklyHours': 0.0,
        'consistencyScore': 0.0,
        'subjectPerformance': {},
        'lastActivityDate': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _firestore.collection(_analyticsCollection).doc(studentId).set({
        'studentId': studentId,
        'totalStudyDays': 0,
        'totalStudyHours': 0.0,
        'learningEfficiency': 0.0,
        'focusTime': 0.0,
        'retentionRate': 0.0,
        'weeklyGoals': 0,
        'goalsAchieved': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error initializing progress tracking: $e');
    }
  }

  Future<StudySchedule?> loadSchedule(String studentId) async {
    try {
      final scheduleDoc = await _firestore
          .collection(_schedulesCollection)
          .doc(studentId)
          .get();

      if (!scheduleDoc.exists) {
        return null;
      }

      final data = scheduleDoc.data()!;
      final startDate = (data['startDate'] as Timestamp).toDate();
      final endDate = (data['endDate'] as Timestamp).toDate();

      // Load ALL activities for the entire schedule duration
      final activitiesSnapshot = await _firestore
          .collection(_schedulesCollection)
          .doc(studentId)
          .collection(_activitiesCollection)
          .orderBy('date')
          .get();

      final dailyActivities = <DateTime, List<DailyActivity>>{};

      for (var doc in activitiesSnapshot.docs) {
        final activity = DailyActivity.fromJson(doc.data());
        final dateKey = DateTime(
          activity.date.year,
          activity.date.month,
          activity.date.day,
        );
        dailyActivities.putIfAbsent(dateKey, () => []).add(activity);
      }

      return StudySchedule(
        studentId: studentId,
        profile: LearningProfile.values.firstWhere(
          (p) => p.toString().split('.').last == data['profile'],
          orElse: () => LearningProfile.balancedStudent,
        ),
        startDate: startDate,
        endDate: endDate,
        dailyActivities: dailyActivities,
        subjectWeights: Map<String, double>.from(data['subjectWeights'] ?? {}),
        totalStudyDays: (data['totalStudyDays'] as int?) ?? 0,
        completedDays: (data['completedDays'] as int?) ?? 0,
        overallProgress: (data['overallProgress'] as num?)?.toDouble() ?? 0.0,
      );
    } catch (e) {
      print('Error loading schedule: $e');
      return null;
    }
  }

  Future<List<DailyActivity>> loadTodayActivities(String studentId) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(Duration(days: 1));

      // First try to load from Firebase
      final snapshot = await _firestore
          .collection(_schedulesCollection)
          .doc(studentId)
          .collection(_activitiesCollection)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThan: Timestamp.fromDate(endOfDay))
          .orderBy('date')
          .get();

      final activities = snapshot.docs
          .map((doc) => DailyActivity.fromJson(doc.data()))
          .where(
            (activity) => activity.id.isNotEmpty && activity.title.isNotEmpty,
          )
          .toList();

      if (activities.isNotEmpty) {
        print('✅ Found ${activities.length} activities for today');
        return activities;
      }

      // If no activities for today, check if schedule exists and generate upcoming activities
      final scheduleDoc = await _firestore
          .collection(_schedulesCollection)
          .doc(studentId)
          .get();

      if (scheduleDoc.exists) {
        print(
          '📅 Schedule exists but no activities for today, showing next scheduled activity',
        );
        // Get the next upcoming activity
        final upcomingSnapshot = await _firestore
            .collection(_schedulesCollection)
            .doc(studentId)
            .collection(_activitiesCollection)
            .where(
              'date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
            )
            .orderBy('date')
            .limit(1)
            .get();

        if (upcomingSnapshot.docs.isNotEmpty) {
          final nextActivity = DailyActivity.fromJson(
            upcomingSnapshot.docs.first.data(),
          );
          print(
            '📌 Next activity: ${nextActivity.title} on ${DateFormat('MMM d').format(nextActivity.date)}',
          );

          // Create a "preview" activity for today
          return [
            DailyActivity(
              id: 'preview_${now.millisecondsSinceEpoch}',
              date: now,
              title: 'Preview: ${nextActivity.title}',
              description:
                  'Next scheduled activity: ${DateFormat('EEEE, MMM d').format(nextActivity.date)}\n\n${nextActivity.description}',
              type: ActivityType.dailyLesson,
              estimatedDuration: Duration(minutes: 30),
              courseCodes: nextActivity.courseCodes,
              metadata: {
                ...nextActivity.metadata,
                'isPreview': true,
                'actualDate': nextActivity.date.toIso8601String(),
                'actualActivityId': nextActivity.id,
              },
            ),
          ];
        }
      }

      print('📭 No activities found for today or upcoming');
      return [];
    } catch (e) {
      print('❌ Error loading today activities: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> loadProgressData(String studentId) async {
    try {
      final progressDoc = await _firestore
          .collection(_progressCollection)
          .doc(studentId)
          .get();

      final analyticsDoc = await _firestore
          .collection(_analyticsCollection)
          .doc(studentId)
          .get();

      return {...progressDoc.data() ?? {}, ...analyticsDoc.data() ?? {}};
    } catch (e) {
      print('Error loading progress data: $e');
      return {};
    }
  }

  Future<void> markActivityComplete({
    required String studentId,
    required String activityId,
    required double score,
  }) async {
    try {
      await _firestore
          .collection(_schedulesCollection)
          .doc(studentId)
          .collection(_activitiesCollection)
          .doc(activityId)
          .update({
            'isCompleted': true,
            'progress': 1.0,
            'completedAt': FieldValue.serverTimestamp(),
            'actualScore': score,
          });

      await _recordActivityCompletion(studentId, activityId, score);

      await _updateOverallProgress(studentId, score);
    } catch (e) {
      print('Error marking activity complete: $e');
      rethrow;
    }
  }

  Future<void> _recordActivityCompletion(
    String studentId,
    String activityId,
    double score,
  ) async {
    await _firestore
        .collection(_progressCollection)
        .doc(studentId)
        .collection('completedActivities')
        .doc(activityId)
        .set({
          'activityId': activityId,
          'score': score,
          'completedAt': FieldValue.serverTimestamp(),
        });
  }

  Future<void> _updateOverallProgress(String studentId, double score) async {
    await _firestore.runTransaction((transaction) async {
      final progressRef = _firestore
          .collection(_progressCollection)
          .doc(studentId);
      final doc = await transaction.get(progressRef);

      if (!doc.exists) return;

      final data = doc.data()!;
      final currentScore = (data['averageScore'] as num?)?.toDouble() ?? 0.0;
      final completedCount = (data['completedActivities'] as int?) ?? 0;
      final streak = (data['streak'] as int?) ?? 0;
      final lastActivityDate = (data['lastActivityDate'] as Timestamp?)
          ?.toDate();

      final newAverage = currentScore == 0
          ? score
          : (currentScore * completedCount + score) / (completedCount + 1);

      final newStreak = _calculateNewStreak(streak, lastActivityDate);

      transaction.update(progressRef, {
        'averageScore': newAverage,
        'completedActivities': completedCount + 1,
        'streak': newStreak,
        'lastActivityDate': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  int _calculateNewStreak(int currentStreak, DateTime? lastActivityDate) {
    if (lastActivityDate == null) return 1;

    final today = DateTime.now();
    final yesterday = today.subtract(Duration(days: 1));

    if (lastActivityDate.year == yesterday.year &&
        lastActivityDate.month == yesterday.month &&
        lastActivityDate.day == yesterday.day) {
      return currentStreak + 1;
    }

    if (lastActivityDate.year == today.year &&
        lastActivityDate.month == today.month &&
        lastActivityDate.day == today.day) {
      return currentStreak;
    }

    return 1;
  }
}

// ==============================================
// MAIN STUDY PLANNER SCREEN WITH ALL UPGRADES
// ==============================================

class StudyPlannerScreen extends StatefulWidget {
  const StudyPlannerScreen({Key? key}) : super(key: key);

  @override
  State<StudyPlannerScreen> createState() => _StudyPlannerScreenState();
}

class _StudyPlannerScreenState extends State<StudyPlannerScreen> {
  // USE NEW SERVICES
  final AuthService _authService = Get.find<AuthService>();
  final ScholonActivityPlanner _planner = ScholonActivityPlanner();
  final StudyPlannerFirebaseService _firebaseService =
      StudyPlannerFirebaseService();
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // Data
  AdaptedScholonCurriculum? _scholonCurriculum;
  StudentUser? _currentUser;
  LearningProfile _selectedProfile = LearningProfile.balancedStudent;
  StudySchedule? _currentSchedule;
  Map<DateTime, List<DailyActivity>> _weeklyActivities = {};
  List<DailyActivity> _todayActivities = [];
  Map<String, dynamic> _progressData = {};

  // UI State
  bool _isLoading = true;
  bool _isGeneratingSchedule = false;
  bool _hasError = false;
  String? _errorMessage;
  DateTime _selectedDate = DateTime.now();
  int _currentWeek = 1;
  int _retryCount = 0;

  // Performance optimizations
  final _debouncer = Debouncer(
    milliseconds: 500,
    delay: Duration(milliseconds: 500),
  );
  final _cache = <String, dynamic>{};
  DateTime? _lastCacheUpdate;
  late StreamSubscription? _authSubscription;

  // Profile options
  final List<Map<String, dynamic>> _profileOptions = [
    {
      'profile': LearningProfile.pacedLearner,
      'title': 'Paced Learner',
      'subtitle': 'Learn at your own comfortable pace',
      'description':
          'Perfect for those who prefer thorough understanding with extra practice time',
      'icon': Icons.timeline,
      'gradient': [Color(0xFF667EEA), Color(0xFF764BA2)],
      'iconBg': Color(0xFF667EEA),
      'time': '1.5 hours/day',
      'features': [
        'Extra practice sessions',
        'Frequent reviews',
        'Step-by-step guidance',
        'Flexible deadlines',
      ],
    },
    {
      'profile': LearningProfile.balancedStudent,
      'title': 'Balanced Student',
      'subtitle': 'Standard pace with optimal workload',
      'description':
          'Ideal for consistent learners who want balanced study sessions',
      'icon': Icons.balance,
      'gradient': [Color(0xFF11998E), Color(0xFF38EF7D)],
      'iconBg': Color(0xFF11998E),
      'time': '2.5 hours/day',
      'features': [
        'Balanced daily schedule',
        'Regular assessments',
        'Mixed learning methods',
        'Weekend breaks',
      ],
    },
    {
      'profile': LearningProfile.acceleratedLearner,
      'title': 'Accelerated Learner',
      'subtitle': 'Fast-paced with advanced challenges',
      'description': 'For ambitious learners who want to excel quickly',
      'icon': Icons.rocket_launch,
      'gradient': [Color(0xFFFF416C), Color(0xFFFF4B2B)],
      'iconBg': Color(0xFFFF416C),
      'time': '4 hours/day',
      'features': [
        'Advanced topics',
        'Weekly projects',
        'Weekend learning',
        'Real-world applications',
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeUserAndData();

    // Listen to auth state changes
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        // Handle logout
        _clearLocalData();
      }
    });

    // Track screen view
    _trackScreenView();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _debouncer.dispose();
    super.dispose();
  }

  // ==============================================
  // ENHANCED INITIALIZATION
  // ==============================================

  Future<void> _initializeUserAndData() async {
    _trackUserInteraction('initialization_started');

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      // Get current user
      final user = await _authService.getCurrentUser();
      if (user != null && user is StudentUser) {
        _currentUser = user;
        _trackUserInteraction('user_loaded', {'user_id': user.uid});

        // Load curriculum using adapter
        _scholonCurriculum = await _loadCurriculumWithAdapter();
        if (_scholonCurriculum == null) {
          _trackUserInteraction('curriculum_load_failed');
          print('⚠️ Failed to load curriculum, will use demo data');
        } else {
          _trackUserInteraction('curriculum_loaded', {
            'course_count': _scholonCurriculum!.courses.length,
            'curriculum': _scholonCurriculum!.curriculum,
          });
        }

        // Load today's activities with cache support
        await _loadTodayActivitiesWithCache();

        // Load progress data
        await _loadProgressData();

        // Check for existing schedule
        await _checkExistingSchedule(user.uid);
      } else {
        _trackUserInteraction('invalid_user_type');
        setState(() {
          _hasError = true;
          _errorMessage = 'Study planner is only available for students';
        });
      }
    } catch (e) {
      print('❌ Error initializing data: $e');
      _trackUserInteraction('initialization_error', {'error': e.toString()});

      setState(() {
        _hasError = true;
        _errorMessage = 'Failed to load data: ${e.toString()}';
        _todayActivities = [];
        _progressData = {
          'averageScore': 0.0,
          'completedActivities': 0,
          'streak': 0,
          'weeklyHours': 0.0,
        };
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<AdaptedScholonCurriculum?> _loadCurriculumWithAdapter() async {
    try {
      print('🔍 DEBUG: Starting curriculum load...');

      // 1. Check if we can access the Courses class
      try {
        print('   Courses class exists: ${Courses != null}');
        // print('   Courses class type: ${Courses.ss3Curriculum}');
      } catch (e) {
        print('   ❌ ERROR: Cannot access Courses class: $e');
        return null;
      }

      // 2. Get the curriculum JSON
      final curriculumJson = Courses.ss3Curriculum;
      print('   ss3Curriculum is null: ${curriculumJson == null}');

      if (curriculumJson == null) {
        print('   ❌ ERROR: Courses.ss3Curriculum is NULL');
        return null;
      }

      print('   ss3Curriculum length: ${curriculumJson.length} characters');
      print('   ss3Curriculum is empty: ${curriculumJson.trim().isEmpty}');

      if (curriculumJson.trim().isEmpty) {
        print('   ❌ ERROR: Courses.ss3Curriculum is EMPTY string');
        return null;
      }

      // 3. Print first 200 chars to see content
      final preview = curriculumJson.length > 200
          ? curriculumJson.substring(0, 200) + '...'
          : curriculumJson;
      print('   Preview: $preview');

      // 4. Try to parse JSON
      print('   Attempting JSON decode...');
      try {
        final parsed = jsonDecode(curriculumJson.trim());
        print('   ✅ JSON decode successful');
        print('   Parsed type: ${parsed.runtimeType}');

        if (parsed is List) {
          print('   It\'s a List with ${parsed.length} items');
          if (parsed.isNotEmpty) {
            print('   First item type: ${parsed[0].runtimeType}');
          }
        } else if (parsed is Map) {
          print('   It\'s a Map with keys: ${parsed.keys}');
        }
      } catch (e) {
        print('   ❌ JSON decode failed: $e');
        print('   This might be invalid JSON in new_courses.dart');
        return null;
      }

      // 5. Use the adapter
      print('📝 Loading curriculum with adapter...');
      final parsed = jsonDecode(curriculumJson.trim());
      final adaptedCurriculum = ScholonCurriculumAdapter.adaptFromJson(parsed);

      print('✅ Curriculum loaded successfully via adapter');
      print('   Name: ${adaptedCurriculum.curriculum}');
      print('   Year: ${adaptedCurriculum.academicYear}');
      print('   Courses: ${adaptedCurriculum.courses.length}');
      print('   Total Weeks: ${adaptedCurriculum.schedule.totalWeeks}');

      return adaptedCurriculum;
    } catch (e, stackTrace) {
      print('❌ Error loading curriculum: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  // ==============================================
  // ENHANCED ACTIVITY LOADING
  // ==============================================

  Future<void> _loadTodayActivitiesWithCache() async {
    if (_currentUser == null) return;

    final cacheKey =
        'today_activities_${_currentUser!.uid}_${DateTime.now().day}';
    final now = DateTime.now();

    // Check cache (valid for 30 minutes)
    if (_cache.containsKey(cacheKey) &&
        _lastCacheUpdate != null &&
        now.difference(_lastCacheUpdate!) < Duration(minutes: 30)) {
      final cached = _cache[cacheKey] as List<DailyActivity>;
      setState(() => _todayActivities = cached);
      print('📦 Using cached activities');
      return;
    }

    // Use debouncer to prevent rapid successive calls
    _debouncer.run(() async {
      try {
        final activities = await _firebaseService.loadTodayActivities(
          _currentUser!.uid,
        );

        // Enrich with curriculum data
        final enrichedActivities = await _enrichActivitiesWithCurriculum(
          activities,
        );

        // Cache the results
        _cache[cacheKey] = enrichedActivities;
        _lastCacheUpdate = now;

        if (mounted) {
          setState(() {
            _todayActivities = enrichedActivities;
          });
        }

        _trackUserInteraction('activities_loaded', {
          'count': enrichedActivities.length,
          'source': 'firebase',
        });
      } catch (e) {
        print('❌ Error loading today activities: $e');
        _trackUserInteraction('activities_load_error', {'error': e.toString()});

        // Fallback to curriculum-based activities
        final curriculumActivities = _generateActivitiesFromCurriculum();
        if (curriculumActivities.isNotEmpty) {
          setState(() {
            _todayActivities = curriculumActivities;
          });
          print('📚 Using curriculum-based activities as fallback');
        }
      }
    });
  }

  Future<List<DailyActivity>> _enrichActivitiesWithCurriculum(
    List<DailyActivity> activities,
  ) async {
    if (_scholonCurriculum == null) return activities;

    return activities.map((activity) {
      if (activity.courseCodes.isNotEmpty) {
        final courseCode = activity.courseCodes.first;
        try {
          final course = _scholonCurriculum!.courses.firstWhere(
            (c) => c.courseCode == courseCode,
          );

          // Find matching content in curriculum
          final curriculumContent = _findCurriculumContent(
            courseCode: courseCode,
            contentId: activity.metadata['originalContentId'] as String?,
            contentType: activity.metadata['originalContentType'] as String?,
          );

          final enrichedMetadata = {
            ...activity.metadata,
            'courseName': course.name,
            'scholonLevel': course.scholonLevel,
            'credits': course.credits,
            'strand': course.strand,
            if (curriculumContent != null) ...curriculumContent,
          };

          return activity.copyWith(metadata: enrichedMetadata);
        } catch (e) {
          print('Course $courseCode not found in curriculum: $e');
          return activity;
        }
      }
      return activity;
    }).toList();
  }

  Map<String, dynamic>? _findCurriculumContent({
    required String courseCode,
    String? contentId,
    String? contentType,
  }) {
    try {
      final course = _scholonCurriculum!.courses.firstWhere(
        (c) => c.courseCode == courseCode,
      );

      for (final term in course.terms) {
        for (final week in term.weeks) {
          // Search in notes
          if (contentType == 'note' && contentId != null) {
            final note = week.notes.firstWhere(
              (n) => n.id == contentId,
              orElse: () => week.notes.first,
            );

            return {
              'detailedContent': note.content,
              'keyConcepts': note.keyConcepts,
              'difficulty': note.difficulty,
              'references': note.references.map((ref) => ref.toJson()).toList(),
            };
          }

          // Search in quizzes
          if (contentType == 'quiz' && contentId != null) {
            final quiz = week.quizzes.firstWhere(
              (q) => q.id == contentId,
              orElse: () => week.quizzes.first,
            );

            return {
              'questionsCount': quiz.questions.length,
              'passingScore': quiz.passingScore,
              'maxAttempts': quiz.maxAttempts,
            };
          }
        }
      }
    } catch (e) {
      print('Error finding curriculum content: $e');
    }

    return null;
  }

  List<DailyActivity> _generateActivitiesFromCurriculum() {
    if (_scholonCurriculum == null) {
      return _getMockActivitiesForToday();
    }

    final activities = <DailyActivity>[];
    final now = DateTime.now();

    // Generate activities from first few courses
    final courses = _scholonCurriculum!.courses.take(2).toList();

    for (final course in courses) {
      for (final term in course.terms.take(1)) {
        for (final week in term.weeks.take(1)) {
          if (week.notes.isNotEmpty) {
            final note = week.notes.first;
            activities.add(
              DailyActivity(
                id: '${course.courseCode}_${note.id}_${now.millisecondsSinceEpoch}',
                date: now,
                title: '${course.name}: ${note.title}',
                description: note.content.length > 100
                    ? note.content.substring(0, 100) + '...'
                    : note.content,
                type: ActivityType.dailyLesson,
                estimatedDuration: _parseDuration(note.duration),
                courseCodes: [course.courseCode],
                metadata: {
                  'courseName': course.name,
                  'courseCode': course.courseCode,
                  'originalContentType': 'note',
                  'originalContentId': note.id,
                  'difficulty': note.difficulty,
                  'contentType': note.contentType,
                  'keyConcepts': note.keyConcepts,
                },
              ),
            );
          }

          if (week.quizzes.isNotEmpty) {
            final quiz = week.quizzes.first;
            activities.add(
              DailyActivity(
                id: '${course.courseCode}_${quiz.id}_${now.millisecondsSinceEpoch}',
                date: now,
                title: '${course.name}: ${quiz.title}',
                description: quiz.description,
                type: ActivityType.dailyQuiz,
                estimatedDuration: Duration(minutes: quiz.duration),
                courseCodes: [course.courseCode],
                metadata: {
                  'courseName': course.name,
                  'courseCode': course.courseCode,
                  'originalContentType': 'quiz',
                  'originalContentId': quiz.id,
                  'questionsCount': quiz.questions.length,
                  'passingScore': quiz.passingScore,
                },
              ),
            );
          }
        }
      }
    }

    return activities.isNotEmpty ? activities : _getMockActivitiesForToday();
  }

  Duration _parseDuration(String durationStr) {
    try {
      if (durationStr.toLowerCase().contains('min')) {
        final minutes =
            int.tryParse(durationStr.replaceAll(RegExp(r'[^0-9]'), '')) ?? 30;
        return Duration(minutes: minutes);
      }
      if (durationStr.toLowerCase().contains('hour')) {
        final hours =
            int.tryParse(durationStr.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
        return Duration(hours: hours);
      }
    } catch (e) {
      print('Error parsing duration: $durationStr');
    }
    return Duration(minutes: 30);
  }

  // ==============================================
  // ENHANCED SCHEDULE GENERATION
  // ==============================================

  // Update the _generateSchedule method to check for existing schedule
  Future<void> _generateSchedule() async {
    // Prevent multiple simultaneous generations
    if (_isGeneratingSchedule) return;

    // Check if schedule already exists
    if (_currentSchedule != null) {
      Get.dialog(
        AlertDialog(
          title: Text('Schedule Already Exists'),
          content: Text(
            'You already have an active study schedule. '
            'Would you like to create a new one? This will override your current schedule.',
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
            TextButton(
              onPressed: () {
                Get.back();
                _generateNewScheduleWithConfirmation();
              },
              child: Text('Create New', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
      return;
    }

    await _generateNewSchedule();
  }

  Future<void> _generateNewSchedule() async {
    if (_currentUser == null) {
      Get.snackbar('Oops!', 'Please sign in first');
      return;
    }

    _trackUserInteraction('schedule_generation_started', {
      'profile': _selectedProfile.toString(),
      'has_curriculum': _scholonCurriculum != null,
    });

    setState(() => _isGeneratingSchedule = true);

    // Use a variable to track dialog state
    bool isDialogOpen = true;

    // Show dialog
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false, // Prevent closing by back button
        child: _buildGeneratingDialog(),
      ),
      barrierDismissible: false,
    );

    try {
      print('🎯 Generating comprehensive schedule...');

      // Create adapted fallback curriculum if needed
      final curriculum =
          _scholonCurriculum ?? await _createAdaptedFallbackCurriculum();

      // Generate schedule using adapter
      final schedule = await _planner.createStudySchedule(
        student: _currentUser!,
        profile: _selectedProfile,
        curriculum: curriculum,
      );

      // Save to Firebase
      await _firebaseService.saveSchedule(
        studentId: _currentUser!.uid,
        schedule: schedule,
        curriculum: curriculum,
      );

      // Update local state
      setState(() {
        _currentSchedule = schedule;
      });

      // Generate weekly view
      _generateWeeklyView();

      // Load today's activities
      await _loadTodayActivitiesWithCache();

      _trackUserInteraction('schedule_generation_success', {
        'activity_count': schedule.dailyActivities.values.fold(
          0,
          (sum, list) => sum + list.length,
        ),
      });

      // Close dialog first
      if (isDialogOpen) {
        isDialogOpen = false;
        Navigator.of(Get.context!, rootNavigator: true).pop();
      }

      // Show success animation
      _showSuccessAnimation();

      // Show success message
      Get.snackbar(
        '🎉 Schedule Created Successfully!',
        'Your study plan is ready!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
        icon: Icon(Icons.check_circle, color: Colors.white),
        shouldIconPulse: true,
      );
    } catch (e) {
      print('❌ Schedule generation error: $e');
      _trackUserInteraction('schedule_generation_failed', {
        'error': e.toString(),
        'retry_count': _retryCount,
      });

      // Close dialog on error
      if (isDialogOpen) {
        isDialogOpen = false;
        Navigator.of(Get.context!, rootNavigator: true).pop();
      }

      Get.snackbar(
        'Schedule Creation Failed',
        'Please try again or contact support',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      // Always reset state
      setState(() => _isGeneratingSchedule = false);

      // Ensure dialog is closed
      if (isDialogOpen && Get.context != null) {
        isDialogOpen = false;
        Navigator.of(Get.context!, rootNavigator: true).pop();
      }
    }
  }

  Future<void> _generateNewScheduleWithConfirmation() async {
    if (_currentUser == null) return;

    _trackUserInteraction('schedule_regeneration_started');

    setState(() => _isGeneratingSchedule = true);

    // Use a variable to track dialog state
    bool isDialogOpen = true;

    // Show dialog
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: _buildGeneratingDialog(),
      ),
      barrierDismissible: false,
    );

    try {
      // Delete existing schedule first
      await _deleteExistingSchedule(_currentUser!.uid);

      // Create adapted fallback curriculum if needed
      final curriculum =
          _scholonCurriculum ?? await _createAdaptedFallbackCurriculum();

      // Generate schedule using adapter
      final schedule = await _planner.createStudySchedule(
        student: _currentUser!,
        profile: _selectedProfile,
        curriculum: curriculum,
      );

      // Save to Firebase
      await _firebaseService.saveSchedule(
        studentId: _currentUser!.uid,
        schedule: schedule,
        curriculum: curriculum,
      );

      // Update local state
      setState(() {
        _currentSchedule = schedule;
      });

      // Generate weekly view
      _generateWeeklyView();

      // Load today's activities
      await _loadTodayActivitiesWithCache();

      _trackUserInteraction('schedule_regeneration_success');

      // Close dialog first
      if (isDialogOpen) {
        isDialogOpen = false;
        Navigator.of(Get.context!, rootNavigator: true).pop();
      }

      Get.snackbar(
        '🎉 Schedule Updated!',
        'Your study plan has been regenerated',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    } catch (e) {
      print('❌ Schedule regeneration error: $e');

      // Close dialog on error
      if (isDialogOpen) {
        isDialogOpen = false;
        Navigator.of(Get.context!, rootNavigator: true).pop();
      }

      Get.snackbar(
        'Update Failed',
        'Could not regenerate schedule',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      // Always reset state
      setState(() => _isGeneratingSchedule = false);

      // Ensure dialog is closed
      if (isDialogOpen && Get.context != null) {
        isDialogOpen = false;
        Navigator.of(Get.context!, rootNavigator: true).pop();
      }
    }
  }

  Future<void> _deleteExistingSchedule(String studentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('studentSchedules')
          .doc(studentId)
          .delete();
      print('🗑️ Deleted existing schedule');
    } catch (e) {
      print('Error deleting schedule: $e');
    }
  }

  Future<AdaptedScholonCurriculum> _createAdaptedFallbackCurriculum() async {
    print('🔄 Creating fallback adapted curriculum');

    return AdaptedScholonCurriculum(
      curriculum: 'Demo Curriculum',
      academicYear: '2024',
      schoolLevel: 'SS3',
      courses: [
        AdaptedCourse(
          id: 'demo_math',
          courseCode: 'MAT',
          name: 'Mathematics',
          description: 'Demo mathematics course',
          strand: 'STEM',
          credits: 1.0,
          scholonLevel: 'Beginner',
          metadata: {},
          terms: _createDemoTerms('MAT'),
        ),
        AdaptedCourse(
          id: 'demo_phy',
          courseCode: 'PHY',
          name: 'Physics',
          description: 'Demo physics course',
          strand: 'STEM',
          credits: 1.0,
          scholonLevel: 'Beginner',
          metadata: {},
          terms: _createDemoTerms('PHY'),
        ),
      ],
      assessmentStructure: AdaptedAssessmentStructure(
        continuousAssessment: 40,
        termlyExaminations: 60,
        gradingScale: {},
        weightDistribution: {},
      ),
      learningOutcomes: AdaptedLearningOutcomes(
        cognitiveSkills: [],
        practicalSkills: [],
        softSkills: [],
        scholonCompetencies: [],
      ),
      resources: AdaptedScholonResources(
        textbooks: [],
        digitalResources: [],
        laboratoryEquipment: [],
        softwareTools: [],
      ),
      schedule: AdaptedSchedule(
        terms: [],
        totalWeeks: 12,
        totalHours: 0,
        contactHoursPerWeek: 0,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(Duration(days: 12 * 7)),
      ),
    );
  }

  List<AdaptedTerm> _createDemoTerms(String courseCode) {
    return [
      AdaptedTerm(
        id: 'demo_term_1',
        term: 'Term 1',
        duration: '12 weeks',
        focus: 'Fundamentals',
        objectives: AdaptedLearningObjectives(
          knowledgeObjectives: ['Understand basic concepts'],
          skillObjectives: ['Apply fundamental principles'],
          attitudeObjectives: ['Develop interest in subject'],
        ),
        weeks: _createDemoWeeks(courseCode),
      ),
    ];
  }

  List<AdaptedWeek> _createDemoWeeks(String courseCode) {
    return [
      AdaptedWeek(
        weekNumber: 1,
        topic: 'Introduction',
        overview: 'Basic concepts introduction',
        coreCompetencies: ['Understanding', 'Application'],
        scholonStandard: 'Beginner',
        notes: [
          AdaptedNote(
            id: 'demo_note_1',
            title: 'Introduction to $courseCode',
            content: 'This is a demo note for $courseCode',
            duration: '30 min',
            difficulty: 'Beginner',
            keyConcepts: ['Basic concepts'],
            learningTags: ['foundation'],
            contentType: 'theory',
            references: [],
          ),
        ],
        quizzes: [
          AdaptedQuiz(
            id: 'demo_quiz_1',
            title: 'Basic Concepts Quiz',
            description: 'Test your understanding of basic concepts',
            questions: [
              AdaptedQuestion(
                id: 'q1',
                question: 'What is the basic concept?',
                options: [
                  AdaptedQuestionOption(
                    id: 'A',
                    text: 'Option A',
                    isCorrect: true,
                  ),
                  AdaptedQuestionOption(
                    id: 'B',
                    text: 'Option B',
                    isCorrect: false,
                  ),
                ],
                correctAnswer: 0,
                explanation: 'Explanation here',
                scholonBloomLevel: 'Remember',
                points: 10,
                questionType: 'multiple_choice',
                tags: ['basic'],
              ),
            ],
            duration: 15,
            passingScore: 70,
            maxAttempts: 3,
            isTimed: true,
            quizType: 'formative',
          ),
        ],
        assignments: [],
        exams: AdaptedExamStructure(
          id: 'demo_exam',
          papers: [],
          metadata: AdaptedExamMetadata(
            totalPapers: 0,
            totalQuestions: 0,
            totalMarks: 0,
            examFormat: '',
            gradingPolicy: '',
          ),
        ),
        activities: [],
      ),
    ];
  }

  // ==============================================
  // ANALYTICS AND TRACKING
  // ==============================================

  void _trackScreenView() {
    _analytics.logEvent(
      name: 'study_planner_screen_view',
      parameters: {'timestamp': DateTime.now().toIso8601String()},
    );
  }

  void _trackUserInteraction(String event, [Map<String, dynamic>? params]) {
    final eventData = {
      'timestamp': DateTime.now().toIso8601String(),
      'user_id': _currentUser?.uid ?? 'unknown',
      'profile': _selectedProfile.toString().split('.').last,
      'has_schedule': _currentSchedule != null ? 1 : 0,
      ...?params,
    };

    _analytics.logEvent(name: 'study_planner_$event', parameters: eventData);

    print('📊 Analytics: $event - $eventData');
  }

  // ==============================================
  // ERROR HANDLING AND RETRY
  // ==============================================

  Widget _buildErrorScreen() {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFF),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 20),
              Text(
                'Something went wrong',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 10),
              Text(
                _errorMessage ?? 'Unable to load study planner',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _retryCount < 3 ? _retryInitialization : null,
                icon: Icon(Icons.refresh),
                label: Text('Try Again (${_retryCount + 1}/3)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
              if (_retryCount >= 3)
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Column(
                    children: [
                      Text(
                        'Too many attempts',
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          // Reset retry count after some time
                          Future.delayed(Duration(minutes: 5), () {
                            setState(() {
                              _retryCount = 0;
                            });
                          });
                        },
                        child: Text('Try again in 5 minutes'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _retryInitialization() async {
    setState(() {
      _retryCount++;
      _isLoading = true;
      _hasError = false;
    });

    await _initializeUserAndData();

    _trackUserInteraction('retry_initialization', {'retry_count': _retryCount});
  }

  // ==============================================
  // CLEANUP AND MEMORY MANAGEMENT
  // ==============================================

  void _clearLocalData() {
    print('🧹 Clearing local study planner data');

    setState(() {
      _currentUser = null;
      _currentSchedule = null;
      _weeklyActivities.clear();
      _todayActivities.clear();
      _cache.clear();
      _scholonCurriculum = null;
    });

    _trackUserInteraction('local_data_cleared');
  }

  // ==============================================
  // PULL TO REFRESH
  // ==============================================

  Future<void> _refreshData() async {
    _trackUserInteraction('pull_to_refresh');

    try {
      // Clear cache to force fresh load
      _cache.clear();

      // Reload data
      await Future.wait([_loadTodayActivitiesWithCache(), _loadProgressData()]);

      Get.snackbar(
        'Refreshed',
        'Study planner data updated',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 2),
      );

      _trackUserInteraction('refresh_success');
    } catch (e) {
      print('❌ Refresh failed: $e');
      _trackUserInteraction('refresh_failed', {'error': e.toString()});

      Get.snackbar(
        'Refresh Failed',
        'Could not update data',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ==============================================
  // EXISTING UI METHODS (Updated for Adapted Curriculum)
  // ==============================================

  Future<void> _checkExistingSchedule(String userId) async {
    try {
      final existingSchedule = await _firebaseService.loadSchedule(userId);

      if (existingSchedule != null) {
        setState(() {
          _currentSchedule = existingSchedule;
        });

        _debugScheduleData();
        _debugScheduleStructure();

        // Generate weekly view with activities
        _generateWeeklyView();

        // Load activities for today
        final todayActivities = await _firebaseService.loadTodayActivities(
          userId,
        );
        if (mounted) {
          setState(() {
            _todayActivities = todayActivities;
          });
        }

        print(
          '📋 Loaded existing schedule with ${existingSchedule.dailyActivities.length} days and ${existingSchedule.dailyActivities.values.fold(0, (sum, list) => sum + list.length)} total activities',
        );

        // Debug: Print first few activities
        final allActivities = existingSchedule.dailyActivities.values
            .expand((x) => x)
            .toList();
        if (allActivities.isNotEmpty) {
          print(
            '📅 First activity: ${allActivities.first.title} on ${DateFormat('MMM d, yyyy').format(allActivities.first.date)}',
          );
        }
      } else {
        print('📭 No existing schedule found');
      }
    } catch (e) {
      print('Error checking schedule: $e');
    }
  }

  Widget _buildGeneratingDialog() {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 300,
        padding: EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 3,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _profileOptions.firstWhere(
                        (opt) => opt['profile'] == _selectedProfile,
                        orElse: () => _profileOptions[1],
                      )['gradient'],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: _profileOptions
                            .firstWhere(
                              (opt) => opt['profile'] == _selectedProfile,
                              orElse: () => _profileOptions[1],
                            )['gradient'][0]
                            .withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.auto_awesome,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                )
                .animate(onPlay: (controller) => controller.repeat())
                .shimmer(duration: 1000.ms),

            SizedBox(height: 25),

            Text(
              'Creating Your Study Plan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 10),

            Text(
              'Personalizing your ${_getProfileTitle()} schedule...',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 25),

            LinearProgressIndicator(
              backgroundColor: Colors.grey[200],
              color: _profileOptions.firstWhere(
                (opt) => opt['profile'] == _selectedProfile,
                orElse: () => _profileOptions[1],
              )['gradient'][0],
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessAnimation() {
    Get.snackbar(
      '🎉 Plan Created Successfully!',
      'Your study plan is ready!',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      margin: EdgeInsets.all(20),
      borderRadius: 15,
      duration: Duration(seconds: 3),
      icon: Icon(Icons.check_circle, color: Colors.white),
      shouldIconPulse: true,
    );
  }

  void _generateWeeklyView() {
    final now = DateTime.now();
    final startOfWeek = DateTime(
      now.year,
      now.month,
      now.day - now.weekday + 1,
    ); // Monday of current week

    print(
      '📅 Generating weekly view for week starting ${DateFormat('MMM d').format(startOfWeek)}',
    );

    _weeklyActivities = {};

    if (_currentSchedule != null &&
        _currentSchedule!.dailyActivities.isNotEmpty) {
      print(
        '📊 Schedule has ${_currentSchedule!.dailyActivities.length} days with activities',
      );

      // Debug: Print all dates in the schedule
      print('📋 All schedule dates:');
      _currentSchedule!.dailyActivities.keys.take(5).forEach((date) {
        final activities = _currentSchedule!.dailyActivities[date] ?? [];
        print(
          '   ${DateFormat('EEE, MMM d, yyyy').format(date)}: ${activities.length} activities',
        );
      });

      // Generate the week view (Monday to Sunday)
      for (int i = 0; i < 7; i++) {
        final date = startOfWeek.add(Duration(days: i));
        final dateKey = DateTime(
          date.year,
          date.month,
          date.day,
        ); // Normalize time to 00:00

        print(
          '\n🔍 Looking for activities on ${DateFormat('EEE, MMM d, yyyy').format(dateKey)}',
        );

        // Try to find activities for this exact date
        var foundActivities = <DailyActivity>[];

        // Check all schedule entries for this date
        for (final entry in _currentSchedule!.dailyActivities.entries) {
          final entryDate = DateTime(
            entry.key.year,
            entry.key.month,
            entry.key.day,
          );

          if (entryDate == dateKey) {
            foundActivities.addAll(entry.value);
            print('   ✅ Found ${entry.value.length} activities');
            break;
          }
        }

        if (foundActivities.isEmpty) {
          // Check if any activity's date matches (some might be stored differently)
          final allActivities = _currentSchedule!.dailyActivities.values
              .expand((x) => x)
              .toList();
          for (final activity in allActivities) {
            final activityDate = DateTime(
              activity.date.year,
              activity.date.month,
              activity.date.day,
            );

            if (activityDate == dateKey) {
              foundActivities.add(activity);
              print('   ✅ Found activity via date check: ${activity.title}');
            }
          }
        }

        _weeklyActivities[date] = foundActivities;
      }

      // Debug summary
      final totalWeeklyActivities = _weeklyActivities.values.fold(
        0,
        (sum, list) => sum + list.length,
      );
      print(
        '\n📈 Weekly view generated: $totalWeeklyActivities activities across ${_weeklyActivities.values.where((list) => list.isNotEmpty).length} days',
      );

      // Print daily summary
      print('📋 Weekly breakdown:');
      for (int i = 0; i < 7; i++) {
        final date = startOfWeek.add(Duration(days: i));
        final activities = _weeklyActivities[date] ?? [];
        print(
          '   ${DateFormat('EEE').format(date)} (${DateFormat('MMM d').format(date)}): ${activities.length} activities',
        );
        if (activities.isNotEmpty) {
          for (final activity in activities.take(2)) {
            print(
              '     • ${activity.title} (${activity.estimatedDuration.inMinutes} min)',
            );
          }
        }
      }
    } else {
      print('⚠️ No schedule data for weekly view');
      // Generate empty week
      for (int i = 0; i < 7; i++) {
        final date = startOfWeek.add(Duration(days: i));
        _weeklyActivities[date] = [];
      }
    }

    setState(() {});
  }

  void _debugScheduleData() {
    if (_currentSchedule != null) {
      print('🔍 DEBUG: Schedule Details');
      print('   Start Date: ${_currentSchedule!.startDate}');
      print('   End Date: ${_currentSchedule!.endDate}');
      print('   Total Days: ${_currentSchedule!.dailyActivities.length}');

      final allActivities = _currentSchedule!.dailyActivities.values
          .expand((x) => x)
          .toList();
      print('   Total Activities: ${allActivities.length}');

      if (allActivities.isNotEmpty) {
        // Sort by date
        allActivities.sort((a, b) => a.date.compareTo(b.date));

        print('   First 5 activities:');
        for (int i = 0; i < min(5, allActivities.length); i++) {
          final activity = allActivities[i];
          print(
            '     ${i + 1}. ${DateFormat('MMM d').format(activity.date)}: ${activity.title}',
          );
        }

        // Check for today's activities
        final today = DateTime.now();
        final todayActivities = allActivities
            .where(
              (a) =>
                  a.date.year == today.year &&
                  a.date.month == today.month &&
                  a.date.day == today.day,
            )
            .toList();

        print('   Today\'s activities: ${todayActivities.length}');
      }
    } else {
      print('🔍 DEBUG: No schedule loaded');
    }
  }

  Future<void> _loadProgressData() async {
    if (_currentUser == null) return;

    try {
      final progressData = await _firebaseService.loadProgressData(
        _currentUser!.uid,
      );
      setState(() {
        _progressData = progressData;
      });
    } catch (e) {
      print('Error loading progress data: $e');
    }
  }

  // MARK ACTIVITY COMPLETE
  Future<void> _markActivityComplete(DailyActivity activity) async {
    if (_currentUser == null) return;

    try {
      // Calculate score
      final score = await _calculateActivityScore(activity);

      // Mark as complete in Firebase
      await _firebaseService.markActivityComplete(
        studentId: _currentUser!.uid,
        activityId: activity.id,
        score: score,
      );

      // Update local state
      setState(() {
        _todayActivities = _todayActivities.map((a) {
          if (a.id == activity.id) {
            return a.copyWith(
              isCompleted: true,
              progress: 1.0,
              completedAt: DateTime.now(),
            );
          }
          return a;
        }).toList();
      });

      // Completion animation
      _showCompletionAnimation(activity);

      // Refresh progress data
      await _refreshProgressData();
    } catch (e) {
      print('Error marking activity complete: $e');
      Get.snackbar(
        'Error',
        'Could not mark activity as complete',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<double> _calculateActivityScore(DailyActivity activity) async {
    final random = Random();
    double baseScore = 70 + random.nextDouble() * 25;

    return switch (activity.type) {
      ActivityType.dailyQuiz => baseScore * 0.9,
      ActivityType.weeklyMockTest => baseScore * 0.85,
      ActivityType.monthlyExam => baseScore * 0.8,
      ActivityType.projectWork => baseScore * 0.95,
      _ => baseScore,
    };
  }

  void _showCompletionAnimation(DailyActivity activity) {
    Get.showSnackbar(
      GetSnackBar(
        message: '🎉 ${activity.title} completed!',
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green.withOpacity(0.9),
        margin: EdgeInsets.all(20),
        borderRadius: 15,
        animationDuration: Duration(milliseconds: 500),
        forwardAnimationCurve: Curves.easeOutBack,
        icon: Icon(Icons.check_circle, color: Colors.white),
        shouldIconPulse: true,
        mainButton: TextButton(
          onPressed: () => Get.back(),
          child: Text('Dismiss', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  Future<void> _refreshProgressData() async {
    if (_currentUser == null) return;

    try {
      final progressData = await _firebaseService.loadProgressData(
        _currentUser!.uid,
      );
      setState(() {
        _progressData = progressData;
      });
    } catch (e) {
      print('Error refreshing progress data: $e');
    }
  }

  String _getProfileTitle() {
    final option = _profileOptions.firstWhere(
      (opt) => opt['profile'] == _selectedProfile,
      orElse: () => _profileOptions[1],
    );
    return option['title'];
  }

  // ==============================================
  // LOADING AND ERROR SCREENS
  // ==============================================

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Icon(Icons.school, size: 40, color: Colors.white),
                  ),
                )
                .animate(onPlay: (controller) => controller.repeat())
                .shimmer(duration: 1500.ms),
            SizedBox(height: 20),
            Text(
              'Loading Study Planner...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                backgroundColor: Colors.grey[200],
                color: Color(0xFF667EEA),
                minHeight: 3,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==============================================
  // MAIN BUILD METHOD
  // ==============================================

  @override
  Widget build(BuildContext context) {
    if (_hasError && !_isLoading) {
      return _buildErrorScreen();
    }

    if (_isLoading) {
      return _buildLoadingScreen();
    }

    return Scaffold(
      backgroundColor: Color(0xFFF8FAFF),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          color: Color(0xFF667EEA),
          backgroundColor: Colors.white,
          child: CustomScrollView(
            physics: BouncingScrollPhysics(),
            slivers: [
              // APP BAR
              SliverAppBar(
                floating: true,
                snap: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Text(
                  'Study Planner',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(Iconsax.calendar, color: Colors.grey[700]),
                    onPressed: () {
                      _showCalendarView();
                    },
                  ),
                  IconButton(
                    icon: Icon(Iconsax.chart_2, color: Colors.grey[700]),
                    onPressed: () {
                      _showAnalytics();
                    },
                  ),
                  SizedBox(width: 8),
                ],
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(60),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFF667EEA).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: Color(0xFF667EEA),
                              ),
                              SizedBox(width: 6),
                              Text(
                                DateFormat(
                                  'EEEE, MMM d',
                                ).format(DateTime.now()),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF667EEA),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Spacer(),
                        if (_currentUser != null)
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                _currentUser!.name
                                    .substring(0, 1)
                                    .toUpperCase(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // MAIN CONTENT
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // Profile Selection
                    _buildProfileSelectionSection(),

                    // Today's Activities
                    _buildTodayActivitiesSection(),

                    // Weekly Overview
                    _buildWeeklyOverviewSection(),

                    // Progress Stats
                    _buildProgressStatsSection(),

                    // Quick Actions
                    _buildQuickActionsSection(),

                    // Course Overview
                    if (_scholonCurriculum != null && _currentSchedule == null)
                      _buildCourseOverviewSection(),

                    // Generate Schedule Button
                    if (_currentSchedule == null)
                      _buildGenerateScheduleButton(),

                    SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==============================================
  // UI COMPONENTS (Updated for Adapted Curriculum)
  // ==============================================

  Widget _buildProfileSelectionSection() {
    final selectedOption = _profileOptions.firstWhere(
      (opt) => opt['profile'] == _selectedProfile,
      orElse: () => _profileOptions[1],
    );

    return Container(
      margin: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose Your Learning Style',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Select the pace that matches your learning preferences',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          SizedBox(height: 20),

          // Profile Cards - Horizontal Scroll
          SizedBox(
            height: 220,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _profileOptions.map((option) {
                final profile = option['profile'] as LearningProfile;
                final isSelected = _selectedProfile == profile;
                final gradientColors = option['gradient'] as List<Color>;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedProfile = profile;
                    });
                  },
                  child: Container(
                    width: 180,
                    margin: EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isSelected
                            ? gradientColors
                            : [Colors.white, Colors.white],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: isSelected
                            ? gradientColors[0].withOpacity(0.3)
                            : Colors.grey.shade200,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                            isSelected ? 0.1 : 0.04,
                          ),
                          blurRadius: 3,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white.withOpacity(0.2)
                                  : gradientColors[0].withOpacity(0.1),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Center(
                              child: Icon(
                                option['icon'] as IconData,
                                color: isSelected
                                    ? Colors.white
                                    : gradientColors[0],
                                size: 24,
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            option['title'] as String,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            option['time'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected
                                  ? Colors.white.withOpacity(0.8)
                                  : Colors.grey[600],
                            ),
                          ),
                          Spacer(),
                          if (isSelected)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Selected',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ).animate().scale(duration: 300.ms, curve: Curves.easeOut),
                );
              }).toList(),
            ),
          ),

          SizedBox(height: 20),

          // Generate Plan Button
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: selectedOption['gradient'],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: selectedOption['gradient'][0].withOpacity(0.3),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: _isGeneratingSchedule ? null : _generateSchedule,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isGeneratingSchedule)
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      else
                        Icon(Icons.auto_awesome, size: 22, color: Colors.white),
                      SizedBox(width: 12),
                      Text(
                        _isGeneratingSchedule
                            ? 'Creating Your Plan...'
                            : 'Generate Study Plan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 20, end: 0);
  }

  Widget _buildTodayActivitiesSection() {
    try {
      // Get today's date for filtering
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Filter activities for today from the schedule
      List<DailyActivity> todayScheduledActivities = [];

      if (_currentSchedule != null) {
        for (final entry in _currentSchedule!.dailyActivities.entries) {
          final activityDate = DateTime(
            entry.key.year,
            entry.key.month,
            entry.key.day,
          );

          if (activityDate == today) {
            todayScheduledActivities.addAll(entry.value);
          }
        }
      }

      // Use scheduled activities if available, otherwise use loaded activities
      final activities = todayScheduledActivities.isNotEmpty
          ? todayScheduledActivities
          : _todayActivities
                .where(
                  (activity) =>
                      activity.id.isNotEmpty && activity.title.isNotEmpty,
                )
                .toList();

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Today's Schedule",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    '${activities.length} activities',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              DateFormat('EEEE, MMMM d, yyyy').format(now),
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 16),

            if (activities.isEmpty)
              _buildNoActivitiesToday()
            else
              Column(
                children: activities.map((activity) {
                  return _buildEnhancedActivityCard(activity);
                }).toList(),
              ),
          ],
        ),
      );
    } catch (e) {
      print('Error building today activities: $e');
      return Container(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Text(
            'Unable to load activities',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
  }

  Widget _buildNoActivitiesToday() {
    return Container(
      padding: EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(Icons.calendar_today, size: 40, color: Colors.orange),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'No Activities Scheduled Today',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Text(
            _currentSchedule == null
                ? 'Generate a study plan to get started with your learning journey'
                : 'All caught up! No activities scheduled for today.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          SizedBox(height: 20),
          if (_currentSchedule == null)
            ElevatedButton.icon(
              onPressed: _generateSchedule,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
              ),
              icon: Icon(Icons.play_arrow),
              label: Text('Create Plan Now'),
            ),
        ],
      ),
    );
  }

  Widget _buildEnhancedActivityCard(DailyActivity activity) {
    final isDemo = activity.metadata['isDemo'] == true;
    final courseCode = activity.courseCodes.isNotEmpty
        ? activity.courseCodes.first
        : '';
    final courseName = activity.metadata['courseName'] as String? ?? '';
    final originalContentType =
        activity.metadata['originalContentType'] as String? ?? '';

    // Determine icon based on content type
    final iconData = switch (activity.type) {
      ActivityType.dailyLesson => Icons.menu_book,
      ActivityType.dailyQuiz => Icons.quiz,
      ActivityType.monthlyExam => Icons.assignment,
      ActivityType.practiceSession => Icons.repeat,
      ActivityType.projectWork => Icons.work,
      ActivityType.researchWork => Icons.search,
      ActivityType.experimentLab => Icons.science,
      _ => Icons.school,
    };

    // Determine color based on course
    final color = _getCourseColor(courseCode);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 3,
      margin: EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Demo badge if applicable
              if (isDemo)
                Container(
                  margin: EdgeInsets.only(bottom: 8),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.science, size: 12, color: Colors.orange),
                      SizedBox(width: 4),
                      Text(
                        'DEMO',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

              // Course tag
              if (courseCode.isNotEmpty)
                Container(
                  margin: EdgeInsets.only(bottom: 8),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    courseCode,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

              SizedBox(height: 8),

              // Activity title
              Text(
                activity.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              SizedBox(height: 8),

              // Activity description
              Text(
                activity.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              SizedBox(height: 16),

              // Metadata row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Content type badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getContentTypeColor(originalContentType),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      (originalContentType.isNotEmpty
                              ? originalContentType
                              : activity.type.name.replaceAll(
                                  'ActivityType.',
                                  '',
                                ))
                          .toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // Duration
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey[500],
                      ),
                      SizedBox(width: 4),
                      Text(
                        '${activity.estimatedDuration.inMinutes} min',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  // Progress
                  if (activity.isCompleted)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 12,
                            color: Colors.green,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Completed',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              // Action buttons
              if (!activity.isCompleted) ...[
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _startActivity(activity),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        icon: Icon(Icons.play_arrow),
                        label: Text('Start Now'),
                      ),
                    ),
                    SizedBox(width: 10),
                    IconButton(
                      onPressed: () => _showActivityDetails(activity),
                      icon: Icon(Icons.info_outline),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getContentTypeColor(String contentType) {
    final colors = {
      'note': Colors.blue,
      'quiz': Colors.green,
      'assignment': Colors.orange,
      'exam': Colors.purple,
      'activity': Colors.teal,
      'project': Colors.deepOrange,
      'research': Colors.pink,
      'practice': Colors.cyan,
      'lab': Colors.lightGreen,
    };
    return colors[contentType.toLowerCase()] ?? Colors.grey;
  }

  List<DailyActivity> _getMockActivitiesForToday() {
    final now = DateTime.now();
    return [
      DailyActivity(
        id: 'mat001_w1_n1_${now.millisecondsSinceEpoch}',
        date: now,
        title: 'Advanced Mathematics: Concept of Limits and Continuity',
        description:
            'Detailed exploration of ε-δ definition of limits, continuity theorems...',
        type: ActivityType.dailyLesson,
        estimatedDuration: Duration(minutes: 60),
        courseCodes: ['MAT'],
        metadata: {
          'courseName': 'Advanced Mathematics',
          'courseCode': 'MAT',
          'originalContentType': 'note',
          'difficulty': 'Advanced',
          'duration': '60 min',
          'isDemo': true,
        },
      ),
      DailyActivity(
        id: 'mat001_w1_q1_${now.millisecondsSinceEpoch}',
        date: now,
        title: 'Advanced Mathematics: Calculus Fundamentals Quiz 1',
        description:
            'Test your understanding of limits and continuity concepts',
        type: ActivityType.dailyQuiz,
        estimatedDuration: Duration(minutes: 30),
        courseCodes: ['MAT'],
        metadata: {
          'courseName': 'Advanced Mathematics',
          'courseCode': 'MAT',
          'originalContentType': 'quiz',
          'questionsCount': 10,
          'passingScore': 70,
          'isDemo': true,
        },
      ),
    ];
  }

  // In your existing study_planner_screen.dart, update this method:
void _startActivity(DailyActivity activity) {
  // Track analytics
  _trackUserInteraction('activity_started', {
    'activity_id': activity.id,
    'activity_type': activity.type.name,
    'course_codes': activity.courseCodes,
  });

  // Navigate to gateway screen first
  final course = _scholonCurriculum?.courses.firstWhere(
    (c) => c.courseCode == activity.courseCodes.firstOrNull,
    orElse: () => _scholonCurriculum?.courses.first ?? _createDemoCourse(),
  );

  Get.to(() => ActivityGatewayScreen(
    activity: activity,
    course: course,
  ));
}
AdaptedCourse _createDemoCourse() {
  return AdaptedCourse(
    id: 'demo_course',
    courseCode: 'DEMO',
    name: 'Demo Course',
    description: 'Demo course for activities',
    strand: 'General',
    credits: 1.0,
    scholonLevel: 'Beginner',
    metadata: {},
    terms: [],
  );
}

  void _showActivityDetails(DailyActivity activity) {
    Get.bottomSheet(
      Container(
        height: 400,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        activity.title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(Icons.close),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  activity.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 20),
                if (activity.metadata.containsKey('detailedContent'))
                  Text(
                    activity.metadata['detailedContent'] as String,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyOverviewSection() {
    final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dates = _weeklyActivities.keys.toList()..sort();

    // Debug: Print what's in weeklyActivities
    print('\n🎯 Building weekly overview section');
    print('   Weekly activities map has ${_weeklyActivities.length} entries');
    print(
      '   Selected date: ${DateFormat('EEE, MMM d').format(_selectedDate)}',
    );

    int daysWithActivities = _weeklyActivities.values
        .where((list) => list.isNotEmpty)
        .length;
    print('   Days with activities: $daysWithActivities');

    for (final entry in _weeklyActivities.entries) {
      if (entry.value.isNotEmpty) {
        print(
          '   ${DateFormat('EEE, MMM d').format(entry.key)}: ${entry.value.length} activities',
        );
      }
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This Week',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),

          // Debug info in dev mode
          if (daysWithActivities == 0 && _currentSchedule != null)
            Container(
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade100),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, size: 20, color: Colors.orange),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Schedule starts on ${DateFormat('MMM d').format(_currentSchedule!.startDate)}. '
                      'No activities for current week.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 30,
                  offset: Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              children: [
                // Week header
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(25),
                    ),
                  ),
                  child: Row(
                    children: weekDays.asMap().entries.map((entry) {
                      final index = entry.key;
                      final day = entry.value;
                      final date = dates.length > index
                          ? dates[index]
                          : DateTime.now();
                      final isToday =
                          date.year == DateTime.now().year &&
                          date.month == DateTime.now().month &&
                          date.day == DateTime.now().day;
                      final isSelected = _selectedDate.day == date.day;
                      final hasActivities =
                          _weeklyActivities[date]?.isNotEmpty == true;

                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedDate = date;
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 4),
                            padding: EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.blue
                                  : isToday
                                  ? Colors.blue.withOpacity(0.1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  day,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : isToday
                                        ? Colors.blue
                                        : Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  date.day.toString(),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: hasActivities
                                        ? Colors.green
                                        : Colors.transparent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Selected day activities OR empty state
                Container(
                  padding: EdgeInsets.all(20),
                  child: _buildSelectedDayContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 20, end: 0, delay: 200.ms);
  }

  Widget _buildSelectedDayContent() {
    final selectedActivities = _weeklyActivities[_selectedDate] ?? [];
    final hasSchedule = _currentSchedule != null;

    if (selectedActivities.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('EEEE, MMMM d').format(_selectedDate),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 12),
          ...selectedActivities.take(2).map((activity) {
            return Container(
              margin: EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getActivityColor(activity.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        _getActivityIcon(activity.type),
                        color: _getActivityColor(activity.type),
                        size: 20,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 12,
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: 4),
                            Text(
                              '${activity.estimatedDuration.inMinutes} min',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(width: 12),
                            if (activity.courseCodes.isNotEmpty)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _getCourseColor(
                                    activity.courseCodes.first,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  activity.courseCodes.first,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: _getCourseColor(
                                      activity.courseCodes.first,
                                    ),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          if (selectedActivities.length > 2)
            Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                '+ ${selectedActivities.length - 2} more activities',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      );
    } else {
      // Empty state
      return Column(
        children: [
          Icon(Icons.beach_access, size: 40, color: Colors.blue.shade300),
          SizedBox(height: 12),
          Text(
            'No activities scheduled',
            style: TextStyle(
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
          if (hasSchedule && _currentSchedule!.dailyActivities.isNotEmpty)
            Column(
              children: [
                SizedBox(height: 8),
                Text(
                  'Schedule has ${_currentSchedule!.dailyActivities.values.fold(0, (sum, list) => sum + list.length)} total activities',
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    // Show all schedule dates
                    _showAllScheduleDates();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade50,
                    foregroundColor: Colors.blue,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('View All Scheduled Dates'),
                ),
              ],
            ),
        ],
      );
    }
  }

  void _showAllScheduleDates() {
    if (_currentSchedule == null || _currentSchedule!.dailyActivities.isEmpty)
      return;

    final allDates = _currentSchedule!.dailyActivities.keys.toList()..sort();

    Get.bottomSheet(
      Container(
        height: 400,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'All Scheduled Dates',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20),
                itemCount: allDates.length,
                itemBuilder: (context, index) {
                  final date = allDates[index];
                  final activities =
                      _currentSchedule!.dailyActivities[date] ?? [];
                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          '${activities.length}',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    title: Text(DateFormat('EEEE, MMMM d, yyyy').format(date)),
                    subtitle: Text('${activities.length} activities'),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {
                      // Jump to this date in weekly view
                      setState(() {
                        _selectedDate = date;
                        // Regenerate weekly view centered on this date
                        _generateWeeklyViewCenteredOn(date);
                      });
                      Get.back();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _generateWeeklyViewCenteredOn(DateTime centerDate) {
    // Calculate Monday of the week containing centerDate
    final startOfWeek = DateTime(
      centerDate.year,
      centerDate.month,
      centerDate.day - centerDate.weekday + 1,
    );

    print(
      '📅 Regenerating weekly view centered on ${DateFormat('MMM d').format(centerDate)}',
    );

    _weeklyActivities = {};

    if (_currentSchedule != null &&
        _currentSchedule!.dailyActivities.isNotEmpty) {
      // Generate the week view
      for (int i = 0; i < 7; i++) {
        final date = startOfWeek.add(Duration(days: i));
        final dateKey = DateTime(date.year, date.month, date.day);

        // Find activities for this date
        var foundActivities = <DailyActivity>[];

        for (final entry in _currentSchedule!.dailyActivities.entries) {
          final entryDate = DateTime(
            entry.key.year,
            entry.key.month,
            entry.key.day,
          );

          if (entryDate == dateKey) {
            foundActivities.addAll(entry.value);
            break;
          }
        }

        _weeklyActivities[date] = foundActivities;
      }

      setState(() {});
    }
  }

  void _debugScheduleStructure() {
  if (_currentSchedule != null) {
    print('\n🔍 DEBUG SCHEDULE STRUCTURE');
    print('Total days in schedule: ${_currentSchedule!.dailyActivities.length}');
    
    final dates = _currentSchedule!.dailyActivities.keys.toList()..sort();
    if (dates.isNotEmpty) {
      print('First date: ${DateFormat('EEE, MMM d, yyyy').format(dates.first)}');
      print('Last date: ${DateFormat('EEE, MMM d, yyyy').format(dates.last)}');
      
      print('\nFirst 5 dates with activities:');
      for (int i = 0; i < min(5, dates.length); i++) {
        final date = dates[i];
        final activities = _currentSchedule!.dailyActivities[date] ?? [];
        print('  ${DateFormat('EEE, MMM d').format(date)}: ${activities.length} activities');
        if (activities.isNotEmpty) {
          for (final activity in activities.take(1)) {
            print('    • ${activity.title}');
            print('      Date in activity: ${DateFormat('EEE, MMM d, yyyy').format(activity.date)}');
          }
        }
      }
    }
  } else {
    print('❌ No schedule loaded');
  }
}

  Widget _buildProgressStatsSection() {
    final averageScore =
        (_progressData['averageScore'] as num?)?.toDouble() ?? 0.0;
    final completedActivities =
        (_progressData['completedActivities'] as int?) ?? 0;
    final streak = (_progressData['streak'] as int?) ?? 0;
    final weeklyHours =
        (_progressData['weeklyHours'] as num?)?.toDouble() ?? 0.0;

    return Container(
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Learning Progress',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 16),

              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF667EEA).withOpacity(0.3),
                      blurRadius: 30,
                      offset: Offset(0, 15),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Overall progress
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Overall Progress',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '${(averageScore).toInt()}%',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${completedActivities} activities completed',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        CircularPercentIndicator(
                          radius: 50,
                          lineWidth: 8,
                          percent: averageScore / 100,
                          center: Text(
                            '${(averageScore).toInt()}%',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          progressColor: Colors.white,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          circularStrokeCap: CircularStrokeCap.round,
                        ),
                      ],
                    ),

                    SizedBox(height: 20),

                    // Stats grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2.5,
                      children: [
                        _buildStatTile(
                          icon: Icons.local_fire_department,
                          value: streak.toString(),
                          label: 'Day Streak',
                          color: Colors.orange,
                          bgColor: Colors.white.withOpacity(0.1),
                        ),
                        _buildStatTile(
                          icon: Icons.access_time,
                          value: '${weeklyHours.toStringAsFixed(1)}h',
                          label: 'Weekly Hours',
                          color: Colors.green,
                          bgColor: Colors.white.withOpacity(0.1),
                        ),
                        _buildStatTile(
                          icon: Icons.check_circle,
                          value: completedActivities.toString(),
                          label: 'Completed',
                          color: Colors.blue,
                          bgColor: Colors.white.withOpacity(0.1),
                        ),
                        _buildStatTile(
                          icon: Icons.trending_up,
                          value: '${(averageScore / 20).toStringAsFixed(1)}',
                          label: 'Avg. Grade',
                          color: Colors.purple,
                          bgColor: Colors.white.withOpacity(0.1),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 700.ms)
        .slideY(begin: 20, end: 0, delay: 300.ms);
  }

  Widget _buildStatTile({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      padding: EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: Icon(icon, size: 18, color: color)),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Container(
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 16),

              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.6,
                children: [
                  _buildQuickActionCard(
                    icon: Icons.assignment_add,
                    title: 'Add Custom Task',
                    subtitle: 'Create your own study task',
                    color: Color(0xFF667EEA),
                    onTap: () => _addCustomTask(),
                  ),
                  _buildQuickActionCard(
                    icon: Icons.replay,
                    title: 'Reset Progress',
                    subtitle: 'Start fresh',
                    color: Color(0xFFFF416C),
                    onTap: () => _resetProgress(),
                  ),
                  _buildQuickActionCard(
                    icon: Icons.download,
                    title: 'Export Schedule',
                    subtitle: 'Save as PDF/Calendar',
                    color: Color(0xFF11998E),
                    onTap: () => _exportSchedule(),
                  ),
                  _buildQuickActionCard(
                    icon: Icons.share,
                    title: 'Share Progress',
                    subtitle: 'With parents/teachers',
                    color: Color(0xFFFFB347),
                    onTap: () => _shareProgress(),
                  ),
                ],
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 800.ms)
        .slideY(begin: 20, end: 0, delay: 400.ms);
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: Icon(icon, color: color, size: 20)),
              ),
              Spacer(),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCourseOverviewSection() {
    if (_scholonCurriculum == null || _scholonCurriculum!.courses.isEmpty) {
      return SizedBox();
    }

    final courses = _scholonCurriculum!.courses;
    final totalCredits = courses.fold(
      0.0,
      (sum, course) => sum + course.credits,
    );

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Curriculum Overview',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '${courses.length} courses • ${totalCredits.toInt()} total credits',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          SizedBox(height: 16),

          ...courses.take(3).map((course) {
            return Container(
              margin: EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _getCourseColor(course.courseCode),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      course.courseCode.substring(0, 2),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  course.name,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  '${course.credits} credits • ${course.scholonLevel}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                trailing: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStrandColor(course.strand).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    course.strand,
                    style: TextStyle(
                      fontSize: 11,
                      color: _getStrandColor(course.strand),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                onTap: () => _showCourseDetails(course),
              ),
            );
          }),

          if (courses.length > 3)
            Center(
              child: TextButton(
                onPressed: () => _showAllCourses(),
                child: Text(
                  'View all ${courses.length} courses',
                  style: TextStyle(
                    color: Color(0xFF667EEA),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 1000.ms);
  }

  Widget _buildGenerateScheduleButton() {
    final selectedOption = _profileOptions.firstWhere(
      (opt) => opt['profile'] == _selectedProfile,
      orElse: () => _profileOptions[1],
    );

    // Don't show generate button if schedule exists
    if (_currentSchedule != null) {
      return Container(
        margin: EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green.shade100),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Schedule Active',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade800,
                          ),
                        ),
                        Text(
                          'Your study plan is ready',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => _generateSchedule(),
                    child: Text('Regenerate'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Text(
              'You can regenerate your schedule if needed',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 1200.ms);
    }

    return Container(
      margin: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: selectedOption['gradient'],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: selectedOption['gradient'][0].withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: _isGeneratingSchedule ? null : _generateSchedule,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isGeneratingSchedule)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                else
                  Icon(Icons.auto_awesome, size: 22, color: Colors.white),
                SizedBox(width: 12),
                Text(
                  _isGeneratingSchedule
                      ? 'Creating Your Plan...'
                      : 'Generate Study Plan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 1200.ms);
  }

  // ==============================================
  // HELPER FUNCTIONS
  // ==============================================

  Color _getActivityColor(ActivityType type) {
    return switch (type) {
      ActivityType.dailyLesson => Colors.blue,
      ActivityType.dailyQuiz => Colors.green,
      ActivityType.weeklyMockTest => Colors.orange,
      ActivityType.monthlyExam => Colors.purple,
      ActivityType.practiceSession => Colors.teal,
      ActivityType.revisionSession => Colors.indigo,
      ActivityType.projectWork => Colors.deepOrange,
      ActivityType.readingSession => Colors.brown,
      ActivityType.researchWork => Colors.pink,
      ActivityType.problemSolving => Colors.cyan,
      ActivityType.experimentLab => Colors.lightGreen,
      ActivityType.groupDiscussion => Colors.deepPurple,
    };
  }

  IconData _getActivityIcon(ActivityType type) {
    return switch (type) {
      ActivityType.dailyLesson => Icons.school,
      ActivityType.dailyQuiz => Icons.quiz,
      ActivityType.weeklyMockTest => Icons.assignment,
      ActivityType.monthlyExam => Icons.assignment_turned_in,
      ActivityType.practiceSession => Icons.repeat,
      ActivityType.revisionSession => Icons.replay,
      ActivityType.projectWork => Icons.work,
      ActivityType.readingSession => Icons.menu_book,
      ActivityType.researchWork => Icons.search,
      ActivityType.problemSolving => Icons.lightbulb,
      ActivityType.experimentLab => Icons.science,
      ActivityType.groupDiscussion => Icons.group,
    };
  }

  Color _getCourseColor(String courseCode) {
    final colors = {
      'MAT': Color(0xFF667EEA), // Blue
      'PHY': Color(0xFF11998E), // Teal
      'CHE': Color(0xFF38EF7D), // Green
      'BIO': Color(0xFFFF416C), // Pink
      'ENG': Color(0xFFFF4B2B), // Orange
      'ECO': Color(0xFF9C27B0), // Purple
      'COM': Color(0xFF2196F3), // Light Blue
      'PHL': Color(0xFFFF9800), // Amber
      'ART': Color(0xFF795548), // Brown
      'ENT': Color(0xFF4CAF50), // Green
    };

    // Extract first 3 letters for mapping
    final prefix = courseCode.length >= 3
        ? courseCode.substring(0, 3)
        : courseCode;
    return colors[prefix] ?? Colors.blue;
  }

  Color _getStrandColor(String strand) {
    return switch (strand.toLowerCase()) {
      'stem' => Colors.blue,
      'core' => Colors.green,
      'humanities' => Colors.purple,
      'social sciences' => Colors.orange,
      'vocational' => Colors.teal,
      'elective' => Colors.pink,
      _ => Colors.grey,
    };
  }

  // ==============================================
  // ACTIVITY HANDLERS
  // ==============================================

  void _showCalendarView() {
    Get.bottomSheet(
      Container(
        height: 400,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              child: Text(
                'Select Date',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 30,
                itemBuilder: (context, index) {
                  final date = DateTime.now().add(Duration(days: index));
                  return ListTile(
                    title: Text(DateFormat('EEEE, MMMM d').format(date)),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {
                      setState(() {
                        _selectedDate = date;
                      });
                      Get.back();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAnalytics() {
    Get.snackbar(
      'Analytics',
      'Detailed analytics coming soon!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _addCustomTask() {
    Get.snackbar(
      'Custom Task',
      'Add custom task feature coming soon!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _resetProgress() {
    Get.defaultDialog(
      title: 'Reset Progress?',
      middleText:
          'Are you sure you want to reset all your progress? This action cannot be undone.',
      textConfirm: 'Reset',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back();
        Get.snackbar(
          'Progress Reset',
          'All progress has been reset',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
  }

  void _exportSchedule() {
    Get.snackbar(
      'Export',
      'Export feature coming soon!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _shareProgress() {
    Get.snackbar(
      'Share',
      'Share feature coming soon!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _showCourseDetails(AdaptedCourse course) {
    Get.bottomSheet(
      Container(
        height: 500,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        course.name,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(Icons.close),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  '${course.courseCode} • ${course.credits} credits • ${course.scholonLevel}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                SizedBox(height: 20),
                Text(
                  course.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAllCourses() {
    if (_scholonCurriculum == null) return;

    Get.bottomSheet(
      Container(
        height: 600,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(25),
              child: Text(
                'All Courses',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20),
                itemCount: _scholonCurriculum!.courses.length,
                itemBuilder: (context, index) {
                  final course = _scholonCurriculum!.courses[index];
                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getCourseColor(course.courseCode),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          course.courseCode.substring(0, 2),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    title: Text(course.name),
                    subtitle: Text('${course.credits} credits'),
                    trailing: Text(course.strand),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
