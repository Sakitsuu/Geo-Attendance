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
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser!.uid;

  // ✅ Choose the correct type for attendance.date
  // If your attendance.date is stored as String "yyyy-MM-dd" keep this false.
  // If your attendance.date is stored as Timestamp, set this true.
  static const bool attendanceDateIsTimestamp = false;

  // ---------- helpers ----------
  String _dateKey(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return "$y-$m-$day"; // yyyy-MM-dd
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

  String _fmtDate(DateTime? d) {
    if (d == null) return '-';
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  Future<Map<String, dynamic>?> _loadProfile() async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data();
  }

  Stream<QuerySnapshot> _pendingRequestsStream() {
    return _db
        .collection('requests')
        .where('uid', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .limit(10)
        .snapshots();
  }

  String _typeLabel(String type) {
    if (type == 'leave') return 'Leave';
    return 'Time-off';
  }

  // ---------- request dialog ----------
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

  // ✅ Attendance Rate (fixed)
  // - shows real errors instead of just "Err"
  // - adds orderBy('date') to satisfy query requirements
  // - supports String or Timestamp attendance.date (toggle at top)
  Widget _monthlyRateWidget() {
    final now = DateTime.now();
    final monthStartDate = DateTime(now.year, now.month, 1);
    final monthNextDate = DateTime(now.year, now.month + 1, 1);

    // used for clamping accepted off days
    final monthStart = monthStartDate;
    final monthNext = monthNextDate;

    Stream<QuerySnapshot> attendanceStream;

    if (attendanceDateIsTimestamp) {
      final startTs = Timestamp.fromDate(monthStartDate);
      final endTs = Timestamp.fromDate(monthNextDate);

      attendanceStream = _db
          .collection('attendance')
          .where('workerId', isEqualTo: uid)
          .where('date', isGreaterThanOrEqualTo: startTs)
          .where('date', isLessThan: endTs)
          .orderBy('date')
          .snapshots();
    } else {
      final startKey = _monthStartKey(now); // yyyy-MM-01
      final endKey = _nextMonthKey(now); // next yyyy-MM-01

      attendanceStream = _db
          .collection('attendance')
          .where('workerId', isEqualTo: uid)
          .where('date', isGreaterThanOrEqualTo: startKey)
          .where('date', isLessThan: endKey)
          .orderBy('date')
          .snapshots();
    }

    return StreamBuilder<QuerySnapshot>(
      stream: attendanceStream,
      builder: (context, attSnap) {
        if (attSnap.hasError) {
          return Text(
            'Error: ${attSnap.error}',
            style: const TextStyle(fontSize: 12),
          );
        }
        if (attSnap.connectionState == ConnectionState.waiting) {
          return const Text(
            '…',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          );
        }

        final Map<String, String> statusByDate = {};

        for (final doc in attSnap.data?.docs ?? []) {
          final m = doc.data() as Map<String, dynamic>;

          String dateKey = '';

          if (attendanceDateIsTimestamp) {
            final ts = m['date'];
            if (ts is Timestamp) {
              final d = ts.toDate();
              dateKey = _dateKey(DateTime(d.year, d.month, d.day));
            }
          } else {
            dateKey = (m['date'] ?? '').toString(); // yyyy-MM-dd
          }

          final status = (m['status'] ?? '').toString(); // PRESENT / LATE
          if (dateKey.isEmpty) continue;

          // keep worst (LATE worse than PRESENT)
          final existing = statusByDate[dateKey];
          if (existing == null) {
            statusByDate[dateKey] = status;
          } else {
            if (existing != 'LATE' && status == 'LATE') {
              statusByDate[dateKey] = 'LATE';
            }
          }
        }

        return StreamBuilder<QuerySnapshot>(
          stream: _db
              .collection('requests')
              .where('uid', isEqualTo: uid)
              .where('status', isEqualTo: 'accepted')
              .snapshots(),
          builder: (context, reqSnap) {
            if (reqSnap.hasError) {
              return Text(
                'Error: ${reqSnap.error}',
                style: const TextStyle(fontSize: 12),
              );
            }
            if (reqSnap.connectionState == ConnectionState.waiting) {
              return const Text(
                '…',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              );
            }

            final Set<String> offDays = {};

            for (final doc in reqSnap.data?.docs ?? []) {
              final m = doc.data() as Map<String, dynamic>;
              final fromTs = m['fromDate'];
              final toTs = m['toDate'];
              if (fromTs is! Timestamp || toTs is! Timestamp) continue;

              DateTime from = fromTs.toDate();
              DateTime to = toTs.toDate();
              from = DateTime(from.year, from.month, from.day);
              to = DateTime(to.year, to.month, to.day);

              // clamp to this month
              if (to.isBefore(monthStart) || from.isAfter(monthNext)) continue;

              final start = from.isBefore(monthStart) ? monthStart : from;
              final end = to.isAfter(monthNext)
                  ? monthNext.subtract(const Duration(days: 1))
                  : to;

              for (
                DateTime d = start;
                !d.isAfter(end);
                d = d.add(const Duration(days: 1))
              ) {
                offDays.add(_dateKey(d));
              }
            }

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
                score -= 1;
              }

              // absent: no attendance doc and not off
              if (st == null && !isOff) {
                absentDays++;
                score -= 5;
              }
            }

            score = score.clamp(0, 100);

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

  // ✅ Engagement Rate (fixed)
  // - adds orderBy('createdAt') for range filter
  // - shows real errors
  Widget _engagementRateWidget() {
    final now = DateTime.now();
    final monthStart = Timestamp.fromDate(DateTime(now.year, now.month, 1));
    final monthNext = Timestamp.fromDate(DateTime(now.year, now.month + 1, 1));

    return StreamBuilder<QuerySnapshot>(
      stream: _db
          .collection('requests')
          .where('uid', isEqualTo: uid)
          .where('createdAt', isGreaterThanOrEqualTo: monthStart)
          .where('createdAt', isLessThan: monthNext)
          .orderBy('createdAt')
          .snapshots(),
      builder: (context, snap) {
        if (snap.hasError) {
          return Text(
            'Error: ${snap.error}',
            style: const TextStyle(fontSize: 12),
          );
        }
        if (snap.connectionState == ConnectionState.waiting) {
          return const Text(
            '…',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          );
        }

        final count = snap.data?.docs.length ?? 0;
        int score = 100 - (count * 5);
        score = score.clamp(0, 100);

        return Text(
          '$score%',
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (_auth.currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'You must be logged in.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: cs.surface,
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _loadProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Text(
                'Profile not found',
                style: TextStyle(color: cs.onSurface),
              ),
            );
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
                    color: cs.surfaceContainerHighest,
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Profile',
                        style: TextStyle(fontSize: 28, color: cs.onSurface),
                      ),
                      VerticalDivider(thickness: 2, color: cs.outline),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Good morning, $name!',
                            style: TextStyle(fontSize: 20, color: cs.onSurface),
                          ),
                          Text(
                            'ID: $id',
                            style: TextStyle(color: cs.onSurfaceVariant),
                          ),
                          Text(
                            'Department: $department',
                            style: TextStyle(color: cs.onSurfaceVariant),
                          ),
                          Text(
                            'Role: $role',
                            style: TextStyle(color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Icon(Icons.person, size: 48, color: cs.onSurface),
                    ],
                  ),
                ),

                // STATS
                Row(
                  children: [
                    _statCard(
                      cs: cs,
                      title: 'Attendance Rate',
                      icon: Icons.alarm,
                      value: _monthlyRateWidget(),
                    ),
                    _statCard(
                      cs: cs,
                      title: 'Engagement Rate',
                      icon: Icons.arrow_outward,
                      value: _engagementRateWidget(),
                    ),
                  ],
                ),

                // REQUESTS
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: cs.surfaceContainerHighest,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.error_outline, color: cs.onSurface),
                          const SizedBox(width: 10),
                          Text(
                            'Pending Approvals',
                            style: TextStyle(fontSize: 20, color: cs.onSurface),
                          ),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: () => _openRequestDialog('time_off'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: cs.primary,
                              foregroundColor: cs.onPrimary,
                            ),
                            child: const Text('Time-off'),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () => _openRequestDialog('leave'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: cs.primary,
                              foregroundColor: cs.onPrimary,
                            ),
                            child: const Text('Leave'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      StreamBuilder<QuerySnapshot>(
                        stream: _pendingRequestsStream(),
                        builder: (context, snap) {
                          if (snap.hasError) {
                            return Text(
                              'Error: ${snap.error}',
                              style: TextStyle(color: cs.onSurface),
                            );
                          }
                          if (snap.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final docs = snap.data?.docs ?? [];
                          if (docs.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                'No pending requests.',
                                style: TextStyle(color: cs.onSurfaceVariant),
                              ),
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
                                  color: cs.surfaceContainer,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${_typeLabel(type)} • ${_fmtDate(from)} → ${_fmtDate(to)}\n$reason',
                                        style: TextStyle(color: cs.onSurface),
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
    required ColorScheme cs,
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
          color: cs.surfaceContainerHighest,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 18, color: cs.onSurface),
                ),
                const Spacer(),
                Icon(icon, color: cs.onSurface),
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
