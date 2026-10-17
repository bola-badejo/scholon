import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:isapp/features/study_guide/study_guide.dart';

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
