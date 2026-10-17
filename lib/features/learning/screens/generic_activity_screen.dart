import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:isapp/features/study_guide/study_guide.dart';

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
