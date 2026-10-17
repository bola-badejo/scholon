import 'package:isapp/features/learning/models/adapted_note_extensions.dart';
import 'package:isapp/features/learning/models/adapted_question_extensions.dart';
import 'package:isapp/features/learning/models/adapted_question_option_extensions.dart';
import 'package:isapp/features/learning/models/adapted_reference.dart';

extension AdaptedReferenceExtensions on AdaptedReference {
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'url': url,
      'type': type,
    };
  }
}
