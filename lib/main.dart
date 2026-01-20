import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geo_attendance_new_ui/pages/login_page.dart';
import 'package:geo_attendance_new_ui/pages/register_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, //
  ).then((_) {
    print("Firebase Initialized");
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Geo Attendant',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        fontFamily: 'MomoTrustDisplay',
      ),
      home: const MyHomePage(title: 'Geo Attendant'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  FirebaseFirestore db = FirebaseFirestore.instance;

  // @override
  // void initState() {
  //   super.initState();
  //   init();
  // }

  // void init() async {
  //   db.collection("collection_credentials").doc("init").set({});
  //   db.collection("collection_credentials").add({
  //     "username": "admin",
  //     "password": "admin",
  //   });
  //   db.collection("collection_credentials").add({
  //     "username": "user",
  //     "password": "pass",
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isMobile(context) ? const MobileLayout() : const DesktopLayout(),
    );
  }
}

class MobileLayout extends StatelessWidget {
  const MobileLayout({super.key});

  final String ApplicationLogo = 'assets/geo_attendance_logo.png';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: <Widget>[
            Container(
              color: Colors.blue[100],
              child: Column(
                children: <Widget>[
                  Image.asset(ApplicationLogo),
                  SizedBox(height: 20),
                  Text(
                    'Welcome to Geo Attendant',
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'MomoTrustDisplay',
                    ),
                  ),
                  SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () {
                      // Login button action
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    child: Text('Login'),
                  ),
                  SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () {
                      // Sign up button action
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpPage()),
                      );
                    },
                    child: Text('Sign up'),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
            Divider(thickness: 1, color: Colors.black),
            Container(
              color: Colors.blue,
              child: Column(
                children: <Widget>[
                  Text(
                    'Geo Attendant Website',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.teal,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'MomoTrustDisplay',
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      'Geo_Attendant is a location-based attendance management system that utilizes real-time geolocation data to authenticate employee presence at designated workplaces. The system determines attendance eligibility by continuously or periodically comparing the employee’s live geographic coordinates with predefined geofenced areas, such as offices, industrial facilities, or assigned job sites. Attendance is recorded only when the detected location satisfies the spatial constraints of the authorized work zone. This mechanism effectively mitigates proxy attendance and location spoofing, thereby enhancing the accuracy, integrity, and reliability of attendance records. By integrating geolocation services with automated verification processes, Geo_Attendant enables secure, transparent, and real-time attendance tracking for workplace environments.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'MomoTrustDisplay',
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DesktopLayout extends StatelessWidget {
  const DesktopLayout({super.key});

  final String Application_Logo = 'geo_attendance_logo.png';
  final String Background = 'assets/Welcome_home_page.png';
  final String Phone_desgin = 'assets/Welcome_home_page_copy.png';

  @override
  Widget build(BuildContext context) {
    return BlueGradientBackground(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
          child: Row(
            children: <Widget>[
              // Left side of the screen (1/3 width)
              Expanded(
                flex: 2,
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Text(
                        'Geo Attendance',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'MomoTrustDisplay',
                        ),
                      ),
                      const Text(
                        'Location-based attendance for Company',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 20),

                      Container(
                        width: 520, // control card width
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: <Widget>[
                                Image.asset(
                                  Application_Logo,
                                  height: 90,
                                  width: 90,
                                ),
                                const SizedBox(width: 16),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        'Welcome to Geo Attendant',
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.white,
                                          fontFamily: 'MomoTrustDisplay',
                                        ),
                                      ),
                                      Text(
                                        'Location-based attendance for Company',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => LoginPage(),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: Colors.blue,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                    ),
                                    child: const Text('Login'),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SignUpPage(),
                                        ),
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      side: const BorderSide(
                                        color: Colors.white,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                    ),
                                    child: const Text('Sign up'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 25),
                      SizedBox(
                        width: 300,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(height: 10),
                            Row(
                              children: <Widget>[
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.grey[200],
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Prevent proxy employees',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: <Widget>[
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.grey[200],
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Real-time location verification',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: <Widget>[
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.grey[200],
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Faster check-in, accurate reports',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Right side of the screen (2/3 width)
              Expanded(
                flex: 1,
                child: Center(
                  child: Image.asset(
                    Phone_desgin,
                    width: 520, // adjust as you like
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BlueGradientBackground extends StatelessWidget {
  final Widget child;
  const BlueGradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradient background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1E4ED8), // deep blue
                Color(0xFF1F8EF1), // lighter blue
              ],
            ),
          ),
        ),

        // Decorative circles
        Positioned(top: 100, left: -80, child: _circle(180, 0.08)),
        Positioned(bottom: 120, right: -60, child: _circle(160, 0.06)),
        Positioned(top: -50, right: 100, child: _circle(120, 0.05)),

        // Page content
        child,
      ],
    );
  }

  Widget _circle(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(opacity),
      ),
    );
  }
}
