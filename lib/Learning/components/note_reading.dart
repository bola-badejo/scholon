// lib/Screens/activity/note_reading_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:isapp/Learning/study_planner_screen.dart';
import 'package:isapp/Models/planner_models.dart';

class NoteReadingScreen extends StatefulWidget {
  final DailyActivity activity;

  const NoteReadingScreen({Key? key, required this.activity}) : super(key: key);

  @override
  State<NoteReadingScreen> createState() => _NoteReadingScreenState();
}

class _NoteReadingScreenState extends State<NoteReadingScreen> {
  final PageController _pageController = PageController();
  final ValueNotifier<int> _currentPage = ValueNotifier<int>(0);
  final ValueNotifier<double> _progress = ValueNotifier<double>(0.0);
  final ValueNotifier<bool> _isCompleted = ValueNotifier<bool>(false);
  
  List<Map<String, dynamic>> _contentSections = [];
  Set<int> _completedSections = {};
  DateTime? _startTime;
  int _totalReadingTime = 0;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _initializeContent();
  }

  void _initializeContent() {
    final metadata = widget.activity.metadata;
    final content = metadata['fullContent'] as String? ?? widget.activity.description;
    
    // Split content into sections based on headings
    final sections = content.split('\n\n');
    
    _contentSections = sections.asMap().entries.map((entry) {
      final index = entry.key;
      final text = entry.value;
      
      // Check if this looks like a heading
      final isHeading = text.trim().startsWith('#') || 
                        (text.length < 100 && text.endsWith(':'));
      
      return {
        'id': index,
        'title': isHeading ? text.replaceAll('#', '').trim() : null,
        'content': isHeading ? null : text,
        'isCompleted': false,
        'readingTime': _estimateReadingTime(text),
      };
    }).toList();
    
    // Filter out empty sections
    _contentSections = _contentSections.where((section) {
      return section['title'] != null || 
             (section['content'] != null && section['content']!.toString().trim().isNotEmpty);
    }).toList();
    
    _totalReadingTime = _contentSections.fold(
      0, 
      (sum, section) => sum + (section['readingTime'] as int),
    );
  }

  int _estimateReadingTime(String text) {
    // Average reading speed: 200 words per minute
    final words = text.split(' ').length;
    return (words / 200 * 60).ceil(); // Convert to seconds
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFF),
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
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
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => _showExitConfirmation(),
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
                            overflow: TextOverflow.ellipsis,
                          ),
                          maxLines: 1,
                        ),
                        SizedBox(height: 2),
                        ValueListenableBuilder<double>(
                          valueListenable: _progress,
                          builder: (context, progress, child) {
                            return LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.grey[200],
                              color: Color(0xFF667EEA),
                              minHeight: 4,
                              borderRadius: BorderRadius.circular(2),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12),
                  ValueListenableBuilder<int>(
                    valueListenable: _currentPage,
                    builder: (context, currentPage, child) {
                      return Text(
                        '${currentPage + 1}/${_contentSections.length}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Progress indicator with time
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: Colors.blue.shade50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.timer, size: 16, color: Colors.blue),
                      SizedBox(width: 6),
                      ValueListenableBuilder<int>(
                        valueListenable: _currentPage,
                        builder: (context, currentPage, child) {
                          final remainingSections = _contentSections
                              .skip(currentPage)
                              .toList();
                          final remainingTime = remainingSections.fold(
                            0,
                            (sum, section) => sum + (section['readingTime'] as int),
                          );
                          return Text(
                            '~${(remainingTime / 60).ceil()} min remaining',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  ValueListenableBuilder<double>(
                    valueListenable: _progress,
                    builder: (context, progress, child) {
                      return Text(
                        '${(progress * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Content Area
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _contentSections.length,
                onPageChanged: (index) {
                  _currentPage.value = index;
                  _progress.value = (index + 1) / _contentSections.length;
                  _markSectionAsRead(index);
                },
                itemBuilder: (context, index) {
                  final section = _contentSections[index];
                  return _buildContentSection(section, index);
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

                  // Next/Complete button
                  Expanded(
                    child: ValueListenableBuilder<int>(
                      valueListenable: _currentPage,
                      builder: (context, currentPage, child) {
                        final isLastPage =
                            currentPage == _contentSections.length - 1;
                        
                        return ValueListenableBuilder<bool>(
                          valueListenable: _isCompleted,
                          builder: (context, isCompleted, child) {
                            if (isCompleted) {
                              return ElevatedButton.icon(
                                onPressed: _completeActivity,
                                icon: Icon(Icons.check_circle, size: 18),
                                label: Text('Mark Complete'),
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
                                  ? _showCompletionOptions
                                  : () => _pageController.nextPage(
                                        duration: Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      ),
                              icon: Icon(
                                isLastPage ? Icons.check : Icons.arrow_forward,
                                size: 18,
                              ),
                              label: Text(isLastPage ? 'Finish' : 'Next'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF667EEA),
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

  Widget _buildContentSection(Map<String, dynamic> section, int index) {
    final isHeading = section['title'] != null;
    final isCompleted = _completedSections.contains(index);
    
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isHeading) ...[
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.label_important,
                    color: Colors.blue,
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      section['title']!,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
          ] else if (section['content'] != null) ...[
            // Checkbox for completion
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: isCompleted,
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _completedSections.add(index);
                      } else {
                        _completedSections.remove(index);
                      }
                    });
                    _updateProgress();
                  },
                  shape: CircleBorder(),
                  activeColor: Colors.green,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    section['content']!,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ],

          SizedBox(height: 20),

          // Key concepts if available
          if (widget.activity.metadata.containsKey('keyConcepts') && index == 0)
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
                  children: (widget.activity.metadata['keyConcepts']
                          as List<dynamic>)
                      .map<Widget>((concept) => Chip(
                            label: Text(
                              concept.toString(),
                              style: TextStyle(fontSize: 12),
                            ),
                            backgroundColor: Colors.blue.shade50,
                            labelStyle: TextStyle(color: Colors.blue),
                          ))
                      .toList(),
                ),
              ],
            ),

          // References if available
          if (widget.activity.metadata.containsKey('references') && index == _contentSections.length - 1)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 30),
                Text(
                  '📚 References',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 10),
                ...(widget.activity.metadata['references'] as List<dynamic>)
                    .map<Widget>((ref) => ListTile(
                          leading: Icon(Icons.link, size: 16, color: Colors.blue),
                          title: Text(
                            ref['title']?.toString() ?? 'Reference',
                            style: TextStyle(fontSize: 14),
                          ),
                          subtitle: Text(
                            ref['url']?.toString() ?? '',
                            style: TextStyle(fontSize: 12, color: Colors.blue),
                            overflow: TextOverflow.ellipsis,
                          ),
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        ))
                    .toList(),
              ],
            ),
        ],
      ),
    );
  }

  void _markSectionAsRead(int index) {
    if (!_completedSections.contains(index)) {
      setState(() {
        _completedSections.add(index);
      });
      _updateProgress();
    }
  }

  void _updateProgress() {
    final progress = _completedSections.length / _contentSections.length;
    _progress.value = progress;
    
    if (progress >= 0.7) { // Mark as mostly completed
      _isCompleted.value = true;
    }
  }

  void _showCompletionOptions() {
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
              'Complete Activity',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 15),
            Text(
              'Have you finished reading and understanding all sections?',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
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
                    child: Text('Continue Reading'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      _completeActivity();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text('Mark Complete'),
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

  void _completeActivity() {
    final endTime = DateTime.now();
    final duration = endTime.difference(_startTime!);
    
    // Calculate score based on completion and time
    final completionRate = _completedSections.length / _contentSections.length;
    final timeEfficiency = _totalReadingTime / duration.inSeconds;
    final score = (completionRate * 100 * 0.7 + 
                  (timeEfficiency > 1 ? 20 : timeEfficiency * 20)).clamp(0, 100);
    
    // Mark activity as complete in Firebase
    final firebaseService = StudyPlannerFirebaseService();
    firebaseService.markActivityComplete(
      studentId: FirebaseAuth.instance.currentUser!.uid,
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
            Icon(Icons.check_circle, size: 60, color: Colors.green),
            SizedBox(height: 15),
            Text(
              'Activity Completed!',
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
              'Great job completing this lesson!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Sections Read:', style: TextStyle(fontSize: 12)),
                Text(
                  '${_completedSections.length}/${_contentSections.length}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Time Spent:', style: TextStyle(fontSize: 12)),
                Text(
                  '${duration.inMinutes} min',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Score:', style: TextStyle(fontSize: 12)),
                Text(
                  '${score.toInt()}%',
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
              Get.back(); // Go back to planner
            },
            child: Text('Back to Planner'),
          ),
        ],
      ),
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Exit Activity?'),
        content: Text('Your progress will be saved. You can continue later.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              Get.back(); // Go back
            },
            child: Text('Exit'),
          ),
        ],
      ),
    );
  }
}