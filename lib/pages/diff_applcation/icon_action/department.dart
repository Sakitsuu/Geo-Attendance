import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DepartmentSite extends StatelessWidget {
  const DepartmentSite({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ IMPORTANT: no MaterialApp here (use global theme from main.dart)
    return const DepartmentPage();
  }
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

class DepartmentPage extends StatefulWidget {
  const DepartmentPage({super.key});

  @override
  State<DepartmentPage> createState() => _DepartmentPageState();
}

class _DepartmentPageState extends State<DepartmentPage> {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _deptRef =>
      _db.collection('departments');

  Stream<QuerySnapshot<Map<String, dynamic>>> _deptStream() {
    return _deptRef.orderBy('name').snapshots();
  }

  Future<void> _openAddDialog() async {
    final nameCtrl = TextEditingController();
    final codeCtrl = TextEditingController();
    bool active = true;
    bool saving = false;

    await showDialog(
      context: context,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;

        return StatefulBuilder(
          builder: (ctx, setLocal) {
            Future<void> save() async {
              final name = nameCtrl.text.trim();
              final code = codeCtrl.text.trim();

              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Department name is required')),
                );
                return;
              }

              setLocal(() => saving = true);
              try {
                await _deptRef.add({
                  'name': name,
                  'code': code.isEmpty
                      ? name.toUpperCase()
                      : code.toUpperCase(),
                  'active': active,
                  'createdAt': FieldValue.serverTimestamp(),
                  'updatedAt': FieldValue.serverTimestamp(),
                });

                if (!mounted) return;
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Department added ✅')),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Add failed: $e')));
              } finally {
                setLocal(() => saving = false);
              }
            }

            return AlertDialog(
              backgroundColor: cs.surface,
              title: Text(
                'Add Department',
                style: TextStyle(color: cs.onSurface),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Department Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: codeCtrl,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Department Code (optional)',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) {
                      if (!saving) save();
                    },
                  ),
                  const SizedBox(height: 10),
                  SwitchListTile(
                    value: active,
                    onChanged: saving
                        ? null
                        : (v) => setLocal(() => active = v),
                    title: const Text('Active'),
                  ),
                ],
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
                      : const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _openEditDialog(String docId, Map<String, dynamic> data) async {
    final nameCtrl = TextEditingController(
      text: (data['name'] ?? '').toString(),
    );
    final codeCtrl = TextEditingController(
      text: (data['code'] ?? '').toString(),
    );
    bool active = (data['active'] ?? true) == true;
    bool saving = false;

    await showDialog(
      context: context,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;

        return StatefulBuilder(
          builder: (ctx, setLocal) {
            Future<void> save() async {
              final name = nameCtrl.text.trim();
              final code = codeCtrl.text.trim();

              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Department name is required')),
                );
                return;
              }

              setLocal(() => saving = true);
              try {
                await _deptRef.doc(docId).update({
                  'name': name,
                  'code': code.isEmpty
                      ? name.toUpperCase()
                      : code.toUpperCase(),
                  'active': active,
                  'updatedAt': FieldValue.serverTimestamp(),
                });

                if (!mounted) return;
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Department updated ✅')),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Update failed: $e')));
              } finally {
                setLocal(() => saving = false);
              }
            }

            return AlertDialog(
              backgroundColor: cs.surface,
              title: Text(
                'Edit Department',
                style: TextStyle(color: cs.onSurface),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Department Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: codeCtrl,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Department Code (optional)',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) {
                      if (!saving) save();
                    },
                  ),
                  const SizedBox(height: 10),
                  SwitchListTile(
                    value: active,
                    onChanged: saving
                        ? null
                        : (v) => setLocal(() => active = v),
                    title: const Text('Active'),
                  ),
                ],
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
                      : const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteDepartment(String docId) async {
    try {
      await _deptRef.doc(docId).delete();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Department deleted ✅')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ================= HEADER (same style as Graphic) =================
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
                    'Department',
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
                            final m = snap.data!.data() as Map<String, dynamic>;
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

            const SizedBox(height: 16),

            // ================= CONTENT =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    'Department List',
                    style: TextStyle(
                      fontSize: AppText.body(context),
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _openAddDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Department'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _deptStream(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text(
                        'Error: ${snapshot.error}',
                        style: TextStyle(color: cs.onSurface),
                      );
                    }
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final docs = snapshot.data!.docs;
                    if (docs.isEmpty) {
                      return Text(
                        'No departments yet. Click "Add Department".',
                        style: TextStyle(color: cs.onSurface),
                      );
                    }

                    return Column(
                      children: docs.map((d) {
                        final data = d.data();
                        final name = (data['name'] ?? '').toString();
                        final code = (data['code'] ?? '').toString();
                        final active = (data['active'] ?? true) == true;

                        return Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainer,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: cs.outlineVariant.withOpacity(0.6),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: TextStyle(
                                        color: cs.onSurface,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      code.isEmpty ? '-' : 'Code: $code',
                                      style: TextStyle(
                                        color: cs.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(999),
                                  color: active
                                      ? Colors.green.shade100
                                      : Colors.red.shade100,
                                ),
                                child: Text(
                                  active ? 'Active' : 'Inactive',
                                  style: TextStyle(
                                    color: active
                                        ? Colors.green.shade900
                                        : Colors.red.shade900,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              IconButton(
                                onPressed: () => _openEditDialog(d.id, data),
                                icon: Icon(Icons.edit, color: cs.onSurface),
                              ),
                              IconButton(
                                onPressed: () => _deleteDepartment(d.id),
                                icon: Icon(Icons.delete, color: cs.error),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
