import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:isapp/data/library/course_logic.dart';
import 'package:isapp/data/library/new_courses.dart';
import 'package:isapp/features/ai_tutor/services/knowledge_index.dart';
import 'package:isapp/features/learning/controllers/scholon_curriculum_planner_adapter.dart';

/// Builds retrievable chunks from the courses that actually exist in Scholon.
/// Chunking follows the content's structure (one note = one chunk, one
/// explanation = one chunk) rather than fixed-size slices.
class CurriculumKnowledgeBuilder {
  static Future<KnowledgeIndex> build() async {
    final chunks = <KnowledgeChunk>[];
    try {
      _fromCatalog(chunks);
    } catch (e) {
      debugPrint('Catalog indexing failed: $e');
    }
    try {
      _fromSs3(chunks);
    } catch (e) {
      debugPrint('SS3 indexing failed: $e');
    }
    return KnowledgeIndex(chunks);
  }

  static void _fromCatalog(List<KnowledgeChunk> out) {
    final cats = jsonDecode(Constants.courseCategoriesJson) as List;
    for (final cat in cats) {
      for (final course in (cat['courses'] as List? ?? const [])) {
        final code = '${course['code'] ?? ''}';
        for (final topic in (course['topics'] as List? ?? const [])) {
          final notes = (topic['materials']?['notes'] as List?) ?? const [];
          for (final n in notes) {
            final body = '${n['content'] ?? ''}'.trim();
            if (body.isEmpty) continue;
            out.add(KnowledgeChunk(
              id: '${n['code'] ?? out.length}',
              title: '${n['title'] ?? topic['title']}',
              text: body,
              sourceType: 'note',
              courseCode: code,
              locator: '${cat['title']} > ${course['title']} > ${topic['title']} > ${n['title']}',
            ));
          }
        }
      }
    }
  }

  static void _fromSs3(List<KnowledgeChunk> out) {
    final parsed = jsonDecode(Courses.ss3Curriculum.trim());
    final cur = ScholonCurriculumAdapter.adaptFromJson(parsed is List ? parsed.first : parsed);
    for (final course in cur.courses) {
      for (final term in course.terms) {
        for (final week in term.weeks) {
          final loc = '${course.name} > ${term.term} > Week ${week.weekNumber}';
          if (week.overview.trim().isNotEmpty) {
            out.add(KnowledgeChunk(
              id: '${course.id}_${term.id}_W${week.weekNumber}_overview',
              title: week.topic,
              text: '${week.overview} Core competencies: ${week.coreCompetencies.join('; ')}',
              sourceType: 'overview',
              courseCode: course.courseCode,
              locator: loc,
            ));
          }
          for (final n in week.notes) {
            out.add(KnowledgeChunk(
              id: n.id,
              title: n.title,
              text: '${n.content} Key concepts: ${n.keyConcepts.join(', ')}',
              sourceType: 'note',
              courseCode: course.courseCode,
              locator: '$loc > ${n.title}',
            ));
          }
          for (final q in week.quizzes) {
            for (final qu in q.questions) {
              if (qu.explanation.trim().isEmpty) continue;
              out.add(KnowledgeChunk(
                id: qu.id,
                title: 'Why: ${qu.question}',
                text: qu.explanation,
                sourceType: 'quiz-explanation',
                courseCode: course.courseCode,
                locator: '$loc > ${q.title}',
              ));
            }
          }
        }
      }
    }
  }
}
