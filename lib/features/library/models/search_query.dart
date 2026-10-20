/// A user's library search. Converts to Internet Archive's Lucene syntax with
/// user text sanitised, so a query can never inject extra operators.
class LibrarySearchQuery {
  final String text;
  final String? subject;
  final int? fromYear;
  final int? toYear;
  final bool englishOnly;
  final bool excludeLending; // hides items known to need borrowing
  final int page;
  final int rows;

  const LibrarySearchQuery({
    this.text = '',
    this.subject,
    this.fromYear,
    this.toYear,
    this.englishOnly = false,
    this.excludeLending = false,
    this.page = 1,
    this.rows = 24,
  });

  LibrarySearchQuery copyWith({String? text, String? subject, int? fromYear, int? toYear, bool? englishOnly, bool? excludeLending, int? page}) =>
      LibrarySearchQuery(
        text: text ?? this.text,
        subject: subject ?? this.subject,
        fromYear: fromYear ?? this.fromYear,
        toYear: toYear ?? this.toYear,
        englishOnly: englishOnly ?? this.englishOnly,
        excludeLending: excludeLending ?? this.excludeLending,
        page: page ?? this.page,
        rows: rows,
      );

  static final _unsafe = RegExp(r'[\\"\x27:()\[\]{}^~*?!+\-&|/<>=]');

  /// Letters, digits and spaces only.
  static String sanitize(String s) => s.replaceAll(_unsafe, ' ').replaceAll(RegExp(r'\s+'), ' ').trim();

  bool get isEmpty => sanitize(text).isEmpty && (subject == null || sanitize(subject!).isEmpty);

  String toLucene() {
    final parts = <String>[];
    final words = sanitize(text).split(' ').where((w) => w.isNotEmpty).toList();
    if (words.isNotEmpty) parts.add('(${words.join(' AND ')})');
    final sub = subject == null ? '' : sanitize(subject!);
    if (sub.isNotEmpty) parts.add('subject:("$sub")');
    parts.add('mediatype:(texts)');
    if (englishOnly) parts.add('language:(eng OR English)');
    if (fromYear != null || toYear != null) parts.add('year:[${fromYear ?? 0} TO ${toYear ?? 2100}]');
    if (excludeLending) parts.add('NOT collection:(inlibrary OR printdisabled OR lendinglibrary)');
    return parts.join(' AND ').replaceAll('AND NOT', 'AND NOT');
  }

  String get cacheKey => '${toLucene()}|$page|$rows';
}
