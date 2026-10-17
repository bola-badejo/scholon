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

enum ContentType {
  note('Note', Icons.note_rounded, Colors.blue),
  material('Material', Icons.description_rounded, Colors.green),
  video('Video', Icons.video_library_rounded, Colors.red),
  assignment('Assignment', Icons.assignment_rounded, Colors.orange),
  test('Test', Icons.quiz_rounded, Colors.purple),
  exam('Exam', Icons.assignment_turned_in_rounded, Colors.deepPurple);

  final String displayName;
  final IconData icon;
  final Color color;

  const ContentType(this.displayName, this.icon, this.color);
}
