import 'package:isapp/features/learning/models/adapted_activity.dart';
import 'package:isapp/features/learning/models/adapted_assignment.dart';
import 'package:isapp/features/learning/models/adapted_exam_structure.dart';
import 'package:isapp/features/learning/models/adapted_note.dart';
import 'package:isapp/features/learning/models/adapted_note_extensions.dart';
import 'package:isapp/features/learning/models/adapted_question_extensions.dart';
import 'package:isapp/features/learning/models/adapted_question_option_extensions.dart';
import 'package:isapp/features/learning/models/adapted_quiz.dart';
import 'package:isapp/features/learning/models/adapted_reference_extensions.dart';

class AdaptedWeek {
  final int weekNumber;
  final String topic;
  final String overview;
  final List<String> coreCompetencies;
  final String scholonStandard;
  final List<AdaptedNote> notes;
  final List<AdaptedQuiz> quizzes;
  final List<AdaptedAssignment> assignments;
  final AdaptedExamStructure exams;
  final List<AdaptedActivity> activities;

  AdaptedWeek({
    required this.weekNumber,
    required this.topic,
    required this.overview,
    required this.coreCompetencies,
    required this.scholonStandard,
    required this.notes,
    required this.quizzes,
    required this.assignments,
    required this.exams,
    required this.activities,
  });
}
