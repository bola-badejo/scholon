import 'package:isapp/features/learning/models/adapted_note_extensions.dart';
import 'package:isapp/features/learning/models/adapted_question_extensions.dart';
import 'package:isapp/features/learning/models/adapted_question_option.dart';
import 'package:isapp/features/learning/models/adapted_question_option_extensions.dart';
import 'package:isapp/features/learning/models/adapted_reference_extensions.dart';

class AdaptedQuestion {
  final String id;
  final String question;
  final List<AdaptedQuestionOption> options;
  final int correctAnswer;
  final String explanation;
  final String scholonBloomLevel;
  final int points;
  final String questionType;
  final List<String> tags;

  AdaptedQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.scholonBloomLevel,
    required this.points,
    required this.questionType,
    required this.tags,
  });
}
