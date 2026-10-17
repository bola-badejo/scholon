// lib/Kidling/screens/stats_page.dart
//
// "Grown-ups corner": gated so little fingers cannot wander in, and written
// for parents: what was practised, what needs help, and what to try at home.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:isapp/features/kidling/controllers/audio_assistant_services.dart';
import 'package:isapp/features/kidling/controllers/progress_controller.dart';
import 'package:isapp/features/kidling/models/kidling_model.dart';
import 'package:isapp/features/kidling/theme/magic_theme.dart';

/// Simple math gate: "What is 7 + 6?" Preschoolers cannot answer it.
class ParentGate {
  static Future<void> open(BuildContext context) async {
    final rnd = math.Random();
    final a = 6 + rnd.nextInt(5), b = 4 + rnd.nextInt(5);
    final answer = a + b;
    final opts = <int>{answer, answer + 2, answer - 3}.toList()..shuffle();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Magic.cream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text('Grown-ups only', style: Magic.title(Magic.ink, 24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('What is $a + $b ?', style: Magic.title(Magic.dusk, 30)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              children: opts
                  .map((o) => ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Magic.dusk, shape: const StadiumBorder(), padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12)),
                        onPressed: () => Navigator.pop(ctx, o == answer),
                        child: Text('$o', style: Magic.title(Colors.white, 22)),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
    if (ok == true) Get.to(() => const StatsPage());
  }
}

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final pc = Get.put(ProgressController());
    final audio = AudioAssistantService.ensure();

    return Scaffold(
      backgroundColor: Magic.cream,
      appBar: AppBar(
        backgroundColor: Magic.cream,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: Magic.ink), onPressed: () => Get.back()),
        title: Text('Learning Report', style: Magic.title(Magic.ink, 24)),
      ),
      body: Obx(() {
        if (pc.isLoading.value) return const Center(child: CircularProgressIndicator(color: Magic.candy));
        return RefreshIndicator(
          onRefresh: pc.loadAllProgress,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _hero(pc),
              const SizedBox(height: 18),
              _card('This week', _weekly(pc), 'Minutes of learning each day'),
              const SizedBox(height: 18),
              _card('Skills', _radar(pc), 'Mastery combines accuracy with practice'),
              const SizedBox(height: 18),
              _card('Worlds', Column(children: pc.categoryAccuracy.entries.map((e) => _bar(e.key, e.value)).toList()), pc.categoryAccuracy.isEmpty ? 'Finish an activity to see progress.' : 'Average first-try accuracy'),
              const SizedBox(height: 18),
              _practice(pc),
              const SizedBox(height: 18),
              _settings(audio),
              const SizedBox(height: 30),
            ],
          ),
        );
      }),
    );
  }

  Widget _hero(ProgressController pc) {
    final s = pc.overallSummary.value;
    Widget stat(IconData i, String v, String l) => Column(children: [
          Icon(i, color: Magic.sun, size: 28),
          const SizedBox(height: 6),
          Text(v, style: Magic.title(Colors.white, 26)),
          Text(l, style: Magic.body(Colors.white70, 13)),
        ]);
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Magic.midnight, Magic.dusk], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          stat(Icons.timer_rounded, '${s.totalTimeSpentMinutes}', 'minutes'),
          stat(Icons.check_circle_rounded, '${s.totalActivitiesCompleted}', 'activities'),
          stat(Icons.star_rounded, '${s.starsEarned}', 'stars'),
        ]),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
          decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(20)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.local_fire_department_rounded, color: Colors.orangeAccent, size: 28),
            const SizedBox(width: 8),
            Text('${s.currentStreak} day streak', style: Magic.title(Colors.white, 20)),
            const SizedBox(width: 14),
            Text('Accuracy ${pc.overallAccuracy.toStringAsFixed(0)}%', style: Magic.body(Colors.white70, 15)),
          ]),
        ),
      ]),
    );
  }

  Widget _card(String title, Widget child, String footnote) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), boxShadow: [BoxShadow(color: Magic.dusk.withOpacity(.08), blurRadius: 16, offset: const Offset(0, 6))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: Magic.title(Magic.ink, 21)),
          const SizedBox(height: 14),
          child,
          const SizedBox(height: 10),
          Text(footnote, style: Magic.body(Magic.ink.withOpacity(.55), 13)),
        ]),
      );

  Widget _weekly(ProgressController pc) {
    final data = pc.weeklyChartData;
    final maxMin = data.fold<int>(10, (m, e) => math.max(m, e['minutes'] as int));
    return SizedBox(
      height: 190,
      child: BarChart(BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (maxMin * 1.25).ceilToDouble(),
        barGroups: data.asMap().entries
            .map((e) => BarChartGroupData(x: e.key, barRods: [
                  BarChartRodData(toY: (e.value['minutes'] as int).toDouble(), color: Magic.candy, width: 20, borderRadius: BorderRadius.circular(6)),
                ]))
            .toList(),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, m) => v.toInt() < data.length ? Text(data[v.toInt()]['day'], style: Magic.body(Magic.ink, 12)) : const Text(''),
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 34)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
      )),
    );
  }

  Widget _radar(ProgressController pc) {
    final skills = pc.skillsProgress;
    final labels = skills.keys.toList();
    return SizedBox(
      height: 250,
      child: RadarChart(RadarChartData(
        dataSets: [
          RadarDataSet(
            dataEntries: skills.values.map((v) => RadarEntry(value: math.max(v, .06))).toList(),
            fillColor: Magic.candy.withOpacity(.3),
            borderColor: Magic.candy,
            borderWidth: 2,
            entryRadius: 4,
          ),
        ],
        radarShape: RadarShape.polygon,
        tickCount: 4,
        ticksTextStyle: const TextStyle(fontSize: 0, color: Colors.transparent),
        getTitle: (i, angle) => i < labels.length ? RadarChartTitle(text: labels[i], angle: angle) : const RadarChartTitle(text: ''),
        titlePositionPercentageOffset: 0.2,
        radarBorderData: const BorderSide(color: Colors.grey, width: 1),
        gridBorderData: const BorderSide(color: Colors.grey, width: .5),
      )),
    );
  }

  Widget _bar(String category, double acc) {
    final color = _colorFor(category);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(category, style: Magic.body(Magic.ink, 15)),
          Text('${acc.toStringAsFixed(0)}%', style: Magic.title(color, 16)),
        ]),
        const SizedBox(height: 6),
        ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: (acc / 100).clamp(0.0, 1.0), minHeight: 10, backgroundColor: color.withOpacity(.12), color: color)),
      ]),
    );
  }

  Widget _practice(ProgressController pc) {
    final items = pc.needsPractice;
    final weakest = pc.weakestCategory;
    final tip = _tipFor(weakest);
    return _card(
      'Needs a little practice',
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (items.isEmpty)
          Text('No trouble spots yet. Keep playing!', style: Magic.body(Magic.ink, 16))
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items
                .map((e) => Chip(
                      backgroundColor: Magic.sun.withOpacity(.35),
                      label: Text('${e.key}  x${e.value}', style: Magic.body(Magic.ink, 14)),
                    ))
                .toList(),
          ),
        if (tip != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Magic.mint.withOpacity(.2), borderRadius: BorderRadius.circular(18)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('💡 ', style: TextStyle(fontSize: 22)),
              Expanded(child: Text('Try at home: $tip', style: Magic.body(Magic.ink, 15))),
            ]),
          ),
        ],
      ]),
      'Shows what was missed on the first try.',
    );
  }

  Widget _settings(AudioAssistantService audio) => _card(
        'Sound',
        Column(children: [
          Obx(() => SwitchListTile(contentPadding: EdgeInsets.zero, activeColor: Magic.candy, title: Text('Luma\'s voice', style: Magic.body(Magic.ink, 16)), value: audio.voiceOn.value, onChanged: (v) => audio.voiceOn.value = v)),
          Obx(() => SwitchListTile(contentPadding: EdgeInsets.zero, activeColor: Magic.candy, title: Text('Sounds and music', style: Magic.body(Magic.ink, 16)), value: audio.soundOn.value, onChanged: (v) => audio.soundOn.value = v)),
        ]),
        'Applies everywhere in the app.',
      );

  String? _tipFor(String category) {
    for (final t in KidActivityType.values) {
      final w = WorldInfo.of(t);
      final a = Activity(id: 'x_0', title: '', type: t, ageGroup: '', difficulty: KidDifficulty.easy, description: '', content: const {}, audioUrl: '', imageAssets: const [], expectedOutcome: const {});
      if (a.displayType == category) return w.parentTip;
    }
    return null;
  }

  Color _colorFor(String category) {
    for (final t in KidActivityType.values) {
      final a = Activity(id: 'x_0', title: '', type: t, ageGroup: '', difficulty: KidDifficulty.easy, description: '', content: const {}, audioUrl: '', imageAssets: const [], expectedOutcome: const {});
      if (a.displayType == category) return WorldInfo.of(t).color;
    }
    return Colors.grey;
  }
}
