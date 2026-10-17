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

class CreateExamPage extends StatelessWidget {
  const CreateExamPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Similar to CreateTestPage but with additional exam-specific features
    return Scaffold(
      appBar: AppBar(title: const Text('Create Exam')),
      body: const Center(child: Text('Exam Creation Page')),
    );
  }
}
