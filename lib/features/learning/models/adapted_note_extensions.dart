import 'package:isapp/features/learning/models/adapted_note.dart';
import 'package:isapp/features/learning/models/adapted_question_extensions.dart';
import 'package:isapp/features/learning/models/adapted_question_option_extensions.dart';
import 'package:isapp/features/learning/models/adapted_reference_extensions.dart';

extension AdaptedNoteExtensions on AdaptedNote {
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'duration': duration,
      'difficulty': difficulty,
      'keyConcepts': keyConcepts,
      'learningTags': learningTags,
      'contentType': contentType,
      'references': references.map((ref) => ref.toJson()).toList(),
    };
  }
}
