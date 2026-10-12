import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CoursesPage extends StatelessWidget {
  const CoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildCourseCategory(
            title: 'Teaching Methods',
            icon: Icons.school_rounded,
            color: Colors.blue,
            courseCount: 5,
          ),
          _buildCourseCategory(
            title: 'Classroom Management',
            icon: Icons.groups_rounded,
            color: Colors.green,
            courseCount: 3,
          ),
          _buildCourseCategory(
            title: 'Assessment Techniques',
            icon: Icons.assignment_rounded,
            color: Colors.purple,
            courseCount: 4,
          ),
          _buildCourseCategory(
            title: 'Digital Tools',
            icon: Icons.computer_rounded,
            color: Colors.orange,
            courseCount: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCategory({
    required String title,
    required IconData icon,
    required Color color,
    required int courseCount,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '$courseCount courses available',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: color),
        ],
      ),
    );
  }
}