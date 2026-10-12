import 'package:flutter/material.dart';
import 'policy_widgets.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terms of Service')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [

            PolicyHeader('TERMS OF SERVICE'),
            PolicyBody(
              'Last Updated: January 2026\n\n'
              'Welcome to Scholon. These Terms of Service ("Terms") form a legally binding agreement '
              'between you and Scholon governing your access to and use of our applications, websites, '
              'learning systems, content libraries, AI-powered tools, and all related services.'
            ),

            PolicyHeader('1. ACCEPTANCE OF TERMS'),
            PolicyBody(
              'By downloading, installing, accessing, registering, or otherwise using Scholon, '
              'you acknowledge that you have read, understood, and agreed to be bound by these Terms. '
              'If you do not agree, you must immediately discontinue use of the Service.'
            ),

            PolicySubHeader('1.1 Binding Nature'),
            PolicyBody(
              'These Terms apply to all users including students, teachers, institutions, parents, '
              'administrators, and any other individuals or entities accessing Scholon.'
            ),

            PolicyHeader('2. ELIGIBILITY'),
            PolicyBody(
              'You must have the legal capacity to enter into an agreement. Where minors are involved, '
              'a parent or legal guardian assumes full responsibility for supervision, consent, and compliance.'
            ),

            PolicyHeader('3. ACCOUNT REGISTRATION'),
            PolicySubHeader('3.1 Account Accuracy'),
            PolicyBody(
              'You agree to provide accurate, current, and complete information during registration '
              'and to update such information as necessary.'
            ),

            PolicySubHeader('3.2 Account Security'),
            PolicyBody(
              'You are solely responsible for safeguarding your login credentials and for all activities '
              'conducted under your account. Scholon shall not be liable for unauthorized access resulting '
              'from your failure to protect your credentials.'
            ),

            PolicyHeader('4. PLATFORM PURPOSE'),
            PolicyBody(
              'Scholon is an educational technology platform designed to facilitate learning, teaching, '
              'assessment, collaboration, and academic resource distribution. Scholon does not replace '
              'formal schooling, accreditation bodies, or government education authorities.'
            ),

            PolicyHeader('5. USER CONDUCT'),
            PolicySubHeader('5.1 Prohibited Activities'),
            PolicyBody(
              'You agree not to misuse Scholon. Prohibited activities include but are not limited to:\n\n'
              '• Uploading harmful or unlawful content\n'
              '• Harassment or abuse of other users\n'
              '• Circumventing security measures\n'
              '• Reverse engineering the platform\n'
              '• Academic dishonesty or impersonation'
            ),

            PolicyHeader('6. EDUCATIONAL CONTENT'),
            PolicyBody(
              'All courses, lessons, notes, quizzes, videos, audio content, and AI-generated materials '
              'are provided for educational purposes only and may not always be error-free.'
            ),

            PolicyHeader('7. INTELLECTUAL PROPERTY'),
            PolicyBody(
              'All Scholon trademarks, logos, software, and proprietary content remain the exclusive '
              'property of Scholon or its licensors. Unauthorized reproduction or redistribution is prohibited.'
            ),

            PolicyHeader('8. AI-POWERED FEATURES'),
            PolicySubHeader('8.1 Informational Use'),
            PolicyBody(
              'AI responses are generated algorithmically and may be inaccurate, incomplete, or outdated. '
              'They are not professional advice and should not be relied upon as authoritative.'
            ),

            PolicyHeader('9. PAYMENTS & SUBSCRIPTIONS'),
            PolicyBody(
              'Paid features may be offered. Subscriptions may renew automatically unless cancelled. '
              'Pricing, billing cycles, and refund eligibility are subject to change.'
            ),

            PolicyHeader('10. CERTIFICATES'),
            PolicyBody(
              'Certificates issued by Scholon represent platform-based achievements only and do not '
              'guarantee recognition by external institutions or employers.'
            ),

            PolicyHeader('11. TERMINATION'),
            PolicyBody(
              'Scholon reserves the right to suspend or terminate accounts for violations of these Terms, '
              'suspected abuse, or legal compliance without prior notice.'
            ),

            PolicyHeader('12. DISCLAIMER'),
            PolicyBody(
              'THE SERVICE IS PROVIDED "AS IS" WITHOUT WARRANTIES OF ANY KIND. SCHOLON DISCLAIMS ALL IMPLIED '
              'WARRANTIES INCLUDING MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT.'
            ),

            PolicyHeader('13. LIMITATION OF LIABILITY'),
            PolicyBody(
              'IN NO EVENT SHALL SCHOLON BE LIABLE FOR INDIRECT, INCIDENTAL, SPECIAL, OR CONSEQUENTIAL DAMAGES, '
              'INCLUDING LOSS OF DATA, ACADEMIC PERFORMANCE, OR REVENUE.'
            ),

            PolicyHeader('14. GOVERNING LAW'),
            PolicyBody(
              'These Terms shall be governed by and construed in accordance with applicable local laws '
              'without regard to conflict of law principles.'
            ),

            PolicyHeader('15. MODIFICATIONS'),
            PolicyBody(
              'Scholon may update these Terms at any time. Continued use after changes constitutes acceptance.'
            ),

            PolicyHeader('16. CONTACT'),
            PolicyBody(
              'For questions regarding these Terms, contact:\n\nsupport@scholon.ng'
            ),
          ],
        ),
      ),
    );
  }
}
