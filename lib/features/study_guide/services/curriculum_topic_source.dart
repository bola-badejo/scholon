import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:isapp/data/library/new_courses.dart';
import 'package:isapp/features/learning/controllers/scholon_curriculum_planner_adapter.dart';
import 'package:isapp/features/study_guide/models/study_topic.dart';

/// Turns the curriculum JSON into a flat, ordered list of study topics.
class CurriculumTopicSource {
  static Future<List<StudyTopic>> load() async {
    try {
      final parsed = jsonDecode(Courses.ss3Curriculum.trim());
      final map = parsed is List ? parsed.first : parsed;
      final curriculum = ScholonCurriculumAdapter.adaptFromJson(map);
      final out = <StudyTopic>[];
      for (final course in curriculum.courses) {
        var order = 0;
        for (final term in course.terms) {
          for (final week in term.weeks) {
            order++;
            final minutes = week.notes.isEmpty ? 25 : 20 + week.notes.length * 5;
            out.add(StudyTopic(
              key: '${course.courseCode}|${term.id}|W${week.weekNumber}',
              courseCode: course.courseCode,
              subject: course.name,
              title: week.topic,
              order: order,
              estimatedMinutes: minutes.clamp(15, 45),
              meta: {'termId': term.id, 'weekNumber': week.weekNumber, 'courseId': course.id},
            ));
          }
        }
      }
      return out;
    } catch (e) {
      debugPrint('CurriculumTopicSource failed: $e');
      return const [];
    }
  }
}
