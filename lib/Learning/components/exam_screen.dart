// lib/Screens/activity/other_activity_screens.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:isapp/Learning/study_planner_screen.dart';
import 'package:isapp/Models/planner_models.dart';

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

// ======================= PRACTICE SESSION SCREEN =======================
class PracticeSessionScreen extends StatefulWidget {
  final DailyActivity activity;

  const PracticeSessionScreen({Key? key, required this.activity}) : super(key: key);

  @override
  State<PracticeSessionScreen> createState() => _PracticeSessionScreenState();
}

class _PracticeSessionScreenState extends State<PracticeSessionScreen> {
  int _currentProblem = 0;
  List<bool> _completedProblems = [];
  List<String> _userSolutions = [];
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    // Initialize with 10 practice problems
    _completedProblems = List.generate(10, (index) => false);
    _userSolutions = List.generate(10, (index) => '');
  }

  @override
  Widget build(BuildContext context) {
    final totalProblems = _completedProblems.length;
    
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFF),
      body: SafeArea(
        child: Column(
          children: [
            // Header
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
                    onPressed: () => Get.back(),
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
                        LinearProgressIndicator(
                          value: _progress,
                          backgroundColor: Colors.grey[200],
                          color: Colors.orange,
                          minHeight: 4,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.orange.shade100),
                    ),
                    child: Text(
                      'Problem ${_currentProblem + 1}/$totalProblems',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Problem Area
            Expanded(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Problem ${_currentProblem + 1}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      _getProblemText(_currentProblem),
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[800],
                        height: 1.6,
                      ),
                    ),
                    SizedBox(height: 30),
                    
                    // Solution Input
                    Text(
                      'Your Solution:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      height: 150,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: TextField(
                        controller: TextEditingController(
                          text: _userSolutions[_currentProblem],
                        ),
                        onChanged: (value) {
                          _userSolutions[_currentProblem] = value;
                        },
                        maxLines: null,
                        expands: true,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Type your solution here...',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    
                    // Solution Steps (if completed)
                    if (_completedProblems[_currentProblem])
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.green.shade100),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.check_circle, size: 16, color: Colors.green),
                                SizedBox(width: 8),
                                Text(
                                  'Solution Steps',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green.shade800,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Text(
                              _getSolutionSteps(_currentProblem),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
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

            // Actions
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
              child: Row(
                children: [
                  // Previous
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _currentProblem > 0
                          ? () => setState(() {
                                _currentProblem--;
                              })
                          : null,
                      icon: Icon(Icons.arrow_back, size: 18),
                      label: Text('Previous'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(width: 12),
                  
                  // Check/Next
                  Expanded(
                    child: _completedProblems[_currentProblem]
                        ? ElevatedButton.icon(
                            onPressed: _currentProblem < totalProblems - 1
                                ? () => setState(() {
                                      _currentProblem++;
                                    })
                                : _completeSession,
                            icon: Icon(
                              _currentProblem < totalProblems - 1
                                  ? Icons.arrow_forward
                                  : Icons.check,
                              size: 18,
                            ),
                            label: Text(
                              _currentProblem < totalProblems - 1
                                  ? 'Next'
                                  : 'Complete',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          )
                        : ElevatedButton.icon(
                            onPressed: () => _checkSolution(),
                            icon: Icon(Icons.check, size: 18),
                            label: Text('Check Solution'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getProblemText(int index) {
    final problems = [
      'Solve for x: 2x + 5 = 13',
      'Find the derivative of f(x) = 3x² + 2x - 5',
      'Calculate the area of a circle with radius 7cm',
      'Simplify: (2x + 3)(x - 4)',
      'Solve the equation: x² - 5x + 6 = 0',
      'Find the slope of the line passing through points (2,3) and (4,7)',
      'Calculate the volume of a cylinder with radius 3cm and height 10cm',
      'Simplify: √(16x⁴)',
      'Solve the system: 2x + y = 7, x - y = 2',
      'Find the value of sin(45°)',
    ];
    return problems[index % problems.length];
  }

  String _getSolutionSteps(int index) {
    final solutions = [
      'Step 1: Subtract 5 from both sides: 2x = 8\n'
      'Step 2: Divide both sides by 2: x = 4',
      
      'Step 1: Apply power rule to 3x²: 6x\n'
      'Step 2: Derivative of 2x is 2\n'
      'Step 3: Derivative of constant -5 is 0\n'
      'Final: f\'(x) = 6x + 2',
      
      'Step 1: Area formula: πr²\n'
      'Step 2: Substitute r = 7: π(7)² = 49π\n'
      'Step 3: Approximate: 49 × 3.1416 = 153.94 cm²',
    ];
    return solutions[index % solutions.length];
  }

  void _checkSolution() {
    setState(() {
      _completedProblems[_currentProblem] = true;
      _updateProgress();
    });
    
    // Show feedback
    Get.snackbar(
      '✅ Solution Checked',
      'Great job! Compare your solution with the provided steps.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade800,
    );
  }

  void _updateProgress() {
    final completedCount = _completedProblems.where((c) => c).length;
    _progress = completedCount / _completedProblems.length;
  }

  void _completeSession() {
    final completedCount = _completedProblems.where((c) => c).length;
    final score = (completedCount / _completedProblems.length * 100).toDouble();
    
    // Mark activity as complete
    final firebaseService = StudyPlannerFirebaseService();
    firebaseService.markActivityComplete(
      studentId: 'current_user_id',
      activityId: widget.activity.id,
      score: score,
    );
    
    // Show completion dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Column(
          children: [
            Icon(Icons.emoji_events, size: 60, color: Colors.orange),
            SizedBox(height: 15),
            Text(
              'Practice Completed!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
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
                border: Border.all(color: Colors.orange, width: 3),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${completedCount}/${_completedProblems.length}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    Text(
                      'Problems',
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
              'Excellent work! Keep practicing to improve your skills.',
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
              Get.back(); // Close dialog
              Get.back(); // Go back
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: Text('Finish'),
          ),
        ],
      ),
    );
  }
}

// ======================= GENERIC ACTIVITY SCREEN =======================
class GenericActivityScreen extends StatefulWidget {
  final DailyActivity activity;

  const GenericActivityScreen({Key? key, required this.activity}) : super(key: key);

  @override
  State<GenericActivityScreen> createState() => _GenericActivityScreenState();
}

class _GenericActivityScreenState extends State<GenericActivityScreen> {
  bool _isCompleted = false;
  double _progress = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFF),
      body: SafeArea(
        child: Column(
          children: [
            // Header
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
                    onPressed: () => Get.back(),
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
                        LinearProgressIndicator(
                          value: _progress,
                          backgroundColor: Colors.grey[200],
                          color: Colors.teal,
                          minHeight: 4,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Activity Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                      widget.activity.description,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[800],
                        height: 1.6,
                      ),
                    ),
                    SizedBox(height: 30),
                    
                    // Task list
                    if (widget.activity.metadata.containsKey('requirements'))
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Requirements:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 10),
                          ...(widget.activity.metadata['requirements'] as List<dynamic>)
                              .asMap()
                              .entries
                              .map((entry) => _buildTaskItem(
                                    index: entry.key,
                                    task: entry.value.toString(),
                                  ))
                              .toList(),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            // Complete Button
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
              child: _isCompleted
                  ? ElevatedButton.icon(
                      onPressed: _markComplete,
                      icon: Icon(Icons.check_circle, size: 20),
                      label: Text(
                        'Mark as Complete',
                        style: TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: () => setState(() {
                            _progress = 1.0;
                            _isCompleted = true;
                          }),
                      icon: Icon(Icons.done_all, size: 20),
                      label: Text(
                        'I have completed this activity',
                        style: TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem({required int index, required String task}) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Checkbox(
            value: _progress > (index + 1) * 0.2,
            onChanged: (value) {
              setState(() {
                _progress = (index + 1) * 0.2;
              });
            },
            shape: CircleBorder(),
            activeColor: Colors.teal,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              task,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _markComplete() {
    // Mark activity as complete
    final firebaseService = StudyPlannerFirebaseService();
    firebaseService.markActivityComplete(
      studentId: 'current_user_id',
      activityId: widget.activity.id,
      score: 100.0,
    );
    
    // Show success message
    Get.snackbar(
      '✅ Activity Completed',
      'Great work on completing this task!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
    
    // Navigate back after delay
    Future.delayed(Duration(seconds: 1), () {
      Get.back();
    });
  }
}