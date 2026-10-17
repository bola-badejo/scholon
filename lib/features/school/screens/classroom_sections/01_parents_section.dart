part of '../classroom.dart';

// _ClassroomPageState: _buildParentsSection, _buildParentCard, _buildLoadingScreen, _buildWelcomeSection, _buildStatChip, _buildSchoolsSection, _buildSchoolCard
extension ClassroomPageStateSection01 on _ClassroomPageState {
  Widget _buildParentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Connected Parents',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            if (_parents.isEmpty || _parents.first['isPlaceholder'] == true)
              TextButton.icon(
                onPressed: _navigateToConnect,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Connect'),
                style: TextButton.styleFrom(foregroundColor: Colors.deepPurple),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_parents.isEmpty)
          _buildEmptyState(
            icon: Icons.family_restroom,
            title: 'No parents connected',
            description: 'Connect with parents to see them here',
            actionText: 'Find Parents',
            onAction: _navigateToConnect,
          )
        else
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _parents.length,
              itemBuilder: (context, index) {
                return _buildParentCard(_parents[index], index);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildParentCard(Map<String, dynamic> parent, int index) {
    final isPlaceholder = parent['isPlaceholder'] == true;
    final isError = parent['isError'] == true;
    final color = parent['color'] as Color? ?? Colors.purple;

    return GestureDetector(
      onTap: isPlaceholder ? _navigateToConnect : null,
      child: Container(
        width: 200,
        margin: EdgeInsets.only(right: index != _parents.length - 1 ? 12 : 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isError
              ? Colors.red.shade50
              : isPlaceholder
              ? Colors.grey.shade50
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isError
                ? Colors.red.shade200
                : isPlaceholder
                ? Colors.grey.shade300
                : Colors.grey.shade200,
          ),
          boxShadow: isPlaceholder || isError
              ? null
              : [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              parent['icon'] as IconData? ?? Icons.family_restroom,
              size: 40,
              color: isError ? Colors.red : color,
            ),
            const SizedBox(height: 8),
            Text(
              parent['name'] as String? ?? 'Parent',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isError
                    ? Colors.red
                    : isPlaceholder
                    ? Colors.grey
                    : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            if (!isPlaceholder && parent['relationship'] != null) ...[
              const SizedBox(height: 4),
              Text(
                parent['relationship'] as String,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
            if (isPlaceholder && parent['actionText'] != null) ...[
              const SizedBox(height: 8),
              Text(
                parent['actionText'] as String,
                style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF4A44C6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.school, size: 40, color: Colors.white),
          ),
          const SizedBox(height: 20),
          const Text(
            'Loading classroom information...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          const CircularProgressIndicator(color: Colors.deepPurple),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    // SAFE NULL HANDLING
    final userName = _currentUser?.name ?? 'Student';
    final studentName = userName.isNotEmpty
        ? userName.split(' ').first
        : 'Student';

    // SAFE NULL HANDLING for classGrade
    final classGrade = _currentUser?.classGrade;
    final className = classGrade != null
        ? 'Grade $classGrade'
        : 'Grade Not specified';

    // SAFE NULL HANDLING for schoolName
    final schoolName = _currentUser?.schoolName ?? 'No school connected';

    // Calculate actual connections (excluding placeholders) with null safety
    final actualSchools = _registeredSchools
        .where((s) => s['isPlaceholder'] != true)
        .length;

    final actualTeachers = _teachers
        .where((t) => t['isPlaceholder'] != true)
        .length;

    final actualParents = _parents
        .where((p) => p['isPlaceholder'] != true)
        .length;

    final actualClasses = _classes
        .where((c) => c['isPlaceholder'] != true)
        .length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade50, Colors.purple.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Center(
              child: Icon(Icons.school, color: Colors.white, size: 30),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome to Your Classroom, $studentName!',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$className • $schoolName',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildStatChip(
                      icon: Icons.school,
                      label: '$actualSchools Schools',
                      color: Colors.blue,
                      onTap: actualSchools > 0
                          ? () {
                              // Show schools
                            }
                          : null,
                    ),
                    _buildStatChip(
                      icon: Icons.people,
                      label: '$actualTeachers Teachers',
                      color: Colors.green,
                      onTap: actualTeachers > 0
                          ? () {
                              // Show teachers
                            }
                          : null,
                    ),
                    _buildStatChip(
                      icon: Icons.family_restroom,
                      label: '$actualParents Parents',
                      color: Colors.purple,
                      onTap: actualParents > 0
                          ? () {
                              // Show parents
                            }
                          : null,
                    ),
                    _buildStatChip(
                      icon: Icons.group,
                      label: '$actualClasses Classes',
                      color: Colors.orange,
                      onTap: actualClasses > 0
                          ? () {
                              // Show classes
                            }
                          : null,
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

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSchoolsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Connected Schools',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            if (_registeredSchools.isEmpty)
              TextButton.icon(
                onPressed: _navigateToConnect,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Connect'),
                style: TextButton.styleFrom(foregroundColor: Colors.deepPurple),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_registeredSchools.isEmpty)
          _buildEmptyState(
            icon: Icons.school,
            title: 'No schools connected',
            description: 'Connect with schools to see them here',
            actionText: 'Find Schools',
            onAction: _navigateToConnect,
          )
        else
          SizedBox(
            height: 200,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (var school in _registeredSchools)
                  Padding(
                    padding: EdgeInsets.only(
                      right: school != _registeredSchools.last ? 12 : 0,
                    ),
                    child: _buildSchoolCard(school),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSchoolCard(Map<String, dynamic> school) {
    // SAFE NULL HANDLING
    final schoolName = school['name']?.toString() ?? 'Unknown School';
    final isPlaceholder =
        schoolName.contains('No Schools') || school['isPlaceholder'] == true;

    final schoolLogo = school['logo']?.toString() ?? '🏫';
    final schoolType = school['type']?.toString() ?? 'School';
    final schoolAddress =
        school['address']?.toString() ?? 'Address not available';

    // SAFE Color handling
    final color = school['color'] is Color
        ? school['color'] as Color
        : Colors.blue;

    return GestureDetector(
      onTap: () {
        if (isPlaceholder) {
          _navigateToConnect();
        } else {
          _navigateToAffairs(school);
        }
      },
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isPlaceholder ? Colors.grey.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPlaceholder ? Colors.grey.shade300 : Colors.grey.shade200,
          ),
          boxShadow: isPlaceholder
              ? null
              : [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: schoolLogo.startsWith('http')
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              schoolLogo,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.school, size: 30);
                              },
                            ),
                          )
                        : Text(
                            schoolLogo,
                            style: const TextStyle(fontSize: 24),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        schoolName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isPlaceholder ? Colors.grey : Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        schoolType,
                        style: TextStyle(
                          fontSize: 12,
                          color: isPlaceholder ? Colors.grey : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              schoolAddress,
              style: TextStyle(
                fontSize: 14,
                color: isPlaceholder ? Colors.grey : Colors.grey[700],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            if (!isPlaceholder)
              Row(
                children: [
                  Expanded(
                    child: _buildSchoolStat(
                      icon: Icons.people,
                      value: (school['students'] ?? 0).toString(),
                      label: 'Students',
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSchoolStat(
                      icon: Icons.person,
                      value: (school['teachers'] ?? 0).toString(),
                      label: 'Teachers',
                      color: Colors.green,
                    ),
                  ),
                ],
              )
            else
              Center(
                child: TextButton(
                  onPressed: _navigateToConnect,
                  child: const Text('Connect with schools'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
