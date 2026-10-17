import 'package:isapp/features/learning/models/adapted_note_extensions.dart';
import 'package:isapp/features/learning/models/adapted_question_extensions.dart';
import 'package:isapp/features/learning/models/adapted_question_option.dart';
import 'package:isapp/features/learning/models/adapted_reference_extensions.dart';

extension AdaptedQuestionOptionExtensions on AdaptedQuestionOption {
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'isCorrect': isCorrect,
    };
  }
}
