part of '../teacher_page.dart';

// _BoardPageState: _buildAppBar, _buildSchoolSelector, _buildTabBar, _buildTabContent, _buildClassesTab, _buildClassesHeader, _buildQuickStats, _buildClassFilters, _buildContentTab, _buildContentList
extension BoardPageStateSection01 on _BoardPageState {
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Obx(() {
        final school = controller.selectedSchool.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Board',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
              ),
            ),
            if (school != null)
              Text(
                school.schoolName,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
          ],
        );
      }),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 1,
      shadowColor: Colors.grey.withOpacity(0.1),
      actions: [
        IconButton(
          onPressed: () => _showQuickActions(),
          icon: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add_rounded, color: Colors.green, size: 20),
          ),
        ),
        IconButton(
          onPressed: () => controller.refreshData(),
          icon: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.refresh_rounded,
              color: Colors.grey,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSchoolSelector() {
    final schools = controller.teacherSchools;
    if (schools.length <= 1) return const SizedBox();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          const Icon(Icons.school_rounded, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<TeacherSchool>(
                value: controller.selectedSchool.value,
                isExpanded: true,
                items: schools.map((school) {
                  return DropdownMenuItem<TeacherSchool>(
                    value: school,
                    child: Text(
                      school.schoolName,
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                }).toList(),
                onChanged: (school) {
                  controller.selectedSchool.value = school;
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.green,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Colors.green,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorWeight: 3,
        tabs: const [
          Tab(text: 'Classes', icon: Icon(Icons.class_rounded, size: 20)),
          Tab(
            text: 'Content',
            icon: Icon(Icons.library_books_rounded, size: 20),
          ),
          Tab(
            text: 'Assignments',
            icon: Icon(Icons.assignment_rounded, size: 20),
          ),
          Tab(text: 'Assessments', icon: Icon(Icons.quiz_rounded, size: 20)),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildClassesTab(),
        _buildContentTab(),
        _buildAssignmentsTab(),
        _buildAssessmentsTab(),
      ],
    );
  }

  Widget _buildClassesTab() {
    return RefreshIndicator(
      onRefresh: () async => await controller.refreshData,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverToBoxAdapter(child: _buildClassesHeader()),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(child: _buildClassFilters()),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final classes = controller.filteredClasses;
                if (index >= classes.length) return null;
                final classItem = classes[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ClassCard(classItem: classItem),
                );
              }, childCount: controller.filteredClasses.length),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassesHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'My Classes',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
              ),
            ),
            Obx(() {
              final analytics = controller.classAnalytics;
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${analytics['totalClasses'] ?? 0} classes',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              );
            }),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Manage your school and personal classes',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 20),
        _buildQuickStats(),
      ],
    );
  }

  Widget _buildQuickStats() {
    final analytics = controller.classAnalytics;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _QuickStatCard(
          value: analytics['schoolClasses']?.toString() ?? '0',
          label: 'School',
          icon: Icons.school_rounded,
          color: Colors.blue,
        ),
        _QuickStatCard(
          value: analytics['personalClasses']?.toString() ?? '0',
          label: 'Personal',
          icon: Icons.person_rounded,
          color: Colors.green,
        ),
        _QuickStatCard(
          value: analytics['studyGroups']?.toString() ?? '0',
          label: 'Groups',
          icon: Icons.group_rounded,
          color: Colors.orange,
        ),
        _QuickStatCard(
          value: analytics['totalStudents']?.toString() ?? '0',
          label: 'Students',
          icon: Icons.people_rounded,
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildClassFilters() {
    return Column(
      children: [
        // Search Bar
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: Colors.grey, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      controller.searchQuery.value = value;
                    },
                    decoration: const InputDecoration(
                      hintText: 'Search classes...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(fontSize: 14),
                    ),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Class Type Filters
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ClassType.values.map((type) {
            return Obx(() {
              final selected = controller.selectedClassType.value == type;
              return FilterChip(
                label: Text(type.displayName),
                selected: selected,
                onSelected: (_) {
                  controller.selectedClassType.value = selected ? null : type;
                },
                backgroundColor: type.color.withOpacity(0.1),
                selectedColor: type.color,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : type.color,
                  fontWeight: FontWeight.w500,
                ),
                avatar: Icon(
                  type.icon,
                  size: 16,
                  color: selected ? Colors.white : type.color,
                ),
              );
            });
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildContentTab() {
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

          // Content Type Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ContentType.values.map((type) {
                  return Obx(() {
                    final selected =
                        controller.selectedContentType.value == type;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(type.displayName),
                        selected: selected,
                        onSelected: (_) {
                          controller.selectedContentType.value = selected
                              ? null
                              : type;
                        },
                        backgroundColor: type.color.withOpacity(0.1),
                        selectedColor: type.color,
                        labelStyle: TextStyle(
                          color: selected ? Colors.white : type.color,
                        ),
                        avatar: Icon(
                          type.icon,
                          size: 16,
                          color: selected ? Colors.white : type.color,
                        ),
                      ),
                    );
                  });
                }).toList(),
              ),
            ),
          ),

          // Content List
          if (selectedClass != null) ...[
            const SizedBox(height: 20),
            Expanded(child: _buildContentList(selectedClass.id)),
          ] else ...[
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.library_books_outlined,
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
                      'Choose a class to view its content',
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

  Widget _buildContentList(String classId) {
    final contents = controller.contentByClass[classId] ?? [];
    final filteredContents = contents.where((content) {
      final typeFilter =
          controller.selectedContentType.value == null ||
          content.type == controller.selectedContentType.value;
      return typeFilter;
    }).toList();

    if (filteredContents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.library_books_outlined,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No content yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add notes, materials, or assignments',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _showCreateContentDialog(),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create Content'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: filteredContents.length,
      itemBuilder: (context, index) {
        final content = filteredContents[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _ContentCard(content: content),
        );
      },
    );
  }
}
