import 'package:isapp/features/learning/models/adapted_note_extensions.dart';
import 'package:isapp/features/learning/models/adapted_question_extensions.dart';
import 'package:isapp/features/learning/models/adapted_question_option_extensions.dart';
import 'package:isapp/features/learning/models/adapted_reference_extensions.dart';

class AdaptedEquipment {
  final String name;
  final String description;
  final int quantity;
  final String specifications;
  final String safetyLevel;

  AdaptedEquipment({
    required this.name,
    required this.description,
    required this.quantity,
    required this.specifications,
    required this.safetyLevel,
  });
}
