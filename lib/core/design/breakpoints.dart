import 'package:flutter/widgets.dart';

/// Central responsive rules. Every adaptive widget in Scholon reads these.
enum ScreenClass { compact, medium, expanded, large }

class Breakpoints {
  Breakpoints._();

  static const double medium = 600;
  static const double expanded = 1024;
  static const double large = 1440;

  /// Reading columns never exceed this, however wide the window is.
  static const double readingMaxWidth = 720;
  static const double contentMaxWidth = 1280;

  static ScreenClass of(double width) {
    if (width < medium) return ScreenClass.compact;
    if (width < expanded) return ScreenClass.medium;
    if (width < large) return ScreenClass.expanded;
    return ScreenClass.large;
  }

  static ScreenClass ofContext(BuildContext context) => of(MediaQuery.sizeOf(context).width);

  /// Bento grid columns: 4 on phones, 6 on tablets, 8 on desktop.
  static int bentoColumns(ScreenClass c) {
    switch (c) {
      case ScreenClass.compact:
        return 4;
      case ScreenClass.medium:
        return 6;
      case ScreenClass.expanded:
      case ScreenClass.large:
        return 8;
    }
  }
}
