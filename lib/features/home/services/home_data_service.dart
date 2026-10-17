import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:isapp/data/library/course_logic.dart';
import 'package:isapp/data/library/new_courses.dart';
import 'package:isapp/features/auth/models/user.dart';
import 'package:isapp/features/home/models/course_progress.dart';
import 'package:isapp/features/home/models/game_detail_2.dart';
import 'package:isapp/features/home/models/recommended_course.dart';
import 'package:isapp/features/home/models/upcoming_quiz.dart';
import 'package:isapp/features/learning/models/course_models.dart';
import 'package:isapp/features/study_guide/study_guide.dart';

class HomeDataService {
  // Parse JSON data (updated with optional json parameter)
  static List<CourseCategories> parseCourseCategoriesJson() {
    try {
      if (Constants.courseCategoriesJson.isEmpty) {
        print('Warning: courseCategoriesJson is empty');
        return [];
      }

      List<dynamic> jsonList = jsonDecode(Constants.courseCategoriesJson);
      final categories = jsonList
          .map((json) => CourseCategories.fromJson(json))
          .toList();

      print('Successfully parsed ${categories.length} course categories');
      return categories;
    } catch (e) {
      print('Error parsing course categories JSON: $e');
      print(
        'JSON content: ${Constants.courseCategoriesJson.substring(0, min(200, Constants.courseCategoriesJson.length))}...',
      );
      return [];
    }
  }

  static List<CourseCategories> parseQuizCategoriesJson([String? jsonData]) {
    try {
      final jsonString = jsonData ?? Constants.quizCategoriesJson;
      List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => CourseCategories.fromJson(json)).toList();
    } catch (e) {
      print('Error parsing quiz categories: $e');
      return [];
    }
  }

  static List<CourseCategories> parseExamCategoriesJson([String? jsonData]) {
    try {
      final jsonString = jsonData ?? Constants.examCategoriesJson;
      List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => CourseCategories.fromJson(json)).toList();
    } catch (e) {
      print('Error parsing exam categories: $e');
      return [];
    }
  }

  // Get all games data - RESTORED
  static List<GameDetail> getGames() {
    return [
      GameDetail(
        emojiImage: "assets/bee.png",
        description: "Mobile spelling bee game for school kids",
        color: const Color(0xFFC7E9FE),
        image: "assets/bee.png",
        name: 'Spelling Bee',
        instructor: "B. Badejo",
        time: 3,
        route: '/spelling-bee', // Add route
      ),
      GameDetail(
        emojiImage: "assets/ttt.png",
        description: "Mobile Tic Tac Toe game for all ages",
        color: const Color(0xFFFFDEFF),
        image: "assets/ttt.png",
        name: 'Tic Tac Toe',
        instructor: "B. Badejo",
        time: 1,
        route: '/tic-tac-toe',
      ),
      GameDetail(
        emojiImage: "assets/ttt.png",
        description: "Mobile Sudoku game for all ages",
        color: const Color(0xFFFFDEFF),
        image: "assets/ttt.png",
        name: 'Sudoku',
        instructor: "B. Badejo",
        time: 1,
        route: '/sudoku',
      ),
    ];
  }

  // Get tools data - RESTORED
  static List<Map<String, String>> getTools() {
    return [
      {
        'title': 'Account Settings',
        'icon': 'person',
        'color': '4280391411',
        'route': '/account-settings', // Add route
      },
      {
        'title': 'Privacy Policy',
        'icon': 'security',
        'color': '4283215696',
        'route': '/privacy-policy', // Add route
      },
      {
        'title': 'Score Sheet',
        'icon': 'assessment',
        'color': '4288423856',
        'route': '/score-sheet', // Add route
      },
      {
        'title': 'Notepad',
        'icon': 'note_add',
        'color': '4294940672',
        'subtitle': 'Stories',
        'route': '/notepad', // Add route
      },
    ];
  }

  // Get study plan data from Firebase
  static Future<Map<String, dynamic>> getStudyPlanData(String studentId) async {
    try {
      final firestore = FirebaseFirestore.instance;

      // Get schedule
      final scheduleDoc = await firestore
          .collection('studentSchedules')
          .doc(studentId)
          .get();

      if (!scheduleDoc.exists) {
        return {
          'hasSchedule': false,
          'totalActivities': 0,
          'completedActivities': 0,
          'dailyGoalMinutes': 120,
          'examsCount': 0,
          'upcomingQuizzes': [],
          'courseProgress': {},
          'totalStudyMinutes': 0,
        };
      }

      final scheduleData = scheduleDoc.data()!;

      // Get all activities
      final activitiesSnapshot = await firestore
          .collection('studentSchedules')
          .doc(studentId)
          .collection('dailyActivities')
          .get();

      // Calculate stats
      int totalActivities = 0;
      int completedActivities = 0;
      int totalStudyMinutes = 0;
      int examsCount = 0;

      final courseProgress = <String, CourseProgress>{};

      for (final doc in activitiesSnapshot.docs) {
        final data = doc.data();
        totalActivities++;

        if (data['isCompleted'] == true) {
          completedActivities++;
          final duration = (data['estimatedMinutes'] as num?)?.toInt() ?? 0;
          totalStudyMinutes += duration; // This is now int + int
        }

        // Count exams
        final type = data['type'] ?? '';
        if (type.contains('Exam') || type.contains('Test')) {
          examsCount++;
        }

        // Track course progress
        final courseCodes = List<String>.from(data['courseCodes'] ?? []);
        final isCompleted = data['isCompleted'] == true;
        final progress = (data['progress'] as num?)?.toDouble() ?? 0.0;

        for (final courseCode in courseCodes) {
          if (!courseProgress.containsKey(courseCode)) {
            courseProgress[courseCode] = CourseProgress(
              courseCode: courseCode,
              totalActivities: 0,
              completedActivities: 0,
              totalProgress: 0.0,
            );
          }

          final progressObj = courseProgress[courseCode]!;
          progressObj.totalActivities++;
          if (isCompleted) {
            progressObj.completedActivities++;
          }
          progressObj.totalProgress += progress;
        }
      }

      // Get upcoming quizzes (next 7 days)
      final now = DateTime.now();
      final nextWeek = now.add(Duration(days: 7));

      final upcomingQuizzesSnapshot = await firestore
          .collection('studentSchedules')
          .doc(studentId)
          .collection('dailyActivities')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(nextWeek))
          .where('type', whereIn: ['dailyQuiz', 'weeklyMockTest'])
          .orderBy('date')
          .limit(5)
          .get();

      final upcomingQuizzes = upcomingQuizzesSnapshot.docs.map((doc) {
        final data = doc.data();
        final date = (data['date'] as Timestamp).toDate();
        final metadata = Map<String, dynamic>.from(data['metadata'] ?? {});
        final courseCodes = List<String>.from(data['courseCodes'] ?? []);
        final courseCode = courseCodes.isNotEmpty ? courseCodes[0] : '';

        return UpcomingQuiz(
          id: doc.id,
          subject: _getSubjectName(
            metadata['courseName']?.toString() ?? courseCode,
          ),
          topic:
              metadata['topic']?.toString() ??
              data['title']?.toString() ??
              'Quiz',
          dateTime: date,
          duration:
              (data['estimatedMinutes'] as num?)?.toInt() ??
              20, // Fixed here too
          totalQuestions: (metadata['questionsCount'] as int?) ?? 10,
          icon: _getQuizIcon(data['type'] ?? 'dailyQuiz'),
          color: _getQuizColor(data['type'] ?? 'dailyQuiz'),
          description: data['description']?.toString(),
          activityType: data['type'],
          courseCode: courseCode,
        );
      }).toList();

      // Calculate daily goal based on profile
      final profile = scheduleData['profile'] ?? 'balancedStudent';
      final dailyGoalMinutes = _getDailyGoalMinutes(profile);

      return {
        'hasSchedule': true,
        'totalActivities': totalActivities,
        'completedActivities': completedActivities,
        'dailyGoalMinutes': dailyGoalMinutes,
        'examsCount': examsCount,
        'upcomingQuizzes': upcomingQuizzes,
        'courseProgress': courseProgress,
        'totalStudyMinutes': totalStudyMinutes,
        'profile': profile,
        'subjectWeights': Map<String, double>.from(
          scheduleData['subjectWeights'] ?? {},
        ),
      };
    } catch (e) {
      print('Error getting study plan data: $e');
      return {
        'hasSchedule': false,
        'totalActivities': 0,
        'completedActivities': 0,
        'dailyGoalMinutes': 120,
        'examsCount': 0,
        'upcomingQuizzes': [],
        'courseProgress': {},
        'totalStudyMinutes': 0,
      };
    }
  }

  static Future<List<UpcomingQuiz>> getUpcomingQuizzesFromPlan(
    String studentId, {
    int limit = 3,
  }) async {
    try {
      final planData = await getStudyPlanData(studentId);
      final upcomingQuizzes = planData['upcomingQuizzes'] as List<UpcomingQuiz>;

      if (upcomingQuizzes.isNotEmpty) {
        return upcomingQuizzes.take(limit).toList();
      }

      // Fallback to simulated quizzes
      return getUpcomingQuizzes();
    } catch (e) {
      print('Error getting upcoming quizzes from plan: $e');
      return getUpcomingQuizzes();
    }
  }

  // Get recommended courses from study plan
  static Future<List<RecommendedCourse>> getRecommendedCoursesFromPlan(
    String studentId, {
    int limit = 4,
  }) async {
    try {
      final planData = await getStudyPlanData(studentId);
      final courseProgress =
          planData['courseProgress'] as Map<String, CourseProgress>;
      final subjectWeights = planData['subjectWeights'] as Map<String, double>;

      if (courseProgress.isEmpty) {
        // Load from curriculum if no schedule
        return _getCoursesFromCurriculum(limit);
      }

      // Convert course progress to recommended courses
      final recommendedCourses = courseProgress.entries.map((entry) {
        final courseCode = entry.key;
        final progress = entry.value;
        final avgProgress = progress.totalActivities > 0
            ? (progress.totalProgress / progress.totalActivities)
            : 0.0;

        // Get course details from curriculum
        final courseDetails = _getCourseDetails(courseCode);
        final subject = _extractSubjectFromCourseCode(courseCode);

        return RecommendedCourse(
          id: courseCode,
          title: courseDetails['title'] ?? courseCode,
          description: courseDetails['description'] ?? 'Study plan course',
          icon: _getCourseIcon(subject),
          color: _getCourseColor(subject),
          level: _getCourseLevel(
            planData['profile']?.toString() ?? 'balancedStudent',
          ),
          lessons: progress.totalActivities,
          progress: avgProgress,
          courseCode: courseCode,
          subject: subject,
          totalActivities: progress.totalActivities,
          completedActivities: progress.completedActivities,
        );
      }).toList();

      // Sort by subject weight and then progress
      recommendedCourses.sort((a, b) {
        final weightA = subjectWeights[a.courseCode] ?? 0;
        final weightB = subjectWeights[b.courseCode] ?? 0;
        if (weightB.compareTo(weightA) != 0) {
          return weightB.compareTo(weightA);
        }
        return a.progress.compareTo(b.progress); // Lower progress first
      });

      return recommendedCourses.take(limit).toList();
    } catch (e) {
      print('Error getting recommended courses from plan: $e');
      return _getCoursesFromCurriculum(limit);
    }
  }

  // Get courses from curriculum
  static List<RecommendedCourse> _getCoursesFromCurriculum(int limit) {
    try {
      // Parse curriculum from Courses class
      final curriculumJson = Courses.ss3Curriculum;
      if (curriculumJson.isEmpty) {
        return getRecommendedCourses('Basic Education', 1);
      }

      final parsed = jsonDecode(curriculumJson.trim());
      if (parsed is List && parsed.isNotEmpty) {
        final curriculum = parsed[0];
        final courses = curriculum['courses'] as List? ?? [];

        return courses.take(limit).map((course) {
          final courseCode = course['courseCode']?.toString() ?? '';
          final subject = _extractSubjectFromCourseCode(courseCode);

          return RecommendedCourse(
            id: courseCode,
            title: course['name']?.toString() ?? courseCode,
            description:
                course['description']?.toString() ?? 'Curriculum course',
            icon: _getCourseIcon(subject),
            color: _getCourseColor(subject),
            level: 'Intermediate',
            lessons: 10, // Default
            progress: 0.0,
            courseCode: courseCode,
            subject: subject,
          );
        }).toList();
      }

      return getRecommendedCourses('Basic Education', 1);
    } catch (e) {
      print('Error loading courses from curriculum: $e');
      return getRecommendedCourses('Basic Education', 1);
    }
  }

  // Get student learning stats
  static Future<Map<String, dynamic>> getStudentLearningStats(
    String studentId,
  ) async {
    try {
      final planData = await getStudyPlanData(studentId);

      // Calculate additional stats
      final totalActivities = planData['totalActivities'] as int;
      final completedActivities = planData['completedActivities'] as int;
      final totalStudyMinutes = planData['totalStudyMinutes'] as int;

      // Calculate average score from completed activities
      final firestore = FirebaseFirestore.instance;
      final completedSnapshot = await firestore
          .collection('studentSchedules')
          .doc(studentId)
          .collection('dailyActivities')
          .where('isCompleted', isEqualTo: true)
          .limit(50)
          .get();

      double totalScore = 0;
      int scoredActivities = 0;

      for (final doc in completedSnapshot.docs) {
        final data = doc.data();
        final score = (data['actualScore'] as num?)?.toDouble();
        if (score != null) {
          totalScore += score;
          scoredActivities++;
        }
      }

      final avgScore = scoredActivities > 0
          ? (totalScore / scoredActivities)
          : 0.0;

      return {
        'totalStudyMinutes': totalStudyMinutes,
        'avgScore': avgScore,
        'completedLessons': completedActivities,
        'enrolledCourses': (planData['courseProgress'] as Map).length,
        'totalActivities': totalActivities,
        'dailyGoalMinutes': planData['dailyGoalMinutes'] as int,
        'examsCount': planData['examsCount'] as int,
      };
    } catch (e) {
      print('Error getting student learning stats: $e');
      return {
        'totalStudyMinutes': 0,
        'avgScore': 0.0,
        'completedLessons': 0,
        'enrolledCourses': 0,
        'totalActivities': 0,
        'dailyGoalMinutes': 120,
        'examsCount': 0,
      };
    }
  }

  // Get today's study items
  static Future<List<Map<String, dynamic>>> getTodaysStudyItems(
    String studentId,
  ) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(Duration(days: 1));

      final firestore = FirebaseFirestore.instance;
      final snapshot = await firestore
          .collection('studentSchedules')
          .doc(studentId)
          .collection('dailyActivities')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThan: Timestamp.fromDate(endOfDay))
          .orderBy('date')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        final metadata = Map<String, dynamic>.from(data['metadata'] ?? {});
        final courseCodes = List<String>.from(data['courseCodes'] ?? []);
        final courseCode = courseCodes.isNotEmpty ? courseCodes[0] : '';

        return {
          'id': doc.id,
          'title': data['title'] ?? 'Activity',
          'description': data['description'] ?? '',
          'type': data['type'] ?? 'lesson',
          'duration': data['estimatedMinutes'] ?? 30,
          'courseCode': courseCode,
          'courseName': metadata['courseName'] ?? courseCode,
          'isCompleted': data['isCompleted'] ?? false,
          'progress': (data['progress'] as num?)?.toDouble() ?? 0.0,
          'icon': _getActivityIcon(data['type'] ?? 'lesson'),
          'color': _getActivityColor(data['type'] ?? 'lesson'),
        };
      }).toList();
    } catch (e) {
      print('Error getting today\'s study items: $e');
      return [];
    }
  }

  // Helper methods
  static int _getDailyGoalMinutes(String profile) {
    return switch (profile) {
      'pacedLearner' => 90, // 1.5 hours
      'balancedStudent' => 150, // 2.5 hours
      'acceleratedLearner' => 240, // 4 hours
      _ => 120, // Default 2 hours
    };
  }

  static IconData _getQuizIcon(String type) {
    return switch (type) {
      'weeklyMockTest' => Icons.assignment,
      'monthlyExam' => Icons.assignment_turned_in,
      _ => Icons.quiz,
    };
  }

  static Color _getQuizColor(String type) {
    return switch (type) {
      'weeklyMockTest' => Colors.orange,
      'monthlyExam' => Colors.purple,
      _ => Colors.green,
    };
  }

  static IconData _getActivityIcon(String type) {
    return switch (type) {
      'dailyLesson' => Icons.menu_book,
      'dailyQuiz' => Icons.quiz,
      'practiceSession' => Icons.repeat,
      'projectWork' => Icons.work,
      'monthlyExam' => Icons.assignment_turned_in,
      'weeklyMockTest' => Icons.assignment,
      _ => Icons.school,
    };
  }

  static Color _getActivityColor(String type) {
    return switch (type) {
      'dailyLesson' => Colors.blue,
      'dailyQuiz' => Colors.green,
      'practiceSession' => Colors.teal,
      'projectWork' => Colors.orange,
      'monthlyExam' => Colors.purple,
      'weeklyMockTest' => Colors.deepOrange,
      _ => Colors.grey,
    };
  }

  static Map<String, dynamic> _getCourseDetails(String courseCode) {
    try {
      final curriculumJson = Courses.ss3Curriculum;
      if (curriculumJson.isNotEmpty) {
        final parsed = jsonDecode(curriculumJson.trim());
        if (parsed is List && parsed.isNotEmpty) {
          final curriculum = parsed[0];
          final courses = curriculum['courses'] as List? ?? [];

          for (final course in courses) {
            if (course['courseCode']?.toString() == courseCode) {
              return {
                'title': course['name']?.toString() ?? courseCode,
                'description': course['description']?.toString() ?? '',
              };
            }
          }
        }
      }
    } catch (e) {
      print('Error getting course details: $e');
    }

    return {'title': courseCode, 'description': 'Study plan course'};
  }

  static String _getSubjectName(String subjectCode) {
    final Map<String, String> subjectNames = {
      'english': 'English Language',
      'mathematics': 'Mathematics',
      'science': 'Basic Science',
      'basic_science': 'Basic Science',
      'social_studies': 'Social Studies',
      'creative_arts': 'Creative Arts',
      'moral_ed': 'Moral Education',
      'basic_tech': 'Basic Technology',
      'business_studies': 'Business Studies',
      'french': 'French',
      'physics': 'Physics',
      'chemistry': 'Chemistry',
      'biology': 'Biology',
      'economics': 'Economics',
      'government': 'Government',
      'literature': 'Literature',
      'mat': 'Mathematics',
      'phy': 'Physics',
      'che': 'Chemistry',
      'bio': 'Biology',
      'eng': 'English Language',
      'eco': 'Economics',
      'gov': 'Government',
      'lit': 'Literature',
    };

    // Extract prefix from course code
    final prefix = subjectCode.length >= 3
        ? subjectCode.substring(0, 3).toLowerCase()
        : subjectCode.toLowerCase();

    return subjectNames[prefix] ??
        subjectNames[subjectCode.toLowerCase()] ??
        subjectCode;
  }

  static String _extractSubjectFromCourseCode(String courseCode) {
    if (courseCode.length >= 3) {
      final prefix = courseCode.substring(0, 3).toLowerCase();
      final Map<String, String> prefixMap = {
        'mat': 'mathematics',
        'eng': 'english',
        'phy': 'physics',
        'che': 'chemistry',
        'bio': 'biology',
        'sci': 'science',
        'soc': 'social',
        'art': 'art',
        'tec': 'tech',
        'bus': 'business',
        'fre': 'french',
        'eco': 'economics',
        'gov': 'government',
        'lit': 'literature',
      };
      return prefixMap[prefix] ?? 'general';
    }
    return 'general';
  }

  static IconData _getCourseIcon(String subject) {
    final Map<String, IconData> icons = {
      'english': Icons.language,
      'mathematics': Icons.calculate,
      'science': Icons.science,
      'physics': Icons.bolt,
      'chemistry': Icons.emoji_objects,
      'biology': Icons.psychology,
      'social': Icons.public,
      'art': Icons.palette,
      'tech': Icons.computer,
      'business': Icons.business,
      'french': Icons.translate,
      'economics': Icons.trending_up,
      'government': Icons.account_balance,
      'literature': Icons.menu_book,
    };

    return icons[subject] ?? Icons.school;
  }

  static Color _getCourseColor(String subject) {
    final Map<String, Color> colors = {
      'english': Colors.blue,
      'mathematics': Colors.purple,
      'science': Colors.green,
      'physics': Colors.deepOrange,
      'chemistry': Colors.teal,
      'biology': Colors.lightGreen,
      'social': Colors.orange,
      'art': Colors.pink,
      'tech': Colors.indigo,
      'business': Colors.brown,
      'french': Colors.cyan,
      'economics': Colors.amber,
      'government': Colors.deepPurple,
      'literature': Colors.red,
    };

    return colors[subject] ?? Colors.grey;
  }

  static String _getCourseLevel(String profile) {
    return switch (profile) {
      'pacedLearner' => 'Beginner',
      'balancedStudent' => 'Intermediate',
      'acceleratedLearner' => 'Advanced',
      _ => 'Intermediate',
    };
  }

  // Get upcoming quizzes (simulated) - COMPLETED
  static List<UpcomingQuiz> getUpcomingQuizzes() {
    return [
      UpcomingQuiz(
        id: '1',
        subject: 'English Language',
        topic: 'Comprehension',
        dateTime: DateTime.now().add(const Duration(days: 1)),
        duration: 30,
        totalQuestions: 20,
        icon: Icons.language,
        color: Colors.blue,
      ),
      UpcomingQuiz(
        id: '2',
        subject: 'Basic Science',
        topic: 'Living Things',
        dateTime: DateTime.now().add(const Duration(days: 3)),
        duration: 45,
        totalQuestions: 25,
        icon: Icons.science,
        color: Colors.green,
      ),
      UpcomingQuiz(
        id: '3',
        subject: 'Mathematics',
        topic: 'Fractions',
        dateTime: DateTime.now().add(const Duration(days: 7)),
        duration: 60,
        totalQuestions: 30,
        icon: Icons.calculate,
        color: Colors.purple,
      ),
    ];
  }

  // Get recommended courses based on user info - COMPLETED
  static List<RecommendedCourse> getRecommendedCourses(
    String educationCategory,
    int classGrade,
  ) {
    return [
      RecommendedCourse(
        id: '1',
        title: educationCategory == 'Basic Education'
            ? 'English Studies'
            : 'English Language',
        description: 'Reading & Comprehension',
        icon: Icons.language,
        color: Colors.blue,
        level: 'Beginner',
        lessons: 12,
        progress: 0.3,
      ),
      RecommendedCourse(
        id: '2',
        title: educationCategory == 'Basic Education'
            ? 'Mathematics'
            : 'Further Maths',
        description: 'Numbers & Operations',
        icon: Icons.calculate,
        color: Colors.purple,
        level: 'Intermediate',
        lessons: 15,
        progress: 0.1,
      ),
      RecommendedCourse(
        id: '3',
        title: educationCategory == 'Basic Education'
            ? 'Basic Science'
            : 'Physics',
        description: 'Science & Discovery',
        icon: Icons.science,
        color: Colors.green,
        level: 'Beginner',
        lessons: 10,
        progress: 0.0,
      ),
      RecommendedCourse(
        id: '4',
        title: 'Social Studies',
        description: 'Culture & Society',
        icon: Icons.public,
        color: Colors.orange,
        level: 'Beginner',
        lessons: 8,
        progress: 0.5,
      ),
    ];
  }
}
