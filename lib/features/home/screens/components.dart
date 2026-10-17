import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:isapp/core/widgets/welcome_text.dart';
import 'package:isapp/data/library/course_logic.dart';
import 'package:isapp/features/home/models/game_detail.dart';
import 'package:isapp/features/home/widgets/fullscreen/course_card.dart';
import 'package:isapp/features/learning/models/course_models.dart';

export 'package:isapp/features/home/models/game_detail.dart';

part 'components_sections/01_header_section.dart';
part 'components_sections/02_tools_card.dart';

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
