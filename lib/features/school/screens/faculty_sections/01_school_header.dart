part of '../faculty.dart';

// _FacultyPageState: _buildSchoolHeader, _buildHeaderStat, _buildStatisticsRow, _buildStatSkeleton, _buildStaffTab, _buildStudentsTab, _buildParentsTab, _buildClassesTab, _buildSearchSection, _buildStaffFilters, _buildStudentFilters, _buildClassFilters, _buildFilterSection, _buildStaffList
extension FacultyPageStateSection01 on _FacultyPageState {
  Widget _buildSchoolHeader() {
    return Obx(() {
      final schoolName = schoolController.currentSchoolName.value;
      final schoolCode = schoolController.currentSchoolCode.value;
      final stats = schoolController.schoolStats;

      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.deepPurple.shade600, Colors.purple.shade600],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 60),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          schoolName ?? 'No School Selected',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        if (schoolCode != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Code: $schoolCode',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                        const SizedBox(height: 15),

                        // Statistics Row
                        _buildStatisticsRow(),
                      ],
                    ),
                  ),
                ],
              ),
              // const SizedBox(height: 20),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildHeaderStat({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: color.withOpacity(0.9)),
        ),
      ],
    );
  }

  Widget _buildStatisticsRow() {
    final stats = schoolController.schoolStats;

    // Check if stats are still loading or empty
    if (stats.isEmpty || stats['totalTeachers'] == null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(3, (index) => _buildStatSkeleton()),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _StatItem(
          value: stats['totalTeachers']?.toString() ?? '0',
          label: 'Teachers',
          icon: Icons.school_rounded,
          color: Colors.white,
        ),
        SizedBox(width: 6),
        _StatItem(
          value: stats['totalStudents']?.toString() ?? '0',
          label: 'Students',
          icon: Icons.person_rounded,
          color: Colors.white,
        ),
        SizedBox(width: 6),
        _StatItem(
          value: stats['totalParents']?.toString() ?? '0',
          label: 'Parents',
          icon: Icons.family_restroom_rounded,
          color: Colors.white,
        ),
      ],
    );
  }

  Widget _buildStatSkeleton() {
    return Container(
      width: 80,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildStaffTab() {
    return RefreshIndicator(
      onRefresh: () => schoolController.refreshData(),
      child: CustomScrollView(
        slivers: [
          _buildSearchSection('Search staff...'),
          _buildStaffFilters(),
          Obx(() => _buildStaffList()),
        ],
      ),
    );
  }

  Widget _buildStudentsTab() {
    return RefreshIndicator(
      onRefresh: () => schoolController.refreshData(),
      child: CustomScrollView(
        slivers: [
          _buildSearchSection('Search students...'),
          _buildStudentFilters(),
          Obx(() => _buildStudentList()),
        ],
      ),
    );
  }

  Widget _buildParentsTab() {
    return RefreshIndicator(
      onRefresh: () => schoolController.refreshData(),
      child: CustomScrollView(
        slivers: [
          _buildSearchSection('Search parents...'),
          Obx(() => _buildParentList()),
        ],
      ),
    );
  }

  Widget _buildClassesTab() {
    return RefreshIndicator(
      onRefresh: () => schoolController.refreshData(),
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Class Management',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Manage classes, assign teachers, and monitor student distribution',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ),
          _buildClassFilters(),
          Obx(() => _buildClassList()),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildSearchSection(String hintText) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: Colors.grey, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      schoolController.searchQuery.value = value;
                    },
                    decoration: InputDecoration(
                      hintText: hintText,
                      border: InputBorder.none,
                      hintStyle: const TextStyle(fontSize: 15),
                    ),
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildStaffFilters() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            // Department Filters
            _buildFilterSection(
              title: 'Departments',
              filters: SchoolDepartment.values.map((dept) {
                return Obx(() {
                  final selected =
                      schoolController.selectedDepartment.value == dept;
                  return FilterChip(
                    label: Text(dept.name),
                    selected: selected,
                    onSelected: (_) {
                      schoolController.selectedDepartment.value = selected
                          ? null
                          : dept;
                    },
                    backgroundColor: dept.color.withOpacity(0.1),
                    selectedColor: dept.color,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : dept.color,
                      fontWeight: FontWeight.w500,
                    ),
                    avatar: selected
                        ? Icon(dept.icon, size: 16, color: Colors.white)
                        : Icon(dept.icon, size: 16, color: dept.color),
                  );
                });
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildStudentFilters() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Obx(() {
          // Use activeClasses if available, otherwise show all classes
          final classes = schoolController.activeClasses.isNotEmpty
              ? schoolController.activeClasses
              : NigerianClass.values.toList();

          if (classes.isEmpty) {
            return const SizedBox.shrink();
          }

          return Column(
            children: [
              _buildFilterSection(
                title: 'Classes',
                filters: classes.map((grade) {
                  final selected =
                      schoolController.selectedClass.value == grade;
                  return FilterChip(
                    label: Text(grade.displayName),
                    selected: selected,
                    onSelected: (_) {
                      schoolController.selectedClass.value = selected
                          ? null
                          : grade;
                    },
                    backgroundColor: grade.color.withOpacity(0.1),
                    selectedColor: grade.color,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : grade.color,
                      fontWeight: FontWeight.w500,
                    ),
                    avatar: selected
                        ? Icon(grade.icon, size: 16, color: Colors.white)
                        : Icon(grade.icon, size: 16, color: grade.color),
                  );
                }).toList(),
              ),
            ],
          );
        }),
      ),
    );
  }

  SliverToBoxAdapter _buildClassFilters() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilterChip(
              label: const Text('Primary'),
              selected: false,
              onSelected: (_) {
                // Filter primary classes
              },
              backgroundColor: Colors.blue.withOpacity(0.1),
              selectedColor: Colors.blue,
            ),
            FilterChip(
              label: const Text('Junior Secondary'),
              selected: false,
              onSelected: (_) {
                // Filter JSS classes
              },
              backgroundColor: Colors.green.withOpacity(0.1),
              selectedColor: Colors.green,
            ),
            FilterChip(
              label: const Text('Senior Secondary'),
              selected: false,
              onSelected: (_) {
                // Filter SSS classes
              },
              backgroundColor: Colors.purple.withOpacity(0.1),
              selectedColor: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required List<Widget> filters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: filters),
      ],
    );
  }

  SliverList _buildStaffList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final staffList = schoolController.schoolTeachers;
        if (index >= staffList.length) return null;
        final staff = staffList[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: _StaffProfileCard(
            profile: staff,
            onTap: () => _showStaffDetails(staff),
          ),
        );
      }, childCount: schoolController.schoolTeachers.length),
    );
  }
}
