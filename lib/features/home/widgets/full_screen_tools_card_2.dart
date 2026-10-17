import 'package:flutter/material.dart';

import 'package:isapp/features/score_sheet/screens/score_sheet.dart';

class FullScreenToolsCard extends StatelessWidget {
  final List<Map<String, String>> toolItems;
  const FullScreenToolsCard({super.key, required this.toolItems});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Hero(
        tag: 'toolsCard',
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              // Background Image with Blur
              Image.asset(
                'assets/explore_bg.jpeg',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
              
              // Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.blue.withOpacity(0.8),
                      Colors.blue[800]!.withOpacity(0.9),
                      Colors.blue[900]!.withOpacity(0.95),
                    ],
                  ),
                ),
              ),
              
              // Content
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Learning Toolkit',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    height: 1.2,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Essential tools for academic success',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Tools Grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.2,
                        ),
                        itemCount: toolItems.length,
                        itemBuilder: (context, index) {
                          final tool = toolItems[index];
                          final icon = _getToolIcon(tool['title']!);
                          
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {
                                  _handleToolTap(context, tool['title']!);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        icon,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        tool['title']!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getToolIcon(String title) {
    switch (title) {
      case 'Account Settings':
        return Icons.person_rounded;
      case 'Privacy':
        return Icons.security_rounded;
      case 'Score Sheet':
        return Icons.assessment_rounded;
      case 'Notepad':
        return Icons.note_add_rounded;
      default:
        return Icons.build_rounded;
    }
  }

  void _handleToolTap(BuildContext context, String title) {
    if (title == "Account Settings") {
      _showProfileBottomSheet(context);
    } else if (title == "Privacy") {
      _showPrivacyPolicy(context);
    } else if (title == "Score Sheet") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => StudentResultsPage()),
      );
    } else if (title == "Notepad") {
      // Handle Notepad
    }
  }

  void _showProfileBottomSheet(BuildContext context) {
    // Your existing implementation
  }

  void _showPrivacyPolicy(BuildContext context) {
    // Your existing implementation
  }
}
