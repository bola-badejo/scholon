// lib/Screens/subscription/subscription_faq_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SubscriptionFAQPage extends StatelessWidget {
  const SubscriptionFAQPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> faqs = [
      {
        'question': 'What payment methods do you accept?',
        'answer': 'We accept all major credit/debit cards (Visa, MasterCard, Verve), bank transfers, PayStack, Flutterwave, and wallet payments.',
      },
      {
        'question': 'Can I cancel my subscription anytime?',
        'answer': 'Yes, you can cancel your subscription at any time. The cancellation will take effect at the end of your current billing period.',
      },
      {
        'question': 'Do you offer refunds?',
        'answer': 'We offer a 14-day money-back guarantee for annual subscriptions. Monthly subscriptions can be cancelled before the next billing cycle.',
      },
      {
        'question': 'Can I switch between plans?',
        'answer': 'Yes, you can upgrade or downgrade your plan at any time. The changes will be reflected in your next billing cycle.',
      },
      {
        'question': 'Is there a free trial?',
        'answer': 'Yes, we offer a 30-day free trial for new users. No credit card is required for the trial.',
      },
      {
        'question': 'How many devices can I use?',
        'answer': 'It depends on your plan. Basic plans typically allow 2-3 devices, while premium plans allow 5-10 devices.',
      },
      {
        'question': 'Can I share my account with family?',
        'answer': 'We offer family plans that allow multiple users. Regular individual plans are for single use only.',
      },
      {
        'question': 'What happens when my trial ends?',
        'answer': 'After your trial ends, you\'ll be automatically downgraded to the free plan unless you choose a paid plan.',
      },
      {
        'question': 'Do you offer student discounts?',
        'answer': 'Yes, we offer special discounts for students. Please contact support with your student ID for verification.',
      },
      {
        'question': 'How do I update my payment information?',
        'answer': 'You can update your payment method in the Account Settings section under Billing & Payments.',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription FAQ'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF4A44C6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.help_outline, size: 40, color: Colors.white),
                  SizedBox(height: 12),
                  Text(
                    'Frequently Asked Questions',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Find answers to common questions about subscriptions, billing, and account management',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ...faqs.asMap().entries.map((entry) {
              final index = entry.key;
              final faq = entry.value;
              return ExpansionTile(
                key: Key('faq_$index'),
                initiallyExpanded: index == 0,
                title: Text(
                  faq['question']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Text(
                      faq['answer']!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Still have questions?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Our support team is here to help you with any questions or concerns.',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Get.toNamed('/contact-support'),
                          icon: const Icon(Icons.email, size: 18),
                          label: const Text('Email Support'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Get.toNamed('/live-chat'),
                          icon: const Icon(Icons.chat, size: 18),
                          label: const Text('Live Chat'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}