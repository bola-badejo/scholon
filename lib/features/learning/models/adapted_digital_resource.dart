import 'package:isapp/features/learning/models/adapted_note_extensions.dart';
import 'package:isapp/features/learning/models/adapted_question_extensions.dart';
import 'package:isapp/features/learning/models/adapted_question_option_extensions.dart';
import 'package:isapp/features/learning/models/adapted_reference_extensions.dart';

class AdaptedDigitalResource {
  final String title;
  final String url;
  final String type;
  final String? description;
  final String? accessType;
  final String? format;

  AdaptedDigitalResource({
    required this.title,
    required this.url,
    required this.type,
    this.description,
    this.accessType,
    this.format,
  });
}
