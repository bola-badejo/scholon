import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:isapp/features/auth/models/user.dart';
import 'package:isapp/features/connect/models/nigerian_system_on_connect_controller.dart';

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
