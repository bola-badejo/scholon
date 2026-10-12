// // lib/services/subscription_service.dart
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:isapp/Models/user.dart';

// class SubscriptionService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   // Create free trial for new user based on user type
//   Future<void> createFreeTrial(BaseUser user) async {
//     try {
//       Subscription? trialSubscription;
      
//       // Create appropriate trial subscription based on user type
//       switch (user.userType) {
//         case UserType.student:
//           trialSubscription = StudentSubscription.create(plan: StudentPlan.trial);
//           break;
//         case UserType.teacher:
//           trialSubscription = TeacherSubscription.create(plan: TeacherPlan.trial);
//           break;
//         case UserType.schoolAdmin:
//           trialSubscription = SchoolSubscription.create(plan: SchoolPlan.trial);
//           break;
//         case UserType.parent:
//           trialSubscription = ParentSubscription.create(plan: ParentPlan.free);
//           break;
//       }

//       if (trialSubscription != null) {
//         await _firestore.collection('users').doc(user.uid).update({
//           'currentSubscription': trialSubscription.toMap(),
//           'trialStarted': Timestamp.now(),
//         });

//         // Schedule trial expiry check (only for paid trials)
//         if (user.userType != UserType.parent) { // Parent free plan doesn't expire
//           _scheduleTrialExpiryCheck(user.uid, trialSubscription.expiryDate);
//         }
//       }
//     } catch (e) {
//       print('Error creating free trial: $e');
//     }
//   }

//   // Purchase subscription based on user type
//   Future<bool> purchaseSubscription({
//     required dynamic plan, // Can be StudentPlan, TeacherPlan, etc.
//     required String userId,
//     required UserType userType,
//     String? transactionId,
//   }) async {
//     try {
//       Subscription? subscription;
      
//       // Create appropriate subscription based on user type
//       switch (userType) {
//         case UserType.student:
//           if (plan is StudentPlan) {
//             subscription = StudentSubscription.create(
//               plan: plan,
//               transactionId: transactionId,
//             );
//           }
//           break;
//         case UserType.teacher:
//           if (plan is TeacherPlan) {
//             subscription = TeacherSubscription.create(
//               plan: plan,
//               transactionId: transactionId,
//             );
//           }
//           break;
//         case UserType.schoolAdmin:
//           if (plan is SchoolPlan) {
//             subscription = SchoolSubscription.create(
//               plan: plan,
//               transactionId: transactionId,
//             );
//           }
//           break;
//         case UserType.parent:
//           if (plan is ParentPlan) {
//             subscription = ParentSubscription.create(
//               plan: plan,
//               transactionId: transactionId,
//             );
//           }
//           break;
//       }

//       if (subscription == null) {
//         throw Exception('Invalid plan for user type');
//       }

//       // Update user document
//       await _firestore.collection('users').doc(userId).update({
//         'currentSubscription': subscription.toMap(),
//         'lastSubscriptionUpdate': Timestamp.now(),
//       });

//       // Create payment record
//       await _createPaymentRecord(
//         userId: userId,
//         subscription: subscription,
//       );

//       return true;
//     } catch (e) {
//       print('Error purchasing subscription: $e');
//       return false;
//     }
//   }

//   // Check subscription status
//   Future<SubscriptionStatus> checkSubscriptionStatus(BaseUser user) async {
//     try {
//       if (user.currentSubscription == null) {
//         return SubscriptionStatus.inactive;
//       }

//       final subscription = user.currentSubscription!;

//       if (!subscription.isActive) {
//         return SubscriptionStatus.paymentPending;
//       }

//       if (subscription.hasExpired) {
//         return SubscriptionStatus.expired;
//       }

//       // Check if it's a trial
//       if (subscription.plan == SubscriptionPlan.trial && !subscription.hasExpired) {
//         return SubscriptionStatus.trial;
//       }

//       return SubscriptionStatus.active;
//     } catch (e) {
//       print('Error checking subscription: $e');
//       return SubscriptionStatus.error;
//     }
//   }

//   // Get subscription info for user
//   Future<Subscription?> getUserSubscription(String userId) async {
//     try {
//       final doc = await _firestore.collection('users').doc(userId).get();
//       final data = doc.data();

//       if (data != null && data['currentSubscription'] != null) {
//         // Get user type to determine which subscription type to create
//         final userTypeString = data['userType'] as String? ?? 'student';
//         final userType = UserType.values.firstWhere(
//           (e) => e.name == userTypeString,
//           orElse: () => UserType.student,
//         );

//         return createSubscriptionForUserType(userType, data['currentSubscription']);
//       }
//       return null;
//     } catch (e) {
//       print('Error getting user subscription: $e');
//       return null;
//     }
//   }

//   // Renew subscription automatically
//   Future<bool> autoRenewSubscription(BaseUser user) async {
//     try {
//       final subscription = user.currentSubscription;
      
//       if (subscription == null || !subscription.autoRenew) {
//         return false;
//       }

//       // Check if subscription is about to expire (within 3 days)
//       final daysUntilExpiry = subscription.expiryDate
//           .difference(DateTime.now())
//           .inDays;

//       if (daysUntilExpiry <= 3) {
//         // Process renewal payment
//         dynamic plan;
        
//         // Get the appropriate plan enum based on subscription type
//         if (subscription is StudentSubscription) {
//           plan = subscription.studentPlan;
//         } else if (subscription is TeacherSubscription) {
//           plan = subscription.teacherPlan;
//         } else if (subscription is SchoolSubscription) {
//           plan = subscription.schoolPlan;
//         } else if (subscription is ParentSubscription) {
//           plan = subscription.parentPlan;
//         }

//         if (plan != null) {
//           final renewed = await purchaseSubscription(
//             plan: plan,
//             userId: user.uid,
//             userType: user.userType,
//             transactionId: 'auto_renew_${DateTime.now().millisecondsSinceEpoch}',
//           );

//           return renewed;
//         }
//       }

//       return false;
//     } catch (e) {
//       print('Error auto-renewing subscription: $e');
//       return false;
//     }
//   }

//   // Cancel subscription auto-renewal
//   Future<bool> cancelSubscription(String userId) async {
//     try {
//       await _firestore.collection('users').doc(userId).update({
//         'currentSubscription.autoRenew': false,
//         'subscriptionCancelled': Timestamp.now(),
//       });
//       return true;
//     } catch (e) {
//       print('Error cancelling subscription: $e');
//       return false;
//     }
//   }

//   // Create payment record
//   Future<void> _createPaymentRecord({
//     required String userId,
//     required Subscription subscription,
//   }) async {
//     await _firestore.collection('payments').doc(subscription.transactionId).set({
//       'userId': userId,
//       'amount': subscription.amount,
//       'plan': subscription.plan.name,
//       'transactionId': subscription.transactionId,
//       'status': subscription.paymentStatus.name,
//       'date': Timestamp.now(),
//       'currency': 'NGN',
//       'description': subscription.planDescription,
//     });
//   }

//   // Schedule trial expiry check
//   void _scheduleTrialExpiryCheck(String userId, DateTime expiryDate) {
//     final durationUntilExpiry = expiryDate.difference(DateTime.now());
    
//     if (durationUntilExpiry.inSeconds > 0) {
//       Future.delayed(durationUntilExpiry, () async {
//         await _handleTrialExpiry(userId);
//       });
//     }
//   }

//   Future<void> _handleTrialExpiry(String userId) async {
//     try {
//       final doc = await _firestore.collection('users').doc(userId).get();
//       final subscriptionData = doc.data()?['currentSubscription'];

//       if (subscriptionData != null) {
//         // Get user type to parse subscription
//         final userTypeString = doc.data()?['userType'] as String? ?? 'student';
//         final userType = UserType.values.firstWhere(
//           (e) => e.name == userTypeString,
//           orElse: () => UserType.student,
//         );

//         final subscription = createSubscriptionForUserType(userType, subscriptionData);
        
//         if (subscription.plan == SubscriptionPlan.trial && subscription.hasExpired) {
//           await _firestore.collection('users').doc(userId).update({
//             'currentSubscription': FieldValue.delete(),
//             'trialExpired': Timestamp.now(),
//           });

//           // Send notification to user about trial expiry
//           await _sendTrialExpiryNotification(userId);
//         }
//       }
//     } catch (e) {
//       print('Error handling trial expiry: $e');
//     }
//   }

//   Future<void> _sendTrialExpiryNotification(String userId) async {
//     // Implement notification logic
//     print('Trial expired for user: $userId');
//   }

//   // Get subscription plans with pricing for specific user type
//   static List<Map<String, dynamic>> getSubscriptionPlansForUserType(UserType userType) {
//     switch (userType) {
//       case UserType.student:
//         return [
//           {
//             'plan': StudentPlan.basic,
//             'name': 'Student Basic',
//             'price': StudentSubscription.studentPrices[StudentPlan.basic],
//             'duration': 'Monthly',
//             'features': [
//               'Access to basic courses',
//               'Limited quizzes',
//               'Basic progress tracking',
//               '2 devices maximum',
//             ],
//             'popular': false,
//           },
//           {
//             'plan': StudentPlan.premium,
//             'name': 'Student Premium',
//             'price': StudentSubscription.studentPrices[StudentPlan.premium],
//             'duration': 'Monthly',
//             'features': [
//               'Access to all courses',
//               'Unlimited quizzes',
//               'Advanced progress tracking',
//               'Parental controls',
//               '5 devices maximum',
//             ],
//             'popular': true,
//           },
//           {
//             'plan': StudentPlan.family,
//             'name': 'Family Plan',
//             'price': StudentSubscription.studentPrices[StudentPlan.family],
//             'duration': 'Monthly',
//             'features': [
//               'Up to 3 students',
//               'Access to all courses',
//               'Unlimited quizzes',
//               'Family progress tracking',
//               'Parental controls',
//               '10 devices maximum',
//             ],
//             'popular': false,
//           },
//         ];

//       case UserType.teacher:
//         return [
//           {
//             'plan': TeacherPlan.basic,
//             'name': 'Teacher Basic',
//             'price': TeacherSubscription.teacherPrices[TeacherPlan.basic],
//             'duration': 'Monthly',
//             'features': [
//               'Up to 100 students',
//               'Basic analytics',
//               '10GB storage',
//               'Resource sharing',
//             ],
//             'popular': false,
//           },
//           {
//             'plan': TeacherPlan.pro,
//             'name': 'Teacher Pro',
//             'price': TeacherSubscription.teacherPrices[TeacherPlan.pro],
//             'duration': 'Monthly',
//             'features': [
//               'Up to 500 students',
//               'Advanced analytics',
//               '50GB storage',
//               'Resource sharing',
//               'Community access',
//             ],
//             'popular': true,
//           },
//           {
//             'plan': TeacherPlan.school,
//             'name': 'School License',
//             'price': TeacherSubscription.teacherPrices[TeacherPlan.school],
//             'duration': 'Monthly',
//             'features': [
//               'Up to 2000 students',
//               'Enterprise analytics',
//               '200GB storage',
//               'Unlimited resources',
//               'Priority support',
//             ],
//             'popular': false,
//           },
//         ];

//       case UserType.schoolAdmin:
//         return [
//           {
//             'plan': SchoolPlan.basic,
//             'name': 'School Basic',
//             'price': SchoolSubscription.schoolPrices[SchoolPlan.basic],
//             'duration': 'Annual',
//             'features': [
//               'Up to 1000 students',
//               'Up to 50 teachers',
//               'Basic analytics',
//               '40 support hours',
//               'Parent portal access',
//             ],
//             'popular': false,
//           },
//           {
//             'plan': SchoolPlan.advanced,
//             'name': 'School Advanced',
//             'price': SchoolSubscription.schoolPrices[SchoolPlan.advanced],
//             'duration': 'Annual',
//             'features': [
//               'Up to 5000 students',
//               'Up to 200 teachers',
//               'Advanced analytics',
//               '80 support hours',
//               'Finance module',
//               'Attendance system',
//             ],
//             'popular': true,
//           },
//           {
//             'plan': SchoolPlan.enterprise,
//             'name': 'School Enterprise',
//             'price': SchoolSubscription.schoolPrices[SchoolPlan.enterprise],
//             'duration': 'Annual',
//             'features': [
//               'Up to 10,000 students',
//               'Up to 500 teachers',
//               'Enterprise analytics',
//               '160 support hours',
//               'All modules included',
//               'Unlimited storage',
//               'Dedicated support',
//             ],
//             'popular': false,
//           },
//         ];

//       case UserType.parent:
//         return [
//           {
//             'plan': ParentPlan.free,
//             'name': 'Parent Free',
//             'price': ParentSubscription.parentPrices[ParentPlan.free],
//             'duration': 'Free',
//             'features': [
//               '1 child monitoring',
//               'Basic academic updates',
//             ],
//             'popular': false,
//           },
//           {
//             'plan': ParentPlan.premium,
//             'name': 'Parent Premium',
//             'price': ParentSubscription.parentPrices[ParentPlan.premium],
//             'duration': 'Monthly',
//             'features': [
//               'Up to 5 children',
//               'Real-time tracking',
//               'Detailed academic reports',
//               'Communication portal',
//               'Fee payment integration',
//             ],
//             'popular': true,
//           },
//         ];
//     }
//   }

//   // Get plan price for a specific plan
//   static double? getPlanPrice(dynamic plan) {
//     if (plan is StudentPlan) {
//       return StudentSubscription.studentPrices[plan];
//     } else if (plan is TeacherPlan) {
//       return TeacherSubscription.teacherPrices[plan];
//     } else if (plan is SchoolPlan) {
//       return SchoolSubscription.schoolPrices[plan];
//     } else if (plan is ParentPlan) {
//       return ParentSubscription.parentPrices[plan];
//     }
//     return null;
//   }

//   // Get plan description
//   static String getPlanDescription(dynamic plan) {
//     if (plan is StudentPlan) {
//       return StudentSubscription._getStudentPlanDescription(plan);
//     } else if (plan is TeacherPlan) {
//       return TeacherSubscription._getTeacherPlanDescription(plan);
//     } else if (plan is SchoolPlan) {
//       return SchoolSubscription._getSchoolPlanDescription(plan);
//     } else if (plan is ParentPlan) {
//       return ParentSubscription._getParentPlanDescription(plan);
//     }
//     return '';
//   }
// }

// enum SubscriptionStatus {
//   active,
//   inactive,
//   expired,
//   paymentPending,
//   trial,
//   error,
// }