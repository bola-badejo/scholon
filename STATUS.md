# Scholon transformation: honest status

Nothing in this package has been compiled or run. The sandbox has no Flutter/Dart SDK, so
`flutter analyze`, `flutter test` and builds are **not verified**. What WAS verified (by scripts
I wrote): every import resolves, brackets balance, no ambiguous type imports, no cross-library
private access, every file reachable from `main.dart`. Expect some compile errors on first build.

## Done (code exists)
| Area | State |
|---|---|
| Modular architecture | 357 files, feature-first, `app/` bootstrap, `core/`, `data/`, 38 unreachable files archived |
| Design system foundation | breakpoints, Inter typography + serif reading style, `BentoGrid`/`BentoCard`, `ReadingColumn` |
| Bento dashboard | `/dashboard`, built only from real data, honest empty states |
| Study guide (adaptive) | SM-2 spaced repetition, staged mastery (learn/practice/check/master), adaptive daily plan, XP/streak, focus timer, exam mode, self-rating; unit tests written |
| Internet Archive library | search/filter/details/save/recent/cache, access status from metadata only, links OUT to archive.org, course-contextual shelf; unit tests written |
| AI tutor (architecture) | BM25 retrieval with citations, prompt-injection scrubbing, provider chain, streaming chat UI, stop/retry/history, honest offline lookup; gateway reference server |

## NOT done (be clear-eyed)
* **No model is installed or benchmarked.** The AI tutor produces generative answers only once
  `SCHOLON_AI_URL` points at a running gateway + model. Otherwise it says it is offline and shows
  course passages (labelled "not AI-generated"). On-device inference is an interface only.
* **Course content is NOT expanded.** See COURSE_AUDIT.md: the real catalogue is thin. Writing
  rigorous lessons, exercises and verified videos is a large authoring effort not performed here.
* **No videos** were added or verified; no video player/transcript work.
* **Reader redesign, onboarding/splash redesign, global navigation shell, accessibility audit,
  offline model manager, WebGPU path** are not implemented.
* The old giant screens (home_page, connect_screen, teacher_page...) are only split by file; they
  still use their old visuals.
* Vector search, embeddings, transcript indexing, book-text indexing: not built (BM25 only).
* Internet Archive cover URL (`/services/img/{id}`) is unverified; UI degrades to a placeholder.
