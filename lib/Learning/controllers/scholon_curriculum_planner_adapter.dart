extension AdaptedReferenceExtensions on AdaptedReference {
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'url': url,
      'type': type,
    };
  }
}

extension AdaptedQuestionExtensions on AdaptedQuestion {
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options.map((opt) => opt.toJson()).toList(),
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'scholonBloomLevel': scholonBloomLevel,
      'points': points,
      'questionType': questionType,
      'tags': tags,
    };
  }
}

extension AdaptedQuestionOptionExtensions on AdaptedQuestionOption {
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'isCorrect': isCorrect,
    };
  }
}

extension AdaptedNoteExtensions on AdaptedNote {
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'duration': duration,
      'difficulty': difficulty,
      'keyConcepts': keyConcepts,
      'learningTags': learningTags,
      'contentType': contentType,
      'references': references.map((ref) => ref.toJson()).toList(),
    };
  }
}

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

class AdaptedTerm {
  final String id;
  final String term;
  final String duration;
  final String focus;
  final AdaptedLearningObjectives objectives;
  final List<AdaptedWeek> weeks;

  AdaptedTerm({
    required this.id,
    required this.term,
    required this.duration,
    required this.focus,
    required this.objectives,
    required this.weeks,
  });
}

class AdaptedLearningObjectives {
  final List<String> knowledgeObjectives;
  final List<String> skillObjectives;
  final List<String> attitudeObjectives;

  AdaptedLearningObjectives({
    required this.knowledgeObjectives,
    required this.skillObjectives,
    required this.attitudeObjectives,
  });
}

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

class AdaptedNote {
  final String id;
  final String title;
  final String content;
  final String duration;
  final String difficulty;
  final List<String> keyConcepts;
  final List<String> learningTags;
  final String contentType;
  final List<AdaptedReference> references;

  AdaptedNote({
    required this.id,
    required this.title,
    required this.content,
    required this.duration,
    required this.difficulty,
    required this.keyConcepts,
    required this.learningTags,
    required this.contentType,
    required this.references,
  });
}

class AdaptedReference {
  final String title;
  final String url;
  final String type;

  AdaptedReference({
    required this.title,
    required this.url,
    required this.type,
  });
}

class AdaptedQuiz {
  final String id;
  final String title;
  final String description;
  final List<AdaptedQuestion> questions;
  final int duration;
  final int passingScore;
  final int maxAttempts;
  final bool isTimed;
  final String quizType;

  AdaptedQuiz({
    required this.id,
    required this.title,
    required this.description,
    required this.questions,
    required this.duration,
    required this.passingScore,
    required this.maxAttempts,
    required this.isTimed,
    required this.quizType,
  });
}

class AdaptedQuestion {
  final String id;
  final String question;
  final List<AdaptedQuestionOption> options;
  final int correctAnswer;
  final String explanation;
  final String scholonBloomLevel;
  final int points;
  final String questionType;
  final List<String> tags;

  AdaptedQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.scholonBloomLevel,
    required this.points,
    required this.questionType,
    required this.tags,
  });
}

class AdaptedQuestionOption {
  final String id;
  final String text;
  final bool isCorrect;

  AdaptedQuestionOption({
    required this.id,
    required this.text,
    required this.isCorrect,
  });
}

class AdaptedAssignment {
  final String id;
  final String title;
  final String type;
  final String description;
  final List<String> requirements;
  final String submissionFormat;
  final String deadline;
  final int totalPoints;
  final dynamic rubric;
  final List<AdaptedAssignmentQuestion>? questions;
  final List<AdaptedSubmissionCriteria> submissionCriteria;
  final String difficulty;
  final List<String> skillsDeveloped;

  AdaptedAssignment({
    required this.id,
    required this.title,
    required this.type,
    required this.description,
    required this.requirements,
    required this.submissionFormat,
    required this.deadline,
    required this.totalPoints,
    this.rubric,
    this.questions,
    required this.submissionCriteria,
    required this.difficulty,
    required this.skillsDeveloped,
  });
}

class AdaptedAssignmentQuestion {
  final String question;
  final String? solutionHint;
  final int points;
  final String questionType;
  final List<String>? parts;

  AdaptedAssignmentQuestion({
    required this.question,
    this.solutionHint,
    required this.points,
    required this.questionType,
    this.parts,
  });
}

class AdaptedSubmissionCriteria {
  final String criterion;
  final int maxPoints;
  final String description;

  AdaptedSubmissionCriteria({
    required this.criterion,
    required this.maxPoints,
    required this.description,
  });
}

class AdaptedExamStructure {
  final String id;
  final List<AdaptedExamPaper> papers;
  final AdaptedExamMetadata metadata;

  AdaptedExamStructure({
    required this.id,
    required this.papers,
    required this.metadata,
  });
}

class AdaptedExamPaper {
  final String id;
  final String title;
  final String examType;
  final List<dynamic> questions;
  final int duration;
  final int totalMarks;
  final String instructions;
  final List<String> allowedMaterials;

  AdaptedExamPaper({
    required this.id,
    required this.title,
    required this.examType,
    required this.questions,
    required this.duration,
    required this.totalMarks,
    required this.instructions,
    required this.allowedMaterials,
  });
}

class AdaptedExamMetadata {
  final int totalPapers;
  final int totalQuestions;
  final int totalMarks;
  final String examFormat;
  final String gradingPolicy;

  AdaptedExamMetadata({
    required this.totalPapers,
    required this.totalQuestions,
    required this.totalMarks,
    required this.examFormat,
    required this.gradingPolicy,
  });
}

class AdaptedActivity {
  final String id;
  final String title;
  final String type;
  final String description;
  final String duration;
  final List<String> materialsNeeded;
  final String learningOutcome;
  final List<AdaptedActivityStep> steps;

  AdaptedActivity({
    required this.id,
    required this.title,
    required this.type,
    required this.description,
    required this.duration,
    required this.materialsNeeded,
    required this.learningOutcome,
    required this.steps,
  });
}

class AdaptedActivityStep {
  final int stepNumber;
  final String instruction;
  final String? timeAllocation;
  final String? facilitatorNote;

  AdaptedActivityStep({
    required this.stepNumber,
    required this.instruction,
    this.timeAllocation,
    this.facilitatorNote,
  });
}

class AdaptedAssessmentStructure {
  final int continuousAssessment;
  final int termlyExaminations;
  final Map<String, String> gradingScale;
  final Map<String, int> weightDistribution;

  AdaptedAssessmentStructure({
    required this.continuousAssessment,
    required this.termlyExaminations,
    required this.gradingScale,
    required this.weightDistribution,
  });
}

class AdaptedLearningOutcomes {
  final List<String> cognitiveSkills;
  final List<String> practicalSkills;
  final List<String> softSkills;
  final List<String> scholonCompetencies;

  AdaptedLearningOutcomes({
    required this.cognitiveSkills,
    required this.practicalSkills,
    required this.softSkills,
    required this.scholonCompetencies,
  });
}

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