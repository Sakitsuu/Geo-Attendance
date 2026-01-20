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
  final uid = FirebaseAuth.instance.currentUser!.uid;

  Future<Map<String, dynamic>> _loadProfile() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    return doc.data()!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Profile not found'));
          }

          final data = snapshot.data!;
          final name = data['name'];
          final department = data['department'];
          final role = data['role'];
          final id = data['id'];

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
                      Text('Profile', style: TextStyle(fontSize: 28)),
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

                // STATS
                Row(
                  children: [
                    _statCard(
                      title: 'Attendance Rate',
                      icon: Icons.alarm,
                      value: '75%',
                    ),
                    _statCard(
                      title: 'Engagement Rate',
                      icon: Icons.arrow_outward,
                      value: '82%',
                    ),
                  ],
                ),

                // REQUESTS
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
                        children: const [
                          Icon(Icons.error_outline),
                          SizedBox(width: 10),
                          Text(
                            'Pending Approvals',
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      _requestTile(context, 'Time-off Request'),
                      _requestTile(context, 'Leave Request'),
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
    required String value,
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
            Text(
              value,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _requestTile(BuildContext context, String type) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey[200],
      ),
      child: Row(
        children: [
          Text(type),
          const Spacer(),
          ElevatedButton(
            onPressed: () => _openRequestDialog(context, type),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            child: const Text('Request'),
          ),
        ],
      ),
    );
  }

  void _openRequestDialog(BuildContext context, String type) {
    showDialog(
      context: context,
      builder: (_) {
        final controller = TextEditingController();

        return AlertDialog(
          title: Text(type),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Enter reason'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance.collection('requests').add({
                  'uid': uid,
                  'type': type,
                  'reason': controller.text.trim(),
                  'status': 'pending',
                  'createdAt': FieldValue.serverTimestamp(),
                });

                Navigator.pop(context);
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}
