import 'package:isapp/features/learning/models/adapted_note_extensions.dart';
import 'package:isapp/features/learning/models/adapted_question_extensions.dart';
import 'package:isapp/features/learning/models/adapted_question_option_extensions.dart';
import 'package:isapp/features/learning/models/adapted_reference_extensions.dart';

class AdaptedExamPaper {
  final String id;
  final String title;
  final String examType;
  final List<dynamic> questions;
  final int duration;
  final int totalMarks;
  final String instructions;
  final List<String> allowedMaterials;

  AdaptedExamPaper({
    required this.id,
    required this.title,
    required this.examType,
    required this.questions,
    required this.duration,
    required this.totalMarks,
    required this.instructions,
    required this.allowedMaterials,
  });
}
