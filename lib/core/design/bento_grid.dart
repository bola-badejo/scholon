import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:isapp/core/design/breakpoints.dart';

/// A tile's footprint on the bento grid. On compact screens spans are clamped
/// to the available 4 columns, so one layout description works everywhere.
class BentoSpan {
  final int cols;
  final double rows; // height in grid units (1 unit ~ one column wide)
  const BentoSpan(this.cols, this.rows);

  static const small = BentoSpan(2, 1.0);
  static const wide = BentoSpan(4, 1.0);
  static const tall = BentoSpan(2, 2.0);
  static const hero = BentoSpan(4, 1.6);
  static const full = BentoSpan(99, 1.0); // always the full row
}

class BentoTile {
  final BentoSpan span;
  final Widget child;
  const BentoTile({required this.span, required this.child});
}

/// Responsive bento grid: 4 / 6 / 8 columns by screen class, centered and
/// capped at [Breakpoints.contentMaxWidth] so it never stretches absurdly.
class BentoGrid extends StatelessWidget {
  final List<BentoTile> tiles;
  final double gap;
  const BentoGrid({super.key, required this.tiles, this.gap = 14});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      final width = box.maxWidth.clamp(0.0, Breakpoints.contentMaxWidth);
      final cols = Breakpoints.bentoColumns(Breakpoints.of(box.maxWidth));
      return Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: width,
          child: StaggeredGrid.count(
            crossAxisCount: cols,
            mainAxisSpacing: gap,
            crossAxisSpacing: gap,
            children: [
              for (final t in tiles)
                StaggeredGridTile.count(
                  crossAxisCellCount: t.span.cols.clamp(1, cols),
                  mainAxisCellCount: t.span.rows,
                  child: t.child,
                ),
            ],
          ),
        ),
      );
    });
  }
}

/// Consistent card shell: radius, padding, optional tap target and semantics.
class BentoCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? color;
  final Gradient? gradient;
  final EdgeInsets padding;
  final String? semanticLabel;

  const BentoCard({super.key, required this.child, this.onTap, this.color, this.gradient, this.padding = const EdgeInsets.all(18), this.semanticLabel});

  @override
  Widget build(BuildContext context) {
    final deco = BoxDecoration(
      color: gradient == null ? (color ?? Colors.white.withOpacity(.08)) : null,
      gradient: gradient,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Colors.white.withOpacity(.12)),
    );
    final body = Padding(padding: padding, child: child);
    return Semantics(
      container: true,
      button: onTap != null,
      label: semanticLabel,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: deco,
          child: onTap == null ? body : InkWell(borderRadius: BorderRadius.circular(24), onTap: onTap, child: body),
        ),
      ),
    );
  }
}
