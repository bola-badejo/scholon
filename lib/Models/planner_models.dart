import 'package:isapp/Models/courses.dart';

class StudyPlan {
  final String courseId;
  final String topicId;
  final DateTime scheduledDate;
  final int durationMinutes;
  final bool completed;

  StudyPlan({
    required this.courseId,
    required this.topicId,
    required this.scheduledDate,
    required this.durationMinutes,
    this.completed = false,
  });
}

class StudyTask {
  final String id;
  final String title;
  final DateTime date;
  final Duration duration;
  final bool completed;

  StudyTask({
    required this.id,
    required this.title,
    required this.date,
    required this.duration,
    this.completed = false,
  });

  StudyTask copyWith({bool? completed}) {
    return StudyTask(
      id: id,
      title: title,
      date: date,
      duration: duration,
      completed: completed ?? this.completed,
    );
  }
}


class UpcomingQuizItem {
  final String courseId;
  final String topicId;
  final DateTime quizDate;
  final String quizType;

  UpcomingQuizItem({
    required this.courseId,
    required this.topicId,
    required this.quizDate,
    required this.quizType,
  });
}

class RecommendationItem {
  final CourseCategories category;
  final String reason;

  RecommendationItem({
    required this.category,
    required this.reason,
  });
}



class StudyPlanItem {
  final String courseId;
  final String topicId;
  final DateTime scheduledDate;
  final int durationMinutes;
  final bool completed;

  StudyPlanItem({
    required this.courseId,
    required this.topicId,
    required this.scheduledDate,
    required this.durationMinutes,
    this.completed = false,
  });
}
