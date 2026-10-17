import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import 'package:isapp/features/auth/models/user.dart';
import 'package:isapp/features/connect/screens/connect_screen.dart';
import 'package:isapp/features/school/screens/faculty.dart';
import 'package:isapp/features/teachly/controllers/board_controller.dart';
import 'package:isapp/features/teachly/models/class_content.dart';
import 'package:isapp/features/teachly/models/class_type.dart';
import 'package:isapp/features/teachly/models/content_type.dart';
import 'package:isapp/features/teachly/models/teacher_class.dart';
import 'package:isapp/features/teachly/models/teacher_school.dart';
import 'package:isapp/features/teachly/screens/assessment_view_page.dart';
import 'package:isapp/features/teachly/screens/assignment_view_page.dart';
import 'package:isapp/features/teachly/screens/create_exam_page.dart';
import 'package:isapp/features/teachly/screens/create_test_page.dart';
import 'package:isapp/features/teachly/screens/material_view_page.dart';
import 'package:isapp/features/teachly/screens/note_view_page.dart';
import 'package:isapp/features/teachly/screens/video_view_page.dart';

export 'package:isapp/features/teachly/controllers/board_binding.dart';
export 'package:isapp/features/teachly/controllers/board_controller.dart';
export 'package:isapp/features/teachly/models/class_content.dart';
export 'package:isapp/features/teachly/models/class_type.dart';
export 'package:isapp/features/teachly/models/content_type.dart';
export 'package:isapp/features/teachly/models/question.dart';
export 'package:isapp/features/teachly/models/school_data.dart';
export 'package:isapp/features/teachly/models/teacher_class.dart';
export 'package:isapp/features/teachly/models/teacher_school.dart';
export 'package:isapp/features/teachly/screens/assessment_view_page.dart';
export 'package:isapp/features/teachly/screens/assignment_view_page.dart';
export 'package:isapp/features/teachly/screens/class_analytics_page.dart';
export 'package:isapp/features/teachly/screens/content_analytics_page.dart';
export 'package:isapp/features/teachly/screens/create_exam_page.dart';
export 'package:isapp/features/teachly/screens/create_test_page.dart';
export 'package:isapp/features/teachly/screens/material_view_page.dart';
export 'package:isapp/features/teachly/screens/note_view_page.dart';
export 'package:isapp/features/teachly/screens/video_view_page.dart';

part 'teacher_page_sections/01_app_bar.dart';
part 'teacher_page_sections/02_assignments_tab.dart';
part 'teacher_page_sections/03_assessment_section.dart';

class BoardPage extends StatefulWidget {
  const BoardPage({super.key});

  @override
  State<BoardPage> createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final BoardController controller = Get.put(BoardController());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    controller.clearFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // School selector if teacher has multiple schools
          Obx(() => _buildSchoolSelector()),

          // Tab bar
          _buildTabBar(),

          // Tab content
          Expanded(child: _buildTabContent()),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class _QuickStatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _QuickStatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

class _ClassCard extends StatelessWidget {
  final TeacherClass classItem;

  const _ClassCard({required this.classItem});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BoardController>();

    return GestureDetector(
      onTap: () {
        controller.selectedClass.value = classItem;
        controller.selectedTab.value = 1; // Switch to content tab
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: classItem.type.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  classItem.type.icon,
                  color: classItem.type.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      classItem.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      classItem.subject,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.people_rounded,
                          size: 12,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${classItem.currentStudents}/${classItem.maxStudents} students',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: classItem.type.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            classItem.type.displayName,
                            style: TextStyle(
                              fontSize: 10,
                              color: classItem.type.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'analytics',
                    child: Text('View Analytics'),
                  ),
                  const PopupMenuItem(
                    value: 'share',
                    child: Text('Share Class'),
                  ),
                  const PopupMenuItem(value: 'edit', child: Text('Edit Class')),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Archive Class'),
                  ),
                ],
                onSelected: (value) {
                  switch (value) {
                    case 'analytics':
                      controller.viewClassAnalytics(classItem);
                      break;
                    case 'share':
                      controller.shareClassCode(classItem);
                      break;
                    case 'edit':
                      // Show edit dialog
                      break;
                    case 'delete':
                      controller.deleteClass(classItem.id);
                      break;
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContentCard extends StatelessWidget {
  final ClassContent content;

  const _ContentCard({required this.content});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BoardController>();

    return GestureDetector(
      onTap: () => _viewContentDetails(content),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: content.type.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  content.type.icon,
                  color: content.type.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      content.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      content.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.visibility_rounded,
                          size: 12,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${content.viewCount} views',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        if (content.points != null) ...[
                          const SizedBox(width: 12),
                          Icon(
                            Icons.score_rounded,
                            size: 12,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${content.points} points',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                        if (content.dueDate != null) ...[
                          const SizedBox(width: 12),
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 12,
                            color: content.isPastDue
                                ? Colors.red
                                : Colors.green,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('MMM dd').format(content.dueDate!),
                            style: TextStyle(
                              fontSize: 12,
                              color: content.isPastDue
                                  ? Colors.red
                                  : Colors.green,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'analytics',
                    child: Text('View Analytics'),
                  ),
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(
                    value: 'publish',
                    child: Text(content.isPublished ? 'Unpublish' : 'Publish'),
                  ),
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
                onSelected: (value) {
                  switch (value) {
                    case 'analytics':
                      controller.viewContentAnalytics(content);
                      break;
                    case 'edit':
                      // Show edit dialog
                      break;
                    case 'publish':
                      // Toggle publish status
                      break;
                    case 'delete':
                      // Delete content
                      break;
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _viewContentDetails(ClassContent content) {
    switch (content.type) {
      case ContentType.note:
        Get.to(() => NoteViewPage(content: content));
        break;
      case ContentType.material:
        Get.to(() => MaterialViewPage(content: content));
        break;
      case ContentType.video:
        Get.to(() => VideoViewPage(content: content));
        break;
      case ContentType.assignment:
        Get.to(() => AssignmentViewPage(content: content));
        break;
      case ContentType.test:
      case ContentType.exam:
        Get.to(() => AssessmentViewPage(content: content));
        break;
    }
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: (Get.width - 64) / 3,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AssessmentTypeCard extends StatelessWidget {
  final ContentType type;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AssessmentTypeCard({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: type.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: type.color.withOpacity(0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: type.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(type.icon, color: type.color, size: 24),
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
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateClassForm extends StatefulWidget {
  const _CreateClassForm();

  @override
  State<_CreateClassForm> createState() => __CreateClassFormState();
}

class __CreateClassFormState extends State<_CreateClassForm> {
  final BoardController controller = Get.find<BoardController>();
  final _formKey = GlobalKey<FormState>();

  final Rx<ClassType> selectedClassType = Rx(ClassType.personal);
  final Rx<String?> selectedSchoolId = Rx(null);
  final Rx<NigerianClass?> selectedGradeLevel = Rx(null);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create New Class',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Class Type Selection
            _buildClassTypeSelection(),
            const SizedBox(height: 20),

            // School Selection (if school class)
            Obx(() {
              if (selectedClassType.value == ClassType.school) {
                return _buildSchoolSelection();
              }
              return const SizedBox();
            }),
            const SizedBox(height: 20),

            // Class Details
            TextFormField(
              controller: controller.classNameController,
              decoration: const InputDecoration(
                labelText: 'Class Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter class name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: controller.classDescriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller.classSubjectController,
                    decoration: const InputDecoration(
                      labelText: 'Subject',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter subject';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(child: Obx(() => _buildGradeLevelSelection())),
              ],
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: controller.classMaxStudentsController,
              decoration: const InputDecoration(
                labelText: 'Max Students',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter maximum students';
                }
                final number = int.tryParse(value);
                if (number == null || number <= 0) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 30),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Obx(
                    () => ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : _createClass,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: controller.isLoading.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Create Class'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Class Type', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Row(
          children: ClassType.values.map((type) {
            return Expanded(
              child: Obx(() {
                final selected = selectedClassType.value == type;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(type.displayName),
                    selected: selected,
                    onSelected: (_) => selectedClassType.value = type,
                    backgroundColor: type.color.withOpacity(0.1),
                    selectedColor: type.color,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : type.color,
                      fontWeight: FontWeight.w500,
                    ),
                    avatar: selected
                        ? Icon(type.icon, size: 16, color: Colors.white)
                        : Icon(type.icon, size: 16, color: type.color),
                  ),
                );
              }),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSchoolSelection() {
    final schools = controller.teacherSchools;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select School',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedSchoolId.value,
                isExpanded: true,
                hint: const Text('Choose a school'),
                items: schools.map((school) {
                  return DropdownMenuItem<String>(
                    value: school.schoolId,
                    child: Text(school.schoolName),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedSchoolId.value = value;
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGradeLevelSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Grade Level',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<NigerianClass>(
                value: selectedGradeLevel.value,
                isExpanded: true,
                hint: const Text('Optional'),
                items: NigerianClass.values.map((grade) {
                  return DropdownMenuItem<NigerianClass>(
                    value: grade,
                    child: Text(grade.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedGradeLevel.value = value;
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _createClass() async {
    if (_formKey.currentState!.validate()) {
      await controller.createClass(
        title: controller.classNameController.text,
        description: controller.classDescriptionController.text,
        subject: controller.classSubjectController.text,
        type: selectedClassType.value,
        gradeLevel: selectedGradeLevel.value,
        schoolId: selectedClassType.value == ClassType.school
            ? selectedSchoolId.value
            : null,
        maxStudents: int.parse(controller.classMaxStudentsController.text),
      );

      if (Get.isDialogOpen!) Get.back();
    }
  }
}

class _AssignmentCard extends StatelessWidget {
  final ClassContent assignment;

  const _AssignmentCard({required this.assignment});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BoardController>();
    final isPastDue = assignment.isPastDue;
    final hasSubmissions = assignment.submissionCount > 0;

    return GestureDetector(
      onTap: () => Get.to(() => AssignmentViewPage(content: assignment)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPastDue ? Colors.red.shade200 : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isPastDue
                      ? Colors.red.withOpacity(0.1)
                      : assignment.type.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isPastDue ? Icons.warning_rounded : assignment.type.icon,
                  color: isPastDue ? Colors.red : assignment.type.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assignment.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      assignment.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.people_rounded,
                          size: 12,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${assignment.submissionCount} submissions',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.score_rounded,
                          size: 12,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${assignment.points ?? 0} points',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        if (assignment.dueDate != null) ...[
                          const SizedBox(width: 12),
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 12,
                            color: isPastDue ? Colors.red : Colors.green,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('MMM dd').format(assignment.dueDate!),
                            style: TextStyle(
                              fontSize: 12,
                              color: isPastDue ? Colors.red : Colors.green,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  if (isPastDue)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Past Due',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    )
                  else if (!assignment.isPublished)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Draft',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  if (hasSubmissions)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${assignment.submissionCount} to grade',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AssessmentCard extends StatelessWidget {
  final ClassContent assessment;

  const _AssessmentCard({required this.assessment});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BoardController>();
    final isPastDue = assessment.isPastDue;
    final isExam = assessment.type == ContentType.exam;
    final duration = assessment.contentData['duration'] ?? 0;
    final questions =
        (assessment.contentData['questions'] as List?)?.length ?? 0;
    final passingScore = assessment.contentData['passingScore'] ?? 0;

    return GestureDetector(
      onTap: () => Get.to(() => AssessmentViewPage(content: assessment)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPastDue ? Colors.red.shade200 : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isPastDue
                      ? Colors.red.withOpacity(0.1)
                      : assessment.type.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isPastDue ? Icons.warning_rounded : assessment.type.icon,
                  color: isPastDue ? Colors.red : assessment.type.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          assessment.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: assessment.type.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isExam ? 'Exam' : 'Test',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: assessment.type.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      assessment.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.quiz_rounded,
                          size: 12,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$questions questions',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.timer_rounded,
                          size: 12,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$duration min',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.score_rounded,
                          size: 12,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${assessment.points ?? 0} points',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        if (assessment.dueDate != null) ...[
                          const SizedBox(width: 12),
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 12,
                            color: isPastDue ? Colors.red : Colors.green,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('MMM dd').format(assessment.dueDate!),
                            style: TextStyle(
                              fontSize: 12,
                              color: isPastDue ? Colors.red : Colors.green,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  if (isPastDue)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Past Due',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    )
                  else if (!assessment.isPublished)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Draft',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  if (assessment.submissionCount > 0)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${assessment.submissionCount} taken',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
