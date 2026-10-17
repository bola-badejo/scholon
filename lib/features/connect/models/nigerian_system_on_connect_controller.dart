import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:isapp/features/auth/models/user.dart';
import 'package:isapp/features/connect/controllers/connect_controller.dart';
import 'package:isapp/features/connect/models/connection_result.dart';
import 'package:isapp/features/connect/models/connection_type.dart';

extension NigerianSystemOnConnectController on ConnectController {

  Future<List<Map<String, dynamic>>> getConnectedClassmatesNigerian() async {
    try {
      final userId = firebaseAuth.currentUser?.uid;
      if (userId == null) return [];

      final connections = await firestoreDb
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
            final doc = await firestoreDb.collection('users').doc(id).get();
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
      await firestoreDb
          .collection('connection_requests')
          .where('senderId', isEqualTo: firebaseAuth.currentUser!.uid)
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
