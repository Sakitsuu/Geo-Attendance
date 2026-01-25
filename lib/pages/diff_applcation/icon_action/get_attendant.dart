import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GetAttendance extends StatefulWidget {
  const GetAttendance({super.key});

  @override
  State<GetAttendance> createState() => _GetAttendanceState();
}

class AppText {
  static double title(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return (w * 0.03).clamp(18.0, 32.0);
  }
}

class _GetAttendanceState extends State<GetAttendance> {
  String statusMessage = "Press the button to check attendance";
  bool isChecking = false;

  bool? isLocationAllowed;

  // Office config
  final double officeLatitude = 11.5671548;
  final double officeLongitude = 104.8958224;
  final double allowedDistanceInMeters = 50;

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // Firestore
  final CollectionReference attendanceRef = FirebaseFirestore.instance
      .collection('attendance');

  // User profile (from Auth + Firestore)
  bool loadingUser = true;
  String workerId = "";
  String workerName = "";
  String department = "";
  String phone = "";

  @override
  void initState() {
    super.initState();
    loadLocationStatus();
    _loadUserProfile();
  }

  Future<void> loadLocationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isLocationAllowed = prefs.getBool('shareLocation') ?? true;
    });
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        setState(() {
          workerName = "Not logged in";
          loadingUser = false;
        });
        return;
      }

      workerId = user.uid;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(workerId)
          .get();

      final data = doc.data() ?? {};

      setState(() {
        workerName = (data['name'] ?? user.email ?? 'Unknown').toString();
        department = (data['department'] ?? '').toString();
        phone = (data['phone'] ?? '').toString();
        loadingUser = false;
      });
    } catch (_) {
      setState(() {
        workerName = "Failed to load user";
        loadingUser = false;
      });
    }
  }

  String _dateKey(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return "$y-$m-$day";
  }

  Future<void> _saveAttendance({required bool isLate}) async {
    if (workerId.isEmpty) {
      setState(() => statusMessage = "User not logged in ❌");
      return;
    }

    final today = _dateKey(DateTime.now());
    final docId = "${workerId}_$today";
    final docRef = attendanceRef.doc(docId);

    final snap = await docRef.get();

    // 1) First time today => check-in
    if (!snap.exists) {
      await docRef.set({
        'workerId': workerId,
        'name': workerName,
        'department': department,
        'phone': phone,
        'date': today,
        'status': isLate ? 'LATE' : 'PRESENT',
        'checkIn': FieldValue.serverTimestamp(),
        'checkOut': null,
        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        statusMessage = isLate
            ? "Checked ✅ You are LATE today (Check-in saved)"
            : "Checked ✅ You are PRESENT (Check-in saved)";
      });
      return;
    }

    // 2) Second time today => check-out (only if not already checked out)
    final data = snap.data() as Map<String, dynamic>? ?? {};
    final alreadyCheckedOut = data['checkOut'] != null;

    if (alreadyCheckedOut) {
      setState(() => statusMessage = "You already checked-out today ✅");
      return;
    }

    await docRef.update({
      'checkOut': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    setState(() => statusMessage = "Checked ✅ Check-out saved");
  }

  Future<void> checkLocation() async {
    if (loadingUser) {
      setState(() => statusMessage = "Loading user... please wait");
      return;
    }

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

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        statusMessage = "Location services are disabled ❌";
        isChecking = false;
      });
      return;
    }

    var permission = await Geolocator.checkPermission();
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
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        officeLatitude,
        officeLongitude,
      );

      if (distance <= allowedDistanceInMeters) {
        final now = DateTime.now();
        final isLate = now.hour > 9 || (now.hour == 9 && now.minute > 0);
        await _saveAttendance(isLate: isLate);
      } else {
        setState(() => statusMessage = "You are not at the workplace ❌");
      }
    } catch (_) {
      setState(() => statusMessage = "Failed to get location ❌");
    }

    setState(() => isChecking = false);
  }

  Color getStatusColor(ColorScheme cs) {
    if (statusMessage.contains("PRESENT")) return Colors.green;
    if (statusMessage.contains("LATE")) return Colors.orange;
    if (statusMessage.contains("❌")) return Colors.red;
    return cs.onSurface; // ✅ was Colors.black
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
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
                    'Get your attendance',
                    style: TextStyle(
                      fontSize: AppText.title(context),
                      color: cs.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  VerticalDivider(
                    thickness: 2,
                    width: 40, // ✅ same as Graphic
                    color: cs.outlineVariant,
                  ),

                  // Name block EXACT same structure as Graphic
                  const Icon(Icons.person, size: 50),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 50,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text('Name'),
                        StreamBuilder<DocumentSnapshot>(
                          stream: _db
                              .collection('users')
                              .doc(_auth.currentUser?.uid)
                              .snapshots(),
                          builder: (context, snap) {
                            if (!snap.hasData || !snap.data!.exists) {
                              return const Text('-');
                            }
                            final m = snap.data!.data() as Map<String, dynamic>;
                            return Text((m['name'] ?? '-').toString());
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 75),

            Padding(
              padding: EdgeInsets.all(isMobile ? 16 : 40),
              child: Card(
                color: cs.surfaceContainerHighest,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: cs.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(Icons.location_on, size: 60, color: cs.primary),
                      const SizedBox(height: 8),

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
                          color: getStatusColor(cs),
                        ),
                      ),

                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: isChecking ? null : checkLocation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: cs.primary,
                            foregroundColor: cs.onPrimary,
                            disabledBackgroundColor: cs.surfaceContainerHighest,
                            disabledForegroundColor: cs.onSurfaceVariant,
                          ),
                          child: isChecking
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text("Check Attendance"),
                        ),
                      ),
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
