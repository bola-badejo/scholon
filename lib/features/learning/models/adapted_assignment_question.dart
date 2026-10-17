import 'package:isapp/features/learning/models/adapted_note_extensions.dart';
import 'package:isapp/features/learning/models/adapted_question_extensions.dart';
import 'package:isapp/features/learning/models/adapted_question_option_extensions.dart';
import 'package:isapp/features/learning/models/adapted_reference_extensions.dart';

class AdaptedAssignmentQuestion {
  final String question;
  final String? solutionHint;
  final int points;
  final String questionType;
  final List<String>? parts;

  AdaptedAssignmentQuestion({
    required this.question,
    this.solutionHint,
    required this.points,
    required this.questionType,
    this.parts,
  });
}
