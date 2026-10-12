// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:isapp/Screens/faculty/faculty.dart';

// // ========== HELPER WIDGETS ==========
// class _InfoRow extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final String value;
//   final Color color;

//   const _InfoRow({
//     required this.icon,
//     required this.label,
//     required this.value,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16),
//       child: Row(
//         children: [
//           Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(icon, color: color, size: 20),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   label,
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey.shade600,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   value,
//                   style: const TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _ProfileStatItem extends StatelessWidget {
//   final String value;
//   final String label;
//   final IconData icon;
//   final Color color;

//   const _ProfileStatItem({
//     required this.value,
//     required this.label,
//     required this.icon,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Container(
//           width: 50,
//           height: 50,
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Icon(icon, color: color, size: 24),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: color,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 12,
//             color: Colors.grey.shade600,
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _MetricItem extends StatelessWidget {
//   final String value;
//   final String label;
//   final Color color;
//   final IconData icon;

//   const _MetricItem({
//     required this.value,
//     required this.label,
//     required this.color,
//     required this.icon,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Container(
//           width: 50,
//           height: 50,
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Icon(icon, color: color, size: 28),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: color,
//           ),
//         ),
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 12,
//             color: Colors.grey.shade600,
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _StudentListItem extends StatelessWidget {
//   final StudentProfile student;
//   final VoidCallback onTap;

//   const _StudentListItem({required this.student, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: Colors.grey.shade200),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.05),
//               blurRadius: 5,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Row(
//             children: [
//               CircleAvatar(
//                 backgroundColor: Colors.purple.withOpacity(0.1),
//                 child: Text(
//                   student.name.substring(0, 1).toUpperCase(),
//                   style: const TextStyle(
//                     color: Colors.purple,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       student.name,
//                       style: const TextStyle(
//                         fontWeight: FontWeight.w600,
//                         fontSize: 16,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       student.gradeLevel.displayName,
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey.shade600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               IconButton(
//                 onPressed: onTap,
//                 icon: const Icon(Icons.chevron_right_rounded),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _TaskCard extends StatelessWidget {
//   final StaffTask task;

//   const _TaskCard({required this.task});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.shade200),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.05),
//             blurRadius: 5,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   task.title,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.w600,
//                     fontSize: 16,
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 8,
//                     vertical: 4,
//                   ),
//                   decoration: BoxDecoration(
//                     color: task.status.color.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     task.status.displayName,
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: task.status.color,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             Text(
//               task.description,
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey.shade600,
//               ),
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//             ),
//             const SizedBox(height: 12),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     Icon(
//                       Icons.calendar_today_rounded,
//                       size: 16,
//                       color: Colors.grey.shade500,
//                     ),
//                     const SizedBox(width: 4),
//                     Text(
//                       'Due: ${_formatDate(task.dueDate)}',
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.grey.shade600,
//                       ),
//                     ),
//                   ],
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 8,
//                     vertical: 4,
//                   ),
//                   decoration: BoxDecoration(
//                     color: task.priority.color.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     task.priority.displayName,
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: task.priority.color,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   String _formatDate(DateTime date) {
//     return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
//   }
// }

// class _ParentListItem extends StatelessWidget {
//   final ParentProfile parent;
//   final VoidCallback onTap;

//   const _ParentListItem({required this.parent, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: Colors.grey.shade200),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.05),
//               blurRadius: 5,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Row(
//             children: [
//               CircleAvatar(
//                 backgroundColor: Colors.deepOrange.withOpacity(0.1),
//                 child: Text(
//                   parent.name.substring(0, 1).toUpperCase(),
//                   style: const TextStyle(
//                     color: Colors.deepOrange,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Text(
//                           parent.name,
//                           style: const TextStyle(
//                             fontWeight: FontWeight.w600,
//                             fontSize: 16,
//                           ),
//                         ),
//                         if (parent.isPrimaryGuardian)
//                           Container(
//                             margin: const EdgeInsets.only(left: 8),
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 6,
//                               vertical: 2,
//                             ),
//                             decoration: BoxDecoration(
//                               color: Colors.green.withOpacity(0.1),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: const Text(
//                               'Primary',
//                               style: TextStyle(
//                                 fontSize: 10,
//                                 color: Colors.green,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                       ],
//                     ),
//                     const SizedBox(height: 4),
//                     if (parent.relationship != null)
//                       Text(
//                         parent.relationship!,
//                         style: TextStyle(
//                           fontSize: 13,
//                           color: Colors.grey.shade600,
//                         ),
//                       ),
//                     if (parent.childNames.isNotEmpty)
//                       Text(
//                         'Children: ${parent.childNames.length}',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey.shade500,
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//               IconButton(
//                 onPressed: onTap,
//                 icon: const Icon(Icons.chevron_right_rounded),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _ParentSelectionCard extends StatelessWidget {
//   final ParentProfile parent;
//   final VoidCallback onSelect;

//   const _ParentSelectionCard({
//     required this.parent,
//     required this.onSelect,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Row(
//           children: [
//             CircleAvatar(
//               backgroundColor: Colors.deepOrange.withOpacity(0.1),
//               child: Text(
//                 parent.name.substring(0, 1).toUpperCase(),
//                 style: const TextStyle(
//                   color: Colors.deepOrange,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     parent.name,
//                     style: const TextStyle(
//                       fontWeight: FontWeight.w600,
//                       fontSize: 16,
//                     ),
//                   ),
//                   if (parent.relationship != null)
//                     Text(
//                       parent.relationship!,
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey.shade600,
//                       ),
//                     ),
//                   if (parent.childNames.isNotEmpty)
//                     Text(
//                       'Has ${parent.childNames.length} children',
//                       style: TextStyle(
//                         fontSize: 13,
//                         color: Colors.grey.shade500,
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//             ElevatedButton(
//               onPressed: onSelect,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.deepOrange,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               child: const Text(
//                 'Select',
//                 style: TextStyle(color: Colors.white),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _TrendItem extends StatelessWidget {
//   final String label;
//   final int current;
//   final int previous;
//   final Color color;

//   const _TrendItem({
//     required this.label,
//     required this.current,
//     required this.previous,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final change = current - previous;
//     final isPositive = change > 0;

//     return Column(
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 12,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           '$current%',
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: color,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               isPositive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
//               size: 12,
//               color: isPositive ? Colors.green : Colors.red,
//             ),
//             Text(
//               '${isPositive ? '+' : ''}$change%',
//               style: TextStyle(
//                 fontSize: 11,
//                 color: isPositive ? Colors.green : Colors.red,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }

// class _AttendanceStatItem extends StatelessWidget {
//   final String label;
//   final int value;
//   final int total;
//   final Color color;
//   final IconData icon;

//   const _AttendanceStatItem({
//     required this.label,
//     required this.value,
//     required this.total,
//     required this.color,
//     required this.icon,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final percentage = total > 0 ? (value / total * 100).round() : 0;

//     return Column(
//       children: [
//         Container(
//           width: 60,
//           height: 60,
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: Icon(icon, color: color, size: 28),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           '$value',
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: color,
//           ),
//         ),
//         Text(
//           '$percentage%',
//           style: TextStyle(
//             fontSize: 12,
//             color: color,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 12,
//             color: Colors.grey,
//           ),
//         ),
//       ],
//     );
//   }
// }

// // ========== STRING EXTENSION ==========
// extension StringExtension on String {
//   String? get capitalizeFirst {
//     if (isEmpty) return null;
//     return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
//   }
// }

// // ========== STAFF PROFILE PAGE ==========
// class StaffProfilePage extends StatefulWidget {
//   final String staffId;

//   const StaffProfilePage({super.key, required this.staffId});

//   @override
//   State<StaffProfilePage> createState() => _StaffProfilePageState();
// }

// class _StaffProfilePageState extends State<StaffProfilePage>
//     with SingleTickerProviderStateMixin {
//   final FacultyController controller = Get.find();
//   late TabController _tabController;
//   final Rx<StaffProfile?> staffProfile = Rx<StaffProfile?>(null);
//   final RxBool isLoading = false.obs;
//   final RxList<StudentProfile> assignedStudents = <StudentProfile>[].obs;
//   final RxList<StaffTask> staffTasks = <StaffTask>[].obs;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 4, vsync: this);
//     _loadStaffProfile();
//   }

//   Future<void> _loadStaffProfile() async {
//     try {
//       isLoading.value = true;
//       final profile = await controller.getStaffProfile(widget.staffId);
//       staffProfile.value = profile;
      
//       if (profile != null) {
//         await _loadAssignedStudents();
//         await _loadStaffTasks();
//       }
//     } catch (e) {
//       print('Error loading staff profile: $e');
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   Future<void> _loadAssignedStudents() async {
//     try {
//       assignedStudents.value = controller.studentList.take(5).toList();
//     } catch (e) {
//       print('Error loading assigned students: $e');
//     }
//   }

//   Future<void> _loadStaffTasks() async {
//     try {
//       staffTasks.value = [
//         StaffTask(
//           id: 'task1',
//           title: 'Prepare Lesson Plan',
//           description: 'Create lesson plan for next week\'s classes',
//           assignedBy: 'Principal',
//           assignedTo: staffProfile.value?.name ?? '',
//           assignedDate: DateTime.now().subtract(const Duration(days: 2)),
//           dueDate: DateTime.now().add(const Duration(days: 3)),
//           status: TaskStatus.inProgress,
//           priority: TaskPriority.high,
//         ),
//         StaffTask(
//           id: 'task2',
//           title: 'Grade Assignments',
//           description: 'Grade student assignments for Mathematics',
//           assignedBy: 'Head of Department',
//           assignedTo: staffProfile.value?.name ?? '',
//           assignedDate: DateTime.now().subtract(const Duration(days: 1)),
//           dueDate: DateTime.now().add(const Duration(days: 2)),
//           status: TaskStatus.pending,
//           priority: TaskPriority.medium,
//         ),
//       ];
//     } catch (e) {
//       print('Error loading staff tasks: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Obx(() {
//         final profile = staffProfile.value;

//         if (isLoading.value) {
//           return _buildLoadingState();
//         }

//         if (profile == null) {
//           return _buildNotFoundState();
//         }

//         return NestedScrollView(
//           headerSliverBuilder: (context, innerBoxIsScrolled) {
//             return [
//               SliverAppBar(
//                 expandedHeight: 280,
//                 floating: true,
//                 pinned: true,
//                 backgroundColor: Colors.white,
//                 foregroundColor: Colors.black,
//                 elevation: 0,
//                 flexibleSpace: FlexibleSpaceBar(
//                   collapseMode: CollapseMode.pin,
//                   background: _buildProfileHeader(profile),
//                 ),
//                 bottom: PreferredSize(
//                   preferredSize: const Size.fromHeight(50),
//                   child: Container(
//                     color: Colors.white,
//                     child: TabBar(
//                       controller: _tabController,
//                       labelColor: Colors.deepPurple,
//                       unselectedLabelColor: Colors.grey,
//                       indicatorColor: Colors.deepPurple,
//                       indicatorSize: TabBarIndicatorSize.tab,
//                       indicatorWeight: 3,
//                       tabs: const [
//                         Tab(text: 'Overview'),
//                         Tab(text: 'Students'),
//                         Tab(text: 'Tasks'),
//                         Tab(text: 'Performance'),
//                       ],
//                     ),
//                   ),
//                 ),
//                 actions: [
//                   IconButton(
//                     onPressed: () => _showEditStaffDialog(profile),
//                     icon: const Icon(Icons.edit_rounded, color: Colors.deepPurple),
//                     tooltip: 'Edit Profile',
//                   ),
//                   IconButton(
//                     onPressed: _showActionsMenu,
//                     icon: const Icon(Icons.more_vert_rounded, color: Colors.deepPurple),
//                     tooltip: 'More Actions',
//                   ),
//                 ],
//               ),
//             ];
//           },
//           body: TabBarView(
//             controller: _tabController,
//             children: [
//               _buildOverviewTab(profile),
//               _buildStudentsTab(),
//               _buildTasksTab(),
//               _buildPerformanceTab(profile),
//             ],
//           ),
//         );
//       }),
//     );
//   }

//   Widget _buildProfileHeader(StaffProfile profile) {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [
//             profile.department.color.withOpacity(0.1),
//             Colors.white,
//           ],
//         ),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.end,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   width: 90,
//                   height: 90,
//                   decoration: BoxDecoration(
//                     color: profile.department.color.withOpacity(0.2),
//                     shape: BoxShape.circle,
//                     border: Border.all(
//                       color: profile.department.color,
//                       width: 3,
//                     ),
//                   ),
//                   child: profile.profileImageUrl != null
//                       ? CircleAvatar(
//                           backgroundImage: NetworkImage(profile.profileImageUrl!),
//                           radius: 45,
//                         )
//                       : Center(
//                           child: Text(
//                             profile.name.substring(0, 1).toUpperCase(),
//                             style: TextStyle(
//                               fontSize: 36,
//                               fontWeight: FontWeight.bold,
//                               color: profile.department.color,
//                             ),
//                           ),
//                         ),
//                 ),

//                 const SizedBox(width: 20),

//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         profile.name,
//                         style: const TextStyle(
//                           fontSize: 26,
//                           fontWeight: FontWeight.w800,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Row(
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 12,
//                               vertical: 6,
//                             ),
//                             decoration: BoxDecoration(
//                               color: profile.status.color.withOpacity(0.1),
//                               borderRadius: BorderRadius.circular(20),
//                             ),
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Icon(
//                                   profile.status.icon,
//                                   size: 14,
//                                   color: profile.status.color,
//                                 ),
//                                 const SizedBox(width: 6),
//                                 Text(
//                                   profile.status.displayName,
//                                   style: TextStyle(
//                                     fontSize: 13,
//                                     color: profile.status.color,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 12,
//                               vertical: 6,
//                             ),
//                             decoration: BoxDecoration(
//                               color: profile.department.color.withOpacity(0.1),
//                               borderRadius: BorderRadius.circular(20),
//                             ),
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Icon(
//                                   profile.department.icon,
//                                   size: 14,
//                                   color: profile.department.color,
//                                 ),
//                                 const SizedBox(width: 6),
//                                 Text(
//                                   profile.department.name,
//                                   style: TextStyle(
//                                     fontSize: 13,
//                                     color: profile.department.color,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 24),

//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 _ProfileStatItem(
//                   value: profile.experienceYears,
//                   label: 'Experience',
//                   icon: Icons.work_history_rounded,
//                   color: Colors.blue,
//                 ),
//                 _ProfileStatItem(
//                   value: profile.assignedClasses.length.toString(),
//                   label: 'Classes',
//                   icon: Icons.class_rounded,
//                   color: Colors.green,
//                 ),
//                 _ProfileStatItem(
//                   value: assignedStudents.length.toString(),
//                   label: 'Students',
//                   icon: Icons.people_rounded,
//                   color: Colors.orange,
//                 ),
//                 _ProfileStatItem(
//                   value: profile.isFullTime ? 'Full Time' : 'Part Time',
//                   label: 'Employment',
//                   icon: Icons.schedule_rounded,
//                   color: Colors.purple,
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildOverviewTab(StaffProfile profile) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildInfoCard(
//             title: 'Professional Details',
//             icon: Icons.business_center_rounded,
//             color: Colors.blue,
//             children: [
//               _InfoRow(
//                 icon: Icons.work_rounded,
//                 label: 'Position',
//                 value: profile.position.title,
//                 color: Colors.blue,
//               ),
//               _InfoRow(
//                 icon: Icons.badge_rounded,
//                 label: 'Employee ID',
//                 value: profile.employeeId ?? 'Not assigned',
//                 color: Colors.green,
//               ),
//               _InfoRow(
//                 icon: Icons.calendar_today_rounded,
//                 label: 'Joined Date',
//                 value: _formatDate(profile.joinedDate),
//                 color: Colors.orange,
//               ),
//               if (profile.lastPromotion != null)
//                 _InfoRow(
//                   icon: Icons.trending_up_rounded,
//                   label: 'Last Promotion',
//                   value: _formatDate(profile.lastPromotion!),
//                   color: Colors.purple,
//                 ),
//               if (profile.officeLocation != null)
//                 _InfoRow(
//                   icon: Icons.location_on_rounded,
//                   label: 'Office Location',
//                   value: profile.officeLocation!,
//                   color: Colors.red,
//                 ),
//             ],
//           ),

//           const SizedBox(height: 20),

//           _buildInfoCard(
//             title: 'Contact Information',
//             icon: Icons.contact_page_rounded,
//             color: Colors.green,
//             children: [
//               _InfoRow(
//                 icon: Icons.email_rounded,
//                 label: 'Email',
//                 value: profile.email,
//                 color: Colors.red,
//               ),
//               if (profile.phone != null)
//                 _InfoRow(
//                   icon: Icons.phone_rounded,
//                   label: 'Phone',
//                   value: profile.phone!,
//                   color: Colors.green,
//                 ),
//               if (profile.emergencyContact != null)
//                 _InfoRow(
//                   icon: Icons.emergency_rounded,
//                   label: 'Emergency Contact',
//                   value: profile.emergencyContact!,
//                   color: Colors.orange,
//                 ),
//             ],
//           ),

//           const SizedBox(height: 20),

//           if (profile.qualifications.isNotEmpty)
//             _buildInfoCard(
//               title: 'Qualifications',
//               icon: Icons.school_rounded,
//               color: Colors.purple,
//               children: [
//                 ...profile.qualifications.map((qualification) {
//                   return Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: Row(
//                       children: [
//                         Icon(Icons.check_circle_rounded,
//                             size: 16, color: Colors.green),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Text(
//                             qualification,
//                             style: const TextStyle(fontSize: 14),
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 }).toList(),
//               ],
//             ),

//           const SizedBox(height: 20),

//           if (profile.responsibilities.isNotEmpty)
//             _buildInfoCard(
//               title: 'Responsibilities',
//               icon: Icons.task_rounded,
//               color: Colors.orange,
//               children: [
//                 ...profile.responsibilities.map((responsibility) {
//                   return Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: Row(
//                       children: [
//                         Icon(Icons.circle_rounded,
//                             size: 8, color: Colors.blue),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Text(
//                             responsibility,
//                             style: const TextStyle(fontSize: 14),
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 }).toList(),
//               ],
//             ),

//           const SizedBox(height: 20),

//           if (profile.bio != null && profile.bio!.isNotEmpty)
//             _buildInfoCard(
//               title: 'About',
//               icon: Icons.person_rounded,
//               color: Colors.teal,
//               children: [
//                 Text(
//                   profile.bio!,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     color: Colors.black87,
//                     height: 1.5,
//                   ),
//                 ),
//               ],
//             ),

//           const SizedBox(height: 40),
//         ],
//       ),
//     );
//   }

//   Widget _buildStudentsTab() {
//     return Obx(() {
//       if (assignedStudents.isEmpty) {
//         return Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.people_outline_rounded,
//                   size: 80, color: Colors.grey.shade300),
//               const SizedBox(height: 20),
//               const Text(
//                 'No assigned students',
//                 style: TextStyle(
//                   fontSize: 18,
//                   color: Colors.grey,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 'Students will appear here when assigned',
//                 style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
//               ),
//             ],
//           ),
//         );
//       }

//       return ListView.builder(
//         padding: const EdgeInsets.all(20),
//         itemCount: assignedStudents.length,
//         itemBuilder: (context, index) {
//           final student = assignedStudents[index];
//           return Padding(
//             padding: const EdgeInsets.only(bottom: 12),
//             child: _StudentListItem(
//               student: student,
//               onTap: () => Get.to(
//                 () => StudentProfilePage(studentId: student.id),
//               ),
//             ),
//           );
//         },
//       );
//     });
//   }

//   Widget _buildTasksTab() {
//     return Obx(() {
//       if (staffTasks.isEmpty) {
//         return Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.task_outlined, size: 80, color: Colors.grey.shade300),
//               const SizedBox(height: 20),
//               const Text(
//                 'No tasks assigned',
//                 style: TextStyle(
//                   fontSize: 18,
//                   color: Colors.grey,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 'Tasks will appear here when assigned',
//                 style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
//               ),
//             ],
//           ),
//         );
//       }

//       return ListView.builder(
//         padding: const EdgeInsets.all(20),
//         itemCount: staffTasks.length,
//         itemBuilder: (context, index) {
//           final task = staffTasks[index];
//           return Padding(
//             padding: const EdgeInsets.only(bottom: 12),
//             child: _TaskCard(task: task),
//           );
//         },
//       );
//     });
//   }

//   Widget _buildPerformanceTab(StaffProfile profile) {
//     final metrics = profile.performanceMetrics;
    
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildInfoCard(
//             title: 'Performance Summary',
//             icon: Icons.assessment_rounded,
//             color: Colors.deepPurple,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   _MetricItem(
//                     value: metrics['rating']?.toString() ?? 'N/A',
//                     label: 'Rating',
//                     color: Colors.blue,
//                     icon: Icons.star_rounded,
//                   ),
//                   _MetricItem(
//                     value: metrics['attendance']?.toString() ?? 'N/A',
//                     label: 'Attendance %',
//                     color: Colors.green,
//                     icon: Icons.event_available_rounded,
//                   ),
//                   _MetricItem(
//                     value: metrics['productivity']?.toString() ?? 'N/A',
//                     label: 'Productivity',
//                     color: Colors.orange,
//                     icon: Icons.trending_up_rounded,
//                   ),
//                 ],
//               ),
//             ],
//           ),

//           const SizedBox(height: 20),

//           _buildInfoCard(
//             title: 'Key Metrics',
//             icon: Icons.analytics_rounded,
//             color: Colors.blue,
//             children: [
//               _buildMetricRow('Student Satisfaction', metrics['studentSatisfaction'] ?? 0, Colors.green),
//               _buildMetricRow('Class Completion', metrics['classCompletion'] ?? 0, Colors.blue),
//               _buildMetricRow('Grading Timeliness', metrics['gradingTimeliness'] ?? 0, Colors.orange),
//               _buildMetricRow('Meeting Attendance', metrics['meetingAttendance'] ?? 0, Colors.purple),
//               _buildMetricRow('Professional Development', metrics['professionalDevelopment'] ?? 0, Colors.red),
//             ],
//           ),

//           const SizedBox(height: 20),

//           if (profile.nextReviewDate != null)
//             _buildInfoCard(
//               title: 'Next Review',
//               icon: Icons.calendar_month_rounded,
//               color: Colors.green,
//               children: [
//                 Row(
//                   children: [
//                     Icon(Icons.calendar_today_rounded, color: Colors.green),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             _formatDate(profile.nextReviewDate!),
//                             style: const TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                           Text(
//                             '${profile.nextReviewDate!.difference(DateTime.now()).inDays} days remaining',
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.grey.shade600,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),

//           const SizedBox(height: 20),

//           if (metrics['achievements'] != null)
//             _buildInfoCard(
//               title: 'Recent Achievements',
//               icon: Icons.emoji_events_rounded,
//               color: Colors.amber,
//               children: [
//                 ...(metrics['achievements'] as List).map((achievement) {
//                   return Padding(
//                     padding: const EdgeInsets.only(bottom: 12),
//                     child: Row(
//                       children: [
//                         Icon(Icons.check_circle_rounded,
//                             color: Colors.green, size: 20),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Text(
//                             achievement.toString(),
//                             style: const TextStyle(fontSize: 14),
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 }).toList(),
//               ],
//             ),

//           const SizedBox(height: 40),
//         ],
//       ),
//     );
//   }

//   Widget _buildMetricRow(String label, dynamic value, Color color) {
//     final numericValue = value is num ? value.toDouble() : 0.0;
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 label,
//                 style: const TextStyle(
//                   fontWeight: FontWeight.w500,
//                   fontSize: 14,
//                 ),
//               ),
//               Text(
//                 '${numericValue.toStringAsFixed(1)}%',
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: color,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           LinearProgressIndicator(
//             value: numericValue / 100,
//             backgroundColor: Colors.grey.shade200,
//             color: color,
//             minHeight: 6,
//             borderRadius: BorderRadius.circular(3),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildLoadingState() {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(
//               valueColor: AlwaysStoppedAnimation(Colors.deepPurple),
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               'Loading profile...',
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.grey,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildNotFoundState() {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text('Staff Profile'),
//         leading: IconButton(
//           onPressed: () => Get.back(),
//           icon: const Icon(Icons.arrow_back_rounded),
//         ),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.person_off_rounded,
//                 size: 80, color: Colors.grey.shade300),
//             const SizedBox(height: 20),
//             const Text(
//               'Staff profile not found',
//               style: TextStyle(
//                 fontSize: 18,
//                 color: Colors.grey,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'The requested staff profile does not exist',
//               style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton(
//               onPressed: () => Get.back(),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.deepPurple,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//               ),
//               child: const Text(
//                 'Go Back',
//                 style: TextStyle(color: Colors.white),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoCard({
//     required String title,
//     required IconData icon,
//     required Color color,
//     required List<Widget> children,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.grey.shade100),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   width: 40,
//                   height: 40,
//                   decoration: BoxDecoration(
//                     color: color.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Icon(icon, color: color, size: 22),
//                 ),
//                 const SizedBox(width: 12),
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w700,
//                     color: Colors.black87,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             ...children,
//           ],
//         ),
//       ),
//     );
//   }

//   void _showEditStaffDialog(StaffProfile profile) {
//     Get.bottomSheet(
//       Container(
//         height: Get.height * 0.4,
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
//         ),
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Edit Staff Profile',
//               style: TextStyle(
//                 fontSize: 22,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//             const SizedBox(height: 20),
//             ListTile(
//               leading: Container(
//                 width: 40,
//                 height: 40,
//                 decoration: BoxDecoration(
//                   color: Colors.blue.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: const Icon(Icons.edit_rounded, color: Colors.blue),
//               ),
//               title: const Text('Edit Information'),
//               subtitle: const Text('Update personal and professional details'),
//               onTap: () {
//                 Get.back();
//                 // Get.to(() => CreateStaffForm(staff: profile));
//               },
//             ),
//             ListTile(
//               leading: Container(
//                 width: 40,
//                 height: 40,
//                 decoration: BoxDecoration(
//                   color: Colors.green.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: const Icon(Icons.assignment_rounded, color: Colors.green),
//               ),
//               title: const Text('Manage Tasks'),
//               subtitle: const Text('Assign or update tasks'),
//               onTap: () {
//                 Get.back();
//                 Get.snackbar(
//                   'Coming Soon',
//                   'Task management will be available soon',
//                   backgroundColor: Colors.deepPurple,
//                   colorText: Colors.white,
//                 );
//               },
//             ),
//             ListTile(
//               leading: Container(
//                 width: 40,
//                 height: 40,
//                 decoration: BoxDecoration(
//                   color: Colors.orange.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: const Icon(Icons.people_alt_rounded, color: Colors.orange),
//               ),
//               title: const Text('Assign Students'),
//               subtitle: const Text('Assign students to this staff member'),
//               onTap: () {
//                 Get.back();
//                 Get.snackbar(
//                   'Coming Soon',
//                   'Student assignment will be available soon',
//                   backgroundColor: Colors.deepPurple,
//                   colorText: Colors.white,
//                 );
//               },
//             ),
//             const SizedBox(height: 20),
//             SizedBox(
//               width: double.infinity,
//               child: OutlinedButton(
//                 onPressed: () => Get.back(),
//                 style: OutlinedButton.styleFrom(
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   side: BorderSide(color: Colors.grey.shade300),
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                 ),
//                 child: const Text('Cancel'),
//               ),
//             ),
//           ],
//         ),
//       ),
//       isScrollControlled: true,
//     );
//   }

//   void _showActionsMenu() {
//     Get.bottomSheet(
//       Container(
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
//         ),
//         child: SafeArea(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               ListTile(
//                 leading: const Icon(Icons.print_rounded, color: Colors.blue),
//                 title: const Text('Print Profile'),
//                 onTap: () {
//                   Get.back();
//                   Get.snackbar(
//                     'Coming Soon',
//                     'Print feature will be available soon',
//                     backgroundColor: Colors.blue,
//                     colorText: Colors.white,
//                   );
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.share_rounded, color: Colors.green),
//                 title: const Text('Share Profile'),
//                 onTap: () {
//                   Get.back();
//                   Get.snackbar(
//                     'Coming Soon',
//                     'Share feature will be available soon',
//                     backgroundColor: Colors.green,
//                     colorText: Colors.white,
//                   );
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.message_rounded, color: Colors.orange),
//                 title: const Text('Send Message'),
//                 onTap: () {
//                   Get.back();
//                   Get.snackbar(
//                     'Coming Soon',
//                     'Messaging will be available soon',
//                     backgroundColor: Colors.orange,
//                     colorText: Colors.white,
//                   );
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.block_rounded, color: Colors.red),
//                 title: const Text('Deactivate Account'),
//                 onTap: () {
//                   Get.back();
//                   _showDeactivateDialog();
//                 },
//               ),
//               Container(
//                 height: 1,
//                 color: Colors.grey.shade200,
//               ),
//               TextButton(
//                 onPressed: () => Get.back(),
//                 child: const Text('Cancel'),
//               ),
//               const SizedBox(height: 8),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _showDeactivateDialog() {
//     Get.dialog(
//       AlertDialog(
//         title: const Text('Deactivate Account'),
//         content: const Text(
//           'Are you sure you want to deactivate this staff account? '
//           'They will not be able to access the system until reactivated.',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () async {
//               Get.back();
//               try {
//                 await controller.updateStaffProfile(staffProfile.value!.id, {
//                   'status': 'Suspended',
//                   'updatedAt': Timestamp.now(),
//                 });
//                 Get.snackbar(
//                   'Account Deactivated',
//                   'Staff account has been deactivated',
//                   backgroundColor: Colors.red,
//                   colorText: Colors.white,
//                 );
//                 await _loadStaffProfile();
//               } catch (e) {
//                 Get.snackbar(
//                   'Error',
//                   'Failed to deactivate account',
//                   backgroundColor: Colors.red,
//                   colorText: Colors.white,
//                 );
//               }
//             },
//             child: const Text(
//               'Deactivate',
//               style: TextStyle(color: Colors.red),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _formatDate(DateTime date) {
//     final now = DateTime.now();
//     final difference = now.difference(date);
    
//     if (difference.inDays == 0) return 'Today';
//     if (difference.inDays == 1) return 'Yesterday';
//     if (difference.inDays < 7) return '${difference.inDays} days ago';
//     if (difference.inDays < 30) return '${(difference.inDays / 7).floor()} weeks ago';
    
//     return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
// }

// // ========== STUDENT PROFILE PAGE ==========
// class StudentProfilePage extends StatefulWidget {
//   final String studentId;

//   const StudentProfilePage({super.key, required this.studentId});

//   @override
//   State<StudentProfilePage> createState() => _StudentProfilePageState();
// }

// class _StudentProfilePageState extends State<StudentProfilePage>
//     with SingleTickerProviderStateMixin {
//   final FacultyController controller = Get.find();
//   late TabController _tabController;
//   final Rx<StudentProfile?> studentProfile = Rx<StudentProfile?>(null);
//   final RxBool isLoading = false.obs;
//   final RxList<ParentProfile> parents = <ParentProfile>[].obs;
//   final RxList<StaffProfile> teachers = <StaffProfile>[].obs;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 4, vsync: this);
//     _loadStudentProfile();
//   }

//   Future<void> _loadStudentProfile() async {
//     try {
//       isLoading.value = true;
//       final profile = await controller.getStudentProfile(widget.studentId);
//       studentProfile.value = profile;
      
//       if (profile != null) {
//         await _loadParents();
//         await _loadTeachers();
//       }
//     } catch (e) {
//       print('Error loading student profile: $e');
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   Future<void> _loadParents() async {
//     try {
//       final parentsList = <ParentProfile>[];
//       for (final parentId in studentProfile.value!.parentIds) {
//         final parent = await controller.getParentProfile(parentId);
//         if (parent != null) {
//           parentsList.add(parent);
//         }
//       }
//       parents.value = parentsList;
//     } catch (e) {
//       print('Error loading parents: $e');
//     }
//   }

//   Future<void> _loadTeachers() async {
//     try {
//       teachers.value = controller.staffList
//           .where((staff) => staff.position == Position.teacher)
//           .take(3)
//           .toList();
//     } catch (e) {
//       print('Error loading teachers: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Obx(() {
//         final profile = studentProfile.value;

//         if (isLoading.value) {
//           return _buildLoadingState();
//         }

//         if (profile == null) {
//           return _buildNotFoundState();
//         }

//         return NestedScrollView(
//           headerSliverBuilder: (context, innerBoxIsScrolled) {
//             return [
//               SliverAppBar(
//                 expandedHeight: 300,
//                 floating: true,
//                 pinned: true,
//                 backgroundColor: Colors.white,
//                 foregroundColor: Colors.black,
//                 elevation: 0,
//                 flexibleSpace: FlexibleSpaceBar(
//                   collapseMode: CollapseMode.pin,
//                   background: _buildProfileHeader(profile),
//                 ),
//                 bottom: PreferredSize(
//                   preferredSize: const Size.fromHeight(50),
//                   child: Container(
//                     color: Colors.white,
//                     child: TabBar(
//                       controller: _tabController,
//                       labelColor: Colors.purple,
//                       unselectedLabelColor: Colors.grey,
//                       indicatorColor: Colors.purple,
//                       indicatorSize: TabBarIndicatorSize.tab,
//                       indicatorWeight: 3,
//                       tabs: const [
//                         Tab(text: 'Overview'),
//                         Tab(text: 'Academics'),
//                         Tab(text: 'Attendance'),
//                         Tab(text: 'Parents'),
//                       ],
//                     ),
//                   ),
//                 ),
//                 actions: [
//                   IconButton(
//                     onPressed: () => _showEditStudentDialog(profile),
//                     icon: const Icon(Icons.edit_rounded, color: Colors.purple),
//                     tooltip: 'Edit Profile',
//                   ),
//                   IconButton(
//                     onPressed: _showStudentActionsMenu,
//                     icon: const Icon(Icons.more_vert_rounded, color: Colors.purple),
//                     tooltip: 'More Actions',
//                   ),
//                 ],
//               ),
//             ];
//           },
//           body: TabBarView(
//             controller: _tabController,
//             children: [
//               _buildOverviewTab(profile),
//               _buildAcademicsTab(profile),
//               _buildAttendanceTab(profile),
//               _buildParentsTab(),
//             ],
//           ),
//         );
//       }),
//     );
//   }

//   Widget _buildProfileHeader(StudentProfile profile) {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [
//             Colors.purple.withOpacity(0.1),
//             Colors.white,
//           ],
//         ),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.end,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   width: 90,
//                   height: 90,
//                   decoration: BoxDecoration(
//                     color: Colors.purple.withOpacity(0.2),
//                     shape: BoxShape.circle,
//                     border: Border.all(
//                       color: Colors.purple,
//                       width: 3,
//                     ),
//                   ),
//                   child: profile.profileImageUrl != null
//                       ? CircleAvatar(
//                           backgroundImage: NetworkImage(profile.profileImageUrl!),
//                           radius: 45,
//                         )
//                       : Center(
//                           child: Text(
//                             profile.name.substring(0, 1).toUpperCase(),
//                             style: const TextStyle(
//                               fontSize: 36,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.purple,
//                             ),
//                           ),
//                         ),
//                 ),
//                 const SizedBox(width: 20),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         profile.name,
//                         style: const TextStyle(
//                           fontSize: 26,
//                           fontWeight: FontWeight.w800,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Row(
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 12,
//                               vertical: 6,
//                             ),
//                             decoration: BoxDecoration(
//                               color: profile.status.color.withOpacity(0.1),
//                               borderRadius: BorderRadius.circular(20),
//                             ),
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Icon(
//                                   profile.status.icon,
//                                   size: 14,
//                                   color: profile.status.color,
//                                 ),
//                                 const SizedBox(width: 6),
//                                 Text(
//                                   profile.status.displayName,
//                                   style: TextStyle(
//                                     fontSize: 13,
//                                     color: profile.status.color,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 12,
//                               vertical: 6,
//                             ),
//                             decoration: BoxDecoration(
//                               color: Colors.purple.withOpacity(0.1),
//                               borderRadius: BorderRadius.circular(20),
//                             ),
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Icon(
//                                   Icons.school_rounded,
//                                   size: 14,
//                                   color: Colors.purple,
//                                 ),
//                                 const SizedBox(width: 6),
//                                 Text(
//                                   profile.gradeLevel.displayName,
//                                   style: const TextStyle(
//                                     fontSize: 13,
//                                     color: Colors.purple,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 24),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 _ProfileStatItem(
//                   value: profile.studentId,
//                   label: 'Student ID',
//                   icon: Icons.badge_rounded,
//                   color: Colors.blue,
//                 ),
//                 _ProfileStatItem(
//                   value: profile.age.toString(),
//                   label: 'Age',
//                   icon: Icons.person_rounded,
//                   color: Colors.green,
//                 ),
//                 _ProfileStatItem(
//                   value: profile.averageGrade.toStringAsFixed(1),
//                   label: 'GPA',
//                   icon: Icons.grade_rounded,
//                   color: Colors.orange,
//                 ),
//                 _ProfileStatItem(
//                   value: profile.attendancePercentage,
//                   label: 'Attendance',
//                   icon: Icons.event_available_rounded,
//                   color: Colors.purple,
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildOverviewTab(StudentProfile profile) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildInfoCard(
//             title: 'Personal Information',
//             icon: Icons.person_rounded,
//             color: Colors.purple,
//             children: [
//               _InfoRow(
//                 icon: Icons.person_rounded,
//                 label: 'Full Name',
//                 value: profile.name,
//                 color: Colors.purple,
//               ),
//               _InfoRow(
//                 icon: Icons.email_rounded,
//                 label: 'Email',
//                 value: profile.email,
//                 color: Colors.red,
//               ),
//               if (profile.phone != null)
//                 _InfoRow(
//                   icon: Icons.phone_rounded,
//                   label: 'Phone',
//                   value: profile.phone!,
//                   color: Colors.green,
//                 ),
//               if (profile.dateOfBirth != null)
//                 _InfoRow(
//                   icon: Icons.cake_rounded,
//                   label: 'Date of Birth',
//                   value: _formatDate(profile.dateOfBirth!),
//                   color: Colors.orange,
//                 ),
//               if (profile.gender != null)
//                 _InfoRow(
//                   icon: profile.gender == 'male' 
//                       ? Icons.male_rounded 
//                       : profile.gender == 'female'
//                           ? Icons.female_rounded
//                           : Icons.person_rounded,
//                   label: 'Gender',
//                   value: StringExtension(profile.gender!).capitalizeFirst!,
//                   color: Colors.blue,
//                 ),
//               if (profile.age > 0)
//                 _InfoRow(
//                   icon: Icons.numbers_rounded,
//                   label: 'Age',
//                   value: profile.age.toString(),
//                   color: Colors.teal,
//                 ),
//             ],
//           ),

//           const SizedBox(height: 20),

//           _buildInfoCard(
//             title: 'Academic Information',
//             icon: Icons.school_rounded,
//             color: Colors.blue,
//             children: [
//               _InfoRow(
//                 icon: Icons.badge_rounded,
//                 label: 'Student ID',
//                 value: profile.studentId,
//                 color: Colors.blue,
//               ),
//               _InfoRow(
//                 icon: Icons.class_rounded,
//                 label: 'Grade Level',
//                 value: profile.gradeLevel.displayName,
//                 color: Colors.green,
//               ),
//               if (profile.section != null)
//                 _InfoRow(
//                   icon: Icons.group_rounded,
//                   label: 'Section',
//                   value: profile.section!,
//                   color: Colors.orange,
//                 ),
//               _InfoRow(
//                 icon: Icons.calendar_today_rounded,
//                 label: 'Enrollment Date',
//                 value: _formatDate(profile.enrollmentDate),
//                 color: Colors.purple,
//               ),
//               _InfoRow(
//                 icon: Icons.analytics_rounded,
//                 label: 'Status',
//                 value: profile.status.displayName,
//                 color: profile.status.color,
//               ),
//             ],
//           ),

//           const SizedBox(height: 20),

//           _buildInfoCard(
//             title: 'Contact Information',
//             icon: Icons.contact_page_rounded,
//             color: Colors.green,
//             children: [
//               if (profile.address != null)
//                 _InfoRow(
//                   icon: Icons.location_on_rounded,
//                   label: 'Address',
//                   value: profile.address!,
//                   color: Colors.red,
//                 ),
//               if (profile.emergencyContact != null)
//                 _InfoRow(
//                   icon: Icons.emergency_rounded,
//                   label: 'Emergency Contact',
//                   value: profile.emergencyContact!,
//                   color: Colors.orange,
//                 ),
//             ],
//           ),

//           const SizedBox(height: 20),

//           if (profile.medicalInfo != null || profile.bloodGroup != null || profile.allergies != null)
//             _buildInfoCard(
//               title: 'Medical Information',
//               icon: Icons.medical_services_rounded,
//               color: Colors.red,
//               children: [
//                 if (profile.medicalInfo != null)
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Medical Conditions:',
//                         style: TextStyle(
//                           fontSize: 13,
//                           fontWeight: FontWeight.w500,
//                           color: Colors.black87,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         profile.medicalInfo!,
//                         style: const TextStyle(
//                           fontSize: 14,
//                           color: Colors.black87,
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                     ],
//                   ),
//                 if (profile.bloodGroup != null)
//                   _InfoRow(
//                     icon: Icons.bloodtype_rounded,
//                     label: 'Blood Group',
//                     value: profile.bloodGroup!,
//                     color: Colors.red,
//                   ),
//                 if (profile.allergies != null)
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Allergies:',
//                         style: TextStyle(
//                           fontSize: 13,
//                           fontWeight: FontWeight.w500,
//                           color: Colors.black87,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         profile.allergies!,
//                         style: const TextStyle(
//                           fontSize: 14,
//                           color: Colors.black87,
//                         ),
//                       ),
//                     ],
//                   ),
//               ],
//             ),

//           const SizedBox(height: 20),

//           if (profile.extracurricularActivities.isNotEmpty)
//             _buildInfoCard(
//               title: 'Extracurricular Activities',
//               icon: Icons.sports_rounded,
//               color: Colors.orange,
//               children: [
//                 ...profile.extracurricularActivities.map((activity) {
//                   return Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: Row(
//                       children: [
//                         Icon(Icons.check_circle_rounded,
//                             size: 16, color: Colors.green),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Text(
//                             activity,
//                             style: const TextStyle(fontSize: 14),
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 }).toList(),
//               ],
//             ),

//           const SizedBox(height: 20),

//           if (profile.previousSchool != null)
//             _buildInfoCard(
//               title: 'Previous School',
//               icon: Icons.school_rounded,
//               color: Colors.teal,
//               children: [
//                 Text(
//                   profile.previousSchool!,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     color: Colors.black87,
//                   ),
//                 ),
//               ],
//             ),

//           const SizedBox(height: 40),
//         ],
//       ),
//     );
//   }

//   Widget _buildAcademicsTab(StudentProfile profile) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildInfoCard(
//             title: 'Academic Summary',
//             icon: Icons.analytics_rounded,
//             color: Colors.purple,
//             children: [
//               Center(
//                 child: Column(
//                   children: [
//                     Text(
//                       '${profile.averageGrade.toStringAsFixed(1)} GPA',
//                       style: const TextStyle(
//                         fontSize: 36,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.purple,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 16,
//                         vertical: 8,
//                       ),
//                       decoration: BoxDecoration(
//                         color: profile.gradeColor.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Text(
//                         'Grade ${profile.gradeLetter}',
//                         style: TextStyle(
//                           fontSize: 18,
//                           color: profile.gradeColor,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                   ],
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(height: 20),

//           if (profile.grades.isNotEmpty)
//             _buildInfoCard(
//               title: 'Subject Grades',
//               icon: Icons.subject_rounded,
//               color: Colors.blue,
//               children: [
//                 ...profile.grades.entries.map((entry) {
//                   final subject = entry.key;
//                   final grade = entry.value;
//                   final letterGrade = _getLetterGrade(grade);
//                   final color = _getGradeColor(grade);
                  
//                   return Padding(
//                     padding: const EdgeInsets.only(bottom: 16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               subject,
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.w500,
//                                 fontSize: 15,
//                               ),
//                             ),
//                             Row(
//                               children: [
//                                 Text(
//                                   grade.toStringAsFixed(1),
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     color: color,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Container(
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 8,
//                                     vertical: 2,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: color.withOpacity(0.1),
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                   child: Text(
//                                     letterGrade,
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       color: color,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 8),
//                         LinearProgressIndicator(
//                           value: grade / 100,
//                           backgroundColor: Colors.grey.shade200,
//                           color: color,
//                           minHeight: 6,
//                           borderRadius: BorderRadius.circular(3),
//                         ),
//                       ],
//                     ),
//                   );
//                 }).toList(),
//               ],
//             ),

//           const SizedBox(height: 20),

//           if (profile.enrolledSubjects.isNotEmpty)
//             _buildInfoCard(
//               title: 'Enrolled Subjects',
//               icon: Icons.menu_book_rounded,
//               color: Colors.green,
//               children: [
//                 Wrap(
//                   spacing: 8,
//                   runSpacing: 8,
//                   children: profile.enrolledSubjects.map((subject) {
//                     return Chip(
//                       label: Text(subject),
//                       backgroundColor: Colors.green.withOpacity(0.1),
//                       labelStyle: const TextStyle(
//                         color: Colors.green,
//                         fontWeight: FontWeight.w500,
//                       ),
//                       avatar: const Icon(
//                         Icons.check_circle_rounded,
//                         size: 16,
//                         color: Colors.green,
//                       ),
//                     );
//                   }).toList(),
//                 ),
//               ],
//             ),

//           const SizedBox(height: 20),

//           _buildInfoCard(
//             title: 'Performance Trends',
//             icon: Icons.trending_up_rounded,
//             color: Colors.orange,
//             children: [
//               const SizedBox(height: 16),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   _TrendItem(
//                     label: 'Math',
//                     current: 85,
//                     previous: 78,
//                     color: Colors.blue,
//                   ),
//                   _TrendItem(
//                     label: 'Science',
//                     current: 92,
//                     previous: 88,
//                     color: Colors.green,
//                   ),
//                   _TrendItem(
//                     label: 'English',
//                     current: 78,
//                     previous: 75,
//                     color: Colors.red,
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               const Text(
//                 'Overall improvement of +5% compared to last semester',
//                 style: TextStyle(
//                   fontSize: 13,
//                   color: Colors.grey,
//                   fontStyle: FontStyle.italic,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),

//           const SizedBox(height: 40),
//         ],
//       ),
//     );
//   }

//   Widget _buildAttendanceTab(StudentProfile profile) {
//     final attendance = profile.attendance;
//     final present = attendance['present'] ?? 0;
//     final absent = attendance['absent'] ?? 0;
//     final late = attendance['late'] ?? 0;
//     final total = present + absent + late;
//     final percentage = total > 0 ? (present / total * 100).round() : 0;

//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildInfoCard(
//             title: 'Attendance Summary',
//             icon: Icons.event_available_rounded,
//             color: Colors.green,
//             children: [
//               Center(
//                 child: Column(
//                   children: [
//                     Text(
//                       '$percentage%',
//                       style: TextStyle(
//                         fontSize: 48,
//                         fontWeight: FontWeight.bold,
//                         color: _getAttendanceColor(percentage),
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       'Attendance Rate',
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.grey.shade600,
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                   ],
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(height: 20),

//           _buildInfoCard(
//             title: 'Attendance Breakdown',
//             icon: Icons.pie_chart_rounded,
//             color: Colors.blue,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   _AttendanceStatItem(
//                     label: 'Present',
//                     value: present,
//                     total: total,
//                     color: Colors.green,
//                     icon: Icons.check_circle_rounded,
//                   ),
//                   _AttendanceStatItem(
//                     label: 'Absent',
//                     value: absent,
//                     total: total,
//                     color: Colors.red,
//                     icon: Icons.cancel_rounded,
//                   ),
//                   _AttendanceStatItem(
//                     label: 'Late',
//                     value: late,
//                     total: total,
//                     color: Colors.orange,
//                     icon: Icons.schedule_rounded,
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 20),
//               const Divider(),
//               const SizedBox(height: 16),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     'Total Days',
//                     style: TextStyle(
//                       fontWeight: FontWeight.w500,
//                       fontSize: 14,
//                     ),
//                   ),
//                   Text(
//                     total.toString(),
//                     style: const TextStyle(
//                       fontWeight: FontWeight.w600,
//                       fontSize: 16,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),

//           const SizedBox(height: 20),

//           _buildInfoCard(
//             title: 'Recent Attendance',
//             icon: Icons.history_rounded,
//             color: Colors.purple,
//             children: [
//               const SizedBox(height: 8),
//               ..._generateSampleAttendance().map((record) {
//                 return Padding(
//                   padding: const EdgeInsets.only(bottom: 12),
//                   child: Row(
//                     children: [
//                       Container(
//                         width: 36,
//                         height: 36,
//                         decoration: BoxDecoration(
//                           color: _getStatusColor(record['status']!)
//                               .withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Icon(
//                           _getStatusIcon(record['status']!),
//                           size: 20,
//                           color: _getStatusColor(record['status']!),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               record['date']!,
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.w500,
//                                 fontSize: 14,
//                               ),
//                             ),
//                             Text(
//                               record['class']!,
//                               style: TextStyle(
//                                 fontSize: 13,
//                                 color: Colors.grey.shade600,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 8,
//                           vertical: 4,
//                         ),
//                         decoration: BoxDecoration(
//                           color: _getStatusColor(record['status']!)
//                               .withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Text(
//                           record['status']!.toUpperCase(),
//                           style: TextStyle(
//                             fontSize: 11,
//                             color: _getStatusColor(record['status']!),
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               }).toList(),
//             ],
//           ),

//           const SizedBox(height: 20),

//           _buildInfoCard(
//             title: 'Attendance Notes',
//             icon: Icons.note_rounded,
//             color: Colors.orange,
//             children: [
//               const Text(
//                 'Important attendance policies:',
//                 style: TextStyle(
//                   fontWeight: FontWeight.w500,
//                   fontSize: 14,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               const Text(
//                 '• 90%+ attendance required for academic awards\n'
//                 '• 3+ consecutive absences require medical certificate\n'
//                 '• Late arrivals after 9:00 AM count as absent\n'
//                 '• Parents notified after 5 absences per month',
//                 style: TextStyle(
//                   fontSize: 13,
//                   color: Color.fromARGB(255, 97, 97, 97),
//                   height: 1.5,
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(height: 40),
//         ],
//       ),
//     );
//   }

//   Widget _buildParentsTab() {
//     return Obx(() {
//       if (parents.isEmpty) {
//         return Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.family_restroom_outlined,
//                   size: 80, color: Colors.grey.shade300),
//               const SizedBox(height: 20),
//               const Text(
//                 'No parents linked',
//                 style: TextStyle(
//                   fontSize: 18,
//                   color: Colors.grey,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 'Parents will appear here when linked to this student',
//                 style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 24),
//               ElevatedButton(
//                 onPressed: () => _linkParent(),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.deepOrange,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 24,
//                     vertical: 12,
//                   ),
//                 ),
//                 child: const Text(
//                   'Link Parent',
//                   style: TextStyle(color: Colors.white),
//                 ),
//               ),
//             ],
//           ),
//         );
//       }

//       return ListView.builder(
//         padding: const EdgeInsets.all(20),
//         itemCount: parents.length,
//         itemBuilder: (context, index) {
//           final parent = parents[index];
//           return Padding(
//             padding: const EdgeInsets.only(bottom: 12),
//             child: _ParentListItem(
//               parent: parent,
//               onTap: () {
//                 // Get.to(() => ParentProfilePage(parentId: parent.id));
//               },
//             ),
//           );
//         },
//       );
//     });
//   }

//   void _showEditStudentDialog(StudentProfile profile) {
//     Get.bottomSheet(
//       Container(
//         height: Get.height * 0.4,
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
//         ),
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Edit Student Profile',
//               style: TextStyle(
//                 fontSize: 22,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//             const SizedBox(height: 20),
//             ListTile(
//               leading: Container(
//                 width: 40,
//                 height: 40,
//                 decoration: BoxDecoration(
//                   color: Colors.purple.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: const Icon(Icons.edit_rounded, color: Colors.purple),
//               ),
//               title: const Text('Edit Information'),
//               subtitle: const Text('Update personal and academic details'),
//               onTap: () {
//                 Get.back();
//                 // Get.to(() => CreateStudentForm(student: profile));
//               },
//             ),
//             ListTile(
//               leading: Container(
//                 width: 40,
//                 height: 40,
//                 decoration: BoxDecoration(
//                   color: Colors.green.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: const Icon(Icons.grade_rounded, color: Colors.green),
//               ),
//               title: const Text('Update Grades'),
//               subtitle: const Text('Add or modify subject grades'),
//               onTap: () {
//                 Get.back();
//                 _showUpdateGradesDialog(profile);
//               },
//             ),
//             ListTile(
//               leading: Container(
//                 width: 40,
//                 height: 40,
//                 decoration: BoxDecoration(
//                   color: Colors.orange.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: const Icon(Icons.family_restroom_rounded, color: Colors.orange),
//               ),
//               title: const Text('Link Parents'),
//               subtitle: const Text('Add or remove parent connections'),
//               onTap: () {
//                 Get.back();
//                 _linkParent();
//               },
//             ),
//             const SizedBox(height: 20),
//             SizedBox(
//               width: double.infinity,
//               child: OutlinedButton(
//                 onPressed: () => Get.back(),
//                 style: OutlinedButton.styleFrom(
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   side: BorderSide(color: Colors.grey.shade300),
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                 ),
//                 child: const Text('Cancel'),
//               ),
//             ),
//           ],
//         ),
//       ),
//       isScrollControlled: true,
//     );
//   }

//   void _showStudentActionsMenu() {
//     Get.bottomSheet(
//       Container(
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
//         ),
//         child: SafeArea(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               ListTile(
//                 leading: const Icon(Icons.print_rounded, color: Colors.blue),
//                 title: const Text('Print Report Card'),
//                 onTap: () {
//                   Get.back();
//                   Get.snackbar(
//                     'Coming Soon',
//                     'Report card printing will be available soon',
//                     backgroundColor: Colors.blue,
//                     colorText: Colors.white,
//                   );
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.share_rounded, color: Colors.green),
//                 title: const Text('Share Profile'),
//                 onTap: () {
//                   Get.back();
//                   Get.snackbar(
//                     'Coming Soon',
//                     'Share feature will be available soon',
//                     backgroundColor: Colors.green,
//                     colorText: Colors.white,
//                   );
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.email_rounded, color: Colors.orange),
//                 title: const Text('Send to Parents'),
//                 onTap: () {
//                   Get.back();
//                   Get.snackbar(
//                     'Coming Soon',
//                     'Parent communication will be available soon',
//                     backgroundColor: Colors.orange,
//                     colorText: Colors.white,
//                   );
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.history_rounded, color: Colors.purple),
//                 title: const Text('View Activity Log'),
//                 onTap: () {
//                   Get.back();
//                   Get.snackbar(
//                     'Coming Soon',
//                     'Activity log will be available soon',
//                     backgroundColor: Colors.purple,
//                     colorText: Colors.white,
//                   );
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.block_rounded, color: Colors.red),
//                 title: const Text('Deactivate Account'),
//                 onTap: () {
//                   Get.back();
//                   _showDeactivateStudentDialog();
//                 },
//               ),
//               Container(
//                 height: 1,
//                 color: Colors.grey.shade200,
//               ),
//               TextButton(
//                 onPressed: () => Get.back(),
//                 child: const Text('Cancel'),
//               ),
//               const SizedBox(height: 8),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildLoadingState() {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(
//               valueColor: AlwaysStoppedAnimation(Colors.purple),
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               'Loading profile...',
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.grey,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildNotFoundState() {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text('Student Profile'),
//         leading: IconButton(
//           onPressed: () => Get.back(),
//           icon: const Icon(Icons.arrow_back_rounded),
//         ),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.person_off_rounded,
//                 size: 80, color: Colors.grey.shade300),
//             const SizedBox(height: 20),
//             const Text(
//               'Student profile not found',
//               style: TextStyle(
//                 fontSize: 18,
//                 color: Colors.grey,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'The requested student profile does not exist',
//               style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton(
//               onPressed: () => Get.back(),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.purple,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//               ),
//               child: const Text(
//                 'Go Back',
//                 style: TextStyle(color: Colors.white),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   String _formatDate(DateTime date) {
//     final now = DateTime.now();
//     final difference = now.difference(date);
    
//     if (difference.inDays == 0) return 'Today';
//     if (difference.inDays == 1) return 'Yesterday';
//     if (difference.inDays < 7) return '${difference.inDays} days ago';
//     if (difference.inDays < 30) return '${(difference.inDays / 7).floor()} weeks ago';
    
//     return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
//   }

//   String _getLetterGrade(double grade) {
//     if (grade >= 90) return 'A';
//     if (grade >= 80) return 'B';
//     if (grade >= 70) return 'C';
//     if (grade >= 60) return 'D';
//     return 'F';
//   }

//   Color _getGradeColor(double grade) {
//     if (grade >= 90) return Colors.green;
//     if (grade >= 80) return Colors.blue;
//     if (grade >= 70) return Colors.orange;
//     if (grade >= 60) return Colors.amber;
//     return Colors.red;
//   }

//   Color _getAttendanceColor(int percentage) {
//     if (percentage >= 90) return Colors.green;
//     if (percentage >= 80) return Colors.blue;
//     if (percentage >= 70) return Colors.orange;
//     if (percentage >= 60) return Colors.amber;
//     return Colors.red;
//   }

//   Color _getStatusColor(String status) {
//     switch (status.toLowerCase()) {
//       case 'present':
//         return Colors.green;
//       case 'absent':
//         return Colors.red;
//       case 'late':
//         return Colors.orange;
//       case 'excused':
//         return Colors.blue;
//       default:
//         return Colors.grey;
//     }
//   }

//   IconData _getStatusIcon(String status) {
//     switch (status.toLowerCase()) {
//       case 'present':
//         return Icons.check_circle_rounded;
//       case 'absent':
//         return Icons.cancel_rounded;
//       case 'late':
//         return Icons.schedule_rounded;
//       case 'excused':
//         return Icons.event_busy_rounded;
//       default:
//         return Icons.help_rounded;
//     }
//   }

//   List<Map<String, String>> _generateSampleAttendance() {
//     final now = DateTime.now();
//     return [
//       {
//         'date': _formatDate(now.subtract(const Duration(days: 1))),
//         'class': 'Mathematics - 9:00 AM',
//         'status': 'present',
//       },
//       {
//         'date': _formatDate(now.subtract(const Duration(days: 2))),
//         'class': 'Science - 10:00 AM',
//         'status': 'present',
//       },
//       {
//         'date': _formatDate(now.subtract(const Duration(days: 3))),
//         'class': 'English - 11:00 AM',
//         'status': 'late',
//       },
//       {
//         'date': _formatDate(now.subtract(const Duration(days: 4))),
//         'class': 'History - 2:00 PM',
//         'status': 'absent',
//       },
//       {
//         'date': _formatDate(now.subtract(const Duration(days: 5))),
//         'class': 'Physical Education - 3:00 PM',
//         'status': 'present',
//       },
//     ];
//   }

//   Widget _buildInfoCard({
//     required String title,
//     required IconData icon,
//     required Color color,
//     required List<Widget> children,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.grey.shade100),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   width: 40,
//                   height: 40,
//                   decoration: BoxDecoration(
//                     color: color.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Icon(icon, color: color, size: 22),
//                 ),
//                 const SizedBox(width: 12),
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w700,
//                     color: Colors.black87,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             ...children,
//           ],
//         ),
//       ),
//     );
//   }

//   void _showUpdateGradesDialog(StudentProfile profile) {
//     final TextEditingController subjectController = TextEditingController();
//     final TextEditingController gradeController = TextEditingController();
//     final RxString selectedSubject = RxString('');
//     final RxDouble selectedGrade = RxDouble(0.0);

//     Get.dialog(
//       AlertDialog(
//         title: const Text('Update Grades'),
//         content: SizedBox(
//           width: Get.width * 0.8,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Obx(() => DropdownButtonFormField<String>(
//                 value: selectedSubject.value.isNotEmpty 
//                     ? selectedSubject.value 
//                     : null,
//                 decoration: InputDecoration(
//                   labelText: 'Select Subject',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 items: [
//                   ...profile.enrolledSubjects.map((subject) {
//                     return DropdownMenuItem(
//                       value: subject,
//                       child: Text(subject),
//                     );
//                   }).toList(),
//                   const DropdownMenuItem(
//                     value: 'other',
//                     child: Text('Other Subject'),
//                   ),
//                 ],
//                 onChanged: (value) {
//                   selectedSubject.value = value!;
//                 },
//               )),
//               const SizedBox(height: 16),
//               if (selectedSubject.value == 'other')
//                 TextField(
//                   controller: subjectController,
//                   decoration: InputDecoration(
//                     labelText: 'Enter Subject Name',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                 ),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: gradeController,
//                 decoration: InputDecoration(
//                   labelText: 'Grade (0-100)',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 keyboardType: TextInputType.number,
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               final subject = selectedSubject.value == 'other'
//                   ? subjectController.text
//                   : selectedSubject.value;
//               final grade = double.tryParse(gradeController.text) ?? 0.0;
              
//               if (subject.isNotEmpty && grade >= 0 && grade <= 100) {
//                 try {
//                   await controller.updateStudentProfile(profile.id, {
//                     'grades': {
//                       ...profile.grades,
//                       subject: grade,
//                     },
//                     'updatedAt': Timestamp.now(),
//                   });
//                   Get.back();
//                   Get.snackbar(
//                     'Success',
//                     'Grade updated successfully',
//                     backgroundColor: Colors.green,
//                     colorText: Colors.white,
//                   );
//                   await _loadStudentProfile();
//                 } catch (e) {
//                   Get.snackbar(
//                     'Error',
//                     'Failed to update grade',
//                     backgroundColor: Colors.red,
//                     colorText: Colors.white,
//                   );
//                 }
//               } else {
//                 Get.snackbar(
//                   'Invalid Input',
//                   'Please enter valid subject and grade',
//                   backgroundColor: Colors.orange,
//                   colorText: Colors.white,
//                 );
//               }
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.purple,
//             ),
//             child: const Text('Update'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _linkParent() {
//     Get.bottomSheet(
//       Container(
//         height: Get.height * 0.6,
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
//         ),
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(20),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     'Link Parent',
//                     style: TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                   IconButton(
//                     onPressed: () => Get.back(),
//                     icon: const Icon(Icons.close_rounded),
//                   ),
//                 ],
//               ),
//             ),
//             Expanded(
//               child: Obx(() {
//                 final availableParents = controller.parentList
//                     .where((parent) => 
//                         !studentProfile.value!.parentIds.contains(parent.id))
//                     .toList();

//                 if (availableParents.isEmpty) {
//                   return Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.people_outline_rounded,
//                             size: 80, color: Colors.grey.shade300),
//                         const SizedBox(height: 20),
//                         const Text(
//                           'No parents available',
//                           style: TextStyle(
//                             fontSize: 18,
//                             color: Colors.grey,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           'All parents are already linked to this student',
//                           style: TextStyle(
//                               fontSize: 14, color: Colors.grey.shade500),
//                           textAlign: TextAlign.center,
//                         ),
//                       ],
//                     ),
//                   );
//                 }

//                 return ListView.builder(
//                   padding: const EdgeInsets.all(20),
//                   itemCount: availableParents.length,
//                   itemBuilder: (context, index) {
//                     final parent = availableParents[index];
//                     return Padding(
//                       padding: const EdgeInsets.only(bottom: 12),
//                       child: _ParentSelectionCard(
//                         parent: parent,
//                         onSelect: () => _confirmLinkParent(parent),
//                       ),
//                     );
//                   },
//                 );
//               }),
//             ),
//           ],
//         ),
//       ),
//       isScrollControlled: true,
//     );
//   }

//   void _confirmLinkParent(ParentProfile parent) {
//     Get.dialog(
//       AlertDialog(
//         title: const Text('Link Parent'),
//         content: Text(
//           'Are you sure you want to link ${parent.name} to ${studentProfile.value?.name}?',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               Get.back();
//               try {
//                 final currentParentIds = studentProfile.value!.parentIds;
//                 if (!currentParentIds.contains(parent.id)) {
//                   await controller.updateStudentProfile(
//                     studentProfile.value!.id,
//                     {
//                       'parentIds': [...currentParentIds, parent.id],
//                       'updatedAt': Timestamp.now(),
//                     },
//                   );
//                 }

//                 final currentStudentIds = parent.studentIds;
//                 if (!currentStudentIds.contains(studentProfile.value!.id)) {
//                   await controller.updateParentProfile(
//                     parent.id,
//                     {
//                       'studentIds': [...currentStudentIds, studentProfile.value!.id],
//                       'childNames': [...parent.childNames, studentProfile.value!.name],
//                       'updatedAt': Timestamp.now(),
//                     },
//                   );
//                 }

//                 Get.snackbar(
//                   'Success',
//                   'Parent linked successfully',
//                   backgroundColor: Colors.green,
//                   colorText: Colors.white,
//                 );
//                 await _loadStudentProfile();
//               } catch (e) {
//                 Get.snackbar(
//                   'Error',
//                   'Failed to link parent',
//                   backgroundColor: Colors.red,
//                   colorText: Colors.white,
//                 );
//               }
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.deepOrange,
//             ),
//             child: const Text('Link'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showDeactivateStudentDialog() {
//     Get.dialog(
//       AlertDialog(
//         title: const Text('Deactivate Student'),
//         content: const Text(
//           'Are you sure you want to deactivate this student account? '
//           'They will not be able to access the system until reactivated.',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () async {
//               Get.back();
//               try {
//                 await controller.updateStudentProfile(studentProfile.value!.id, {
//                   'status': 'Withdrawn',
//                   'updatedAt': Timestamp.now(),
//                 });
//                 Get.snackbar(
//                   'Account Deactivated',
//                   'Student account has been deactivated',
//                   backgroundColor: Colors.red,
//                   colorText: Colors.white,
//                 );
//                 await _loadStudentProfile();
//               } catch (e) {
//                 Get.snackbar(
//                   'Error',
//                   'Failed to deactivate account',
//                   backgroundColor: Colors.red,
//                   colorText: Colors.white,
//                 );
//               }
//             },
//             child: const Text(
//               'Deactivate',
//               style: TextStyle(color: Colors.red),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
// }