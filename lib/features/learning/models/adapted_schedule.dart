import 'package:isapp/features/learning/models/adapted_note_extensions.dart';
import 'package:isapp/features/learning/models/adapted_question_extensions.dart';
import 'package:isapp/features/learning/models/adapted_question_option_extensions.dart';
import 'package:isapp/features/learning/models/adapted_reference_extensions.dart';
import 'package:isapp/features/learning/models/adapted_term_schedule.dart';

class AdaptedSchedule {
  final List<AdaptedTermSchedule> terms;
  final int totalWeeks;
  final int totalHours;
  final int contactHoursPerWeek;
  final DateTime startDate;
  final DateTime endDate;

  AdaptedSchedule({
    required this.terms,
    required this.totalWeeks,
    required this.totalHours,
    required this.contactHoursPerWeek,
    required this.startDate,
    required this.endDate,
  });
}
