// lib/Screens/activity/project_work_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isapp/features/study_guide/study_guide.dart';

part 'project_work_screen_sections/01_task_item.dart';

class ProjectWorkScreen extends StatefulWidget {
  final DailyActivity activity;

  const ProjectWorkScreen({Key? key, required this.activity}) : super(key: key);

  @override
  State<ProjectWorkScreen> createState() => _ProjectWorkScreenState();
}

class _ProjectWorkScreenState extends State<ProjectWorkScreen> {
  final PageController _pageController = PageController();
  final ValueNotifier<int> _currentPage = ValueNotifier<int>(0);
  final ValueNotifier<double> _progress = ValueNotifier<double>(0.0);
  final ValueNotifier<bool> _isCompleted = ValueNotifier<bool>(false);
  
  List<Map<String, dynamic>> _projectSections = [];
  Map<int, bool> _completedSections = {};
  Map<int, String> _sectionContent = {};
  DateTime? _startTime;
  Timer? _autoSaveTimer;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _initializeProject();
    _startAutoSave();
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    super.dispose();
  }

  void _initializeProject() {
    final metadata = widget.activity.metadata;
    
    // Define project sections based on project type
    _projectSections = [
      {
        'id': 'research',
        'title': '📚 Research & Background',
        'description': 'Conduct research and gather information about your project topic.',
        'tasks': [
          'Define project scope and objectives',
          'Research relevant literature and resources',
          'Identify key concepts and theories',
          'Gather data and references',
        ],
        'estimatedTime': '60 minutes',
        'tips': 'Start with a clear research question. Use academic databases and credible sources.',
      },
      {
        'id': 'planning',
        'title': '📋 Project Planning',
        'description': 'Create a detailed plan for your project execution.',
        'tasks': [
          'Create project timeline',
          'Define milestones and deliverables',
          'Allocate resources and materials',
          'Identify potential challenges',
        ],
        'estimatedTime': '45 minutes',
        'tips': 'Break down the project into manageable tasks. Set realistic deadlines.',
      },
      {
        'id': 'execution',
        'title': '⚡ Project Execution',
        'description': 'Implement your project plan and develop the project.',
        'tasks': [
          'Start with core functionality',
          'Implement key features',
          'Test components as you build',
          'Document your progress',
        ],
        'estimatedTime': '120 minutes',
        'tips': 'Work methodically. Test frequently. Keep detailed notes of your implementation.',
      },
      {
        'id': 'documentation',
        'title': '📝 Documentation & Report',
        'description': 'Document your project and create a comprehensive report.',
        'tasks': [
          'Write project introduction',
          'Document methodology and approach',
          'Present results and findings',
          'Write conclusion and recommendations',
        ],
        'estimatedTime': '90 minutes',
        'tips': 'Be thorough and clear. Include visuals like diagrams and charts where helpful.',
      },
      {
        'id': 'review',
        'title': '🔍 Review & Refinement',
        'description': 'Review your work and make improvements.',
        'tasks': [
          'Proofread documentation',
          'Test final product thoroughly',
          'Gather feedback if possible',
          'Make final improvements',
        ],
        'estimatedTime': '60 minutes',
        'tips': 'Take a break before reviewing. Look for both technical and presentation improvements.',
      },
    ];
    
    // Initialize completion status
    for (int i = 0; i < _projectSections.length; i++) {
      _completedSections[i] = false;
      _sectionContent[i] = '';
    }
  }

  void _startAutoSave() {
    _autoSaveTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      _saveProgress();
    });
  }

  void _saveProgress() {
    // Calculate progress based on completed sections
    final completedCount = _completedSections.values.where((c) => c).length;
    final newProgress = completedCount / _projectSections.length;
    _progress.value = newProgress;
    
    // Auto-mark as ready for completion if 80% done
    if (newProgress >= 0.8 && !_isCompleted.value) {
      _isCompleted.value = true;
    }
    
    // Save to local storage (would integrate with Firebase in production)
    print('Auto-saving project progress: ${(newProgress * 100).toInt()}%');
  }

  @override
  Widget build(BuildContext context) {
    final currentSection = _projectSections[_currentPage.value];
    final totalSections = _projectSections.length;

    return Scaffold(
      backgroundColor: Color(0xFFF8FAFF),
      body: SafeArea(
        child: Column(
          children: [
            // Project Header
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
                        ValueListenableBuilder<double>(
                          valueListenable: _progress,
                          builder: (context, progress, child) {
                            return LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.grey[200],
                              color: Color(0xFF4CAF50),
                              minHeight: 4,
                              borderRadius: BorderRadius.circular(2),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.green.shade100),
                    ),
                    child: ValueListenableBuilder<int>(
                      valueListenable: _currentPage,
                      builder: (context, currentPage, child) {
                        return Text(
                          'Step ${currentPage + 1}/$totalSections',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Project Content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _projectSections.length,
                onPageChanged: (index) {
                  _currentPage.value = index;
                  _saveProgress();
                },
                itemBuilder: (context, index) {
                  final section = _projectSections[index];
                  final isCompleted = _completedSections[index] ?? false;
                  
                  return SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section Header
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.green.shade100),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      section['title'],
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green.shade800,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      section['description'],
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.green.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 20),

                        // Estimated Time
                        Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.shade100),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.timer, size: 20, color: Colors.blue),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Estimated Time',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue.shade600,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      section['estimatedTime'],
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blue.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isCompleted
                                      ? Colors.green
                                      : Colors.orange.shade100,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Text(
                                  isCompleted ? 'COMPLETED' : 'IN PROGRESS',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isCompleted
                                        ? Colors.white
                                        : Colors.orange.shade800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 20),

                        // Tasks
                        Text(
                          'Tasks to Complete:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 10),
                        ...(section['tasks'] as List<String>)
                            .asMap()
                            .entries
                            .map((entry) => _buildTaskItem(
                                  index: entry.key,
                                  task: entry.value,
                                  sectionIndex: index,
                                  taskIndex: entry.key,
                                ))
                            .toList(),

                        SizedBox(height: 20),

                        // Tips
                        Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.amber.shade100),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.lightbulb,
                                      size: 18, color: Colors.amber.shade700),
                                  SizedBox(width: 8),
                                  Text(
                                    'Pro Tips',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.amber.shade800,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                section['tips'],
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.amber.shade700,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 20),

                        // Notes/Work Area
                        Text(
                          'Your Work & Notes:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 10),
                        Container(
                          height: 200,
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: TextEditingController(
                              text: _sectionContent[index] ?? '',
                            ),
                            onChanged: (value) {
                              _sectionContent[index] = value;
                            },
                            maxLines: null,
                            expands: true,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Record your work, ideas, and progress here...',
                              hintStyle: TextStyle(color: Colors.grey[500]),
                            ),
                          ),
                        ),

                        SizedBox(height: 20),

                        // Completion Toggle
                        Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? Colors.green.shade50
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isCompleted
                                  ? Colors.green.shade100
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Row(
                            children: [
                              Checkbox(
                                value: isCompleted,
                                onChanged: (value) {
                                  setState(() {
                                    _completedSections[index] = value ?? false;
                                  });
                                  _saveProgress();
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                activeColor: Colors.green,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Mark this section as complete',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: isCompleted
                                            ? Colors.green.shade800
                                            : Colors.grey.shade700,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      isCompleted
                                          ? 'Great job! Move to next section.'
                                          : 'Check when you\'ve completed all tasks.',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isCompleted
                                            ? Colors.green.shade600
                                            : Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 30),
                      ],
                    ),
                  );
                },
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
                      onPressed: _currentPage.value > 0
                          ? () => _pageController.previousPage(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              )
                          : null,
                      icon: Icon(Icons.arrow_back, size: 18),
                      label: Text('Previous Step'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 12),

                  // Next/Complete button
                  Expanded(
                    child: ValueListenableBuilder<int>(
                      valueListenable: _currentPage,
                      builder: (context, currentPage, child) {
                        final isLastPage = currentPage == _projectSections.length - 1;
                        
                        return ValueListenableBuilder<bool>(
                          valueListenable: _isCompleted,
                          builder: (context, isCompleted, child) {
                            if (isLastPage && isCompleted) {
                              return ElevatedButton.icon(
                                onPressed: _completeProject,
                                icon: Icon(Icons.check_circle, size: 18),
                                label: Text('Complete Project'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            }

                            return ElevatedButton.icon(
                              onPressed: isLastPage
                                  ? () {
                                      // Show completion options on last page
                                      _showCompletionOptions();
                                    }
                                  : () => _pageController.nextPage(
                                        duration: Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      ),
                              icon: Icon(
                                isLastPage ? Icons.flag : Icons.arrow_forward,
                                size: 18,
                              ),
                              label: Text(
                                isLastPage ? 'Finish Steps' : 'Next Step',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF4CAF50),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          },
                        );
                      },
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

  void _completeProject() {
    _autoSaveTimer?.cancel();
    
    final endTime = DateTime.now();
    final duration = endTime.difference(_startTime!);
    final completedCount = _completedSections.values.where((c) => c).length;
    final totalCount = _projectSections.length;
    final completionPercentage = completedCount / totalCount * 100;
    
    // Calculate score based on completion and time efficiency
    final timeEfficiency = (totalCount * 60) / duration.inMinutes;
    final score = (completionPercentage * 0.7 + 
                  (timeEfficiency > 1 ? 30 : timeEfficiency * 30))
                  .clamp(0, 100);
    
    // Mark activity as complete in Firebase
    final firebaseService = StudyPlannerFirebaseService();
    firebaseService.markActivityComplete(
      studentId: 'current_user_id', // Get from auth
      activityId: widget.activity.id,
      score: score.toDouble(),
    );
    
    // Show completion dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Column(
          children: [
            Icon(Icons.celebration, size: 60, color: Colors.green),
            SizedBox(height: 15),
            Text(
              'Project Completed!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.green, width: 3),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${score.toInt()}%',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
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
            
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  _buildProjectStatRow(
                    label: 'Sections Completed',
                    value: '$completedCount/$totalCount',
                    color: Colors.green,
                  ),
                  SizedBox(height: 8),
                  _buildProjectStatRow(
                    label: 'Time Spent',
                    value: '${duration.inHours}h ${duration.inMinutes.remainder(60)}m',
                    color: Colors.blue,
                  ),
                  SizedBox(height: 8),
                  _buildProjectStatRow(
                    label: 'Completion Rate',
                    value: '${completionPercentage.toInt()}%',
                    color: Colors.purple,
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 15),
            
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.shade100),
              ),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome, size: 16, color: Colors.green),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Excellent work! Your project has been submitted successfully.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Get.back(); // Close dialog
              Get.back(); // Go back to planner
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: Text('Back to Planner'),
          ),
        ],
      ),
    );
  }

}