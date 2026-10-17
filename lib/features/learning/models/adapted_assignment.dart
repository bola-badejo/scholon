import 'package:isapp/features/learning/models/adapted_assignment_question.dart';
import 'package:isapp/features/learning/models/adapted_note_extensions.dart';
import 'package:isapp/features/learning/models/adapted_question_extensions.dart';
import 'package:isapp/features/learning/models/adapted_question_option_extensions.dart';
import 'package:isapp/features/learning/models/adapted_reference_extensions.dart';
import 'package:isapp/features/learning/models/adapted_submission_criteria.dart';

class AdaptedAssignment {
  final String id;
  final String title;
  final String type;
  final String description;
  final List<String> requirements;
  final String submissionFormat;
  final String deadline;
  final int totalPoints;
  final dynamic rubric;
  final List<AdaptedAssignmentQuestion>? questions;
  final List<AdaptedSubmissionCriteria> submissionCriteria;
  final String difficulty;
  final List<String> skillsDeveloped;

  AdaptedAssignment({
    required this.id,
    required this.title,
    required this.type,
    required this.description,
    required this.requirements,
    required this.submissionFormat,
    required this.deadline,
    required this.totalPoints,
    this.rubric,
    this.questions,
    required this.submissionCriteria,
    required this.difficulty,
    required this.skillsDeveloped,
  });
}
