import 'package:flutter/material.dart';
import 'package:isapp/features/quiz/screens/test_page.dart';
import 'package:svg_flutter/svg_flutter.dart';

import 'package:isapp/features/learning/models/course_models.dart';
import 'package:isapp/core/constants/app_constants.dart';

class DetailBody extends StatelessWidget {
  final List<Course> course;
  final CourseCategories courseCategory;
  DetailBody({super.key, required this.course, required this.courseCategory});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blue[900]!,
                      Colors.purple[900]!,
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          courseCategory.code,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        courseCategory.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildStarRating(4.5),
                          const SizedBox(width: 8),
                          Text(
                            '4.5 (1.2k reviews)',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Course Info Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        _buildInfoItem(
                          icon: Icons.calendar_today,
                          title: 'Total Years',
                          value: '${course.length}',
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 20),
                        _buildInfoItem(
                          icon: Icons.timer,
                          title: 'Duration',
                          value: '45 hours',
                          color: Colors.green,
                        ),
                        const SizedBox(width: 20),
                        _buildInfoItem(
                          icon: Icons.star,
                          title: 'Level',
                          value: 'All Levels',
                          color: Colors.orange,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Description
                  const Text(
                    'About This Package',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Comprehensive JAMB preparation package with past questions from different years. Each year contains subject-wise tests for thorough practice.',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Course Modules Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Available Years',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.blue,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${course.length} Years',
                              style: TextStyle(
                                color: Colors.blue[800],
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, courseIndex) {
                final currentCourse = course[courseIndex];
                final topic = currentCourse.topics.isNotEmpty ? currentCourse.topics[0] : null;
                
                if (topic == null) return const SizedBox();
                
                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ExpansionTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF6A11CB),
                            Color(0xFF2575FC),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.calendar_today,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      currentCourse.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _buildModuleChip(
                              icon: Icons.assignment,
                              text: '${topic.materials.tests.length} subjects',
                            ),
                            const SizedBox(width: 8),
                            _buildModuleChip(
                              icon: Icons.question_answer,
                              text: '${_getTotalQuestions(currentCourse)} questions',
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.lock_open,
                        color: Colors.green,
                        size: 16,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: topic.materials.tests
                              .asMap()
                              .entries
                              .map((entry) {
                            final testIndex = entry.key;
                            final test = entry.value;
                            
                            return ListTile(
                              leading: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: _getSubjectColor(test.title),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    _getSubjectInitial(test.title),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(
                                test.title,
                                style: const TextStyle(fontSize: 14),
                              ),
                              subtitle: Text(
                                '${test.questions.length} questions • ${test.duration ~/ 60} min',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              trailing: const Icon(
                                Icons.play_circle_filled,
                                color: Colors.blue,
                              ),
                              onTap: () {
                                // Navigate directly to test page
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TestPage(
                                      test: topic.materials.tests,
                                      index: testIndex,
                                      question: test.questions,
                                    ),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                );
              },
              childCount: course.length,
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleChip({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    int fullStars = rating.floor();
    bool hasHalfStar = rating - fullStars >= 0.5;
    return Row(
      children: List.generate(5, (index) {
        if (index < fullStars) {
          return const Icon(Icons.star, color: Colors.amber, size: 16);
        } else if (index == fullStars && hasHalfStar) {
          return const Icon(Icons.star_half, color: Colors.amber, size: 16);
        } else {
          return const Icon(Icons.star_border, color: Colors.amber, size: 16);
        }
      }),
    );
  }

  int _getTotalQuestions(Course course) {
    int total = 0;
    for (var topic in course.topics) {
      for (var test in topic.materials.tests) {
        total += test.questions.length;
      }
    }
    return total;
  }

  Color _getSubjectColor(String title) {
    if (title.contains('English') || title.contains('ENG')) {
      return Colors.red;
    } else if (title.contains('Math') || title.contains('MAT')) {
      return Colors.blue;
    } else if (title.contains('Bio') || title.contains('BIO')) {
      return Colors.green;
    } else if (title.contains('Phy') || title.contains('PHY')) {
      return Colors.purple;
    } else if (title.contains('Chem') || title.contains('CHE')) {
      return Colors.orange;
    } else {
      return Colors.grey;
    }
  }

  String _getSubjectInitial(String title) {
    if (title.contains('English') || title.contains('ENG')) {
      return 'E';
    } else if (title.contains('Math') || title.contains('MAT')) {
      return 'M';
    } else if (title.contains('Bio') || title.contains('BIO')) {
      return 'B';
    } else if (title.contains('Phy') || title.contains('PHY')) {
      return 'P';
    } else if (title.contains('Chem') || title.contains('CHE')) {
      return 'C';
    } else {
      return '?';
    }
  }
}