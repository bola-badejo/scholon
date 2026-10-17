import 'package:flutter/material.dart';
import 'package:isapp/features/learning/models/course_models.dart';
// import '../../../../../Utils/constants.dart';
import 'package:isapp/features/reader/screens/reader_page.dart';
import 'package:isapp/features/quiz/screens/test_page.dart';

class DetailBody extends StatelessWidget {
  final Materials material;
  final List<Topic> topic;
  final Course course;
  const DetailBody({
    super.key,
    required this.course,
    required this.material,
    required this.topic
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blue[900]!,
                  Colors.blue[800]!,
                  Colors.blue[700]!,
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  Text(
                    course.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Complete all materials to finish this chapter',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Notes Section
                if (material.notes.isNotEmpty) ...[
                  _buildSectionHeader(
                    'Study Notes',
                    '${material.notes.length} available',
                    Icons.article_rounded,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  ...material.notes.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final note = entry.value;
                    return _buildMaterialCard(
                      context,
                      note.title,
                      note.duration.toString(),
                      Icons.article_rounded,
                      Colors.blue,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReaderPage(
                              note: note,
                              index: idx,
                              course: course,
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                  
                  const SizedBox(height: 32),
                ],
                
                // Tests Section
                if (material.tests.isNotEmpty) ...[
                  _buildSectionHeader(
                    'Practice Tests',
                    '${material.tests.length} available',
                    Icons.quiz_rounded,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  ...material.tests.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final test = entry.value;
                    return _buildMaterialCard(
                      context,
                      test.title,
                      '${test.questions.length} questions',
                      Icons.quiz_rounded,
                      Colors.green,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TestPage(
                              test: [test],
                              index: idx,
                              question: test.questions,
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ],
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.grey[600], size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMaterialCard(
    BuildContext context,
    String title,
    String duration,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        duration,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: color,
                    size: 16,
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