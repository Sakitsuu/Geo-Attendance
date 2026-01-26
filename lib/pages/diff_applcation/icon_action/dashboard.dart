import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardSite extends StatelessWidget {
  const DashboardSite({super.key});

  @override
  Widget build(BuildContext context) {
    return const MyHomePage(title: 'Geo Attendant');
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class AppText {
  static double title(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return (w * 0.03).clamp(18.0, 32.0);
  }

  static double subtitle(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return (w * 0.022).clamp(16.0, 26.0);
  }

  static double body(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return (w * 0.015).clamp(13.0, 18.0);
  }
}

class AppIcon {
  static double medium(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return (w * 0.045).clamp(28.0, 60.0);
  }

  static double huge(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return (w * 0.11).clamp(120.0, 180.0);
  }
}

class _MyHomePageState extends State<MyHomePage> {
  late String today;
  late String currentTime;

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    today = _dateKey(now);
    currentTime = _formatTime(now);
  }

  String _formatTime(DateTime now) {
    return "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
  }

  String _dateKey(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return "$y-$m-$day";
  }

  Text _numText(BuildContext context, String value, ColorScheme cs) {
    return Text(
      value,
      style: TextStyle(fontSize: AppText.title(context), color: cs.onSurface),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              // ================= HEADER =================
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(8),
                height: 166,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: cs.surfaceContainerHighest, // ✅ was grey[300]
                ),
                child: Row(
                  children: <Widget>[
                    Text(
                      'Dashboard',
                      style: TextStyle(
                        fontSize: AppText.title(context),
                        color: cs.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),

                    VerticalDivider(thickness: 2, color: cs.outlineVariant),

                    Icon(Icons.person, size: 50, color: cs.onSurface),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 50,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Name', style: TextStyle(color: cs.onSurface)),
                          StreamBuilder<DocumentSnapshot>(
                            stream: _db
                                .collection('users')
                                .doc(_auth.currentUser?.uid)
                                .snapshots(),
                            builder: (context, snap) {
                              if (!snap.hasData || !snap.data!.exists) {
                                return Text(
                                  '-',
                                  style: TextStyle(color: cs.onSurfaceVariant),
                                );
                              }
                              final m =
                                  snap.data!.data() as Map<String, dynamic>;
                              return Text(
                                (m['name'] ?? '-').toString(),
                                style: TextStyle(color: cs.onSurfaceVariant),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 75),

              // ================= MAIN ROW =================
              Row(
                children: <Widget>[
                  // ============ LEFT BIG CARD ============
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.all(8),
                      height: 547,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: cs.surfaceContainerHighest, // ✅
                      ),
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Icon(
                                Icons.sunny,
                                size: AppIcon.huge(context),
                                color: cs.onSurfaceVariant, // ✅ was grey[500]
                              ),
                              const SizedBox(width: 10),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Time: $currentTime',
                                      style: TextStyle(
                                        color: cs.onSurfaceVariant,
                                        fontSize: AppText.subtitle(context),
                                      ),
                                    ),
                                    Text(
                                      'Realtime insight',
                                      style: TextStyle(
                                        color: cs.onSurfaceVariant,
                                        fontSize: AppText.body(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  'Today:',
                                  style: TextStyle(
                                    fontSize: AppText.title(context),
                                    color: cs.onSurface,
                                  ),
                                ),
                                Text(
                                  today,
                                  style: TextStyle(
                                    fontSize: AppText.subtitle(context),
                                    color: cs.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ============ COLUMN 1 ============
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        _statCard(
                          context,
                          cs: cs,
                          title: "Total Employees",
                          icon: Icons.person,
                          value: StreamBuilder<QuerySnapshot>(
                            stream: _db.collection('users').snapshots(),
                            builder: (context, snap) {
                              final total = snap.data?.docs.length ?? 0;
                              return _numText(context, '$total', cs);
                            },
                          ),
                        ),
                        _statCard(
                          context,
                          cs: cs,
                          title: "Late Arrival",
                          icon: Icons.alarm_off,
                          value: StreamBuilder<QuerySnapshot>(
                            stream: _db
                                .collection('attendance')
                                .where('date', isEqualTo: today)
                                .where('status', isEqualTo: 'LATE')
                                .snapshots(),
                            builder: (context, snap) {
                              final late = snap.data?.docs.length ?? 0;
                              return _numText(context, '$late', cs);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ============ COLUMN 2 ============
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        _statCard(
                          context,
                          cs: cs,
                          title: "On Time",
                          icon: Icons.alarm,
                          value: StreamBuilder<QuerySnapshot>(
                            stream: _db
                                .collection('attendance')
                                .where('date', isEqualTo: today)
                                .where('status', isEqualTo: 'PRESENT')
                                .snapshots(),
                            builder: (context, snap) {
                              final present = snap.data?.docs.length ?? 0;
                              return _numText(context, '$present', cs);
                            },
                          ),
                        ),
                        _statCard(
                          context,
                          cs: cs,
                          title: "Early Departures",
                          icon: Icons.outbond_outlined,
                          value: StreamBuilder<QuerySnapshot>(
                            stream: _db
                                .collection('attendance')
                                .where('date', isEqualTo: today)
                                .snapshots(),
                            builder: (context, snap) {
                              if (!snap.hasData)
                                return _numText(context, '0', cs);

                              int early = 0;
                              for (final doc in snap.data!.docs) {
                                final m = doc.data() as Map<String, dynamic>;
                                final checkOut = m['checkOut'];
                                if (checkOut is! Timestamp) continue;

                                final dt = checkOut.toDate();
                                if (dt.hour < 17) early++;
                              }
                              return _numText(context, '$early', cs);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ============ COLUMN 3 ============
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        _statCard(
                          context,
                          cs: cs,
                          title: "Absent",
                          icon: Icons.person_off,
                          value: StreamBuilder<QuerySnapshot>(
                            stream: _db.collection('users').snapshots(),
                            builder: (context, userSnap) {
                              final totalUsers =
                                  userSnap.data?.docs.length ?? 0;

                              return StreamBuilder<QuerySnapshot>(
                                stream: _db
                                    .collection('attendance')
                                    .where('date', isEqualTo: today)
                                    .snapshots(),
                                builder: (context, attSnap) {
                                  final checkedInToday =
                                      attSnap.data?.docs.length ?? 0;
                                  final absent =
                                      (totalUsers - checkedInToday) < 0
                                      ? 0
                                      : (totalUsers - checkedInToday);
                                  return _numText(context, '$absent', cs);
                                },
                              );
                            },
                          ),
                        ),
                        _statCard(
                          context,
                          cs: cs,
                          title: "Time Off",
                          icon: Icons.date_range,
                          value: StreamBuilder<QuerySnapshot>(
                            stream: _db
                                .collection('requests')
                                .where('status', isEqualTo: 'accepted')
                                .snapshots(),
                            builder: (context, snap) {
                              if (!snap.hasData)
                                return _numText(context, '0', cs);

                              int count = 0;
                              for (final doc in snap.data!.docs) {
                                final m = doc.data() as Map<String, dynamic>;
                                final from = m['fromDate'];
                                final to = m['toDate'];
                                if (from is! Timestamp || to is! Timestamp)
                                  continue;

                                final fromDate = DateTime(
                                  from.toDate().year,
                                  from.toDate().month,
                                  from.toDate().day,
                                );
                                final toDate = DateTime(
                                  to.toDate().year,
                                  to.toDate().month,
                                  to.toDate().day,
                                );

                                final t0 = DateTime.now();
                                final t = DateTime(t0.year, t0.month, t0.day);

                                if (!t.isBefore(fromDate) &&
                                    !t.isAfter(toDate)) {
                                  count++;
                                }
                              }

                              return _numText(context, '$count', cs);
                            },
                          ),
                        ),
                      ],
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

  // ===================== STAT CARD WIDGET =====================
  Widget _statCard(
    BuildContext context, {
    required ColorScheme cs,
    required String title,
    required IconData icon,
    required Widget value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(8),
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: cs.surfaceContainerHighest, // ✅ was grey[300]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: value),
              const Spacer(),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(4),
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cs.surfaceContainer, // ✅ was grey[100]
                  ),
                  child: Icon(
                    icon,
                    color: cs.primary, // ✅ was Colors.blue
                    size: AppIcon.medium(context),
                  ),
                ),
              ),
            ],
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: AppText.body(context),
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
