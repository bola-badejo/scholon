// // lib/Widgets/subscription_card.dart
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:isapp/Models/user.dart';
// import 'package:isapp/Services/subscription_service.dart';

// class SubscriptionStatusCard extends StatelessWidget {
//   final StudyUser? user;
//   final VoidCallback? onUpgrade;
//   final VoidCallback? onRenew;

//   const SubscriptionStatusCard({
//     super.key,
//     this.user,
//     this.onUpgrade,
//     this.onRenew,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final subscription = user?.currentSubscription;
//     final isActive = subscription?.isActive ?? false;
//     final hasExpired = subscription?.hasExpired ?? true;
//     final isTrial = subscription?.plan == SubscriptionPlan.trial;
//     final daysRemaining = subscription?.daysRemaining ?? 0;

//     Color statusColor = isActive
//         ? Colors.green
//         : hasExpired
//             ? Colors.red
//             : Colors.orange;

//     String statusText = isActive
//         ? 'Active'
//         : hasExpired
//             ? 'Expired'
//             : 'Pending';

//     if (isTrial) {
//       statusText = 'Free Trial';
//       statusColor = Colors.blue;
//     }

//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: isTrial
//               ? [Colors.blue.shade50, Colors.lightBlue.shade50]
//               : isActive
//                   ? [Colors.green.shade50, Colors.lightGreen.shade50]
//                   : [Colors.orange.shade50, Colors.orange.shade100],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 15,
//             offset: const Offset(0, 5),
//           ),
//         ],
//         border: Border.all(
//           color: statusColor.withOpacity(0.3),
//           width: 2,
//         ),
//       ),
//       child: Column(
//         children: [
//           // Header with status
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Your Plan',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey[600],
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     _getPlanName(subscription?.plan),
//                     style: const TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black87,
//                     ),
//                   ),
//                 ],
//               ),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: statusColor.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(color: statusColor.withOpacity(0.3)),
//                 ),
//                 child: Text(
//                   statusText,
//                   style: TextStyle(
//                     color: statusColor,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 12,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
          
//           // Progress bar for trial
//           if (isTrial && daysRemaining > 0)
//             Column(
//               children: [
//                 LinearProgressIndicator(
//                   value: (30 - daysRemaining) / 30,
//                   backgroundColor: Colors.grey[200],
//                   color: Colors.blue,
//                   minHeight: 6,
//                   borderRadius: BorderRadius.circular(3),
//                 ),
//                 const SizedBox(height: 8),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       '$daysRemaining days left',
//                       style: const TextStyle(
//                         fontSize: 12,
//                         color: Colors.blue,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     Text(
//                       '30 days total',
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.grey[600],
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//               ],
//             ),
          
//           // Subscription details
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               _buildDetailItem(
//                 icon: Icons.calendar_today,
//                 label: 'Started',
//                 value: subscription != null
//                     ? '${subscription.startDate.day}/${subscription.startDate.month}'
//                     : '--/--',
//               ),
//               _buildDetailItem(
//                 icon: Icons.event_busy,
//                 label: 'Expires',
//                 value: subscription != null
//                     ? '${subscription.expiryDate.day}/${subscription.expiryDate.month}'
//                     : '--/--',
//               ),
//               _buildDetailItem(
//                 icon: Icons.attach_money,
//                 label: 'Amount',
//                 value: subscription != null
//                     ? '₦${subscription.amount.toInt()}'
//                     : '₦0',
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
          
//           // Action button
//           if (hasExpired || subscription == null)
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: onUpgrade,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.deepPurple,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   elevation: 2,
//                 ),
//                 child: const Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.upgrade, size: 18),
//                     SizedBox(width: 8),
//                     Text(
//                       'Upgrade Plan',
//                       style: TextStyle(
//                         fontWeight: FontWeight.w600,
//                         fontSize: 15,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             )
//           else if (daysRemaining <= 7 && !isTrial)
//             SizedBox(
//               width: double.infinity,
//               child: OutlinedButton(
//                 onPressed: onRenew,
//                 style: OutlinedButton.styleFrom(
//                   foregroundColor: Colors.deepPurple,
//                   side: const BorderSide(color: Colors.deepPurple),
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: const Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.autorenew, size: 18),
//                     SizedBox(width: 8),
//                     Text(
//                       'Renew Early',
//                       style: TextStyle(
//                         fontWeight: FontWeight.w600,
//                         fontSize: 15,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDetailItem({
//     required IconData icon,
//     required String label,
//     required String value,
//   }) {
//     return Column(
//       children: [
//         Icon(
//           icon,
//           size: 18,
//           color: Colors.grey[600],
//         ),
//         const SizedBox(height: 4),
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 11,
//             color: Colors.grey[600],
//           ),
//         ),
//         const SizedBox(height: 2),
//         Text(
//           value,
//           style: const TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w600,
//             color: Colors.black87,
//           ),
//         ),
//       ],
//     );
//   }

//   String _getPlanName(SubscriptionPlan? plan) {
//     switch (plan) {
//       case SubscriptionPlan.trial:
//         return 'Free Trial';
//       case SubscriptionPlan.weekly:
//         return 'Weekly Plan';
//       case SubscriptionPlan.monthly:
//         return 'Monthly Plan';
//       case SubscriptionPlan.annual:
//         return 'Annual Plan';
//       default:
//         return 'No Active Plan';
//     }
//   }
// }