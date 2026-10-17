import 'package:isapp/features/learning/models/adapted_digital_resource.dart';
import 'package:isapp/features/learning/models/adapted_equipment.dart';
import 'package:isapp/features/learning/models/adapted_note_extensions.dart';
import 'package:isapp/features/learning/models/adapted_question_extensions.dart';
import 'package:isapp/features/learning/models/adapted_question_option_extensions.dart';
import 'package:isapp/features/learning/models/adapted_reference_extensions.dart';
import 'package:isapp/features/learning/models/adapted_software_tool.dart';

class AdaptedScholonResources {
  final List<AdaptedDigitalResource> textbooks;
  final List<AdaptedDigitalResource> digitalResources;
  final List<AdaptedEquipment> laboratoryEquipment;
  final List<AdaptedSoftwareTool> softwareTools;

  AdaptedScholonResources({
    required this.textbooks,
    required this.digitalResources,
    required this.laboratoryEquipment,
    required this.softwareTools,
  });
}
