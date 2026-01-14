import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const GetAttendance());
}

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

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  String statusMessage = "Press the button to check attendance";
  bool isChecking = false;

  // Office location
  final double officeLatitude = 11.5671548;
  final double officeLongitude = 104.8958224;
  final double allowedDistanceInMeters = 50;

  Future<void> checkLocation() async {
    setState(() {
      isChecking = true;
      statusMessage = "Checking location...";
    });

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

        // Late after 9:00 AM
        final isLate = now.hour > 9 || (now.hour == 9 && now.minute > 0);

        setState(() {
          statusMessage = isLate
              ? "Checked ✅ You are LATE today"
              : "Checked ✅ You are PRESENT";
        });
      } else {
        setState(() {
          statusMessage = "You are not at the workplace ❌\nDistance too far";
        });
      }
    } catch (e) {
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
    final bool isMobile = width < 600;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.all(8),
              height: 166,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[300],
              ),
              child: Row(
                children: <Widget>[
                  Text(
                    'Get your attendance',
                    style: TextStyle(fontSize: AppText.title(context)),
                  ),
                  Spacer(),
                  VerticalDivider(thickness: 2, color: Colors.grey),
                  Icon(Icons.person, size: 50),
                  SizedBox(
                    height: 50,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[Text('Name'), Text('@name')],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 75),
            Center(
              child: Padding(
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_on, size: 60, color: Colors.blue),
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
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: isChecking
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    "Check Attendance",
                                    style: TextStyle(fontSize: 16),
                                  ),
                          ),
                        ),
                      ],
                    ),
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
