import 'package:isapp/features/learning/models/adapted_note_extensions.dart';
import 'package:isapp/features/learning/models/adapted_question.dart';
import 'package:isapp/features/learning/models/adapted_question_option_extensions.dart';
import 'package:isapp/features/learning/models/adapted_reference_extensions.dart';

extension AdaptedQuestionExtensions on AdaptedQuestion {
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options.map((opt) => opt.toJson()).toList(),
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'scholonBloomLevel': scholonBloomLevel,
      'points': points,
      'questionType': questionType,
      'tags': tags,
    };
  }
}
