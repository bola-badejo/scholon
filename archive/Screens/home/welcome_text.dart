// lib/Widgets/welcome_text.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isapp/features/auth/models/user.dart';
import 'package:isapp/features/auth/controllers/authentication_controller.dart';

class WelcomeText extends StatelessWidget {
  const WelcomeText({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();
    final user = authService.currentUser.value;
    final subscription = user?.currentSubscription;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            children: [
              TextSpan(
                text: 'Ready to ',
                style: TextStyle(
                  color: Colors.grey[800],
                ),
              ),
              const TextSpan(
                text: 'Learn',
                style: TextStyle(
                  color: Colors.deepPurple,
                ),
              ),
              TextSpan(
                text: ' Today?',
                style: TextStyle(
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subscription != null && subscription.isActive
              ? subscription.plan == SubscriptionPlan.trial
                  ? 'Your free trial ends in ${subscription.daysRemaining} days'
                  : 'Your ${subscription.plan.name} plan is active'
              : 'Explore all features with a subscription',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}