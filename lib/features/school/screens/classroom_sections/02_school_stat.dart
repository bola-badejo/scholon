part of '../classroom.dart';

// _ClassroomPageState: _buildSchoolStat, _buildTeachersSection, _buildTeacherCard, _buildClassesSection, _buildClassCard
extension ClassroomPageStateSection02 on _ClassroomPageState {
  Widget _buildSchoolStat({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildTeachersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Connected Teachers',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            if (_teachers.isEmpty)
              TextButton.icon(
                onPressed: _navigateToConnect,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Connect'),
                style: TextButton.styleFrom(foregroundColor: Colors.deepPurple),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_teachers.isEmpty)
          _buildEmptyState(
            icon: Icons.person,
            title: 'No teachers connected',
            description: 'Connect with teachers to see them here',
            actionText: 'Find Teachers',
            onAction: _navigateToConnect,
          )
        else
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (var teacher in _teachers) _buildTeacherCard(teacher),
            ],
          ),
      ],
    );
  }

  Widget _buildTeacherCard(Map<String, dynamic> teacher) {
  // SAFE NULL HANDLING
  final teacherName = teacher['name']?.toString() ?? 'Unknown Teacher';
  final isPlaceholder = teacherName.contains('No Teachers') || 
                       teacher['isPlaceholder'] == true;
  
  final teacherSubject = teacher['subject']?.toString() ?? 'General';
  final teacherAvatar = teacher['avatar']?.toString() ?? '👨‍🏫';
  final teacherClasses = teacher['classes'] as List? ?? [];
  
  // SAFE Color handling
  final color = teacher['color'] is Color 
      ? teacher['color'] as Color 
      : Colors.green;

  return Container(
    width: (MediaQuery.of(context).size.width - 44) / 2,
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
          ),
          child: teacher['profileImageUrl'] != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.network(
                    teacher['profileImageUrl'].toString(),
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(child: Text(teacherAvatar, style: const TextStyle(fontSize: 32)));
                    },
                  ),
                )
              : Center(
                  child: Text(
                    teacherAvatar,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
        ),
        const SizedBox(height: 12),
        Text(
          teacherName,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isPlaceholder ? Colors.grey : Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          teacherSubject,
          style: TextStyle(
            fontSize: 14,
            color: isPlaceholder ? Colors.grey : Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        if (teacherClasses.isNotEmpty)
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (var className in teacherClasses.take(3))
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    className.toString(),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (teacherClasses.length > 3)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '+${teacherClasses.length - 3}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        const SizedBox(height: 12),
        if (!isPlaceholder)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.email, color: Colors.grey[600]),
                onPressed: () {
                  final email = teacher['email']?.toString();
                  if (email != null && email.isNotEmpty && email != 'No email') {
                    // Launch email
                  }
                },
              ),
              IconButton(
                icon: Icon(Icons.phone, color: Colors.grey[600]),
                onPressed: () {
                  final phone = teacher['phone']?.toString();
                  if (phone != null && phone.isNotEmpty && phone != 'No phone') {
                    // Launch phone
                  }
                },
              ),
              IconButton(
                icon: Icon(Icons.message, color: Colors.grey[600]),
                onPressed: () {
                  // Navigate to chat
                },
              ),
            ],
          )
        else
          TextButton(
            onPressed: _navigateToConnect,
            child: const Text('Connect with teachers'),
          ),
      ],
    ),
  );
}

  Widget _buildClassesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Classes from Connections',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            if (_classes.isEmpty)
              TextButton.icon(
                onPressed: _navigateToConnect,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Connect'),
                style: TextButton.styleFrom(foregroundColor: Colors.deepPurple),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Based on your classmates\' connections',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        if (_classes.isEmpty)
          _buildEmptyState(
            icon: Icons.group,
            title: 'No classes found',
            description: 'Connect with classmates to discover classes',
            actionText: 'Find Classmates',
            onAction: _navigateToConnect,
          )
        else
          Column(
            children: [
              for (var classItem in _classes)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildClassCard(classItem),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildClassCard(Map<String, dynamic> classItem) {
  // SAFE NULL HANDLING
  final className = classItem['name']?.toString() ?? 'Unknown Class';
  final isPlaceholder = className.contains('No Classes') || 
                       classItem['isPlaceholder'] == true;
  
  final classSection = classItem['section']?.toString() ?? 'General';
  final classTeacher = classItem['teacher']?.toString() ?? 'Not assigned';
  final classRoom = classItem['room']?.toString() ?? 'Room 000';
  
  final classmates = classItem['classmates'] as List<dynamic>? ?? [];
  final classmatesCount = classmates.length;
  
  // SAFE Color and Icon handling
  final color = classItem['color'] is Color 
      ? classItem['color'] as Color 
      : Colors.grey;
  
  final iconData = classItem['icon'] is IconData
      ? classItem['icon'] as IconData
      : Icons.school;

  return Container(
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
    child: Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            iconData,
            color: color,
            size: 28,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                className,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isPlaceholder ? Colors.grey : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$classSection • $classTeacher',
                style: TextStyle(
                  fontSize: 14,
                  color: isPlaceholder ? Colors.grey : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.people, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    '$classmatesCount classmates',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.room, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    classRoom,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
              if (classmatesCount > 0 && !isPlaceholder) ...[
                const SizedBox(height: 8),
                SizedBox(
                  height: 30,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: classmatesCount > 3 ? 3 : classmatesCount,
                    itemBuilder: (context, index) {
                      final classmate = classmates[index];
                      final mateName = classmate['name']?.toString() ?? '?';
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: CircleAvatar(
                          radius: 15,
                          backgroundColor: Colors.blue.shade100,
                          child: Text(
                            mateName.isNotEmpty ? mateName.substring(0, 1).toUpperCase() : '?',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
        if (!isPlaceholder)
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 16),
            onPressed: () {
              // Navigate to class details
              _showClassDetails(classItem);
            },
          ),
      ],
    ),
  );
}
}
