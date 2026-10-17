import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isapp/core/theme/scholar_theme.dart';
import 'package:isapp/features/study_guide/controllers/study_guide_controller.dart';

class WeeklyChart extends StatelessWidget {
  final StudyGuideController c;
  const WeeklyChart({super.key, required this.c});

  @override
  Widget build(BuildContext context) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Obx(() {
      final data = c.weeklyMinutes.toList();
      final goal = c.progress.value.dailyMinutes.toDouble();
      final maxY = [goal, ...data.map((e) => e.toDouble())].reduce((a, b) => a > b ? a : b) * 1.2;
      final todayIdx = DateTime.now().weekday - 1;
      return SizedBox(
        height: 170,
        child: BarChart(BarChartData(
          maxY: maxY < 30 ? 30 : maxY,
          alignment: BarChartAlignment.spaceAround,
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          extraLinesData: ExtraLinesData(horizontalLines: [HorizontalLine(y: goal, color: Scholar.sun.withOpacity(.6), strokeWidth: 1.5, dashArray: [6, 4])]),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, m) {
                  final dayIndex = (todayIdx - (6 - v.toInt())) % 7;
                  return Padding(padding: const EdgeInsets.only(top: 6), child: Text(names[dayIndex < 0 ? dayIndex + 7 : dayIndex], style: Scholar.body()));
                },
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < data.length; i++)
              BarChartGroupData(x: i, barRods: [
                BarChartRodData(
                  toY: data[i].toDouble(),
                  width: 20,
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(colors: i == 6 ? [Scholar.aurora, Scholar.sky] : [Scholar.violet, Scholar.lilac], begin: Alignment.bottomCenter, end: Alignment.topCenter),
                ),
              ]),
          ],
        )),
      );
    });
  }
}
