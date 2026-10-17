import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import 'package:isapp/features/auth/models/user.dart';
import 'package:isapp/features/connect/screens/connect_screen.dart';
import 'package:isapp/features/teachly/models/class_content.dart';

class AssignmentViewPage extends StatelessWidget {
  final ClassContent content;

  const AssignmentViewPage({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(content.title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            content.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            content.description,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 20),

          // Assignment details
          _buildDetailItem(
            icon: Icons.score_rounded,
            label: 'Points',
            value: '${content.points ?? 0}',
          ),
          if (content.dueDate != null)
            _buildDetailItem(
              icon: Icons.calendar_today_rounded,
              label: 'Due Date',
              value: DateFormat(
                'MMM dd, yyyy - HH:mm',
              ).format(content.dueDate!),
            ),
          _buildDetailItem(
            icon: Icons.visibility_rounded,
            label: 'Submissions',
            value: '${content.submissionCount}',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
    );
  }
}
