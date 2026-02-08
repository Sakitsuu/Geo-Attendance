import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ManagerRequestsPage extends StatefulWidget {
  const ManagerRequestsPage({super.key});

  @override
  State<ManagerRequestsPage> createState() => _ManagerRequestsPageState();
}

class _ManagerRequestsPageState extends State<ManagerRequestsPage> {
  String filterStatus = 'pending';

  Stream<QuerySnapshot> _requestsStreamSafe() async* {
    try {
      yield* FirebaseFirestore.instance.collection('requests').snapshots();
    } catch (e) {
      debugPrint('🔥 Firestore fatal error (requests stream): $e');
      rethrow;
    }
  }

  String _fmtDate(Timestamp ts) {
    final d = ts.toDate();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  String _safeDate(dynamic v) {
    if (v is Timestamp) return _fmtDate(v);
    return '-';
  }

  DateTime _safeCreatedAt(dynamic v) {
    if (v is Timestamp) return v.toDate();
    return DateTime(1970);
  }

  Future<void> _updateRequestStatus(
    DocumentSnapshot doc,
    String newStatus,
  ) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('You are not logged in.')));
        return;
      }

      final managerUid = user.uid;
      final data = doc.data() as Map<String, dynamic>;
      final workerUid = data['uid'];

      if (workerUid == null || workerUid.toString().isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request has no worker uid.')),
        );
        return;
      }

      await FirebaseFirestore.instance
          .collection('requests')
          .doc(doc.id)
          .update({
            'status': newStatus,
            'reviewedBy': managerUid,
            'reviewedAt': FieldValue.serverTimestamp(),
          });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(workerUid.toString())
          .collection('notifications')
          .add({
            'title': 'Request ${newStatus.toUpperCase()}',
            'message':
                'Your ${data['type']} request (${_safeDate(data['fromDate'])} → ${_safeDate(data['toDate'])}) was $newStatus.',
            'type': 'request',
            'status': newStatus,
            'createdAt': FieldValue.serverTimestamp(),
          });

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Request $newStatus ✅')));
    } catch (e) {
      debugPrint('🔥 Update/Notify failed: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Action failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        backgroundColor: cs.surface,
        body: Center(
          child: Text(
            'You must be logged in to view requests.',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: cs.surface,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(8),
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: cs.surfaceContainerHighest,
            ),
            child: Row(
              children: [
                Text(
                  'Manage Requests',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const Spacer(),

                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: filterStatus,
                    dropdownColor: cs.surfaceContainerHighest,
                    style: TextStyle(color: cs.onSurface),
                    items: const [
                      DropdownMenuItem(
                        value: 'pending',
                        child: Text('Pending'),
                      ),
                      DropdownMenuItem(
                        value: 'accepted',
                        child: Text('Accepted'),
                      ),
                      DropdownMenuItem(
                        value: 'rejected',
                        child: Text('Rejected'),
                      ),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => filterStatus = v);
                    },
                  ),
                ),
              ],
            ),
          ),

          // LIST
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _requestsStreamSafe(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Firestore error:\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: cs.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No requests found',
                      style: TextStyle(color: cs.onSurface),
                    ),
                  );
                }

                final docs = snapshot.data!.docs.toList()
                  ..sort((a, b) {
                    final ad = (a.data() as Map)['createdAt'];
                    final bd = (b.data() as Map)['createdAt'];
                    return _safeCreatedAt(bd).compareTo(_safeCreatedAt(ad));
                  });

                final filteredDocs = docs.where((d) {
                  final data = d.data() as Map<String, dynamic>;
                  return (data['status'] ?? 'pending') == filterStatus;
                }).toList();

                if (filteredDocs.isEmpty) {
                  return Center(
                    child: Text(
                      'No $filterStatus requests',
                      style: TextStyle(color: cs.onSurface),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final doc = filteredDocs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    final type = (data['type'] ?? '').toString();
                    final reason = (data['reason'] ?? '').toString();

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: cs.outlineVariant),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${type.toUpperCase()} REQUEST',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: cs.onSurface,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${_safeDate(data['fromDate'])} → ${_safeDate(data['toDate'])}',
                            style: TextStyle(color: cs.onSurfaceVariant),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Reason: $reason',
                            style: TextStyle(color: cs.onSurfaceVariant),
                          ),
                          const SizedBox(height: 10),

                          if (filterStatus == 'pending')
                            Row(
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () =>
                                      _updateRequestStatus(doc, 'accepted'),
                                  child: const Text('Accept'),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () =>
                                      _updateRequestStatus(doc, 'rejected'),
                                  child: const Text('Reject'),
                                ),
                              ],
                            )
                          else
                            Chip(
                              label: Text(
                                filterStatus,
                                style: TextStyle(color: cs.onSurface),
                              ),
                              backgroundColor: filterStatus == 'accepted'
                                  ? Colors.green.shade100
                                  : Colors.red.shade100,
                            ),
                        ],
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
