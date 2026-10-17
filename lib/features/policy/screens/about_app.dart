import 'package:flutter/material.dart';

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Stack(
        children: [
          // MAIN CONTENT
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.6,
                    color: Colors.white,
                    fontWeight: FontWeight.w500, // medium
                  ),
                  children: const [
                    TextSpan(
                      text: "App Name: ",
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    TextSpan(text: "Scholon | "),

                    TextSpan(
                      text: "Version: ",
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    TextSpan(text: "1.0.0 | "),

                    TextSpan(
                      text: "Release Year: ",
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    TextSpan(text: "2026 | "),

                    TextSpan(
                      text: "Developed By: ",
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    TextSpan(text: "Emirate Publishers LLC | "),

                    TextSpan(
                      text: "Lead Engineer: ",
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    TextSpan(text: "Bolarinwa Badejo | "),

                    TextSpan(
                      text: "Core Team: ",
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    TextSpan(
                        text:
                            "Mobile Engineers, Backend Engineers, UI/UX Designers, Curriculum Experts, Legal & Compliance Advisors | "),

                    TextSpan(
                      text: "Description: ",
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    TextSpan(
                      text:
                          "Scholon is an educational technology platform designed to deliver structured learning, curriculum-aligned content, AI-assisted study tools, secure data handling, institutional compliance features, and parent-governed learning environments for schools, educators, and learners across multiple regions. | ",
                    ),

                    TextSpan(
                      text: "Data Handling: ",
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    TextSpan(
                        text:
                            "All user data is encrypted, securely stored, consent-driven, audit-ready, and compliant with child data protection standards. | "),

                    TextSpan(
                      text: "Legal: ",
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    TextSpan(
                        text:
                            "Usage of this application is governed by accepted Terms of Service and Privacy Policies. | "),

                    TextSpan(
                      text: "Contact: ",
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    TextSpan(text: "support@scholon.app | "),

                    TextSpan(
                      text: "Rights: ",
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    TextSpan(
                        text:
                            "© 2026 Scholon Technologies Ltd. All rights reserved."),
                  ],
                ),
              ),
            ),
          ),

          // FLOATING X BUTTON
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
