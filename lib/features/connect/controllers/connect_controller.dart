import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:isapp/features/auth/models/user.dart';
import 'package:isapp/features/connect/models/connection_request.dart';
import 'package:isapp/features/connect/models/connection_result.dart';
import 'package:isapp/features/connect/models/connection_status.dart';
import 'package:isapp/features/connect/models/connection_type.dart';
import 'package:isapp/features/connect/models/group_result.dart';
import 'package:isapp/features/connect/models/nigerian_system_on_connect_controller.dart';
import 'package:isapp/features/connect/models/study_group.dart';
import 'package:isapp/features/connect/models/user_online_status.dart';
import 'package:isapp/features/connect/models/validation_result.dart';

// ========== ENHANCED CONNECTION CONTROLLER ==========
class ConnectController extends GetxController {
  // Firebase instances
  final FirebaseFirestore firestoreDb = FirebaseFirestore.instance;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

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
    reinitialize();

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
  Future<void> reinitialize() async {
    try {
      final user = firebaseAuth.currentUser;
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
        final doc = await firestoreDb.collection(collection).doc(userId).get();
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
    _userSubscription = firestoreDb
        .collection('users')
        .doc(userId)
        .snapshots()
        .listen((snapshot) {
          if (snapshot.exists) {
            currentUser.value = createUserFromMap(snapshot.data()!);
          }
        });

    // Incoming connection requests
    _requestsSubscription = firestoreDb
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
    _pendingSentSubscription = firestoreDb
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
    _connectionsSubscription = firestoreDb
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
    _onlineUsersSubscription = firestoreDb
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
    _groupsSubscription = firestoreDb
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
      final userId = firebaseAuth.currentUser?.uid;
      if (userId == null) return [];

      // Try to get from connections
      final connections = await firestoreDb
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
              final doc = await firestoreDb
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
      final userId = firebaseAuth.currentUser?.uid;
      if (userId == null) return [];

      final connections = await firestoreDb
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
              final doc = await firestoreDb
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
        final snapshot = await firestoreDb.collection(collection).get();

        for (final doc in snapshot.docs) {
          final userId = doc.id;
          final userType = collection.replaceAll('_details', '');

          // Create connection document if it doesn't exist
          final existingConnections = await firestoreDb
              .collection('connections')
              .doc(userId)
              .get();

          if (!existingConnections.exists) {
            await firestoreDb.collection('connections').doc(userId).set({
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
      await firestoreDb.collection('connections').doc(request.senderId).update({
        'connectedUsers': FieldValue.arrayUnion([request.receiverId]),
        '${request.type.name}s': FieldValue.arrayUnion([request.receiverId]),
        'updatedAt': now,
      });

      // For receiver
      await firestoreDb.collection('connections').doc(request.receiverId).update(
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
      final userId = firebaseAuth.currentUser?.uid;
      if (userId == null) return [];

      final connections = await firestoreDb
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
              final doc = await firestoreDb
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
      final userId = firebaseAuth.currentUser?.uid;
      if (userId == null) return [];

      final connections = await firestoreDb
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
              final doc = await firestoreDb
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
      final userId = firebaseAuth.currentUser?.uid;
      if (userId == null) return {};

      final connections = await firestoreDb
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
          final doc = await firestoreDb.collection('users').doc(id).get();
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
          final doc = await firestoreDb.collection('users').doc(id).get();
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
          final doc = await firestoreDb.collection('users').doc(id).get();
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
      final userId = firebaseAuth.currentUser?.uid;
      if (userId == null) return;

      final stats = <String, int>{};
      final connectionsSnapshot = await firestoreDb
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
    final currentUserId = firebaseAuth.currentUser?.uid;
    if (currentUserId == null) return [];

    final blockedSnapshot = await firestoreDb
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

      final currentUserId = firebaseAuth.currentUser?.uid;
      if (currentUserId == null) return;

      Query queryRef = firestoreDb.collection('users');

      final snapshot = await queryRef.limit(100).get();
      final blockedSnapshot = await firestoreDb
          .collection('blocked_users')
          .where('userId', isEqualTo: currentUserId)
          .get();
      final blockedIds = blockedSnapshot.docs
          .map((doc) => doc.data()['blockedUserId'] as String)
          .where((id) => id.isNotEmpty)
          .toSet();

      final connectionsSnapshot = await firestoreDb
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

      final existingRequest = await firestoreDb
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

      final receiverDoc = await firestoreDb
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

      await firestoreDb
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

    final receiverDoc = await firestoreDb
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

    final blockedCheck = await firestoreDb
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
    final mutualConnection = await firestoreDb
        .collection('connections')
        .where('userId', isEqualTo: senderId)
        .where('connectedUserId', isEqualTo: receiverId)
        .where('status', isEqualTo: 'accepted')
        .limit(1)
        .get();
    if (mutualConnection.docs.isNotEmpty) {
      return ValidationResult.error('Already connected');
    }

    final existingRequest = await firestoreDb
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
      final requestDoc = await firestoreDb
          .collection('connection_requests')
          .doc(requestId)
          .get();
      if (!requestDoc.exists) {
        throw Exception('Request not found');
      }

      final request = ConnectionRequest.fromFirestore(requestDoc.data()!);
      final currentUserId = firebaseAuth.currentUser?.uid;
      if (currentUserId != request.receiverId) {
        throw Exception('Unauthorized');
      }

      await firestoreDb.collection('connection_requests').doc(requestId).update({
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
      final currentUserId = firebaseAuth.currentUser?.uid;
      if (currentUserId == null) return;

      await firestoreDb.collection('connections').doc(connectionId).delete();
      final reverseId = '${connectedUserId}_${currentUserId}';
      await firestoreDb.collection('connections').doc(reverseId).delete();

      final batch = firestoreDb.batch();
      final requests = await firestoreDb
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
      final currentUserId = firebaseAuth.currentUser?.uid;
      if (currentUserId == null) return;

      await firestoreDb
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
      final requestDoc = await firestoreDb
          .collection('connection_requests')
          .doc(requestId)
          .get();
      if (!requestDoc.exists) {
        throw Exception('Request not found');
      }

      final request = ConnectionRequest.fromFirestore(requestDoc.data()!);
      final currentUserId = firebaseAuth.currentUser?.uid;
      if (currentUserId != request.senderId) {
        throw Exception('Unauthorized');
      }

      await firestoreDb.collection('connection_requests').doc(requestId).update({
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

      await firestoreDb
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

      final groupDoc = await firestoreDb
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

      await firestoreDb.collection('study_groups').doc(groupId).update({
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
      final currentUserId = firebaseAuth.currentUser?.uid;
      if (currentUserId == null) return;

      await firestoreDb.collection('study_groups').doc(groupId).update({
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

      await firestoreDb.collection('notifications').doc(notificationId).set({
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
      final userId = firebaseAuth.currentUser?.uid;
      if (userId == null) return;

      await firestoreDb.collection('users').doc(userId).update({
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
    final connectionsSnapshot = await firestoreDb
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
