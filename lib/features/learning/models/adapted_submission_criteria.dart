import 'package:isapp/features/learning/models/adapted_note_extensions.dart';
import 'package:isapp/features/learning/models/adapted_question_extensions.dart';
import 'package:isapp/features/learning/models/adapted_question_option_extensions.dart';
import 'package:isapp/features/learning/models/adapted_reference_extensions.dart';

class AdaptedSubmissionCriteria {
  final String criterion;
  final int maxPoints;
  final String description;

  AdaptedSubmissionCriteria({
    required this.criterion,
    required this.maxPoints,
    required this.description,
  });
}
