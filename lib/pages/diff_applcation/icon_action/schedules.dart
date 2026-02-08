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
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  DateTime currentMonth = DateTime.now();

  void _prevMonth() {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
    });
  }

  int daysInMonth(DateTime d) => DateTime(d.year, d.month + 1, 0).day;
  String dateKey(DateTime d) => DateFormat('yyyy-MM-dd').format(d);
  String monthKey(DateTime d) => DateFormat('yyyy-MM').format(d);

  Future<void> _addEvent(DateTime date) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final titleCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text("Add Event (${DateFormat('dd MMM yyyy').format(date)})"),
        content: TextField(
          controller: titleCtrl,
          decoration: const InputDecoration(hintText: "Event title"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = titleCtrl.text.trim();
              if (title.isEmpty) return;

              final userDoc = await _db.collection('users').doc(user.uid).get();
              final name = (userDoc.data()?['name'] ?? 'Unknown').toString();

              await _db.collection('events').add({
                "title": title,
                "date": dateKey(date),
                "createdBy": user.uid,
                "createdByName": name,
                "createdAt": FieldValue.serverTimestamp(),
              });

              if (dialogContext.mounted) Navigator.of(dialogContext).pop();
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );

    titleCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mk = monthKey(currentMonth);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text("Schedules"),
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _prevMonth,
                  icon: Icon(Icons.chevron_left, color: cs.onSurface),
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
                  onPressed: _nextMonth,
                  icon: Icon(Icons.chevron_right, color: cs.onSurface),
                ),
              ],
            ),
          ),
          Row(
            children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                .map(
                  (d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _db.collection('events').snapshots(),
              builder: (context, snap) {
                if (snap.hasError) {
                  return Center(child: Text("Error: ${snap.error}"));
                }
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final events = <String, String>{};

                for (final doc in snap.data!.docs) {
                  final data = doc.data();
                  final date = (data['date'] ?? '').toString();
                  if (date.startsWith('$mk-')) {
                    events[date] = (data['title'] ?? '').toString();
                  }
                }

                final totalDays = daysInMonth(currentMonth);
                final firstWeekday = DateTime(
                  currentMonth.year,
                  currentMonth.month,
                  1,
                ).weekday;

                final now = DateTime.now();

                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: totalDays + firstWeekday - 1,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                  ),
                  itemBuilder: (context, index) {
                    if (index < firstWeekday - 1) return const SizedBox();

                    final day = index - firstWeekday + 2;
                    final date = DateTime(
                      currentMonth.year,
                      currentMonth.month,
                      day,
                    );
                    final key = dateKey(date);

                    final hasEvent = events.containsKey(key);
                    final isToday =
                        now.year == date.year &&
                        now.month == date.month &&
                        now.day == date.day;

                    final bg = isToday ? cs.primary : cs.surface;
                    final border = isToday ? cs.primary : cs.outlineVariant;
                    final textColor = isToday ? cs.onPrimary : cs.onSurface;

                    return InkWell(
                      onTap: () => _addEvent(date),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: border,
                            width: isToday ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "$day",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const Spacer(),
                            if (hasEvent)
                              Text(
                                events[key]!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: textColor,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
