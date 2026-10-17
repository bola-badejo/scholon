import 'package:isapp/features/learning/models/adapted_note_extensions.dart';
import 'package:isapp/features/learning/models/adapted_question_extensions.dart';
import 'package:isapp/features/learning/models/adapted_question_option_extensions.dart';
import 'package:isapp/features/learning/models/adapted_reference_extensions.dart';

class AdaptedReference {
  final String title;
  final String url;
  final String type;

  AdaptedReference({
    required this.title,
    required this.url,
    required this.type,
  });
}
