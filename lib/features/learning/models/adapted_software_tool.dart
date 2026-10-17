import 'package:isapp/features/learning/models/adapted_note_extensions.dart';
import 'package:isapp/features/learning/models/adapted_question_extensions.dart';
import 'package:isapp/features/learning/models/adapted_question_option_extensions.dart';
import 'package:isapp/features/learning/models/adapted_reference_extensions.dart';

class AdaptedSoftwareTool {
  final String name;
  final String version;
  final String purpose;
  final String license;
  final String systemRequirements;

  AdaptedSoftwareTool({
    required this.name,
    required this.version,
    required this.purpose,
    required this.license,
    required this.systemRequirements,
  });
}
