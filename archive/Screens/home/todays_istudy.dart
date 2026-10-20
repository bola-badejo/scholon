// // lib/Screens/home/components/today_study_items.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:get/get.dart';
// import 'package:isapp/features/study_guide/models/learning_profile.dart';
// import 'package:isapp/features/study_guide/study_planner_screen.dart' hide ActivityType;
// import 'package:isapp/features/auth/controllers/authentication_controller.dart';

// class TodayStudyItems extends StatefulWidget {
//   final VoidCallback? onViewAll;
  
//   const TodayStudyItems({super.key, this.onViewAll});

//   @override
//   State<TodayStudyItems> createState() => _TodayStudyItemsState();
// }

// class _TodayStudyItemsState extends State<TodayStudyItems> {
//   final AuthService _authService = Get.find<AuthService>();
  
//   List<DailyActivity> _todayActivities = [];
//   bool _isLoading = true;
//   bool _hasStudyPlan = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadTodayActivities();
//   }

//   Future<void> _loadTodayActivities() async {
//     setState(() => _isLoading = true);
    
//     try {
//       final user = await _authService.getCurrentUser();
//       if (user != null) {
//         // _todayActivities = await _plannerService.getTodayActivities(user.uid);
//         _hasStudyPlan = _todayActivities.isNotEmpty;
//       }
//     } catch (e) {
//       print('Error loading today activities: $e');
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   void _markActivityComplete(DailyActivity activity) async {
//     final user = await _authService.getCurrentUser();
//     if (user == null) return;

//     try {
//       // await _plannerService.markActivityComplete(
//       //   studentId: user.uid,
//       //   activityId: activity.id,
//       //   score: 85.0,
//       //   actualDuration: const Duration(minutes: 40),
//       //   metadata: activity.metadata,
//       // );

//       // Refresh the list
//       await _loadTodayActivities();

//       Get.snackbar(
//         '🎉 Completed!',
//         '${activity.title} marked as complete',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//       );
//     } catch (e) {
//       print('Error marking activity complete: $e');
//       Get.snackbar(
//         'Error',
//         'Failed to mark activity as complete',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }

//   void _startActivity(DailyActivity activity) {
//     Get.snackbar(
//       '🚀 Starting Activity',
//       'Opening "${activity.title}"',
//       snackPosition: SnackPosition.BOTTOM,
//       backgroundColor: Colors.blue,
//       colorText: Colors.white,
//     );
    
//     // TODO: Navigate to actual activity screen
//     // Get.to(() => ActivityScreen(activity: activity));
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return _buildLoadingState();
//     }

//     if (!_hasStudyPlan) {
//       return _buildNoStudyPlanState();
//     }

//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 "Today's Study Items",
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.grey[900],
//                 ),
//               ),
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 12,
//                   vertical: 6,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.deepPurple.shade50,
//                   borderRadius: BorderRadius.circular(15),
//                 ),
//                 child: Text(
//                   '${_todayActivities.length} activities',
//                   style: const TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.deepPurple,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),

//           // Activities List
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(color: Colors.grey.shade200),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.grey.withOpacity(0.05),
//                   blurRadius: 10,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: Column(
//               children: [
//                 // Activity Items
//                 for (int i = 0; i < _todayActivities.length && i < 3; i++)
//                   Column(
//                     children: [
//                       if (i > 0) const Divider(height: 20),
//                       _buildActivityItem(_todayActivities[i]),
//                     ],
//                   ),

//                 // View All Button
//                 if (_todayActivities.length > 3)
//                   Column(
//                     children: [
//                       const Divider(height: 20),
//                       SizedBox(
//                         width: double.infinity,
//                         child: TextButton(
//                           onPressed: widget.onViewAll ?? () {
//                             Get.toNamed('/activities');
//                           },
//                           style: TextButton.styleFrom(
//                             padding: const EdgeInsets.symmetric(vertical: 12),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           child: const Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Text(
//                                 'View All Activities',
//                                 style: TextStyle(
//                                   color: Colors.deepPurple,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                               SizedBox(width: 8),
//                               Icon(
//                                 Icons.arrow_forward,
//                                 size: 16,
//                                 color: Colors.deepPurple,
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0);
//   }

//   Widget _buildLoadingState() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             "Today's Study Items",
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey[900],
//             ),
//           ),
//           const SizedBox(height: 12),
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(color: Colors.grey.shade200),
//             ),
//             child: const Row(
//               children: [
//                 SizedBox(
//                   width: 20,
//                   height: 20,
//                   child: CircularProgressIndicator(
//                     strokeWidth: 2,
//                     color: Colors.deepPurple,
//                   ),
//                 ),
//                 SizedBox(width: 12),
//                 Text(
//                   'Loading your study plan...',
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildNoStudyPlanState() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             "Today's Study Items",
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey[900],
//             ),
//           ),
//           const SizedBox(height: 12),
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.orange.shade50,
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(color: Colors.orange.shade200),
//             ),
//             child: Column(
//               children: [
//                 Row(
//                   children: [
//                     Container(
//                       width: 40,
//                       height: 40,
//                       decoration: BoxDecoration(
//                         color: Colors.orange.shade100,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: const Icon(
//                         Icons.calendar_today,
//                         color: Colors.orange,
//                         size: 20,
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             'No Study Plan Created',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.black87,
//                             ),
//                           ),
//                           const SizedBox(height: 2),
//                           Text(
//                             'Create a personalized study plan to get started',
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.grey[600],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       Get.toNamed('/activities');
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.orange,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       elevation: 0,
//                     ),
//                     child: const Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.auto_awesome, size: 18),
//                         SizedBox(width: 8),
//                         Text(
//                           'Create Study Plan',
//                           style: TextStyle(
//                             fontWeight: FontWeight.w600,
//                             fontSize: 15,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildActivityItem(DailyActivity activity) {
//     final isCompleted = activity.isCompleted;
//     final activityColor = _getActivityColor(activity.type as ActivityType);
//     final activityIcon = _getActivityIcon(activity.type as ActivityType);

//     return Row(
//       children: [
//         // Status Indicator
//         Container(
//           width: 8,
//           height: 8,
//           decoration: BoxDecoration(
//             color: isCompleted ? Colors.green : activityColor,
//             shape: BoxShape.circle,
//           ),
//         ),
//         const SizedBox(width: 12),

//         // Activity Icon
//         Container(
//           width: 50,
//           height: 50,
//           decoration: BoxDecoration(
//             color: activityColor.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Icon(activityIcon, color: activityColor),
//         ),
//         const SizedBox(width: 12),

//         // Activity Info
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 activity.title,
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.black87,
//                   decoration: isCompleted
//                       ? TextDecoration.lineThrough
//                       : TextDecoration.none,
//                 ),
//               ),
//               const SizedBox(height: 2),
//               Text(
//                 activity.description,
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.grey[600],
//                   decoration: isCompleted
//                       ? TextDecoration.lineThrough
//                       : TextDecoration.none,
//                 ),
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//               ),
//               const SizedBox(height: 4),
//               Row(
//                 children: [
//                   Icon(
//                     Icons.access_time,
//                     size: 12,
//                     color: Colors.grey[500],
//                   ),
//                   const SizedBox(width: 4),
//                   Text(
//                     '${activity.estimatedDuration.inMinutes} min',
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.grey[500],
//                     ),
//                   ),
//                   if (activity.courseCodes.isNotEmpty) ...[
//                     const SizedBox(width: 12),
//                     Icon(
//                       Icons.school,
//                       size: 12,
//                       color: Colors.grey[500],
//                     ),
//                     const SizedBox(width: 4),
//                     Text(
//                       activity.courseCodes.first,
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.grey[500],
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ],
//           ),
//         ),

//         // Actions
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.end,
//           children: [
//             if (!isCompleted) ...[
//               OutlinedButton(
//                 onPressed: () => _startActivity(activity),
//                 style: OutlinedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 6,
//                   ),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   side: BorderSide(color: activityColor),
//                 ),
//                 child: Text(
//                   'Start',
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: activityColor,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 4),
//               TextButton(
//                 onPressed: () => _markActivityComplete(activity),
//                 style: TextButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 4,
//                   ),
//                   minimumSize: Size.zero,
//                 ),
//                 child: const Text(
//                   'Mark Done',
//                   style: TextStyle(
//                     fontSize: 11,
//                     color: Colors.grey,
//                   ),
//                 ),
//               ),
//             ] else ...[
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 12,
//                   vertical: 6,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.green.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(
//                       Icons.check,
//                       size: 12,
//                       color: Colors.green,
//                     ),
//                     const SizedBox(width: 4),
//                     Text(
//                       'Completed',
//                       style: TextStyle(
//                         fontSize: 11,
//                         color: Colors.green,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               if (activity.completedAt != null) ...[
//                 const SizedBox(height: 4),
//                 Text(
//                   _formatTime(activity.completedAt!),
//                   style: const TextStyle(
//                     fontSize: 10,
//                     color: Colors.grey,
//                   ),
//                 ),
//               ],
//             ],
//           ],
//         ),
//       ],
//     );
//   }

//   Color _getActivityColor(ActivityType type) {
//     switch (type) {
//       case ActivityType.dailyLesson:
//         return Colors.blue;
//       case ActivityType.dailyQuiz:
//         return Colors.green;
//       case ActivityType.weeklyMockTest:
//         return Colors.orange;
//       case ActivityType.monthlyExam:
//         return Colors.purple;
//       case ActivityType.practiceSession:
//         return Colors.teal;
//       case ActivityType.revisionSession:
//         return Colors.indigo;
//       case ActivityType.projectWork:
//         return Colors.deepOrange;
//       case ActivityType.readingSession:
//         return Colors.brown;
//     }
//   }

//   IconData _getActivityIcon(ActivityType type) {
//     switch (type) {
//       case ActivityType.dailyLesson:
//         return Icons.school;
//       case ActivityType.dailyQuiz:
//         return Icons.quiz;
//       case ActivityType.weeklyMockTest:
//         return Icons.assignment;
//       case ActivityType.monthlyExam:
//         return Icons.assignment_turned_in;
//       case ActivityType.practiceSession:
//         return Icons.repeat;
//       case ActivityType.revisionSession:
//         return Icons.replay;
//       case ActivityType.projectWork:
//         return Icons.work;
//       case ActivityType.readingSession:
//         return Icons.menu_book;
//     }
//   }

//   String _formatTime(DateTime date) {
//     final hour = date.hour;
//     final minute = date.minute;
//     final period = hour >= 12 ? 'PM' : 'AM';
//     final hour12 = hour % 12 == 0 ? 12 : hour % 12;
    
//     return '$hour12:${minute.toString().padLeft(2, '0')} $period';
//   }
// }