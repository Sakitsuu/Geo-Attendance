import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ListWorkerSite extends StatefulWidget {
  const ListWorkerSite({super.key});

  @override
  State<ListWorkerSite> createState() => _ListWorkerSiteState();
}

class AppText {
  static double title(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return (w * 0.03).clamp(18.0, 32.0);
  }

  static double body(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return (w * 0.015).clamp(13.0, 18.0);
  }
}

class AppIcon {
  static double large(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return (w * 0.06).clamp(36.0, 80.0);
  }
}

class _ListWorkerSiteState extends State<ListWorkerSite> {
  final CollectionReference attendanceRef = FirebaseFirestore.instance
      .collection('attendance');

  DateTime _selectedDate = DateTime.now();

  String get _dateKey => _formatDateKey(_selectedDate);

  static String _formatDateKey(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return "$y-$m-$day";
  }

  String _formatTime(dynamic v) {
    if (v == null) return "-";
    if (v is Timestamp) {
      final dt = v.toDate();
      final hh = dt.hour.toString().padLeft(2, '0');
      final mm = dt.minute.toString().padLeft(2, '0');
      return "$hh:$mm";
    }
    return v.toString();
  }

  String _text(dynamic v) => (v ?? '').toString();

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020, 1, 1),
      lastDate: DateTime(2100, 12, 31),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final query = attendanceRef.where('date', isEqualTo: _dateKey);

    return Scaffold(
      body: SingleChildScrollView(
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
                  Text(
                    'Attendance List',
                    style: TextStyle(
                      fontSize: AppText.title(context),
                      color: cs.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _dateKey,
                    style: TextStyle(
                      fontSize: AppText.body(context),
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_month),
                    label: const Text('Date'),
                  ),
                  const SizedBox(width: 12),
                  VerticalDivider(thickness: 2, color: cs.outlineVariant),
                  Icon(Icons.people, size: AppIcon.large(context)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 800,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: cs.surfaceContainerHighest,
                  ),
                  child: Column(
                    children: <Widget>[
                      DefaultTextStyle(
                        style: TextStyle(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                        child: const Row(
                          children: <Widget>[
                            Expanded(flex: 1, child: Text('No.')),
                            Expanded(flex: 2, child: Text('Name')),
                            Expanded(flex: 3, child: Text('Department')),
                            Expanded(flex: 3, child: Text('Phone number')),
                            Expanded(flex: 2, child: Text('Check-in')),
                            Expanded(flex: 2, child: Text('Check-out')),
                            Expanded(flex: 2, child: Text('Date')),
                          ],
                        ),
                      ),

                      Divider(thickness: 2, color: cs.outlineVariant),

                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: query.snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(
                                child: Text(
                                  'Error loading attendance',
                                  style: TextStyle(color: cs.onSurface),
                                ),
                              );
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            final docs = snapshot.data?.docs ?? [];

                            if (docs.isEmpty) {
                              return Center(
                                child: Text(
                                  'No attendance on $_dateKey',
                                  style: TextStyle(color: cs.onSurface),
                                ),
                              );
                            }

                            return ListView.builder(
                              itemCount: docs.length,
                              itemBuilder: (context, index) {
                                final m =
                                    (docs[index].data()
                                        as Map<String, dynamic>?) ??
                                    {};

                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: cs.outlineVariant.withOpacity(
                                          0.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                  child: DefaultTextStyle(
                                    style: TextStyle(color: cs.onSurface),
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                          flex: 1,
                                          child: Text('${index + 1}'),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(_text(m['name'])),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Text(_text(m['department'])),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Text(_text(m['phone'])),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            _formatTime(m['checkIn']),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            _formatTime(m['checkOut']),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(_text(m['date'])),
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
