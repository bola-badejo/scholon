// // lib/Screens/Parent/pages/children_list_screen.dart
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:isapp/features/auth/models/user.dart';
// import 'package:isapp/Screens/parents/child_analytics.dart';
// import 'package:isapp/features/parents/controllers/parent_controller.dart';

// class ChildrenListScreen extends StatelessWidget {
//   ChildrenListScreen({super.key});

//   final ParentController controller = Get.find();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFFEF6E6),
//       appBar: AppBar(
//         title: const Text(
//           'My Children',
//           style: TextStyle(fontWeight: FontWeight.w600),
//         ),
//         backgroundColor: Colors.orange,
//         foregroundColor: Colors.white,
//         elevation: 0,
//       ),
//       body: Obx(() {
//         if (controller.isLoadingChildren.value) {
//           return const Center(
//             child: CircularProgressIndicator(color: Colors.orange),
//           );
//         }

//         if (controller.children.isEmpty) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.child_care_rounded, size: 80, color: Colors.orange.shade300),
//                 const SizedBox(height: 20),
//                 const Text(
//                   'No Children Added',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 const Text(
//                   'Add your children to monitor their progress',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey,
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 ElevatedButton(
//                   onPressed: () {
//                     // Navigate to add child page
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.orange,
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
//                   ),
//                   child: const Text('Add Child'),
//                 ),
//               ],
//             ),
//           );
//         }

//         return RefreshIndicator(
//           onRefresh: () async => controller.refreshAll(),
//           child: ListView.separated(
//             padding: const EdgeInsets.all(20),
//             itemCount: controller.children.length,
//             separatorBuilder: (context, index) => const SizedBox(height: 12),
//             itemBuilder: (context, index) {
//               final child = controller.children[index];
//               final analytics = controller.childAnalytics[child.uid] ?? {};
//               final progress = analytics['overallProgress'] ?? 0;
//               final averageScore = analytics['averageScore'] ?? 0;

//               return GestureDetector(
//                 onTap: () => Get.to(() => ChildAnalyticsScreen(selectedChild: child)),
//                 child: Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(16),
//                     border: Border.all(color: Colors.orange.shade100),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.orange.withOpacity(0.05),
//                         blurRadius: 10,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: Row(
//                     children: [
//                       Container(
//                         width: 60,
//                         height: 60,
//                         decoration: BoxDecoration(
//                           color: Colors.orange.shade50,
//                           shape: BoxShape.circle,
//                         ),
//                         child: const Icon(Icons.person_rounded, color: Colors.orange, size: 30),
//                       ),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               child.name,
//                               style: const TextStyle(
//                                 fontSize: 17,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                             const SizedBox(height: 6),
//                             Row(
//                               children: [
//                                 Icon(Icons.school_rounded, size: 14, color: Colors.grey.shade500),
//                                 const SizedBox(width: 4),
//                                 Expanded(
//                                   child: Text(
//                                     child.schoolName ?? 'No School',
//                                     style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
//                                     maxLines: 1,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 4),
//                             Row(
//                               children: [
//                                 Icon(Icons.grade_rounded, size: 14, color: Colors.grey.shade500),
//                                 const SizedBox(width: 4),
//                                 Text(
//                                   'Grade ${child.classGrade ?? "N/A"}',
//                                   style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.end,
//                         children: [
//                           Row(
//                             children: [
//                               Icon(Icons.trending_up_rounded, size: 16, color: Colors.green),
//                               const SizedBox(width: 4),
//                               Text(
//                                 '${progress.toStringAsFixed(0)}%',
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                   color: progress >= 70 ? Colors.green : Colors.orange,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 8),
//                           Row(
//                             children: [
//                               Icon(Icons.score_rounded, size: 16, color: Colors.purple),
//                               const SizedBox(width: 4),
//                               Text(
//                                 '${averageScore}%',
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w600,
//                                   color: Colors.purple,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//         );
//       }),
//     );
//   }
// }