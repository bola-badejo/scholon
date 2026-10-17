import 'package:isapp/features/learning/models/adapted_note_extensions.dart';
import 'package:isapp/features/learning/models/adapted_question_extensions.dart';
import 'package:isapp/features/learning/models/adapted_question_option_extensions.dart';
import 'package:isapp/features/learning/models/adapted_reference_extensions.dart';

class AdaptedLearningObjectives {
  final List<String> knowledgeObjectives;
  final List<String> skillObjectives;
  final List<String> attitudeObjectives;

  AdaptedLearningObjectives({
    required this.knowledgeObjectives,
    required this.skillObjectives,
    required this.attitudeObjectives,
  });
}
