import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import 'package:isapp/core/utils/debouncer.dart';
import 'package:isapp/data/library/new_courses.dart';
import 'package:isapp/features/auth/controllers/authentication_controller.dart';
import 'package:isapp/features/auth/models/user.dart';
import 'package:isapp/features/learning/controllers/scholon_curriculum_planner_adapter.dart';
import 'package:isapp/features/learning/screens/activity_gateway.dart';
import 'package:isapp/features/study_guide/models/activity_type.dart';
import 'package:isapp/features/study_guide/models/daily_activity.dart';
import 'package:isapp/features/study_guide/models/learning_profile.dart';
import 'package:isapp/features/study_guide/models/study_schedule.dart';
import 'package:isapp/features/study_guide/services/scholon_activity_planner.dart';
import 'package:isapp/features/study_guide/services/study_planner_firebase_service.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

part 'study_planner_screen_sections/01_error_screen.dart';
part 'study_planner_screen_sections/02_today_activities_section.dart';
part 'study_planner_screen_sections/03_weekly_overview_section.dart';
part 'study_planner_screen_sections/04_stat_tile.dart';
part 'study_planner_screen_sections/05_analytics.dart';

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

}
