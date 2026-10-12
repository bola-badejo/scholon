import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StudentResultsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Student Performance Analytics")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bar Chart - Subject Scores
            Text("📊 Bar Chart: Subject Scores", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Container(height: 250, child: _buildBarChart()),

            SizedBox(height: 20),

            // Pie Chart - Subject Score Distribution
            Text("📊 Pie Chart: Subject Score Distribution", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Container(height: 250, child: _buildPieChart()),

            SizedBox(height: 20),

            // Scatter Plot - Student Performance Trends
            Text("📊 Scatter Plot: Student Performance Trends", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Container(height: 250, child: _buildScatterPlot()),
          ],
        ),
      ),
    );
  }

  // 📌 Bar Chart (Subject Scores)
  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barGroups: [
          _barData(0, 80), // Math
          _barData(1, 95), // English
          _barData(2, 60), // Science
          _barData(3, 75), // History
          _barData(4, 85), // Physics
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, getTitlesWidget: (double value, TitleMeta meta) {
              List<String> subjects = ["Math", "Eng", "Sci", "Hist", "Phys"];
              return Text(subjects[value.toInt()], style: TextStyle(fontSize: 12));
            }),
          ),
        ),
      ),
    );
  }

  // 📌 Bar Data Helper
  BarChartGroupData _barData(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [BarChartRodData(toY: y, color: Colors.blue, width: 16)],
    );
  }

  // 📌 Pie Chart (Score Distribution)
  Widget _buildPieChart() {
    return PieChart(
      PieChartData(
        sections: [
          _pieSection(30, Colors.blue, "Math"),
          _pieSection(25, Colors.red, "Eng"),
          _pieSection(20, Colors.green, "Sci"),
          _pieSection(15, Colors.orange, "Hist"),
          _pieSection(10, Colors.purple, "Phys"),
        ],
      ),
    );
  }

  // 📌 Pie Section Helper
  PieChartSectionData _pieSection(double value, Color color, String title) {
    return PieChartSectionData(
      value: value,
      color: color,
      title: title,
      radius: 50,
    );
  }

  // 📌 Scatter Plot (Performance Trends)
  Widget _buildScatterPlot() {
    return ScatterChart(
      ScatterChartData(
        scatterSpots: [
          ScatterSpot(1, 80, show: true),
          ScatterSpot(2, 95, show: true),
          ScatterSpot(3, 60, show: true),
          ScatterSpot(4, 75, show: true),
          ScatterSpot(5, 85, show: true),
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
        ),
      ),
    );
  }
}
