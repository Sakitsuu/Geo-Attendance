import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotificationSite extends StatelessWidget {
  const NotificationSite({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Geo Attendant',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        fontFamily: 'MomoTrustDisplay',
      ),
      home: const NotificationPage(),
    );
  }
}

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  Stream<QuerySnapshot<Map<String, dynamic>>> _notifStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _notifStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No notifications yet'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final data = docs[index].data();

              final title = (data['title'] ?? 'Notification').toString();
              final message = (data['message'] ?? '').toString();

              // type: "request" or "password"
              final type = (data['type'] ?? '').toString();

              // status only for request: "pending"/"accepted"/"rejected"
              final status = (data['status'] ?? '').toString();

              final ts = data['createdAt'];
              final dateText = (ts is Timestamp)
                  ? _formatTime(ts.toDate())
                  : '';

              final icon = _iconFor(type, status);
              final chip = _statusChip(type, status);

              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, size: 26),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              if (chip != null) chip,
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            message,
                            style: TextStyle(color: Colors.grey[800]),
                          ),
                          if (dateText.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              dateText,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // icon based on notification type + status
  IconData _iconFor(String type, String status) {
    if (type == 'password') return Icons.lock_reset;

    // request
    switch (status) {
      case 'accepted':
        return Icons.check_circle_outline;
      case 'rejected':
        return Icons.cancel_outlined;
      case 'pending':
      default:
        return Icons.hourglass_bottom;
    }
  }

  // chip only for request type
  Widget? _statusChip(String type, String status) {
    if (type == 'password') return null;

    String label = status.isEmpty ? 'pending' : status;

    Color bg;
    Color fg;

    switch (label) {
      case 'accepted':
        bg = Colors.green.shade100;
        fg = Colors.green.shade900;
        break;
      case 'rejected':
        bg = Colors.red.shade100;
        fg = Colors.red.shade900;
        break;
      case 'pending':
      default:
        bg = Colors.orange.shade100;
        fg = Colors.orange.shade900;
        label = 'pending';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
