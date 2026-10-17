import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'package:isapp/features/onboarding/models/platform_option.dart';
import 'package:isapp/features/onboarding/widgets/platform_card.dart';

export 'package:isapp/features/onboarding/models/platform_option.dart';
export 'package:isapp/features/onboarding/widgets/platform_card.dart';

part 'platform_selection_screen_sections/01_selection_screen.dart';

class PlatformSelectionScreen extends StatefulWidget {
  const PlatformSelectionScreen({super.key});

  @override
  State<PlatformSelectionScreen> createState() => _PlatformSelectionScreenState();
}

class _PlatformSelectionScreenState extends State<PlatformSelectionScreen> {
  final PageController _controller = PageController(viewportFraction: 0.85);
  final PageController _verticalController = PageController();
  int _currentPage = 0;
  double _pageOffset = 0;

  final List<PlatformOption> _platforms = [
    PlatformOption(
      id: 'kidling',
      name: 'Kidling',
      tagline: 'Preschool Learning PlatformOption',
      description: 'Fun and interactive learning for preschoolers with age-appropriate games, stories, and creative activities.',
      icon: Icons.child_care,
      color: const Color(0xFFFF6B6B),
      image: 'assets/kidling.JPG',
      features: [
        'Age-appropriate content',
        'Interactive games & puzzles',
        'Story time with animations',
        'Creative arts & crafts',
        'Parent progress dashboard',
      ],
    ),
    PlatformOption(
      id: 'istudyapp',
      name: 'iStudyApp',
      tagline: 'Student Learning PlatformOption',
      description: 'Interactive learning for primary & secondary students with curriculum-aligned content, quizzes, and progress tracking.',
      icon: Icons.school,
      color: const Color(0xFF4361EE),
      image: 'assets/istudyapp.JPG',
      features: [
        'Curriculum-aligned content',
        'Practice tests & quizzes',
        'Progress tracking',
        'Personalized learning path',
      ],
    ),
    PlatformOption(
      id: 'teachly',
      name: 'Teachly',
      tagline: 'Teachers Community',
      description: 'Professional development, resource sharing, and collaboration platform for educators worldwide.',
      icon: Icons.people,
      color: const Color(0xFF06D6A0),
      image: 'assets/teachly.JPG',
      features: [
        'Teacher training resources',
        'Lesson plan sharing',
        'Community forums',
        'Professional development',
      ],
    ),
    PlatformOption(
      id: 'automated_school',
      name: 'Automated School',
      tagline: 'School Management System',
      description: 'Complete digital solution for school administration, student management, and operational efficiency.',
      icon: Icons.business,
      color: const Color(0xFF7209B7),
      image: 'assets/automated_school.JPG',
      features: [
        'Student management',
        'Staff administration',
        'Financial tracking',
        'Communication system',
      ],
    ),
    PlatformOption(
      id: 'parents_portal',
      name: 'Parents Portal',
      tagline: 'Parent Engagement PlatformOption',
      description: 'Stay connected with your child\'s education journey through real-time updates and performance analytics.',
      icon: Icons.family_restroom,
      color: const Color(0xFFFF9E00),
      image: 'assets/parent.JPG',
      features: [
        'Real-time performance tracking',
        'PTA notifications',
        'Fee payment portal',
        'Teacher communication',
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _pageOffset = _controller.page ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  void _selectPlatform(PlatformOption platform) {
    Get.toNamed(
      '/auth',
      arguments: {
        'platform': platform.id,
        'platformName': platform.name,
        'platformColor': platform.color.value,
        'platformImage': platform.image,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0E21) : const Color(0xFFF8F9FD),
      body: SafeArea(
        child: PageView(
          controller: _verticalController,
          scrollDirection: Axis.vertical,
          children: [
            // SCREEN 1: PlatformOption Selection
            _buildSelectionScreen(size, isDark),
            
            // SCREEN 2: PlatformOption Details (Scrollable)
            _buildDetailsScreen(size, isDark),
          ],
        ),
      ),
    );
  }

  IconData _getFeatureIcon(String feature) {
    if (feature.toLowerCase().contains('game') || feature.toLowerCase().contains('puzzle')) return Icons.games;
    if (feature.toLowerCase().contains('story')) return Icons.auto_stories;
    if (feature.toLowerCase().contains('art') || feature.toLowerCase().contains('craft')) return Icons.palette;
    if (feature.toLowerCase().contains('dashboard')) return Icons.dashboard;
    if (feature.toLowerCase().contains('content')) return Icons.book;
    if (feature.toLowerCase().contains('test') || feature.toLowerCase().contains('quiz')) return Icons.quiz;
    if (feature.toLowerCase().contains('tracking')) return Icons.trending_up;
    if (feature.toLowerCase().contains('learning')) return Icons.school;
    if (feature.toLowerCase().contains('training')) return Icons.train;
    if (feature.toLowerCase().contains('sharing')) return Icons.share;
    if (feature.toLowerCase().contains('community')) return Icons.groups;
    if (feature.toLowerCase().contains('management')) return Icons.manage_accounts;
    if (feature.toLowerCase().contains('admin')) return Icons.admin_panel_settings;
    if (feature.toLowerCase().contains('financial')) return Icons.attach_money;
    if (feature.toLowerCase().contains('communication')) return Icons.chat;
    if (feature.toLowerCase().contains('notification')) return Icons.notifications;
    if (feature.toLowerCase().contains('payment')) return Icons.payment;
    if (feature.toLowerCase().contains('teacher')) return Icons.person;
    return Icons.check_circle;
  }

  String _getFeatureDescription(String feature) {
    if (feature.toLowerCase().contains('game') || feature.toLowerCase().contains('puzzle')) {
      return 'Fun and educational games for young learners';
    } else if (feature.toLowerCase().contains('story')) {
      return 'Engaging animated stories and read-alongs';
    } else if (feature.toLowerCase().contains('art') || feature.toLowerCase().contains('craft')) {
      return 'Creative activities to develop fine motor skills';
    } else if (feature.toLowerCase().contains('dashboard')) {
      return 'Track your child\'s learning progress and milestones';
    } else if (feature.toLowerCase().contains('content')) {
      return 'Access curriculum-aligned study materials';
    } else if (feature.toLowerCase().contains('test') || feature.toLowerCase().contains('quiz')) {
      return 'Practice with interactive assessments';
    } else if (feature.toLowerCase().contains('tracking')) {
      return 'Monitor progress and performance analytics';
    } else if (feature.toLowerCase().contains('learning')) {
      return 'Customized educational pathways';
    } else if (feature.toLowerCase().contains('training')) {
      return 'Professional development resources';
    } else if (feature.toLowerCase().contains('sharing')) {
      return 'Share and discover educational resources';
    } else if (feature.toLowerCase().contains('community')) {
      return 'Connect with fellow educators';
    } else if (feature.toLowerCase().contains('management')) {
      return 'Efficient student and staff administration';
    } else if (feature.toLowerCase().contains('financial')) {
      return 'Track fees, expenses, and budgets';
    } else if (feature.toLowerCase().contains('communication')) {
      return 'Seamless school-wide communication';
    } else if (feature.toLowerCase().contains('notification')) {
      return 'Stay updated with important announcements';
    } else if (feature.toLowerCase().contains('payment')) {
      return 'Secure online fee payment system';
    } else if (feature.toLowerCase().contains('teacher')) {
      return 'Direct communication with educators';
    }
    return 'Enhanced platform feature';
  }
}
