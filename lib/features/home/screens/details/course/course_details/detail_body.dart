import 'package:flutter/material.dart';
import 'package:isapp/features/learning/models/course_models.dart';
// import '../../../../../Utils/constants.dart';
import 'package:isapp/features/home/screens/details/course/topic_details/detail_page.dart';

class DetailBody extends StatelessWidget {
  final List<Course> course;
  final CourseCategories courseCategory;
  DetailBody({super.key, required this.course, required this.courseCategory});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          courseCategory.title,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course Info Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF6C63FF),
                      Color(0xFF4A44C6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      courseCategory.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      courseCategory.code,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          course.length.toString(),
                          'Chapters',
                          Icons.layers_rounded,
                        ),
                        _buildStatItem(
                          _calculateTotalTopics().toString(),
                          'Topics',
                          Icons.menu_book_rounded,
                        ),
                        _buildStatItem(
                          _calculateTotalNotes().toString(),
                          'Notes',
                          Icons.article_rounded,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Chapters Header
              const Text(
                'Course Chapters',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'Progress through each chapter in sequence',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Chapters List
              ...course.asMap().entries.map((entry) {
                final index = entry.key;
                final courseItem = entry.value;
                final notesCount = courseItem.topics.isEmpty ? 0 : courseItem.topics[0].materials.notes.length;
                final testsCount = courseItem.topics.isEmpty ? 0 : courseItem.topics[0].materials.tests.length;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TopicDetailScreen(
                              course: courseItem,
                              index: index,
                              topic: courseItem.topics,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            // Chapter Number
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF6C63FF),
                                    Color(0xFF4A44C6),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            
                            const SizedBox(width: 16),
                            
                            // Chapter Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    courseItem.title,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 8),
                                  
                                  Row(
                                    children: [
                                      _buildChapterStat(Icons.article, '$notesCount Notes'),
                                      const SizedBox(width: 16),
                                      _buildChapterStat(Icons.quiz, '$testsCount Tests'),
                                    ],
                                  ),
                                  
                                  const SizedBox(height: 12),
                                  
                                  // Progress Bar
                                  Container(
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: FractionallySizedBox(
                                      widthFactor: 0.3,
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF6C63FF),
                                              Color(0xFF4A44C6),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(3),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(width: 16),
                            
                            // Arrow
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.grey,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildChapterStat(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  int _calculateTotalTopics() {
    return course.fold(0, (sum, c) => sum + c.topics.length);
  }

  int _calculateTotalNotes() {
    return course.fold(0, (sum, c) => sum + (c.topics.isEmpty ? 0 : c.topics[0].materials.notes.length));
  }
}