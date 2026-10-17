part of '../classroom.dart';

// _ClassroomPageState: _showClassDetails, _buildEmptyState, _buildConnectionStatus
extension ClassroomPageStateSection03 on _ClassroomPageState {
  void _showClassDetails(Map<String, dynamic> classItem) {
  final classmates = classItem['classmates'] as List<dynamic>? ?? [];
  
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      final className = classItem['name']?.toString() ?? 'Unknown Class';
      final classSection = classItem['section']?.toString() ?? 'General';
      final color = classItem['color'] is Color 
          ? classItem['color'] as Color 
          : Colors.grey;
      final iconData = classItem['icon'] is IconData
          ? classItem['icon'] as IconData
          : Icons.school;

      return Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    iconData,
                    color: color,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        className,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        classSection,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Classmates (${classmates.length})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: classmates.isEmpty
                  ? const Center(
                      child: Text('No classmates found'),
                    )
                  : ListView.builder(
                      itemCount: classmates.length,
                      itemBuilder: (context, index) {
                        final classmate = classmates[index];
                        final mateName = classmate['name']?.toString() ?? 'Unknown';
                        final schoolName = classmate['schoolName']?.toString() ?? '';
                        
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            child: Text(
                              mateName.isNotEmpty ? mateName.substring(0, 1).toUpperCase() : '?',
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(mateName),
                          subtitle: schoolName.isNotEmpty 
                              ? Text(schoolName)
                              : null,
                          trailing: IconButton(
                            icon: const Icon(Icons.message),
                            onPressed: () {
                              // Navigate to chat
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      );
    },
  );
}

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String description,
    required String actionText,
    required VoidCallback onAction,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(actionText),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus() {
    final totalConnections =
        _registeredSchools.length +
        _teachers.length +
        _classes.fold(0, (sum, c) => sum + ((c['classmates'] as List).length));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        children: [
          const Icon(Icons.info, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Connection Status',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$totalConnections connections from Connect tab',
                  style: TextStyle(fontSize: 14, color: Colors.blue.shade700),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: totalConnections / 20,
                  backgroundColor: Colors.blue.shade100,
                  color: Colors.blue,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
