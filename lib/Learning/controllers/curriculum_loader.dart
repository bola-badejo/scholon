import 'dart:convert';

import 'package:isapp/Learning/controllers/scholon_curriculum_planner_adapter.dart';
import 'package:isapp/Utils/library/new_courses.dart';

class CurriculumLoader {
  static Future<AdaptedScholonCurriculum?> loadCurriculum() async {
    try {
      final curriculumJson = Courses.ss3Curriculum;
      if (curriculumJson.trim().isEmpty) {
        print('❌ Curriculum JSON is null or empty');
        return _createFallbackCurriculum();
      }

      print('📝 Loading curriculum...');
      
      dynamic parsed;
      try {
        parsed = jsonDecode(curriculumJson.trim());
      } catch (e) {
        print('❌ JSON parsing error: $e');
        return _createFallbackCurriculum();
      }
      
      // Check if it's a list or map
      if (parsed is List) {
        if (parsed.isEmpty) {
          print('❌ Empty curriculum list');
          return _createFallbackCurriculum();
        }
        
        final firstItem = parsed.first;
        if (firstItem is Map<String, dynamic>) {
          final adapted = ScholonCurriculumAdapter.adaptFromJson(firstItem);
          print('✅ Curriculum loaded successfully from list');
          return adapted;
        }
      } else if (parsed is Map<String, dynamic>) {
        final adapted = ScholonCurriculumAdapter.adaptFromJson(parsed);
        print('✅ Curriculum loaded successfully from map');
        return adapted;
      }
      
      print('❌ Unexpected curriculum format: ${parsed.runtimeType}');
      return _createFallbackCurriculum();
      
    } catch (e, stackTrace) {
      print('❌ Error loading curriculum: $e');
      print('Stack trace: $stackTrace');
      return _createFallbackCurriculum();
    }
  }
  
  static AdaptedScholonCurriculum _createFallbackCurriculum() {
    print('🔄 Creating fallback curriculum');
    
    // Create a simple fallback curriculum with real content from your JSON
    return AdaptedScholonCurriculum(
      curriculum: 'Scholon Advanced Curriculum',
      academicYear: '2023/2024',
      schoolLevel: 'Senior Secondary 3 (SS3)',
      courses: [
        AdaptedCourse(
          id: 'MAT001',
          courseCode: 'MAT',
          name: 'Advanced Mathematics',
          description: 'Advanced mathematical concepts including calculus, linear algebra, and discrete mathematics',
          strand: 'STEM',
          credits: 1.0,
          scholonLevel: 'Scholon Advanced Level',
          metadata: {
            'difficulty': 'Advanced',
            'instructor': 'Dr. Sarah Johnson',
            'department': 'Mathematics',
          },
          terms: [
            AdaptedTerm(
              id: 'MAT001_T1',
              term: 'First Term',
              duration: 'September - December',
              focus: 'Calculus and Advanced Algebra',
              objectives: AdaptedLearningObjectives(
                knowledgeObjectives: [
                  'Master advanced calculus concepts',
                  'Understand linear algebra fundamentals',
                  'Apply mathematical modeling techniques'
                ],
                skillObjectives: [
                  'Solve complex mathematical problems',
                  'Use mathematical software tools',
                  'Present mathematical proofs'
                ],
                attitudeObjectives: [
                  'Develop persistence in problem-solving',
                  'Cultivate appreciation for mathematical beauty',
                  'Enhance collaborative learning'
                ],
              ),
              weeks: [
                AdaptedWeek(
                  weekNumber: 1,
                  topic: 'Limits, Continuity and Differentiation',
                  overview: 'This week focuses on foundational concepts of calculus, including limits, continuity, and differentiation techniques.',
                  coreCompetencies: [
                    'Understanding limits and continuity',
                    'Applying differentiation rules',
                    'Solving optimization problems',
                    'Analyzing rates of change'
                  ],
                  scholonStandard: 'Scholon Advanced Level',
                  notes: [
                    AdaptedNote(
                      id: 'MAT001_W1_N1',
                      title: 'Concept of Limits and Continuity',
                      content: 'Detailed exploration of ε-δ definition of limits, continuity theorems, and their applications.',
                      duration: '60 min',
                      difficulty: 'Advanced',
                      keyConcepts: ['ε-δ definition', 'Intermediate Value Theorem', 'Continuous functions'],
                      learningTags: ['calculus', 'limits', 'continuity'],
                      contentType: 'theory',
                      references: [],
                    ),
                  ],
                  quizzes: [
                    AdaptedQuiz(
                      id: 'MAT001_W1_Q1',
                      title: 'Calculus Fundamentals Quiz 1',
                      description: 'Test your understanding of limits and continuity concepts',
                      questions: [
                        AdaptedQuestion(
                          id: 'MAT001_W1_Q1_Q1',
                          question: 'Which of the following represents the formal ε-δ definition of a limit?',
                          options: [
                            AdaptedQuestionOption(id: 'A', text: 'For every ε > 0, there exists δ > 0 such that if 0 < |x - a| < δ, then |f(x) - L| < ε', isCorrect: true),
                            AdaptedQuestionOption(id: 'B', text: 'The value that f(x) approaches as x gets closer to a', isCorrect: false),
                            AdaptedQuestionOption(id: 'C', text: 'The instantaneous rate of change at a point', isCorrect: false),
                            AdaptedQuestionOption(id: 'D', text: 'The derivative of the function at point a', isCorrect: false),
                          ],
                          correctAnswer: 0,
                          explanation: 'The ε-δ definition provides the rigorous mathematical definition of a limit.',
                          scholonBloomLevel: 'Understand',
                          points: 2,
                          questionType: 'multiple_choice',
                          tags: ['limits', 'definition', 'calculus'],
                        ),
                      ],
                      duration: 30,
                      passingScore: 70,
                      maxAttempts: 3,
                      isTimed: true,
                      quizType: 'formative',
                    ),
                  ],
                  assignments: [],
                  exams: AdaptedExamStructure(
                    id: 'MAT001_W1_EXAM',
                    papers: [],
                    metadata: AdaptedExamMetadata(
                      totalPapers: 0,
                      totalQuestions: 0,
                      totalMarks: 0,
                      examFormat: 'No exam this week',
                      gradingPolicy: 'N/A',
                    ),
                  ),
                  activities: [],
                ),
              ],
            ),
          ],
        ),
      ],
      assessmentStructure: AdaptedAssessmentStructure(
        continuousAssessment: 40,
        termlyExaminations: 60,
        gradingScale: {
          'A+': '95-100%', 'A': '90-94%', 'A-': '85-89%',
          'B+': '80-84%', 'B': '75-79%', 'B-': '70-74%',
          'C+': '65-69%', 'C': '60-64%', 'D': '50-59%', 'F': 'Below 50%',
        },
        weightDistribution: {
          'quizzes': 15,
          'assignments': 25,
          'midterm': 20,
          'final': 40,
        },
      ),
      learningOutcomes: AdaptedLearningOutcomes(
        cognitiveSkills: [
          'Critical thinking and advanced problem-solving at university level',
          'Research methodology and academic writing proficiency',
        ],
        practicalSkills: [
          'Advanced laboratory techniques and safety protocols',
          'Data analysis and statistical inference using software tools',
        ],
        softSkills: [
          'Collaboration and teamwork in academic settings',
          'Time management and organizational skills',
        ],
        scholonCompetencies: [
          'Scholon Advanced Problem Solver',
          'Scholon Research Scholar',
        ],
      ),
      resources: AdaptedScholonResources(
        textbooks: [],
        digitalResources: [],
        laboratoryEquipment: [],
        softwareTools: [],
      ),
      schedule: AdaptedSchedule(
        terms: [],
        totalWeeks: 36,
        totalHours: 1440,
        contactHoursPerWeek: 40,
        startDate: DateTime(2023, 9, 4),
        endDate: DateTime(2024, 7, 12),
      ),
    );
  }
}

// Then update your loadCurriculum method in ScholonActivityPlanner:
Future<AdaptedScholonCurriculum?> loadCurriculum() async {
  return await CurriculumLoader.loadCurriculum();
}