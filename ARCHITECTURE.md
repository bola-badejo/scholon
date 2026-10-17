# Scholon architecture (after modularization)

```
lib/
  main.dart                      7 lines: bind, bootstrap()
  app/                           bootstrap, routes, theme, DI (ServiceLocator), error app
  core/                          theme (colors, scholar_theme), constants, services, widgets, firebase config
  data/library/                  bundled curriculum + course data (moved out of Utils)
  features/
    auth/  onboarding/  home/  parents/  school/  teachers/  teachly/  learning/
    study_guide/ (NEW engine)  kidling/  affairs/  connect/  profile/  notes/
    reader/  quiz/  score_sheet/  games/  notifications/  policy/
test/
  study_guide_engine_test.dart   unit tests for spaced repetition, plan builder, XP
archive/                         38 files not reachable from main.dart (kept, not compiled)
```

Inside each feature: `models/ controllers/ services|data/ screens/ widgets/ bindings/`.

## Conventions used by the split
* One public class per file. A file that used to contain many classes now `export`s
  the pieces it gave away, so existing imports keep working.
* Very large `State` classes are divided into `<screen>_sections/NN_*.dart` files,
  which are `part of` the screen (extension methods on the State). They share the
  screen's private state. Next step: promote each section to its own StatelessWidget.
* `Kid*` prefix on Kidling's `KidActivityType` and `KidDifficulty` avoids clashes with
  the study guide and Sudoku.
