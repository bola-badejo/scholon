import 'package:flutter/material.dart';
import 'policy_widgets.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [

            PolicyHeader('PRIVACY POLICY'),
            PolicyBody(
              'Last Updated: January 2026\n\n'
              'Scholon ("we", "us", "our") is committed to protecting your privacy and safeguarding '
              'the personal, educational, and technical information of all users. This Privacy Policy '
              'explains how information is collected, used, stored, processed, and protected when you '
              'use the Scholon platform.'
            ),

            PolicyHeader('1. SCOPE OF THIS POLICY'),
            PolicyBody(
              'This Privacy Policy applies to all users of Scholon, including students, educators, '
              'institutions, administrators, parents, guardians, and visitors. It covers all services, '
              'applications, websites, APIs, AI tools, and learning systems operated by Scholon.'
            ),

            PolicyHeader('2. DEFINITIONS'),
            PolicyBody(
              '• "Personal Data" means any information that identifies or can identify an individual.\n'
              '• "Educational Data" refers to academic records, assessments, progress, and certificates.\n'
              '• "Processing" means any operation performed on data including collection, storage, use, or deletion.\n'
              '• "Third Party" refers to service providers that assist Scholon operations.'
            ),

            PolicyHeader('3. INFORMATION WE COLLECT'),
            PolicySubHeader('3.1 Personal Information'),
            PolicyBody(
              'We may collect personal information such as:\n\n'
              '• Full name\n'
              '• Email address\n'
              '• Phone number\n'
              '• Profile photos\n'
              '• Account identifiers\n'
              '• Institutional affiliation'
            ),

            PolicySubHeader('3.2 Educational & Academic Data'),
            PolicyBody(
              'Educational data collected may include:\n\n'
              '• Courses enrolled\n'
              '• Learning progress\n'
              '• Quiz and exam results\n'
              '• Assignments and submissions\n'
              '• Certificates earned\n'
              '• Teacher feedback'
            ),

            PolicySubHeader('3.3 Technical & Usage Data'),
            PolicyBody(
              'We automatically collect technical data such as:\n\n'
              '• Device type and model\n'
              '• Operating system\n'
              '• App version\n'
              '• IP address (anonymized where possible)\n'
              '• Crash reports\n'
              '• Usage analytics'
            ),

            PolicyHeader('4. HOW WE COLLECT DATA'),
            PolicyBody(
              'Data is collected through:\n\n'
              '• Account registration forms\n'
              '• User interactions with the platform\n'
              '• Automated logging systems\n'
              '• Third-party authentication providers\n'
              '• AI interaction sessions'
            ),

            PolicyHeader('5. PURPOSE OF DATA PROCESSING'),
            PolicyBody(
              'We process personal and educational data for the following purposes:\n\n'
              '• Providing and maintaining educational services\n'
              '• Personalizing learning experiences\n'
              '• Conducting assessments and certifications\n'
              '• Supporting educators and institutions\n'
              '• Improving platform functionality\n'
              '• Ensuring system security and fraud prevention\n'
              '• Legal and regulatory compliance'
            ),

            PolicyHeader('6. AI & AUTOMATED PROCESSING'),
            PolicySubHeader('6.1 AI Learning Tools'),
            PolicyBody(
              'Scholon uses artificial intelligence to assist learning, generate explanations, '
              'recommend content, and enhance educational outcomes. AI outputs are generated '
              'algorithmically and may not always be accurate.'
            ),

            PolicySubHeader('6.2 AI Data Handling'),
            PolicyBody(
              'AI systems may process anonymized or pseudonymized data to improve performance. '
              'Private conversations are not sold or used for advertising purposes.'
            ),

            PolicyHeader('7. CHILDREN & STUDENT PRIVACY'),
            PolicyBody(
              'Scholon is designed for educational use, including by minors. Where applicable:\n\n'
              '• Parental or institutional consent is required\n'
              '• Student data is handled with heightened protection\n'
              '• No targeted advertising is directed at children\n'
              '• Educational records are not publicly disclosed'
            ),

            PolicyHeader('8. DATA SHARING & DISCLOSURE'),
            PolicyBody(
              'We do NOT sell personal data. Data may be shared only with:\n\n'
              '• Cloud hosting providers\n'
              '• Payment processors\n'
              '• Analytics services\n'
              '• Educators and institutions (limited academic data)\n'
              '• Legal authorities where required by law'
            ),

            PolicyHeader('9. THIRD-PARTY SERVICES'),
            PolicyBody(
              'Scholon may integrate third-party services. These providers are contractually obligated '
              'to protect user data and process it only for authorized purposes.'
            ),

            PolicyHeader('10. DATA STORAGE & SECURITY'),
            PolicyBody(
              'We implement industry-standard security measures including:\n\n'
              '• Data encryption\n'
              '• Secure servers\n'
              '• Access controls\n'
              '• Regular monitoring\n\n'
              'Despite these measures, no system is completely secure.'
            ),

            PolicyHeader('11. DATA RETENTION'),
            PolicyBody(
              'Data is retained only as long as necessary to:\n\n'
              '• Provide educational services\n'
              '• Maintain academic records\n'
              '• Comply with legal obligations\n'
              '• Resolve disputes\n\n'
              'Data may be deleted upon valid request, subject to legal requirements.'
            ),

            PolicyHeader('12. USER RIGHTS'),
            PolicySubHeader('12.1 Access & Correction'),
            PolicyBody(
              'You have the right to access and correct your personal data.'
            ),

            PolicySubHeader('12.2 Deletion & Restriction'),
            PolicyBody(
              'You may request deletion or restriction of processing, subject to educational and legal obligations.'
            ),

            PolicySubHeader('12.3 Consent Withdrawal'),
            PolicyBody(
              'Where processing is based on consent, you may withdraw consent at any time.'
            ),

            PolicyHeader('13. INTERNATIONAL DATA TRANSFERS'),
            PolicyBody(
              'Your data may be stored or processed on servers located in different jurisdictions. '
              'Appropriate safeguards are implemented to ensure lawful transfers.'
            ),

            PolicyHeader('14. COOKIES & ANALYTICS'),
            PolicyBody(
              'Scholon may use cookies, local storage, and analytics tools to improve performance, '
              'understand usage patterns, and enhance user experience.'
            ),

            PolicyHeader('15. LEGAL COMPLIANCE'),
            PolicyBody(
              'Scholon complies with applicable data protection regulations, including:\n\n'
              '• Nigerian Data Protection Regulation (NDPR)\n'
              '• General Data Protection Regulation (GDPR) where applicable\n'
              '• Education-sector data protection standards'
            ),

            PolicyHeader('16. DATA BREACH RESPONSE'),
            PolicyBody(
              'In the event of a data breach, Scholon will:\n\n'
              '• Investigate promptly\n'
              '• Mitigate potential harm\n'
              '• Notify affected users where legally required'
            ),

            PolicyHeader('17. POLICY CHANGES'),
            PolicyBody(
              'This Privacy Policy may be updated periodically. Changes will be communicated within '
              'the app or through official channels.'
            ),

            PolicyHeader('18. CONTACT INFORMATION'),
            PolicyBody(
              'For privacy-related inquiries, requests, or complaints:\n\n'
              'Email: privacy@scholon.ng\n'
              'Support: support@scholon.ng'
            ),

            PolicyBody(
              '\nEND OF PRIVACY POLICY'
            ),
          ],
        ),
      ),
    );
  }
}
