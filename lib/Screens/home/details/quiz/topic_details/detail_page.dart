import 'package:flutter/material.dart';

import '../../../../../Models/courses.dart';
import 'detail_body.dart';

class TopicDetailScreen extends StatelessWidget {
  final List<Topic> topic;
  final int index;
  final Course course;
  const TopicDetailScreen(
      {super.key, required this.topic, required this.index, required this.course});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: DetailBody(course: course, topic: topic, material: course.topics[index].materials),
    );
  }
}