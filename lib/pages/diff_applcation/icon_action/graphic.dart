import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const GraphicSite());
}

class GraphicSite extends StatelessWidget {
  const GraphicSite({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Geo Attendant',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        fontFamily: 'MomoTrustDisplay',
      ),
      home: const MyHomePage(title: 'Geo Attendant'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.all(8),
                height: 166,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[300],
                ),
                child: Row(
                  children: <Widget>[
                    Text('Graphics', style: TextStyle(fontSize: 32)),
                    SizedBox(width: 10),
                    Spacer(),
                    VerticalDivider(thickness: 2, color: Colors.grey),
                    Icon(Icons.person, size: 50),
                    SizedBox(
                      height: 50,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[Text('Name'), Text('@name')],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: EdgeInsets.all(16),
                      margin: EdgeInsets.all(8),
                      height: 514,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SizedBox(child: LineChartGraphic()),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: EdgeInsets.all(16),
                      margin: EdgeInsets.all(8),
                      height: 514,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[300],
                      ),
                      child: SizedBox(child: BarChartGraphic()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LineChartGraphic extends StatelessWidget {
  const LineChartGraphic({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Attendance Comparison Chart",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            SizedBox(
              height: 240,
              child: LineChart(
                LineChartData(
                  minX: 1,
                  maxX: 16,
                  minY: 0,
                  maxY: 100,

                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: false),

                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 20,
                        getTitlesWidget: (value, meta) =>
                            Text('${value.toInt()}%'),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, meta) =>
                            Text('${value.toInt()} Aug'),
                      ),
                    ),
                  ),

                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(show: true),
                      spots: const [
                        FlSpot(1, 58),
                        FlSpot(2, 72),
                        FlSpot(3, 58),
                        FlSpot(4, 75),
                        FlSpot(7, 91),
                        FlSpot(8, 54),
                        FlSpot(9, 72),
                        FlSpot(10, 38),
                        FlSpot(11, 60),
                        FlSpot(14, 72),
                        FlSpot(15, 58),
                        FlSpot(16, 38),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BarChartGraphic extends StatelessWidget {
  const BarChartGraphic({super.key});

  BarChartGroupData _bar(int x, double y, {bool highlight = false}) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          width: 22,
          borderRadius: BorderRadius.circular(6),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Weekly Attendance",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            SizedBox(
              height: 240,
              child: BarChart(
                BarChartData(
                  maxY: 100,
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: false),

                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 20,
                        getTitlesWidget: (value, meta) =>
                            Text('${value.toInt()}%'),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const labels = [
                            'Sale',
                            'Finance',
                            'IT',
                            'Legal',
                            'API',
                          ];
                          return Text(labels[value.toInt()]);
                        },
                      ),
                    ),
                  ),

                  barGroups: [
                    _bar(0, 40),
                    _bar(1, 60),
                    _bar(2, 86, highlight: true),
                    _bar(3, 60),
                    _bar(4, 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
