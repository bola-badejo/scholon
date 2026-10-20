import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isapp/core/design/scholon_type.dart';
import 'package:isapp/core/theme/scholar_theme.dart';
import 'package:isapp/features/library/controllers/library_controller.dart';
import 'package:isapp/features/library/screens/library_item_screen.dart';
import 'package:isapp/features/library/screens/library_screen.dart';
import 'package:isapp/features/library/services/library_repository.dart';
import 'package:isapp/features/library/widgets/archive_item_card.dart';

/// Drop into any course page: real Internet Archive results for [subject],
/// grouped by the purpose of the search that found them.
class CourseResourcesSection extends StatefulWidget {
  final String subject;
  const CourseResourcesSection({super.key, required this.subject});

  @override
  State<CourseResourcesSection> createState() => _CourseResourcesSectionState();
}

class _CourseResourcesSectionState extends State<CourseResourcesSection> {
  late final LibraryController c = Get.isRegistered<LibraryController>() ? Get.find<LibraryController>() : Get.put(LibraryController());
  late Future<List<CourseResources>> _future = c.repo.forCourse(widget.subject);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CourseResources>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator(color: Scholar.aurora)));
        }
        final groups = snap.data ?? const [];
        if (groups.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Expanded(child: Text('No library suggestions right now.', style: ScholonType.support(Colors.white54))),
              TextButton(onPressed: () => setState(() => _future = c.repo.forCourse(widget.subject)), child: const Text('Retry')),
              TextButton(onPressed: () => Get.to(() => LibraryScreen(initialQuery: widget.subject)), child: const Text('Search library')),
            ]),
          );
        }
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Library resources', style: ScholonType.section(Colors.white)),
          const SizedBox(height: 4),
          Text('Matched by search intent from Internet Archive. Difficulty is not verified.', style: ScholonType.support(Colors.white54)),
          const SizedBox(height: 12),
          for (final g in groups) ...[
            Text(g.purpose.label, style: ScholonType.cardTitle(Colors.white)),
            Text(g.purpose.queryHint, style: ScholonType.support(Colors.white54)),
            const SizedBox(height: 8),
            SizedBox(
              height: 190,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: g.items.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => Get.to(() => LibraryItemScreen(item: g.items[i])),
                  child: SizedBox(
                    width: 112,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      ArchiveCover(item: g.items[i], width: 112, height: 140),
                      const SizedBox(height: 6),
                      Text(g.items[i].title, maxLines: 2, overflow: TextOverflow.ellipsis, style: ScholonType.support(Colors.white)),
                    ]),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],
        ]);
      },
    );
  }
}
