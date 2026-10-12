import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:isapp/Screens/home/fullscreen/course_card.dart';
import 'package:isapp/Widgets/welcome_text.dart';
import '../../Models/courses.dart';
import '../../Utils/library/course_logic.dart';

class BodyParts extends StatelessWidget {
  BodyParts({super.key});

  final List<Map<String, String>> items = [
    {
      'image': 'assets/finance1.png',
      'title': 'Account Settings',
    },
    {
      'image': 'assets/finance1.png',
      'title': 'Privacy',
    },
    {
      'image': 'assets/finance1.png',
      'title': 'Score Sheet',
    },
    {'image': 'assets/finance1.png', 'title': 'Notepad', 'subtitle': 'Stories'}
  ];

  @override
  Widget build(BuildContext context) {
    List<CourseCategories> categories = parseCourseCategoriesJson();
    List<CourseCategories> quiz = parseQuizCategoriesJson();
    List<CourseCategories> exam = parseExamCategoriesJson();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Section
        _buildHeaderSection(),
        
        // Welcome Text
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: welcomeText(),
        ).animate().fadeIn(duration: 400.ms).slideX(
          begin: -0.1,
          end: 0,
          curve: Curves.easeOut,
        ),
        
        const SizedBox(height: 20),
        
        // Courses Section
        _buildCourseCard(context, categories),
        
        const SizedBox(height: 16),
        
        // Quizzes Section
        _buildQuizCard(context, quiz),
        
        const SizedBox(height: 16),
        
        // Exams Section
        _buildExamCard(context, exam),
        
        const SizedBox(height: 16),
        
        // Tools Section
        _buildToolsCard(context),
        
        const SizedBox(height: 16),
        
        // Games Section
        _buildGamesCard(context),
        
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildHeaderSection() {
    final DateTime now = DateTime.now();
    final List<String> months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                days[now.weekday - 1],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "${months[now.month - 1]} ${now.day}",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF4A44C6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                "BB",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ).animate(
            delay: 300.ms,
          ).scale(
            curve: Curves.elasticOut,
            duration: 600.ms,
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, List<CourseCategories> categories) {
    return Hero(
      tag: 'courseCard',
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FullScreenCourseCard(categories: categories),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          height: 280,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background Image with Overlay
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/learn_bg.jpeg',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 280,
                ),
              ),
              
              // Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.deepPurple.withOpacity(0.7),
                      Colors.deepPurple.withOpacity(0.9),
                    ],
                  ),
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "Featured",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Title
                    const Text(
                      "Personalized Learning Paths",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Description
                    Text(
                      "Master NERDC curriculum with expert-guided courses from Primary to Secondary",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Stats
                    Row(
                      children: [
                        _buildStatItem("${categories.length}", "Courses", Icons.menu_book_rounded),
                        const SizedBox(width: 16),
                        _buildStatItem("100%", "Coverage", Icons.check_circle_rounded),
                        const SizedBox(width: 16),
                        _buildStatItem("24/7", "Access", Icons.access_time_rounded),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // CTA Button
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          "Explore Courses",
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 500.ms).slideY(
          begin: 0.2,
          end: 0,
          curve: Curves.easeOut,
        ),
      ),
    );
  }

  Widget _buildQuizCard(BuildContext context, List<CourseCategories> quiz) {
    return Hero(
      tag: 'quizCard',
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FullScreenQuizCard(categories: quiz),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6B6B), Color(0xFFEE5A5A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF6B6B).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background Pattern
              Positioned(
                right: -50,
                top: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "Interactive",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 12),
                          
                          const Text(
                            "Smart Quizzes",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          Text(
                            "Test your knowledge with adaptive quizzes & instant feedback",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(width: 20),
                    
                    // Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.quiz_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 600.ms).slideY(
          begin: 0.2,
          end: 0,
          curve: Curves.easeOut,
          delay: 100.ms,
        ),
      ),
    );
  }

  Widget _buildExamCard(BuildContext context, List<CourseCategories> exam) {
    return Hero(
      tag: 'examCard',
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FullScreenExamsCard(categories: exam),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2ECC71).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background Pattern
              Positioned(
                left: -50,
                top: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.assignment_turned_in_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    
                    const SizedBox(width: 20),
                    
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "Exam Prep",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 12),
                          
                          const Text(
                            "JAMB • WAEC • NECO",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          Text(
                            "Past questions & mock exams for real exam experience",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 700.ms).slideY(
          begin: 0.2,
          end: 0,
          curve: Curves.easeOut,
          delay: 200.ms,
        ),
      ),
    );
  }

  Widget _buildToolsCard(BuildContext context) {
    return Hero(
      tag: 'toolsCard',
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FullScreenToolsCard(toolItems: items),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3498DB).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: 20,
                top: 20,
                child: Icon(
                  Icons.build_rounded,
                  size: 80,
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Learning Toolkit",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      "Everything you need for academic success in one place",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    
                    const Spacer(),
                    
                    Row(
                      children: [
                        _buildToolItem(Icons.person, "Profile"),
                        const SizedBox(width: 12),
                        _buildToolItem(Icons.security, "Privacy"),
                        const SizedBox(width: 12),
                        _buildToolItem(Icons.assessment, "Scores"),
                        const SizedBox(width: 12),
                        _buildToolItem(Icons.note_add, "Notes"),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 800.ms).slideY(
          begin: 0.2,
          end: 0,
          curve: Curves.easeOut,
          delay: 300.ms,
        ),
      ),
    );
  }

  Widget _buildGamesCard(BuildContext context) {
    return Hero(
      tag: 'gamesCard',
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FullScreenGamesCard(gameItems: gameItems),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          height: 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFF9B59B6), Color(0xFF8E44AD)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF9B59B6).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -30,
                top: -30,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "Play & Learn",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.videogame_asset_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    const Text(
                      "Educational Games",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      "Learn through play with our interactive game collection",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    
                    const Spacer(),
                    
                    Row(
                      children: [
                        _buildGameItem("assets/bee.png", "Spelling Bee"),
                        const SizedBox(width: 12),
                        _buildGameItem("assets/ttt.png", "Tic Tac Toe"),
                        const SizedBox(width: 12),
                        _buildGameItem("assets/ttt.png", "Sudoku"),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 900.ms).slideY(
          begin: 0.2,
          end: 0,
          curve: Curves.easeOut,
          delay: 400.ms,
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.8),
          size: 16,
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildToolItem(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildGameItem(String image, String name) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: Image.asset(
              image,
              width: 30,
              height: 30,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  List<CourseCategories> parseCourseCategoriesJson() {
    List<dynamic> jsonList = jsonDecode(Constants.courseCategoriesJson);
    return jsonList.map((json) => CourseCategories.fromJson(json)).toList();
  }

  List<CourseCategories> parseQuizCategoriesJson() {
    List<dynamic> jsonList = jsonDecode(Constants.quizCategoriesJson);
    return jsonList.map((json) => CourseCategories.fromJson(json)).toList();
  }

  List<CourseCategories> parseExamCategoriesJson() {
    List<dynamic> jsonList = jsonDecode(Constants.examCategoriesJson);
    return jsonList.map((json) => CourseCategories.fromJson(json)).toList();
  }
}

class GameDetail {
  String image;
  String emojiImage;
  String name;
  String instructor;
  String description;
  Color color;
  int time;

  GameDetail({
    required this.emojiImage,
    required this.description,
    required this.color,
    required this.image,
    required this.name,
    required this.instructor,
    required this.time,
  });
}

List<GameDetail> gameItems = [
  GameDetail(
    emojiImage: "assets/bee.png",
    description: "Mobile spelling bee game for school kids",
    color: const Color(0xFFC7E9FE),
    image: "assets/bee.png",
    name: 'Spelling Bee',
    instructor: "B. Badejo",
    time: 3,
  ),
  GameDetail(
    emojiImage: "assets/ttt.png",
    description: "Mobile Tic Tac Toe game for all ages",
    color: const Color(0xFFFFDEFF),
    image: "assets/ttt.png",
    name: 'Tic Tac Toe',
    instructor: "B. Badejo",
    time: 1,
  ),
  GameDetail(
    emojiImage: "assets/ttt.png",
    description: "Mobile Sudoku game for all ages",
    color: const Color(0xFFFFDEFF),
    image: "assets/ttt.png",
    name: 'Sudoku',
    instructor: "B. Badejo",
    time: 1,
  ),
];