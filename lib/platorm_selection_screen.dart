import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

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

  final List<Platform> _platforms = [
    Platform(
      id: 'kidling',
      name: 'Kidling',
      tagline: 'Preschool Learning Platform',
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
    Platform(
      id: 'istudyapp',
      name: 'iStudyApp',
      tagline: 'Student Learning Platform',
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
    Platform(
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
    Platform(
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
    Platform(
      id: 'parents_portal',
      name: 'Parents Portal',
      tagline: 'Parent Engagement Platform',
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

  void _selectPlatform(Platform platform) {
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
            // SCREEN 1: Platform Selection
            _buildSelectionScreen(size, isDark),
            
            // SCREEN 2: Platform Details (Scrollable)
            _buildDetailsScreen(size, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionScreen(Size size, bool isDark) {
    return SingleChildScrollView(
      child: Container(
        constraints: BoxConstraints(
          minHeight: size.height,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _currentPage == 0 ? 1 : 0.5,
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Choose Your ',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                              height: 1.2,
                            ),
                          ),
                          TextSpan(
                            text: 'Platform',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: _platforms[_currentPage].color,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _currentPage == 0 ? 1 : 0.7,
                    child: Text(
                      'Swipe horizontally to explore platforms',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.white70 : const Color(0xFF6C757D),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Platform Cards Carousel
            SizedBox(
              height: size.height * 0.6,
              child: PageView.builder(
                controller: _controller,
                itemCount: _platforms.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final platform = _platforms[index];
                  final offset = index - _pageOffset;
                  final scale = 1 - (offset.abs() * 0.1);
                  final opacity = 1 - (offset.abs() * 0.3);

                  return Transform(
                    transform: Matrix4.identity()
                      ..scale(scale.clamp(0.9, 1.0)),
                    alignment: Alignment.center,
                    child: Opacity(
                      opacity: opacity.clamp(0.7, 1.0),
                      child: GestureDetector(
                        onTap: () => _verticalController.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: offset.abs() * 20,
                            horizontal: 8,
                          ),
                          child: PlatformCard(
                            platform: platform,
                            isActive: index == _currentPage,
                            isDark: isDark,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Page Indicator and Platform Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  // Page Indicator
                  SmoothPageIndicator(
                    controller: _controller,
                    count: _platforms.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: _platforms[_currentPage].color,
                      dotColor: isDark ? Colors.white24 : Colors.grey[300]!,
                      dotHeight: 8,
                      dotWidth: 8,
                      spacing: 6,
                      expansionFactor: 3,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Platform Features
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      key: ValueKey(_currentPage),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          if (!isDark)
                            BoxShadow(
                              color: _platforms[_currentPage].color.withOpacity(0.1),
                              blurRadius: 20,
                              spreadRadius: 1,
                            ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Key Features',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _platforms[_currentPage].tagline,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDark ? Colors.white60 : Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _platforms[_currentPage].color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _platforms[_currentPage].name.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: _platforms[_currentPage].color,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Features Grid
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            alignment: WrapAlignment.start,
                            children: _platforms[_currentPage].features.map((feature) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: _platforms[_currentPage].color.withOpacity(isDark ? 0.15 : 0.08),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: _platforms[_currentPage].color.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: _platforms[_currentPage].color.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        _getFeatureIcon(feature),
                                        size: 16,
                                        color: _platforms[_currentPage].color,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Flexible(
                                      child: Text(
                                        feature,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: isDark ? Colors.white : Colors.black87,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Scroll Hint
                  Column(
                    children: [
                      Icon(
                        Icons.swipe_up,
                        color: _platforms[_currentPage].color,
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Swipe up for details',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white54 : Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsScreen(Size size, bool isDark) {
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0E21) : const Color(0xFFF8F9FD),
      body: SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(
            minHeight: size.height,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button
              GestureDetector(
                onTap: () {
                  _verticalController.previousPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _platforms[_currentPage].color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.arrow_back,
                    color: _platforms[_currentPage].color,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Platform Header
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _platforms[_currentPage].color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      _platforms[_currentPage].icon,
                      size: 32,
                      color: _platforms[_currentPage].color,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _platforms[_currentPage].name,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: _platforms[_currentPage].color,
                          ),
                        ),
                        Text(
                          _platforms[_currentPage].tagline,
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.white70 : Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Hero Image
              Hero(
                tag: _platforms[_currentPage].id,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      image: AssetImage(_platforms[_currentPage].image),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        _platforms[_currentPage].color.withOpacity(0.3),
                        BlendMode.multiply,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Description Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: _platforms[_currentPage].color.withOpacity(0.1),
                        blurRadius: 15,
                        spreadRadius: 1,
                      ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About ${_platforms[_currentPage].name}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _platforms[_currentPage].description,
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.white70 : Colors.black87,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Features Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: _platforms[_currentPage].color.withOpacity(0.1),
                        blurRadius: 15,
                        spreadRadius: 1,
                      ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Key Features',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._platforms[_currentPage].features.map((feature) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: _platforms[_currentPage].color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Icon(
                                _getFeatureIcon(feature),
                                color: _platforms[_currentPage].color,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    feature,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _getFeatureDescription(feature),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDark ? Colors.white60 : Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _selectPlatform(_platforms[_currentPage]),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _platforms[_currentPage].color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _platforms[_currentPage].icon,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Continue with ${_platforms[_currentPage].name}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Back Hint
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.swipe_down,
                      color: _platforms[_currentPage].color,
                      size: 24,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Swipe down to go back',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white54 : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
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

class PlatformCard extends StatelessWidget {
  final Platform platform;
  final bool isActive;
  final bool isDark;

  const PlatformCard({
    super.key,
    required this.platform,
    required this.isActive,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: platform.id,
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: platform.color.withOpacity(isActive ? 0.4 : 0.2),
                blurRadius: isActive ? 30 : 20,
                spreadRadius: isActive ? 3 : 1,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              children: [
                // Background Image
                Positioned.fill(
                  child: Image.asset(
                    platform.image,
                    fit: BoxFit.cover,
                    colorBlendMode: BlendMode.multiply,
                    color: isDark ? Colors.black54 : Colors.black12,
                  ),
                ),

                // Gradient Overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          platform.color.withOpacity(0.95),
                          platform.color.withOpacity(0.7),
                          platform.color.withOpacity(0.4),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.3, 0.6, 0.9],
                      ),
                    ),
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Platform Icon
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: isActive ? 70 : 60,
                        height: isActive ? 70 : 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          platform.icon,
                          color: Colors.white,
                          size: isActive ? 32 : 28,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Platform Name
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: TextStyle(
                          fontSize: isActive ? 32 : 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.2,
                        ),
                        child: Text(platform.name),
                      ),

                      const SizedBox(height: 8),

                      // Tagline
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: TextStyle(
                          fontSize: isActive ? 18 : 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        child: Text(platform.tagline),
                      ),

                      const SizedBox(height: 16),

                      // Description
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: isActive ? 1 : 0,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                          ),
                          child: Text(
                            platform.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                              height: 1.5,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Select Indicator
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: isActive ? 1 : 0,
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 2,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white,
                                      Colors.white.withOpacity(0),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withOpacity(0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'View details',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Active Border
                if (isActive)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.4),
                          width: 3,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Platform {
  final String id;
  final String name;
  final String tagline;
  final String description;
  final IconData icon;
  final Color color;
  final String image;
  final List<String> features;

  Platform({
    required this.id,
    required this.name,
    required this.tagline,
    required this.description,
    required this.icon,
    required this.color,
    required this.image,
    required this.features,
  });
}