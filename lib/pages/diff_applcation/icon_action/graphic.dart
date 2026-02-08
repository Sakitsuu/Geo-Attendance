import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GraphicSite extends StatelessWidget {
  const GraphicSite({super.key});
  @override
  Widget build(BuildContext context) {
    return const GraphicHomePage(title: 'Geo Attendant');
  }
}

class GraphicHomePage extends StatefulWidget {
  const GraphicHomePage({super.key, required this.title});
  final String title;

  @override
  State<GraphicHomePage> createState() => _GraphicHomePageState();
}

class _GraphicHomePageState extends State<GraphicHomePage> {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  DateTime _selectedMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  );

  String _dateKey(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return "$y-$m-$day";
  }

  DateTime _nextMonth(DateTime d) => DateTime(d.year, d.month + 1, 1);

  int _daysInMonth(DateTime d) => DateTime(d.year, d.month + 1, 0).day;

  String _monthLabel(DateTime d) {
    const names = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return "${names[d.month - 1]} ${d.year}";
  }

  Future<void> _pickMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020, 1, 1),
      lastDate: DateTime(2100, 12, 31),
    );

    if (picked != null) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month, 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final startKey = _dateKey(_selectedMonth);
    final endKey = _dateKey(
      _nextMonth(_selectedMonth),
    ); // next month yyyy-MM-01
    final days = _daysInMonth(_selectedMonth);

    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(8),
                height: 166,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: cs.surfaceContainerHighest,
                ),
                child: Row(
                  children: <Widget>[
                    const Text('Graphics', style: TextStyle(fontSize: 32)),
                    const SizedBox(width: 16),

                    OutlinedButton.icon(
                      onPressed: _pickMonth,
                      icon: const Icon(Icons.calendar_month),
                      label: Text(_monthLabel(_selectedMonth)),
                    ),

                    const Spacer(),
                    VerticalDivider(thickness: 2, color: cs.outlineVariant),
                    const Icon(Icons.person, size: 50),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 50,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text('Name'),
                          StreamBuilder<DocumentSnapshot>(
                            stream: _db
                                .collection('users')
                                .doc(_auth.currentUser?.uid)
                                .snapshots(),
                            builder: (context, snap) {
                              if (!snap.hasData || !snap.data!.exists) {
                                return const Text('-');
                              }
                              final m =
                                  snap.data!.data() as Map<String, dynamic>;
                              return Text((m['name'] ?? '-').toString());
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              Row(
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.all(8),
                      height: 514,
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: LineChartMonthly(
                        db: _db,
                        startKey: startKey,
                        endKey: endKey,
                        daysInMonth: days,
                        selectedMonth: _selectedMonth,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.all(8),
                      height: 514,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: cs.surfaceContainerHighest,
                      ),
                      child: BarChartMonthlyByDept(
                        db: _db,
                        startKey: startKey,
                        endKey: endKey,
                        daysInMonth: days,
                      ),
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

class LineChartMonthly extends StatelessWidget {
  const LineChartMonthly({
    super.key,
    required this.db,
    required this.startKey,
    required this.endKey,
    required this.daysInMonth,
    required this.selectedMonth,
  });

  final FirebaseFirestore db;
  final String startKey;
  final String endKey;
  final int daysInMonth;
  final DateTime selectedMonth;

  String _dayKey(int day) {
    final y = selectedMonth.year.toString().padLeft(4, '0');
    final m = selectedMonth.month.toString().padLeft(2, '0');
    final d = day.toString().padLeft(2, '0');
    return "$y-$m-$d";
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<QuerySnapshot>(
          stream: db.collection('users').snapshots(),
          builder: (context, userSnap) {
            final totalUsers = userSnap.data?.docs.length ?? 0;
            if (totalUsers == 0) {
              return const Center(child: Text("No users found"));
            }

            return StreamBuilder<QuerySnapshot>(
              stream: db
                  .collection('attendance')
                  .where('date', isGreaterThanOrEqualTo: startKey)
                  .where('date', isLessThan: endKey)
                  .snapshots(),
              builder: (context, attSnap) {
                if (!attSnap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final Map<int, int> countByDay = {
                  for (int i = 1; i <= daysInMonth; i++) i: 0,
                };

                for (final doc in attSnap.data!.docs) {
                  final m = doc.data() as Map<String, dynamic>? ?? {};
                  final status = (m['status'] ?? '').toString();
                  if (status != 'PRESENT' && status != 'LATE') continue;

                  final date = (m['date'] ?? '').toString();
                  if (date.length >= 10) {
                    final dayStr = date.substring(8, 10);
                    final day = int.tryParse(dayStr);
                    if (day != null && day >= 1 && day <= daysInMonth) {
                      countByDay[day] = (countByDay[day] ?? 0) + 1;
                    }
                  }
                }

                final spots = <FlSpot>[];
                for (int day = 1; day <= daysInMonth; day++) {
                  final attended = countByDay[day] ?? 0;
                  final percent = (attended / totalUsers) * 100.0;
                  spots.add(FlSpot(day.toDouble(), percent));
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Monthly Attendance (Daily %)",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text("Total employees: $totalUsers"),
                    const SizedBox(height: 20),

                    SizedBox(
                      height: 260,
                      child: LineChart(
                        LineChartData(
                          minX: 1,
                          maxX: daysInMonth.toDouble(),
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
                                interval: 5, // show every 5 days
                                getTitlesWidget: (value, meta) {
                                  final d = value.toInt();
                                  if (d < 1 || d > daysInMonth) {
                                    return const SizedBox.shrink();
                                  }
                                  return Text('$d');
                                },
                              ),
                            ),
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              isCurved: true,
                              barWidth: 3,
                              dotData: FlDotData(show: false),
                              belowBarData: BarAreaData(show: true),
                              spots: spots,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class BarChartMonthlyByDept extends StatelessWidget {
  const BarChartMonthlyByDept({
    super.key,
    required this.db,
    required this.startKey,
    required this.endKey,
    required this.daysInMonth,
  });

  final FirebaseFirestore db;
  final String startKey;
  final String endKey;
  final int daysInMonth;

  BarChartGroupData _bar(int x, double y) {
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
        child: StreamBuilder<QuerySnapshot>(
          stream: db.collection('users').snapshots(),
          builder: (context, userSnap) {
            if (!userSnap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final Map<String, int> totalByDept = {};
            for (final doc in userSnap.data!.docs) {
              final m = doc.data() as Map<String, dynamic>? ?? {};
              final dept = (m['department'] ?? 'Unknown').toString();
              totalByDept[dept] = (totalByDept[dept] ?? 0) + 1;
            }

            final depts = totalByDept.keys.toList()..sort();
            final shownDepts = depts.take(5).toList();

            return StreamBuilder<QuerySnapshot>(
              stream: db
                  .collection('attendance')
                  .where('date', isGreaterThanOrEqualTo: startKey)
                  .where('date', isLessThan: endKey)
                  .snapshots(),
              builder: (context, attSnap) {
                if (!attSnap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final Map<String, int> attByDept = {
                  for (final d in shownDepts) d: 0,
                };

                for (final doc in attSnap.data!.docs) {
                  final m = doc.data() as Map<String, dynamic>? ?? {};
                  final status = (m['status'] ?? '').toString();
                  if (status != 'PRESENT' && status != 'LATE') continue;

                  final dept = (m['department'] ?? '').toString();
                  if (attByDept.containsKey(dept)) {
                    attByDept[dept] = (attByDept[dept] ?? 0) + 1;
                  }
                }

                final groups = <BarChartGroupData>[];
                for (int i = 0; i < shownDepts.length; i++) {
                  final dept = shownDepts[i];
                  final usersInDept = totalByDept[dept] ?? 0;
                  final denom = usersInDept * daysInMonth;
                  final attended = attByDept[dept] ?? 0;
                  final percent = denom == 0 ? 0.0 : (attended / denom) * 100.0;
                  groups.add(_bar(i, percent));
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Monthly Attendance by Dept",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 260,
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
                                  final i = value.toInt();
                                  if (i < 0 || i >= shownDepts.length) {
                                    return const SizedBox.shrink();
                                  }
                                  final label = shownDepts[i];
                                  return Text(
                                    label.length > 8
                                        ? '${label.substring(0, 8)}…'
                                        : label,
                                  );
                                },
                              ),
                            ),
                          ),
                          barGroups: groups,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Range: $startKey  →  (before) $endKey",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
