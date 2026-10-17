import 'package:isapp/features/study_guide/models/activity_type.dart';

// Data class for curriculum content item
class CurriculumContentItem {
  final CurriculumContentType type;
  final String id;
  final String title;
  final String description;
  final String courseCode;
  final Map<String, dynamic> metadata;
  final Duration estimatedDuration;

  CurriculumContentItem({
    required this.type,
    required this.id,
    required this.title,
    required this.description,
    required this.courseCode,
    required this.metadata,
    required this.estimatedDuration,
  });
}
