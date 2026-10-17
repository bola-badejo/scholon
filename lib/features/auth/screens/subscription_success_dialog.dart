import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:isapp/features/auth/models/user.dart';

class SubscriptionSuccessDialog extends StatelessWidget {
  final String planName;
  final double amount;
  final String duration;
  final bool isAnnual;
  final String paymentMethod;
  final bool isKidling;

  const SubscriptionSuccessDialog({
    Key? key,
    required this.planName,
    required this.amount,
    required this.duration,
    required this.isAnnual,
    required this.paymentMethod,
    this.isKidling = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accentColor = isKidling ? Colors.pink : Colors.deepPurple;
    final icon = isKidling ? Icons.child_care : Icons.check_circle;
    final title = isKidling ? 'Welcome to Kidling!' : 'Subscription Successful!';
    final message = isKidling
        ? 'Your child\'s learning adventure begins now!'
        : 'Welcome to $planName plan';

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      child: Container(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 50,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Plan:', style: TextStyle(color: Colors.grey[600])),
                      Text(planName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Amount:', style: TextStyle(color: Colors.grey[600])),
                      Text(
                        '₦$amount',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Duration:', style: TextStyle(color: Colors.grey[600])),
                      Text(duration, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Payment Method:', style: TextStyle(color: Colors.grey[600])),
                      Text(paymentMethod, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                children: [
                  const TextSpan(text: 'Your subscription is now active. '),
                  TextSpan(
                    text: 'A receipt has been sent to your email.',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Get.until((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isKidling ? 'Start Playing & Learning' : 'Start Learning Now',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Get.toNamed('/subscription-details'),
              child: Text(
                'View Subscription Details',
                style: TextStyle(color: accentColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
