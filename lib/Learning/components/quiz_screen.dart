// lib/Screens/activity/quiz_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:isapp/Learning/study_planner_screen.dart';
import 'package:isapp/Models/planner_models.dart';

class QuizScreen extends StatefulWidget {
  final DailyActivity activity;

  const QuizScreen({Key? key, required this.activity}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late List<Map<String, dynamic>> _questions;
  late Timer _timer;
  int _currentQuestionIndex = 0;
  int _timeRemaining = 0;
  Map<int, dynamic> _answers = {};
  Map<int, bool> _answered = {};
  bool _isSubmitted = false;
  int _score = 0;
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _initializeQuiz();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _initializeQuiz() {
    final metadata = widget.activity.metadata;
    final questionsData = metadata['questions'] as List<dynamic>? ?? [];
    
    _questions = questionsData.map((q) {
      return {
        'id': q['id'],
        'question': q['question'],
        'options': q['options'],
        'correctAnswer': q['correctAnswer'] ?? 0,
        'explanation': q['explanation'] ?? '',
        'points': (q['points'] ?? 10) as int,
      };
    }).toList();
    
    _timeRemaining = (metadata['duration'] as int? ?? 15) * 60; // Convert minutes to seconds
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0 && !_isSubmitted) {
        setState(() {
          _timeRemaining--;
        });
      } else {
        timer.cancel();
        if (!_isSubmitted) {
          _submitQuiz();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_currentQuestionIndex];
    final totalQuestions = _questions.length;
    final progress = (_currentQuestionIndex + 1) / totalQuestions;
    final isAnswered = _answered.containsKey(_currentQuestionIndex);

    return Scaffold(
      backgroundColor: Color(0xFFF8FAFF),
      body: SafeArea(
        child: Column(
          children: [
            // Quiz Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
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
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.grey[200],
                              color: Color(0xFF667EEA),
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
                          color: _timeRemaining < 60 
                              ? Colors.red.shade50 
                              : Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: _timeRemaining < 60 
                                ? Colors.red.shade100 
                                : Colors.blue.shade100,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.timer,
                              size: 14,
                              color: _timeRemaining < 60 ? Colors.red : Colors.blue,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '${_timeRemaining ~/ 60}:${(_timeRemaining % 60).toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _timeRemaining < 60 ? Colors.red : Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 10),
                  
                  // Question progress
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Question ${_currentQuestionIndex + 1} of $totalQuestions',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${(_score / totalQuestions * 100).toInt()}% Score',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Current Question
            Expanded(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question
                    Container(
                      padding: EdgeInsets.all(20),
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
                      child: Text(
                        currentQuestion['question'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // Options
                    ...(currentQuestion['options'] as List<dynamic>)
                        .asMap()
                        .entries
                        .map((entry) {
                      final index = entry.key;
                      final option = entry.value;
                      final isSelected = _answers[_currentQuestionIndex] == index;
                      final isCorrect = index == currentQuestion['correctAnswer'];
                      final showResult = _isSubmitted && isAnswered;
                      
                      return _buildOptionCard(
                        index: index,
                        option: option,
                        isSelected: isSelected,
                        isCorrect: isCorrect,
                        showResult: showResult,
                      );
                    }),

                    // Explanation (shown after answering in review mode)
                    if (_isSubmitted && isAnswered && currentQuestion['explanation'] != null)
                      Container(
                        margin: EdgeInsets.only(top: 20),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.blue.shade100),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.lightbulb, size: 16, color: Colors.blue),
                                SizedBox(width: 8),
                                Text(
                                  'Explanation',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue.shade800,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              currentQuestion['explanation'],
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

            // Navigation & Actions
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
                  // Previous button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _currentQuestionIndex > 0
                          ? () => setState(() {
                                _currentQuestionIndex--;
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

                  // Next/Submit button
                  Expanded(
                    child: _isSubmitted
                        ? ElevatedButton.icon(
                            onPressed: _currentQuestionIndex < totalQuestions - 1
                                ? () => setState(() {
                                      _currentQuestionIndex++;
                                    })
                                : _showResults,
                            icon: Icon(
                              _currentQuestionIndex < totalQuestions - 1
                                  ? Icons.arrow_forward
                                  : Icons.analytics,
                              size: 18,
                            ),
                            label: Text(
                              _currentQuestionIndex < totalQuestions - 1
                                  ? 'Next'
                                  : 'Results',
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
                            onPressed: isAnswered
                                ? () {
                                    if (_currentQuestionIndex < totalQuestions - 1) {
                                      setState(() {
                                        _currentQuestionIndex++;
                                      });
                                    } else {
                                      _submitQuiz();
                                    }
                                  }
                                : null,
                            icon: Icon(
                              _currentQuestionIndex < totalQuestions - 1
                                  ? Icons.arrow_forward
                                  : Icons.send,
                              size: 18,
                            ),
                            label: Text(
                              _currentQuestionIndex < totalQuestions - 1
                                  ? 'Next'
                                  : 'Submit',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isAnswered
                                  ? Color(0xFF667EEA)
                                  : Colors.grey[300],
                              foregroundColor: isAnswered
                                  ? Colors.white
                                  : Colors.grey[500],
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

  Widget _buildOptionCard({
    required int index,
    required dynamic option,
    required bool isSelected,
    required bool isCorrect,
    required bool showResult,
  }) {
    Color backgroundColor = Colors.white;
    Color borderColor = Colors.grey[300]!;
    Color textColor = Colors.black87;
    
    if (showResult) {
      if (isCorrect) {
        backgroundColor = Colors.green.shade50;
        borderColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
      } else if (isSelected) {
        backgroundColor = Colors.red.shade50;
        borderColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
      }
    } else if (isSelected) {
      backgroundColor = Colors.blue.shade50;
      borderColor = Colors.blue.shade200;
      textColor = Colors.blue.shade800;
    }

    return GestureDetector(
      onTap: _isSubmitted ? null : () => _selectOption(index),
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: showResult && isCorrect
              ? [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Option letter
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: showResult
                    ? (isCorrect
                        ? Colors.green
                        : isSelected
                            ? Colors.red
                            : Colors.grey[300])
                    : isSelected
                        ? Colors.blue
                        : Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + index), // A, B, C, D
                  style: TextStyle(
                    color: showResult || isSelected
                        ? Colors.white
                        : Colors.grey[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            
            SizedBox(width: 12),
            
            // Option text
            Expanded(
              child: Text(
                option['text']?.toString() ?? 'Option ${index + 1}',
                style: TextStyle(
                  fontSize: 15,
                  color: textColor,
                  fontWeight: isSelected || showResult
                      ? FontWeight.w600
                      : FontWeight.normal,
                  height: 1.4,
                ),
              ),
            ),
            
            // Correct/Incorrect indicator
            if (showResult && (isCorrect || isSelected))
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                size: 20,
                color: isCorrect ? Colors.green : Colors.red,
              ),
          ],
        ),
      ),
    );
  }

  void _selectOption(int optionIndex) {
    setState(() {
      _answers[_currentQuestionIndex] = optionIndex;
      _answered[_currentQuestionIndex] = true;
      
      // Calculate score if this is the correct answer
      final currentQuestion = _questions[_currentQuestionIndex];
      if (optionIndex == currentQuestion['correctAnswer']) {
        // FIXED: Explicitly cast to int
        final points = (currentQuestion['points'] as int?) ?? 10;
        _score += points;
      }
    });
  }

  void _submitQuiz() {
    setState(() {
      _isSubmitted = true;
      _timer.cancel();
    });
    
    // Auto-answer any unanswered questions
    for (int i = 0; i < _questions.length; i++) {
      if (!_answered.containsKey(i)) {
        _answers[i] = -1; // Mark as unanswered
      }
    }
    
    // Show submission confirmation
    _showSubmissionConfirmation();
  }

  void _showSubmissionConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Column(
          children: [
            Icon(Icons.upload_file, size: 60, color: Colors.blue),
            SizedBox(height: 15),
            Text(
              'Quiz Submitted!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Your answers have been submitted successfully.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Questions Answered:', style: TextStyle(fontSize: 12)),
                Text(
                  '${_answered.length}/${_questions.length}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Time Used:', style: TextStyle(fontSize: 12)),
                Text(
                  '${((widget.activity.metadata['duration'] as int? ?? 15) * 60 - _timeRemaining) ~/ 60} min',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Estimated Score:', style: TextStyle(fontSize: 12)),
                Text(
                  '${(_score / _questions.length * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              // Stay on quiz for review
            },
            child: Text('Review Answers'),
          ),
          ElevatedButton(
            onPressed: _showResults,
            child: Text('See Results'),
          ),
        ],
      ),
    );
  }

  void _showResults() {
    // FIXED: Explicitly cast to int in fold function
    final totalPossibleScore = _questions.fold<int>(
      0, 
      (sum, q) => sum + ((q['points'] as int?) ?? 10),
    );
    
    final percentage = totalPossibleScore > 0 
        ? (_score / totalPossibleScore * 100).toInt()
        : 0;
    
    final passingScore = widget.activity.metadata['passingScore'] as int? ?? 70;
    final hasPassed = percentage >= passingScore;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Column(
          children: [
            Icon(
              hasPassed ? Icons.celebration : Icons.sentiment_dissatisfied,
              size: 60,
              color: hasPassed ? Colors.green : Colors.orange,
            ),
            SizedBox(height: 15),
            Text(
              hasPassed ? 'Quiz Passed!' : 'Quiz Completed',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: hasPassed ? Colors.green : Colors.orange,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Score circle
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: hasPassed ? Colors.green : Colors.orange,
                  width: 4,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$percentage%',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: hasPassed ? Colors.green : Colors.orange,
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
            
            // Stats
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  _buildStatRow(
                    label: 'Correct Answers',
                    value: '${_answers.values.where((ans) => 
                      _questions[ans.key]?['correctAnswer'] == ans.value).length}/$_questions.length',
                    color: Colors.green,
                  ),
                  SizedBox(height: 8),
                  _buildStatRow(
                    label: 'Time Taken',
                    value: '${((widget.activity.metadata['duration'] as int? ?? 15) * 60 - _timeRemaining) ~/ 60}:'
                           '${((widget.activity.metadata['duration'] as int? ?? 15) * 60 - _timeRemaining) % 60} min',
                    color: Colors.blue,
                  ),
                  SizedBox(height: 8),
                  _buildStatRow(
                    label: 'Passing Score',
                    value: '$passingScore%',
                    color: Colors.purple,
                  ),
                  SizedBox(height: 8),
                  _buildStatRow(
                    label: 'Your Score',
                    value: '$_score/$totalPossibleScore',
                    color: hasPassed ? Colors.green : Colors.orange,
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 15),
            
            if (!hasPassed)
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.orange.shade100),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, size: 16, color: Colors.orange),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Score below passing. Review and retry to improve.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // Close results
              Get.back(); // Go back to quiz for review
            },
            child: Text('Review'),
          ),
          ElevatedButton(
            onPressed: () {
              _completeQuiz(percentage);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: hasPassed ? Colors.green : Colors.orange,
            ),
            child: Text('Finish'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow({
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  void _completeQuiz(int score) {
    final endTime = DateTime.now();
    final duration = endTime.difference(_startTime!);
    
    // Mark activity as complete in Firebase
    final firebaseService = StudyPlannerFirebaseService();
    firebaseService.markActivityComplete(
      studentId: 'current_user_id', // Get from auth
      activityId: widget.activity.id,
      score: score.toDouble(),
    );
    
    // Navigate back to planner
    Get.back(); // Close results
    Get.back(); // Close quiz
    Get.back(); // Go back to planner
    
    // Show success message
    Get.snackbar(
      '🎉 Quiz Completed!',
      'Score: $score%',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: Duration(seconds: 3),
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Exit Quiz?'),
        content: Text(
          _isSubmitted
              ? 'Your quiz has been submitted. Exiting will take you back to the planner.'
              : 'If you exit now, your progress will be lost. The quiz will be graded based on completed questions.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (!_isSubmitted) {
                // Auto-submit if not submitted
                _submitQuiz();
              }
              Get.back(); // Close dialog
              Get.back(); // Go back
            },
            child: Text('Exit', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}