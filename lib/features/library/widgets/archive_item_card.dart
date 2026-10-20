import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:isapp/core/design/bento_grid.dart';
import 'package:isapp/core/design/scholon_type.dart';
import 'package:isapp/core/theme/scholar_theme.dart';
import 'package:isapp/features/library/models/archive_item.dart';

class AccessBadge extends StatelessWidget {
  final AccessStatus status;
  const AccessBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (status) {
      AccessStatus.openLicensed => (Scholar.mint, Icons.lock_open_rounded),
      AccessStatus.borrowOrRestricted => (Scholar.sun, Icons.lock_clock_rounded),
      AccessStatus.viewOnArchive => (Scholar.sky, Icons.open_in_new_rounded),
    };
    return Semantics(
      label: 'Access: ${status.label}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: color.withOpacity(.16), borderRadius: BorderRadius.circular(10)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(status.label, style: ScholonType.label(color)),
        ]),
      ),
    );
  }
}

class ArchiveCover extends StatelessWidget {
  final ArchiveItem item;
  final double? width;
  final double? height;
  const ArchiveCover({super.key, required this.item, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: width,
      height: height,
      color: Colors.white10,
      alignment: Alignment.center,
      child: const Icon(Icons.menu_book_rounded, color: Colors.white38, size: 32),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: CachedNetworkImage(
        imageUrl: item.coverUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        placeholder: (_, __) => placeholder,
        errorWidget: (_, __, ___) => placeholder,
        fadeInDuration: const Duration(milliseconds: 250),
      ),
    );
  }
}

class ArchiveItemCard extends StatelessWidget {
  final ArchiveItem item;
  final bool saved;
  final VoidCallback onTap;
  final VoidCallback onToggleSave;
  const ArchiveItemCard({super.key, required this.item, required this.saved, required this.onTap, required this.onToggleSave});

  @override
  Widget build(BuildContext context) {
    return BentoCard(
      onTap: onTap,
      semanticLabel: '${item.title} by ${item.authorLine}',
      padding: const EdgeInsets.all(12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ArchiveCover(item: item, width: 74, height: 104),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: ScholonType.cardTitle(Colors.white)),
            const SizedBox(height: 4),
            Text('${item.authorLine}${item.year.isEmpty ? '' : '  -  ${item.year}'}', maxLines: 1, overflow: TextOverflow.ellipsis, style: ScholonType.support(Colors.white70)),
            const SizedBox(height: 8),
            AccessBadge(status: item.access),
          ]),
        ),
        IconButton(
          tooltip: saved ? 'Remove from saved' : 'Save for later',
          onPressed: onToggleSave,
          icon: Icon(saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, color: saved ? Scholar.sun : Colors.white54),
        ),
      ]),
    );
  }
}
