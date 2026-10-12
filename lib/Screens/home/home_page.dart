import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:isapp/Learning/study_planner_screen.dart';
import 'package:isapp/Models/user.dart';
import 'package:isapp/Models/courses.dart';
import 'package:isapp/Screens/Profile/profile_page.dart';
import 'package:isapp/Screens/authentication/controllers/authentication_controller.dart';
import 'package:isapp/Screens/classroom/classroom.dart';
import 'package:isapp/Screens/home/animated_play_button.dart';
import 'package:isapp/Screens/home/fullscreen/course_card.dart';
import 'package:isapp/Screens/home/tutorials.dart';
import 'package:isapp/Screens/home/youtube_player.dart';
import 'package:isapp/Utils/library/course_logic.dart';
import 'package:isapp/Utils/library/new_courses.dart';

class UpcomingQuiz {
  final String id;
  final String subject;
  final String topic;
  final DateTime dateTime;
  final int duration; // in minutes
  final int totalQuestions;
  final IconData icon;
  final Color color;
  final String? description;
  final String? activityType;
  final String? courseCode;

  UpcomingQuiz({
    required this.id,
    required this.subject,
    required this.topic,
    required this.dateTime,
    required this.duration,
    required this.totalQuestions,
    required this.icon,
    required this.color,
    this.description,
    this.activityType,
    this.courseCode,
  });

  String get formattedDate {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.inDays == 0) return 'Today, ${_formatTime(dateTime)}';
    if (difference.inDays == 1) return 'Tomorrow, ${_formatTime(dateTime)}';

    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    if (difference.inDays <= 7)
      return '${weekdays[dateTime.weekday - 1]}, ${_formatTime(dateTime)}';

    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class RecommendedCourse {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String level;
  final int lessons;
  final double progress;
  final String? courseCode;
  final String? subject;
  final int totalActivities;
  final int completedActivities;

  RecommendedCourse({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.level,
    required this.lessons,
    required this.progress,
    this.courseCode,
    this.subject,
    this.totalActivities = 0,
    this.completedActivities = 0,
  });
}

class CourseProgress {
  final String courseCode;
  int totalActivities;
  int completedActivities;
  double totalProgress;

  CourseProgress({
    required this.courseCode,
    required this.totalActivities,
    required this.completedActivities,
    required this.totalProgress,
  });
}

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

// ============================
// DATA MODELS
// ============================

class GameDetail {
  final String emojiImage;
  final String description;
  final Color color;
  final String image;
  final String name;
  final String instructor;
  final int time;
  final String route;

  GameDetail({
    required this.emojiImage,
    required this.description,
    required this.color,
    required this.image,
    required this.name,
    required this.instructor,
    required this.time,
    required this.route,
  });
}

// ============================
// FULLSCREEN CARD SCREENS (Based on original navigation)
// ============================

class FullScreenToolsCard extends StatelessWidget {
  final List<Map<String, String>> toolItems;

  const FullScreenToolsCard({Key? key, required this.toolItems})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tools')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: toolItems.length,
        itemBuilder: (context, index) {
          final item = toolItems[index];
          return Card(
            child: ListTile(
              title: Text(item['title']!),
              subtitle: item['subtitle'] != null
                  ? Text(item['subtitle']!)
                  : null,
              onTap: () {
                // Handle tool navigation
              },
            ),
          );
        },
      ),
    );
  }
}

class FullScreenGamesCard extends StatelessWidget {
  final List<GameDetail> gameItems;

  const FullScreenGamesCard({Key? key, required this.gameItems})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Educational Games')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: gameItems.length,
        itemBuilder: (context, index) {
          final game = gameItems[index];
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              onTap: () {
                // Navigate to game details
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(game.image, width: 60, height: 60),
                    const SizedBox(height: 12),
                    Text(
                      game.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      game.description,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================
// MAIN HOME SCREEN
// ============================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = Get.find<AuthService>();
  StudentUser? _currentUser;
  bool _isLoading = true;

  // Data from services
  late List<CourseCategories> _courses;
  late List<CourseCategories> _quizzes;
  late List<CourseCategories> _exams;
  late List<GameDetail> _games;
  late List<Map<String, String>> _tools;
  late List<UpcomingQuiz> _upcomingQuizzes;
  late List<RecommendedCourse> _recommendedCourses;

  List<Tutorial> tutorials = [];

  // Dynamic data
  Map<String, dynamic> _learningStats = {};
  List<Map<String, dynamic>> _todaysStudyItems = [];

  int _currentNavIndex = 0;
  bool _fabExpanded = false;
  final PageController _pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    _initializeData();
    _loadUserData();
    loadTutorials();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _initializeData() {
    _courses = HomeDataService.parseCourseCategoriesJson();
    _quizzes = HomeDataService.parseQuizCategoriesJson();
    _exams = HomeDataService.parseExamCategoriesJson();
    _games = HomeDataService.getGames();
    _tools = HomeDataService.getTools();
    _upcomingQuizzes = HomeDataService.getUpcomingQuizzes();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    try {
      final user = await _authService.getCurrentUser();

      if (!mounted) return;

      if (user != null && user is StudentUser) {
        setState(() {
          _currentUser = user;
        });

        // Load dynamic data
        await _loadDynamicData(user.uid);
      } else {
        Get.snackbar(
          'Error',
          'Invalid user type. Please login as a student.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        await _authService.signOut();
        Get.offAllNamed('/auth');
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadDynamicData(String studentId) async {
    try {
      // Load learning stats
      _learningStats = await HomeDataService.getStudentLearningStats(studentId);

      // Load today's study items
      _todaysStudyItems = await HomeDataService.getTodaysStudyItems(studentId);

      // Load upcoming quizzes
      _upcomingQuizzes = await HomeDataService.getUpcomingQuizzesFromPlan(
        studentId,
      );

      // Load recommended courses
      _recommendedCourses = await HomeDataService.getRecommendedCoursesFromPlan(
        studentId,
      );

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error loading dynamic data: $e');
    }
  }

  Future<void> loadTutorials() async {
    final data = await rootBundle.loadString('assets/tutorials.json');
    final List decoded = json.decode(data);
    setState(() {
      tutorials = decoded.map((e) => Tutorial.fromJson(e)).toList();
    });
  }

  // ====================
  // ORIGINAL NAVIGATIONS
  // ====================

  // Courses Navigation (from original BodyParts)
  void _navigateToCourses() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenCourseCard(categories: _courses),
      ),
    );
  }

  // Quizzes Navigation (from original BodyParts)
  void _navigateToQuizzes() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenQuizCard(categories: _quizzes),
      ),
    );
  }

  // Exams Navigation (from original BodyParts)
  void _navigateToExams() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenExamsCard(categories: _exams),
      ),
    );
  }

  // Tools Navigation (from original BodyParts)
  void _navigateToTools() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenToolsCard(toolItems: _tools),
      ),
    );
  }

  // Games Navigation (from original BodyParts)
  void _navigateToGames() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenGamesCard(gameItems: _games),
      ),
    );
  }

  void _navigateToCourseDetails(RecommendedCourse course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenCourseCard(categories: _courses),
      ),
    );

    Get.snackbar(
      'Browse Courses',
      'Explore "${course.title}" and more in the Courses section',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

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
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF4A44C6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.school, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 20),
            const Text(
              'Loading your learning journey...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: Colors.deepPurple),
          ],
        ),
      ),
    );
  }

  // ====================
  // PAGE VIEW CONTENT
  // ====================
  Widget _buildHomePageContent() {
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    if (_currentUser == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No user data found', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Get.offAllNamed('/auth'),
                child: const Text('Go to Login'),
              ),
            ],
          ),
        ),
      );
    }

    final studentName = _currentUser!.name.split(' ').first;
    final gradeLevel = _currentUser!.gradeLevel;
    final subscription = _currentUser!.currentSubscription;
    final hasActiveSubscription = _currentUser!.hasActiveSubscription;
    final isOnTrial = _currentUser!.isOnFreeTrial;
    final daysRemaining = _currentUser!.currentSubscription?.daysRemaining ?? 0;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome & User Info Section
          _buildStudentWelcomeSection(
            studentName,
            gradeLevel,
            _courses.length,
            _quizzes.length,
          ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),

          // Subscription Status Section
          _buildSubscriptionSection(
                hasActiveSubscription,
                isOnTrial,
                daysRemaining,
                subscription,
              )
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.1, end: 0, delay: 100.ms),

          // Quick Stats
          _buildQuickStatsSection()
              .animate()
              .fadeIn(duration: 500.ms)
              .slideY(begin: 0.1, end: 0, delay: 200.ms),

          // Continue Learning
          _buildContinueLearningSection()
              .animate()
              .fadeIn(duration: 600.ms)
              .slideY(begin: 0.1, end: 0, delay: 300.ms),

          // Today's Study Items (Updated)
          _buildTodaysStudySection()
              .animate()
              .fadeIn(duration: 700.ms)
              .slideY(begin: 0.1, end: 0, delay: 400.ms),

          // Upcoming Quizzes (Dynamic)
          _buildUpcomingQuizzesSection()
              .animate()
              .fadeIn(duration: 800.ms)
              .slideY(begin: 0.1, end: 0, delay: 500.ms),

          // Recommended Courses (Dynamic)
          _buildRecommendedCoursesSection()
              .animate()
              .fadeIn(duration: 800.ms)
              .slideY(begin: 0.1, end: 0, delay: 500.ms),

          // Quick Access Cards (Courses, Quizzes, Exams)
          _buildQuickAccessSection()
              .animate()
              .fadeIn(duration: 900.ms)
              .slideY(begin: 0.1, end: 0, delay: 600.ms),

          _buildVideoListCard()
              .animate()
              .fadeIn(duration: 1000.ms)
              .slideY(begin: 0.1, end: 0, delay: 700.ms),

          // Learning Tools
          _buildLearningToolsSection()
              .animate()
              .fadeIn(duration: 1100.ms)
              .slideY(begin: 0.1, end: 0, delay: 800.ms),

          // Educational Games
          _buildEducationalGamesSection()
              .animate()
              .fadeIn(duration: 1200.ms)
              .slideY(begin: 0.1, end: 0, delay: 900.ms),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _currentNavIndex == 0 ? _buildCustomAppBar() : null,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // Home Page (Index 0)
          _buildHomePageContent(),

          // Activities Page (Index 1)
          StudyPlannerScreen(),

          // Connect is handled by FAB (Index 2)

          // Explore Page (Index 3)
          ClassroomPage(),

          // Profile Page (Index 4)
          UniversalProfileScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  PreferredSizeWidget _buildCustomAppBar() {
    final studentName = _currentUser?.name.split(' ').first ?? 'Student';

    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                // App Logo
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF4A44C6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.school,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'iStudyApp',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Student Learning Platform',
                      style: TextStyle(fontSize: 9, color: Colors.grey),
                    ),
                  ],
                ),
                const Spacer(),

                // Notification & Profile
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.notifications_none,
                              size: 20,
                            ),
                            color: Colors.grey,
                            onPressed: () {},
                          ),
                          if (_upcomingQuizzes.isNotEmpty)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: _showStudentProfileMenu,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6C63FF), Color(0xFF4A44C6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6C63FF).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: _currentUser?.profileImageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  _currentUser!.profileImageUrl!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Center(
                                child: Text(
                                  studentName.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStudentWelcomeSection(
    String studentName,
    String gradeLevel,
    int totalCourses,
    int totalQuizzes,
  ) {
    final greeting = _getTimeBasedGreeting();

    // Get dynamic data
    final dailyGoalMinutes = _learningStats['dailyGoalMinutes'] as int? ?? 120;
    final examsCount = _learningStats['examsCount'] as int? ?? 0;
    final hours = dailyGoalMinutes ~/ 60;
    final minutes = dailyGoalMinutes % 60;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF4A44C6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Center(
                  child: Icon(Icons.school, color: Colors.white, size: 24),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greeting, $studentName! 👋',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Grade $gradeLevel • ${_currentUser?.schoolName ?? "No school"}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                height: 1.3,
              ),
              children: [
                const TextSpan(text: 'Ready to explore '),
                TextSpan(
                  text: '$totalCourses courses',
                  style: const TextStyle(color: Colors.deepPurple),
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: '$totalQuizzes quizzes',
                  style: const TextStyle(color: Colors.deepPurple),
                ),
                const TextSpan(text: ' today?'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timer, size: 14, color: Colors.amber.shade700),
                    const SizedBox(width: 6),
                    Text(
                      hours > 0
                          ? 'Daily Goal: ${hours}h ${minutes}m'
                          : 'Daily Goal: ${minutes}m',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.assignment_turned_in,
                      size: 14,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$examsCount exam${examsCount != 1 ? 's' : ''} preps',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionSection(
    bool hasActiveSubscription,
    bool isOnTrial,
    int daysRemaining,
    StudentSubscription? subscription,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: hasActiveSubscription
              ? [Colors.green.shade50, Colors.lightGreen.shade50]
              : [Colors.orange.shade50, Colors.orange.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasActiveSubscription
              ? Colors.green.shade200
              : Colors.orange.shade200,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasActiveSubscription ? 'Premium Access' : 'Subscription',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subscription?.studentPlanDescription ?? 'No Active Plan',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: hasActiveSubscription
                      ? Colors.green.withOpacity(0.2)
                      : Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: hasActiveSubscription
                        ? Colors.green.withOpacity(0.3)
                        : Colors.orange.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  hasActiveSubscription
                      ? isOnTrial
                            ? '$daysRemaining days left'
                            : 'Active'
                      : 'Expired',
                  style: TextStyle(
                    color: hasActiveSubscription ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          if (isOnTrial && daysRemaining > 0) ...[
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: (30 - daysRemaining) / 30,
              backgroundColor: Colors.grey[200],
              color: Colors.blue,
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$daysRemaining days left in trial',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextButton(
                  onPressed: _navigateToUpgrade,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                  ),
                  child: const Text(
                    'Upgrade Now →',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (!hasActiveSubscription) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _navigateToUpgrade,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.upgrade, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Upgrade to Premium',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickStatsSection() {
    final totalStudyMinutes = _learningStats['totalStudyMinutes'] as int? ?? 0;
    final avgScore = _learningStats['avgScore'] as double? ?? 0.0;
    final completedLessons = _learningStats['completedLessons'] as int? ?? 0;
    final enrolledCourses = _learningStats['enrolledCourses'] as int? ?? 0;
    final totalActivities = _learningStats['totalActivities'] as int? ?? 0;

    final hours = totalStudyMinutes ~/ 60;
    final minutes = totalStudyMinutes % 60;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Learning Stats',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.access_time,
                  value: hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m',
                  label: 'Study Time',
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.quiz,
                  value: '${avgScore.toInt()}%',
                  label: 'Avg Score',
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.check_circle,
                  value: '$completedLessons',
                  label: 'Lessons Done',
                  color: Colors.purple,
                  subtitle: 'of $totalActivities',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.library_books,
                  value: '$enrolledCourses',
                  label: 'Courses',
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          if (subtitle != null)
            Text(
              subtitle,
              style: TextStyle(fontSize: 10, color: Colors.grey[400]),
            ),
        ],
      ),
    );
  }

  Widget _buildContinueLearningSection() {
    final totalActivities = _learningStats['totalActivities'] as int? ?? 0;
    final completedLessons = _learningStats['completedLessons'] as int? ?? 0;
    final progress = totalActivities > 0
        ? completedLessons / totalActivities
        : 0.0;
    final enrolledCourses = _learningStats['enrolledCourses'] as int? ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Continue Learning',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: _navigateToCourses,
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _navigateToCourses,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple.shade50, Colors.purple.shade50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.deepPurple.shade100),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.library_books,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          enrolledCourses > 0
                              ? 'Continue Your Journey'
                              : 'Start Learning Today',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          enrolledCourses > 0
                              ? '$completedLessons of $totalActivities activities completed'
                              : '${_courses.length} courses available',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey[300],
                          color: Colors.deepPurple,
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${(progress * 100).toInt()}% Complete',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              enrolledCourses > 0
                                  ? '$enrolledCourses courses'
                                  : 'Start Now →',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoListCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Video Lessons',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: tutorials.length,
              itemBuilder: (context, index) {
                final tutorial = tutorials[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            VideoPlayerPage(videoUrl: tutorial.videoUrl),
                      ),
                    );
                  },
                  child: Container(
                    width: 280,
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue[800]!, Colors.purple[800]!],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  tutorial.thumbnail,
                                  height: 100,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const AnimatedPlayButton(),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            tutorial.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            tutorial.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaysStudySection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Today's Study Plan",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  '${_todaysStudyItems.length} activities',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_todaysStudyItems.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  for (int i = 0; i < _todaysStudyItems.length && i < 3; i++)
                    Column(
                      children: [
                        if (i > 0) const Divider(height: 24),
                        _buildStudyItem(_todaysStudyItems[i]),
                      ],
                    ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 40,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No activities scheduled for today',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Visit the Study Planner to create your schedule',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStudyItem(Map<String, dynamic> item) {
    final icon = item['icon'] as IconData? ?? Icons.school;
    final color = item['color'] as Color? ?? Colors.blue;
    final isCompleted = item['isCompleted'] as bool? ?? false;
    final progress = (item['progress'] as num?)?.toDouble() ?? 0.0;

    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['title']?.toString() ?? 'Activity',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item['description']?.toString() ?? '',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.access_time, size: 12, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    '${item['duration'] ?? 30} min',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  const SizedBox(width: 12),
                  if (item['courseName'] != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item['courseName']?.toString() ?? '',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (isCompleted)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check, size: 12, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            else
              OutlinedButton(
                onPressed: () {
                  // Navigate to activity
                  Get.to(() => StudyPlannerScreen());
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  side: BorderSide(color: Colors.deepPurple.shade200),
                ),
                child: const Text(
                  'Start',
                  style: TextStyle(fontSize: 12, color: Colors.deepPurple),
                ),
              ),
            if (!isCompleted)
              SizedBox(
                width: 60,
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[200],
                  color: Colors.deepPurple,
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildUpcomingQuizzesSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Upcoming Quizzes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: _navigateToQuizzes,
                child: const Text(
                  'View Schedule',
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_upcomingQuizzes.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  for (int i = 0; i < _upcomingQuizzes.length && i < 3; i++)
                    Column(
                      children: [
                        if (i > 0) const Divider(height: 24),
                        _buildQuizItem(_upcomingQuizzes[i]),
                      ],
                    ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Icon(Icons.quiz, size: 40, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  const Text(
                    'No upcoming quizzes',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Check back later for scheduled quizzes',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuizItem(UpcomingQuiz quiz) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: quiz.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(quiz.icon, color: quiz.color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                quiz.subject,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                quiz.topic,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.access_time, size: 12, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    '${quiz.duration} min • ${quiz.totalQuestions} questions',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              quiz.formattedDate,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 4),
            OutlinedButton(
              onPressed: () => _navigateToQuizzes(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                side: BorderSide(color: Colors.deepPurple.shade200),
              ),
              child: const Text(
                'Prepare',
                style: TextStyle(fontSize: 12, color: Colors.deepPurple),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecommendedCoursesSection() {
    final studentGrade = _currentUser?.classGrade ?? 1;
    final String? grade = _currentUser!.educationCategory;
    String parsedGrade = 'Primary';

    if (grade == 'Senior Secondary Education') {
      parsedGrade = 'SS';
    } else {
      parsedGrade = 'Primary';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recommended For $parsedGrade $studentGrade',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          if (_recommendedCourses.isNotEmpty)
            SizedBox(
              height: 260,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (var course in _recommendedCourses.take(4))
                    Padding(
                      padding: EdgeInsets.only(
                        right: course != _recommendedCourses.last ? 12 : 0,
                      ),
                      child: _buildCourseCard(course),
                    ),
                ],
              ),
            )
          else
            SizedBox(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.school, size: 50, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Text(
                      'No courses available',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Visit the Study Planner to create your schedule',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(RecommendedCourse course) {
    final progressPercent = (course.progress * 100).toInt();

    return GestureDetector(
      onTap: () => _navigateToCourseDetails(course),
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: course.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(course.icon, color: course.color, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              course.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              course.description,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            if (course.totalActivities > 0)
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$progressPercent%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.deepPurple,
                        ),
                      ),
                      Text(
                        '${course.completedActivities}/${course.totalActivities}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: course.progress,
                    backgroundColor: Colors.grey[200],
                    color: course.color,
                    minHeight: 4,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ElevatedButton(
              onPressed: () => _navigateToCourseDetails(course),
              style: ElevatedButton.styleFrom(
                backgroundColor: course.color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: course.progress > 0
                  ? const Text('Continue')
                  : const Text('Start Learning'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Access',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickAccessCard(
                  title: 'Courses',
                  subtitle: '${_courses.length} available',
                  icon: Icons.library_books,
                  color: Colors.blue,
                  onTap: _navigateToCourses,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickAccessCard(
                  title: 'Quizzes',
                  subtitle: '${_quizzes.length} available',
                  icon: Icons.quiz,
                  color: Colors.green,
                  onTap: _navigateToQuizzes,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickAccessCard(
                  title: 'Exams',
                  subtitle: '${_exams.length} available',
                  icon: Icons.assignment,
                  color: Colors.purple,
                  onTap: _navigateToExams,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickAccessCard(
                  title: 'Tools',
                  subtitle: '${_tools.length} available',
                  icon: Icons.build,
                  color: Colors.orange,
                  onTap: _navigateToTools,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
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
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLearningToolsSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tools',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: _navigateToTools,
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (var tool in _tools.take(4))
                  Padding(
                    padding: EdgeInsets.only(
                      right: tool != _tools.last ? 12 : 0,
                    ),
                    child: _buildToolCard(tool),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolCard(Map<String, String> tool) {
    // Parse color from string
    final color = Color(int.parse(tool['color']!));
    final iconName = tool['icon']!;
    final route = tool['route'] ?? '/not-found'; // Get route or default

    // Map icon names to IconData
    final iconMap = {
      'person': Icons.person,
      'security': Icons.security,
      'assessment': Icons.assessment,
      'note_add': Icons.note_add,
      'settings': Icons.settings,
      'lock': Icons.lock,
      'bar_chart': Icons.bar_chart,
      'edit_note': Icons.edit_note,
      'library_books': Icons.library_books,
      'calendar_today': Icons.calendar_today,
    };

    return GestureDetector(
      onTap: () {
        // Handle tool specific navigation
        if (tool['route'] != null) {
          Get.toNamed(tool['route']!); // Navigate to specific route
        }
      },
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                iconMap[iconName] ?? Icons.help_outline,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              tool['title']!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            if (tool['subtitle'] != null) ...[
              const SizedBox(height: 4),
              Text(
                tool['subtitle']!,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEducationalGamesSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Games',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: _navigateToGames,
                child: const Text(
                  'Play All',
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 160,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (var game in _games.take(3))
                  Padding(
                    padding: EdgeInsets.only(
                      right: game != _games.last ? 12 : 0,
                    ),
                    child: _buildGameCard(game),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard(GameDetail game) {
    return GestureDetector(
      onTap: () => Get.toNamed(game.route), // Use Get.toNamed for navigation
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: game.color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: game.color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: game.color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(game.image, width: 40, height: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    game.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              game.description,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => Get.toNamed(game.route), // Use Get.toNamed
              style: ElevatedButton.styleFrom(
                backgroundColor: game.color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(double.infinity, 36),
              ),
              child: const Text('Play Now'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 25,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Stack(
        alignment: AlignmentDirectional.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // Bottom Navigation Bar
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 25,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(25),
              ),
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(25),
                  ),
                  border: Border.all(color: Colors.grey.shade200, width: 0.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Home
                    _buildNavItem(
                      index: 0,
                      icon: Icons.home_rounded,
                      label: 'Home',
                      isActive: _currentNavIndex == 0,
                    ),

                    // Activities
                    _buildNavItem(
                      index: 1,
                      icon: Icons.local_activity_rounded,
                      label: 'Planner',
                      isActive: _currentNavIndex == 1,
                    ),

                    // Spacer for FAB
                    const SizedBox(width: 60),

                    // Explore
                    _buildNavItem(
                      index: 2,
                      icon: Icons.school_rounded,
                      label: 'Classroom',
                      isActive: _currentNavIndex == 2,
                    ),

                    // Profile
                    _buildNavItem(
                      index: 4,
                      icon: Icons.person_rounded,
                      label: 'Profile',
                      isActive: _currentNavIndex == 4,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Floating Action Button for Connect
          Positioned(
            left: MediaQuery.of(context).size.width / 2 - 30,
            bottom: 25,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _fabExpanded = !_fabExpanded;
                });
                // Navigate to Connect page after animation
                Future.delayed(300.ms, () {
                  Get.toNamed('/connect');
                });
              },
              child: AnimatedContainer(
                duration: 300.ms,
                curve: Curves.easeInOut,
                width: _fabExpanded ? 140 : 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _currentNavIndex == 2
                        ? [Colors.deepPurple, Colors.purple]
                        : [Colors.deepPurple.shade400, Colors.purple.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(_fabExpanded ? 20 : 30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(
                        _fabExpanded ? 0.4 : 0.3,
                      ),
                      blurRadius: _fabExpanded ? 20 : 15,
                      spreadRadius: _fabExpanded ? 1 : 0,
                      offset: Offset(0, _fabExpanded ? 8 : 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _fabExpanded
                        ? AnimatedOpacity(
                            duration: 200.ms,
                            opacity: _fabExpanded ? 1 : 0,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 16,
                                right: 8,
                              ),
                              child:
                                  Text(
                                    'Connect',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ).animate().slideX(
                                    begin: -0.2,
                                    end: 0,
                                    duration: 200.ms,
                                    curve: Curves.easeOut,
                                  ),
                            ),
                          )
                        : Container(),
                    Icon(
                      Icons.connect_without_contact_rounded,
                      color: Colors.white,
                      size: 24,
                    ).animate().rotate(
                      duration: 300.ms,
                      curve: Curves.easeInOut,
                      begin: _fabExpanded ? 0 : -0.5,
                      end: _fabExpanded ? 0.5 : 0,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentNavIndex = index;
          _pageController.jumpToPage(index);
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.deepPurple.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child:
                  Icon(
                    icon,
                    size: 30,
                    color: isActive ? Colors.deepPurple : Colors.grey.shade600,
                  ).animate(delay: 100.ms * index)..scale(
                    duration: 200.ms,
                    begin: isActive ? Offset(0.8, 0.8) : Offset(1, 1),
                    end: Offset(1, 1),
                    curve: Curves.elasticOut,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive ? Colors.deepPurple : Colors.grey.shade600,
                  ),
                )
                .animate(delay: 150.ms * index)
                .fadeIn(duration: 300.ms, curve: Curves.easeOut),
          ],
        ),
      ),
    );
  }

  void _showStudentProfileMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF4A44C6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      _currentUser?.name
                              .split(' ')
                              .map((s) => s[0])
                              .take(2)
                              .join()
                              .toUpperCase() ??
                          'S',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _currentUser?.name ?? 'Student',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_currentUser?.schoolName != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _currentUser!.schoolName!,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
                if (_currentUser?.classGrade != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${_currentUser!.gradeLevel}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
                if (_currentUser?.parentName != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Parent: ${_currentUser!.parentName!}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
                const SizedBox(height: 20),
                _buildMenuOption(
                  icon: Icons.person,
                  title: 'My Profile',
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _currentNavIndex = 4;
                      _pageController.jumpToPage(4);
                    });
                  },
                ),
                _buildMenuOption(
                  icon: Icons.bar_chart,
                  title: 'Progress Report',
                  onTap: () {
                    Navigator.pop(context);
                    Get.toNamed('/progress');
                  },
                ),
                _buildMenuOption(
                  icon: Icons.assignment,
                  title: 'My Assignments',
                  onTap: () {
                    Navigator.pop(context);
                    Get.toNamed('/assignments');
                  },
                ),
                _buildMenuOption(
                  icon: Icons.school,
                  title: 'My Courses',
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToCourses();
                  },
                ),
                _buildMenuOption(
                  icon: Icons.settings,
                  title: 'Settings',
                  onTap: () {
                    Navigator.pop(context);
                    Get.toNamed('/settings');
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      await _authService.signOut();
                      Get.offAllNamed('/auth');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text('Sign Out'),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.grey[700]),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
    );
  }

  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  void _navigateToUpgrade() {
    Get.toNamed('/subscription-plans');
  }
}
