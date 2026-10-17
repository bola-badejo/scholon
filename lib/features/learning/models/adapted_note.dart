import 'package:isapp/features/learning/models/adapted_note_extensions.dart';
import 'package:isapp/features/learning/models/adapted_question_extensions.dart';
import 'package:isapp/features/learning/models/adapted_question_option_extensions.dart';
import 'package:isapp/features/learning/models/adapted_reference.dart';
import 'package:isapp/features/learning/models/adapted_reference_extensions.dart';

class AdaptedNote {
  final String id;
  final String title;
  final String content;
  final String duration;
  final String difficulty;
  final List<String> keyConcepts;
  final List<String> learningTags;
  final String contentType;
  final List<AdaptedReference> references;

  AdaptedNote({
    required this.id,
    required this.title,
    required this.content,
    required this.duration,
    required this.difficulty,
    required this.keyConcepts,
    required this.learningTags,
    required this.contentType,
    required this.references,
  });
}
