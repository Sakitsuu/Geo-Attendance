import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DepartmentSite extends StatelessWidget {
  const DepartmentSite({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ IMPORTANT: no MaterialApp here (use global theme from main.dart)
    return const DepartmentPage();
  }
}

// ------------------ Responsive helpers ------------------
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

  static double medium(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return (w * 0.045).clamp(28.0, 60.0);
  }

  static double small(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return (w * 0.035).clamp(24.0, 48.0);
  }
}

// ------------------ Department Model ------------------
class DepartmentItem {
  final String id; // docId in departments
  final String name; // departments.name
  final int totalEmployees; // computed from users.department
  final String leaderName; // departments.leaderName
  final String icon; // departments.icon

  const DepartmentItem({
    required this.id,
    required this.name,
    required this.totalEmployees,
    required this.leaderName,
    required this.icon,
  });
}

class DepartmentPage extends StatefulWidget {
  const DepartmentPage({super.key});

  @override
  State<DepartmentPage> createState() => _DepartmentPageState();
}

class _DepartmentPageState extends State<DepartmentPage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser?.uid ?? '';

  Stream<String> _roleStream() {
    if (uid.isEmpty) return Stream.value('guest');
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      final role = (doc.data()?['role'] ?? 'staff').toString();
      return role.toLowerCase();
    });
  }

  IconData _iconFromString(String icon) {
    switch (icon) {
      case 'bar_chart':
        return Icons.bar_chart_rounded;
      case 'computer':
        return Icons.computer;
      case 'finance':
        return Icons.monetization_on_outlined;
      case 'legal':
        return Icons.gavel;
      case 'api':
        return Icons.api;
      case 'group':
        return Icons.group;
      default:
        return Icons.business;
    }
  }

  // ------------------ CRUD (manager only UI) ------------------
  Future<void> _openDeptDialog({
    String? docId,
    Map<String, dynamic>? existing,
  }) async {
    final nameCtrl = TextEditingController(
      text: (existing?['name'] ?? '').toString(),
    );
    final leaderCtrl = TextEditingController(
      text: (existing?['leaderName'] ?? '').toString(),
    );
    String selectedIcon = (existing?['icon'] ?? 'group').toString();

    bool saving = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            Future<void> save() async {
              final name = nameCtrl.text.trim();
              final leader = leaderCtrl.text.trim();

              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Department name is required')),
                );
                return;
              }

              setLocal(() => saving = true);

              final payload = <String, dynamic>{
                'name': name,
                'leaderName': leader.isEmpty ? '-' : leader,
                'icon': selectedIcon,
                'updatedAt': FieldValue.serverTimestamp(),
              };

              try {
                if (docId == null) {
                  payload['createdAt'] = FieldValue.serverTimestamp();
                  await _db
                      .collection('departments')
                      .add(payload); // auto id OK
                } else {
                  await _db
                      .collection('departments')
                      .doc(docId)
                      .update(payload);
                }
                if (mounted) Navigator.pop(ctx);
              } catch (e) {
                setLocal(() => saving = false);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Save failed: $e')));
              }
            }

            return AlertDialog(
              title: Text(docId == null ? 'Add Department' : 'Edit Department'),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Department name',
                        hintText: 'e.g. IT',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: leaderCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Team leader name (optional)',
                        hintText: 'e.g. Mr. John De',
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedIcon,
                      items: const [
                        DropdownMenuItem(
                          value: 'bar_chart',
                          child: Text('bar_chart'),
                        ),
                        DropdownMenuItem(
                          value: 'computer',
                          child: Text('computer'),
                        ),
                        DropdownMenuItem(
                          value: 'finance',
                          child: Text('finance'),
                        ),
                        DropdownMenuItem(value: 'legal', child: Text('legal')),
                        DropdownMenuItem(value: 'api', child: Text('api')),
                        DropdownMenuItem(value: 'group', child: Text('group')),
                      ],
                      onChanged: (v) =>
                          setLocal(() => selectedIcon = v ?? 'group'),
                      decoration: const InputDecoration(labelText: 'Icon'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: saving ? null : () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: saving ? null : save,
                  child: saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(docId == null ? 'Add' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );

    nameCtrl.dispose();
    leaderCtrl.dispose();
  }

  Future<void> _deleteDept(String docId, String name) async {
    final ok =
        await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete department?'),
            content: Text('Delete "$name"? Users still keep users.department.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;

    if (!ok) return;

    try {
      await _db.collection('departments').doc(docId).delete();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    }
  }

  // ------------------ UI ------------------
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final bool isSmall = w < 1100;

    return StreamBuilder<String>(
      stream: _roleStream(),
      builder: (context, roleSnap) {
        final role = (roleSnap.data ?? 'staff').toLowerCase();
        final bool isManager = role == 'manager';

        return Scaffold(
          floatingActionButton: isManager
              ? FloatingActionButton(
                  onPressed: () => _openDeptDialog(),
                  child: const Icon(Icons.add),
                )
              : null,
          body: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1400),
                child: Column(
                  children: [
                    _header(context, role),
                    const SizedBox(height: 16),

                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: _db
                          .collection('departments')
                          .orderBy('name')
                          .snapshots(),
                      builder: (context, deptSnap) {
                        if (deptSnap.hasError)
                          return _errorBox('Error: ${deptSnap.error}');
                        if (!deptSnap.hasData) {
                          return const Padding(
                            padding: EdgeInsets.all(24.0),
                            child: CircularProgressIndicator(),
                          );
                        }

                        return StreamBuilder<
                          QuerySnapshot<Map<String, dynamic>>
                        >(
                          stream: _db.collection('users').snapshots(),
                          builder: (context, userSnap) {
                            if (userSnap.hasError)
                              return _errorBox('Error: ${userSnap.error}');
                            if (!userSnap.hasData) {
                              return const Padding(
                                padding: EdgeInsets.all(24.0),
                                child: CircularProgressIndicator(),
                              );
                            }

                            final deptDocs = deptSnap.data!.docs;
                            final userDocs = userSnap.data!.docs;

                            if (deptDocs.isEmpty) {
                              return _emptyBox(
                                'No departments yet',
                                isManager
                                    ? 'Tap + to add a department (e.g. IT, Sale).'
                                    : 'Ask manager to create departments.',
                              );
                            }

                            // ✅ COUNT USERS BY users.department (case-insensitive)
                            final Map<String, int> countsByDept = {};
                            for (final u in userDocs) {
                              final dep = (u.data()['department'] ?? '')
                                  .toString()
                                  .trim()
                                  .toLowerCase();
                              if (dep.isEmpty) continue;
                              countsByDept[dep] = (countsByDept[dep] ?? 0) + 1;
                            }

                            final items = deptDocs.map((d) {
                              final data = d.data();
                              final depId = d.id;
                              final depName = (data['name'] ?? depId)
                                  .toString();
                              final key = depName.trim().toLowerCase();

                              return DepartmentItem(
                                id: depId,
                                name: depName,
                                totalEmployees: countsByDept[key] ?? 0,
                                leaderName: (data['leaderName'] ?? '-')
                                    .toString(),
                                icon: (data['icon'] ?? 'group').toString(),
                              );
                            }).toList();

                            if (isSmall) {
                              return Column(
                                children: [
                                  _departmentGrid(context, items, isManager),
                                  const SizedBox(height: 16),
                                  _leadersBox(context, items),
                                ],
                              );
                            }

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: _departmentGrid(
                                    context,
                                    items,
                                    isManager,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: _leadersBox(context, items),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _header(BuildContext context, String role) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(8),
      height: 166,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[300],
      ),
      child: Row(
        children: [
          Text(
            'Department',
            style: TextStyle(fontSize: AppText.title(context)),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.75),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text('Role: $role'),
          ),
          const SizedBox(width: 12),
          const VerticalDivider(thickness: 2, color: Colors.grey),
          Icon(Icons.person, size: AppIcon.large(context)),
          const SizedBox(width: 10),
          SizedBox(
            height: 50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('User'),
                Text(uid.isEmpty ? '@guest' : '@$uid'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _departmentGrid(
    BuildContext context,
    List<DepartmentItem> items,
    bool isManager,
  ) {
    final w = MediaQuery.of(context).size.width;

    int crossAxisCount = 3;
    if (w < 1200) crossAxisCount = 2;
    if (w < 700) crossAxisCount = 1;

    final double cardHeight = (w < 700) ? 180 : 170;

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[300],
      ),
      child: GridView.builder(
        itemCount: items.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          mainAxisExtent: cardHeight,
        ),
        itemBuilder: (context, i) => _deptCard(context, items[i], isManager),
      ),
    );
  }

  Widget _deptCard(BuildContext context, DepartmentItem d, bool isManager) {
    final icon = _iconFromString(d.icon);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                DepartmentMembersPage(departmentName: d.name, icon: icon),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[100],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: AppIcon.medium(context)),
                const Spacer(),
                if (isManager)
                  PopupMenuButton<String>(
                    tooltip: 'Manage',
                    onSelected: (v) {
                      if (v == 'edit') {
                        _openDeptDialog(
                          docId: d.id,
                          existing: {
                            'name': d.name,
                            'leaderName': d.leaderName,
                            'icon': d.icon,
                          },
                        );
                      } else if (v == 'delete') {
                        _deleteDept(d.id, d.name);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              d.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: AppText.body(context)),
            ),
            const SizedBox(height: 6),
            const Divider(thickness: 2),
            Expanded(
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Total Employees: ${d.totalEmployees}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: AppText.body(context),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _leadersBox(BuildContext context, List<DepartmentItem> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[300],
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              'All team leader of each department',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppText.title(context),
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 20),
            ...items.map((d) {
              final icon = _iconFromString(d.icon);
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    Icon(icon, size: AppIcon.small(context)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Team leader of ${d.name}: ${d.leaderName}',
                        style: TextStyle(fontSize: AppText.body(context)),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _errorBox(String msg) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red),
      ),
      child: Text(msg),
    );
  }

  Widget _emptyBox(String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(subtitle),
        ],
      ),
    );
  }
}

// ------------------ Members Page ------------------
class DepartmentMembersPage extends StatelessWidget {
  final String departmentName;
  final IconData icon;

  const DepartmentMembersPage({
    super.key,
    required this.departmentName,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;

    // ✅ case-insensitive match by adding "departmentLower" is best
    // But for now, we match exact departmentName.
    return Scaffold(
      appBar: AppBar(title: Text('Members: $departmentName')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: db
            .collection('users')
            .where('department', isEqualTo: departmentName)
            .snapshots(),
        builder: (context, snap) {
          if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
          if (!snap.hasData)
            return const Center(child: CircularProgressIndicator());

          final users = snap.data!.docs;
          if (users.isEmpty) {
            return Center(
              child: Text(
                'No users in $departmentName yet.\n'
                'Make sure users.department == "$departmentName"',
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.separated(
            itemCount: users.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final u = users[i].data();
              final name = (u['name'] ?? 'Unknown').toString();
              final role = (u['role'] ?? 'staff').toString();
              final email = (u['email'] ?? '').toString();

              return ListTile(
                leading: CircleAvatar(child: Icon(icon)),
                title: Text(name),
                subtitle: Text(
                  email.isEmpty ? 'Role: $role' : '$email • Role: $role',
                ),
              );
            },
          );
        },
      ),
    );
  }
}
