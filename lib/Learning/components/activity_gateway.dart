// lib/Screens/activity/activity_gateway_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:isapp/Learning/components/exam_screen.dart';
import 'package:isapp/Learning/components/note_reading.dart';
import 'package:isapp/Learning/components/project_work_screen.dart';
import 'package:isapp/Learning/components/quiz_screen.dart';
import 'package:isapp/Learning/controllers/scholon_curriculum_planner_adapter.dart';
import 'package:isapp/Learning/study_planner_screen.dart';
import 'package:isapp/Models/planner_models.dart';

class ActivityGatewayScreen extends StatelessWidget {
  final DailyActivity activity;
  final AdaptedCourse? course;

  const ActivityGatewayScreen({
    Key? key,
    required this.activity,
    this.course,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final metadata = activity.metadata;
    final courseName = course?.name ?? metadata['courseName'] ?? 'Course';
    final courseCode = activity.courseCodes.isNotEmpty 
        ? activity.courseCodes.first 
        : metadata['courseCode'] ?? '';

    return Scaffold(
      backgroundColor: Color(0xFFF8FAFF),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.arrow_back, color: Colors.grey[700]),
                ),
                
                SizedBox(height: 20),
                
                // Header
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _getActivityGradient(activity.type),
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: _getActivityGradient(activity.type)[0]
                              .withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        _getActivityIcon(activity.type),
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: 30),
                
                // Course badge
                Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _getCourseColor(courseCode).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      courseCode,
                      style: TextStyle(
                        color: _getCourseColor(courseCode),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: 15),
                
                // Title
                Center(
                  child: Text(
                    activity.title,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                SizedBox(height: 10),
                
                // Activity type badge
                Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getActivityColor(activity.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getActivityTypeText(activity.type).toUpperCase(),
                      style: TextStyle(
                        color: _getActivityColor(activity.type),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: 30),
                
                // Instructions Section
                Container(
                  padding: EdgeInsets.all(20),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📋 Activity Instructions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      
                      SizedBox(height: 15),
                      
                      _buildInstructionItem(
                        icon: Icons.timer,
                        title: 'Estimated Duration',
                        value: '${activity.estimatedDuration.inMinutes} minutes',
                        color: Colors.blue,
                      ),
                      
                      SizedBox(height: 12),
                      
                      _buildInstructionItem(
                        icon: Icons.school,
                        title: 'Course',
                        value: courseName,
                        color: Colors.green,
                      ),
                      
                      if (metadata.containsKey('difficulty'))
                        SizedBox(height: 12),
                      
                      if (metadata.containsKey('difficulty'))
                        _buildInstructionItem(
                          icon: Icons.speed,
                          title: 'Difficulty',
                          value: metadata['difficulty'].toString(),
                          color: Colors.orange,
                        ),
                      
                      SizedBox(height: 12),
                      
                      if (activity.type == ActivityType.dailyQuiz ||
                          activity.type == ActivityType.weeklyMockTest)
                        _buildInstructionItem(
                          icon: Icons.quiz,
                          title: 'Format',
                          value: metadata['quizType']?.toString() ?? 'Multiple Choice',
                          color: Colors.purple,
                        ),
                      
                      SizedBox(height: 20),
                      
                      Divider(color: Colors.grey[200]),
                      
                      SizedBox(height: 15),
                      
                      Text(
                        '📝 What to Expect',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      
                      SizedBox(height: 10),
                      
                      ..._getActivityExpectations(activity).map((expectation) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.check_circle, size: 16, color: Colors.green),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                expectation,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                      
                      SizedBox(height: 20),
                      
                      if (metadata.containsKey('keyConcepts'))
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '🎯 Key Concepts',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            
                            SizedBox(height: 10),
                            
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: (metadata['keyConcepts'] as List<dynamic>?)
                                  ?.map<Widget>((concept) => Chip(
                                    label: Text(
                                      concept.toString(),
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    backgroundColor: Colors.blue.shade50,
                                    labelStyle: TextStyle(color: Colors.blue),
                                  ))
                                  .toList() ?? [],
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                
                SizedBox(height: 30),
                
                // Important Notes
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info, color: Colors.orange),
                          SizedBox(width: 8),
                          Text(
                            'Important Information',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange.shade800,
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 10),
                      
                      Text(
                        _getImportantNote(activity),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.orange.shade700,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 40),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                        child: Text(
                          'Back',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                    ),
                    
                    SizedBox(width: 16),
                    
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _startActivity(activity),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _getActivityColor(activity.type),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 0,
                          shadowColor: _getActivityColor(activity.type)
                              .withOpacity(0.3),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Start Now',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Icon(icon, size: 20, color: color),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<String> _getActivityExpectations(DailyActivity activity) {
    switch (activity.type) {
      case ActivityType.dailyLesson:
        return [
          'Read and understand the study material',
          'Take notes on key concepts',
          'Review examples and practice problems',
          'Complete the learning objectives',
        ];
      case ActivityType.dailyQuiz:
        return [
          'Multiple choice questions based on the lesson',
          'Timed assessment to test understanding',
          'Immediate feedback on answers',
          'Review explanations for correct answers',
        ];
      case ActivityType.weeklyMockTest:
        return [
          'Comprehensive test covering weekly topics',
          'Mix of question types',
          'Time-limited assessment',
          'Detailed performance analysis',
        ];
      case ActivityType.monthlyExam:
        return [
          'Full exam covering monthly curriculum',
          'Strict time limits enforced',
          'Comprehensive grading',
          'Performance tracking and analytics',
        ];
      case ActivityType.practiceSession:
        return [
          'Hands-on practice problems',
          'Step-by-step solutions',
          'Progress tracking',
          'Difficulty progression',
        ];
      case ActivityType.projectWork:
        return [
          'Real-world application project',
          'Research and development',
          'Submission requirements',
          'Grading rubric applied',
        ];
      default:
        return [
          'Complete all required sections',
          'Follow the provided instructions',
          'Submit before deadline',
          'Review your work before submission',
        ];
    }
  }

  String _getImportantNote(DailyActivity activity) {
    switch (activity.type) {
      case ActivityType.dailyQuiz:
      case ActivityType.weeklyMockTest:
      case ActivityType.monthlyExam:
        return 'Once started, you cannot pause or cancel this assessment. '
            'Your answers will be automatically submitted when time expires. '
            'Ensure you have a stable internet connection.';
      default:
        return 'Make sure to complete all sections before submitting. '
            'Your progress is automatically saved as you work. '
            'You can return to this activity later if needed.';
    }
  }

  void _startActivity(DailyActivity activity) {
    // Navigate to appropriate screen based on activity type
    switch (activity.type) {
      case ActivityType.dailyLesson:
        Get.to(() => NoteReadingScreen(activity: activity));
        break;
      case ActivityType.dailyQuiz:
      case ActivityType.weeklyMockTest:
        Get.to(() => QuizScreen(activity: activity));
        break;
      case ActivityType.monthlyExam:
        Get.to(() => ExamScreen(activity: activity));
        break;
      case ActivityType.practiceSession:
        Get.to(() => PracticeSessionScreen(activity: activity));
        break;
      case ActivityType.projectWork:
        Get.to(() => ProjectWorkScreen(activity: activity));
        break;
      default:
        Get.to(() => GenericActivityScreen(activity: activity));
    }
  }

  // Helper methods for UI
  List<Color> _getActivityGradient(ActivityType type) {
    return switch (type) {
      ActivityType.dailyLesson => [Color(0xFF667EEA), Color(0xFF764BA2)],
      ActivityType.dailyQuiz => [Color(0xFF11998E), Color(0xFF38EF7D)],
      ActivityType.weeklyMockTest => [Color(0xFFFF416C), Color(0xFFFF4B2B)],
      ActivityType.monthlyExam => [Color(0xFF9C27B0), Color(0xFF673AB7)],
      ActivityType.practiceSession => [Color(0xFFFF9800), Color(0xFFFF5722)],
      ActivityType.projectWork => [Color(0xFF4CAF50), Color(0xFF2196F3)],
      _ => [Color(0xFF607D8B), Color(0xFF455A64)],
    };
  }

  IconData _getActivityIcon(ActivityType type) {
    return switch (type) {
      ActivityType.dailyLesson => Icons.menu_book,
      ActivityType.dailyQuiz => Icons.quiz,
      ActivityType.weeklyMockTest => Icons.assignment,
      ActivityType.monthlyExam => Icons.assignment_turned_in,
      ActivityType.practiceSession => Icons.repeat,
      ActivityType.projectWork => Icons.work,
      ActivityType.researchWork => Icons.search,
      ActivityType.experimentLab => Icons.science,
      _ => Icons.school,
    };
  }

  Color _getActivityColor(ActivityType type) {
    return switch (type) {
      ActivityType.dailyLesson => Color(0xFF667EEA),
      ActivityType.dailyQuiz => Color(0xFF11998E),
      ActivityType.weeklyMockTest => Color(0xFFFF416C),
      ActivityType.monthlyExam => Color(0xFF9C27B0),
      ActivityType.practiceSession => Color(0xFFFF9800),
      ActivityType.projectWork => Color(0xFF4CAF50),
      _ => Color(0xFF607D8B),
    };
  }

  String _getActivityTypeText(ActivityType type) {
    return switch (type) {
      ActivityType.dailyLesson => 'Lesson',
      ActivityType.dailyQuiz => 'Quiz',
      ActivityType.weeklyMockTest => 'Mock Test',
      ActivityType.monthlyExam => 'Exam',
      ActivityType.practiceSession => 'Practice',
      ActivityType.projectWork => 'Project',
      ActivityType.revisionSession => 'Revision',
      ActivityType.readingSession => 'Reading',
      ActivityType.researchWork => 'Research',
      ActivityType.problemSolving => 'Problem Solving',
      ActivityType.experimentLab => 'Lab',
      ActivityType.groupDiscussion => 'Discussion',
    };
  }

  Color _getCourseColor(String courseCode) {
    final colors = {
      'MAT': Color(0xFF667EEA),
      'PHY': Color(0xFF11998E),
      'CHE': Color(0xFF38EF7D),
      'BIO': Color(0xFFFF416C),
      'ENG': Color(0xFFFF4B2B),
      'ECO': Color(0xFF9C27B0),
      'COM': Color(0xFF2196F3),
      'PHL': Color(0xFFFF9800),
      'ART': Color(0xFF795548),
      'ENT': Color(0xFF4CAF50),
    };
    return colors[courseCode] ?? Colors.blue;
  }
}