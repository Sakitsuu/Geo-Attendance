import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SchedulesSite extends StatefulWidget {
  const SchedulesSite({super.key});

  @override
  State<SchedulesSite> createState() => _SchedulesSiteState();
}

class _SchedulesSiteState extends State<SchedulesSite> {
  DateTime currentMonth = DateTime.now();

  void _previousMonth() {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
    });
  }

  int daysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final int totalDays = daysInMonth(currentMonth);
    final int firstWeekday = DateTime(
      currentMonth.year,
      currentMonth.month,
      1,
    ).weekday;

    final now = DateTime.now();

    return Scaffold(
      backgroundColor: cs.surface, // ✅ was const Color(0xFFF7F9FC)
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Schedule / Day Off',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.person, color: cs.onSurface),
                    const SizedBox(width: 8),
                    Text('Name', style: TextStyle(color: cs.onSurface)),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// Month Selector
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest, // ✅ was Colors.grey[200]
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.chevron_left, color: cs.onSurface),
                    onPressed: _previousMonth,
                  ),
                  Text(
                    DateFormat('MMMM yyyy').format(currentMonth),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.chevron_right, color: cs.onSurface),
                    onPressed: _nextMonth,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// Calendar Card
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest, // ✅ was Colors.grey[200]
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    /// Weekdays
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children:
                          const [
                            'Mon',
                            'Tue',
                            'Wed',
                            'Thu',
                            'Fri',
                            'Sat',
                            'Sun',
                          ].map((day) {
                            return Expanded(
                              child: Center(
                                child: Builder(
                                  builder: (context) {
                                    final cs = Theme.of(context).colorScheme;
                                    return Text(
                                      day,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: cs.onSurface,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          }).toList(),
                    ),

                    const SizedBox(height: 10),

                    /// Days Grid
                    Expanded(
                      child: GridView.builder(
                        itemCount: totalDays + firstWeekday - 1,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 7,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                            ),
                        itemBuilder: (context, index) {
                          if (index < firstWeekday - 1) {
                            return const SizedBox();
                          }

                          final day = index - firstWeekday + 2;

                          final isToday =
                              day == now.day &&
                              currentMonth.month == now.month &&
                              currentMonth.year == now.year;

                          return GestureDetector(
                            onTap: () {
                              // later: request day off
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isToday
                                    ? cs
                                          .primaryContainer // ✅ was Colors.blue[100]
                                    : cs.surface, // ✅ was Colors.white
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: cs.outlineVariant),
                              ),
                              child: Center(
                                child: Text(
                                  day.toString(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isToday
                                        ? cs
                                              .onPrimaryContainer // ✅ adapts
                                        : cs.onSurface, // ✅ adapts
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
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
