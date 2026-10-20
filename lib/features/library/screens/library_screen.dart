import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isapp/core/design/breakpoints.dart';
import 'package:isapp/core/design/scholon_type.dart';
import 'package:isapp/core/theme/scholar_theme.dart';
import 'package:isapp/features/library/controllers/library_controller.dart';
import 'package:isapp/features/library/models/archive_item.dart';
import 'package:isapp/features/library/screens/library_item_screen.dart';
import 'package:isapp/features/library/widgets/archive_item_card.dart';

/// Scholon Library: search Internet Archive's texts, save, and continue.
class LibraryScreen extends StatefulWidget {
  final String? initialQuery;
  const LibraryScreen({super.key, this.initialQuery});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  late final LibraryController c = Get.isRegistered<LibraryController>() ? Get.find<LibraryController>() : Get.put(LibraryController());
  final _text = TextEditingController();
  final _scroll = ScrollController();

  static const _topics = ['Mathematics', 'Physics', 'Chemistry', 'English literature', 'Biology', 'History', 'Computer science', 'Economics'];

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 400) c.loadMore();
    });
    if (widget.initialQuery != null) {
      _text.text = widget.initialQuery!;
      WidgetsBinding.instance.addPostFrameCallback((_) => c.search(widget.initialQuery!));
    }
  }

  @override
  void dispose() {
    _text.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _open(ArchiveItem i) => Get.to(() => LibraryItemScreen(item: i));

  @override
  Widget build(BuildContext context) {
    final cols = Breakpoints.ofContext(context) == ScreenClass.compact ? 1 : (Breakpoints.ofContext(context) == ScreenClass.medium ? 2 : 3);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: Scholar.backdrop),
        child: SafeArea(
          child: Obx(() {
            return CustomScrollView(controller: _scroll, slivers: [
              SliverToBoxAdapter(child: _header()),
              if (c.isLoading.value)
                const SliverFillRemaining(hasScrollBody: false, child: Center(child: CircularProgressIndicator(color: Scholar.aurora)))
              else if (c.error.value.isNotEmpty && c.results.isEmpty)
                SliverFillRemaining(hasScrollBody: false, child: _message(Icons.wifi_off_rounded, c.error.value, action: ('Try again', () => c.search(_text.text))))
              else if (!c.hasSearched.value)
                SliverToBoxAdapter(child: _home())
              else if (c.results.isEmpty)
                SliverFillRemaining(hasScrollBody: false, child: _message(Icons.search_off_rounded, 'No texts matched. Try fewer or different words.'))
              else ...[
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                  sliver: SliverToBoxAdapter(child: Text('${c.total.value} texts found', style: ScholonType.support(Colors.white54))),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: cols, mainAxisSpacing: 12, crossAxisSpacing: 12, mainAxisExtent: 140),
                    delegate: SliverChildBuilderDelegate(
                      (_, i) {
                        final it = c.results[i];
                        return ArchiveItemCard(item: it, saved: c.isSaved(it.identifier), onTap: () => _open(it), onToggleSave: () => c.toggleSaved(it));
                      },
                      childCount: c.results.length,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: c.isLoadingMore.value
                          ? const CircularProgressIndicator(color: Scholar.aurora)
                          : c.error.value.isNotEmpty
                              ? TextButton(onPressed: c.loadMore, child: Text('${c.error.value} Tap to retry'))
                              : const SizedBox(),
                    ),
                  ),
                ),
              ],
            ]);
          }),
        ),
      ),
    );
  }

  Widget _header() => Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 20, 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            IconButton(onPressed: Get.back, tooltip: 'Back', icon: const Icon(Icons.arrow_back_rounded, color: Colors.white)),
            Text('Library', style: ScholonType.pageTitle(Colors.white)),
          ]),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: TextField(
              controller: _text,
              textInputAction: TextInputAction.search,
              onSubmitted: c.search,
              style: ScholonType.body(Colors.white),
              decoration: InputDecoration(
                hintText: 'Search books by title, author or subject',
                hintStyle: ScholonType.body(Colors.white38),
                prefixIcon: const Icon(Icons.search_rounded, color: Colors.white54),
                suffixIcon: IconButton(tooltip: 'Search', icon: const Icon(Icons.arrow_forward_rounded, color: Scholar.aurora), onPressed: () => c.search(_text.text)),
                filled: true,
                fillColor: Colors.white.withOpacity(.08),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 10),
            child: Obx(() => Wrap(spacing: 8, children: [
                  FilterChip(
                    label: const Text('English only'),
                    selected: c.query.value.englishOnly,
                    onSelected: (v) => c.applyFilters(englishOnly: v),
                  ),
                  FilterChip(
                    label: const Text('Hide borrow-only'),
                    selected: c.query.value.excludeLending,
                    onSelected: (v) => c.applyFilters(excludeLending: v),
                  ),
                ])),
          ),
        ]),
      );

  Widget _home() => Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Explore a subject', style: ScholonType.section(Colors.white)),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final t in _topics)
              ActionChip(
                label: Text(t),
                onPressed: () {
                  _text.text = t;
                  c.search(t);
                },
              ),
          ]),
          if (c.recent.isNotEmpty) ...[const SizedBox(height: 24), _shelf('Recently viewed', c.recent)],
          if (c.saved.isNotEmpty) ...[const SizedBox(height: 24), _shelf('Saved', c.saved)],
        ]),
      );

  Widget _shelf(String title, List<ArchiveItem> items) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: ScholonType.section(Colors.white)),
        const SizedBox(height: 10),
        SizedBox(
          height: 190,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => GestureDetector(
              onTap: () => _open(items[i]),
              child: SizedBox(
                width: 112,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  ArchiveCover(item: items[i], width: 112, height: 150),
                  const SizedBox(height: 6),
                  Text(items[i].title, maxLines: 1, overflow: TextOverflow.ellipsis, style: ScholonType.support(Colors.white)),
                ]),
              ),
            ),
          ),
        ),
      ]);

  Widget _message(IconData icon, String text, {(String, VoidCallback)? action}) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 52, color: Colors.white38),
            const SizedBox(height: 12),
            Text(text, textAlign: TextAlign.center, style: ScholonType.body(Colors.white70)),
            if (action != null) ...[const SizedBox(height: 14), FilledButton(onPressed: action.$2, child: Text(action.$1))],
          ]),
        ),
      );
}
