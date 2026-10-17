import 'package:isapp/features/learning/models/adapted_note_extensions.dart';
import 'package:isapp/features/learning/models/adapted_question_extensions.dart';
import 'package:isapp/features/learning/models/adapted_question_option_extensions.dart';
import 'package:isapp/features/learning/models/adapted_reference_extensions.dart';

class AdaptedQuestionOption {
  final String id;
  final String text;
  final bool isCorrect;

  AdaptedQuestionOption({
    required this.id,
    required this.text,
    required this.isCorrect,
  });
}
