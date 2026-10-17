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
import 'package:isapp/features/teachly/models/content_type.dart';

class ClassContent {
  final String id;
  final String classId;
  final String teacherId;
  final String title;
  final String description;
  final ContentType type;
  final DateTime createdAt;
  final DateTime? dueDate;
  final int? points;
  final Map<String, dynamic> contentData;
  final List<String> attachments;
  final bool isPublished;
  final int viewCount;
  final int submissionCount;

  ClassContent({
    required this.id,
    required this.classId,
    required this.teacherId,
    required this.title,
    required this.description,
    required this.type,
    required this.createdAt,
    this.dueDate,
    this.points,
    this.contentData = const {},
    this.attachments = const [],
    this.isPublished = false,
    this.viewCount = 0,
    this.submissionCount = 0,
  });

  factory ClassContent.fromMap(Map<String, dynamic> map) {
    return ClassContent(
      id: map['id'] ?? '',
      classId: map['classId'] ?? '',
      teacherId: map['teacherId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      type: ContentType.values.firstWhere(
        (e) => e.name == (map['type'] ?? 'note'),
        orElse: () => ContentType.note,
      ),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      dueDate: map['dueDate'] != null
          ? (map['dueDate'] as Timestamp).toDate()
          : null,
      points: map['points'],
      contentData: Map<String, dynamic>.from(map['contentData'] ?? {}),
      attachments: List<String>.from(map['attachments'] ?? []),
      isPublished: map['isPublished'] ?? false,
      viewCount: map['viewCount'] ?? 0,
      submissionCount: map['submissionCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'classId': classId,
      'teacherId': teacherId,
      'title': title,
      'description': description,
      'type': type.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'points': points,
      'contentData': contentData,
      'attachments': attachments,
      'isPublished': isPublished,
      'viewCount': viewCount,
      'submissionCount': submissionCount,
      'updatedAt': Timestamp.now(),
    };
  }

  bool get isAssignment => type == ContentType.assignment;
  bool get isTestOrExam => type == ContentType.test || type == ContentType.exam;
  bool get isPastDue => dueDate != null && dueDate!.isBefore(DateTime.now());
  bool get hasAttachments => attachments.isNotEmpty;
}
