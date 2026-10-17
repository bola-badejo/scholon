import 'package:isapp/features/learning/models/adapted_activity_step.dart';
import 'package:isapp/features/learning/models/adapted_note_extensions.dart';
import 'package:isapp/features/learning/models/adapted_question_extensions.dart';
import 'package:isapp/features/learning/models/adapted_question_option_extensions.dart';
import 'package:isapp/features/learning/models/adapted_reference_extensions.dart';

class AdaptedActivity {
  final String id;
  final String title;
  final String type;
  final String description;
  final String duration;
  final List<String> materialsNeeded;
  final String learningOutcome;
  final List<AdaptedActivityStep> steps;

  AdaptedActivity({
    required this.id,
    required this.title,
    required this.type,
    required this.description,
    required this.duration,
    required this.materialsNeeded,
    required this.learningOutcome,
    required this.steps,
  });
}
