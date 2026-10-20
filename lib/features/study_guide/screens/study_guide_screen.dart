import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:isapp/core/theme/scholar_theme.dart';
import 'package:isapp/features/ai_tutor/models/ai_models.dart';
import 'package:isapp/features/ai_tutor/widgets/ask_scholon_button.dart';
import 'package:isapp/features/learning/screens/activity_gateway.dart';
import 'package:isapp/features/library/widgets/course_resources.dart';
import 'package:isapp/features/study_guide/controllers/study_guide_controller.dart';
import 'package:isapp/features/study_guide/models/plan_item.dart';
import 'package:isapp/features/study_guide/widgets/focus_timer_card.dart';
import 'package:isapp/features/study_guide/widgets/mastery_map.dart';
import 'package:isapp/features/study_guide/widgets/plan_settings_card.dart';
import 'package:isapp/features/study_guide/widgets/plan_tile.dart';
import 'package:isapp/features/study_guide/widgets/progress_header.dart';
import 'package:isapp/features/study_guide/widgets/rate_sheet.dart';
import 'package:isapp/features/study_guide/widgets/stage_style.dart';
import 'package:isapp/features/study_guide/widgets/weekly_chart.dart';

/// Adaptive study guide: today's plan, focus timer, mastery map, weekly rhythm.
class StudyGuideScreen extends StatelessWidget {
  const StudyGuideScreen({super.key});

  StudyGuideController get c => Get.find<StudyGuideController>();

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<StudyGuideController>()) Get.put(StudyGuideController());
    return Scaffold(
      floatingActionButton: Obx(() {
        final next = c.plan.firstWhereOrNull((i) => !c.doneIds.contains(i.id));
        return AskScholonButton(
          context: AiContext(screen: 'study-guide', courseCode: next?.topic.courseCode, courseName: next?.topic.subject, lessonTitle: next?.topic.title),
        );
      }),
      body: Container(
        decoration: const BoxDecoration(gradient: Scholar.backdrop),
        child: SafeArea(
          child: Obx(() {
            if (c.isLoading.value) return const Center(child: CircularProgressIndicator(color: Scholar.aurora));
            return RefreshIndicator(
              color: Scholar.aurora,
              onRefresh: c.load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                children: [
                  _topBar(),
                  const SizedBox(height: 16),
                  ProgressHeader(c: c).animate().fadeIn(duration: 400.ms).slideY(begin: .08),
                  const SizedBox(height: 20),
                  _todaySection(context),
                  const SizedBox(height: 24),
                  _section('Focus', FocusTimerCard(c: c), delay: 100),
                  _section('Your week', WeeklyChart(c: c), delay: 150),
                  _section('Mastery map', MasteryMap(c: c), delay: 200),
                  _weakSpots(context),
                  _libraryFor(),
                  _section('Plan settings', PlanSettingsCard(c: c), delay: 250),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _topBar() => Row(children: [
        IconButton(onPressed: Get.back, icon: const Icon(Icons.arrow_back_rounded, color: Colors.white)),
        const SizedBox(width: 4),
        Text('Study Guide', style: Scholar.h1()),
        const Spacer(),
        Obx(() => c.dueCount == 0
            ? const SizedBox()
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: Scholar.coral.withOpacity(.18), borderRadius: BorderRadius.circular(16)),
                child: Text('${c.dueCount} due', style: const TextStyle(color: Scholar.coral, fontWeight: FontWeight.w700)),
              )),
      ]);

  Widget _section(String title, Widget child, {int delay = 0}) => Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: Scholar.h2()),
          const SizedBox(height: 12),
          Container(width: double.infinity, padding: const EdgeInsets.all(18), decoration: Scholar.glass(), child: child),
        ]).animate().fadeIn(delay: delay.ms, duration: 400.ms).slideY(begin: .06),
      );

  Widget _todaySection(BuildContext context) {
    return Obx(() {
      final plan = c.plan;
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text("Today's plan", style: Scholar.h2()),
          const Spacer(),
          Text('${c.doneCount}/${plan.length}  -  ${c.plannedMinutes} min', style: Scholar.body()),
        ]),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: c.dayProgress),
            duration: const Duration(milliseconds: 600),
            builder: (_, v, __) => LinearProgressIndicator(value: v, minHeight: 8, backgroundColor: Colors.white12, valueColor: const AlwaysStoppedAnimation(Scholar.mint)),
          ),
        ),
        const SizedBox(height: 14),
        if (c.error.value.isNotEmpty && plan.isEmpty)
          _empty(c.error.value, Icons.cloud_off_rounded)
        else if (c.dayComplete)
          _celebrate()
        else if (plan.isEmpty)
          _empty('Nothing planned. Pull down to refresh.', Icons.inbox_rounded)
        else
          for (var i = 0; i < plan.length; i++)
            PlanTile(item: plan[i], index: i, done: c.doneIds.contains(plan[i].id), onStart: () => _start(plan[i])).animate().fadeIn(delay: (80 * i).ms).slideX(begin: .08),
        if (c.dayComplete && plan.isNotEmpty)
          for (var i = 0; i < plan.length; i++) PlanTile(item: plan[i], index: i, done: true, onStart: () {}),
      ]);
    });
  }

  Widget _celebrate() => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(gradient: const LinearGradient(colors: [Scholar.mint, Scholar.aurora]), borderRadius: BorderRadius.circular(24)),
        child: Column(children: [
          const Icon(Icons.emoji_events_rounded, size: 52, color: Scholar.night),
          const SizedBox(height: 8),
          const Text('Day complete!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Scholar.night)),
          const SizedBox(height: 4),
          Text('Your streak is safe. Come back tomorrow for fresh reviews.', textAlign: TextAlign.center, style: Scholar.body(Scholar.night)),
        ]),
      ).animate().scale(duration: 500.ms, curve: Curves.elasticOut);

  Widget _empty(String msg, IconData icon) => Container(
        padding: const EdgeInsets.all(22),
        decoration: Scholar.glass(),
        child: Row(children: [Icon(icon, color: Colors.white38, size: 32), const SizedBox(width: 14), Expanded(child: Text(msg, style: Scholar.body()))]),
      );

  /// Real Internet Archive suggestions for the subject the student needs most.
  Widget _libraryFor() {
    return Obx(() {
      final subject = c.weakSpots.isNotEmpty ? c.weakSpots.first.subject : (c.plan.isNotEmpty ? c.plan.first.topic.subject : null);
      if (subject == null) return const SizedBox();
      return _section('Read more: $subject', CourseResourcesSection(key: ValueKey(subject), subject: subject), delay: 240);
    });
  }

  Widget _weakSpots(BuildContext context) {
    return Obx(() {
      final weak = c.weakSpots;
      if (weak.isEmpty) return const SizedBox();
      return _section(
        'Needs attention',
        Column(children: [
          for (final r in weak)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(backgroundColor: Scholar.coral.withOpacity(.18), child: Text('${(r.mastery * 100).round()}', style: const TextStyle(color: Scholar.coral, fontWeight: FontWeight.w800))),
              title: Text(r.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              subtitle: Text('${r.subject}  -  ${r.stage.label}', style: Scholar.body()),
              trailing: Icon(StageStyle.icon(r.stage), color: StageStyle.color(r.stage)),
            ),
        ]),
        delay: 220,
      );
    });
  }

  /// Opens the existing activity screens, then asks the student to rate recall.
  Future<void> _start(PlanItem item) async {
    final watch = Stopwatch()..start();
    await Get.to(() => ActivityGatewayScreen(activity: item.toDailyActivity(DateTime.now())));
    final minutes = watch.elapsed.inMinutes.clamp(1, item.minutes * 2);
    final quality = await RateSheet.show(item);
    if (quality == null) return;
    final xp = await c.completeItem(item, quality: quality, minutesSpent: minutes);
    Get.snackbar('+$xp XP', quality >= 4 ? 'Strong recall. See you for review soon.' : 'Good honesty. We will revisit this sooner.',
        snackPosition: SnackPosition.BOTTOM, backgroundColor: Scholar.indigo, colorText: Colors.white, margin: const EdgeInsets.all(16));
  }
}
