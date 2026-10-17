import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:isapp/features/auth/models/user.dart';
import 'package:isapp/features/home/widgets/fullscreen/course_card.dart';
import 'package:isapp/features/study_guide/study_guide.dart';

class FullScreenToolsCard extends StatelessWidget {
  final List<Map<String, String>> toolItems;

  const FullScreenToolsCard({Key? key, required this.toolItems})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tools')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: toolItems.length,
        itemBuilder: (context, index) {
          final item = toolItems[index];
          return Card(
            child: ListTile(
              title: Text(item['title']!),
              subtitle: item['subtitle'] != null
                  ? Text(item['subtitle']!)
                  : null,
              onTap: () {
                // Handle tool navigation
              },
            ),
          );
        },
      ),
    );
  }
}
