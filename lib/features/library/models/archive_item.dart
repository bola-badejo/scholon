/// How an item may be used. Derived ONLY from metadata Internet Archive
/// returns; when in doubt we say "view on Internet Archive".
enum AccessStatus {
  openLicensed('Open licence', 'Metadata lists a public-domain or Creative Commons licence.'),
  borrowOrRestricted('Borrow or restricted', 'Lending or access restrictions apply. Open it on Internet Archive.'),
  viewOnArchive('View on Internet Archive', 'No open licence is stated in the metadata. Check the terms on Internet Archive.');

  final String label;
  final String explanation;
  const AccessStatus(this.label, this.explanation);
}

List<String> _list(dynamic v) {
  if (v == null) return const [];
  if (v is List) return v.map((e) => e.toString()).toList();
  return [v.toString()];
}

String _first(dynamic v) => _list(v).isEmpty ? '' : _list(v).first;

class ArchiveItem {
  final String identifier;
  final String title;
  final List<String> creators;
  final String year;
  final String description;
  final List<String> languages;
  final List<String> subjects;
  final String mediatype;
  final List<String> collections;
  final int downloads;
  final String? licenseUrl;
  final bool restricted;
  final String publisher;
  final List<String> formats; // only populated from the metadata endpoint

  const ArchiveItem({
    required this.identifier,
    required this.title,
    this.creators = const [],
    this.year = '',
    this.description = '',
    this.languages = const [],
    this.subjects = const [],
    this.mediatype = '',
    this.collections = const [],
    this.downloads = 0,
    this.licenseUrl,
    this.restricted = false,
    this.publisher = '',
    this.formats = const [],
  });

  String get detailsUrl => 'https://archive.org/details/$identifier';

  /// Cover thumbnail service. Unverified against official docs: the UI must
  /// handle load failure (it falls back to a placeholder).
  String get coverUrl => 'https://archive.org/services/img/$identifier';

  AccessStatus get access {
    final lending = collections.any((c) => const {'inlibrary', 'printdisabled', 'lendinglibrary'}.contains(c));
    if (restricted || lending) return AccessStatus.borrowOrRestricted;
    final l = (licenseUrl ?? '').toLowerCase();
    if (l.contains('publicdomain') || l.contains('creativecommons.org')) return AccessStatus.openLicensed;
    return AccessStatus.viewOnArchive;
  }

  String get authorLine => creators.isEmpty ? 'Unknown author' : creators.take(3).join(', ');

  factory ArchiveItem.fromSearchDoc(Map<String, dynamic> d) => ArchiveItem(
        identifier: _first(d['identifier']),
        title: _first(d['title']).isEmpty ? 'Untitled' : _first(d['title']),
        creators: _list(d['creator']),
        year: _first(d['year']),
        description: _list(d['description']).join(' '),
        languages: _list(d['language']),
        subjects: _list(d['subject']),
        mediatype: _first(d['mediatype']),
        collections: _list(d['collection']),
        downloads: int.tryParse(_first(d['downloads'])) ?? 0,
        licenseUrl: _first(d['licenseurl']).isEmpty ? null : _first(d['licenseurl']),
        restricted: _first(d['access-restricted-item']).toLowerCase() == 'true',
      );

  /// `/metadata/{identifier}` returns {"metadata": {...}, "files": [...]}.
  factory ArchiveItem.fromMetadata(Map<String, dynamic> json) {
    final m = Map<String, dynamic>.from(json['metadata'] ?? {});
    final files = (json['files'] as List?) ?? const [];
    final formats = files.map((f) => (f as Map)['format']?.toString() ?? '').where((f) => f.isNotEmpty).toSet().toList()..sort();
    final base = ArchiveItem.fromSearchDoc(m);
    return ArchiveItem(
      identifier: base.identifier,
      title: base.title,
      creators: base.creators,
      year: base.year.isNotEmpty ? base.year : _first(m['date']).split('-').first,
      description: base.description,
      languages: base.languages,
      subjects: base.subjects,
      mediatype: base.mediatype,
      collections: base.collections,
      downloads: base.downloads,
      licenseUrl: base.licenseUrl,
      restricted: base.restricted,
      publisher: _first(m['publisher']),
      formats: formats,
    );
  }

  Map<String, dynamic> toJson() => {
        'identifier': identifier,
        'title': title,
        'creator': creators,
        'year': year,
        'description': description,
        'language': languages,
        'subject': subjects,
        'mediatype': mediatype,
        'collection': collections,
        'downloads': downloads,
        'licenseurl': licenseUrl,
        'access-restricted-item': restricted.toString(),
        'publisher': publisher,
        'formats': formats,
      };

  factory ArchiveItem.fromJson(Map<String, dynamic> j) {
    final base = ArchiveItem.fromSearchDoc(j);
    return ArchiveItem(
      identifier: base.identifier,
      title: base.title,
      creators: base.creators,
      year: base.year,
      description: base.description,
      languages: base.languages,
      subjects: base.subjects,
      mediatype: base.mediatype,
      collections: base.collections,
      downloads: base.downloads,
      licenseUrl: base.licenseUrl,
      restricted: base.restricted,
      publisher: _first(j['publisher']),
      formats: _list(j['formats']),
    );
  }
}

class SearchPage {
  final List<ArchiveItem> items;
  final int total;
  final int page;
  final int rows;
  const SearchPage({required this.items, required this.total, required this.page, required this.rows});
  bool get hasMore => page * rows < total && items.isNotEmpty;
}

class LibraryException implements Exception {
  final String message;
  final bool retryable;
  const LibraryException(this.message, {this.retryable = true});
  @override
  String toString() => message;
}
