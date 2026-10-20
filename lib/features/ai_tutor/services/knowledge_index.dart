import 'dart:math' as math;
import 'package:isapp/features/ai_tutor/models/ai_models.dart';

/// A retrievable passage with the metadata needed for honest citations.
class KnowledgeChunk {
  final String id;
  final String title;
  final String text;
  final String sourceType; // note | quiz-explanation | overview | glossary
  final String? courseCode;
  final String locator;
  final String license;
  final bool restricted; // restricted chunks are never sent to a model

  const KnowledgeChunk({
    required this.id,
    required this.title,
    required this.text,
    required this.sourceType,
    required this.locator,
    this.courseCode,
    this.license = 'Scholon course material',
    this.restricted = false,
  });

  SourceRef toRef() => SourceRef(title: title, locator: locator, sourceType: sourceType, license: license);
}

class ScoredChunk {
  final KnowledgeChunk chunk;
  final double score;
  const ScoredChunk(this.chunk, this.score);
}

/// Keyword retrieval (BM25). Runs fully offline on-device with no model.
/// A vector index can be added behind the same `search` signature later and
/// fused with these scores (hybrid retrieval).
class KnowledgeIndex {
  KnowledgeIndex(List<KnowledgeChunk> chunks) : _chunks = chunks {
    for (final c in chunks) {
      final toks = tokenize('${c.title} ${c.title} ${c.text}');
      _tokens.add(toks);
      final tf = <String, int>{};
      for (final t in toks) {
        tf[t] = (tf[t] ?? 0) + 1;
      }
      _tf.add(tf);
      for (final t in tf.keys) {
        _df[t] = (_df[t] ?? 0) + 1;
      }
    }
    _avg = chunks.isEmpty ? 0 : _tokens.fold<int>(0, (s, t) => s + t.length) / chunks.length;
  }

  final List<KnowledgeChunk> _chunks;
  final List<List<String>> _tokens = [];
  final List<Map<String, int>> _tf = [];
  final Map<String, int> _df = {};
  double _avg = 0;

  int get size => _chunks.length;

  static const _stop = {
    'the', 'a', 'an', 'of', 'to', 'in', 'is', 'are', 'and', 'or', 'for', 'on', 'with', 'what', 'how', 'why', 'does', 'do', 'it', 'this', 'that',
    'be', 'as', 'at', 'by', 'from', 'can', 'me', 'my', 'i', 'you', 'explain', 'about', 'please', 'tell', 'give',
  };

  static List<String> tokenize(String s) {
    final out = <String>[];
    for (final w in s.toLowerCase().split(RegExp(r'[^a-z0-9]+'))) {
      if (w.length < 2 || _stop.contains(w)) continue;
      out.add(_stem(w));
    }
    return out;
  }

  static String _stem(String w) {
    for (final suf in const ['ing', 'edly', 'ed', 'es', 's']) {
      if (w.length > suf.length + 3 && w.endsWith(suf)) return w.substring(0, w.length - suf.length);
    }
    return w;
  }

  /// [minScore] keeps weak matches out: no evidence means no citation.
  List<ScoredChunk> search(String query, {int k = 4, String? courseCode, double minScore = 1.2}) {
    final q = tokenize(query);
    if (q.isEmpty || _chunks.isEmpty) return const [];
    const k1 = 1.5, b = .75;
    final n = _chunks.length;
    final scored = <ScoredChunk>[];
    for (var i = 0; i < n; i++) {
      var s = 0.0;
      final len = _tokens[i].length;
      for (final t in q.toSet()) {
        final f = _tf[i][t] ?? 0;
        if (f == 0) continue;
        final df = _df[t] ?? 0;
        final idf = math.log(1 + (n - df + .5) / (df + .5));
        s += idf * (f * (k1 + 1)) / (f + k1 * (1 - b + b * len / (_avg == 0 ? 1 : _avg)));
      }
      if (s <= 0) continue;
      if (courseCode != null && _chunks[i].courseCode == courseCode) s *= 1.3;
      if (s >= minScore) scored.add(ScoredChunk(_chunks[i], s));
    }
    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.take(k).toList();
  }
}
