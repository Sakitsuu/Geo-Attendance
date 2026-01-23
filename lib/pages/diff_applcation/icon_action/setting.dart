import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geo_attendance_new_ui/pages/theme_controller.dart';

class SettingSite extends StatelessWidget {
  const SettingSite({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingPage();
  }
}

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> _loadUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _db.collection('users').doc(user.uid).get();
    return doc.data();
  }

  Future<void> _sendResetEmail() async {
    final user = _auth.currentUser;
    final email = user?.email;

    if (email == null || email.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No email found for this account.')),
      );
      return;
    }

    await _auth.sendPasswordResetEmail(email: email);
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Reset link sent to $email')));
  }

  Future<void> _logout() async {
    await _auth.signOut();
    if (!mounted) return;

    // Go back to first route (your app should show login on first route)
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    // ✅ IMPORTANT: rebuild this page when theme changes
    return AnimatedBuilder(
      animation: themeController,
      builder: (context, _) {
        final cs = Theme.of(context).colorScheme;

        return Scaffold(
          backgroundColor: cs.surface,
          appBar: AppBar(
            title: const Text('Settings'),
            backgroundColor: cs.surface,
            foregroundColor: cs.onSurface,
            elevation: 0,
          ),
          body: FutureBuilder<Map<String, dynamic>?>(
            future: _loadUser(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final data = snap.data;
              final user = _auth.currentUser;

              final name = (data?['name'] ?? '').toString();
              final dept = (data?['department'] ?? '').toString();
              final role = (data?['role'] ?? '').toString();
              final email = (user?.email ?? '').toString();

              return ListView(
                padding: const EdgeInsets.all(14),
                children: [
                  // ===== Profile Card =====
                  Card(
                    color: cs.surfaceContainerHighest,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: cs.primaryContainer,
                            foregroundColor: cs.onPrimaryContainer,
                            child: const Icon(Icons.person),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name.isEmpty ? 'No name set' : name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: cs.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  email.isEmpty ? '-' : email,
                                  style: TextStyle(color: cs.onSurfaceVariant),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Dept: ${dept.isEmpty ? "-" : dept} • Role: ${role.isEmpty ? "-" : role}',
                                  style: TextStyle(color: cs.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ===== Account section =====
                  Card(
                    color: cs.surfaceContainerHighest,
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.edit, color: cs.primary),
                          title: Text(
                            'Edit profile',
                            style: TextStyle(color: cs.onSurface),
                          ),
                          onTap: () {
                            // TODO: Navigator.push(...EditProfilePage())
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ===== Appearance section =====
                  Card(
                    color: cs.surfaceContainerHighest,
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(
                            Icons.palette_outlined,
                            color: cs.primary,
                          ),
                          title: Text(
                            'Appearance',
                            style: TextStyle(color: cs.onSurface),
                          ),
                          subtitle: Text(
                            'Light / Dark mode',
                            style: TextStyle(color: cs.onSurfaceVariant),
                          ),
                        ),
                        Divider(height: 1, color: cs.outlineVariant),
                        SwitchListTile(
                          title: Text(
                            'Dark mode',
                            style: TextStyle(color: cs.onSurface),
                          ),
                          value: themeController.isDark,
                          onChanged: (v) => themeController.setDark(v),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ===== Security section =====
                  Card(
                    color: cs.surfaceContainerHighest,
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.lock_outline, color: cs.primary),
                          title: Text(
                            'Security',
                            style: TextStyle(color: cs.onSurface),
                          ),
                          subtitle: Text(
                            'Password & account recovery',
                            style: TextStyle(color: cs.onSurfaceVariant),
                          ),
                        ),
                        Divider(height: 1, color: cs.outlineVariant),
                        ListTile(
                          leading: Icon(
                            Icons.email_outlined,
                            color: cs.primary,
                          ),
                          title: Text(
                            'Send password reset email',
                            style: TextStyle(color: cs.onSurface),
                          ),
                          onTap: () async {
                            try {
                              await _sendResetEmail();
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed: $e')),
                              );
                            }
                          },
                        ),
                        Divider(height: 1, color: cs.outlineVariant),
                        ListTile(
                          leading: Icon(Icons.password, color: cs.primary),
                          title: Text(
                            'Change password',
                            style: TextStyle(color: cs.onSurface),
                          ),
                          onTap: () {
                            // TODO: Navigator.push(...ChangePasswordPage())
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ===== About =====
                  Card(
                    color: cs.surfaceContainerHighest,
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.info_outline, color: cs.primary),
                          title: Text(
                            'About',
                            style: TextStyle(color: cs.onSurface),
                          ),
                          subtitle: Text(
                            'Geo Attendant',
                            style: TextStyle(color: cs.onSurfaceVariant),
                          ),
                        ),
                        Divider(height: 1, color: cs.outlineVariant),

                        // ✅ Logout at the bottom (as you wanted)
                        ListTile(
                          leading: Icon(Icons.logout, color: cs.error),
                          title: Text(
                            'Logout',
                            style: TextStyle(color: cs.error),
                          ),
                          onTap: _logout,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
