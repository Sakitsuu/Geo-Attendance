import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool shareLocation = true;

  @override
  void initState() {
    super.initState();
    _loadPrivacySettings();
  }

  Future<void> _loadPrivacySettings() async {
    final prefs = await SharedPreferences.getInstance();
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

    // If user turns ON, request permission
    if (value) {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      } else if (permission == LocationPermission.deniedForever) {
        await Geolocator.openAppSettings();
      }
      setState(() {}); // refresh permission badge
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _topHeader(context, title: 'Privacy'),
            const SizedBox(height: 20),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _sectionCard(
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

                              return Container(
                                margin: const EdgeInsets.only(top: 10),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      color: (!shareLocation)
                                          ? Colors.grey
                                          : (allowed
                                                ? Colors.green
                                                : Colors.red),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "Share Location",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            !shareLocation
                                                ? "Turn this ON if you want to use attendance checking."
                                                : (allowed
                                                      ? "Location permission is enabled. Attendance can verify your location."
                                                      : "Permission is not enabled yet. Tap 'Open Location Settings'."),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black54,
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
                      title: "Data & Permissions",
                      icon: Icons.admin_panel_settings_outlined,
                      child: Column(
                        children: [
                          _actionTile(
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
                            icon: Icons.delete_outline,
                            title: "Delete Activity History",
                            subtitle: "Remove saved activity logs.",
                            onTap: () => _confirmDanger(
                              context,
                              title: "Delete Activity History?",
                              message:
                                  "This action cannot be undone. Continue?",
                              onConfirm: () => Navigator.pop(context),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    _sectionCard(
                      title: "Legal",
                      icon: Icons.article_outlined,
                      child: Column(
                        children: [
                          _actionTile(
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

/// ✅ Shared UI widgets (header/cards/actions)
Widget _topHeader(BuildContext context, {required String title}) {
  return Container(
    padding: const EdgeInsets.all(16),
    margin: const EdgeInsets.all(8),
    height: 120,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      color: Colors.grey[300],
    ),
    child: Row(
      children: <Widget>[
        Text(title, style: TextStyle(fontSize: AppText.title(context))),
        const Spacer(),
        const VerticalDivider(thickness: 2, color: Colors.grey),
        const Icon(Icons.person, size: 50),
        const SizedBox(width: 8),
        const SizedBox(
          height: 50,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[Text('Name'), Text('@name')],
          ),
        ),
      ],
    ),
  );
}

Widget _sectionCard({
  required String title,
  required IconData icon,
  required Widget child,
}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.grey[200],
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.blue),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    ),
  );
}

void _showInfo(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("OK"),
        ),
      ],
    ),
  );
}

void _confirmDanger(
  BuildContext context, {
  required String title,
  required String message,
  required VoidCallback onConfirm,
}) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: onConfirm,
          child: const Text("Confirm"),
        ),
      ],
    ),
  );
}
