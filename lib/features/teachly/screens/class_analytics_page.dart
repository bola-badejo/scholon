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
import 'package:isapp/features/teachly/models/teacher_class.dart';

class ClassAnalyticsPage extends StatelessWidget {
  final TeacherClass classItem;

  const ClassAnalyticsPage({super.key, required this.classItem});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${classItem.title} Analytics')),
      body: const Center(child: Text('Class Analytics Page')),
    );
  }
}
