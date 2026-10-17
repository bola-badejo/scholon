import 'package:isapp/features/learning/models/adapted_note_extensions.dart';
import 'package:isapp/features/learning/models/adapted_question_extensions.dart';
import 'package:isapp/features/learning/models/adapted_question_option_extensions.dart';
import 'package:isapp/features/learning/models/adapted_reference_extensions.dart';

class AdaptedExamMetadata {
  final int totalPapers;
  final int totalQuestions;
  final int totalMarks;
  final String examFormat;
  final String gradingPolicy;

  AdaptedExamMetadata({
    required this.totalPapers,
    required this.totalQuestions,
    required this.totalMarks,
    required this.examFormat,
    required this.gradingPolicy,
  });
}
