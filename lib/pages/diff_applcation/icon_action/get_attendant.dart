import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const GetAttendance());
}

/* ===================== APP ===================== */
class GetAttendance extends StatelessWidget {
  const GetAttendance({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Geo Attendance',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        fontFamily: 'MomoTrustDisplay',
      ),
      home: const AttendancePage(),
    );
  }
}

/* ===================== TEXT SCALE ===================== */
class AppText {
  static double title(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return (w * 0.03).clamp(18.0, 32.0);
  }
}

/* ===================== ATTENDANCE PAGE ===================== */
class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  String statusMessage = "Press the button to check attendance";
  bool isChecking = false;

  bool? isLocationAllowed; // 🔴🟢 show ON / OFF

  final double officeLatitude = 11.5671548;
  final double officeLongitude = 104.8958224;
  final double allowedDistanceInMeters = 50;

  @override
  void initState() {
    super.initState();
    loadLocationStatus();
  }

  Future<void> loadLocationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isLocationAllowed = prefs.getBool('shareLocation') ?? true;
    });
  }

  Future<void> checkLocation() async {
    setState(() {
      isChecking = true;
      statusMessage = "Checking location...";
    });

    final prefs = await SharedPreferences.getInstance();
    final shareLocation = prefs.getBool('shareLocation') ?? true;

    if (!shareLocation) {
      setState(() {
        statusMessage = "Location is OFF in Privacy settings ❌";
        isChecking = false;
      });
      return;
    }

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        statusMessage = "Location services are disabled ❌";
        isChecking = false;
      });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      setState(() {
        statusMessage = "Location permission denied ❌";
        isChecking = false;
      });
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      double distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        officeLatitude,
        officeLongitude,
      );

      if (distance <= allowedDistanceInMeters) {
        final now = DateTime.now();
        final isLate = now.hour > 9 || (now.hour == 9 && now.minute > 0);

        setState(() {
          statusMessage = isLate
              ? "Checked ✅ You are LATE today"
              : "Checked ✅ You are PRESENT";
        });
      } else {
        setState(() {
          statusMessage = "You are not at the workplace ❌";
        });
      }
    } catch (_) {
      setState(() {
        statusMessage = "Failed to get location ❌";
      });
    }

    setState(() => isChecking = false);
  }

  Color getStatusColor() {
    if (statusMessage.contains("PRESENT")) return Colors.green;
    if (statusMessage.contains("LATE")) return Colors.orange;
    if (statusMessage.contains("❌")) return Colors.red;
    return Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
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
                  Text(
                    'Get your attendance',
                    style: TextStyle(fontSize: AppText.title(context)),
                  ),
                  const Spacer(),
                  const VerticalDivider(thickness: 2),
                  const Icon(Icons.person, size: 50),
                  const SizedBox(width: 8),
                  const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Text('Name'), Text('@name')],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 75),

            Padding(
              padding: EdgeInsets.all(isMobile ? 16 : 40),
              child: Card(
                color: Colors.grey[300],
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 60,
                        color: Colors.blue,
                      ),

                      const SizedBox(height: 8),

                      // ✅ ONLY ADDED TEXT
                      Text(
                        isLocationAllowed == null
                            ? "Checking location status..."
                            : isLocationAllowed!
                            ? "Location: ON"
                            : "Location: OFF",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isLocationAllowed == true
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),

                      const SizedBox(height: 20),

                      Text(
                        statusMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isMobile ? 18 : 20,
                          fontWeight: FontWeight.bold,
                          color: getStatusColor(),
                        ),
                      ),

                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isChecking ? null : checkLocation,
                          child: isChecking
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text("Check Attendance"),
                        ),
                      ),

                      const SizedBox(height: 12),
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

/* ===================== SECURITY / PRIVACY PAGE ===================== */
class SecuritySite extends StatefulWidget {
  const SecuritySite({super.key});

  @override
  State<SecuritySite> createState() => _SecuritySiteState();
}

class _SecuritySiteState extends State<SecuritySite> {
  bool? shareLocation;

  @override
  void initState() {
    super.initState();
    loadSetting();
  }

  Future<void> loadSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      shareLocation = prefs.getBool('shareLocation') ?? true;
    });
  }

  Future<void> saveSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('shareLocation', value);
  }

  @override
  Widget build(BuildContext context) {
    if (shareLocation == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Privacy")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: shareLocation! ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "Share Location for attendance tracking",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Switch(
                value: shareLocation!,
                onChanged: (value) async {
                  setState(() => shareLocation = value);
                  await saveSetting(value);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
