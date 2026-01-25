import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SchedulesSite extends StatefulWidget {
  const SchedulesSite({super.key});

  @override
  State<SchedulesSite> createState() => _SchedulesSiteState();
}

class _SchedulesSiteState extends State<SchedulesSite> {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

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

  int daysInMonth(DateTime date) => DateTime(date.year, date.month + 1, 0).day;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final totalDays = daysInMonth(currentMonth);
    final firstWeekday = DateTime(
      currentMonth.year,
      currentMonth.month,
      1,
    ).weekday;

    final now = DateTime.now();
    final isTodayMonth =
        now.month == currentMonth.month && now.year == currentMonth.year;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Padding(
        padding: const EdgeInsets.all(16), // ✅ same as Graphic
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(8),
              height: 166,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text(
                    'Schedules',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Month badge (same style as Graphic date badge)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: cs.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_month, size: 18, color: cs.primary),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('MMM yyyy').format(currentMonth),
                          style: TextStyle(color: cs.primary),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  VerticalDivider(
                    thickness: 2,
                    width: 40, // ✅ same as Graphic
                    color: cs.outlineVariant,
                  ),

                  // Name block EXACT same structure as Graphic
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
                            final m = snap.data!.data() as Map<String, dynamic>;
                            return Text((m['name'] ?? '-').toString());
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ================= CALENDAR CARD (match Graphic card look) =================
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14), // ✅ same rounding
                ),
                child: Column(
                  children: [
                    // Month navigation row (more compact)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: _previousMonth,
                          icon: Icon(Icons.chevron_left, color: cs.onSurface),
                        ),
                        Text(
                          DateFormat('MMMM yyyy').format(currentMonth),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: cs.onSurface,
                          ),
                        ),
                        IconButton(
                          onPressed: _nextMonth,
                          icon: Icon(Icons.chevron_right, color: cs.onSurface),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Weekdays
                    Row(
                      children:
                          const [
                                'Mon',
                                'Tue',
                                'Wed',
                                'Thu',
                                'Fri',
                                'Sat',
                                'Sun',
                              ]
                              .map(
                                (d) => Expanded(
                                  child: Center(
                                    child: Text(
                                      d,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize:
                                            12, // ✅ smaller like Graphic UI
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                    ),

                    const SizedBox(height: 10),

                    // Days Grid (smaller + cleaner)
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
                          final isToday = isTodayMonth && day == now.day;

                          return Container(
                            decoration: BoxDecoration(
                              color: isToday ? cs.primaryContainer : cs.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: cs.outlineVariant),
                            ),
                            child: Center(
                              child: Text(
                                '$day',
                                style: TextStyle(
                                  fontSize: 13, // ✅ smaller day number
                                  fontWeight: FontWeight.w700,
                                  color: isToday
                                      ? cs.onPrimaryContainer
                                      : cs.onSurface,
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
