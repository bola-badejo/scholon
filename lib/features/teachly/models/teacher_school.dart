import 'dart:io';

import 'package:chewie/chewie.dart';
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

class TeacherSchool {
  final String schoolId;
  final String schoolName;
  final String schoolCode;
  final NigerianPosition position;
  final List<String> assignedClasses;
  final bool isActive;
  final DateTime joinedDate;

  TeacherSchool({
    required this.schoolId,
    required this.schoolName,
    required this.schoolCode,
    required this.position,
    required this.assignedClasses,
    required this.isActive,
    required this.joinedDate,
  });
}
