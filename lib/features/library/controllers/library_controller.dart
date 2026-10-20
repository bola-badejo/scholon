import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:isapp/features/library/models/archive_item.dart';
import 'package:isapp/features/library/models/search_query.dart';
import 'package:isapp/features/library/services/library_repository.dart';

class LibraryController extends GetxController {
  final LibraryRepository repo;
  LibraryController({LibraryRepository? repo}) : repo = repo ?? LibraryRepository();

  final results = <ArchiveItem>[].obs;
  final saved = <ArchiveItem>[].obs;
  final recent = <ArchiveItem>[].obs;
  final query = const LibrarySearchQuery().obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final error = ''.obs;
  final hasMore = false.obs;
  final total = 0.obs;
  final hasSearched = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadLocal();
  }

  Future<void> _loadLocal() async {
    saved.assignAll(await repo.cache.loadList('lib_saved'));
    recent.assignAll(await repo.cache.loadList('lib_recent'));
  }

  Future<void> search(String text, {String? subject}) async {
    query.value = query.value.copyWith(text: text, subject: subject, page: 1);
    await _run(reset: true);
  }

  Future<void> applyFilters({bool? englishOnly, bool? excludeLending, int? fromYear, int? toYear}) async {
    query.value = query.value.copyWith(englishOnly: englishOnly, excludeLending: excludeLending, fromYear: fromYear, toYear: toYear, page: 1);
    if (hasSearched.value) await _run(reset: true);
  }

  Future<void> loadMore() async {
    if (!hasMore.value || isLoadingMore.value || isLoading.value) return;
    query.value = query.value.copyWith(page: query.value.page + 1);
    await _run(reset: false);
  }

  Future<void> _run({required bool reset}) async {
    if (query.value.isEmpty) return;
    error.value = '';
    hasSearched.value = true;
    reset ? isLoading.value = true : isLoadingMore.value = true;
    try {
      final page = await repo.search(query.value);
      if (reset) results.clear();
      final seen = results.map((e) => e.identifier).toSet();
      results.addAll(page.items.where((i) => seen.add(i.identifier)));
      total.value = page.total;
      hasMore.value = page.hasMore;
    } on LibraryException catch (e) {
      error.value = e.message;
      if (!reset) query.value = query.value.copyWith(page: query.value.page - 1);
    } catch (e) {
      debugPrint('Library search failed: $e');
      error.value = 'Something went wrong. Please try again.';
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  bool isSaved(String id) => saved.any((i) => i.identifier == id);

  Future<void> toggleSaved(ArchiveItem item) async {
    isSaved(item.identifier) ? saved.removeWhere((i) => i.identifier == item.identifier) : saved.insert(0, item);
    await repo.cache.saveList('lib_saved', saved.toList());
  }

  Future<void> markViewed(ArchiveItem item) async {
    recent.removeWhere((i) => i.identifier == item.identifier);
    recent.insert(0, item);
    if (recent.length > 20) recent.removeRange(20, recent.length);
    await repo.cache.saveList('lib_recent', recent.toList());
  }
}
