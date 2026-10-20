import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:isapp/features/library/models/archive_item.dart';

/// Public metadata cache: memory for search pages, disk for item details
/// (24h). Saved/recent lists live here too so they survive outages.
class LibraryCache {
  static const _ttl = Duration(hours: 24);
  final Map<String, (DateTime, SearchPage)> _pages = {};

  SearchPage? page(String key) {
    final e = _pages[key];
    if (e == null || DateTime.now().difference(e.$1) > const Duration(minutes: 10)) return null;
    return e.$2;
  }

  void putPage(String key, SearchPage p) => _pages[key] = (DateTime.now(), p);

  Future<ArchiveItem?> item(String id, {bool allowStale = false}) async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString('ia_item_$id');
    if (raw == null) return null;
    try {
      final j = jsonDecode(raw) as Map<String, dynamic>;
      final at = DateTime.fromMillisecondsSinceEpoch(j['at'] as int);
      if (!allowStale && DateTime.now().difference(at) > _ttl) return null;
      return ArchiveItem.fromJson(Map<String, dynamic>.from(j['item'] as Map));
    } catch (_) {
      return null;
    }
  }

  Future<void> putItem(ArchiveItem item) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString('ia_item_${item.identifier}', jsonEncode({'at': DateTime.now().millisecondsSinceEpoch, 'item': item.toJson()}));
  }

  Future<List<ArchiveItem>> loadList(String key) async {
    final sp = await SharedPreferences.getInstance();
    try {
      final l = jsonDecode(sp.getString(key) ?? '[]') as List;
      return l.map((e) => ArchiveItem.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveList(String key, List<ArchiveItem> items) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(key, jsonEncode(items.map((e) => e.toJson()).toList()));
  }
}
