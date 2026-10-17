/// One teachable unit of the curriculum (a week of a course).
class StudyTopic {
  final String key;
  final String courseCode;
  final String subject;
  final String title;
  final int order;
  final int estimatedMinutes;
  final Map<String, dynamic> meta;

  const StudyTopic({
    required this.key,
    required this.courseCode,
    required this.subject,
    required this.title,
    required this.order,
    this.estimatedMinutes = 25,
    this.meta = const {},
  });
}
