// lib/Kidling/screens/categories_activities_page.dart
//
// The "adventure path": a winding trail of levels. A level opens when the
// previous one is finished, so children always meet material that fits.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isapp/Kidling/controllers/audio_assistant_services.dart';
import 'package:isapp/Kidling/controllers/home_controller.dart';
import 'package:isapp/Kidling/models/kidling_model.dart';
import 'package:isapp/Kidling/screens/activity_page.dart';
import 'package:isapp/Kidling/theme/magic_theme.dart';
import 'package:isapp/Kidling/widgets/magic_widgets.dart';

class CategoryActivitiesPage extends StatefulWidget {
  final String categoryType; // ActivityType.name, e.g. 'phonics'
  const CategoryActivitiesPage({super.key, required this.categoryType});

  @override
  State<CategoryActivitiesPage> createState() => _CategoryActivitiesPageState();
}

class _CategoryActivitiesPageState extends State<CategoryActivitiesPage> {
  final HomeController home = Get.find<HomeController>();
  final AudioAssistantService audio = AudioAssistantService.ensure();

  ActivityType get type => ActivityType.values.firstWhere((t) => t.name == widget.categoryType, orElse: () => ActivityType.phonics);

  static const double _rowH = 150;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final w = WorldInfo.of(type);
      audio.speak('Welcome to ${w.name}! ${w.tagline}');
    });
  }

  @override
  Widget build(BuildContext context) {
    final w = WorldInfo.of(type);
    return Scaffold(
      body: MagicBackground(
        colors: [Magic.midnight, Color.lerp(Magic.dusk, w.deep, .55)!, Color.lerp(const Color(0xFFD9558F), w.color, .5)!, Color.lerp(Magic.peach, w.color, .35)!],
        child: SafeArea(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
              child: Row(children: [
                IconButton(icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 30), onPressed: () => Get.back()),
                Text(w.emoji, style: const TextStyle(fontSize: 34)),
                const SizedBox(width: 8),
                Expanded(child: Text(w.name, style: Magic.title(Colors.white, 26))),
                Obx(() => Text('${home.completedIn(type)}/${home.pathFor(type).length}', style: Magic.title(Magic.sun, 20))),
                const Icon(Icons.star_rounded, color: Magic.sun),
              ]),
            ),
            Expanded(
              child: Obx(() {
                final path = home.pathFor(type);
                home.progressMap.length; // subscribe
                if (path.isEmpty) return Center(child: Text('Adventures coming soon!', style: Magic.title(Colors.white, 22)));
                return LayoutBuilder(builder: (context, box) => _trail(path, box.maxWidth, w));
              }),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _trail(List<Activity> path, double width, WorldInfo w) {
    final height = path.length * _rowH + 80;
    final pts = <Offset>[
      for (var i = 0; i < path.length; i++) Offset(width / 2 + math.sin(i * 1.15) * (width * .27), 70 + i * _rowH),
    ];
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(children: [
          CustomPaint(size: Size(width, height), painter: _TrailPainter(pts)),
          for (var i = 0; i < path.length; i++) _node(path[i], pts[i], w),
        ]),
      ),
    );
  }

  Widget _node(Activity a, Offset p, WorldInfo w) {
    final unlocked = home.isUnlocked(a);
    final done = home.isCompleted(a);
    final stars = home.starsFor(a);
    final current = unlocked && !done && home.nextUp(a.type)?.id == a.id;
    const r = 44.0;
    return Positioned(
      left: p.dx - 90,
      top: p.dy - r - 4,
      width: 180,
      child: Bouncy(
        sound: unlocked,
        onTap: () {
          if (!unlocked) {
            audio.playSfx('wrong');
            audio.speak('Finish the level before this one to open it!');
            return;
          }
          Get.to(() => ActivityPage(activity: a));
        },
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Floaty(
            amplitude: current ? 10 : 0,
            child: Container(
              width: r * 2,
              height: r * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: unlocked ? LinearGradient(colors: [w.color, w.deep], begin: Alignment.topLeft, end: Alignment.bottomRight) : null,
                color: unlocked ? null : Colors.white24,
                border: Border.all(color: current ? Magic.sun : Colors.white, width: current ? 6 : 3),
                boxShadow: unlocked ? Magic.glow(current ? Magic.sun : w.color, blur: current ? 34 : 18, a: current ? .9 : .5) : null,
              ),
              alignment: Alignment.center,
              child: unlocked
                  ? (done ? Text('${a.level}', style: Magic.title(Colors.white, 34)) : Text(current ? '▶' : '${a.level}', style: Magic.title(Colors.white, current ? 30 : 34)))
                  : const Icon(Icons.lock_rounded, color: Colors.white54, size: 34),
            ),
          ),
          const SizedBox(height: 6),
          Text(a.title, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: Magic.title(unlocked ? Colors.white : Colors.white54, 15)),
          if (done) StarsRow(earned: stars, size: 20),
        ]),
      ),
    );
  }
}

class _TrailPainter extends CustomPainter {
  final List<Offset> pts;
  _TrailPainter(this.pts);

  @override
  void paint(Canvas canvas, Size size) {
    if (pts.length < 2) return;
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 1; i < pts.length; i++) {
      final a = pts[i - 1], b = pts[i];
      path.cubicTo(a.dx, a.dy + 70, b.dx, b.dy - 70, b.dx, b.dy);
    }
    for (final m in path.computeMetrics()) {
      var d = 0.0;
      final dot = Paint()..color = Colors.white.withOpacity(.55);
      while (d < m.length) {
        final t = m.getTangentForOffset(d);
        if (t != null) canvas.drawCircle(t.position, 4, dot);
        d += 20;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TrailPainter old) => old.pts != pts;
}
