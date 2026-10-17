import 'package:isapp/features/learning/models/adapted_note_extensions.dart';
import 'package:isapp/features/learning/models/adapted_question_extensions.dart';
import 'package:isapp/features/learning/models/adapted_question_option_extensions.dart';
import 'package:isapp/features/learning/models/adapted_reference_extensions.dart';

class AdaptedActivityStep {
  final int stepNumber;
  final String instruction;
  final String? timeAllocation;
  final String? facilitatorNote;

  AdaptedActivityStep({
    required this.stepNumber,
    required this.instruction,
    this.timeAllocation,
    this.facilitatorNote,
  });
}
