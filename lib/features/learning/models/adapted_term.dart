import 'package:isapp/features/learning/models/adapted_learning_objectives.dart';
import 'package:isapp/features/learning/models/adapted_note_extensions.dart';
import 'package:isapp/features/learning/models/adapted_question_extensions.dart';
import 'package:isapp/features/learning/models/adapted_question_option_extensions.dart';
import 'package:isapp/features/learning/models/adapted_reference_extensions.dart';
import 'package:isapp/features/learning/models/adapted_week.dart';

class AdaptedTerm {
  final String id;
  final String term;
  final String duration;
  final String focus;
  final AdaptedLearningObjectives objectives;
  final List<AdaptedWeek> weeks;

  AdaptedTerm({
    required this.id,
    required this.term,
    required this.duration,
    required this.focus,
    required this.objectives,
    required this.weeks,
  });
}
