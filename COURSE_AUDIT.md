# Course audit (real numbers from the repository)

## Catalog A: `Constants.courseCategoriesJson` (course_logic.dart)

| Category | Courses | Topics | Notes | Quizzes | Courses with 0 topics |
|---|---|---|---|---|---|
| Mathematics | 15 | 15 | 45 | 0 | 0 |
| English Language | 16 | 7 | 20 | 0 | 9 |
| Chemistry | 6 | 1 | 3 | 0 | 5 |
| Physics | 6 | 1 | 3 | 0 | 5 |

Totals: 43 courses, 24 topics, 71 notes; 19 courses have no topics at all.

Note body length (words): min 23, median 44, max 142, notes under 150 words: 71 of 71.

## `quizCategoriesJson`
4 top-level categories: Mathematics, English Language, Chemistry, Physics

## `examCategoriesJson`
3 top-level categories: JAMB, WAEC, NECO

## Catalog B: `Courses.ss3Curriculum` (new_courses.dart)

| Course | Terms | Weeks | Notes | Quizzes | Assignments |
|---|---|---|---|---|---|
| Advanced Mathematics | 3 | 4 | 9 | 7 | 8 |
| Advanced Physics | 3 | 3 | 6 | 3 | 3 |
| Advanced Chemistry | 3 | 3 | 6 | 3 | 3 |

Courses in SS3 curriculum: 3

## Findings
* The study guide can only schedule topics that exist: the SS3 curriculum has **3 courses and 10 weeks**.
* In the main catalogue, **19 of 43 courses have no topics at all**; Chemistry and Physics have 1 topic each.
* All 71 notes are under 150 words (median 44). They are summaries, not lessons.
* No quizzes are attached to catalogue topics (0), and there are no verified videos in the study flow.
* Primary school, JSS and SS1/SS2 have no curriculum data at all.

## Required before any course is marked Published
Per course: outcomes, prerequisites, modules, full lessons with worked examples, practice, assessment,
verified video links, references. Track status as Draft / In Review / Published / Needs Improvement.
Recommended pipeline: author in structured JSON (assets/curriculum/*.json), validate with a schema
script, load through `CurriculumTopicSource` and `CurriculumKnowledgeBuilder` (both already read it).
