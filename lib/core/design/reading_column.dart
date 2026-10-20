import 'package:flutter/material.dart';
import 'package:isapp/core/design/breakpoints.dart';

/// Keeps long-form text at a comfortable measure (~65-75 characters).
class ReadingColumn extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const ReadingColumn({super.key, required this.child, this.padding = const EdgeInsets.symmetric(horizontal: 20)});

  @override
  Widget build(BuildContext context) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: Breakpoints.readingMaxWidth),
          child: Padding(padding: padding, child: child),
        ),
      );
}
