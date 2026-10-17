import 'package:isapp/features/learning/models/adapted_note_extensions.dart';
import 'package:isapp/features/learning/models/adapted_question_extensions.dart';
import 'package:isapp/features/learning/models/adapted_question_option_extensions.dart';
import 'package:isapp/features/learning/models/adapted_reference_extensions.dart';

class AdaptedLearningOutcomes {
  final List<String> cognitiveSkills;
  final List<String> practicalSkills;
  final List<String> softSkills;
  final List<String> scholonCompetencies;

  AdaptedLearningOutcomes({
    required this.cognitiveSkills,
    required this.practicalSkills,
    required this.softSkills,
    required this.scholonCompetencies,
  });
}
