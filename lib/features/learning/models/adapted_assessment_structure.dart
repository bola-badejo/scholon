import 'package:isapp/features/learning/models/adapted_note_extensions.dart';
import 'package:isapp/features/learning/models/adapted_question_extensions.dart';
import 'package:isapp/features/learning/models/adapted_question_option_extensions.dart';
import 'package:isapp/features/learning/models/adapted_reference_extensions.dart';

class AdaptedAssessmentStructure {
  final int continuousAssessment;
  final int termlyExaminations;
  final Map<String, String> gradingScale;
  final Map<String, int> weightDistribution;

  AdaptedAssessmentStructure({
    required this.continuousAssessment,
    required this.termlyExaminations,
    required this.gradingScale,
    required this.weightDistribution,
  });
}
