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

enum ClassType {
  school('School Class', Icons.school_rounded, Colors.blue),
  personal('Personal Class', Icons.person_rounded, Colors.green),
  group('Study Group', Icons.group_rounded, Colors.orange);

  final String displayName;
  final IconData icon;
  final Color color;

  const ClassType(this.displayName, this.icon, this.color);
}
