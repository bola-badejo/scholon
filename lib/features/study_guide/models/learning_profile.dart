/// How fast a student wants to move through the curriculum.
enum LearningProfile {
  pacedLearner, 
  balancedStudent,
  acceleratedLearner
}

class SubjectFocus {
  final String subjectCode;
  final String subjectName;
  final double weight; // 0.0 to 1.0
  final List<String> topics;
  final int weeklyHours;
  final double currentMastery; // 0.0 to 1.0

  SubjectFocus({
    required this.subjectCode,
    required this.subjectName,
    required this.weight,
    required this.topics,
    required this.weeklyHours,
    this.currentMastery = 0.0,
  });
}
