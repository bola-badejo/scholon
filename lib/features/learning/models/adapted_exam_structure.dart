import 'package:isapp/features/learning/models/adapted_exam_metadata.dart';
import 'package:isapp/features/learning/models/adapted_exam_paper.dart';
import 'package:isapp/features/learning/models/adapted_note_extensions.dart';
import 'package:isapp/features/learning/models/adapted_question_extensions.dart';
import 'package:isapp/features/learning/models/adapted_question_option_extensions.dart';
import 'package:isapp/features/learning/models/adapted_reference_extensions.dart';

class AdaptedExamStructure {
  final String id;
  final List<AdaptedExamPaper> papers;
  final AdaptedExamMetadata metadata;

  AdaptedExamStructure({
    required this.id,
    required this.papers,
    required this.metadata,
  });
}
