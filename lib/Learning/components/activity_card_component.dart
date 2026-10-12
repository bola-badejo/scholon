// lib/Learning/components/activity_card_component.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:isapp/Learning/study_planner_screen.dart';

class ActivityCard extends StatefulWidget {
  final DailyActivity activity;
  final VoidCallback onComplete;
  final VoidCallback onStart;
  final bool showActions;
  
  const ActivityCard({
    Key? key,
    required this.activity,
    required this.onComplete,
    required this.onStart,
    this.showActions = true,
  }) : super(key: key);

  @override
  State<ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<ActivityCard> {
  bool _isStarting = false;
  bool _isCompleting = false;

  @override
  Widget build(BuildContext context) {
    final activity = widget.activity;
    final isCompleted = activity.isCompleted;
    
    return Container(
      margin: EdgeInsets.only(bottom: 16),
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
        children: [
          // Activity header with gradient
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getActivityColor(activity.type).withOpacity(0.1),
                  _getActivityColor(activity.type).withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Activity icon with glow effect
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _getActivityColor(activity.type).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: _getActivityColor(activity.type).withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      _getActivityIcon(activity.type),
                      color: _getActivityColor(activity.type),
                      size: 24,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                
                // Activity info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  activity.title,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 6),
                                Text(
                                  activity.description,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          
                          // Status badge with animation
                          if (isCompleted)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.green, Colors.lightGreen],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.check, size: 14, color: Colors.white),
                                  SizedBox(width: 4),
                                  Text(
                                    'Completed',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ).animate().scale(duration: 300.ms),
                        ],
                      ),
                      
                      // Progress indicator
                      if (activity.progress > 0 && activity.progress < 1)
                        Column(
                          children: [
                            SizedBox(height: 16),
                            LinearProgressIndicator(
                              value: activity.progress,
                              backgroundColor: Colors.grey[200],
                              color: _getActivityColor(activity.type),
                              minHeight: 6,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${(activity.progress * 100).toInt()}% complete',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  _getRemainingTime(activity),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _getActivityColor(activity.type),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Activity details and actions
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                // Metadata
                Row(
                  children: [
                    // Time
                    _buildMetadataChip(
                      icon: Icons.access_time,
                      text: '${activity.estimatedDuration.inMinutes} min',
                      color: Colors.blue,
                    ),
                    SizedBox(width: 12),
                    
                    // Type
                    _buildMetadataChip(
                      icon: Icons.category,
                      text: _getActivityTypeLabel(activity.type),
                      color: _getActivityColor(activity.type),
                    ),
                    
                    Spacer(),
                    
                    // Difficulty
                    if (activity.metadata['difficulty'] != null)
                      _buildDifficultyBadge(activity.metadata['difficulty'] as String),
                  ],
                ),
                
                // Action buttons
                if (widget.showActions && !isCompleted)
                  Column(
                    children: [
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionButton(
                              text: 'Start Activity',
                              icon: Icons.play_arrow,
                              color: _getActivityColor(activity.type),
                              isLoading: _isStarting,
                              onPressed: () {
                                setState(() => _isStarting = true);
                                Future.delayed(Duration(milliseconds: 500), () {
                                  setState(() => _isStarting = false);
                                  widget.onStart();
                                });
                              },
                              isPrimary: false,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _buildActionButton(
                              text: 'Mark Complete',
                              icon: Icons.check,
                              color: Colors.green,
                              isLoading: _isCompleting,
                              onPressed: () {
                                setState(() => _isCompleting = true);
                                Future.delayed(Duration(milliseconds: 800), () {
                                  setState(() => _isCompleting = false);
                                  widget.onComplete();
                                });
                              },
                              isPrimary: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                
                // Completion info
                if (isCompleted && activity.completedAt != null)
                  Column(
                    children: [
                      SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.green.withOpacity(0.1),
                              Colors.lightGreen.withOpacity(0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.green.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.verified,
                              color: Colors.green,
                              size: 20,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Completed Successfully',
                                    style: TextStyle(
                                      color: Colors.green.shade700,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    _formatDate(activity.completedAt!),
                                    style: TextStyle(
                                      color: Colors.green.shade600,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    ).animate().scale(
      duration: 300.ms,
      curve: Curves.easeOutBack,
    );
  }

  Widget _buildMetadataChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyBadge(String difficulty) {
    Color color;
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        color = Colors.green;
        break;
      case 'intermediate':
        color = Colors.orange;
        break;
      case 'advanced':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        difficulty,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required IconData icon,
    required Color color,
    required bool isLoading,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        gradient: isPrimary
            ? LinearGradient(
                colors: [color, color.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isPrimary ? null : Colors.transparent,
        borderRadius: BorderRadius.circular(15),
        border: isPrimary
            ? null
            : Border.all(color: color.withOpacity(0.3)),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(15),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: isPrimary ? Colors.white : color,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        size: 18,
                        color: isPrimary ? Colors.white : color,
                      ),
                      SizedBox(width: 8),
                      Text(
                        text,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isPrimary ? Colors.white : color,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  String _getRemainingTime(DailyActivity activity) {
    final remainingMinutes = activity.estimatedDuration.inMinutes * (1 - activity.progress);
    
    if (remainingMinutes < 60) {
      return '${remainingMinutes.round()} min left';
    } else {
      final hours = remainingMinutes ~/ 60;
      final minutes = remainingMinutes % 60;
      return '${hours}h ${minutes}m left';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today at ${DateFormat('h:mm a').format(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday at ${DateFormat('h:mm a').format(date)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  Color _getActivityColor(ActivityType type) {
    switch (type) {
      case ActivityType.dailyLesson:
        return Colors.blue;
      case ActivityType.dailyQuiz:
        return Colors.green;
      case ActivityType.weeklyMockTest:
        return Colors.orange;
      case ActivityType.monthlyExam:
        return Colors.purple;
      case ActivityType.practiceSession:
        return Colors.teal;
      case ActivityType.revisionSession:
        return Colors.indigo;
      case ActivityType.projectWork:
        return Colors.deepOrange;
      case ActivityType.readingSession:
        return Colors.brown;
      case ActivityType.researchWork:
        // TODO: Handle this case.
        throw UnimplementedError();
      case ActivityType.problemSolving:
        // TODO: Handle this case.
        throw UnimplementedError();
      case ActivityType.experimentLab:
        // TODO: Handle this case.
        throw UnimplementedError();
      case ActivityType.groupDiscussion:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  IconData _getActivityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.dailyLesson:
        return Icons.school;
      case ActivityType.dailyQuiz:
        return Icons.quiz;
      case ActivityType.weeklyMockTest:
        return Icons.assignment;
      case ActivityType.monthlyExam:
        return Icons.assignment_turned_in;
      case ActivityType.practiceSession:
        return Icons.repeat;
      case ActivityType.revisionSession:
        return Icons.replay;
      case ActivityType.projectWork:
        return Icons.work;
      case ActivityType.readingSession:
        return Icons.menu_book;
      case ActivityType.researchWork:
        // TODO: Handle this case.
        throw UnimplementedError();
      case ActivityType.problemSolving:
        // TODO: Handle this case.
        throw UnimplementedError();
      case ActivityType.experimentLab:
        // TODO: Handle this case.
        throw UnimplementedError();
      case ActivityType.groupDiscussion:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  String _getActivityTypeLabel(ActivityType type) {
    switch (type) {
      case ActivityType.dailyLesson:
        return 'Lesson';
      case ActivityType.dailyQuiz:
        return 'Quiz';
      case ActivityType.weeklyMockTest:
        return 'Test';
      case ActivityType.monthlyExam:
        return 'Exam';
      case ActivityType.practiceSession:
        return 'Practice';
      case ActivityType.revisionSession:
        return 'Revision';
      case ActivityType.projectWork:
        return 'Project';
      case ActivityType.readingSession:
        return 'Reading';
      case ActivityType.researchWork:
        // TODO: Handle this case.
        throw UnimplementedError();
      case ActivityType.problemSolving:
        // TODO: Handle this case.
        throw UnimplementedError();
      case ActivityType.experimentLab:
        // TODO: Handle this case.
        throw UnimplementedError();
      case ActivityType.groupDiscussion:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }
}