import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isapp/core/design/reading_column.dart';
import 'package:isapp/core/design/scholon_type.dart';
import 'package:isapp/core/theme/scholar_theme.dart';
import 'package:isapp/features/library/controllers/library_controller.dart';
import 'package:isapp/features/library/models/archive_item.dart';
import 'package:isapp/features/library/widgets/archive_item_card.dart';
import 'package:url_launcher/url_launcher.dart';

/// Item details. Loads full metadata, explains access honestly, and only ever
/// links OUT to Internet Archive for reading, borrowing or downloading.
class LibraryItemScreen extends StatefulWidget {
  final ArchiveItem item;
  const LibraryItemScreen({super.key, required this.item});

  @override
  State<LibraryItemScreen> createState() => _LibraryItemScreenState();
}

class _LibraryItemScreenState extends State<LibraryItemScreen> {
  final LibraryController c = Get.find<LibraryController>();
  late ArchiveItem item = widget.item;
  String? error;

  @override
  void initState() {
    super.initState();
    c.markViewed(widget.item);
    _load();
  }

  Future<void> _load() async {
    try {
      final full = await c.repo.item(widget.item.identifier);
      if (mounted) setState(() => item = full);
    } on LibraryException catch (e) {
      if (mounted) setState(() => error = e.message);
    }
  }

  Future<void> _open() async {
    final ok = await launchUrl(Uri.parse(item.detailsUrl), mode: LaunchMode.externalApplication);
    if (!ok && mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open Internet Archive.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: Scholar.backdrop),
        child: SafeArea(
          child: ReadingColumn(
            child: ListView(children: [
              Align(alignment: Alignment.centerLeft, child: IconButton(onPressed: Get.back, icon: const Icon(Icons.arrow_back_rounded, color: Colors.white), tooltip: 'Back')),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                ArchiveCover(item: item, width: 120, height: 170),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(item.title, style: ScholonType.pageTitle(Colors.white)),
                    const SizedBox(height: 6),
                    Text(item.authorLine, style: ScholonType.body(Colors.white70)),
                    if (item.publisher.isNotEmpty || item.year.isNotEmpty)
                      Padding(padding: const EdgeInsets.only(top: 4), child: Text([item.publisher, item.year].where((e) => e.isNotEmpty).join(', '), style: ScholonType.support(Colors.white54))),
                    const SizedBox(height: 10),
                    AccessBadge(status: item.access),
                  ]),
                ),
              ]),
              const SizedBox(height: 18),
              _AccessNote(item: item),
              const SizedBox(height: 16),
              Wrap(spacing: 10, runSpacing: 10, children: [
                FilledButton.icon(onPressed: _open, icon: const Icon(Icons.open_in_new_rounded), label: const Text('Open on Internet Archive')),
                Obx(() => OutlinedButton.icon(
                      onPressed: () => c.toggleSaved(item),
                      icon: Icon(c.isSaved(item.identifier) ? Icons.bookmark_rounded : Icons.bookmark_border_rounded),
                      label: Text(c.isSaved(item.identifier) ? 'Saved' : 'Save'),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
                    )),
              ]),
              if (item.description.isNotEmpty) ...[
                const SizedBox(height: 22),
                Text('About this item', style: ScholonType.section(Colors.white)),
                const SizedBox(height: 8),
                Text(_plain(item.description), style: ScholonType.body(Colors.white70)),
              ],
              if (item.subjects.isNotEmpty) ...[
                const SizedBox(height: 20),
                Wrap(spacing: 6, runSpacing: 6, children: [for (final s in item.subjects.take(10)) Chip(label: Text(s, style: ScholonType.label(Colors.white)), backgroundColor: Colors.white12, side: BorderSide.none)]),
              ],
              if (item.formats.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text('Formats listed: ${item.formats.take(8).join(', ')}', style: ScholonType.support(Colors.white54)),
              ],
              if (error != null) Padding(padding: const EdgeInsets.only(top: 16), child: Text('Showing saved details. $error', style: ScholonType.support(Scholar.sun))),
              const SizedBox(height: 24),
              Text('Source: Internet Archive (archive.org). Scholon shows public metadata only. Reading, borrowing and downloads follow the terms on Internet Archive.', style: ScholonType.support(Colors.white38)),
              const SizedBox(height: 40),
            ]),
          ),
        ),
      ),
    );
  }

  String _plain(String html) => html.replaceAll(RegExp(r'<[^>]+>'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
}

class _AccessNote extends StatelessWidget {
  final ArchiveItem item;
  const _AccessNote({required this.item});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white.withOpacity(.07), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.info_outline_rounded, color: Scholar.sky, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(item.access.explanation, style: ScholonType.support(Colors.white70))),
        ]),
      );
}
