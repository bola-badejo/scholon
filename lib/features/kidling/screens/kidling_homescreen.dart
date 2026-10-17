// lib/Kidling/screens/kidling_homescreen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isapp/features/kidling/controllers/activity_controller.dart';
import 'package:isapp/features/kidling/controllers/audio_assistant_services.dart';
import 'package:isapp/features/kidling/controllers/home_controller.dart';
import 'package:isapp/features/kidling/models/kidling_model.dart';
import 'package:isapp/features/kidling/screens/activity_page.dart';
import 'package:isapp/features/kidling/screens/categories_activities_page.dart';
import 'package:isapp/features/kidling/screens/stats_page.dart';
import 'package:isapp/features/kidling/theme/magic_theme.dart';
import 'package:isapp/features/kidling/widgets/magic_widgets.dart';

class KidlingHomePage extends StatefulWidget {
  const KidlingHomePage({super.key});

  @override
  State<KidlingHomePage> createState() => _KidlingHomePageState();
}

class _KidlingHomePageState extends State<KidlingHomePage> {
  final HomeController home = Get.put(HomeController());
  final AudioAssistantService audio = AudioAssistantService.ensure();
  bool _greeted = false;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<ActivityController>()) Get.put(ActivityController());
    ever<bool>(home.isLoading, (loading) {
      if (!loading && !_greeted && mounted) {
        _greeted = true;
        audio.speak(home.welcomeSpeech);
      }
    });
  }

  @override
  void dispose() {
    audio.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MagicBackground(
        child: SafeArea(
          child: Obx(() {
            if (home.isLoading.value) return _loading();
            if (home.allActivities.isEmpty) return _empty();
            return RefreshIndicator(
              color: Magic.candy,
              onRefresh: home.refreshHomeData,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                slivers: [
                  SliverToBoxAdapter(child: _header()),
                  SliverToBoxAdapter(child: _lumaGreeting()),
                  SliverToBoxAdapter(child: _dailyGoal()),
                  SliverToBoxAdapter(child: _continueCard()),
                  SliverToBoxAdapter(child: _sectionTitle('Today\'s quests')),
                  SliverToBoxAdapter(child: _quests()),
                  SliverToBoxAdapter(child: _sectionTitle('Choose a world')),
                  _worlds(),
                  const SliverToBoxAdapter(child: SizedBox(height: 40)),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _loading() => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Luma(size: 170),
          const SizedBox(height: 12),
          Text('Getting the stars ready...', style: Magic.title(Colors.white, 22)),
        ]),
      );

  Widget _empty() => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Luma(size: 150, mood: LumaMood.oops),
            Text('No adventures yet', style: Magic.title(Colors.white, 26)),
            const SizedBox(height: 8),
            Text('Ask a grown-up to run SeedActivities.seedAllActivities().', textAlign: TextAlign.center, style: Magic.body(Colors.white70, 16)),
            const SizedBox(height: 16),
            BigButton(label: 'Try again', onTap: home.refreshHomeData),
          ]),
        ),
      );

  // ---------------- header ----------------
  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 12, 0),
      child: Row(children: [
        Text('Kidling', style: Magic.title(Colors.white, 28)),
        const Spacer(),
        _chip(Icons.star_rounded, '${home.totalStars}', Magic.sun),
        const SizedBox(width: 8),
        Obx(() => _chip(Icons.local_fire_department_rounded, '${home.currentChild.value?.progress.currentStreak ?? 0}', Colors.orangeAccent)),
        IconButton(
          tooltip: 'Grown-ups',
          icon: const Icon(Icons.lock_outline_rounded, color: Colors.white70),
          onPressed: () => ParentGate.open(context),
        ),
      ]),
    );
  }

  Widget _chip(IconData i, String t, Color c) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: Colors.white.withOpacity(.18), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white30)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(i, color: c, size: 20),
          const SizedBox(width: 4),
          Text(t, style: Magic.title(Colors.white, 17)),
        ]),
      );

  Widget _lumaGreeting() => Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
        child: LumaSays(
          text: home.greetingMessage,
          lumaSize: 100,
          mood: LumaMood.cheer,
          onTap: () => audio.speak(home.welcomeSpeech),
        ),
      );

  Widget _dailyGoal() {
    final done = home.todayProgress.value.activitiesCompleted;
    final goal = HomeController.dailyGoal;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Row(children: [
          Expanded(
            child: Text(done >= goal ? 'Daily goal complete!' : 'Today: $done of $goal adventures', style: Magic.title(Colors.white, 18)),
          ),
          StarsRow(earned: done.clamp(0, goal), total: goal, size: 32),
        ]),
      ),
    );
  }

  Widget _continueCard() {
    final a = home.resumeCandidate;
    if (a == null) return const SizedBox();
    final w = a.world;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Bouncy(
        onTap: () => _start(a),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [w.color, w.deep], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(30),
            boxShadow: Magic.glow(w.color, blur: 26, a: .5),
          ),
          child: Row(children: [
            Floaty(child: Text(w.emoji, style: const TextStyle(fontSize: 54))),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Keep going', style: Magic.body(Colors.white70, 14)),
                Text(a.title, style: Magic.title(Colors.white, 22)),
              ]),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Icon(Icons.play_arrow_rounded, color: w.deep, size: 32),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 24, 20, 10),
        child: Text(t, style: Magic.title(Colors.white, 24)),
      );

  Widget _quests() {
    final list = home.recommendedActivities;
    if (list.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: GlassCard(child: Text('You finished everything! More adventures are coming soon.', style: Magic.body(Colors.white, 16))),
      );
    }
    return SizedBox(
      height: 170,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (_, i) {
          final a = list[i];
          final w = a.world;
          return Bouncy(
            onTap: () => _start(a),
            child: Container(
              width: 160,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [w.color, w.deep], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(28),
                boxShadow: Magic.glow(w.color, blur: 20, a: .45),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(w.emoji, style: const TextStyle(fontSize: 38)),
                const Spacer(),
                Text(a.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: Magic.title(Colors.white, 18)),
                const SizedBox(height: 4),
                Text('Level ${a.level}', style: Magic.body(Colors.white70, 13)),
              ]),
            ),
          );
        },
      ),
    );
  }

  Widget _worlds() {
    final types = KidActivityType.values;
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: .92),
        delegate: SliverChildBuilderDelegate((ctx, i) {
          final t = types[i];
          final w = WorldInfo.of(t);
          final progress = home.worldProgress(t);
          return Bouncy(
            onTap: () => _openWorld(t),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [w.color, w.deep], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(32),
                boxShadow: Magic.glow(w.color, blur: 22, a: .4),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Floaty(phase: i * .13, child: Text(w.emoji, style: const TextStyle(fontSize: 44))),
                  const Spacer(),
                  SizedBox(
                    width: 38,
                    height: 38,
                    child: Stack(alignment: Alignment.center, children: [
                      CircularProgressIndicator(value: progress, strokeWidth: 5, backgroundColor: Colors.white24, valueColor: const AlwaysStoppedAnimation(Magic.sun)),
                      progress >= 1 ? const Icon(Icons.check_rounded, color: Colors.white, size: 18) : const SizedBox(),
                    ]),
                  ),
                ]),
                const Spacer(),
                Text(w.name, style: Magic.title(Colors.white, 20)),
                const SizedBox(height: 2),
                Text(w.tagline, maxLines: 2, overflow: TextOverflow.ellipsis, style: Magic.body(Colors.white70, 13)),
              ]),
            ),
          );
        }, childCount: types.length),
      ),
    );
  }

  void _start(Activity a) {
    audio.speak('Let us go!');
    Get.to(() => ActivityPage(activity: a));
  }

  void _openWorld(KidActivityType t) {
    audio.speak(WorldInfo.of(t).name);
    Get.to(() => CategoryActivitiesPage(categoryType: t.name));
  }
}
