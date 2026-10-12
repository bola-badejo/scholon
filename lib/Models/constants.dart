// // Add to lib/Utils/constants.dart
// import 'package:flutter/material.dart';

// import '../Models/user.dart';

// class SubscriptionHelper {
//   static String getPlanDisplayName(SubscriptionPlan? plan) {
//     switch (plan) {
//       case SubscriptionPlan.trial:
//         return 'Free Trial';
//       case SubscriptionPlan.weekly:
//         return 'Weekly (₦300/week)';
//       case SubscriptionPlan.monthly:
//         return 'Monthly (₦1,200/month)';
//       case SubscriptionPlan.annual:
//         return 'Annual (₦14,400/year)';
//       default:
//         return 'No Plan';
//     }
//   }

//   static Color getPlanColor(SubscriptionPlan? plan) {
//     switch (plan) {
//       case SubscriptionPlan.trial:
//         return Colors.blue;
//       case SubscriptionPlan.weekly:
//         return Colors.orange;
//       case SubscriptionPlan.monthly:
//         return Colors.green;
//       case SubscriptionPlan.annual:
//         return Colors.purple;
//       default:
//         return Colors.grey;
//     }
//   }

//   static IconData getPlanIcon(SubscriptionPlan? plan) {
//     switch (plan) {
//       case SubscriptionPlan.trial:
//         return Icons.star;
//       case SubscriptionPlan.weekly:
//         return Icons.update;
//       case SubscriptionPlan.monthly:
//         return Icons.calendar_month;
//       case SubscriptionPlan.annual:
//         return Icons.celebration;
//       default:
//         return Icons.block;
//     }
//   }
// }