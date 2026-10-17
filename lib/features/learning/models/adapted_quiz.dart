import 'package:isapp/features/learning/models/adapted_note_extensions.dart';
import 'package:isapp/features/learning/models/adapted_question.dart';
import 'package:isapp/features/learning/models/adapted_question_extensions.dart';
import 'package:isapp/features/learning/models/adapted_question_option_extensions.dart';
import 'package:isapp/features/learning/models/adapted_reference_extensions.dart';

class AdaptedQuiz {
  final String id;
  final String title;
  final String description;
  final List<AdaptedQuestion> questions;
  final int duration;
  final int passingScore;
  final int maxAttempts;
  final bool isTimed;
  final String quizType;

  AdaptedQuiz({
    required this.id,
    required this.title,
    required this.description,
    required this.questions,
    required this.duration,
    required this.passingScore,
    required this.maxAttempts,
    required this.isTimed,
    required this.quizType,
  });
}
