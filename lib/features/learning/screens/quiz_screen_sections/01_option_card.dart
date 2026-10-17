part of '../quiz_screen.dart';

// _QuizScreenState: _buildOptionCard, _showSubmissionConfirmation, _showResults, _buildStatRow, _showExitConfirmation
extension QuizScreenStateSection01 on _QuizScreenState {
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
