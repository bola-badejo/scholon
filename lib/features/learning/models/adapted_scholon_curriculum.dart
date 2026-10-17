import 'package:isapp/features/learning/models/adapted_assessment_structure.dart';
import 'package:isapp/features/learning/models/adapted_course.dart';
import 'package:isapp/features/learning/models/adapted_learning_outcomes.dart';
import 'package:isapp/features/learning/models/adapted_note_extensions.dart';
import 'package:isapp/features/learning/models/adapted_question_extensions.dart';
import 'package:isapp/features/learning/models/adapted_question_option_extensions.dart';
import 'package:isapp/features/learning/models/adapted_reference_extensions.dart';
import 'package:isapp/features/learning/models/adapted_schedule.dart';
import 'package:isapp/features/learning/models/adapted_scholon_resources.dart';

class AdaptedScholonCurriculum {
  final String curriculum;
  final String academicYear;
  final String schoolLevel;
  final List<AdaptedCourse> courses;
  final AdaptedAssessmentStructure assessmentStructure;
  final AdaptedLearningOutcomes learningOutcomes;
  final AdaptedScholonResources resources;
  final AdaptedSchedule schedule;

  AdaptedScholonCurriculum({
    required this.curriculum,
    required this.academicYear,
    required this.schoolLevel,
    required this.courses,
    required this.assessmentStructure,
    required this.learningOutcomes,
    required this.resources,
    required this.schedule,
  });
}
