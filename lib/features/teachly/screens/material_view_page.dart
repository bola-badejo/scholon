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
import 'package:isapp/features/teachly/models/class_content.dart';

class MaterialViewPage extends StatelessWidget {
  final ClassContent content;

  const MaterialViewPage({super.key, required this.content});

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

          // Download buttons for attachments
          if (content.attachments.isNotEmpty) ...[
            const Text(
              'Attachments:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ...content.attachments.map((url) {
              return ListTile(
                leading: const Icon(Icons.attach_file_rounded),
                title: Text(_getFileNameFromUrl(url)),
                trailing: IconButton(
                  icon: const Icon(Icons.download_rounded),
                  onPressed: () => _downloadFile(url),
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }

  String _getFileNameFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final path = uri.path;
      return path.split('/').last;
    } catch (e) {
      return 'File';
    }
  }

  void _downloadFile(String url) async {
    // Implementation for file download
    // You can use url_launcher or downloader package
    Get.snackbar('Download', 'Starting download...');
  }
}
