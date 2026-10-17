import 'package:isapp/features/study_guide/models/activity_type.dart';
import 'package:isapp/features/study_guide/models/daily_activity.dart';
import 'package:isapp/features/study_guide/models/mastery_record.dart';
import 'package:isapp/features/study_guide/models/study_topic.dart';

enum PlanReason {
  dueReview('Due for review'),
  weakSpot('Weak spot'),
  newTopic('New topic'),
  checkpoint('Checkpoint'),
  weeklyReview('Weekly review'),
  examPrep('Exam prep');

  final String label;
  const PlanReason(this.label);
}

/// One thing to do today.
class PlanItem {
  final String id;
  final StudyTopic topic;
  final TopicStage stage;
  final PlanReason reason;
  final ActivityType activityType;
  final int minutes;

  const PlanItem({
    required this.id,
    required this.topic,
    required this.stage,
    required this.reason,
    required this.activityType,
    required this.minutes,
  });

  String get title {
    switch (stage) {
      case TopicStage.learn:
        return 'Learn: ${topic.title}';
      case TopicStage.practice:
        return 'Practice: ${topic.title}';
      case TopicStage.check:
        return 'Quiz yourself: ${topic.title}';
      case TopicStage.master:
        return 'Refresh: ${topic.title}';
    }
  }

  /// Bridge to the existing activity screens (notes, quiz, exam, project).
  DailyActivity toDailyActivity(DateTime day) => DailyActivity(
        id: id,
        date: day,
        title: title,
        description: '${reason.label} - ${stage.hint}',
        type: activityType,
        estimatedDuration: Duration(minutes: minutes),
        courseCodes: [topic.courseCode],
        metadata: {
          ...topic.meta,
          'courseCode': topic.courseCode,
          'courseName': topic.subject,
          'topic': topic.title,
          'topicKey': topic.key,
          'stage': stage.name,
        },
      );
}
