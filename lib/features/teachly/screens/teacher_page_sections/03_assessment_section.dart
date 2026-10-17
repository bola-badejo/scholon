part of '../teacher_page.dart';

// _BoardPageState: _buildAssessmentSection, _buildFloatingActionButton, _showQuickActions, _showCreateClassDialog, _showCreateContentDialog, _showCreateNoteDialog, _showCreateAssignmentDialog, _showCreateTestDialog, _showUploadVideoDialog, _showUploadMaterialDialog, _showCreateAssessmentDialog, _showCreateTestForm, _showCreateExamForm
extension BoardPageStateSection03 on _BoardPageState {
  Widget _buildAssessmentSection({
    required String title,
    required List<ClassContent> assessments,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 20,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${assessments.length}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...assessments.map((assessment) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _AssessmentCard(assessment: assessment),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return Obx(() {
      final selectedTab = controller.selectedTab.value;

      IconData icon;
      VoidCallback onPressed;

      switch (selectedTab) {
        case 0: // Classes
          icon = Icons.add_rounded;
          onPressed = () => _showCreateClassDialog();
          break;
        case 1: // Content
          icon = Icons.add_rounded;
          onPressed = () => _showCreateContentDialog();
          break;
        case 2: // Assignments
          icon = Icons.home_mini_sharp;
          onPressed = () => _showCreateAssignmentDialog();
          break;
        case 3: // Assessments
          icon = Icons.quiz_outlined;
          onPressed = () => _showCreateAssessmentDialog();
          break;
        default:
          icon = Icons.add_rounded;
          onPressed = () {};
      }

      return FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 4,
        child: Icon(icon),
      );
    });
  }

  void _showQuickActions() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Quick Actions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _QuickActionCard(
                    icon: Icons.class_rounded,
                    label: 'New Class',
                    color: Colors.green,
                    onTap: () {
                      Get.back();
                      _showCreateClassDialog();
                    },
                  ),
                  _QuickActionCard(
                    icon: Icons.note_add_rounded,
                    label: 'New Note',
                    color: Colors.green,
                    onTap: () {
                      Get.back();
                      _showCreateNoteDialog();
                    },
                  ),
                  _QuickActionCard(
                    icon: Icons.home_mini_sharp,
                    label: 'Assignment',
                    color: Colors.orange,
                    onTap: () {
                      Get.back();
                      _showCreateAssignmentDialog();
                    },
                  ),
                  _QuickActionCard(
                    icon: Icons.quiz_outlined,
                    label: 'Test',
                    color: Colors.purple,
                    onTap: () {
                      Get.back();
                      _showCreateTestDialog();
                    },
                  ),
                  _QuickActionCard(
                    icon: Icons.video_library_rounded,
                    label: 'Video',
                    color: Colors.red,
                    onTap: () {
                      Get.back();
                      _showUploadVideoDialog();
                    },
                  ),
                  _QuickActionCard(
                    icon: Icons.file_upload_rounded,
                    label: 'Material',
                    color: Colors.teal,
                    onTap: () {
                      Get.back();
                      _showUploadMaterialDialog();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _showCreateClassDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _CreateClassForm(),
        ),
      ),
    );
  }

  void _showCreateContentDialog() {
    // Similar implementation for content creation
  }

  void _showCreateNoteDialog() {
    // Implementation for note creation
  }

  void _showCreateAssignmentDialog() {
    // Implementation for assignment creation
  }

  void _showCreateTestDialog() {
    // Implementation for test creation
  }

  void _showUploadVideoDialog() {
    // Implementation for video upload
  }

  void _showUploadMaterialDialog() {
    // Implementation for material upload
  }

  void _showCreateAssessmentDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Create Assessment',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _AssessmentTypeCard(
                type: ContentType.test,
                title: 'Test',
                subtitle:
                    'Create a test with multiple choice, true/false, and short answer questions',
                onTap: () {
                  Get.back();
                  _showCreateTestForm();
                },
              ),
              const SizedBox(height: 12),
              _AssessmentTypeCard(
                type: ContentType.exam,
                title: 'Exam',
                subtitle:
                    'Create a comprehensive exam with multiple sections and advanced settings',
                onTap: () {
                  Get.back();
                  _showCreateExamForm();
                },
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateTestForm() {
    Get.to(() => CreateTestPage());
  }

  void _showCreateExamForm() {
    Get.to(() => CreateExamPage());
  }
}
