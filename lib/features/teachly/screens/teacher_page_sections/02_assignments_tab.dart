part of '../teacher_page.dart';

// _BoardPageState: _buildAssignmentsTab, _buildAssignmentList, _buildAssignmentSection, _buildAssessmentsTab, _buildAssessmentList
extension BoardPageStateSection02 on _BoardPageState {
  Widget _buildAssignmentsTab() {
    return Obx(() {
      final classes = controller.teacherClasses;
      final selectedClass = controller.selectedClass.value;
      final currentTime = DateTime.now();

      return Column(
        children: [
          // Class Selector
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<TeacherClass>(
                  value: selectedClass,
                  isExpanded: true,
                  hint: const Text('Select a class'),
                  items: classes.map((classItem) {
                    return DropdownMenuItem<TeacherClass>(
                      value: classItem,
                      child: Text(classItem.title),
                    );
                  }).toList(),
                  onChanged: (classItem) {
                    controller.selectedClass.value = classItem;
                  },
                ),
              ),
            ),
          ),

          // Assignment Status Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected: controller.selectedContentType.value == null,
                    onSelected: (_) {
                      controller.selectedContentType.value = null;
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Active'),
                    selected:
                        controller.selectedContentType.value ==
                        ContentType.assignment,
                    onSelected: (_) {
                      controller.selectedContentType.value =
                          ContentType.assignment;
                    },
                    backgroundColor: Colors.green.withOpacity(0.1),
                    selectedColor: Colors.green,
                    labelStyle: const TextStyle(color: Colors.green),
                    avatar: const Icon(Icons.access_time_rounded, size: 16),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Past Due'),
                    selected: false,
                    onSelected: (_) {},
                    backgroundColor: Colors.red.withOpacity(0.1),
                    labelStyle: const TextStyle(color: Colors.red),
                    avatar: const Icon(Icons.warning_rounded, size: 16),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Graded'),
                    selected: false,
                    onSelected: (_) {},
                    backgroundColor: Colors.green.withOpacity(0.1),
                    labelStyle: const TextStyle(color: Colors.green),
                    avatar: const Icon(Icons.grade_rounded, size: 16),
                  ),
                ],
              ),
            ),
          ),

          // Assignment List
          if (selectedClass != null) ...[
            const SizedBox(height: 20),
            Expanded(child: _buildAssignmentList(selectedClass.id)),
          ] else ...[
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.assignment_outlined,
                      size: 80,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Select a class',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Choose a class to view assignments',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      );
    });
  }

  Widget _buildAssignmentList(String classId) {
    final contents = controller.contentByClass[classId] ?? [];
    final assignments = contents
        .where((content) => content.type == ContentType.assignment)
        .toList();

    if (assignments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.assignment_outlined, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No assignments yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create assignments for your students',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _showCreateAssignmentDialog(),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create Assignment'),
            ),
          ],
        ),
      );
    }

    // Separate assignments into active, upcoming, and past due
    final currentTime = DateTime.now();
    final activeAssignments = assignments
        .where(
          (a) =>
              a.isPublished &&
              (a.dueDate == null || a.dueDate!.isAfter(currentTime)),
        )
        .toList();

    final pastDueAssignments = assignments
        .where(
          (a) =>
              a.isPublished &&
              a.dueDate != null &&
              a.dueDate!.isBefore(currentTime),
        )
        .toList();

    final draftAssignments = assignments.where((a) => !a.isPublished).toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (activeAssignments.isNotEmpty) ...[
          _buildAssignmentSection(
            title: 'Active Assignments',
            assignments: activeAssignments,
            color: Colors.green,
          ),
          const SizedBox(height: 24),
        ],

        if (pastDueAssignments.isNotEmpty) ...[
          _buildAssignmentSection(
            title: 'Past Due',
            assignments: pastDueAssignments,
            color: Colors.red,
          ),
          const SizedBox(height: 24),
        ],

        if (draftAssignments.isNotEmpty) ...[
          _buildAssignmentSection(
            title: 'Drafts',
            assignments: draftAssignments,
            color: Colors.grey,
          ),
        ],
      ],
    );
  }

  Widget _buildAssignmentSection({
    required String title,
    required List<ClassContent> assignments,
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
                '${assignments.length}',
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
        ...assignments.map((assignment) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _AssignmentCard(assignment: assignment),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildAssessmentsTab() {
    return Obx(() {
      final classes = controller.teacherClasses;
      final selectedClass = controller.selectedClass.value;

      return Column(
        children: [
          // Class Selector
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<TeacherClass>(
                  value: selectedClass,
                  isExpanded: true,
                  hint: const Text('Select a class'),
                  items: classes.map((classItem) {
                    return DropdownMenuItem<TeacherClass>(
                      value: classItem,
                      child: Text(classItem.title),
                    );
                  }).toList(),
                  onChanged: (classItem) {
                    controller.selectedClass.value = classItem;
                  },
                ),
              ),
            ),
          ),

          // Assessment Type Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected: controller.selectedContentType.value == null,
                    onSelected: (_) {
                      controller.selectedContentType.value = null;
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Tests'),
                    selected:
                        controller.selectedContentType.value ==
                        ContentType.test,
                    onSelected: (_) {
                      controller.selectedContentType.value = ContentType.test;
                    },
                    backgroundColor: Colors.purple.withOpacity(0.1),
                    selectedColor: Colors.purple,
                    labelStyle: const TextStyle(color: Colors.purple),
                    avatar: const Icon(Icons.quiz_rounded, size: 16),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Exams'),
                    selected:
                        controller.selectedContentType.value ==
                        ContentType.exam,
                    onSelected: (_) {
                      controller.selectedContentType.value = ContentType.exam;
                    },
                    backgroundColor: Colors.deepPurple.withOpacity(0.1),
                    selectedColor: Colors.deepPurple,
                    labelStyle: const TextStyle(color: Colors.deepPurple),
                    avatar: const Icon(
                      Icons.assignment_turned_in_rounded,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Active'),
                    selected: false,
                    onSelected: (_) {},
                    backgroundColor: Colors.green.withOpacity(0.1),
                    labelStyle: const TextStyle(color: Colors.green),
                    avatar: const Icon(Icons.access_time_rounded, size: 16),
                  ),
                ],
              ),
            ),
          ),

          // Assessment List
          if (selectedClass != null) ...[
            const SizedBox(height: 20),
            Expanded(child: _buildAssessmentList(selectedClass.id)),
          ] else ...[
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.quiz_outlined,
                      size: 80,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Select a class',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Choose a class to view assessments',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      );
    });
  }

  Widget _buildAssessmentList(String classId) {
    final contents = controller.contentByClass[classId] ?? [];
    final assessments = contents
        .where(
          (content) =>
              content.type == ContentType.test ||
              content.type == ContentType.exam,
        )
        .toList();

    if (assessments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.quiz_outlined, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No assessments yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create tests and exams for your students',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _showCreateAssessmentDialog(),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create Assessment'),
            ),
          ],
        ),
      );
    }

    final currentTime = DateTime.now();

    // Filter based on selected content type
    List<ClassContent> filteredAssessments = assessments;
    if (controller.selectedContentType.value == ContentType.test) {
      filteredAssessments = assessments
          .where((a) => a.type == ContentType.test)
          .toList();
    } else if (controller.selectedContentType.value == ContentType.exam) {
      filteredAssessments = assessments
          .where((a) => a.type == ContentType.exam)
          .toList();
    }

    // Separate into upcoming, active, and completed
    final upcomingAssessments = filteredAssessments
        .where((a) => a.dueDate != null && a.dueDate!.isAfter(currentTime))
        .toList();

    final activeAssessments = filteredAssessments
        .where(
          (a) =>
              a.isPublished &&
              (a.dueDate == null || !a.dueDate!.isBefore(currentTime)),
        )
        .toList();

    final completedAssessments = filteredAssessments
        .where((a) => a.dueDate != null && a.dueDate!.isBefore(currentTime))
        .toList();

    final draftAssessments = filteredAssessments
        .where((a) => !a.isPublished)
        .toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (activeAssessments.isNotEmpty) ...[
          _buildAssessmentSection(
            title: 'Active Assessments',
            assessments: activeAssessments,
            color: Colors.green,
          ),
          const SizedBox(height: 24),
        ],

        if (upcomingAssessments.isNotEmpty) ...[
          _buildAssessmentSection(
            title: 'Upcoming',
            assessments: upcomingAssessments,
            color: Colors.orange,
          ),
          const SizedBox(height: 24),
        ],

        if (completedAssessments.isNotEmpty) ...[
          _buildAssessmentSection(
            title: 'Completed',
            assessments: completedAssessments,
            color: Colors.green,
          ),
          const SizedBox(height: 24),
        ],

        if (draftAssessments.isNotEmpty) ...[
          _buildAssessmentSection(
            title: 'Drafts',
            assessments: draftAssessments,
            color: Colors.grey,
          ),
        ],
      ],
    );
  }
}
