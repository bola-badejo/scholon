import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:isapp/Models/user.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:isapp/Models/user.dart';

enum ConnectionType {
  parent('Parent', Icons.family_restroom, Colors.deepOrange),
  teacher('Teacher', Icons.school, Colors.blue),
  school('School', Icons.business, Colors.green),
  student('Student', Icons.person, Colors.purple),
  classmate('Classmate', Icons.groups, Colors.teal),
  course('Course', Icons.menu_book, Colors.indigo),
  job('Job', Icons.work, Colors.amber),
  kidling('Kidling', Icons.work, Colors.red);

  final String displayName;
  final IconData icon;
  final Color color;

  const ConnectionType(this.displayName, this.icon, this.color);
}

enum ConnectionStatus {
  pending('Pending', Colors.orange, Icons.pending_actions_rounded),
  accepted('Connected', Colors.green, Icons.check_circle_rounded),
  rejected('Rejected', Colors.red, Icons.cancel_rounded),
  blocked('Blocked', Colors.grey, Icons.block_rounded);

  final String displayName;
  final Color color;
  final IconData icon;

  const ConnectionStatus(this.displayName, this.color, this.icon);
}

enum UserOnlineStatus {
  online('Online', Colors.green),
  offline('Offline', Colors.grey),
  busy('Busy', Colors.orange),
  studying('Studying', Colors.blue);

  final String displayName;
  final Color color;

  const UserOnlineStatus(this.displayName, this.color);
}

// ========== ENHANCED CONNECTION CONTROLLER ==========
class ConnectController extends GetxController {
  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Current user - using BaseUser from original classes
  final Rx<BaseUser?> currentUser = Rx<BaseUser?>(null);

  // Reactive lists - using BaseUser instead of ConnectUser
  final RxList<ConnectionRequest> pendingRequests = <ConnectionRequest>[].obs;
  final RxList<BaseUser> connections = <BaseUser>[].obs;
  final RxList<BaseUser> pendingConnections = <BaseUser>[].obs;
  final RxList<BaseUser> searchResults = <BaseUser>[].obs;
  final RxList<BaseUser> onlineUsers = <BaseUser>[].obs;
  final RxList<StudyGroup> studyGroups = <StudyGroup>[].obs;
  final RxList<String> blockedUsers = <String>[].obs;

  // Search state
  final TextEditingController searchController = TextEditingController();
  final Rx<ConnectionType?> selectedConnectionType = Rx<ConnectionType?>(null);
  final RxString searchQuery = ''.obs;
  final RxBool isSearching = false.obs;

  // Form controllers
  final TextEditingController groupNameController = TextEditingController();
  final TextEditingController groupDescriptionController =
      TextEditingController();
  final TextEditingController connectionMessageController =
      TextEditingController();
  final RxString selectedSubject = 'General'.obs;

  // State
  final RxBool isLoading = false.obs;
  final RxInt totalConnections = 0.obs;
  final RxInt totalGroups = 0.obs;
  final RxInt totalPending = 0.obs;
  final Rx<Map<String, int>> connectionStats = Rx<Map<String, int>>({});

  // Stream subscriptions
  StreamSubscription? _userSubscription;
  StreamSubscription? _connectionsSubscription;
  StreamSubscription? _requestsSubscription;
  StreamSubscription? _pendingSentSubscription;
  StreamSubscription? _onlineUsersSubscription;
  StreamSubscription? _groupsSubscription;

  @override
  void onInit() {
    super.onInit();
    _initialize();

    // Debounce search
    debounce(searchQuery, (_) {
      if (searchQuery.value.isNotEmpty) {
        _performSearch();
      } else {
        searchResults.clear();
      }
    }, time: const Duration(milliseconds: 500));
  }

  @override
  void onClose() {
    _userSubscription?.cancel();
    _connectionsSubscription?.cancel();
    _requestsSubscription?.cancel();
    _pendingSentSubscription?.cancel();
    _onlineUsersSubscription?.cancel();
    _groupsSubscription?.cancel();
    searchController.dispose();
    groupNameController.dispose();
    groupDescriptionController.dispose();
    connectionMessageController.dispose();
    super.onClose();
  }

  // ========== INITIALIZATION ==========
  Future<void> _initialize() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _loadCurrentUser(user.uid);
      _setupRealtimeListeners(user.uid);
      await updateUserOnlineStatus(UserOnlineStatus.online);
      await _loadConnectionStats();
    } catch (e) {
      print('Initialization error: $e');
    }
  }

  Future<void> _loadCurrentUser(String userId) async {
    try {
      final userTypes = [
        'student_details',
        'teacher_details',
        'school_details',
        'parent_details',
      ];

      for (final collection in userTypes) {
        final doc = await _firestore.collection(collection).doc(userId).get();
        if (doc.exists) {
          final data = doc.data()!;
          data['userType'] = collection.replaceAll('_details', '');
          currentUser.value = createUserFromMap(data);
          return;
        }
      }
    } catch (e) {
      print('Error loading user: $e');
    }
  }

  void _setupRealtimeListeners(String userId) {
    // Current user updates
    _userSubscription = _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .listen((snapshot) {
          if (snapshot.exists) {
            currentUser.value = createUserFromMap(snapshot.data()!);
          }
        });

    // Incoming connection requests
    _requestsSubscription = _firestore
        .collection('connection_requests')
        .where('receiverId', isEqualTo: userId)
        .where('status', whereIn: ['pending', 'accepted'])
        .orderBy('sentAt', descending: true)
        .snapshots()
        .listen((snapshot) async {
          final requests = snapshot.docs
              .map((doc) => ConnectionRequest.fromFirestore(doc.data()))
              .where((request) => request.status != ConnectionStatus.rejected)
              .toList();

          pendingRequests.value = requests
              .where((request) => request.status == ConnectionStatus.pending)
              .toList();

          final acceptedRequests = requests
              .where((request) => request.status == ConnectionStatus.accepted)
              .toList();
          if (acceptedRequests.isNotEmpty) {
            await _loadAcceptedConnections(acceptedRequests);
          }
        });

    // Outgoing connection requests
    _pendingSentSubscription = _firestore
        .collection('connection_requests')
        .where('senderId', isEqualTo: userId)
        .where('status', whereIn: ['pending', 'accepted'])
        .orderBy('sentAt', descending: true)
        .snapshots()
        .listen((snapshot) async {
          final requests = snapshot.docs
              .map((doc) => ConnectionRequest.fromFirestore(doc.data()))
              .where((request) => request.status != ConnectionStatus.rejected)
              .toList();

          final pendingSentRequests = requests
              .where((request) => request.status == ConnectionStatus.pending)
              .toList();
          if (pendingSentRequests.isNotEmpty) {
            await _loadPendingSentConnections(pendingSentRequests);
          }
        });

    // Connections
    _connectionsSubscription = _firestore
        .collection('connections')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'accepted')
        .snapshots()
        .listen((snapshot) async {
          final connectionIds = snapshot.docs
              .map((doc) => doc.data()['connectedUserId'] as String)
              .where((id) => id.isNotEmpty)
              .toSet()
              .toList();

          if (connectionIds.isNotEmpty) {
            await _loadConnections(connectionIds);
          }
          await _loadConnectionStats();
        });

    // Online users
    _onlineUsersSubscription = _firestore
        .collection('users')
        .where('onlineStatus', whereIn: ['online', 'studying'])
        .limit(50)
        .snapshots()
        .listen((snapshot) async {
          final users = await _filterUsers(
            snapshot.docs
                .map((doc) => createUserFromMap(doc.data()))
                .where((user) => user.uid != userId)
                .toList(),
          );

          onlineUsers.value = users;
        });

    // Study groups
    _groupsSubscription = _firestore
        .collection('study_groups')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(10)
        .snapshots()
        .listen((snapshot) {
          studyGroups.value = snapshot.docs
              .map((doc) => StudyGroup.fromFirestore(doc.data()))
              .toList();
          totalGroups.value = studyGroups.length;
        });
  }

  // ========== CLASSROOM DATA FETCHING METHODS ==========

  Future<List<Map<String, dynamic>>> getConnectedSchools() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return [];

      // Try to get from connections
      final connections = await _firestore
          .collection('connections')
          .where('userId', isEqualTo: userId)
          .where(
            'connectionType',
            whereIn: ['school', ConnectionType.school.name],
          )
          .where('status', isEqualTo: 'accepted')
          .get();

      final schoolIds = connections.docs
          .map((doc) {
            final data = doc.data();
            return data['connectedUserId'] as String?;
          })
          .where((id) => id != null && id.isNotEmpty)
          .cast<String>()
          .toSet()
          .toList();

      if (schoolIds.isEmpty) return [];

      final schools = <Map<String, dynamic>>[];

      for (final schoolId in schoolIds) {
        try {
          // Try multiple collections
          final collections = [
            'school_details',
            'users',
            'schools',
            'school_user_profiles',
          ];

          Map<String, dynamic>? schoolData;
          String? foundCollection;

          for (final collection in collections) {
            try {
              final doc = await _firestore
                  .collection(collection)
                  .doc(schoolId)
                  .get();
              if (doc.exists) {
                schoolData = doc.data();
                foundCollection = collection;
                break;
              }
            } catch (e) {
              continue; // Try next collection
            }
          }

          if (schoolData != null) {
            // Extract school info based on collection
            String schoolName;
            String? address;
            String? code;

            switch (foundCollection) {
              case 'school_details':
                schoolName =
                    schoolData['schoolName'] as String? ?? 'Unknown School';
                address = schoolData['schoolAddress'] as String?;
                code = schoolData['schoolCode'] as String?;
                break;

              case 'users':
                // Check if it's a SchoolAdmin user
                final userType = schoolData['userType'] as String?;
                if (userType == UserType.schoolAdmin.name ||
                    schoolData.containsKey('schoolName') ||
                    schoolData.containsKey('schoolCode')) {
                  schoolName =
                      schoolData['schoolName'] as String? ??
                      schoolData['name'] as String? ??
                      'Unknown School';
                  address =
                      schoolData['schoolAddress'] as String? ??
                      schoolData['address'] as String?;
                  code = schoolData['schoolCode'] as String?;
                } else {
                  continue; // Not a school admin
                }
                break;

              case 'schools':
                schoolName = schoolData['name'] as String? ?? 'Unknown School';
                address = schoolData['address'] as String?;
                code = schoolData['code'] as String?;
                break;

              case 'school_user_profiles':
                schoolName =
                    schoolData['schoolName'] as String? ?? 'Unknown School';
                address = schoolData['address'] as String?;
                code = schoolData['schoolCode'] as String?;
                break;

              default:
                schoolName = 'Unknown School';
                address = null;
                code = null;
            }

            schools.add({
              'id': schoolId,
              'name': schoolName,
              'address': address ?? 'Address not available',
              'type': 'School',
              'students': schoolData['totalStudents'] as int? ?? 0,
              'teachers': schoolData['totalTeachers'] as int? ?? 0,
              'logo':
                  schoolData['logoUrl'] as String? ??
                  schoolData['profileImageUrl'] as String? ??
                  '🏫',
              'color': Colors.blue,
              'schoolCode': code,
            });
          }
        } catch (e) {
          print('Error processing school $schoolId: $e');
          // Add minimal school info
          schools.add({
            'id': schoolId,
            'name': 'School $schoolId',
            'address': 'Address not available',
            'type': 'School',
            'students': 0,
            'teachers': 0,
            'logo': '🏫',
            'color': Colors.grey,
          });
        }
      }

      return schools;
    } catch (e) {
      print('Error in getConnectedSchools: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getConnectedParents() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return [];

      final connections = await _firestore
          .collection('connections')
          .where('userId', isEqualTo: userId)
          .where(
            'connectionType',
            whereIn: ['parent', ConnectionType.parent.name],
          )
          .where('status', isEqualTo: 'accepted')
          .get();

      final parentIds = connections.docs
          .map((doc) {
            final data = doc.data();
            return data['connectedUserId'] as String?;
          })
          .where((id) => id != null && id.isNotEmpty)
          .cast<String>()
          .toSet()
          .toList();

      if (parentIds.isEmpty) return [];

      final parents = <Map<String, dynamic>>[];

      for (final parentId in parentIds) {
        try {
          // Try multiple collections
          final collections = [
            'parent_details',
            'users',
            'school_user_profiles',
          ];

          Map<String, dynamic>? parentData;

          for (final collection in collections) {
            try {
              final doc = await _firestore
                  .collection(collection)
                  .doc(parentId)
                  .get();
              if (doc.exists) {
                parentData = doc.data();
                break;
              }
            } catch (e) {
              continue;
            }
          }

          if (parentData != null) {
            final name =
                parentData['name'] as String? ??
                parentData['userName'] as String? ??
                'Unknown Parent';

            final relationship =
                parentData['relationship'] as String? ?? 'Parent';
            final studentName = parentData['studentName'] as String?;
            final studentClass = parentData['studentClass'] as String?;
            final schoolName =
                parentData['schoolName'] as String? ?? 'Unknown School';

            parents.add({
              'id': parentId,
              'name': name,
              'email': parentData['email'] as String? ?? '',
              'phone': parentData['phoneNumber'] as String? ?? '',
              'relationship': relationship,
              'studentName': studentName,
              'studentClass': studentClass,
              'schoolName': schoolName,
              'profileImageUrl': parentData['profileImageUrl'] as String?,
              'color': Colors.purple,
              'icon': Icons.family_restroom,
            });
          } else {
            // Add minimal parent info
            parents.add({
              'id': parentId,
              'name': 'Parent $parentId',
              'relationship': 'Parent',
              'color': Colors.grey,
              'icon': Icons.family_restroom,
            });
          }
        } catch (e) {
          print('Error processing parent $parentId: $e');
        }
      }

      return parents;
    } catch (e) {
      print('Error in getConnectedParents: $e');
      return [];
    }
  }

  Future<void> setupConnectionsForExistingUsers() async {
    try {
      // Get all user documents from all collections
      final collections = [
        'student_details',
        'teacher_details',
        'school_details',
        'parent_details',
      ];

      for (final collection in collections) {
        final snapshot = await _firestore.collection(collection).get();

        for (final doc in snapshot.docs) {
          final userId = doc.id;
          final userType = collection.replaceAll('_details', '');

          // Create connection document if it doesn't exist
          final existingConnections = await _firestore
              .collection('connections')
              .doc(userId)
              .get();

          if (!existingConnections.exists) {
            await _firestore.collection('connections').doc(userId).set({
              'userId': userId,
              'userType': userType,
              'connectedUsers': [],
              'schools': [],
              'teachers': [],
              'classmates': [],
              'parents': [],
              'createdAt': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
            });
          }
        }
      }
    } catch (e) {
      print('Error setting up connections: $e');
    }
  }

  Future<void> _createMutualConnection(ConnectionRequest request) async {
    try {
      // Create connection records for both users
      final now = Timestamp.now();

      // For sender
      await _firestore.collection('connections').doc(request.senderId).update({
        'connectedUsers': FieldValue.arrayUnion([request.receiverId]),
        '${request.type.name}s': FieldValue.arrayUnion([request.receiverId]),
        'updatedAt': now,
      });

      // For receiver
      await _firestore.collection('connections').doc(request.receiverId).update(
        {
          'connectedUsers': FieldValue.arrayUnion([request.senderId]),
          'updatedAt': now,
        },
      );
    } catch (e) {
      print('Error creating mutual connection: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getConnectedTeachers() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return [];

      final connections = await _firestore
          .collection('connections')
          .where('userId', isEqualTo: userId)
          .where(
            'connectionType',
            whereIn: ['teacher', ConnectionType.teacher.name],
          )
          .where('status', isEqualTo: 'accepted')
          .get();

      final teacherIds = connections.docs
          .map((doc) {
            final data = doc.data();
            return data['connectedUserId'] as String?;
          })
          .where((id) => id != null && id.isNotEmpty)
          .cast<String>()
          .toSet()
          .toList();

      if (teacherIds.isEmpty) return [];

      final teachers = <Map<String, dynamic>>[];

      for (final teacherId in teacherIds) {
        try {
          // Try multiple collections
          final collections = [
            'teacher_details',
            'users',
            'school_user_profiles',
          ];

          Map<String, dynamic>? teacherData;

          for (final collection in collections) {
            try {
              final doc = await _firestore
                  .collection(collection)
                  .doc(teacherId)
                  .get();
              if (doc.exists) {
                teacherData = doc.data();
                break;
              }
            } catch (e) {
              continue;
            }
          }

          if (teacherData != null) {
            // Extract teacher info
            final name =
                teacherData['name'] as String? ??
                teacherData['userName'] as String? ??
                'Unknown Teacher';

            final subject =
                teacherData['subjectSpecialization'] as String? ??
                teacherData['subject'] as String? ??
                'General';

            final email = teacherData['email'] as String? ?? 'No email';
            final phone = teacherData['phoneNumber'] as String? ?? 'No phone';

            final profileImageUrl = teacherData['profileImageUrl'] as String?;
            final schoolName =
                teacherData['schoolName'] as String? ?? 'Unknown School';

            // Get classes/assigned subjects
            final List<String> classes = [];
            if (teacherData.containsKey('assignedSubjects')) {
              final assigned = teacherData['assignedSubjects'];
              if (assigned is List) {
                classes.addAll(assigned.whereType<String>());
              }
            }
            if (teacherData.containsKey('assignedClasses')) {
              final assigned = teacherData['assignedClasses'];
              if (assigned is List) {
                classes.addAll(assigned.whereType<String>());
              }
            }

            teachers.add({
              'id': teacherId,
              'name': name,
              'subject': subject,
              'email': email,
              'phone': phone,
              'avatar': '👨‍🏫',
              'classes': classes.isNotEmpty ? classes : ['Not assigned'],
              'color': Colors.green,
              'profileImageUrl': profileImageUrl,
              'userType': teacherData['userType'] as String? ?? 'teacher',
              'schoolName': schoolName,
            });
          } else {
            // Add minimal teacher info
            teachers.add({
              'id': teacherId,
              'name': 'Teacher $teacherId',
              'subject': 'General',
              'email': 'No email',
              'phone': 'No phone',
              'avatar': '👨‍🏫',
              'classes': ['Not assigned'],
              'color': Colors.grey,
            });
          }
        } catch (e) {
          print('Error processing teacher $teacherId: $e');
        }
      }

      return teachers;
    } catch (e) {
      print('Error in getConnectedTeachers: $e');
      return [];
    }
  }

  // Get connected classmates and group them by class
  Future<List<Map<String, dynamic>>> getConnectedClassmates() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return [];

      final connections = await _firestore
          .collection('connections')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'accepted')
          .get();

      // Filter for student/classmate connections
      final studentConnections = connections.docs.where((doc) {
        final data = doc.data();
        final connectionType = data['connectionType'] as String? ?? '';
        return connectionType == ConnectionType.classmate.name ||
            connectionType == ConnectionType.student.name ||
            connectionType == 'student' ||
            connectionType == 'classmate';
      }).toList();

      final classmateIds = studentConnections
          .map((doc) {
            final data = doc.data();
            return data['connectedUserId'] as String?;
          })
          .where((id) => id != null && id.isNotEmpty)
          .cast<String>()
          .toSet()
          .toList();

      if (classmateIds.isEmpty) return [];

      final classmatesData = <Map<String, dynamic>>[];

      for (final classmateId in classmateIds) {
        try {
          // Try multiple collections
          final collections = [
            'student_details',
            'users',
            'school_user_profiles',
          ];

          Map<String, dynamic>? studentData;

          for (final collection in collections) {
            try {
              final doc = await _firestore
                  .collection(collection)
                  .doc(classmateId)
                  .get();
              if (doc.exists) {
                studentData = doc.data();
                break;
              }
            } catch (e) {
              continue;
            }
          }

          if (studentData != null) {
            final name =
                studentData['name'] as String? ??
                studentData['userName'] as String? ??
                'Unknown Student';

            final classGrade =
                studentData['classGrade']?.toString() ?? 'Unknown';
            final schoolName =
                studentData['schoolName'] as String? ?? 'Unknown School';

            classmatesData.add({
              'userId': classmateId,
              'name': name,
              'classGrade': classGrade,
              'schoolName': schoolName,
              'profileImageUrl': studentData['profileImageUrl'] as String?,
              'email': studentData['email'] as String? ?? '',
              'phone': studentData['phoneNumber'] as String? ?? '',
            });
          }
        } catch (e) {
          print('Error processing classmate $classmateId: $e');
        }
      }

      // Group classmates by class
      final classesMap = <String, Map<String, dynamic>>{};

      for (final classmate in classmatesData) {
        final className = classmate['classGrade'] as String? ?? 'Unknown';
        final classKey = className.trim().isEmpty
            ? 'Unknown'
            : className.trim();

        if (!classesMap.containsKey(classKey)) {
          classesMap[classKey] = {
            'id': classKey,
            'name': className,
            'section': _getSectionFromClassName(className),
            'teacher': 'To be assigned',
            'students': 1,
            'room': 'Room ${_generateRoomNumber(classKey)}',
            'schedule': 'Mon-Fri, 8:00 AM - 3:00 PM',
            'color': _getColorForClass(classKey),
            'icon': Icons.school,
            'classmates': [classmate],
          };
        } else {
          final existingClass = classesMap[classKey]!;
          existingClass['students'] = (existingClass['students'] as int) + 1;
          (existingClass['classmates'] as List).add(classmate);
        }
      }

      return classesMap.values.toList();
    } catch (e) {
      print('Error in getConnectedClassmates: $e');
      return [];
    }
  }

  // ========== HELPER METHODS FOR CLASSROOM DATA ==========

  String _getSectionFromClassName(String className) {
    final lowerName = className.toLowerCase();
    if (lowerName.contains('science') || lowerName.contains('sci'))
      return 'Science';
    if (lowerName.contains('arts') || lowerName.contains('art')) return 'Arts';
    if (lowerName.contains('commercial') ||
        lowerName.contains('comm') ||
        lowerName.contains('bus'))
      return 'Commercial';
    return 'General';
  }

  int _generateRoomNumber(String className) {
    return (className.hashCode.abs() % 400) + 100;
  }

  Color _getColorForClass(String className) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.red,
      Colors.indigo,
      Colors.pink,
      Colors.amber,
      Colors.cyan,
    ];
    return colors[className.hashCode.abs() % colors.length];
  }

  // Get total connection stats for Classroom page
  Future<Map<String, dynamic>> getClassroomStats() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return {};

      final connections = await _firestore
          .collection('connections')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'accepted')
          .get();

      final stats = {
        'totalConnections': connections.docs.length,
        'schools': 0,
        'teachers': 0,
        'classmates': 0,
        'parents': 0,
      };

      for (final doc in connections.docs) {
        final type = doc.data()['connectionType'] as String? ?? '';
        if (type == ConnectionType.school.name || type == 'school') {
          stats['schools'] = stats['schools']! + 1;
        } else if (type == ConnectionType.teacher.name || type == 'teacher') {
          stats['teachers'] = stats['teachers']! + 1;
        } else if (type == ConnectionType.classmate.name ||
            type == 'classmate' ||
            type == 'student') {
          stats['classmates'] = stats['classmates']! + 1;
        } else if (type == ConnectionType.parent.name || type == 'parent') {
          stats['parents'] = stats['parents']! + 1;
        }
      }

      return stats;
    } catch (e) {
      print('Error in getClassroomStats: $e');
      return {};
    }
  }

  Future<void> _loadAcceptedConnections(
    List<ConnectionRequest> acceptedRequests,
  ) async {
    try {
      final userIds = acceptedRequests
          .map((request) => request.senderId)
          .toSet()
          .toList();
      if (userIds.isEmpty) return;

      final connections = await Future.wait(
        userIds.map((id) async {
          final doc = await _firestore.collection('users').doc(id).get();
          return doc.exists ? createUserFromMap(doc.data()!) : null;
        }),
      );

      final newConnections = connections.whereType<BaseUser>().toList();
      for (final user in newConnections) {
        if (!this.connections.any((u) => u.uid == user.uid)) {
          this.connections.add(user);
        }
      }

      totalConnections.value = this.connections.length;
    } catch (e) {
      print('Error loading accepted connections: $e');
    }
  }

  Future<void> _loadPendingSentConnections(
    List<ConnectionRequest> pendingRequests,
  ) async {
    try {
      final userIds = pendingRequests
          .map((request) => request.receiverId)
          .toSet()
          .toList();
      if (userIds.isEmpty) {
        pendingConnections.clear();
        return;
      }

      final users = await Future.wait(
        userIds.map((id) async {
          final doc = await _firestore.collection('users').doc(id).get();
          return doc.exists ? createUserFromMap(doc.data()!) : null;
        }),
      );

      pendingConnections.value = users.whereType<BaseUser>().toList();
      totalPending.value = pendingConnections.length;
    } catch (e) {
      print('Error loading pending sent connections: $e');
    }
  }

  Future<void> _loadConnections(List<String> userIds) async {
    try {
      if (userIds.isEmpty) return;

      final connections = await Future.wait(
        userIds.map((id) async {
          final doc = await _firestore.collection('users').doc(id).get();
          return doc.exists ? createUserFromMap(doc.data()!) : null;
        }),
      );

      this.connections.value = connections.whereType<BaseUser>().toList();
      totalConnections.value = this.connections.length;
    } catch (e) {
      print('Error loading connections: $e');
    }
  }

  Future<void> _loadConnectionStats() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final stats = <String, int>{};
      final connectionsSnapshot = await _firestore
          .collection('connections')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'accepted')
          .get();

      for (final doc in connectionsSnapshot.docs) {
        final type = doc.data()['connectionType'] as String? ?? 'unknown';
        stats[type] = (stats[type] ?? 0) + 1;
      }

      connectionStats.value = stats;
    } catch (e) {
      print('Error loading connection stats: $e');
    }
  }

  Future<List<BaseUser>> _filterUsers(List<BaseUser> users) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return [];

    final blockedSnapshot = await _firestore
        .collection('blocked_users')
        .where('userId', isEqualTo: currentUserId)
        .get();
    final blockedIds = blockedSnapshot.docs
        .map((doc) => doc.data()['blockedUserId'] as String)
        .where((id) => id.isNotEmpty)
        .toSet();

    return users.where((user) => !blockedIds.contains(user.uid)).toList();
  }

  // ========== ENHANCED SEARCH ==========
  Future<void> searchUsers({String? query, ConnectionType? type}) async {
    try {
      isSearching.value = true;
      selectedConnectionType.value = type;

      final searchQuery = query ?? searchController.text.trim();
      if (searchQuery.isEmpty) {
        searchResults.clear();
        return;
      }

      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return;

      Query queryRef = _firestore.collection('users');

      final snapshot = await queryRef.limit(100).get();
      final blockedSnapshot = await _firestore
          .collection('blocked_users')
          .where('userId', isEqualTo: currentUserId)
          .get();
      final blockedIds = blockedSnapshot.docs
          .map((doc) => doc.data()['blockedUserId'] as String)
          .where((id) => id.isNotEmpty)
          .toSet();

      final connectionsSnapshot = await _firestore
          .collection('connections')
          .where('userId', isEqualTo: currentUserId)
          .where('status', isEqualTo: 'accepted')
          .get();
      final connectedIds = connectionsSnapshot.docs
          .map((doc) => doc.data()['connectedUserId'] as String)
          .where((id) => id.isNotEmpty)
          .toSet();

      final results =
          snapshot.docs
              .map(
                (doc) => createUserFromMap(doc.data() as Map<String, dynamic>),
              )
              .where((user) => user.uid != currentUserId)
              .where((user) => !blockedIds.contains(user.uid))
              .where((user) => !connectedIds.contains(user.uid))
              .where((user) {
                final searchLower = searchQuery.toLowerCase();
                return user.name.toLowerCase().contains(searchLower) ||
                    user.email.toLowerCase().contains(searchLower) ||
                    (user.phoneNumber != null &&
                        user.phoneNumber!.toLowerCase().contains(
                          searchLower,
                        )) ||
                    _checkUserSpecificFields(user, searchLower);
              })
              .toList()
            ..sort((a, b) => a.name.compareTo(b.name));

      searchResults.value = results;
    } catch (e) {
      print('Search error: $e');
      searchResults.clear();
    } finally {
      isSearching.value = false;
    }
  }

  bool _checkUserSpecificFields(BaseUser user, String searchLower) {
    if (user is StudentUser) {
      return (user.schoolName != null &&
              user.schoolName!.toLowerCase().contains(searchLower)) ||
          (user.studentId != null &&
              user.studentId!.toLowerCase().contains(searchLower));
    } else if (user is TeacherUser) {
      return (user.schoolName != null &&
              user.schoolName!.toLowerCase().contains(searchLower)) ||
          (user.teacherId != null &&
              user.teacherId!.toLowerCase().contains(searchLower));
    } else if (user is SchoolAdminUser) {
      return (user.schoolName != null &&
              user.schoolName!.toLowerCase().contains(searchLower)) ||
          (user.schoolCode != null &&
              user.schoolCode!.toLowerCase().contains(searchLower));
    } else if (user is ParentUser) {
      return (user.schoolName != null &&
              user.schoolName!.toLowerCase().contains(searchLower)) ||
          (user.studentName != null &&
              user.studentName!.toLowerCase().contains(searchLower));
    }
    return false;
  }

  void _performSearch() {
    if (searchQuery.value.isEmpty) {
      searchResults.clear();
      return;
    }

    searchUsers(query: searchQuery.value);
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    searchResults.clear();
    selectedConnectionType.value = null;
  }

  // ========== CONNECTION MANAGEMENT ==========
  Future<ConnectionResult> sendConnectionRequest({
    required String receiverId,
    required ConnectionType type,
    String? message,
  }) async {
    try {
      final currentUser = this.currentUser.value;
      if (currentUser == null) {
        return ConnectionResult.error('User not found');
      }

      // REMOVED: All relationship validation restrictions
      // Anyone can connect with anyone now

      final existingRequest = await _firestore
          .collection('connection_requests')
          .where('senderId', isEqualTo: currentUser.uid)
          .where('receiverId', isEqualTo: receiverId)
          .where('status', whereIn: ['pending', 'accepted'])
          .limit(1)
          .get();

      if (existingRequest.docs.isNotEmpty) {
        final request = ConnectionRequest.fromFirestore(
          existingRequest.docs.first.data(),
        );
        switch (request.status) {
          case ConnectionStatus.pending:
            return ConnectionResult.error('Request already sent');
          case ConnectionStatus.accepted:
            return ConnectionResult.error('Already connected');
          default:
            break;
        }
      }

      final receiverDoc = await _firestore
          .collection('users')
          .doc(receiverId)
          .get();
      if (!receiverDoc.exists) {
        return ConnectionResult.error('User not found');
      }

      final receiver = createUserFromMap(receiverDoc.data()!);
      final requestId =
          '${currentUser.uid}_${receiverId}_${DateTime.now().millisecondsSinceEpoch}';

      final request = ConnectionRequest(
        id: requestId,
        senderId: currentUser.uid,
        senderName: currentUser.name,
        senderType: currentUser.userType.name,
        receiverId: receiverId,
        receiverName: receiver.name,
        receiverType: receiver.userType.name,
        type: type,
        message: message?.trim(),
        sentAt: DateTime.now(),
      );

      await _firestore
          .collection('connection_requests')
          .doc(requestId)
          .set(request.toFirestore());

      await _createNotification(
        userId: receiverId,
        title: 'Connection Request',
        body: '${currentUser.name} wants to connect as ${type.displayName}',
        type: 'connection_request',
        data: {'requestId': requestId},
      );

      return ConnectionResult.success();
    } catch (e) {
      print('Send request error: $e');
      return ConnectionResult.error('Failed to send request');
    }
  }

  Future<ValidationResult> _validateConnection(
    BaseUser currentUser,
    String receiverId,
    ConnectionType type,
  ) async {
    // REMOVED: All relationship validation
    // Only basic validation remains

    if (currentUser.uid == receiverId) {
      return ValidationResult.error('Cannot connect to yourself');
    }

    final receiverDoc = await _firestore
        .collection('users')
        .doc(receiverId)
        .get();
    if (!receiverDoc.exists) {
      return ValidationResult.error('User not found');
    }

    final existingConnections = await _checkExistingConnections(
      currentUser.uid,
      receiverId,
      type,
    );
    if (!existingConnections.success) {
      return ValidationResult.error(existingConnections.message!);
    }

    final blockedCheck = await _firestore
        .collection('blocked_users')
        .where('userId', isEqualTo: currentUser.uid)
        .where('blockedUserId', isEqualTo: receiverId)
        .limit(1)
        .get();
    if (blockedCheck.docs.isNotEmpty) {
      return ValidationResult.error('Cannot connect to blocked user');
    }

    return ValidationResult.success();
  }

  Future<ValidationResult> _checkExistingConnections(
    String senderId,
    String receiverId,
    ConnectionType type,
  ) async {
    final mutualConnection = await _firestore
        .collection('connections')
        .where('userId', isEqualTo: senderId)
        .where('connectedUserId', isEqualTo: receiverId)
        .where('status', isEqualTo: 'accepted')
        .limit(1)
        .get();
    if (mutualConnection.docs.isNotEmpty) {
      return ValidationResult.error('Already connected');
    }

    final existingRequest = await _firestore
        .collection('connection_requests')
        .where('senderId', whereIn: [senderId, receiverId])
        .where('receiverId', whereIn: [senderId, receiverId])
        .where('status', whereIn: ['pending', 'accepted'])
        .limit(1)
        .get();

    if (existingRequest.docs.isNotEmpty) {
      final request = ConnectionRequest.fromFirestore(
        existingRequest.docs.first.data(),
      );
      if (request.senderId == senderId) {
        switch (request.status) {
          case ConnectionStatus.pending:
            return ValidationResult.error('Request already sent');
          case ConnectionStatus.accepted:
            return ValidationResult.error('Already connected');
          default:
            break;
        }
      } else {
        switch (request.status) {
          case ConnectionStatus.pending:
            return ValidationResult.error('This user has sent you a request');
          case ConnectionStatus.accepted:
            return ValidationResult.error('Already connected');
          default:
            break;
        }
      }
    }

    // REMOVED: All connection type restrictions
    // Everyone can connect with everyone

    return ValidationResult.success();
  }

  Future<void> respondToConnectionRequest({
    required String requestId,
    required ConnectionStatus response,
    String? rejectionReason,
  }) async {
    try {
      final requestDoc = await _firestore
          .collection('connection_requests')
          .doc(requestId)
          .get();
      if (!requestDoc.exists) {
        throw Exception('Request not found');
      }

      final request = ConnectionRequest.fromFirestore(requestDoc.data()!);
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId != request.receiverId) {
        throw Exception('Unauthorized');
      }

      await _firestore.collection('connection_requests').doc(requestId).update({
        'status': response.name,
        'respondedAt': Timestamp.now(),
        if (rejectionReason != null) 'rejectionReason': rejectionReason,
      });

      if (response == ConnectionStatus.accepted) {
        await _createMutualConnection(request);
        await _createNotification(
          userId: request.senderId,
          title: 'Connection Accepted',
          body: '${request.receiverName} accepted your connection request',
          type: 'connection_accepted',
          data: {'connectionType': request.type.name},
        );
      } else if (response == ConnectionStatus.rejected) {
        await _createNotification(
          userId: request.senderId,
          title: 'Connection Rejected',
          body: '${request.receiverName} rejected your connection request',
          type: 'connection_rejected',
          data: {'rejectionReason': rejectionReason},
        );
      }
    } catch (e) {
      print('Respond to request error: $e');
      rethrow;
    }
  }

  Future<void> removeConnection(
    String connectionId,
    String connectedUserId,
  ) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return;

      await _firestore.collection('connections').doc(connectionId).delete();
      final reverseId = '${connectedUserId}_${currentUserId}';
      await _firestore.collection('connections').doc(reverseId).delete();

      final batch = _firestore.batch();
      final requests = await _firestore
          .collection('connection_requests')
          .where('senderId', whereIn: [currentUserId, connectedUserId])
          .where('receiverId', whereIn: [currentUserId, connectedUserId])
          .where('status', whereIn: ['pending', 'accepted'])
          .get();

      for (final doc in requests.docs) {
        batch.update(doc.reference, {
          'status': 'rejected',
          'respondedAt': Timestamp.now(),
          'rejectionReason': 'Connection removed',
        });
      }

      await batch.commit();
    } catch (e) {
      print('Remove connection error: $e');
      rethrow;
    }
  }

  Future<void> blockUser(String userId) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return;

      await _firestore
          .collection('blocked_users')
          .doc('${currentUserId}_$userId')
          .set({
            'userId': currentUserId,
            'blockedUserId': userId,
            'blockedAt': Timestamp.now(),
            'reason': 'User requested',
          });

      await removeConnection('${currentUserId}_$userId', userId);
      searchResults.removeWhere((user) => user.uid == userId);
      onlineUsers.removeWhere((user) => user.uid == userId);
      connections.removeWhere((user) => user.uid == userId);
    } catch (e) {
      print('Block user error: $e');
      rethrow;
    }
  }

  Future<void> cancelPendingRequest(String requestId) async {
    try {
      final requestDoc = await _firestore
          .collection('connection_requests')
          .doc(requestId)
          .get();
      if (!requestDoc.exists) {
        throw Exception('Request not found');
      }

      final request = ConnectionRequest.fromFirestore(requestDoc.data()!);
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId != request.senderId) {
        throw Exception('Unauthorized');
      }

      await _firestore.collection('connection_requests').doc(requestId).update({
        'status': ConnectionStatus.rejected.name,
        'respondedAt': Timestamp.now(),
        'rejectionReason': 'Request cancelled by sender',
      });

      pendingConnections.removeWhere((user) => user.uid == request.receiverId);
    } catch (e) {
      print('Cancel request error: $e');
      rethrow;
    }
  }

  // ========== STUDY GROUPS ==========
  Future<GroupResult> createStudyGroup({
    required String name,
    required String description,
    required String subject,
    int maxMembers = 50,
  }) async {
    try {
      final currentUser = this.currentUser.value;
      if (currentUser == null) {
        return GroupResult.error('User not found');
      }

      if (name.isEmpty || description.isEmpty || subject.isEmpty) {
        return GroupResult.error('Please fill all fields');
      }

      final groupId =
          'group_${DateTime.now().millisecondsSinceEpoch}_${currentUser.uid}';
      final group = StudyGroup(
        id: groupId,
        name: name.trim(),
        description: description.trim(),
        subject: subject.trim(),
        creatorId: currentUser.uid,
        creatorName: currentUser.name,
        maxMembers: maxMembers,
        createdAt: DateTime.now(),
        memberIds: [currentUser.uid],
      );

      await _firestore
          .collection('study_groups')
          .doc(groupId)
          .set(group.toFirestore());
      groupNameController.clear();
      groupDescriptionController.clear();

      return GroupResult.success(groupId);
    } catch (e) {
      print('Create group error: $e');
      return GroupResult.error('Failed to create group');
    }
  }

  Future<GroupResult> joinStudyGroup(String groupId) async {
    try {
      final currentUser = this.currentUser.value;
      if (currentUser == null) {
        return GroupResult.error('User not found');
      }

      final groupDoc = await _firestore
          .collection('study_groups')
          .doc(groupId)
          .get();
      if (!groupDoc.exists) {
        return GroupResult.error('Group not found');
      }

      final group = StudyGroup.fromFirestore(groupDoc.data()!);
      if (group.memberIds.contains(currentUser.uid)) {
        return GroupResult.error('Already a member');
      }

      if (group.memberIds.length >= group.maxMembers) {
        return GroupResult.error('Group is full');
      }

      await _firestore.collection('study_groups').doc(groupId).update({
        'memberIds': FieldValue.arrayUnion([currentUser.uid]),
        'memberCount': group.memberIds.length + 1,
        'updatedAt': Timestamp.now(),
      });

      await _createNotification(
        userId: group.creatorId,
        title: 'New Group Member',
        body: '${currentUser.name} joined ${group.name}',
        type: 'group_join',
        data: {'groupId': groupId, 'memberId': currentUser.uid},
      );

      return GroupResult.success(groupId);
    } catch (e) {
      print('Join group error: $e');
      return GroupResult.error('Failed to join group');
    }
  }

  Future<void> leaveStudyGroup(String groupId) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return;

      await _firestore.collection('study_groups').doc(groupId).update({
        'memberIds': FieldValue.arrayRemove([currentUserId]),
        'memberCount': FieldValue.increment(-1),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      print('Leave group error: $e');
      rethrow;
    }
  }

  // ========== NOTIFICATIONS ==========
  Future<void> _createNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    try {
      final notificationId =
          '${userId}_${DateTime.now().millisecondsSinceEpoch}';

      await _firestore.collection('notifications').doc(notificationId).set({
        'id': notificationId,
        'userId': userId,
        'title': title,
        'body': body,
        'type': type,
        'data': data ?? {},
        'read': false,
        'createdAt': Timestamp.now(),
      });
    } catch (e) {
      print('Create notification error: $e');
    }
  }

  // ========== USER STATUS ==========
  Future<void> updateUserOnlineStatus(UserOnlineStatus status) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      await _firestore.collection('users').doc(userId).update({
        'onlineStatus': status.name,
        'lastSeen': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      print('Update status error: $e');
    }
  }

  // ========== HELPER METHODS ==========
  List<ConnectionType> getAvailableConnectionTypes() {
    // REMOVED: All restrictions - return all connection types
    return ConnectionType.values.toList();
  }

  String _getTargetUserType(ConnectionType type) {
    switch (type) {
      case ConnectionType.parent:
        return UserType.parent.name;
      case ConnectionType.kidling:
        return UserType.parent.name;
      case ConnectionType.teacher:
        return UserType.teacher.name;
      case ConnectionType.school:
        return UserType.schoolAdmin.name;
      case ConnectionType.student:
      case ConnectionType.classmate:
        return UserType.student.name;
      case ConnectionType.course:
        return 'course';
      case ConnectionType.job:
        return 'job';
    }
  }

  Future<Map<String, dynamic>> getUserConnectionStats(String userId) async {
    final connectionsSnapshot = await _firestore
        .collection('connections')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'accepted')
        .get();

    final stats = <String, int>{};
    for (final doc in connectionsSnapshot.docs) {
      final type = doc.data()['connectionType'] as String? ?? 'unknown';
      stats[type] = (stats[type] ?? 0) + 1;
    }

    return stats;
  }

  Future<bool> canConnectToUser(String userId, ConnectionType type) async {
    final currentUser = this.currentUser.value;
    if (currentUser == null) return false;

    final validation = await _validateConnection(currentUser, userId, type);
    return validation.success;
  }

  void viewUserProfile(String userId) {
    Get.snackbar(
      'Coming Soon',
      'User profile feature will be available soon',
      backgroundColor: Colors.deepPurple,
      colorText: Colors.white,
    );
  }

  void viewConnectionDetails(String userId) {
    Get.snackbar(
      'Coming Soon',
      'Connection details feature will be available soon',
      backgroundColor: Colors.deepPurple,
      colorText: Colors.white,
    );
  }

  String getConnectionTerm(ConnectionType type, bool isSender) {
    switch (type) {
      case ConnectionType.parent:
        return isSender ? 'Parent' : 'Child';
      case ConnectionType.teacher:
        return 'Teacher';
      case ConnectionType.school:
        return 'School';
      case ConnectionType.kidling:
        return 'Kidling';
      case ConnectionType.student:
        return 'Student';
      case ConnectionType.classmate:
        return 'Classmate';
      case ConnectionType.course:
        return 'Course';
      case ConnectionType.job:
        return 'Job';
    }
  }

  // Helper method to get user's connection type based on their user type
  ConnectionType getConnectionTypeForUser(BaseUser user) {
    switch (user.userType) {
      case UserType.student:
        return ConnectionType.student;
      case UserType.kidling:
        return ConnectionType.kidling;
      case UserType.teacher:
        return ConnectionType.teacher;
      case UserType.schoolAdmin:
        return ConnectionType.school;
      case UserType.parent:
        return ConnectionType.parent;
    }
  }

  // Helper method to check if user is online
  bool isUserOnline(BaseUser user) {
    // This would require storing online status in the user document
    // For now, we'll use a placeholder
    return onlineUsers.any((u) => u.uid == user.uid);
  }

  // Helper method to get user's school name
  String? getSchoolName(BaseUser user) {
    if (user is StudentUser) {
      return user.schoolName;
    } else if (user is TeacherUser) {
      return user.schoolName;
    } else if (user is SchoolAdminUser) {
      return user.schoolName;
    } else if (user is ParentUser) {
      return user.schoolName;
    }
    return null;
  }
}

// ========== CONNECTION REQUEST MODEL ==========
class ConnectionRequest {
  final String id;
  final String senderId;
  final String senderName;
  final String senderType;
  final String receiverId;
  final String receiverName;
  final String receiverType;
  final ConnectionType type;
  final String? message;
  final DateTime sentAt;
  final ConnectionStatus status;
  final DateTime? respondedAt;
  final String? rejectionReason;

  ConnectionRequest({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderType,
    required this.receiverId,
    required this.receiverName,
    required this.receiverType,
    required this.type,
    this.message,
    required this.sentAt,
    this.status = ConnectionStatus.pending,
    this.respondedAt,
    this.rejectionReason,
  });

  factory ConnectionRequest.fromFirestore(Map<String, dynamic> data) {
    return ConnectionRequest(
      id: data['id']?.toString() ?? '',
      senderId: data['senderId']?.toString() ?? '',
      senderName: data['senderName']?.toString() ?? '',
      senderType: data['senderType']?.toString() ?? '',
      receiverId: data['receiverId']?.toString() ?? '',
      receiverName: data['receiverName']?.toString() ?? '',
      receiverType: data['receiverType']?.toString() ?? '',
      type: ConnectionType.values.firstWhere(
        (e) => e.name == (data['type']?.toString() ?? 'student'),
        orElse: () => ConnectionType.student,
      ),
      message: data['message']?.toString(),
      sentAt: (data['sentAt'] as Timestamp).toDate(),
      status: ConnectionStatus.values.firstWhere(
        (e) => e.name == (data['status']?.toString() ?? 'pending'),
        orElse: () => ConnectionStatus.pending,
      ),
      respondedAt: data['respondedAt'] != null
          ? (data['respondedAt'] as Timestamp).toDate()
          : null,
      rejectionReason: data['rejectionReason']?.toString(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'senderType': senderType,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'receiverType': receiverType,
      'type': type.name,
      'message': message,
      'sentAt': Timestamp.fromDate(sentAt),
      'status': status.name,
      'respondedAt': respondedAt != null
          ? Timestamp.fromDate(respondedAt!)
          : null,
      'rejectionReason': rejectionReason,
      'createdAt': Timestamp.now(),
    };
  }

  bool get isPending => status == ConnectionStatus.pending;
  bool get isAccepted => status == ConnectionStatus.accepted;
  bool get isRejected => status == ConnectionStatus.rejected;
}

// ========== STUDY GROUP MODEL ==========
class StudyGroup {
  final String id;
  final String name;
  final String description;
  final String subject;
  final String creatorId;
  final String creatorName;
  final List<String> memberIds;
  final int maxMembers;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  StudyGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.subject,
    required this.creatorId,
    required this.creatorName,
    this.memberIds = const [],
    this.maxMembers = 50,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory StudyGroup.fromFirestore(Map<String, dynamic> data) {
    return StudyGroup(
      id: data['id']?.toString() ?? '',
      name: data['name']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      subject: data['subject']?.toString() ?? '',
      creatorId: data['creatorId']?.toString() ?? '',
      creatorName: data['creatorName']?.toString() ?? '',
      memberIds: List<String>.from(data['memberIds'] ?? []),
      maxMembers: data['maxMembers'] ?? 50,
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'subject': subject,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'memberIds': memberIds,
      'maxMembers': maxMembers,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.now(),
    };
  }

  int get memberCount => memberIds.length;
  bool get isFull => memberCount >= maxMembers;
  bool get canJoin => isActive && !isFull;
}

// ========== RESULT CLASSES ==========
class ConnectionResult {
  final bool success;
  final String? error;
  final String? connectionId;

  ConnectionResult._({this.success = false, this.error, this.connectionId});

  factory ConnectionResult.success([String? connectionId]) {
    return ConnectionResult._(success: true, connectionId: connectionId);
  }

  factory ConnectionResult.error(String error) {
    return ConnectionResult._(error: error);
  }
}

class GroupResult {
  final bool success;
  final String? error;
  final String? groupId;

  GroupResult._({this.success = false, this.error, this.groupId});

  factory GroupResult.success([String? groupId]) {
    return GroupResult._(success: true, groupId: groupId);
  }

  factory GroupResult.error(String error) {
    return GroupResult._(error: error);
  }
}

class ValidationResult {
  final bool success;
  final String? message;

  ValidationResult._({this.success = false, this.message});

  factory ValidationResult.success() {
    return ValidationResult._(success: true);
  }

  factory ValidationResult.error(String message) {
    return ValidationResult._(message: message);
  }
}

// ========== CONNECT SCREEN ==========
class ConnectScreen extends StatelessWidget {
  const ConnectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ConnectController>(
      init: ConnectController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: AppBar(
            title: Obx(() {
              final user = controller.currentUser.value;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Connect',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  if (user != null)
                    Text(
                      'Welcome, ${user.name.split(' ').first}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                ],
              );
            }),
            backgroundColor: Colors.deepPurple,
            elevation: 4,
            actions: [
              Obx(() {
                final pendingCount = controller.pendingRequests.length;
                return Stack(
                  children: [
                    IconButton(
                      onPressed: () => _showPendingRequests(controller),
                      icon: const Icon(Icons.notifications_outlined),
                      tooltip: 'Notifications',
                      color: Colors.white,
                    ),
                    if (pendingCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            pendingCount > 9 ? '9+' : pendingCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              }),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await controller._initialize();
            },
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Hero Section
                  _buildHeroSection(controller),
                  const SizedBox(height: 24),

                  // Quick Stats
                  _buildQuickStats(controller),
                  const SizedBox(height: 24),

                  // Pending Connections
                  _buildPendingConnections(controller),

                  // Pending Requests
                  if (controller.pendingRequests.isNotEmpty) ...[
                    _buildPendingRequests(controller),
                    const SizedBox(height: 24),
                  ],

                  // Connection Types
                  _buildConnectionTypes(controller),
                  const SizedBox(height: 24),

                  // Active Study Groups
                  _buildStudyGroups(controller),
                  const SizedBox(height: 24),

                  // Online Now
                  _buildOnlineUsers(controller),
                  const SizedBox(height: 24),

                  // Recent Connections
                  _buildRecentConnections(controller),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // Floating Action Button
          floatingActionButton: _buildFloatingActionButton(controller),
        );
      },
    );
  }

  // ========== HERO SECTION ==========
  Widget _buildHeroSection(ConnectController controller) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade600, Colors.purple.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withOpacity(0.3),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar with Status
            Stack(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Obx(() {
                      final user = controller.currentUser.value;
                      return Text(
                        user?.name.substring(0, 1).toUpperCase() ?? 'U',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      );
                    }),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.green.shade400,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
            // User Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() {
                    final user = controller.currentUser.value;
                    return Text(
                      user?.name ?? 'Loading...',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    );
                  }),
                  const SizedBox(height: 4),
                  Obx(() {
                    final user = controller.currentUser.value;
                    return Text(
                      user?.email ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    );
                  }),
                  const SizedBox(height: 12),
                  Obx(() {
                    final user = controller.currentUser.value;
                    final userType = user?.userType ?? UserType.student;
                    final typeColor = _getUserTypeColor(userType);
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: typeColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getUserTypeIcon(userType),
                            size: 14,
                            color: typeColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            userType.displayName,
                            style: TextStyle(
                              fontSize: 12,
                              color: typeColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== QUICK STATS ==========
  Widget _buildQuickStats(ConnectController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              icon: Icons.people_alt_rounded,
              value: controller.totalConnections.value.toString(),
              label: 'Connections',
              color: Colors.deepPurple,
              onTap: () => _showAllConnections(controller),
            ),
            _buildStatItem(
              icon: Icons.group_rounded,
              value: controller.totalGroups.value.toString(),
              label: 'Groups',
              color: Colors.green,
              onTap: () => _showAllGroups(controller),
            ),
            _buildStatItem(
              icon: Icons.pending_actions_rounded,
              value: controller.totalPending.value.toString(),
              label: 'Pending',
              color: Colors.orange,
              onTap: () => _showPendingConnectionsSheet(controller),
            ),
            _buildStatItem(
              icon: Icons.online_prediction_rounded,
              value: controller.onlineUsers.length.toString(),
              label: 'Online',
              color: Colors.blue,
              onTap: () => _scrollToOnlineUsers(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
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
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  // ========== PENDING CONNECTIONS ==========
  Widget _buildPendingConnections(ConnectController controller) {
    return Obx(() {
      if (controller.pendingConnections.isEmpty) return const SizedBox();
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pending Connections',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () => _showPendingConnectionsSheet(controller),
                  child: const Text(
                    'View All',
                    style: TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.pendingConnections.length,
                itemBuilder: (context, index) {
                  final user = controller.pendingConnections[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index < controller.pendingConnections.length - 1
                          ? 12
                          : 0,
                    ),
                    child: _PendingConnectionCard(
                      user: user,
                      onCancel: () => _cancelPendingRequest(user, controller),
                      onTap: () => controller.viewUserProfile(user.uid),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  // ========== PENDING REQUESTS ==========
  Widget _buildPendingRequests(ConnectController controller) {
    return Obx(() {
      if (controller.pendingRequests.isEmpty) return const SizedBox();
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Connection Requests',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                Badge(
                  label: Text(controller.pendingRequests.length.toString()),
                  backgroundColor: Colors.deepPurple,
                  child: IconButton(
                    onPressed: () => _showPendingRequests(controller),
                    icon: const Icon(Icons.notifications_rounded),
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...controller.pendingRequests.take(2).map((request) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _PendingRequestCard(
                  request: request,
                  onAccept: () => _acceptRequest(request, controller),
                  onReject: () => _rejectRequest(request, controller),
                  onView: () => controller.viewUserProfile(request.senderId),
                ),
              );
            }),
          ],
        ),
      );
    });
  }

  // ========== CONNECTION TYPES ==========
  Widget _buildConnectionTypes(ConnectController controller) {
    final types = controller.getAvailableConnectionTypes();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Connect With',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: types.map((type) {
              return _ConnectionTypeChip(
                type: type,
                onTap: () => _showSearchScreen(controller, type: type),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ========== STUDY GROUPS ==========
  Widget _buildStudyGroups(ConnectController controller) {
    return Obx(() {
      final groups = controller.studyGroups;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Active Study Groups',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  onPressed: () => _showCreateGroupDialog(controller),
                  icon: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add_rounded,
                      color: Colors.deepPurple,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (groups.isEmpty)
              _EmptyStateCard(
                icon: Icons.group_off_rounded,
                title: 'No active groups',
                subtitle: 'Create or join a study group to get started',
                actionText: 'Create Group',
                onAction: () => _showCreateGroupDialog(controller),
              )
            else
              Column(
                children: groups
                    .take(2)
                    .map(
                      (group) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _StudyGroupCard(
                          group: group,
                          onJoin: () => _joinGroup(group, controller),
                          onTap: () => _showGroupDetails(group, controller),
                        ),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      );
    });
  }

  // ========== ONLINE USERS ==========
  Widget _buildOnlineUsers(ConnectController controller) {
    return Obx(() {
      final onlineUsers = controller.onlineUsers;
      if (onlineUsers.isEmpty) return const SizedBox();
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Online Now',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: onlineUsers.length,
                itemBuilder: (context, index) {
                  final user = onlineUsers[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index < onlineUsers.length - 1 ? 12 : 0,
                    ),
                    child: _OnlineUserCard(
                      user: user,
                      onConnect: () => _showConnectDialog(user, controller),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  // ========== RECENT CONNECTIONS ==========
  Widget _buildRecentConnections(ConnectController controller) {
    return Obx(() {
      final connections = controller.connections;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Connections',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            if (connections.isEmpty)
              _EmptyStateCard(
                icon: Icons.person_add_disabled_rounded,
                title: 'No connections yet',
                subtitle: 'Start connecting with people to build your network',
                actionText: 'Find People',
                onAction: () => _showSearchScreen(controller),
                compact: true,
              )
            else
              Column(
                children: connections
                    .take(3)
                    .map(
                      (user) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ConnectionCard(
                          user: user,
                          onTap: () =>
                              controller.viewConnectionDetails(user.uid),
                          onMessage: () => _sendMessage(user, controller),
                        ),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      );
    });
  }

  // ========== FLOATING ACTION BUTTON ==========
  Widget _buildFloatingActionButton(ConnectController controller) {
    return FloatingActionButton.extended(
      onPressed: () => _showQuickConnectMenu(controller),
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      icon: const Icon(Icons.add_rounded),
      label: const Text(
        'Connect',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  // ========== HELPER METHODS ==========
  Color _getUserTypeColor(UserType userType) {
    switch (userType) {
      case UserType.teacher:
        return Colors.blue;
      case UserType.schoolAdmin:
        return Colors.green;
      case UserType.parent:
        return Colors.deepOrange;
      default:
        return Colors.purple;
    }
  }

  IconData _getUserTypeIcon(UserType userType) {
    switch (userType) {
      case UserType.teacher:
        return Icons.school_rounded;
      case UserType.schoolAdmin:
        return Icons.business_rounded;
      case UserType.parent:
        return Icons.family_restroom_rounded;
      default:
        return Icons.person_rounded;
    }
  }

  // ========== DIALOGS AND SHEETS ==========
  void _showPendingRequests(ConnectController controller) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.only(top: 16),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Text(
                    'Connection Requests',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  Obx(() {
                    final count = controller.pendingRequests.length;
                    if (count > 0) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          count.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }
                    return const SizedBox();
                  }),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Obx(() {
                final requests = controller.pendingRequests;
                if (requests.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_off_rounded,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No pending requests',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final request = requests[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _PendingRequestCard(
                        request: request,
                        onAccept: () => _acceptRequest(request, controller),
                        onReject: () => _rejectRequest(request, controller),
                        onView: () =>
                            controller.viewUserProfile(request.senderId),
                      ),
                    );
                  },
                );
              }),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      isScrollControlled: true,
      enableDrag: true,
    );
  }

  void _showPendingConnectionsSheet(ConnectController controller) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.only(top: 16),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    'Pending Connections',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  Spacer(),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Obx(() {
                final pendingUsers = controller.pendingConnections;
                if (pendingUsers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.pending_actions_rounded,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No pending connections',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: pendingUsers.length,
                  itemBuilder: (context, index) {
                    final user = pendingUsers[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _PendingConnectionListCard(
                        user: user,
                        onCancel: () => _cancelPendingRequest(user, controller),
                        onView: () => controller.viewUserProfile(user.uid),
                      ),
                    );
                  },
                );
              }),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      isScrollControlled: true,
      enableDrag: true,
    );
  }

  void _acceptRequest(ConnectionRequest request, ConnectController controller) {
    controller.respondToConnectionRequest(
      requestId: request.id,
      response: ConnectionStatus.accepted,
    );
    Get.snackbar(
      'Connection Accepted',
      'You are now connected with ${request.senderName}',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void _rejectRequest(ConnectionRequest request, ConnectController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Reject Request'),
        content: Text('Reject connection request from ${request.senderName}?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              controller.respondToConnectionRequest(
                requestId: request.id,
                response: ConnectionStatus.rejected,
                rejectionReason: 'Request rejected by user',
              );
              Get.snackbar(
                'Request Rejected',
                'Connection request rejected',
                backgroundColor: Colors.orange,
                colorText: Colors.white,
                duration: const Duration(seconds: 2),
              );
            },
            child: const Text('Reject', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _cancelPendingRequest(BaseUser user, ConnectController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Cancel Request'),
        content: Text('Cancel connection request to ${user.name}?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('No')),
          TextButton(
            onPressed: () async {
              Get.back();
              final requests = await controller._firestore
                  .collection('connection_requests')
                  .where(
                    'senderId',
                    isEqualTo: controller._auth.currentUser!.uid,
                  )
                  .where('receiverId', isEqualTo: user.uid)
                  .where('status', isEqualTo: 'pending')
                  .get();

              if (requests.docs.isNotEmpty) {
                await controller.cancelPendingRequest(requests.docs.first.id);
                Get.snackbar(
                  'Request Cancelled',
                  'Connection request cancelled',
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 2),
                );
              }
            },
            child: const Text('Yes', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showSearchScreen(ConnectController controller, {ConnectionType? type}) {
    Get.to(() => SearchScreen(initialType: type));
  }

  void _showCreateGroupDialog(ConnectController controller) {
    final subjects = ['Math', 'Science', 'English', 'History', 'General'];
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Create Study Group',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: controller.groupNameController,
                  decoration: InputDecoration(
                    labelText: 'Group Name',
                    prefixIcon: const Icon(Icons.group_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller.groupDescriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    prefixIcon: const Icon(Icons.description_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: controller.selectedSubject.value,
                  decoration: InputDecoration(
                    labelText: 'Subject',
                    prefixIcon: const Icon(Icons.subject_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  items: subjects
                      .map(
                        (subject) => DropdownMenuItem(
                          value: subject,
                          child: Text(subject),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) controller.selectedSubject.value = value;
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: Colors.grey.shade300),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Obx(
                        () => ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : () async {
                                  final result = await controller
                                      .createStudyGroup(
                                        name:
                                            controller.groupNameController.text,
                                        description: controller
                                            .groupDescriptionController
                                            .text,
                                        subject:
                                            controller.selectedSubject.value,
                                      );

                                  if (result.success) {
                                    Get.back();
                                    Get.snackbar(
                                      'Success',
                                      'Group created successfully',
                                      backgroundColor: Colors.green,
                                      colorText: Colors.white,
                                    );
                                  } else {
                                    Get.snackbar(
                                      'Error',
                                      result.error ?? 'Failed to create group',
                                      backgroundColor: Colors.red,
                                      colorText: Colors.white,
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
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
                              : const Text('Create'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _joinGroup(
    StudyGroup group,
    ConnectController controller,
  ) async {
    final result = await controller.joinStudyGroup(group.id);
    if (result.success) {
      Get.snackbar(
        'Success',
        'Joined ${group.name} successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Error',
        result.error ?? 'Failed to join group',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _showGroupDetails(StudyGroup group, ConnectController controller) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.group_rounded,
                    color: Colors.deepPurple,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        group.subject,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Description',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              group.description,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Icon(
                  Icons.people_rounded,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  '${group.memberCount}/${group.maxMembers} members',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const Spacer(),
                Icon(
                  Icons.calendar_today_rounded,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  'Created ${_formatDate(group.createdAt)}',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _joinGroup(group, controller),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Join Group'),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showConnectDialog(BaseUser user, ConnectController controller) {
    final availableTypes = controller.getAvailableConnectionTypes();
    final connectionType = controller.getConnectionTypeForUser(user);

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: connectionType.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    user.name.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: connectionType.color,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                user.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user.userType.displayName,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              const Text(
                'Connect as:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: availableTypes.map((type) {
                  return FilterChip(
                    label: Text(type.displayName),
                    selected: false,
                    onSelected: (_) async {
                      Get.back();
                      await _sendConnectionRequestWithType(
                        user,
                        type,
                        controller,
                      );
                    },
                    backgroundColor: type.color.withOpacity(0.1),
                    selectedColor: type.color,
                    labelStyle: TextStyle(color: type.color),
                    avatar: Icon(type.icon, size: 16, color: type.color),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () => Get.back(),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: Colors.grey.shade300),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendConnectionRequestWithType(
    BaseUser user,
    ConnectionType type,
    ConnectController controller,
  ) async {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Send Connection Request',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.connectionMessageController,
                decoration: InputDecoration(
                  labelText: 'Message (optional)',
                  hintText: 'Add a personal message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final result = await controller.sendConnectionRequest(
                          receiverId: user.uid,
                          type: type,
                          message: controller.connectionMessageController.text,
                        );

                        Get.back();
                        controller.connectionMessageController.clear();

                        if (result.success) {
                          Get.snackbar(
                            'Request Sent',
                            'Connection request sent to ${user.name}',
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                            duration: const Duration(seconds: 2),
                          );
                        } else {
                          Get.snackbar(
                            'Error',
                            result.error ?? 'Failed to send request',
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: type.color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'Send as ${type.displayName}',
                        style: const TextStyle(color: Colors.white),
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

  void _showAllConnections(ConnectController controller) {
    Get.snackbar(
      'Coming Soon',
      'All connections view will be available soon',
      backgroundColor: Colors.deepPurple,
      colorText: Colors.white,
    );
  }

  void _showAllGroups(ConnectController controller) {
    Get.snackbar(
      'Coming Soon',
      'All groups view will be available soon',
      backgroundColor: Colors.deepPurple,
      colorText: Colors.white,
    );
  }

  void _scrollToOnlineUsers() {
    // Implementation for scrolling to online users section
  }

  void _showQuickConnectMenu(ConnectController controller) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Quick Connect',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _quickActions.map((action) {
                  return SizedBox(
                    width: (Get.width - 64) / 3,
                    child: _QuickActionGridCard(
                      icon: action.icon,
                      label: action.label,
                      color: action.color,
                      onTap: () => action.onTap(controller),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: OutlinedButton(
                onPressed: () => Get.back(),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: Colors.grey.shade300),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const SizedBox(
                  width: double.infinity,
                  child: Center(child: Text('Close')),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _sendMessage(BaseUser user, ConnectController controller) {
    Get.snackbar(
      'Coming Soon',
      'Messaging feature will be available soon',
      backgroundColor: Colors.deepPurple,
      colorText: Colors.white,
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    if (difference.inDays < 30)
      return '${(difference.inDays / 7).floor()} weeks ago';
    return '${(difference.inDays / 30).floor()} months ago';
  }
}

// ========== UI COMPONENTS ==========

class _PendingConnectionCard extends StatelessWidget {
  final BaseUser user;
  final VoidCallback onCancel;
  final VoidCallback onTap;

  const _PendingConnectionCard({
    required this.user,
    required this.onCancel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ConnectController>();
    final connectionType = controller.getConnectionTypeForUser(user);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: connectionType.color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        user.name.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: connectionType.color,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.pending_rounded,
                        size: 8,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                user.name.split(' ').first,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              IconButton(
                onPressed: onCancel,
                icon: Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: Colors.grey.shade500,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnlineUserCard extends StatelessWidget {
  final BaseUser user;
  final VoidCallback onConnect;

  const _OnlineUserCard({required this.user, required this.onConnect});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ConnectController>();
    final connectionType = controller.getConnectionTypeForUser(user);
    final isOnline = controller.isUserOnline(user);

    return Container(
      width: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => controller.viewUserProfile(user.uid),
            child: Stack(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: connectionType.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Center(
                    child: Text(
                      user.name.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: connectionType.color,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: isOnline ? Colors.green : Colors.grey,
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            user.name.split(' ').first,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: connectionType.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              user.userType.name.substring(0, 1).toUpperCase(),
              style: TextStyle(
                fontSize: 9,
                color: connectionType.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConnectionCard extends StatelessWidget {
  final BaseUser user;
  final VoidCallback onTap;
  final VoidCallback onMessage;

  const _ConnectionCard({
    required this.user,
    required this.onTap,
    required this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ConnectController>();
    final connectionType = controller.getConnectionTypeForUser(user);
    final isOnline = controller.isUserOnline(user);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Stack(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: connectionType.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Center(
                    child: Text(
                      user.name.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: connectionType.color,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: isOnline ? Colors.green : Colors.grey,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.userType.displayName,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  if (user is StudentUser) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Grade ${(user as StudentUser).classGrade ?? 'Unknown'}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: onMessage,
            icon: Icon(
              Icons.message_rounded,
              color: Colors.deepPurple,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

// ========== SEARCH SCREEN ==========
class SearchScreen extends StatelessWidget {
  final ConnectionType? initialType;

  const SearchScreen({super.key, this.initialType});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ConnectController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (initialType != null) {
        controller.selectedConnectionType.value = initialType;
        controller.searchUsers(type: initialType);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          final type = controller.selectedConnectionType.value;
          return Text(
            type != null ? 'Find ${type.displayName}s' : 'Search People',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          );
        }),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        actions: [
          IconButton(
            onPressed: controller.clearSearch,
            icon: const Icon(Icons.clear_all_rounded),
            tooltip: 'Clear all',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(controller),
          _buildTypeFilter(controller),
          Expanded(child: _buildSearchResults(controller)),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ConnectController controller) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Row(
            children: [
              const SizedBox(width: 20),
              const Icon(Icons.search_rounded, color: Colors.grey, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller.searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: controller.selectedConnectionType.value != null
                        ? 'Search ${controller.selectedConnectionType.value!.displayName.toLowerCase()}s...'
                        : 'Search by name, email, or school...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 16,
                    ),
                  ),
                  style: const TextStyle(fontSize: 16),
                  onChanged: (value) {
                    controller.searchQuery.value = value;
                  },
                ),
              ),
              if (controller.searchController.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 20),
                  onPressed: () {
                    controller.clearSearch();
                  },
                ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeFilter(ConnectController controller) {
    final types = controller.getAvailableConnectionTypes();
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: types.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Obx(() {
                final isSelected =
                    controller.selectedConnectionType.value == null;
                return ChoiceChip(
                  label: const Text('All'),
                  selected: isSelected,
                  onSelected: (_) {
                    controller.selectedConnectionType.value = null;
                    controller.searchUsers();
                  },
                  backgroundColor: Colors.grey.shade100,
                  selectedColor: Colors.deepPurple,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                );
              }),
            );
          }

          final type = types[index - 1];
          return Padding(
            padding: EdgeInsets.only(right: index < types.length ? 8 : 0),
            child: Obx(() {
              final isSelected =
                  controller.selectedConnectionType.value == type;
              return ChoiceChip(
                label: Text(type.displayName),
                selected: isSelected,
                onSelected: (_) {
                  controller.selectedConnectionType.value = type;
                  controller.searchUsers(type: type);
                },
                backgroundColor: Colors.grey.shade100,
                selectedColor: type.color,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
                avatar: isSelected
                    ? Icon(type.icon, size: 16, color: Colors.white)
                    : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  Widget _buildSearchResults(ConnectController controller) {
    return Obx(() {
      if (controller.isSearching.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.deepPurple),
              ),
              const SizedBox(height: 16),
              Text(
                'Searching...',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
            ],
          ),
        );
      }

      if (controller.searchQuery.value.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_rounded, size: 80, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                'Start searching',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter a name or keyword to find people',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              ),
            ],
          ),
        );
      }

      if (controller.searchResults.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 80,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 16),
              const Text(
                'No results found',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try different keywords or filters',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: controller.searchResults.length,
        itemBuilder: (context, index) {
          final user = controller.searchResults[index];
          final type =
              controller.selectedConnectionType.value ??
              controller.getConnectionTypeForUser(user);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _SearchResultCard(
              user: user,
              connectionType: type,
              onConnect: () => _showConnectDialog(user, controller),
              onView: () => controller.viewUserProfile(user.uid),
            ),
          );
        },
      );
    });
  }

  void _showConnectDialog(BaseUser user, ConnectController controller) {
    final availableTypes = controller.getAvailableConnectionTypes();
    final connectionType = controller.getConnectionTypeForUser(user);

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: connectionType.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    user.name.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: connectionType.color,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                user.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user.userType.displayName,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              const Text(
                'Connect as:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: availableTypes.map((type) {
                  return FilterChip(
                    label: Text(type.displayName),
                    selected: false,
                    onSelected: (_) async {
                      Get.back();
                      await _sendConnectionRequestWithType(
                        user,
                        type,
                        controller,
                      );
                    },
                    backgroundColor: type.color.withOpacity(0.1),
                    selectedColor: type.color,
                    labelStyle: TextStyle(color: type.color),
                    avatar: Icon(type.icon, size: 16, color: type.color),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () => Get.back(),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: Colors.grey.shade300),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendConnectionRequestWithType(
    BaseUser user,
    ConnectionType type,
    ConnectController controller,
  ) async {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Send Connection Request',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.connectionMessageController,
                decoration: InputDecoration(
                  labelText: 'Message (optional)',
                  hintText: 'Add a personal message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final result = await controller.sendConnectionRequest(
                          receiverId: user.uid,
                          type: type,
                          message: controller.connectionMessageController.text,
                        );

                        Get.back();
                        controller.connectionMessageController.clear();

                        if (result.success) {
                          Get.snackbar(
                            'Request Sent',
                            'Connection request sent to ${user.name}',
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                            duration: const Duration(seconds: 2),
                          );
                        } else {
                          Get.snackbar(
                            'Error',
                            result.error ?? 'Failed to send request',
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: type.color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'Send as ${type.displayName}',
                        style: const TextStyle(color: Colors.white),
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

  void _showAllConnections(ConnectController controller) {
    Get.snackbar(
      'Coming Soon',
      'All connections view will be available soon',
      backgroundColor: Colors.deepPurple,
      colorText: Colors.white,
    );
  }

  void _showAllGroups(ConnectController controller) {
    Get.snackbar(
      'Coming Soon',
      'All groups view will be available soon',
      backgroundColor: Colors.deepPurple,
      colorText: Colors.white,
    );
  }

  void _scrollToOnlineUsers() {
    // Implementation for scrolling to online users section
  }

  void _showQuickConnectMenu(ConnectController controller) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Quick Connect',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _quickActions.map((action) {
                  return SizedBox(
                    width: (Get.width - 64) / 3,
                    child: _QuickActionGridCard(
                      icon: action.icon,
                      label: action.label,
                      color: action.color,
                      onTap: () => action.onTap(controller),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: OutlinedButton(
                onPressed: () => Get.back(),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: Colors.grey.shade300),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const SizedBox(
                  width: double.infinity,
                  child: Center(child: Text('Close')),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _sendMessage(BaseUser user, ConnectController controller) {
    Get.snackbar(
      'Coming Soon',
      'Messaging feature will be available soon',
      backgroundColor: Colors.deepPurple,
      colorText: Colors.white,
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    if (difference.inDays < 30)
      return '${(difference.inDays / 7).floor()} weeks ago';
    return '${(difference.inDays / 30).floor()} months ago';
  }
}

class _SearchResultCard extends StatelessWidget {
  final BaseUser user;
  final ConnectionType connectionType;
  final VoidCallback onConnect;
  final VoidCallback onView;

  const _SearchResultCard({
    required this.user,
    required this.connectionType,
    required this.onConnect,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ConnectController>();
    final schoolName = controller.getSchoolName(user);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            GestureDetector(
              onTap: onView,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: connectionType.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    user.name.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: connectionType.color,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: onView,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          _getUserTypeIcon(user.userType),
                          size: 12,
                          color: connectionType.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          user.userType.displayName,
                          style: TextStyle(
                            fontSize: 13,
                            color: connectionType.color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    if (schoolName != null && schoolName.isNotEmpty)
                      const SizedBox(height: 4),
                    if (schoolName != null && schoolName.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Icons.school_rounded,
                            size: 12,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            schoolName,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Row(
              children: [
                IconButton(
                  onPressed: onView,
                  icon: Icon(
                    Icons.visibility_rounded,
                    color: Colors.deepPurple.shade300,
                    size: 20,
                  ),
                ),
                IconButton(
                  onPressed: onConnect,
                  icon: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: connectionType.color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: connectionType.color.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 20,
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

  IconData _getUserTypeIcon(UserType userType) {
    switch (userType) {
      case UserType.teacher:
        return Icons.school_rounded;
      case UserType.schoolAdmin:
        return Icons.business_rounded;
      case UserType.parent:
        return Icons.family_restroom_rounded;
      default:
        return Icons.person_rounded;
    }
  }
}

// ========== QUICK ACTIONS DATA ==========
class _QuickActionItem {
  final IconData icon;
  final String label;
  final Color color;
  final Function(ConnectController) onTap;

  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

final List<_QuickActionItem> _quickActions = [
  _QuickActionItem(
    icon: Icons.search_rounded,
    label: 'Find People',
    color: Colors.deepPurple,
    onTap: (controller) {
      Get.back();
      Get.to(() => SearchScreen());
    },
  ),
  _QuickActionItem(
    icon: Icons.group_add_rounded,
    label: 'Create Group',
    color: Colors.green,
    onTap: (controller) {
      Get.back();
      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Create Study Group',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: controller.groupNameController,
                  decoration: InputDecoration(
                    labelText: 'Group Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller.groupDescriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Obx(
                        () => ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : () async {
                                  final result = await controller
                                      .createStudyGroup(
                                        name:
                                            controller.groupNameController.text,
                                        description: controller
                                            .groupDescriptionController
                                            .text,
                                        subject: 'General',
                                      );

                                  if (result.success) {
                                    Get.back();
                                    Get.snackbar(
                                      'Success',
                                      'Group created successfully',
                                      backgroundColor: Colors.green,
                                      colorText: Colors.white,
                                    );
                                  } else {
                                    Get.snackbar(
                                      'Error',
                                      result.error ?? 'Failed to create group',
                                      backgroundColor: Colors.red,
                                      colorText: Colors.white,
                                    );
                                  }
                                },
                          child: controller.isLoading.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Create'),
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
    },
  ),
  _QuickActionItem(
    icon: Icons.pending_actions_rounded,
    label: 'Requests',
    color: Colors.orange,
    onTap: (controller) {
      Get.back();
      controller.pendingRequests.isNotEmpty
          ? _showPendingRequests(controller)
          : Get.snackbar(
              'No Requests',
              'You have no pending requests',
              backgroundColor: Colors.deepPurple,
              colorText: Colors.white,
            );
    },
  ),
  _QuickActionItem(
    icon: Icons.people_alt_rounded,
    label: 'Connections',
    color: Colors.purple,
    onTap: (controller) {
      Get.back();
      Get.snackbar(
        'Coming Soon',
        'Connections list will be available soon',
        backgroundColor: Colors.purple,
        colorText: Colors.white,
      );
    },
  ),
];

// ========== OTHER UI COMPONENTS ==========

class _PendingRequestCard extends StatelessWidget {
  final ConnectionRequest request;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onView;

  const _PendingRequestCard({
    required this.request,
    required this.onAccept,
    required this.onReject,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(request.type.icon, color: request.type.color, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${request.type.displayName} Request',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _formatTimeAgo(request.sentAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onView,
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: request.type.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Center(
                    child: Text(
                      request.senderName.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: request.type.color,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.senderName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Wants to connect as ${request.type.displayName}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (request.message != null && request.message!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: request.type.color.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                request.message!,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_rounded, size: 18),
                      SizedBox(width: 8),
                      Text('Accept'),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: onReject,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.close_rounded, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Reject', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays > 0) return '${difference.inDays}d ago';
    if (difference.inHours > 0) return '${difference.inHours}h ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
    return 'Just now';
  }
}

class _ConnectionTypeChip extends StatelessWidget {
  final ConnectionType type;
  final VoidCallback onTap;

  const _ConnectionTypeChip({required this.type, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: type.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: type.color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(type.icon, size: 18, color: type.color),
            const SizedBox(width: 8),
            Text(
              type.displayName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: type.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudyGroupCard extends StatelessWidget {
  final StudyGroup group;
  final VoidCallback onJoin;
  final VoidCallback onTap;

  const _StudyGroupCard({
    required this.group,
    required this.onJoin,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: group.isActive
                      ? Colors.green.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.group_rounded,
                  color: group.isActive ? Colors.green : Colors.grey,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      group.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
                          '${group.memberCount}/${group.maxMembers} members',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            group.subject,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.deepPurple,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: group.canJoin ? onJoin : null,
                icon: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: group.canJoin
                        ? Colors.deepPurple
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: group.canJoin
                        ? [
                            BoxShadow(
                              color: Colors.deepPurple.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    group.canJoin ? Icons.add_rounded : Icons.lock_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionText;
  final VoidCallback? onAction;
  final bool compact;

  const _EmptyStateCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionText,
    this.onAction,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: compact ? const EdgeInsets.all(20) : const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: compact ? 48 : 56, color: Colors.grey.shade300),
          SizedBox(height: compact ? 12 : 16),
          Text(
            title,
            style: TextStyle(
              fontSize: compact ? 16 : 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: compact ? 4 : 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: compact ? 12 : 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          if (actionText != null && onAction != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(actionText!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuickActionGridCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionGridCard({
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PendingConnectionListCard extends StatelessWidget {
  final BaseUser user;
  final VoidCallback onCancel;
  final VoidCallback onView;

  const _PendingConnectionListCard({
    required this.user,
    required this.onCancel,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
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
                color: Colors.orange.shade50,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  user.name.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${user.userType}",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: onView,
                  icon: Icon(
                    Icons.visibility_rounded,
                    color: Colors.deepPurple,
                    size: 20,
                  ),
                ),
                IconButton(
                  onPressed: onCancel,
                  icon: Icon(Icons.close_rounded, color: Colors.red, size: 20),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ========== BINDINGS ==========
class ConnectBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ConnectController());
  }
}

// Helper function to show pending requests
void _showPendingRequests(ConnectController controller) {
  Get.bottomSheet(
    Container(
      height: Get.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Pending Requests',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            child: Obx(() {
              final requests = controller.pendingRequests;
              if (requests.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 80,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No pending requests',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final request = requests[index];
                  return _PendingRequestCard(
                    request: request,
                    onAccept: () => controller.respondToConnectionRequest(
                      requestId: request.id,
                      response: ConnectionStatus.accepted,
                    ),
                    onReject: () => controller.respondToConnectionRequest(
                      requestId: request.id,
                      response: ConnectionStatus.rejected,
                    ),
                    onView: () => controller.viewUserProfile(request.senderId),
                  );
                },
              );
            }),
          ),
        ],
      ),
    ),
    isScrollControlled: true,
  );
}

extension NigerianSystemOnConnectController on ConnectController {
  // Update the getConnectedClassmates method for Nigerian system
  Future<List<Map<String, dynamic>>> getConnectedClassmatesNigerian() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return [];

      final connections = await _firestore
          .collection('connections')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'accepted')
          .get();

      // Filter for student connections
      final studentConnections = connections.docs.where((doc) {
        final data = doc.data();
        final userType = data['userType']?.toString() ?? '';
        return userType == 'student';
      }).toList();

      final classmateIds = studentConnections
          .map((doc) => doc.data()['connectedUserId'] as String?)
          .where((id) => id != null && id.isNotEmpty)
          .cast<String>()
          .toSet()
          .toList();

      if (classmateIds.isEmpty) return [];

      final classmates = await Future.wait(
        classmateIds.map((id) async {
          try {
            final doc = await _firestore.collection('users').doc(id).get();
            if (doc.exists) {
              final user = createUserFromMap(doc.data()!);
              if (user is StudentUser) {
                return {
                  'userId': id,
                  'name': user.name,
                  'classGrade': _parseNigerianClass(user),
                  'schoolName': user.schoolName ?? 'Unknown School',
                  'profileImageUrl': user.profileImageUrl,
                  'email': user.email,
                  'phone': user.phoneNumber ?? '',
                };
              }
            }
          } catch (e) {
            print('Error fetching classmate $id: $e');
          }
          return null;
        }),
      );

      final validClassmates = classmates
          .whereType<Map<String, dynamic>>()
          .toList();

      // Group by Nigerian class system
      final classesMap = <String, Map<String, dynamic>>{};

      for (final classmate in validClassmates) {
        final className = classmate['classGrade'] as String? ?? 'Unknown';
        final classKey = className.trim();

        if (!classesMap.containsKey(classKey)) {
          classesMap[classKey] = {
            'id': classKey,
            'name': className,
            'level': _getClassLevel(className),
            'teacher': 'To be assigned',
            'students': 1,
            'room': 'Room ${_generateNigerianRoomNumber(className)}',
            'schedule': 'Mon-Fri, 8:00 AM - 3:00 PM',
            'color': _getColorForNigerianClass(className),
            'icon': _getClassIcon(className),
            'classmates': [classmate],
          };
        } else {
          final existingClass = classesMap[classKey]!;
          existingClass['students'] = (existingClass['students'] as int) + 1;
          (existingClass['classmates'] as List).add(classmate);
        }
      }

      return classesMap.values.toList();
    } catch (e) {
      print('Error in getConnectedClassmatesNigerian: $e');
      return [];
    }
  }

  String _parseNigerianClass(StudentUser user) {
    if (user.classGrade == null) return 'Unknown';

    final grade = user.classGrade!;
    if (grade <= 6) return 'Primary $grade';
    if (grade <= 9) return 'JSS ${grade - 6}';
    return 'SSS ${grade - 9}';
  }

  String _getClassLevel(String className) {
    if (className.contains('Primary')) return 'Basic Education';
    if (className.contains('JSS')) return 'Junior Secondary';
    if (className.contains('SSS')) return 'Senior Secondary';
    return 'Unknown';
  }

  IconData _getClassIcon(String className) {
    if (className.contains('Primary')) return Icons.child_care_rounded;
    if (className.contains('JSS')) return Icons.school_rounded;
    if (className.contains('SSS')) return Icons.school_rounded;
    return Icons.class_rounded;
  }

  int _generateNigerianRoomNumber(String className) {
    if (className.contains('Primary')) return 100 + (className.hashCode % 50);
    if (className.contains('JSS')) return 200 + (className.hashCode % 50);
    if (className.contains('SSS')) return 300 + (className.hashCode % 50);
    return 400 + (className.hashCode % 50);
  }

  Color _getColorForNigerianClass(String className) {
    if (className.contains('Primary')) return Colors.blue;
    if (className.contains('JSS')) return Colors.green;
    if (className.contains('SSS')) return Colors.purple;
    return Colors.grey;
  }

  // Update connection request to include school info
  Future<ConnectionResult> sendSchoolConnectionRequest({
    required String receiverId,
    required ConnectionType type,
    String? schoolId,
    String? schoolName,
    String? message,
  }) async {
    final result = await sendConnectionRequest(
      receiverId: receiverId,
      type: type,
      message: message,
    );

    if (result.success) {
      // Add school info to connection
      await _firestore
          .collection('connection_requests')
          .where('senderId', isEqualTo: _auth.currentUser!.uid)
          .where('receiverId', isEqualTo: receiverId)
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get()
          .then((snapshot) {
            if (snapshot.docs.isNotEmpty) {
              snapshot.docs.first.reference.update({
                'schoolId': schoolId,
                'schoolName': schoolName,
                'updatedAt': Timestamp.now(),
              });
            }
          });
    }

    return result;
  }
}
