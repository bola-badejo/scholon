import 'package:cloud_firestore/cloud_firestore.dart';

/// Where a student is on a topic. Each stage unlocks a different kind of work:
/// learn -> practice -> check (quiz) -> master (spaced revision only).
enum TopicStage {
  learn('Learn', 'Read and understand'),
  practice('Practice', 'Work examples'),
  check('Check', 'Test yourself'),
  master('Master', 'Keep it fresh');

  final String label;
  final String hint;
  const TopicStage(this.label, this.hint);

  static TopicStage fromMastery(double m, int attempts) {
    if (attempts == 0 || m < .25) return TopicStage.learn;
    if (m < .55) return TopicStage.practice;
    if (m < .80) return TopicStage.check;
    return TopicStage.master;
  }
}

class MasteryRecord {
  final String topicKey;
  final String subject;
  final String title;
  final double mastery; // 0..1
  final double easiness; // SM-2 easiness factor, >= 1.3
  final int repetitions;
  final int intervalDays;
  final int attempts;
  final DateTime? dueDate;
  final DateTime? lastReviewed;

  const MasteryRecord({
    required this.topicKey,
    required this.subject,
    required this.title,
    this.mastery = 0,
    this.easiness = 2.5,
    this.repetitions = 0,
    this.intervalDays = 0,
    this.attempts = 0,
    this.dueDate,
    this.lastReviewed,
  });

  TopicStage get stage => TopicStage.fromMastery(mastery, attempts);

  bool isDue(DateTime now) {
    if (dueDate == null) return false;
    final d = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    final n = DateTime(now.year, now.month, now.day);
    return !d.isAfter(n);
  }

  int overdueDays(DateTime now) {
    if (dueDate == null) return 0;
    return DateTime(now.year, now.month, now.day).difference(DateTime(dueDate!.year, dueDate!.month, dueDate!.day)).inDays;
  }

  MasteryRecord copyWith({
    double? mastery,
    double? easiness,
    int? repetitions,
    int? intervalDays,
    int? attempts,
    DateTime? dueDate,
    DateTime? lastReviewed,
  }) =>
      MasteryRecord(
        topicKey: topicKey,
        subject: subject,
        title: title,
        mastery: mastery ?? this.mastery,
        easiness: easiness ?? this.easiness,
        repetitions: repetitions ?? this.repetitions,
        intervalDays: intervalDays ?? this.intervalDays,
        attempts: attempts ?? this.attempts,
        dueDate: dueDate ?? this.dueDate,
        lastReviewed: lastReviewed ?? this.lastReviewed,
      );

  Map<String, dynamic> toMap() => {
        'topicKey': topicKey,
        'subject': subject,
        'title': title,
        'mastery': mastery,
        'easiness': easiness,
        'repetitions': repetitions,
        'intervalDays': intervalDays,
        'attempts': attempts,
        'dueDate': dueDate == null ? null : Timestamp.fromDate(dueDate!),
        'lastReviewed': lastReviewed == null ? null : Timestamp.fromDate(lastReviewed!),
      };

  factory MasteryRecord.fromMap(Map<String, dynamic> m) => MasteryRecord(
        topicKey: m['topicKey'] ?? '',
        subject: m['subject'] ?? '',
        title: m['title'] ?? '',
        mastery: (m['mastery'] as num?)?.toDouble() ?? 0,
        easiness: (m['easiness'] as num?)?.toDouble() ?? 2.5,
        repetitions: (m['repetitions'] as num?)?.toInt() ?? 0,
        intervalDays: (m['intervalDays'] as num?)?.toInt() ?? 0,
        attempts: (m['attempts'] as num?)?.toInt() ?? 0,
        dueDate: (m['dueDate'] as Timestamp?)?.toDate(),
        lastReviewed: (m['lastReviewed'] as Timestamp?)?.toDate(),
      );
}
