// lib/Kidling/screens/activity_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isapp/Kidling/controllers/activity_controller.dart';
import 'package:isapp/Kidling/controllers/audio_assistant_services.dart';
import 'package:isapp/Kidling/models/kidling_model.dart';
import 'package:isapp/Kidling/screens/activities/phonics_activity.dart';
import 'package:isapp/Kidling/screens/activities/color_shape_activity.dart';
import 'package:isapp/Kidling/screens/activities/counting_activity.dart';
import 'package:isapp/Kidling/screens/activities/memory_activity.dart';
import 'package:isapp/Kidling/screens/activities/puzzle_activity.dart';
import 'package:isapp/Kidling/screens/activities/creativity_activity.dart';
import 'package:isapp/Kidling/screens/activities/emotion_activity.dart';
import 'package:isapp/Kidling/screens/activities/music_activity.dart';
import 'package:isapp/Kidling/theme/magic_theme.dart';
import 'package:isapp/Kidling/widgets/magic_widgets.dart';

class ActivityPage extends StatefulWidget {
  final Activity activity;
  const ActivityPage({super.key, required this.activity});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  late final ActivityController controller =
      Get.isRegistered<ActivityController>() ? Get.find<ActivityController>() : Get.put(ActivityController());

  @override
  void initState() {
    super.initState();
    AudioAssistantService.ensure();
    WidgetsBinding.instance.addPostFrameCallback((_) => controller.startActivity(widget.activity));
  }

  @override
  void dispose() {
    controller.endSession(widget.activity);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final world = widget.activity.world;
    return WillPopScope(
      onWillPop: () async {
        _confirmExit();
        return false;
      },
      child: Scaffold(
        body: MagicBackground(
          child: SafeArea(
            child: Column(
              children: [
                _topBar(world),
                Expanded(
                  child: Obx(() {
                    final current = controller.currentActivity.value;
                    if (current == null || current.id != widget.activity.id) {
                      return const Center(child: CircularProgressIndicator(color: Magic.sun));
                    }
                    // sessionId changes on "Play again" => the activity restarts fresh
                    return KeyedSubtree(key: ValueKey(controller.sessionId.value), child: _body(current));
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _topBar(WorldInfo world) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.close_rounded, color: Colors.white, size: 30), onPressed: _confirmExit),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${world.emoji} ${widget.activity.title}', maxLines: 1, overflow: TextOverflow.ellipsis, style: Magic.title(Colors.white, 18)),
                const SizedBox(height: 6),
                Obx(() => ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(end: controller.progressFraction),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutCubic,
                        builder: (_, v, __) => LinearProgressIndicator(value: v, minHeight: 10, backgroundColor: Colors.white24, valueColor: const AlwaysStoppedAnimation(Magic.sun)),
                      ),
                    )),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.lightbulb_rounded, color: Magic.sun, size: 28), onPressed: controller.requestHint),
          IconButton(icon: const Icon(Icons.volume_up_rounded, color: Colors.white, size: 28), onPressed: controller.playInstruction),
        ],
      ),
    );
  }

  Widget _body(Activity a) {
    switch (a.type) {
      case ActivityType.phonics:
        return PhonicsActivity(controller: controller, activity: a);
      case ActivityType.colorShape:
        return ColorShapeActivity(controller: controller, activity: a);
      case ActivityType.counting:
        return CountingActivity(controller: controller, activity: a);
      case ActivityType.memory:
        return MemoryActivity(controller: controller, activity: a);
      case ActivityType.puzzle:
        return PuzzleActivity(controller: controller, activity: a);
      case ActivityType.creativity:
        return CreativityActivity(controller: controller, activity: a);
      case ActivityType.emotion:
        return EmotionActivity(controller: controller, activity: a);
      case ActivityType.music:
        return MusicActivity(controller: controller, activity: a);
    }
  }

  Future<void> _confirmExit() async {
    final audio = AudioAssistantService.ensure();
    audio.speak('Do you want to stop playing?');
    final leave = await showDialog<bool>(
      context: context,
      barrierColor: Magic.midnight.withOpacity(.7),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Magic.dusk, Magic.midnight], begin: Alignment.topCenter, end: Alignment.bottomCenter),
            borderRadius: BorderRadius.circular(36),
            border: Border.all(color: Colors.white30, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Luma(size: 120, mood: LumaMood.sleepy),
              Text('Stop playing?', style: Magic.title(Colors.white, 28)),
              const SizedBox(height: 6),
              Text('Your stars are safe. Come back soon!', style: Magic.body(Colors.white70, 16), textAlign: TextAlign.center),
              const SizedBox(height: 20),
              BigButton(label: 'Keep playing', color: Magic.candy, onTap: () => Navigator.pop(ctx, false)),
              const SizedBox(height: 12),
              BigButton(label: 'Stop', outlined: true, onTap: () => Navigator.pop(ctx, true)),
            ],
          ),
        ),
      ),
    );
    if (leave == true) {
      audio.speak('See you next time!');
      Get.back();
    } else {
      controller.playInstruction();
    }
  }
}
