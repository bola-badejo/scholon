import 'package:isapp/features/learning/models/adapted_activity.dart';
import 'package:isapp/features/learning/models/adapted_activity_step.dart';
import 'package:isapp/features/learning/models/adapted_assessment_structure.dart';
import 'package:isapp/features/learning/models/adapted_assignment.dart';
import 'package:isapp/features/learning/models/adapted_assignment_question.dart';
import 'package:isapp/features/learning/models/adapted_course.dart';
import 'package:isapp/features/learning/models/adapted_digital_resource.dart';
import 'package:isapp/features/learning/models/adapted_equipment.dart';
import 'package:isapp/features/learning/models/adapted_exam_metadata.dart';
import 'package:isapp/features/learning/models/adapted_exam_paper.dart';
import 'package:isapp/features/learning/models/adapted_exam_structure.dart';
import 'package:isapp/features/learning/models/adapted_learning_objectives.dart';
import 'package:isapp/features/learning/models/adapted_learning_outcomes.dart';
import 'package:isapp/features/learning/models/adapted_note.dart';
import 'package:isapp/features/learning/models/adapted_note_extensions.dart';
import 'package:isapp/features/learning/models/adapted_question.dart';
import 'package:isapp/features/learning/models/adapted_question_extensions.dart';
import 'package:isapp/features/learning/models/adapted_question_option.dart';
import 'package:isapp/features/learning/models/adapted_question_option_extensions.dart';
import 'package:isapp/features/learning/models/adapted_quiz.dart';
import 'package:isapp/features/learning/models/adapted_reference.dart';
import 'package:isapp/features/learning/models/adapted_reference_extensions.dart';
import 'package:isapp/features/learning/models/adapted_schedule.dart';
import 'package:isapp/features/learning/models/adapted_scholon_curriculum.dart';
import 'package:isapp/features/learning/models/adapted_scholon_resources.dart';
import 'package:isapp/features/learning/models/adapted_software_tool.dart';
import 'package:isapp/features/learning/models/adapted_submission_criteria.dart';
import 'package:isapp/features/learning/models/adapted_term.dart';
import 'package:isapp/features/learning/models/adapted_term_schedule.dart';
import 'package:isapp/features/learning/models/adapted_week.dart';

export 'package:isapp/features/learning/models/adapted_activity.dart';
export 'package:isapp/features/learning/models/adapted_activity_step.dart';
export 'package:isapp/features/learning/models/adapted_assessment_structure.dart';
export 'package:isapp/features/learning/models/adapted_assignment.dart';
export 'package:isapp/features/learning/models/adapted_assignment_question.dart';
export 'package:isapp/features/learning/models/adapted_course.dart';
export 'package:isapp/features/learning/models/adapted_digital_resource.dart';
export 'package:isapp/features/learning/models/adapted_equipment.dart';
export 'package:isapp/features/learning/models/adapted_exam_metadata.dart';
export 'package:isapp/features/learning/models/adapted_exam_paper.dart';
export 'package:isapp/features/learning/models/adapted_exam_structure.dart';
export 'package:isapp/features/learning/models/adapted_learning_objectives.dart';
export 'package:isapp/features/learning/models/adapted_learning_outcomes.dart';
export 'package:isapp/features/learning/models/adapted_note.dart';
export 'package:isapp/features/learning/models/adapted_note_extensions.dart';
export 'package:isapp/features/learning/models/adapted_question.dart';
export 'package:isapp/features/learning/models/adapted_question_extensions.dart';
export 'package:isapp/features/learning/models/adapted_question_option.dart';
export 'package:isapp/features/learning/models/adapted_question_option_extensions.dart';
export 'package:isapp/features/learning/models/adapted_quiz.dart';
export 'package:isapp/features/learning/models/adapted_reference.dart';
export 'package:isapp/features/learning/models/adapted_reference_extensions.dart';
export 'package:isapp/features/learning/models/adapted_schedule.dart';
export 'package:isapp/features/learning/models/adapted_scholon_curriculum.dart';
export 'package:isapp/features/learning/models/adapted_scholon_resources.dart';
export 'package:isapp/features/learning/models/adapted_software_tool.dart';
export 'package:isapp/features/learning/models/adapted_submission_criteria.dart';
export 'package:isapp/features/learning/models/adapted_term.dart';
export 'package:isapp/features/learning/models/adapted_term_schedule.dart';
export 'package:isapp/features/learning/models/adapted_week.dart';

// Adapter class
class ScholonCurriculumAdapter {

static AdaptedScholonCurriculum adaptFromJson(dynamic jsonData) {
  try {
    final json = jsonData is List ? jsonData.first : jsonData;
    
    // Safe parsing with defaults for ALL fields
    final curriculum = json['curriculum'] as String? ?? 'Scholon Advanced Curriculum';
    final academicYear = json['academicYear'] as String? ?? '2023/2024';
    final schoolLevel = json['schoolLevel'] as String? ?? 'Senior Secondary 3 (SS3)';
    
    // Courses with safe parsing - handle null or missing
    final coursesJson = json['courses'] as List? ?? [];
    final courses = coursesJson.isNotEmpty ? _adaptCourses(coursesJson) : _createDefaultCourses();
    
    // Assessment structure with defaults
    final assessmentJson = json['assessmentStructure'] as Map<String, dynamic>? ?? {};
    final assessmentStructure = AdaptedAssessmentStructure(
      continuousAssessment: assessmentJson['continuousAssessment'] as int? ?? 40,
      termlyExaminations: assessmentJson['termlyExaminations'] as int? ?? 60,
      gradingScale: Map<String, String>.from(assessmentJson['gradingScale'] ?? {}),
      weightDistribution: Map<String, int>.from(assessmentJson['weightDistribution'] ?? {}),
    );
    
    // Learning outcomes with defaults
    final outcomesJson = json['learningOutcomes'] as Map<String, dynamic>? ?? {};
    final learningOutcomes = AdaptedLearningOutcomes(
      cognitiveSkills: List<String>.from(outcomesJson['cognitiveSkills'] ?? []),
      practicalSkills: List<String>.from(outcomesJson['practicalSkills'] ?? []),
      softSkills: List<String>.from(outcomesJson['softSkills'] ?? []),
      scholonCompetencies: List<String>.from(outcomesJson['scholonCompetencies'] ?? []),
    );
    
    // Resources with defaults
    final resourcesJson = json['resources'] as Map<String, dynamic>? ?? {};
    final resources = AdaptedScholonResources(
      textbooks: _adaptDigitalResources(resourcesJson['textbooks'] as List? ?? []),
      digitalResources: _adaptDigitalResources(resourcesJson['digitalResources'] as List? ?? []),
      laboratoryEquipment: _adaptEquipment(resourcesJson['laboratoryEquipment'] as List? ?? []),
      softwareTools: _adaptSoftwareTools(resourcesJson['softwareTools'] as List? ?? []),
    );
    
    // Schedule with defaults
    final scheduleJson = json['schedule'] as Map<String, dynamic>? ?? {};
    final schedule = AdaptedSchedule(
      terms: _adaptTermSchedules(scheduleJson['terms'] as List? ?? []),
      totalWeeks: scheduleJson['totalWeeks'] as int? ?? 36,
      totalHours: scheduleJson['totalHours'] as int? ?? 1440,
      contactHoursPerWeek: scheduleJson['contactHoursPerWeek'] as int? ?? 40,
      startDate: scheduleJson['startDate'] != null 
          ? DateTime.parse(scheduleJson['startDate'] as String)
          : DateTime(2023, 9, 4),
      endDate: scheduleJson['endDate'] != null
          ? DateTime.parse(scheduleJson['endDate'] as String)
          : DateTime(2024, 7, 12),
    );
    
    print('✅ Adapter: Successfully parsed curriculum with ${courses.length} courses');
    
    return AdaptedScholonCurriculum(
      curriculum: curriculum,
      academicYear: academicYear,
      schoolLevel: schoolLevel,
      courses: courses,
      assessmentStructure: assessmentStructure,
      learningOutcomes: learningOutcomes,
      resources: resources,
      schedule: schedule,
    );
  } catch (e, stackTrace) {
    print('❌ Error in adapter: $e');
    print('Stack trace: $stackTrace');
    
    return AdaptedScholonCurriculum(
      curriculum: 'Demo Curriculum',
      academicYear: '2024',
      schoolLevel: 'Demo Level',
      courses: _createDefaultCourses(),
      assessmentStructure: AdaptedAssessmentStructure(
        continuousAssessment: 40,
        termlyExaminations: 60,
        gradingScale: {},
        weightDistribution: {},
      ),
      learningOutcomes: AdaptedLearningOutcomes(
        cognitiveSkills: [],
        practicalSkills: [],
        softSkills: [],
        scholonCompetencies: [],
      ),
      resources: AdaptedScholonResources(
        textbooks: [],
        digitalResources: [],
        laboratoryEquipment: [],
        softwareTools: [],
      ),
      schedule: AdaptedSchedule(
        terms: [],
        totalWeeks: 12,
        totalHours: 0,
        contactHoursPerWeek: 0,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(Duration(days: 12 * 7)),
      ),
    );
  }
}

static List<AdaptedCourse> _createDefaultCourses() {
  return [
    AdaptedCourse(
      id: 'default_math',
      courseCode: 'MAT',
      name: 'Mathematics',
      description: 'Default mathematics course',
      strand: 'STEM',
      credits: 5.0,
      scholonLevel: 'Intermediate',
      metadata: {},
      terms: [
        AdaptedTerm(
          id: 'default_term_1',
          term: 'Term 1',
          duration: '12 weeks',
          focus: 'Fundamentals',
          objectives: AdaptedLearningObjectives(
            knowledgeObjectives: ['Understand basic concepts'],
            skillObjectives: ['Apply basic principles'],
            attitudeObjectives: ['Develop interest'],
          ),
          weeks: [
            AdaptedWeek(
              weekNumber: 1,
              topic: 'Introduction',
              overview: 'Basic introduction',
              coreCompetencies: ['Understanding'],
              scholonStandard: 'Beginner',
              notes: [
                AdaptedNote(
                  id: 'default_note_1',
                  title: 'Introduction to Mathematics',
                  content: 'Basic mathematics concepts...',
                  duration: '30 min',
                  difficulty: 'Beginner',
                  keyConcepts: ['Basics'],
                  learningTags: ['foundation'],
                  contentType: 'theory',
                  references: [],
                ),
              ],
              quizzes: [
                AdaptedQuiz(
                  id: 'default_quiz_1',
                  title: 'Basic Concepts Quiz',
                  description: 'Test basic understanding',
                  questions: [
                    AdaptedQuestion(
                      id: 'q1',
                      question: 'What is 2+2?',
                      options: [
                        AdaptedQuestionOption(id: 'A', text: '3', isCorrect: false),
                        AdaptedQuestionOption(id: 'B', text: '4', isCorrect: true),
                        AdaptedQuestionOption(id: 'C', text: '5', isCorrect: false),
                      ],
                      correctAnswer: 1,
                      explanation: '2+2 equals 4',
                      scholonBloomLevel: 'Remember',
                      points: 10,
                      questionType: 'multiple_choice',
                      tags: ['basic'],
                    ),
                  ],
                  duration: 10,
                  passingScore: 70,
                  maxAttempts: 3,
                  isTimed: true,
                  quizType: 'formative',
                ),
              ],
              assignments: [],
              exams: AdaptedExamStructure(
                id: 'default_exam',
                papers: [],
                metadata: AdaptedExamMetadata(
                  totalPapers: 0,
                  totalQuestions: 0,
                  totalMarks: 0,
                  examFormat: '',
                  gradingPolicy: '',
                ),
              ),
              activities: [],
            ),
          ],
        ),
      ],
    ),
  ];
}

  // Update ALL these methods to handle null:

static List<AdaptedCourse> _adaptCourses(List<dynamic> coursesJson) {
  try {
    if (coursesJson.isEmpty) return [];
    return coursesJson.map((courseJson) {
      return AdaptedCourse(
        id: courseJson['id'] as String? ?? 'unknown_id',
        courseCode: courseJson['courseCode'] as String? ?? 'UNK',
        name: courseJson['name'] as String? ?? 'Unknown Course',
        description: courseJson['description'] as String? ?? '',
        strand: courseJson['strand'] as String? ?? 'General',
        credits: (courseJson['credits'] as num?)?.toDouble() ?? 1.0,
        scholonLevel: courseJson['scholonLevel'] as String? ?? 'Beginner',
        metadata: courseJson['metadata'] as Map<String, dynamic>? ?? {},
        terms: _adaptTerms(courseJson['terms'] as List? ?? []),
      );
    }).toList();
  } catch (e) {
    print('Error adapting courses: $e');
    return [];
  }
}

static List<AdaptedTerm> _adaptTerms(List<dynamic> termsJson) {
  try {
    if (termsJson.isEmpty) return [];
    return termsJson.map((termJson) {
      final objectivesJson = termJson['objectives'] as Map<String, dynamic>? ?? {};
      return AdaptedTerm(
        id: termJson['id'] as String? ?? 'unknown_term',
        term: termJson['term'] as String? ?? 'Term 1',
        duration: termJson['duration'] as String? ?? '12 weeks',
        focus: termJson['focus'] as String? ?? 'General',
        objectives: AdaptedLearningObjectives(
          knowledgeObjectives: List<String>.from(objectivesJson['knowledgeObjectives'] ?? []),
          skillObjectives: List<String>.from(objectivesJson['skillObjectives'] ?? []),
          attitudeObjectives: List<String>.from(objectivesJson['attitudeObjectives'] ?? []),
        ),
        weeks: _adaptWeeks(termJson['weeks'] as List? ?? []),
      );
    }).toList();
  } catch (e) {
    print('Error adapting terms: $e');
    return [];
  }
}

static List<AdaptedWeek> _adaptWeeks(List<dynamic> weeksJson) {
  try {
    if (weeksJson.isEmpty) return [];
    return weeksJson.map((weekJson) {
      final examsJson = weekJson['exams'] as Map<String, dynamic>? ?? {};
      final metadataJson = examsJson['metadata'] as Map<String, dynamic>? ?? {};
      
      return AdaptedWeek(
        weekNumber: (weekJson['weekNumber'] as num?)?.toInt() ?? 1,
        topic: weekJson['topic'] as String? ?? 'Introduction',
        overview: weekJson['overview'] as String? ?? '',
        coreCompetencies: List<String>.from(weekJson['coreCompetencies'] ?? []),
        scholonStandard: weekJson['scholonStandard'] as String? ?? 'Beginner',
        notes: _adaptNotes(weekJson['notes'] as List? ?? []),
        quizzes: _adaptQuizzes(weekJson['quizzes'] as List? ?? []),
        assignments: _adaptAssignments(weekJson['assignments'] as List? ?? []),
        exams: AdaptedExamStructure(
          id: examsJson['id'] as String? ?? 'default_exam',
          papers: _adaptExamPapers(examsJson['papers'] as List? ?? []),
          metadata: AdaptedExamMetadata(
            totalPapers: (metadataJson['totalPapers'] as num?)?.toInt() ?? 0,
            totalQuestions: (metadataJson['totalQuestions'] as num?)?.toInt() ?? 0,
            totalMarks: (metadataJson['totalMarks'] as num?)?.toInt() ?? 0,
            examFormat: metadataJson['examFormat'] as String? ?? '',
            gradingPolicy: metadataJson['gradingPolicy'] as String? ?? '',
          ),
        ),
        activities: _adaptActivities(weekJson['activities'] as List? ?? []),
      );
    }).toList();
  } catch (e) {
    print('Error adapting weeks: $e');
    return [];
  }
}

static List<AdaptedNote> _adaptNotes(List<dynamic> notesJson) {
  try {
    if (notesJson.isEmpty) return [];
    return notesJson.map((noteJson) {
      return AdaptedNote(
        id: noteJson['id'] as String? ?? 'unknown_note',
        title: noteJson['title'] as String? ?? 'Untitled Note',
        content: noteJson['content'] as String? ?? '',
        duration: noteJson['duration'] as String? ?? '30 min',
        difficulty: noteJson['difficulty'] as String? ?? 'Beginner',
        keyConcepts: List<String>.from(noteJson['keyConcepts'] ?? []),
        learningTags: List<String>.from(noteJson['learningTags'] ?? []),
        contentType: noteJson['contentType'] as String? ?? 'theory',
        references: _adaptReferences(noteJson['references'] as List? ?? []),
      );
    }).toList();
  } catch (e) {
    print('Error adapting notes: $e');
    return [];
  }
}

static List<AdaptedReference> _adaptReferences(List<dynamic> referencesJson) {
  try {
    if (referencesJson.isEmpty) return [];
    return referencesJson.map((refJson) {
      return AdaptedReference(
        title: refJson['title'] as String? ?? 'Untitled Reference',
        url: refJson['url'] as String? ?? '',
        type: refJson['type'] as String? ?? 'textbook',
      );
    }).toList();
  } catch (e) {
    print('Error adapting references: $e');
    return [];
  }
}

static List<AdaptedQuiz> _adaptQuizzes(List<dynamic> quizzesJson) {
  try {
    if (quizzesJson.isEmpty) return [];
    return quizzesJson.map((quizJson) {
      return AdaptedQuiz(
        id: quizJson['id'] as String? ?? 'unknown_quiz',
        title: quizJson['title'] as String? ?? 'Untitled Quiz',
        description: quizJson['description'] as String? ?? '',
        questions: _adaptQuestions(quizJson['questions'] as List? ?? []),
        duration: (quizJson['duration'] as num?)?.toInt() ?? 15,
        passingScore: (quizJson['passingScore'] as num?)?.toInt() ?? 70,
        maxAttempts: (quizJson['maxAttempts'] as num?)?.toInt() ?? 3,
        isTimed: quizJson['isTimed'] as bool? ?? true,
        quizType: quizJson['quizType'] as String? ?? 'formative',
      );
    }).toList();
  } catch (e) {
    print('Error adapting quizzes: $e');
    return [];
  }
}

static List<AdaptedQuestion> _adaptQuestions(List<dynamic> questionsJson) {
  try {
    if (questionsJson.isEmpty) return [];
    return questionsJson.map((questionJson) {
      return AdaptedQuestion(
        id: questionJson['id'] as String? ?? 'unknown_question',
        question: questionJson['question'] as String? ?? 'Question?',
        options: _adaptQuestionOptions(questionJson['options'] as List? ?? []),
        correctAnswer: (questionJson['correctAnswer'] as num?)?.toInt() ?? 0,
        explanation: questionJson['explanation'] as String? ?? '',
        scholonBloomLevel: questionJson['scholonBloomLevel'] as String? ?? 'Remember',
        points: (questionJson['points'] as num?)?.toInt() ?? 10,
        questionType: questionJson['questionType'] as String? ?? 'multiple_choice',
        tags: List<String>.from(questionJson['tags'] ?? []),
      );
    }).toList();
  } catch (e) {
    print('Error adapting questions: $e');
    return [];
  }
}

static List<AdaptedQuestionOption> _adaptQuestionOptions(List<dynamic> optionsJson) {
  try {
    if (optionsJson.isEmpty) return [];
    return optionsJson.map((optionJson) {
      return AdaptedQuestionOption(
        id: optionJson['id'] as String? ?? 'unknown_option',
        text: optionJson['text'] as String? ?? 'Option',
        isCorrect: optionJson['isCorrect'] as bool? ?? false,
      );
    }).toList();
  } catch (e) {
    print('Error adapting question options: $e');
    return [];
  }
}

static List<AdaptedAssignment> _adaptAssignments(List<dynamic> assignmentsJson) {
  try {
    if (assignmentsJson.isEmpty) return [];
    return assignmentsJson.map((assignmentJson) {
      return AdaptedAssignment(
        id: assignmentJson['id'] as String? ?? 'unknown_assignment',
        title: assignmentJson['title'] as String? ?? 'Untitled Assignment',
        type: assignmentJson['type'] as String? ?? 'essay',
        description: assignmentJson['description'] as String? ?? '',
        requirements: List<String>.from(assignmentJson['requirements'] ?? []),
        submissionFormat: assignmentJson['submissionFormat'] as String? ?? 'PDF',
        deadline: assignmentJson['deadline'] as String? ?? '2024-12-31',
        totalPoints: (assignmentJson['totalPoints'] as num?)?.toInt() ?? 100,
        rubric: assignmentJson['rubric'],
        questions: assignmentJson['questions'] != null
            ? _adaptAssignmentQuestions(assignmentJson['questions'] as List)
            : null,
        submissionCriteria: _adaptSubmissionCriteria(
          assignmentJson['submissionCriteria'] as List? ?? [],
        ),
        difficulty: assignmentJson['difficulty'] as String? ?? 'Medium',
        skillsDeveloped: List<String>.from(assignmentJson['skillsDeveloped'] ?? []),
      );
    }).toList();
  } catch (e) {
    print('Error adapting assignments: $e');
    return [];
  }
}

static List<AdaptedAssignmentQuestion> _adaptAssignmentQuestions(List<dynamic> questionsJson) {
  try {
    if (questionsJson.isEmpty) return [];
    return questionsJson.map((qJson) {
      return AdaptedAssignmentQuestion(
        question: qJson['question'] as String? ?? 'Question?',
        solutionHint: qJson['solutionHint'] as String?,
        points: (qJson['points'] as num?)?.toInt() ?? 10,
        questionType: qJson['questionType'] as String? ?? 'essay',
        parts: qJson['parts'] != null ? List<String>.from(qJson['parts']) : null,
      );
    }).toList();
  } catch (e) {
    print('Error adapting assignment questions: $e');
    return [];
  }
}

static List<AdaptedSubmissionCriteria> _adaptSubmissionCriteria(List<dynamic> criteriaJson) {
  try {
    if (criteriaJson.isEmpty) return [];
    return criteriaJson.map((cJson) {
      return AdaptedSubmissionCriteria(
        criterion: cJson['criterion'] as String? ?? 'Criterion',
        maxPoints: (cJson['maxPoints'] as num?)?.toInt() ?? 10,
        description: cJson['description'] as String? ?? '',
      );
    }).toList();
  } catch (e) {
    print('Error adapting submission criteria: $e');
    return [];
  }
}

static List<AdaptedExamPaper> _adaptExamPapers(List<dynamic> papersJson) {
  try {
    if (papersJson.isEmpty) return [];
    return papersJson.map((paperJson) {
      return AdaptedExamPaper(
        id: paperJson['id'] as String? ?? 'unknown_paper',
        title: paperJson['title'] as String? ?? 'Untitled Paper',
        examType: paperJson['examType'] as String? ?? 'written',
        questions: paperJson['questions'] as List? ?? [],
        duration: (paperJson['duration'] as num?)?.toInt() ?? 120,
        totalMarks: (paperJson['totalMarks'] as num?)?.toInt() ?? 100,
        instructions: paperJson['instructions'] as String? ?? '',
        allowedMaterials: List<String>.from(paperJson['allowedMaterials'] ?? []),
      );
    }).toList();
  } catch (e) {
    print('Error adapting exam papers: $e');
    return [];
  }
}

static List<AdaptedActivity> _adaptActivities(List<dynamic> activitiesJson) {
  try {
    if (activitiesJson.isEmpty) return [];
    return activitiesJson.map((activityJson) {
      return AdaptedActivity(
        id: activityJson['id'] as String? ?? 'unknown_activity',
        title: activityJson['title'] as String? ?? 'Untitled Activity',
        type: activityJson['type'] as String? ?? 'practical',
        description: activityJson['description'] as String? ?? '',
        duration: activityJson['duration'] as String? ?? '60 min',
        materialsNeeded: List<String>.from(activityJson['materialsNeeded'] ?? []),
        learningOutcome: activityJson['learningOutcome'] as String? ?? '',
        steps: _adaptActivitySteps(activityJson['steps'] as List? ?? []),
      );
    }).toList();
  } catch (e) {
    print('Error adapting activities: $e');
    return [];
  }
}

static List<AdaptedActivityStep> _adaptActivitySteps(List<dynamic> stepsJson) {
  try {
    if (stepsJson.isEmpty) return [];
    return stepsJson.map((stepJson) {
      return AdaptedActivityStep(
        stepNumber: (stepJson['stepNumber'] as num?)?.toInt() ?? 1,
        instruction: stepJson['instruction'] as String? ?? 'Instruction',
        timeAllocation: stepJson['timeAllocation'] as String?,
        facilitatorNote: stepJson['facilitatorNote'] as String?,
      );
    }).toList();
  } catch (e) {
    print('Error adapting activity steps: $e');
    return [];
  }
}

static List<AdaptedDigitalResource> _adaptDigitalResources(List<dynamic> resourcesJson) {
  try {
    if (resourcesJson.isEmpty) return [];
    return resourcesJson.map((resJson) {
      return AdaptedDigitalResource(
        title: resJson['title'] as String? ?? 'Untitled Resource',
        url: resJson['url'] as String? ?? '',
        type: resJson['type'] as String? ?? 'textbook',
        description: resJson['description'] as String?,
        accessType: resJson['accessType'] as String?,
        format: resJson['format'] as String?,
      );
    }).toList();
  } catch (e) {
    print('Error adapting digital resources: $e');
    return [];
  }
}

static List<AdaptedEquipment> _adaptEquipment(List<dynamic> equipmentJson) {
  try {
    if (equipmentJson.isEmpty) return [];
    return equipmentJson.map((eqJson) {
      return AdaptedEquipment(
        name: eqJson['name'] as String? ?? 'Unknown Equipment',
        description: eqJson['description'] as String? ?? '',
        quantity: (eqJson['quantity'] as num?)?.toInt() ?? 1,
        specifications: eqJson['specifications'] as String? ?? '',
        safetyLevel: eqJson['safetyLevel'] as String? ?? 'Low',
      );
    }).toList();
  } catch (e) {
    print('Error adapting equipment: $e');
    return [];
  }
}

static List<AdaptedSoftwareTool> _adaptSoftwareTools(List<dynamic> toolsJson) {
  try {
    if (toolsJson.isEmpty) return [];
    return toolsJson.map((toolJson) {
      return AdaptedSoftwareTool(
        name: toolJson['name'] as String? ?? 'Unknown Tool',
        version: toolJson['version'] as String? ?? '1.0',
        purpose: toolJson['purpose'] as String? ?? '',
        license: toolJson['license'] as String? ?? 'Free',
        systemRequirements: toolJson['systemRequirements'] as String? ?? '',
      );
    }).toList();
  } catch (e) {
    print('Error adapting software tools: $e');
    return [];
  }
}

static List<AdaptedTermSchedule> _adaptTermSchedules(List<dynamic> termsJson) {
  try {
    if (termsJson.isEmpty) return [];
    return termsJson.map((termJson) {
      return AdaptedTermSchedule(
        term: (termJson['term'] as num?)?.toInt() ?? 1,
        duration: termJson['duration'] as String? ?? '12 weeks',
        weeks: (termJson['weeks'] as num?)?.toInt() ?? 12,
        startDate: DateTime.tryParse(termJson['startDate'] as String? ?? '2023-09-04') ?? DateTime(2023, 9, 4),
        endDate: DateTime.tryParse(termJson['endDate'] as String? ?? '2023-12-15') ?? DateTime(2023, 12, 15),
        holidays: List<String>.from(termJson['holidays'] ?? []),
      );
    }).toList();
  } catch (e) {
    print('Error adapting term schedules: $e');
    return [];
  }
}
}
