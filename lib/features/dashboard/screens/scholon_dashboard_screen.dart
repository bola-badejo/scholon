import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isapp/core/design/bento_grid.dart';
import 'package:isapp/core/design/scholon_type.dart';
import 'package:isapp/core/theme/scholar_theme.dart';
import 'package:isapp/features/ai_tutor/controllers/ai_tutor_controller.dart';
import 'package:isapp/features/ai_tutor/models/ai_models.dart';
import 'package:isapp/features/ai_tutor/screens/ai_tutor_screen.dart';
import 'package:isapp/features/library/controllers/library_controller.dart';
import 'package:isapp/features/library/screens/library_item_screen.dart';
import 'package:isapp/features/library/screens/library_screen.dart';
import 'package:isapp/features/library/widgets/archive_item_card.dart';
import 'package:isapp/features/study_guide/controllers/study_guide_controller.dart';
import 'package:isapp/features/study_guide/screens/study_guide_screen.dart';

/// Bento dashboard built ONLY from real data. A tile with nothing to show
/// says what to do next instead of inventing activity.
class ScholonDashboardScreen extends StatelessWidget {
  const ScholonDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final guide = Get.isRegistered<StudyGuideController>() ? Get.find<StudyGuideController>() : Get.put(StudyGuideController());
    final lib = Get.isRegistered<LibraryController>() ? Get.find<LibraryController>() : Get.put(LibraryController());
    final ai = Get.isRegistered<AiTutorController>() ? Get.find<AiTutorController>() : Get.put(AiTutorController());

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: Scholar.backdrop),
        child: SafeArea(
          child: ListView(padding: const EdgeInsets.all(16), children: [
            Padding(padding: const EdgeInsets.fromLTRB(4, 8, 4, 16), child: Text('Your learning', style: ScholonType.display(Colors.white))),
            Obx(() => BentoGrid(tiles: [
                  BentoTile(span: BentoSpan.hero, child: _continue(guide)),
                  BentoTile(span: BentoSpan.small, child: _tutor(ai)),
                  BentoTile(span: BentoSpan.small, child: _progress(guide)),
                  BentoTile(span: BentoSpan.wide, child: _library(lib)),
                  BentoTile(span: BentoSpan.wide, child: _practice(guide)),
                ])),
          ]),
        ),
      ),
    );
  }

  Widget _continue(StudyGuideController g) {
    if (g.isLoading.value) return const BentoCard(child: Center(child: CircularProgressIndicator(color: Scholar.aurora)));
    final next = g.plan.firstWhereOrNull((i) => !g.doneIds.contains(i.id));
    return BentoCard(
      gradient: const LinearGradient(colors: [Scholar.violet, Color(0xFF2E6BE6)]),
      onTap: () => Get.to(() => const StudyGuideScreen()),
      semanticLabel: 'Continue learning',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(next == null ? (g.plan.isEmpty ? 'Start your study guide' : 'Today is complete') : 'Continue learning', style: ScholonType.label(Colors.white70)),
        Text(next?.topic.title ?? (g.plan.isEmpty ? 'Set your daily time and exam date to get a plan.' : 'Your next review will appear tomorrow.'), maxLines: 3, overflow: TextOverflow.ellipsis, style: ScholonType.section(Colors.white)),
        Row(children: [
          Text(next == null ? 'Open study guide' : '${next.stage.label}  -  ${next.minutes} min', style: ScholonType.support(Colors.white)),
          const Spacer(),
          const Icon(Icons.arrow_forward_rounded, color: Colors.white),
        ]),
      ]),
    );
  }

  Widget _tutor(AiTutorController ai) => BentoCard(
        onTap: () => AiTutorScreen.open(const AiContext(screen: 'home')),
        semanticLabel: 'Ask Scholon AI',
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.auto_awesome_rounded, color: Scholar.aurora, size: 28),
          const Spacer(),
          Text('Scholon AI', style: ScholonType.cardTitle(Colors.white)),
          Text(ai.status.value.available ? 'Online' : 'Offline lookup', style: ScholonType.support(ai.status.value.available ? Scholar.mint : Scholar.sun)),
        ]),
      );

  Widget _progress(StudyGuideController g) {
    final p = g.progress.value;
    return BentoCard(
      onTap: () => Get.to(() => const StudyGuideScreen()),
      semanticLabel: 'Progress: level ${p.level}, ${p.streak} day streak',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Level ${p.level}', style: ScholonType.cardTitle(Colors.white)),
        const Spacer(),
        Text(p.streak == 0 ? 'No streak yet' : '${p.streak} day streak', style: ScholonType.support(Scholar.sun)),
        const SizedBox(height: 6),
        LinearProgressIndicator(value: p.levelProgress, minHeight: 6, backgroundColor: Colors.white12, valueColor: const AlwaysStoppedAnimation(Scholar.aurora)),
      ]),
    );
  }

  Widget _library(LibraryController lib) {
    final items = lib.recent.isNotEmpty ? lib.recent : lib.saved;
    return BentoCard(
      onTap: () => Get.to(() => const LibraryScreen()),
      semanticLabel: 'Open library',
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Library', style: ScholonType.cardTitle(Colors.white)),
            const SizedBox(height: 4),
            Text(items.isEmpty ? 'Search millions of books on Internet Archive.' : 'Pick up where you left off.', style: ScholonType.support(Colors.white70)),
            const Spacer(),
            const Row(children: [Text('Browse', style: TextStyle(color: Scholar.aurora, fontWeight: FontWeight.w600)), SizedBox(width: 4), Icon(Icons.arrow_forward_rounded, size: 16, color: Scholar.aurora)]),
          ]),
        ),
        for (final i in items.take(2))
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: GestureDetector(onTap: () => Get.to(() => LibraryItemScreen(item: i)), child: ArchiveCover(item: i, width: 62, height: 90)),
          ),
      ]),
    );
  }

  Widget _practice(StudyGuideController g) {
    final due = g.dueCount;
    final weak = g.weakSpots;
    return BentoCard(
      onTap: () => Get.to(() => const StudyGuideScreen()),
      semanticLabel: 'Practice',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Practice', style: ScholonType.cardTitle(Colors.white)),
        const SizedBox(height: 6),
        Text(due > 0 ? '$due topics are due for review.' : (weak.isNotEmpty ? 'Weakest topic: ${weak.first.title}' : 'Finish a lesson to unlock reviews and quizzes.'), maxLines: 2, overflow: TextOverflow.ellipsis, style: ScholonType.body(Colors.white70)),
      ]),
    );
  }
}
