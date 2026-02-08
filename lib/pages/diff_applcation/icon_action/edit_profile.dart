import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage>
    with WidgetsBindingObserver {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  final _formKey = GlobalKey<FormState>();

  bool _loading = true;
  bool _saving = false;

  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();

  String get uid => _auth.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    nameCtrl.dispose();
    emailCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshUser();
    }
  }

  Future<void> _load() async {
    try {
      final user = _auth.currentUser!;
      final doc = await _db.collection('users').doc(uid).get();

      nameCtrl.text = (doc.data()?['name'] ?? '').toString();
      emailCtrl.text = user.email ?? '';
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Load failed: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _refreshUser() async {
    try {
      await _auth.currentUser?.reload();
      final user = _auth.currentUser;
      if (user == null) return;

      if (mounted) {
        setState(() {
          emailCtrl.text = user.email ?? '';
        });
      }

      await _db.collection('users').doc(uid).set({
        'email': user.email ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final user = _auth.currentUser!;
      final newName = nameCtrl.text.trim();
      final newEmail = emailCtrl.text.trim();

      await _db.collection('users').doc(uid).set({
        'name': newName,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (newEmail != (user.email ?? '')) {
        await user.verifyBeforeUpdateEmail(newEmail);
        await _db.collection('users').doc(uid).set({
          'pendingEmail': newEmail,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Verification email sent. After verifying, return to the app and it will auto refresh.',
            ),
          ),
        );
        return;
      }

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile updated')));
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      if (e.code == 'requires-recent-login') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please log in again to change email (security requirement).',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message ?? 'Update failed')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Update failed: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _saving ? null : _refreshUser,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    _field(
                      cs: cs,
                      label: 'Full Name',
                      controller: nameCtrl,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Enter name' : null,
                    ),
                    const SizedBox(height: 12),
                    _field(
                      cs: cs,
                      label: 'Email',
                      controller: emailCtrl,
                      validator: (v) {
                        final s = (v ?? '').trim();
                        if (s.isEmpty) return 'Enter email';
                        if (!s.contains('@')) return 'Invalid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    ElevatedButton(
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: cs.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _saving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save'),
                    ),

                    const SizedBox(height: 10),

                    OutlinedButton.icon(
                      onPressed: _saving ? null : _refreshUser,
                      icon: const Icon(Icons.mark_email_read_outlined),
                      label: const Text('I verified my email, refresh'),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'Tip: If you changed email, verify it from your inbox. When you come back to the app, it will refresh automatically.',
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _field({
    required ColorScheme cs,
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: TextStyle(color: cs.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: cs.onSurfaceVariant),
        filled: true,
        fillColor: cs.surfaceContainerHighest,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.primary),
        ),
      ),
    );
  }
}
