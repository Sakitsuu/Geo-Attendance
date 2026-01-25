import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileSite extends StatelessWidget {
  const ProfileSite({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfilePage();
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser!.uid;

  String _dateKey(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return "$y-$m-$day";
  }

  String _monthStartKey(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    return "$y-$m-01";
  }

  String _nextMonthKey(DateTime d) {
    final next = DateTime(d.year, d.month + 1, 1);
    final y = next.year.toString().padLeft(4, '0');
    final m = next.month.toString().padLeft(2, '0');
    return "$y-$m-01";
  }

  Future<Map<String, dynamic>?> _loadProfile() async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data();
  }

  // ✅ pending requests stream (live)
  Stream<QuerySnapshot> _pendingRequestsStream() {
    return _db
        .collection('requests')
        .where('uid', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .limit(10)
        .snapshots();
  }

  // ✅ Request dialog (Time-off / Leave) + dates + reason
  Future<void> _openRequestDialog(String type) async {
    DateTime? fromDate;
    DateTime? toDate;
    final reasonCtrl = TextEditingController();
    bool submitting = false;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            String fmt(DateTime? d) => d == null
                ? 'Select'
                : '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

            Future<void> pickFrom() async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: ctx,
                firstDate: DateTime(now.year - 1),
                lastDate: DateTime(now.year + 2),
                initialDate: now,
              );
              if (picked != null) setLocal(() => fromDate = picked);
            }

            Future<void> pickTo() async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: ctx,
                firstDate: DateTime(now.year - 1),
                lastDate: DateTime(now.year + 2),
                initialDate: fromDate ?? now,
              );
              if (picked != null) setLocal(() => toDate = picked);
            }

            Future<void> submit() async {
              final reason = reasonCtrl.text.trim();

              if (reason.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a reason.')),
                );
                return;
              }
              if (fromDate == null || toDate == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please select From/To dates.')),
                );
                return;
              }
              if (toDate!.isBefore(fromDate!)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('To date cannot be before From date.'),
                  ),
                );
                return;
              }

              setLocal(() => submitting = true);

              try {
                await _db.collection('requests').add({
                  'uid': uid,
                  'type': type, // 'time_off' or 'leave'
                  'reason': reason,
                  'fromDate': Timestamp.fromDate(fromDate!),
                  'toDate': Timestamp.fromDate(toDate!),
                  'status': 'pending',
                  'createdAt': FieldValue.serverTimestamp(),
                  'reviewedBy': null,
                  'reviewedAt': null,
                });

                if (!mounted) return;
                Navigator.pop(ctx);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Request submitted!')),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Submit failed: $e')));
              } finally {
                setLocal(() => submitting = false);
              }
            }

            final titleText = type == 'leave'
                ? 'Leave Request'
                : 'Time-off Request';

            return AlertDialog(
              title: Text(titleText),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: submitting ? null : pickFrom,
                          child: Text('From: ${fmt(fromDate)}'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: submitting ? null : pickTo,
                          child: Text('To: ${fmt(toDate)}'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: reasonCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Enter reason',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: submitting ? null : () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: submitting ? null : submit,
                  child: submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _typeLabel(String type) {
    if (type == 'leave') return 'Leave';
    return 'Time-off';
  }

  String _fmtDate(DateTime? d) {
    if (d == null) return '-';
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  Widget _monthlyRateWidget() {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 1);

    // Your attendance "date" is String yyyy-MM-dd
    final startKey = _monthStartKey(now);
    final endKey = _nextMonthKey(now);

    return StreamBuilder<QuerySnapshot>(
      // attendance for this worker for current month
      stream: _db
          .collection('attendance')
          .where('workerId', isEqualTo: uid)
          .where('date', isGreaterThanOrEqualTo: startKey)
          .where('date', isLessThan: endKey)
          .snapshots(),
      builder: (context, attSnap) {
        if (attSnap.hasError) {
          return Text(
            'Err',
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          );
        }
        if (attSnap.connectionState == ConnectionState.waiting) {
          return const Text(
            '…',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          );
        }
        if (!attSnap.hasData) {
          return const Text(
            '—',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          );
        }

        // Build a map: dateKey -> status
        // If there are multiple docs for same day, keep the "worst" status
        // worst order: ABSENT (no doc) > LATE > PRESENT
        final Map<String, String> statusByDate = {};

        for (final doc in attSnap.data!.docs) {
          final m = doc.data() as Map<String, dynamic>;
          final date = (m['date'] ?? '').toString(); // yyyy-MM-dd
          final status = (m['status'] ?? '').toString(); // PRESENT / LATE
          if (date.isEmpty) continue;

          final existing = statusByDate[date];
          if (existing == null) {
            statusByDate[date] = status;
          } else {
            // If any is LATE, keep LATE
            if (existing != 'LATE' && status == 'LATE') {
              statusByDate[date] = 'LATE';
            }
          }
        }

        // Now also load accepted requests for this user
        return StreamBuilder<QuerySnapshot>(
          stream: _db
              .collection('requests')
              .where('uid', isEqualTo: uid)
              .where('status', isEqualTo: 'accepted')
              .snapshots(),
          builder: (context, reqSnap) {
            if (reqSnap.hasError) {
              return const Text(
                'Err',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              );
            }
            if (reqSnap.connectionState == ConnectionState.waiting) {
              return const Text(
                '…',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              );
            }
            if (!reqSnap.hasData) {
              return const Text(
                '—',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              );
            }

            // Build set of dates covered by accepted leave/time_off in this month
            final Set<String> offDays = {};

            for (final doc in reqSnap.data!.docs) {
              final m = doc.data() as Map<String, dynamic>;
              final fromTs = m['fromDate'];
              final toTs = m['toDate'];
              if (fromTs is! Timestamp || toTs is! Timestamp) continue;

              DateTime from = fromTs.toDate();
              DateTime to = toTs.toDate();

              // normalize to date-only
              from = DateTime(from.year, from.month, from.day);
              to = DateTime(to.year, to.month, to.day);

              // clamp to this month
              if (to.isBefore(monthStart) || from.isAfter(monthEnd)) continue;

              DateTime start = from.isBefore(monthStart) ? monthStart : from;
              DateTime end = to.isAfter(monthEnd)
                  ? monthEnd.subtract(const Duration(days: 1))
                  : to;

              for (
                DateTime d = start;
                !d.isAfter(end);
                d = d.add(const Duration(days: 1))
              ) {
                offDays.add(_dateKey(d));
              }
            }

            // Score calculation
            int score = 100;

            int lateDays = 0;
            int absentDays = 0;
            int offCount = 0;

            final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

            for (int day = 1; day <= daysInMonth; day++) {
              final d = DateTime(now.year, now.month, day);
              final key = _dateKey(d);

              final st = statusByDate[key]; // PRESENT / LATE / null
              final isOff = offDays.contains(key);

              if (st == 'LATE') {
                lateDays++;
                score -= 2;
              }

              if (isOff) {
                offCount++;
                score -= 1; // time off reduces score a little
              }

              // Absent only if no attendance and not off
              if (st == null && !isOff) {
                absentDays++;
                score -= 5;
              }
            }

            // clamp
            if (score < 0) score = 0;
            if (score > 100) score = 100;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$score%',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Late: $lateDays • Absent: $absentDays • Off: $offCount',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _loadProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Profile not found'));
          }

          final data = snapshot.data!;
          final name = (data['name'] ?? '').toString();
          final department = (data['department'] ?? '').toString();
          final role = (data['role'] ?? '').toString();
          final id = (data['id'] ?? '').toString();

          return SingleChildScrollView(
            child: Column(
              children: [
                // HEADER
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(8),
                  height: 166,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[300],
                  ),
                  child: Row(
                    children: [
                      const Text('Profile', style: TextStyle(fontSize: 28)),
                      const VerticalDivider(thickness: 2),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Good morning, $name!',
                            style: const TextStyle(fontSize: 20),
                          ),
                          Text(
                            'ID: $id',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          Text(
                            'Department: $department',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          Text(
                            'Role: $role',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Icon(Icons.person, size: 48),
                    ],
                  ),
                ),

                // STATS (still dummy for now)
                Row(
                  children: [
                    _statCard(
                      title: 'Monthly Rate',
                      icon: Icons.alarm,
                      value: _monthlyRateWidget(),
                    ),

                    _statCard(
                      title: 'Engagement Rate',
                      icon: Icons.arrow_outward,
                      value: StreamBuilder<QuerySnapshot>(
                        stream: _db
                            .collection('requests')
                            .where('uid', isEqualTo: uid)
                            .where(
                              'createdAt',
                              isGreaterThanOrEqualTo: Timestamp.fromDate(
                                DateTime(
                                  DateTime.now().year,
                                  DateTime.now().month,
                                  1,
                                ),
                              ),
                            )
                            .snapshots(),
                        builder: (context, snap) {
                          if (!snap.hasData) {
                            return const Text(
                              '—',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }

                          final requestCount = snap.data!.docs.length;

                          final now = DateTime.now();
                          final daysInMonth = DateTime(
                            now.year,
                            now.month + 1,
                            0,
                          ).day;

                          final rate = daysInMonth == 0
                              ? 0
                              : ((requestCount / daysInMonth) * 100).round();

                          return Text(
                            '$rate%',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                // REQUESTS (REAL)
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[300],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.error_outline),
                          const SizedBox(width: 10),
                          const Text(
                            'Pending Approvals',
                            style: TextStyle(fontSize: 20),
                          ),
                          const Spacer(),

                          // ✅ two buttons like your old UI
                          ElevatedButton(
                            onPressed: () => _openRequestDialog('time_off'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                            ),
                            child: const Text('Time-off'),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () => _openRequestDialog('leave'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                            ),
                            child: const Text('Leave'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // ✅ real pending list from Firestore
                      StreamBuilder<QuerySnapshot>(
                        stream: _pendingRequestsStream(),
                        builder: (context, snap) {
                          if (snap.hasError) {
                            return Text('Error: ${snap.error}');
                          }
                          if (!snap.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final docs = snap.data!.docs;
                          if (docs.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(12),
                              child: Text('No pending requests.'),
                            );
                          }

                          return Column(
                            children: docs.map((doc) {
                              final d = doc.data() as Map<String, dynamic>;
                              final type = (d['type'] ?? '').toString();
                              final reason = (d['reason'] ?? '').toString();
                              final from = (d['fromDate'] as Timestamp?)
                                  ?.toDate();
                              final to = (d['toDate'] as Timestamp?)?.toDate();

                              return Container(
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.grey[200],
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${_typeLabel(type)} • ${_fmtDate(from)} → ${_fmtDate(to)}\n$reason',
                                      ),
                                    ),
                                    const Chip(label: Text('pending')),
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _statCard({
    required String title,
    required IconData icon,
    required Widget value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.all(8),
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[300],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(title, style: const TextStyle(fontSize: 18)),
                const Spacer(),
                Icon(icon),
              ],
            ),
            const Spacer(),
            value,
          ],
        ),
      ),
    );
  }
}
