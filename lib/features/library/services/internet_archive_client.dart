import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:isapp/features/library/models/archive_item.dart';
import 'package:isapp/features/library/models/search_query.dart';

/// Thin, polite client for Internet Archive's public JSON endpoints:
///   GET https://archive.org/advancedsearch.php?q=...&fl[]=...&rows=&page=&output=json
///   GET https://archive.org/metadata/{identifier}
/// No credentials are needed. We identify ourselves, throttle, back off on
/// 429/5xx and never touch download or borrow endpoints.
class InternetArchiveClient {
  InternetArchiveClient({http.Client? client}) : _http = client ?? http.Client();
  final http.Client _http;

  static const _host = 'archive.org';
  static const _timeout = Duration(seconds: 12);
  static const _minGap = Duration(milliseconds: 400);
  static const _fields = [
    'identifier', 'title', 'creator', 'year', 'description', 'language', 'subject',
    'mediatype', 'downloads', 'collection', 'licenseurl', 'access-restricted-item',
  ];
  static const _headers = {'User-Agent': 'Scholon/1.0 (educational app; contact: support@scholon.app)', 'Accept': 'application/json'};

  DateTime _last = DateTime.fromMillisecondsSinceEpoch(0);

  Future<SearchPage> search(LibrarySearchQuery q) async {
    if (q.isEmpty) return SearchPage(items: const [], total: 0, page: q.page, rows: q.rows);
    final uri = Uri.https(_host, '/advancedsearch.php', {
      'q': q.toLucene(),
      'fl[]': _fields,
      'rows': '${q.rows}',
      'page': '${q.page}',
      'sort[]': 'downloads desc',
      'output': 'json',
    });
    final body = await _getJson(uri);
    final resp = body['response'];
    if (resp is! Map) throw const LibraryException('Unexpected response from Internet Archive.');
    final docs = (resp['docs'] as List?) ?? const [];
    final items = <ArchiveItem>[];
    for (final d in docs) {
      try {
        final item = ArchiveItem.fromSearchDoc(Map<String, dynamic>.from(d as Map));
        if (item.identifier.isNotEmpty) items.add(item);
      } catch (_) {/* skip malformed record */}
    }
    return SearchPage(items: items, total: (resp['numFound'] as num?)?.toInt() ?? items.length, page: q.page, rows: q.rows);
  }

  Future<ArchiveItem> metadata(String identifier) async {
    final safe = Uri.encodeComponent(identifier);
    final body = await _getJson(Uri.https(_host, '/metadata/$safe'));
    if (body.isEmpty || body['metadata'] == null) throw const LibraryException('This item is not available.', retryable: false);
    return ArchiveItem.fromMetadata(body);
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    LibraryException? last;
    for (var attempt = 0; attempt < 3; attempt++) {
      final wait = _minGap - DateTime.now().difference(_last);
      if (!wait.isNegative) await Future.delayed(wait);
      _last = DateTime.now();
      try {
        final res = await _http.get(uri, headers: _headers).timeout(_timeout);
        if (res.statusCode == 200) {
          final decoded = jsonDecode(utf8.decode(res.bodyBytes));
          if (decoded is Map) return Map<String, dynamic>.from(decoded);
          throw const LibraryException('Unexpected response from Internet Archive.');
        }
        if (res.statusCode == 429 || res.statusCode >= 500) {
          final ra = int.tryParse(res.headers['retry-after'] ?? '');
          last = LibraryException(res.statusCode == 429 ? 'Internet Archive asked us to slow down. Try again shortly.' : 'Internet Archive is having trouble right now.');
          await Future.delayed(Duration(seconds: (ra ?? (attempt + 1) * 2).clamp(1, 6)));
          continue;
        }
        if (res.statusCode == 404) throw const LibraryException('This item was not found.', retryable: false);
        throw LibraryException('Request failed (${res.statusCode}).');
      } on TimeoutException {
        last = const LibraryException('Internet Archive took too long to respond.');
      } on FormatException {
        throw const LibraryException('Internet Archive returned unreadable data.');
      } on LibraryException {
        rethrow;
      } catch (_) {
        last = const LibraryException('No connection to Internet Archive.');
      }
    }
    throw last ?? const LibraryException('Could not reach Internet Archive.');
  }
}
