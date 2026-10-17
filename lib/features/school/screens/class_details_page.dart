import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:isapp/features/auth/models/user.dart';
import 'package:isapp/features/connect/screens/connect_screen.dart';
import 'package:isapp/features/school/controllers/faculty_controller.dart';
import 'package:isapp/features/school/models/nigerian_class.dart';

class ClassDetailsPage extends StatefulWidget {
  final NigerianClass studentClass;

  const ClassDetailsPage({super.key, required this.studentClass});

  @override
  State<ClassDetailsPage> createState() => _ClassDetailsPageState();
}

class _ClassDetailsPageState extends State<ClassDetailsPage> {
  final FacultyController controller = Get.find();
  final RxBool isLoading = false.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.studentClass.displayName)),
      body: FutureBuilder<Map<String, dynamic>>(
        future: controller.getClassStats(widget.studentClass),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          }

          final stats = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Class Header
                _buildClassHeader(stats),
                const SizedBox(height: 32),
                // Statistics
                _buildStatistics(stats),
                const SizedBox(height: 32),
                // Students
                _buildStudentsSection(),
                const SizedBox(height: 32),
                // Teachers
                _buildTeachersSection(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildClassHeader(Map<String, dynamic> stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.studentClass.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: widget.studentClass.color),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: widget.studentClass.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              widget.studentClass.icon,
              color: widget.studentClass.color,
              size: 36,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.studentClass.displayName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.studentClass.level,
                  style: TextStyle(
                    fontSize: 16,
                    color: widget.studentClass.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.people_rounded,
                      size: 16,
                      color: widget.studentClass.color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${stats['totalStudents']} Students',
                      style: TextStyle(color: widget.studentClass.color),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.person_rounded,
                      size: 16,
                      color: widget.studentClass.color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Average Age: ${stats['averageAge'].toStringAsFixed(1)}',
                      style: TextStyle(color: widget.studentClass.color),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics(Map<String, dynamic> stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Class Statistics',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _StatCard(
              value: stats['totalStudents'].toString(),
              label: 'Total Students',
              color: Colors.blue,
              icon: Icons.people_rounded,
            ),
            _StatCard(
              value: stats['maleStudents'].toString(),
              label: 'Male Students',
              color: Colors.blue.shade700,
              icon: Icons.male_rounded,
            ),
            _StatCard(
              value: stats['femaleStudents'].toString(),
              label: 'Female Students',
              color: Colors.pink,
              icon: Icons.female_rounded,
            ),
            _StatCard(
              value: stats['assignedTeachers'].toString(),
              label: 'Teachers',
              color: Colors.green,
              icon: Icons.school_rounded,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStudentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Students',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            TextButton(
              onPressed: () {
                // View all students
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(() {
          final students = controller.schoolStudents
              .where((s) => s.studentClass == widget.studentClass)
              .take(5)
              .toList();

          return Column(
            children: students.map((student) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: widget.studentClass.color.withOpacity(0.1),
                  child: Text(
                    student.userName.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      color: widget.studentClass.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(student.userName),
                subtitle: Text(student.studentId ?? 'No ID'),
                trailing: student.isClassCaptain || student.isPrefect
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          student.isClassCaptain ? 'Captain' : 'Prefect',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.amber,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : null,
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildTeachersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Assigned Teachers',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        Obx(() {
          final teachers = controller.schoolTeachers.where((teacher) {
            return teacher.classResponsibilities.containsKey(
              widget.studentClass.displayName,
            );
          }).toList();

          if (teachers.isEmpty) {
            return const Center(
              child: Text('No teachers assigned to this class'),
            );
          }

          return Column(
            children: teachers.map((teacher) {
              final subject = teacher
                  .classResponsibilities[widget.studentClass.displayName];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  child: Text(
                    teacher.userName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(teacher.userName),
                subtitle: Text(
                  '$subject • ${teacher.staffPosition?.title ?? 'Teacher'}',
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
