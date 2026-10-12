import 'dart:convert';

// Main data classes
class ScholonCurriculum {
  final String curriculum;
  final String academicYear;
  final String schoolLevel;
  final List<Course> courses;
  final AssessmentStructure assessmentStructure;
  final LearningOutcomes learningOutcomes;
  final ScholonResources resources;
  final Schedule schedule;

  ScholonCurriculum({
    required this.curriculum,
    required this.academicYear,
    required this.schoolLevel,
    required this.courses,
    required this.assessmentStructure,
    required this.learningOutcomes,
    required this.resources,
    required this.schedule,
  });

  factory ScholonCurriculum.fromJson(Map<String, dynamic> json) {
    return ScholonCurriculum(
      curriculum: json['curriculum'] as String,
      academicYear: json['academicYear'] as String,
      schoolLevel: json['schoolLevel'] as String,
      courses: (json['courses'] as List)
          .map((course) => Course.fromJson(course))
          .toList(),
      assessmentStructure:
          AssessmentStructure.fromJson(json['assessmentStructure']),
      learningOutcomes: LearningOutcomes.fromJson(json['learningOutcomes']),
      resources: ScholonResources.fromJson(json['resources']),
      schedule: Schedule.fromJson(json['schedule']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'curriculum': curriculum,
      'academicYear': academicYear,
      'schoolLevel': schoolLevel,
      'courses': courses.map((course) => course.toJson()).toList(),
      'assessmentStructure': assessmentStructure.toJson(),
      'learningOutcomes': learningOutcomes.toJson(),
      'resources': resources.toJson(),
      'schedule': schedule.toJson(),
    };
  }

  String toJsonString() => jsonEncode(toJson());

  @override
  String toString() {
    return 'ScholonCurriculum{curriculum: $curriculum, year: $academicYear, courses: ${courses.length}}';
  }
}

// Course Classes
class Course {
  final String id;
  final String courseCode;
  final String name;
  final String description;
  final String strand;
  final double credits;
  final String scholonLevel;
  final List<CourseTerm> terms;
  final CourseMetadata metadata;

  Course({
    required this.id,
    required this.courseCode,
    required this.name,
    required this.description,
    required this.strand,
    required this.credits,
    required this.scholonLevel,
    required this.terms,
    required this.metadata,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as String,
      courseCode: json['courseCode'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      strand: json['strand'] as String,
      credits: (json['credits'] as num).toDouble(),
      scholonLevel: json['scholonLevel'] as String,
      terms: (json['terms'] as List)
          .map((term) => CourseTerm.fromJson(term))
          .toList(),
      metadata: CourseMetadata.fromJson(json['metadata']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseCode': courseCode,
      'name': name,
      'description': description,
      'strand': strand,
      'credits': credits,
      'scholonLevel': scholonLevel,
      'terms': terms.map((term) => term.toJson()).toList(),
      'metadata': metadata.toJson(),
    };
  }

  int get totalWeeks {
    return terms.fold(0, (sum, term) => sum + term.weeks.length);
  }

  int get totalAssignments {
    return terms
        .expand((term) => term.weeks)
        .fold(0, (sum, week) => sum + week.assignments.length);
  }
}

class CourseMetadata {
  final String difficulty;
  final List<String> prerequisites;
  final String targetAudience;
  final String version;
  final DateTime lastUpdated;
  final String instructor;
  final String department;

  CourseMetadata({
    required this.difficulty,
    required this.prerequisites,
    required this.targetAudience,
    required this.version,
    required this.lastUpdated,
    required this.instructor,
    required this.department,
  });

  factory CourseMetadata.fromJson(Map<String, dynamic> json) {
    return CourseMetadata(
      difficulty: json['difficulty'] as String,
      prerequisites: (json['prerequisites'] as List)
          .map((prereq) => prereq as String)
          .toList(),
      targetAudience: json['targetAudience'] as String,
      version: json['version'] as String,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      instructor: json['instructor'] as String,
      department: json['department'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'difficulty': difficulty,
      'prerequisites': prerequisites,
      'targetAudience': targetAudience,
      'version': version,
      'lastUpdated': lastUpdated.toIso8601String(),
      'instructor': instructor,
      'department': department,
    };
  }
}

class CourseTerm {
  final String id;
  final String term;
  final String duration;
  final String focus;
  final List<CourseWeek> weeks;
  final TermObjectives objectives;

  CourseTerm({
    required this.id,
    required this.term,
    required this.duration,
    required this.focus,
    required this.weeks,
    required this.objectives,
  });

  factory CourseTerm.fromJson(Map<String, dynamic> json) {
    return CourseTerm(
      id: json['id'] as String,
      term: json['term'] as String,
      duration: json['duration'] as String,
      focus: json['focus'] as String,
      weeks: (json['weeks'] as List)
          .map((week) => CourseWeek.fromJson(week))
          .toList(),
      objectives: TermObjectives.fromJson(json['objectives']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'term': term,
      'duration': duration,
      'focus': focus,
      'weeks': weeks.map((week) => week.toJson()).toList(),
      'objectives': objectives.toJson(),
    };
  }
}

class TermObjectives {
  final List<String> knowledgeObjectives;
  final List<String> skillObjectives;
  final List<String> attitudeObjectives;

  TermObjectives({
    required this.knowledgeObjectives,
    required this.skillObjectives,
    required this.attitudeObjectives,
  });

  factory TermObjectives.fromJson(Map<String, dynamic> json) {
    return TermObjectives(
      knowledgeObjectives: (json['knowledgeObjectives'] as List)
          .map((obj) => obj as String)
          .toList(),
      skillObjectives: (json['skillObjectives'] as List)
          .map((obj) => obj as String)
          .toList(),
      attitudeObjectives: (json['attitudeObjectives'] as List)
          .map((obj) => obj as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'knowledgeObjectives': knowledgeObjectives,
      'skillObjectives': skillObjectives,
      'attitudeObjectives': attitudeObjectives,
    };
  }
}

class CourseWeek {
  final int weekNumber;
  final String topic;
  final String overview;
  final List<String> coreCompetencies;
  final String scholonStandard;
  final List<LearningNote> notes;
  final List<CourseQuiz> quizzes;
  final List<CourseAssignment> assignments;
  final WeekExams exams;
  final List<WeekActivity> activities;

  CourseWeek({
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

  factory CourseWeek.fromJson(Map<String, dynamic> json) {
    return CourseWeek(
      weekNumber: json['weekNumber'] as int,
      topic: json['topic'] as String,
      overview: json['overview'] as String,
      coreCompetencies: (json['coreCompetencies'] as List)
          .map((competency) => competency as String)
          .toList(),
      scholonStandard: json['scholonStandard'] as String,
      notes: (json['notes'] as List)
          .map((note) => LearningNote.fromJson(note))
          .toList(),
      quizzes: (json['quizzes'] as List)
          .map((quiz) => CourseQuiz.fromJson(quiz))
          .toList(),
      assignments: (json['assignments'] as List)
          .map((assignment) => CourseAssignment.fromJson(assignment))
          .toList(),
      exams: WeekExams.fromJson(json['exams']),
      activities: (json['activities'] as List)
          .map((activity) => WeekActivity.fromJson(activity))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weekNumber': weekNumber,
      'topic': topic,
      'overview': overview,
      'coreCompetencies': coreCompetencies,
      'scholonStandard': scholonStandard,
      'notes': notes.map((note) => note.toJson()).toList(),
      'quizzes': quizzes.map((quiz) => quiz.toJson()).toList(),
      'assignments': assignments.map((assignment) => assignment.toJson()).toList(),
      'exams': exams.toJson(),
      'activities': activities.map((activity) => activity.toJson()).toList(),
    };
  }
}

// Content Classes
class LearningNote {
  final String id;
  final String title;
  final String content;
  final String duration;
  final String difficulty;
  final List<String> keyConcepts;
  final List<String> learningTags;
  final String contentType; // theory, example, summary, formula, etc.
  final List<Reference> references;

  LearningNote({
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

  factory LearningNote.fromJson(Map<String, dynamic> json) {
    return LearningNote(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      duration: json['duration'] as String,
      difficulty: json['difficulty'] as String,
      keyConcepts: (json['keyConcepts'] as List)
          .map((concept) => concept as String)
          .toList(),
      learningTags: (json['learningTags'] as List)
          .map((tag) => tag as String)
          .toList(),
      contentType: json['contentType'] as String,
      references: (json['references'] as List)
          .map((ref) => Reference.fromJson(ref))
          .toList(),
    );
  }

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

class Reference {
  final String title;
  final String url;
  final String type; // book, website, video, journal, etc.

  Reference({
    required this.title,
    required this.url,
    required this.type,
  });

  factory Reference.fromJson(Map<String, dynamic> json) {
    return Reference(
      title: json['title'] as String,
      url: json['url'] as String,
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'url': url,
      'type': type,
    };
  }
}

class CourseQuiz {
  final String id;
  final String title;
  final String description;
  final List<QuizQuestion> questions;
  final int duration; // minutes
  final int passingScore;
  final int maxAttempts;
  final bool isTimed;
  final String quizType; // formative, summative, practice

  CourseQuiz({
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

  factory CourseQuiz.fromJson(Map<String, dynamic> json) {
    return CourseQuiz(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      questions: (json['questions'] as List)
          .map((question) => QuizQuestion.fromJson(question))
          .toList(),
      duration: json['duration'] as int,
      passingScore: json['passingScore'] as int,
      maxAttempts: json['maxAttempts'] as int,
      isTimed: json['isTimed'] as bool,
      quizType: json['quizType'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'questions': questions.map((question) => question.toJson()).toList(),
      'duration': duration,
      'passingScore': passingScore,
      'maxAttempts': maxAttempts,
      'isTimed': isTimed,
      'quizType': quizType,
    };
  }
}

class QuizQuestion {
  final String id;
  final String question;
  final List<QuizOption> options;
  final dynamic correctAnswer; // Could be int, String, List<int> for multiple
  final String explanation;
  final String scholonBloomLevel;
  final int points;
  final String questionType; // multiple_choice, true_false, fill_blank
  final String? solutionHint;
  final List<String> tags;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.scholonBloomLevel,
    required this.points,
    required this.questionType,
    this.solutionHint,
    required this.tags,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] as String,
      question: json['question'] as String,
      options: (json['options'] as List)
          .map((option) => QuizOption.fromJson(option))
          .toList(),
      correctAnswer: json['correctAnswer'],
      explanation: json['explanation'] as String,
      scholonBloomLevel: json['scholonBloomLevel'] as String,
      points: json['points'] as int,
      questionType: json['questionType'] as String,
      solutionHint: json['solutionHint'] as String?,
      tags: (json['tags'] as List).map((tag) => tag as String).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options.map((option) => option.toJson()).toList(),
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'scholonBloomLevel': scholonBloomLevel,
      'points': points,
      'questionType': questionType,
      if (solutionHint != null) 'solutionHint': solutionHint,
      'tags': tags,
    };
  }
}

class QuizOption {
  final String id;
  final String text;
  final bool isCorrect;

  QuizOption({
    required this.id,
    required this.text,
    required this.isCorrect,
  });

  factory QuizOption.fromJson(Map<String, dynamic> json) {
    return QuizOption(
      id: json['id'] as String,
      text: json['text'] as String,
      isCorrect: json['isCorrect'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'isCorrect': isCorrect,
    };
  }
}

class CourseAssignment {
  final String id;
  final String title;
  final String type; // research, problem_solving, project, presentation
  final String description;
  final List<String> requirements;
  final String submissionFormat;
  final String deadline;
  final int totalPoints;
  final dynamic rubric; // Can be Map<String, int> or AssignmentRubric
  final List<AssignmentQuestion>? questions;
  final List<SubmissionCriteria> submissionCriteria;
  final String difficulty;
  final List<String> skillsDeveloped;

  CourseAssignment({
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

  factory CourseAssignment.fromJson(Map<String, dynamic> json) {
    return CourseAssignment(
      id: json['id'] as String,
      title: json['title'] as String,
      type: json['type'] as String,
      description: json['description'] as String,
      requirements: (json['requirements'] as List)
          .map((req) => req as String)
          .toList(),
      submissionFormat: json['submissionFormat'] as String,
      deadline: json['deadline'] as String,
      totalPoints: json['totalPoints'] as int,
      rubric: json['rubric'],
      questions: json['questions'] != null
          ? (json['questions'] as List)
              .map((q) => AssignmentQuestion.fromJson(q))
              .toList()
          : null,
      submissionCriteria: (json['submissionCriteria'] as List)
          .map((criteria) => SubmissionCriteria.fromJson(criteria))
          .toList(),
      difficulty: json['difficulty'] as String,
      skillsDeveloped: (json['skillsDeveloped'] as List)
          .map((skill) => skill as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'description': description,
      'requirements': requirements,
      'submissionFormat': submissionFormat,
      'deadline': deadline,
      'totalPoints': totalPoints,
      if (rubric != null) 'rubric': rubric,
      if (questions != null)
        'questions': questions!.map((q) => q.toJson()).toList(),
      'submissionCriteria':
          submissionCriteria.map((c) => c.toJson()).toList(),
      'difficulty': difficulty,
      'skillsDeveloped': skillsDeveloped,
    };
  }
}

class SubmissionCriteria {
  final String criterion;
  final int maxPoints;
  final String description;

  SubmissionCriteria({
    required this.criterion,
    required this.maxPoints,
    required this.description,
  });

  factory SubmissionCriteria.fromJson(Map<String, dynamic> json) {
    return SubmissionCriteria(
      criterion: json['criterion'] as String,
      maxPoints: json['maxPoints'] as int,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'criterion': criterion,
      'maxPoints': maxPoints,
      'description': description,
    };
  }
}

class AssignmentQuestion {
  final String question;
  final String? solutionHint;
  final int points;
  final String questionType;
  final List<String>? parts;

  AssignmentQuestion({
    required this.question,
    this.solutionHint,
    required this.points,
    required this.questionType,
    this.parts,
  });

  factory AssignmentQuestion.fromJson(Map<String, dynamic> json) {
    return AssignmentQuestion(
      question: json['question'] as String,
      solutionHint: json['solutionHint'] as String?,
      points: json['points'] as int,
      questionType: json['questionType'] as String,
      parts: json['parts'] != null
          ? (json['parts'] as List).map((part) => part as String).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      if (solutionHint != null) 'solutionHint': solutionHint,
      'points': points,
      'questionType': questionType,
      if (parts != null) 'parts': parts,
    };
  }
}

class AssignmentRubric {
  final int researchDepth;
  final int criticalAnalysis;
  final int writingQuality;
  final int referencing;
  final int creativity;
  final int technicalAccuracy;

  AssignmentRubric({
    required this.researchDepth,
    required this.criticalAnalysis,
    required this.writingQuality,
    required this.referencing,
    required this.creativity,
    required this.technicalAccuracy,
  });

  factory AssignmentRubric.fromJson(Map<String, dynamic> json) {
    return AssignmentRubric(
      researchDepth: json['researchDepth'] as int,
      criticalAnalysis: json['criticalAnalysis'] as int,
      writingQuality: json['writingQuality'] as int,
      referencing: json['referencing'] as int,
      creativity: json['creativity'] as int,
      technicalAccuracy: json['technicalAccuracy'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'researchDepth': researchDepth,
      'criticalAnalysis': criticalAnalysis,
      'writingQuality': writingQuality,
      'referencing': referencing,
      'creativity': creativity,
      'technicalAccuracy': technicalAccuracy,
    };
  }
}

class WeekExams {
  final String id;
  final List<ExamPaper> papers;
  final ExamMetadata metadata;

  WeekExams({
    required this.id,
    required this.papers,
    required this.metadata,
  });

  factory WeekExams.fromJson(Map<String, dynamic> json) {
    return WeekExams(
      id: json['id'] as String,
      papers: (json['papers'] as List)
          .map((paper) => ExamPaper.fromJson(paper))
          .toList(),
      metadata: ExamMetadata.fromJson(json['metadata']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'papers': papers.map((paper) => paper.toJson()).toList(),
      'metadata': metadata.toJson(),
    };
  }
}

class ExamPaper {
  final String id;
  final String title;
  final String examType; // multiple_choice, essay, practical, oral
  final List<dynamic> questions; // Can be List<ExamQuestion> or List<dynamic>
  final int duration; // minutes
  final int totalMarks;
  final String instructions;
  final List<String> allowedMaterials;

  ExamPaper({
    required this.id,
    required this.title,
    required this.examType,
    required this.questions,
    required this.duration,
    required this.totalMarks,
    required this.instructions,
    required this.allowedMaterials,
  });

  factory ExamPaper.fromJson(Map<String, dynamic> json) {
    return ExamPaper(
      id: json['id'] as String,
      title: json['title'] as String,
      examType: json['examType'] as String,
      questions: json['questions'] as List,
      duration: json['duration'] as int,
      totalMarks: json['totalMarks'] as int,
      instructions: json['instructions'] as String,
      allowedMaterials: (json['allowedMaterials'] as List)
          .map((material) => material as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'examType': examType,
      'questions': questions,
      'duration': duration,
      'totalMarks': totalMarks,
      'instructions': instructions,
      'allowedMaterials': allowedMaterials,
    };
  }
}

class ExamQuestion {
  final String id;
  final String question;
  final List<dynamic>? options;
  final dynamic correctAnswer;
  final String solutionSteps;
  final int marks;
  final String scholonBloomLevel;
  final String questionType;
  final int? wordLimit; // For essay questions
  final List<String>? subQuestions;

  ExamQuestion({
    required this.id,
    required this.question,
    this.options,
    required this.correctAnswer,
    required this.solutionSteps,
    required this.marks,
    required this.scholonBloomLevel,
    required this.questionType,
    this.wordLimit,
    this.subQuestions,
  });

  factory ExamQuestion.fromJson(Map<String, dynamic> json) {
    return ExamQuestion(
      id: json['id'] as String,
      question: json['question'] as String,
      options: json['options'] as List<dynamic>?,
      correctAnswer: json['correctAnswer'],
      solutionSteps: json['solutionSteps'] as String,
      marks: json['marks'] as int,
      scholonBloomLevel: json['scholonBloomLevel'] as String,
      questionType: json['questionType'] as String,
      wordLimit: json['wordLimit'] as int?,
      subQuestions: json['subQuestions'] != null
          ? (json['subQuestions'] as List)
              .map((sq) => sq as String)
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      if (options != null) 'options': options,
      'correctAnswer': correctAnswer,
      'solutionSteps': solutionSteps,
      'marks': marks,
      'scholonBloomLevel': scholonBloomLevel,
      'questionType': questionType,
      if (wordLimit != null) 'wordLimit': wordLimit,
      if (subQuestions != null) 'subQuestions': subQuestions,
    };
  }
}

class ExamOption {
  final String id;
  final String text;

  ExamOption({
    required this.id,
    required this.text,
  });

  factory ExamOption.fromJson(Map<String, dynamic> json) {
    return ExamOption(
      id: json['id'] as String,
      text: json['text'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
    };
  }
}

class ExamMetadata {
  final int totalPapers;
  final int totalQuestions;
  final int totalMarks;
  final String examFormat;
  final String gradingPolicy;

  ExamMetadata({
    required this.totalPapers,
    required this.totalQuestions,
    required this.totalMarks,
    required this.examFormat,
    required this.gradingPolicy,
  });

  factory ExamMetadata.fromJson(Map<String, dynamic> json) {
    return ExamMetadata(
      totalPapers: json['totalPapers'] as int,
      totalQuestions: json['totalQuestions'] as int,
      totalMarks: json['totalMarks'] as int,
      examFormat: json['examFormat'] as String,
      gradingPolicy: json['gradingPolicy'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalPapers': totalPapers,
      'totalQuestions': totalQuestions,
      'totalMarks': totalMarks,
      'examFormat': examFormat,
      'gradingPolicy': gradingPolicy,
    };
  }
}

class WeekActivity {
  final String id;
  final String title;
  final String type; // discussion, group_work, lab, field_trip, project
  final String description;
  final String duration;
  final List<String> materialsNeeded;
  final String learningOutcome;
  final List<ActivityStep> steps;

  WeekActivity({
    required this.id,
    required this.title,
    required this.type,
    required this.description,
    required this.duration,
    required this.materialsNeeded,
    required this.learningOutcome,
    required this.steps,
  });

  factory WeekActivity.fromJson(Map<String, dynamic> json) {
    return WeekActivity(
      id: json['id'] as String,
      title: json['title'] as String,
      type: json['type'] as String,
      description: json['description'] as String,
      duration: json['duration'] as String,
      materialsNeeded: (json['materialsNeeded'] as List)
          .map((material) => material as String)
          .toList(),
      learningOutcome: json['learningOutcome'] as String,
      steps: (json['steps'] as List)
          .map((step) => ActivityStep.fromJson(step))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'description': description,
      'duration': duration,
      'materialsNeeded': materialsNeeded,
      'learningOutcome': learningOutcome,
      'steps': steps.map((step) => step.toJson()).toList(),
    };
  }
}

class ActivityStep {
  final int stepNumber;
  final String instruction;
  final String? timeAllocation;
  final String? facilitatorNote;

  ActivityStep({
    required this.stepNumber,
    required this.instruction,
    this.timeAllocation,
    this.facilitatorNote,
  });

  factory ActivityStep.fromJson(Map<String, dynamic> json) {
    return ActivityStep(
      stepNumber: json['stepNumber'] as int,
      instruction: json['instruction'] as String,
      timeAllocation: json['timeAllocation'] as String?,
      facilitatorNote: json['facilitatorNote'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stepNumber': stepNumber,
      'instruction': instruction,
      if (timeAllocation != null) 'timeAllocation': timeAllocation,
      if (facilitatorNote != null) 'facilitatorNote': facilitatorNote,
    };
  }
}

// Supporting Structure Classes
class AssessmentStructure {
  final int continuousAssessment;
  final int termlyExaminations;
  final Map<String, String> gradingScale;
  final Map<String, int> weightDistribution;

  AssessmentStructure({
    required this.continuousAssessment,
    required this.termlyExaminations,
    required this.gradingScale,
    required this.weightDistribution,
  });

  factory AssessmentStructure.fromJson(Map<String, dynamic> json) {
    return AssessmentStructure(
      continuousAssessment: json['continuousAssessment'] as int,
      termlyExaminations: json['termlyExaminations'] as int,
      gradingScale: Map<String, String>.from(json['gradingScale']),
      weightDistribution: Map<String, int>.from(json['weightDistribution']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'continuousAssessment': continuousAssessment,
      'termlyExaminations': termlyExaminations,
      'gradingScale': gradingScale,
      'weightDistribution': weightDistribution,
    };
  }
}

class LearningOutcomes {
  final List<String> cognitiveSkills;
  final List<String> practicalSkills;
  final List<String> softSkills;
  final List<String> scholonCompetencies;

  LearningOutcomes({
    required this.cognitiveSkills,
    required this.practicalSkills,
    required this.softSkills,
    required this.scholonCompetencies,
  });

  factory LearningOutcomes.fromJson(Map<String, dynamic> json) {
    return LearningOutcomes(
      cognitiveSkills: (json['cognitiveSkills'] as List)
          .map((skill) => skill as String)
          .toList(),
      practicalSkills: (json['practicalSkills'] as List)
          .map((skill) => skill as String)
          .toList(),
      softSkills: (json['softSkills'] as List)
          .map((skill) => skill as String)
          .toList(),
      scholonCompetencies: (json['scholonCompetencies'] as List)
          .map((competency) => competency as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cognitiveSkills': cognitiveSkills,
      'practicalSkills': practicalSkills,
      'softSkills': softSkills,
      'scholonCompetencies': scholonCompetencies,
    };
  }
}

class ScholonResources {
  final List<DigitalResource> textbooks;
  final List<DigitalResource> digitalResources;
  final List<Equipment> laboratoryEquipment;
  final List<SoftwareTool> softwareTools;

  ScholonResources({
    required this.textbooks,
    required this.digitalResources,
    required this.laboratoryEquipment,
    required this.softwareTools,
  });

  factory ScholonResources.fromJson(Map<String, dynamic> json) {
    return ScholonResources(
      textbooks: (json['textbooks'] as List)
          .map((book) => DigitalResource.fromJson(book))
          .toList(),
      digitalResources: (json['digitalResources'] as List)
          .map((resource) => DigitalResource.fromJson(resource))
          .toList(),
      laboratoryEquipment: (json['laboratoryEquipment'] as List)
          .map((equipment) => Equipment.fromJson(equipment))
          .toList(),
      softwareTools: (json['softwareTools'] as List)
          .map((tool) => SoftwareTool.fromJson(tool))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'textbooks': textbooks.map((book) => book.toJson()).toList(),
      'digitalResources': digitalResources.map((res) => res.toJson()).toList(),
      'laboratoryEquipment':
          laboratoryEquipment.map((eq) => eq.toJson()).toList(),
      'softwareTools': softwareTools.map((tool) => tool.toJson()).toList(),
    };
  }
}

class DigitalResource {
  final String title;
  final String url;
  final String type;
  final String? description;
  final String? accessType; // free, subscription, institutional
  final String? format; // pdf, video, interactive, etc.

  DigitalResource({
    required this.title,
    required this.url,
    required this.type,
    this.description,
    this.accessType,
    this.format,
  });

  factory DigitalResource.fromJson(Map<String, dynamic> json) {
    return DigitalResource(
      title: json['title'] as String,
      url: json['url'] as String,
      type: json['type'] as String,
      description: json['description'] as String?,
      accessType: json['accessType'] as String?,
      format: json['format'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'url': url,
      'type': type,
      if (description != null) 'description': description,
      if (accessType != null) 'accessType': accessType,
      if (format != null) 'format': format,
    };
  }
}

class Equipment {
  final String name;
  final String description;
  final int quantity;
  final String specifications;
  final String safetyLevel;

  Equipment({
    required this.name,
    required this.description,
    required this.quantity,
    required this.specifications,
    required this.safetyLevel,
  });

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      name: json['name'] as String,
      description: json['description'] as String,
      quantity: json['quantity'] as int,
      specifications: json['specifications'] as String,
      safetyLevel: json['safetyLevel'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'quantity': quantity,
      'specifications': specifications,
      'safetyLevel': safetyLevel,
    };
  }
}

class SoftwareTool {
  final String name;
  final String version;
  final String purpose;
  final String license;
  final String systemRequirements;

  SoftwareTool({
    required this.name,
    required this.version,
    required this.purpose,
    required this.license,
    required this.systemRequirements,
  });

  factory SoftwareTool.fromJson(Map<String, dynamic> json) {
    return SoftwareTool(
      name: json['name'] as String,
      version: json['version'] as String,
      purpose: json['purpose'] as String,
      license: json['license'] as String,
      systemRequirements: json['systemRequirements'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'version': version,
      'purpose': purpose,
      'license': license,
      'systemRequirements': systemRequirements,
    };
  }
}

class Schedule {
  final List<TermSchedule> terms;
  final int totalWeeks;
  final int totalHours;
  final int contactHoursPerWeek;
  final DateTime startDate;
  final DateTime endDate;

  Schedule({
    required this.terms,
    required this.totalWeeks,
    required this.totalHours,
    required this.contactHoursPerWeek,
    required this.startDate,
    required this.endDate,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      terms: (json['terms'] as List)
          .map((term) => TermSchedule.fromJson(term))
          .toList(),
      totalWeeks: json['totalWeeks'] as int,
      totalHours: json['totalHours'] as int,
      contactHoursPerWeek: json['contactHoursPerWeek'] as int,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'terms': terms.map((term) => term.toJson()).toList(),
      'totalWeeks': totalWeeks,
      'totalHours': totalHours,
      'contactHoursPerWeek': contactHoursPerWeek,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }
}

class TermSchedule {
  final int term;
  final String duration;
  final int weeks;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> holidays;

  TermSchedule({
    required this.term,
    required this.duration,
    required this.weeks,
    required this.startDate,
    required this.endDate,
    required this.holidays,
  });

  factory TermSchedule.fromJson(Map<String, dynamic> json) {
    return TermSchedule(
      term: json['term'] as int,
      duration: json['duration'] as String,
      weeks: json['weeks'] as int,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      holidays: (json['holidays'] as List).map((h) => h as String).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'term': term,
      'duration': duration,
      'weeks': weeks,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'holidays': holidays,
    };
  }
}

// Extension Methods for Utility
extension ScholonCurriculumExtensions on ScholonCurriculum {
  List<Course> get stemCourses =>
      courses.where((course) => course.strand == 'STEM').toList();

  List<Course> get coreCourses =>
      courses.where((course) => course.strand == 'Core').toList();

  Course? getCourseById(String id) {
    try {
      return courses.firstWhere((course) => course.id == id);
    } catch (e) {
      return null;
    }
  }

  List<CourseWeek> getAllWeeks() {
    return courses
        .expand((course) => course.terms)
        .expand((term) => term.weeks)
        .toList();
  }

  int get totalQuizzes {
    return courses
        .expand((course) => course.terms)
        .expand((term) => term.weeks)
        .expand((week) => week.quizzes)
        .length;
  }

  int get totalAssignments {
    return courses
        .expand((course) => course.terms)
        .expand((term) => term.weeks)
        .expand((week) => week.assignments)
        .length;
  }

  int get totalExamPapers {
    return courses
        .expand((course) => course.terms)
        .expand((term) => term.weeks)
        .expand((week) => week.exams.papers)
        .length;
  }

  Map<String, int> getCourseStatistics() {
    return {
      'totalCourses': courses.length,
      'totalWeeks': schedule.totalWeeks,
      'totalQuizzes': totalQuizzes,
      'totalAssignments': totalAssignments,
      'totalExamPapers': totalExamPapers,
      'totalHours': schedule.totalHours,
    };
  }
}

// Repository Class for Data Management
class ScholonRepository {
  final ScholonCurriculum _curriculum;

  ScholonRepository(this._curriculum);

  // Getters
  ScholonCurriculum get curriculum => _curriculum;

  // Query Methods
  List<CourseWeek> getWeeksByCourse(String courseId) {
    final course = _curriculum.courses.firstWhere(
      (c) => c.id == courseId,
      orElse: () => throw Exception('Course not found: $courseId'),
    );
    return course.terms.expand((term) => term.weeks).toList();
  }

  List<CourseAssignment> getAssignmentsByType(String type) {
    return _curriculum.getAllWeeks()
        .expand((week) => week.assignments)
        .where((assignment) => assignment.type == type)
        .toList();
  }

  List<CourseQuiz> getQuizzesByDifficulty(String difficultyLevel) {
    return _curriculum.getAllWeeks()
        .expand((week) => week.quizzes)
        .where((quiz) => quiz.passingScore >= 70 ? difficultyLevel == 'Hard' : difficultyLevel == 'Easy')
        .toList();
  }

  Map<String, List<ExamQuestion>> getExamQuestionsByBloomLevel() {
    final Map<String, List<ExamQuestion>> result = {};
    
    for (final week in _curriculum.getAllWeeks()) {
      for (final paper in week.exams.papers) {
        for (final question in paper.questions) {
          if (question is Map<String, dynamic>) {
            final examQuestion = ExamQuestion.fromJson(question);
            result.putIfAbsent(examQuestion.scholonBloomLevel, () => []).add(examQuestion);
          }
        }
      }
    }
    
    return result;
  }

  List<DigitalResource> getResourcesByType(String type) {
    final resources = <DigitalResource>[];
    
    if (type == 'textbook') {
      resources.addAll(_curriculum.resources.textbooks);
    } else if (type == 'digital') {
      resources.addAll(_curriculum.resources.digitalResources);
    }
    
    return resources;
  }

  // Progress Tracking
  StudentProgress calculateStudentProgress(String studentId, {DateTime? asOfDate}) {
    final now = asOfDate ?? DateTime.now();
    
    return StudentProgress(
      studentId: studentId,
      totalCourses: _curriculum.courses.length,
      completedCourses: 0,
      totalWeeks: _curriculum.schedule.totalWeeks,
      completedWeeks: 0,
      totalAssignments: _curriculum.totalAssignments,
      completedAssignments: 0,
      totalQuizzes: _curriculum.totalQuizzes,
      completedQuizzes: 0,
      averageScore: 0.0,
      lastActivity: now,
      streakDays: 0,
    );
  }

  // Course Recommendations
  List<Course> getRecommendedCourses(String studentId, {int limit = 3}) {
    // This would integrate with student performance data
    // For now, return STEM courses as recommendations
    return _curriculum.stemCourses.take(limit).toList();
  }
}

// Additional Data Classes for Progress Tracking
class StudentProgress {
  final String studentId;
  final int totalCourses;
  final int completedCourses;
  final int totalWeeks;
  final int completedWeeks;
  final int totalAssignments;
  final int completedAssignments;
  final int totalQuizzes;
  final int completedQuizzes;
  final double averageScore;
  final DateTime lastActivity;
  final int streakDays;

  StudentProgress({
    required this.studentId,
    required this.totalCourses,
    required this.completedCourses,
    required this.totalWeeks,
    required this.completedWeeks,
    required this.totalAssignments,
    required this.completedAssignments,
    required this.totalQuizzes,
    required this.completedQuizzes,
    required this.averageScore,
    required this.lastActivity,
    required this.streakDays,
  });
}

// Constants for the Scholon App
class ScholonConstants {
  static const String appName = 'Scholon';
  static const String appVersion = '1.0.0';
  static const String appSlogan = 'Learn. Excel. Transform.';

  static const List<String> scholonBloomLevels = [
    'Remember',
    'Understand',
    'Apply',
    'Analyze',
    'Evaluate',
    'Create',
  ];

  static const List<String> assignmentTypes = [
    'research',
    'problem_solving',
    'project',
    'presentation',
    'lab_report',
    'portfolio',
  ];

  static const List<String> courseStrands = [
    'STEM',
    'Humanities',
    'Social Sciences',
    'Vocational',
    'Core',
    'Elective',
  ];

  static const List<String> difficultyLevels = [
    'Beginner',
    'Intermediate',
    'Advanced',
    'Expert',
  ];

  static const Map<String, String> courseColors = {
    'MAT': '#FF6B6B', // Mathematics - Red
    'PHY': '#4ECDC4', // Physics - Teal
    'CHE': '#45B7D1', // Chemistry - Blue
    'BIO': '#96CEB4', // Biology - Green
    'ENG': '#FFEAA7', // English - Yellow
    'ECO': '#DDA0DD', // Economics - Purple
    'COM': '#98D8C8', // Computer Science - Mint
    'PHL': '#F7DC6F', // Philosophy - Gold
    'ART': '#BB8FCE', // Arts - Lavender
    'ENT': '#82E0AA', // Entrepreneurship - Light Green
    'HIS': '#F1948A', // History - Salmon
    'GEO': '#85C1E9', // Geography - Sky Blue
  };

  static const Map<String, int> defaultDurations = {
    'quiz': 30,
    'assignment': 7,
    'exam': 180,
    'note': 60,
    'activity': 90,
  };

  static const Map<String, String> scholonStandards = {
    'advanced': 'Scholon Advanced Level',
    'intermediate': 'Scholon Intermediate Level',
    'foundation': 'Scholon Foundation Level',
    'accelerated': 'Scholon Accelerated Program',
  };

  static const List<String> contentTypes = [
    'theory',
    'example',
    'summary',
    'formula',
    'case_study',
    'experiment',
    'demonstration',
  ];
}



// Utility function to handle dynamic types
dynamic parseDynamicField(Map<String, dynamic> json, String key) {
  return json[key];
}

// Helper for parsing mixed type lists
List<dynamic> parseDynamicList(dynamic value) {
  if (value is List) {
    return value;
  }
  return [];
}

// Helper for parsing mixed type maps
Map<String, dynamic> parseDynamicMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  return {};
}