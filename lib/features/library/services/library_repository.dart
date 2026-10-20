import 'package:isapp/features/library/models/archive_item.dart';
import 'package:isapp/features/library/models/search_query.dart';
import 'package:isapp/features/library/services/internet_archive_client.dart';
import 'package:isapp/features/library/services/library_cache.dart';

/// Why a resource was suggested. This is the SEARCH INTENT that found it.
/// Internet Archive does not tell us reading difficulty, so we never claim it.
class ResourcePurpose {
  final String label;
  final String queryPrefix;
  final String queryHint;
  const ResourcePurpose(this.label, this.queryPrefix, this.queryHint);
}

class CourseResources {
  final ResourcePurpose purpose;
  final List<ArchiveItem> items;
  const CourseResources(this.purpose, this.items);
}

class LibraryRepository {
  LibraryRepository({InternetArchiveClient? client, LibraryCache? cache})
      : _client = client ?? InternetArchiveClient(),
        cache = cache ?? LibraryCache();
  final InternetArchiveClient _client;
  final LibraryCache cache;

  static const purposes = [
    ResourcePurpose('Starting out', 'introduction', 'Introductory books on the subject'),
    ResourcePurpose('Core textbooks', 'textbook', 'Textbooks and standard references'),
    ResourcePurpose('Historical sources', 'history', 'Historical context and older works'),
    ResourcePurpose('Going further', 'advanced', 'Further study and research'),
  ];

  Future<SearchPage> search(LibrarySearchQuery q) async {
    final hit = cache.page(q.cacheKey);
    if (hit != null) return hit;
    final page = await _client.search(q);
    cache.putPage(q.cacheKey, page);
    return page;
  }

  /// Full details; falls back to stale cache when the network is down.
  Future<ArchiveItem> item(String id) async {
    final fresh = await cache.item(id);
    if (fresh != null && fresh.formats.isNotEmpty) return fresh;
    try {
      final item = await _client.metadata(id);
      await cache.putItem(item);
      return item;
    } on LibraryException {
      final stale = await cache.item(id, allowStale: true);
      if (stale != null) return stale;
      rethrow;
    }
  }

  /// Real search results per purpose for a course; purposes with no results
  /// are omitted instead of padded.
  Future<List<CourseResources>> forCourse(String subject, {bool excludeLending = true}) async {
    final out = <CourseResources>[];
    for (final p in purposes) {
      try {
        final page = await search(LibrarySearchQuery(text: '${p.queryPrefix} $subject', englishOnly: true, excludeLending: excludeLending, rows: 6));
        if (page.items.isNotEmpty) out.add(CourseResources(p, page.items.take(4).toList()));
      } on LibraryException {
        break; // service trouble: stop hammering it
      }
    }
    return out;
  }
}
