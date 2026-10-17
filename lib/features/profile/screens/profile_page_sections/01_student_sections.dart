part of '../profile_page.dart';

// UniversalProfileScreen: _buildStudentSections, _buildStudentClassesSection, _buildStudentSchoolSection, _buildTeacherSections, _buildTeacherSchoolSection, _buildTeacherResourcesSection, _buildSchoolAdminSections, _buildSchoolAdminSchoolSection, _buildSchoolStatsSection, _buildParentSections, _buildKidlingParentSections, _buildKidlingChildSection, _buildKidlingProgressSection
extension _UniversalProfileScreenSection01 on UniversalProfileScreen {
  List<Widget> _buildStudentSections(StudentUser user) {
    return [
      _sectionTitle('My Classes'),
      _softCard(_buildStudentClassesSection(user)),
      const SizedBox(height: 28),

      _sectionTitle('My School'),
      _softCard(_buildStudentSchoolSection(user)),
      const SizedBox(height: 28),
    ];
  }

  Widget _buildStudentClassesSection(StudentUser user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (user.enrolledCourses.isNotEmpty)
          ...user.enrolledCourses.take(3).map((course) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: _courseTile(course, user.courseProgress[course] ?? 0),
              ))
        else
          _emptyStateCard(
            icon: Icons.class_rounded,
            title: 'No Classes',
            subtitle: 'You haven\'t enrolled in any classes yet',
            actionText: 'Explore Classes',
            onAction: () {
              // Navigate to classes page
            },
          ),
        if (user.enrolledCourses.length > 3)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: _viewAllButton('View all ${user.enrolledCourses.length} classes', () {}),
          ),
      ],
    );
  }

  Widget _buildStudentSchoolSection(StudentUser user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (user.schoolName != null && user.schoolName!.isNotEmpty)
          _schoolInfoTile(user.schoolName!, 'School', Icons.school_rounded)
        else
          _emptyStateCard(
            icon: Icons.school_rounded,
            title: 'No School',
            subtitle: 'You\'re not enrolled in a school',
            actionText: 'Join School',
            onAction: () {
              // Navigate to school join page
            },
          ),
        const SizedBox(height: 12),
        if (user.classGrade != null)
          _infoRow('Class Grade', 'Grade ${user.classGrade}'),
        if (user.educationCategory != null)
          _infoRow('Education Category', user.educationCategory!),
      ],
    );
  }

  List<Widget> _buildTeacherSections(TeacherUser user) {
    return [
      _sectionTitle('My School'),
      _softCard(_buildTeacherSchoolSection(user)),
      const SizedBox(height: 28),

      if (user.createdResources.isNotEmpty)
        _sectionTitle('My Resources'),
      if (user.createdResources.isNotEmpty)
        _softCard(_buildTeacherResourcesSection(user)),
      if (user.createdResources.isNotEmpty) const SizedBox(height: 28),
    ];
  }

  Widget _buildTeacherSchoolSection(TeacherUser user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (user.schoolName != null && user.schoolName!.isNotEmpty)
          _schoolInfoTile(user.schoolName!, 'School', Icons.business_rounded)
        else
          _emptyStateCard(
            icon: Icons.school_rounded,
            title: 'No School',
            subtitle: 'You\'re not associated with any school',
            actionText: 'Join School',
            onAction: () {
              // Navigate to school join page
            },
          ),
        const SizedBox(height: 12),
        if (user.subjectSpecialization != null)
          _infoRow('Subject Specialization', user.subjectSpecialization!),
        if (user.qualification != null)
          _infoRow('Qualification', user.qualification!),
        if (user.yearsOfExperience != null)
          _infoRow('Experience', user.yearsOfExperience!),
        const SizedBox(height: 16),
        _elevatedButton(
          text: 'School Affairs',
          icon: Icons.newspaper_rounded,
          onPressed: () {
            if (user.schoolName != null && user.schoolName!.isNotEmpty) {
              _navigateToAffairs({
                'schoolName': user.schoolName!,
                'schoolId': user.teacherId ?? '',
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildTeacherResourcesSection(TeacherUser user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...user.createdResources.take(3).map((resource) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _resourceTile(resource),
            )),
        if (user.createdResources.length > 3)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _viewAllButton('View all ${user.createdResources.length} resources', () {}),
          ),
      ],
    );
  }

  List<Widget> _buildSchoolAdminSections(SchoolAdminUser user) {
    return [
      _sectionTitle('My School'),
      _softCard(_buildSchoolAdminSchoolSection(user)),
      const SizedBox(height: 28),

      _sectionTitle('School Stats'),
      _softCard(_buildSchoolStatsSection(user)),
      const SizedBox(height: 28),
    ];
  }

  Widget _buildSchoolAdminSchoolSection(SchoolAdminUser user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (user.schoolName != null && user.schoolName!.isNotEmpty)
          _schoolInfoTile(user.schoolName!, 'School', Icons.business_rounded)
        else
          _emptyStateCard(
            icon: Icons.business_rounded,
            title: 'No School',
            subtitle: 'You\'re not managing any school',
            actionText: 'Create School',
            onAction: () {
              // Navigate to school creation
            },
          ),
        const SizedBox(height: 12),
        if (user.schoolCode != null) _infoRow('School Code', user.schoolCode!),
        if (user.adminPosition != null) _infoRow('Position', user.adminPosition!),
        if (user.schoolAddress != null) _infoRow('Address', user.schoolAddress!),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _elevatedButton(
                text: 'School Affairs',
                icon: Icons.newspaper_rounded,
                onPressed: () {
                  if (user.schoolName != null && user.schoolName!.isNotEmpty) {
                    _navigateToAffairs({
                      'schoolName': user.schoolName!,
                      'schoolCode': user.schoolCode ?? '',
                    });
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _outlinedButton(
                text: 'Manage',
                icon: Icons.settings_rounded,
                onPressed: () {
                  // Navigate to school management
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSchoolStatsSection(SchoolAdminUser user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _statItem(
              value: user.totalStudents.toString(),
              label: 'Students',
              icon: Icons.people_rounded,
              color: Colors.blue,
            ),
            _statItem(
              value: user.totalTeachers.toString(),
              label: 'Teachers',
              icon: Icons.school_rounded,
              color: Colors.green,
            ),
            _statItem(
              value: user.totalClasses.toString(),
              label: 'Classes',
              icon: Icons.class_rounded,
              color: Colors.orange,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _infoRow('Capacity Utilization', '${user.schoolCapacityUtilization.toStringAsFixed(1)}%'),
      ],
    );
  }

  List<Widget> _buildParentSections(ParentUser user) {
    // Check if this is a Kidling parent using the platform
    if (user.platform == Platform.kidling) {
      return _buildKidlingParentSections(user);
    }
    
    // Regular parent sections
    final sections = <Widget>[];
    
    if (user.children.isNotEmpty) {
      sections.add(_sectionTitle('My Children'));
      sections.add(_softCard(_buildChildrenSection(user)));
      sections.add(const SizedBox(height: 28));
    }

    sections.add(_sectionTitle('School Information'));
    sections.add(_softCard(_buildParentSchoolSection(user)));
    sections.add(const SizedBox(height: 28));
    
    return sections;
  }

  List<Widget> _buildKidlingParentSections(ParentUser user) {
    final subscription = user.kidlingSubscription;
    final isPremium = subscription?.kidlingPlan != KidlingPlan.free;
    final dailyLimit = subscription?.dailyActivityLimit ?? 3;
    
    return [
      _sectionTitle('My Little Learner'),
      _softCard(_buildKidlingChildSection(user)),
      const SizedBox(height: 28),

      _sectionTitle('Learning Progress'),
      _softCard(_buildKidlingProgressSection(user, isPremium: isPremium, dailyLimit: dailyLimit)),
      const SizedBox(height: 28),

      _sectionTitle('Favorite Activities'),
      _softCard(_buildKidlingActivitiesSection(user)),
      const SizedBox(height: 28),
    ];
  }

  Widget _buildKidlingChildSection(ParentUser user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pink.shade300, Colors.orange.shade300],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  user.childGender?.toLowerCase() == 'female' 
                      ? Icons.face_3_rounded 
                      : Icons.face_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.childName ?? 'Little Learner',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Age: ${user.childAge ?? '3-6'} years',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _infoRow('Learning Interest', user.learningInterest ?? 'General Learning'),
        _infoRow('Preferred Time', user.preferredLearningTime ?? 'Flexible'),
        if (user.childGender != null)
          _infoRow('Gender', user.childGender!),
      ],
    );
  }

  Widget _buildKidlingProgressSection(ParentUser user, {required bool isPremium, required int dailyLimit}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _kidlingStatItem(
              value: '12',
              label: 'Activities\nCompleted',
              icon: Icons.check_circle_rounded,
              color: Colors.green,
            ),
            _kidlingStatItem(
              value: '45',
              label: 'Minutes\nToday',
              icon: Icons.timer_rounded,
              color: Colors.blue,
            ),
            _kidlingStatItem(
              value: isPremium ? 'Unlimited' : dailyLimit.toString(),
              label: 'Daily\nLimit',
              icon: Icons.star_rounded,
              color: Colors.amber,
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (!isPremium)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(Icons.upgrade_rounded, color: Colors.orange.shade700, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Upgrade to Premium',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Unlock unlimited activities and progress reports!',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.pink.shade50,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(Icons.emoji_events_rounded, color: Colors.amber.shade700, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recent Achievement',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Completed 5 days of learning in a row!',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
