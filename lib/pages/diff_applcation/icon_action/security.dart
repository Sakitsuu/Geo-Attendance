import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SecuritySite extends StatefulWidget {
  const SecuritySite({super.key});

  @override
  State<SecuritySite> createState() => _SecuritySiteState();
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
    return (w * 0.12).clamp(100.0, 180.0);
  }

  static double huge(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return (w * 0.11).clamp(120.0, 180.0);
  }
}

class _SecuritySiteState extends State<SecuritySite> {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  bool shareLocation = true;

  String? get uid => _auth.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _loadPrivacySettings();
  }

  Future<void> _loadPrivacySettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      shareLocation = prefs.getBool('shareLocation') ?? true;
    });
  }

  Future<void> _saveShareLocation(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('shareLocation', value);
  }

  Future<LocationPermission> _getPermission() async {
    return Geolocator.checkPermission();
  }

  Future<void> _handleLocationToggle(bool value) async {
    setState(() => shareLocation = value);
    await _saveShareLocation(value);
    if (value) {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        return;
      }

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      } else if (permission == LocationPermission.deniedForever) {
        await Geolocator.openAppSettings();
        return;
      }

      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _topHeader(context, cs: cs, title: 'Privacy', db: _db, auth: _auth),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _sectionCard(
                      cs: cs,
                      title: "Privacy Controls",
                      icon: Icons.privacy_tip_outlined,
                      child: Column(
                        children: [
                          FutureBuilder<LocationPermission>(
                            future: _getPermission(),
                            builder: (context, snapshot) {
                              final p = snapshot.data;
                              final allowed =
                                  p == LocationPermission.always ||
                                  p == LocationPermission.whileInUse;
                              final statusColor = (!shareLocation)
                                  ? cs.onSurfaceVariant
                                  : (allowed ? Colors.green : Colors.red);

                              return Container(
                                margin: const EdgeInsets.only(top: 10),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: cs.surfaceContainer,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: cs.outlineVariant),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      color: statusColor,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Share Location",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: cs.onSurface,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            !shareLocation
                                                ? "Turn this ON if you want to use attendance checking."
                                                : (allowed
                                                      ? "Location permission is enabled. Attendance can verify your location."
                                                      : "Permission is not enabled yet. Tap 'Open Location Settings'."),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: cs.onSurfaceVariant,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              Switch(
                                                value: shareLocation,
                                                onChanged:
                                                    _handleLocationToggle,
                                              ),
                                              const SizedBox(width: 8),
                                              if (shareLocation && !allowed)
                                                TextButton(
                                                  onPressed: () async {
                                                    await Geolocator.openAppSettings();
                                                    if (mounted) {
                                                      setState(() {});
                                                    }
                                                  },
                                                  child: const Text(
                                                    "Open Location Settings",
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    _sectionCard(
                      cs: cs,
                      title: "Data & Permissions",
                      icon: Icons.admin_panel_settings_outlined,
                      child: Column(
                        children: [
                          _actionTile(
                            cs: cs,
                            icon: Icons.cleaning_services_outlined,
                            title: "Clear Cached Data",
                            subtitle: "Remove local cache on this device.",
                            onTap: () => _showInfo(
                              context,
                              "Cache Cleared",
                              "Local cache cleared successfully.",
                            ),
                          ),
                          _actionTile(
                            cs: cs,
                            icon: Icons.delete_outline,
                            title: "Delete Activity History",
                            subtitle: "Remove saved activity logs.",
                            onTap: () => _confirmDanger(
                              context,
                              cs: cs,
                              title: "Delete Activity History?",
                              message:
                                  "This action cannot be undone. Continue?",
                              onConfirm: () {
                                // TODO: delete logs
                                // Example:
                                // _db.collection('logs').where('uid', isEqualTo: uid).get()...
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    _sectionCard(
                      cs: cs,
                      title: "Legal",
                      icon: Icons.article_outlined,
                      child: Column(
                        children: [
                          _actionTile(
                            cs: cs,
                            icon: Icons.policy_outlined,
                            title: "Privacy Policy",
                            subtitle: "Read how we handle your data.",
                            onTap: () => _showInfo(
                              context,
                              "Privacy Policy",
                              "Open your privacy policy page/link.",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _topHeader(
  BuildContext context, {
  required ColorScheme cs,
  required String title,
  required FirebaseFirestore db,
  required FirebaseAuth auth,
}) {
  final uid = auth.currentUser?.uid;

  return Container(
    padding: const EdgeInsets.all(16),
    margin: const EdgeInsets.all(8),
    height: 120,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      color: cs.surfaceContainerHighest,
    ),
    child: Row(
      children: <Widget>[
        Text(
          title,
          style: TextStyle(
            fontSize: AppText.title(context),
            color: cs.onSurface,
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
              if (uid == null)
                Text('-', style: TextStyle(color: cs.onSurfaceVariant))
              else
                StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: db.collection('users').doc(uid).snapshots(),
                  builder: (context, snap) {
                    if (snap.hasError) {
                      return Text(
                        'Error',
                        style: TextStyle(color: cs.onSurfaceVariant),
                      );
                    }
                    if (!snap.hasData) {
                      return Text(
                        'Loading...',
                        style: TextStyle(color: cs.onSurfaceVariant),
                      );
                    }
                    if (!snap.data!.exists) {
                      return Text(
                        '-',
                        style: TextStyle(color: cs.onSurfaceVariant),
                      );
                    }
                    final m = snap.data!.data() ?? {};
                    return Text(
                      (m['name'] ?? '-').toString(),
                      style: TextStyle(color: cs.onSurface),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _sectionCard({
  required ColorScheme cs,
  required String title,
  required IconData icon,
  required Widget child,
}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: cs.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: cs.outlineVariant),
    ),
    child: Column(
      children: [
        Row(
          children: [
            Icon(icon, color: cs.primary),
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        child,
      ],
    ),
  );
}

Widget _actionTile({
  required ColorScheme cs,
  required IconData icon,
  required String title,
  required String subtitle,
  required VoidCallback onTap,
}) {
  return InkWell(
    borderRadius: BorderRadius.circular(14),
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(icon, color: cs.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
        ],
      ),
    ),
  );
}

void _showInfo(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text("OK"),
        ),
      ],
    ),
  );
}

void _confirmDanger(
  BuildContext context, {
  required ColorScheme cs,
  required String title,
  required String message,
  required VoidCallback onConfirm,
}) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            Navigator.of(dialogContext).pop();
            onConfirm();
          },
          child: const Text("Confirm"),
        ),
      ],
    ),
  );
}
