import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:isapp/data/library/new_courses.dart';
import 'package:isapp/features/auth/models/user.dart';
import 'package:isapp/features/learning/controllers/scholon_curriculum_planner_adapter.dart';
import 'package:isapp/features/study_guide/models/activity_type.dart';
import 'package:isapp/features/study_guide/models/curriculum_content_item.dart';
import 'package:isapp/features/study_guide/models/daily_activity.dart';
import 'package:isapp/features/study_guide/models/learning_profile.dart';
import 'package:isapp/features/study_guide/models/study_schedule.dart';

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
