import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import 'package:isapp/features/auth/models/user.dart';
import 'package:isapp/features/connect/screens/connect_screen.dart';
import 'package:isapp/features/school/screens/faculty.dart';
import 'package:isapp/features/teachly/models/class_type.dart';

class TeacherClass {
  final String id;
  final String teacherId;
  final String title;
  final String description;
  final String subject;
  final NigerianClass? gradeLevel;
  final ClassType type;
  final String? schoolId;
  final String? schoolName;
  final int maxStudents;
  final int currentStudents;
  final List<String> studentIds;
  final List<String> contentIds;
  final DateTime createdAt;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;
  final String joinCode;

  TeacherClass({
    required this.id,
    required this.teacherId,
    required this.title,
    required this.description,
    required this.subject,
    this.gradeLevel,
    required this.type,
    this.schoolId,
    this.schoolName,
    this.maxStudents = 50,
    this.currentStudents = 0,
    this.studentIds = const [],
    this.contentIds = const [],
    required this.createdAt,
    this.startDate,
    this.endDate,
    this.isActive = true,
    required this.joinCode,
  });

  factory TeacherClass.fromMap(Map<String, dynamic> map) {
    return TeacherClass(
      id: map['id'] ?? '',
      teacherId: map['teacherId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      subject: map['subject'] ?? '',
      gradeLevel: map['gradeLevel'] != null
          ? NigerianClass.values.firstWhere(
              (e) => e.displayName == map['gradeLevel'],
              orElse: () => NigerianClass.primary1,
            )
          : null,
      type: ClassType.values.firstWhere(
        (e) => e.name == (map['type'] ?? 'personal'),
        orElse: () => ClassType.personal,
      ),
      schoolId: map['schoolId'],
      schoolName: map['schoolName'],
      maxStudents: map['maxStudents'] ?? 50,
      currentStudents: map['currentStudents'] ?? 0,
      studentIds: List<String>.from(map['studentIds'] ?? []),
      contentIds: List<String>.from(map['contentIds'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      startDate: map['startDate'] != null
          ? (map['startDate'] as Timestamp).toDate()
          : null,
      endDate: map['endDate'] != null
          ? (map['endDate'] as Timestamp).toDate()
          : null,
      isActive: map['isActive'] ?? true,
      joinCode: map['joinCode'] ?? generateJoinCode(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'teacherId': teacherId,
      'title': title,
      'description': description,
      'subject': subject,
      'gradeLevel': gradeLevel?.displayName,
      'type': type.name,
      'schoolId': schoolId,
      'schoolName': schoolName,
      'maxStudents': maxStudents,
      'currentStudents': currentStudents,
      'studentIds': studentIds,
      'contentIds': contentIds,
      'createdAt': Timestamp.fromDate(createdAt),
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'isActive': isActive,
      'joinCode': joinCode,
      'updatedAt': Timestamp.now(),
    };
  }

  static String generateJoinCode() {
    final chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().microsecondsSinceEpoch;
    final code = StringBuffer();

    for (var i = 0; i < 6; i++) {
      final index = (random + i) % chars.length;
      code.write(chars[index]);
    }

    return code.toString();
  }

  bool get isSchoolClass => type == ClassType.school;
  bool get isPersonalClass => type == ClassType.personal;
  bool get isStudyGroup => type == ClassType.group;
  bool get hasCapacity => currentStudents < maxStudents;
}
