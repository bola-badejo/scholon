part of '../project_work_screen.dart';

// _ProjectWorkScreenState: _buildTaskItem, _showCompletionOptions, _showLowCompletionWarning, _buildProjectStatRow, _showExitConfirmation
extension ProjectWorkScreenStateSection01 on _ProjectWorkScreenState {
  Widget _buildTaskItem({
    required int index,
    required String task,
    required int sectionIndex,
    required int taskIndex,
  }) {
    // Create a unique key for each task checkbox
    final taskKey = '$sectionIndex-$taskIndex';
    bool isChecked = _completedSections[sectionIndex] ?? false;
    
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isChecked ? Colors.green.shade200 : Colors.grey.shade200,
        ),
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
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isChecked ? Colors.green : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Icon(
                Icons.check,
                size: 14,
                color: isChecked ? Colors.white : Colors.transparent,
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              task,
              style: TextStyle(
                fontSize: 14,
                color: isChecked ? Colors.grey[600] : Colors.grey[800],
                fontWeight: isChecked ? FontWeight.normal : FontWeight.w500,
                decoration: isChecked ? TextDecoration.lineThrough : null,
                decorationColor: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCompletionOptions() {
    final completedCount = _completedSections.values.where((c) => c).length;
    final totalCount = _projectSections.length;
    final completionPercentage = (completedCount / totalCount * 100).toInt();
    
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Project Completion',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 15),
            
            // Progress indicator
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  CircularProgressIndicator(
                    value: completedCount / totalCount,
                    strokeWidth: 8,
                    backgroundColor: Colors.green.shade100,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                  SizedBox(height: 15),
                  Text(
                    '$completionPercentage% Complete',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    '$completedCount out of $totalCount sections completed',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.green.shade600,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 20),
            
            // Options
            if (completionPercentage < 100)
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade100),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, size: 20, color: Colors.orange),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Complete all sections for best results. '
                        'You can still submit with current progress.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            SizedBox(height: 25),
            
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
                    ),
                    child: Text('Continue Working'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      if (completionPercentage >= 70) {
                        _completeProject();
                      } else {
                        _showLowCompletionWarning();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text('Submit Project'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showLowCompletionWarning() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 10),
            Text('Low Completion'),
          ],
        ),
        content: Text(
          'Your project is less than 70% complete. '
          'Are you sure you want to submit? '
          'Consider completing more sections for better results.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Go Back'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _completeProject();
            },
            child: Text(
              'Submit Anyway',
              style: TextStyle(color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectStatRow({
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
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  void _showExitConfirmation() {
    final completedCount = _completedSections.values.where((c) => c).length;
    final totalCount = _projectSections.length;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Save and Exit?'),
        content: Text(
          'You have completed $completedCount out of $totalCount sections. '
          'Your progress will be saved automatically. '
          'You can continue working on this project later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _saveProgress();
              Get.back(); // Close dialog
              Get.back(); // Go back
            },
            child: Text('Save & Exit'),
          ),
        ],
      ),
    );
  }
}
