import 'package:flutter/material.dart';
import '../../../../../Models/courses.dart';
import 'detail_body.dart';

class TopicDetailScreen extends StatelessWidget {
  final List<Topic> topic;
  final int index;
  final Course course;
  const TopicDetailScreen({
    super.key, 
    required this.topic, 
    required this.index, 
    required this.course
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Chapter ${index + 1}',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: DetailBody(
        course: course, 
        material: topic.isNotEmpty ? topic[0].materials : Materials(notes: [], tests: [], videos: [], audios: []), 
        topic: topic
      ),
    );
  }
}