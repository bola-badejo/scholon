import 'package:isapp/features/learning/models/adapted_note_extensions.dart';
import 'package:isapp/features/learning/models/adapted_question_extensions.dart';
import 'package:isapp/features/learning/models/adapted_question_option_extensions.dart';
import 'package:isapp/features/learning/models/adapted_reference_extensions.dart';

class AdaptedTermSchedule {
  final int term;
  final String duration;
  final int weeks;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> holidays;

  AdaptedTermSchedule({
    required this.term,
    required this.duration,
    required this.weeks,
    required this.startDate,
    required this.endDate,
    required this.holidays,
  });
}
