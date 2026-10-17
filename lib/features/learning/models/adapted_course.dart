import 'package:isapp/features/learning/models/adapted_note_extensions.dart';
import 'package:isapp/features/learning/models/adapted_question_extensions.dart';
import 'package:isapp/features/learning/models/adapted_question_option_extensions.dart';
import 'package:isapp/features/learning/models/adapted_reference_extensions.dart';
import 'package:isapp/features/learning/models/adapted_term.dart';

// Include ALL your adapter classes here (the ones you provided earlier)
class AdaptedCourse {
  final String id;
  final String courseCode;
  final String name;
  final String description;
  final String strand;
  final double credits;
  final String scholonLevel;
  final Map<String, dynamic> metadata;
  final List<AdaptedTerm> terms;

  AdaptedCourse({
    required this.id,
    required this.courseCode,
    required this.name,
    required this.description,
    required this.strand,
    required this.credits,
    required this.scholonLevel,
    required this.metadata,
    required this.terms,
  });
}
