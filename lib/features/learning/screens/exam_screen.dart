import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:isapp/features/study_guide/study_guide.dart';

export 'package:isapp/features/learning/screens/generic_activity_screen.dart';
export 'package:isapp/features/learning/screens/practice_session_screen.dart';

// ======================= EXAM SCREEN =======================
class ExamScreen extends StatefulWidget {
  final DailyActivity activity;

  const ExamScreen({Key? key, required this.activity}) : super(key: key);

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  late Timer _timer;
  int _timeRemaining = 0;
  bool _isCompleted = false;
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _timeRemaining = widget.activity.metadata['duration'] as int? ?? 120 * 60; // 2 hours default
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0 && !_isCompleted) {
        setState(() {
          _timeRemaining--;
        });
      } else {
        timer.cancel();
        if (!_isCompleted) {
          _submitExam();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFF),
      body: SafeArea(
        child: Column(
          children: [
            // Exam Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _showExitConfirmation,
                    icon: Icon(Icons.arrow_back, color: Colors.grey[700]),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.activity.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Monthly Examination',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _timeRemaining < 300 
                          ? Colors.red.shade50 
                          : Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: _timeRemaining < 300 
                            ? Colors.red.shade100 
                            : Colors.purple.shade100,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.timer,
                          size: 14,
                          color: _timeRemaining < 300 ? Colors.red : Colors.purple,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '${_timeRemaining ~/ 60}:${(_timeRemaining % 60).toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _timeRemaining < 300 ? Colors.red : Colors.purple,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Exam Content
            Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.assignment_turned_in,
                        size: 80,
                        color: Colors.purple.shade300,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Exam in Progress',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'This is a comprehensive monthly examination.\n'
                        'Complete all sections before time expires.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 30),
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade50,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.purple.shade100),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '⚠️ Important Notice',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.purple.shade800,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Once started, you cannot pause or exit this exam.\n'
                              'Your work will be automatically submitted when time expires.\n'
                              'Ensure you have a stable internet connection.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.purple.shade700,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Submit Button
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey[200]!)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _submitExam,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.send, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'Submit Exam',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitExam() {
    _timer.cancel();
    setState(() {
      _isCompleted = true;
    });
    
    // Calculate score (simulated)
    final endTime = DateTime.now();
    final duration = endTime.difference(_startTime!);
    final timeUsedPercentage = (duration.inSeconds / (_timeRemaining + duration.inSeconds)) * 100;
    final simulatedScore = (70 + (100 - timeUsedPercentage) * 0.3).clamp(50, 100);
    
    _showResults(simulatedScore.toDouble());
  }

  void _showResults(double score) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Column(
          children: [
            Icon(Icons.analytics, size: 60, color: Colors.purple),
            SizedBox(height: 15),
            Text(
              'Exam Submitted',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.purple, width: 3),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${score.toInt()}%',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                    Text(
                      'Score',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Your exam has been submitted successfully.\n'
              'Detailed results will be available after grading.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              _completeExam(score);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
            ),
            child: Text('Finish'),
          ),
        ],
      ),
    );
  }

  void _completeExam(double score) {
    // Mark activity as complete in Firebase
    final firebaseService = StudyPlannerFirebaseService();
    firebaseService.markActivityComplete(
      studentId: 'current_user_id', // Get from auth
      activityId: widget.activity.id,
      score: score,
    );
    
    // Navigate back
    Get.back(); // Close results
    Get.back(); // Close exam
    
    // Show success message
    Get.snackbar(
      '📊 Exam Completed!',
      'Your exam has been submitted for grading.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.purple,
      colorText: Colors.white,
      duration: Duration(seconds: 3),
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Exit Exam?'),
        content: Text(
          'Exiting now will automatically submit your exam with completed sections only. '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _submitExam();
            },
            child: Text('Submit & Exit', style: TextStyle(color: Colors.purple)),
          ),
        ],
      ),
    );
  }
}
