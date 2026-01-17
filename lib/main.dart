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
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Center(child: Text(widget.title)),
      ),
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

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        children: <Widget>[
          // Left side of the screen (1/3 width)
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.blue[100],
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(Application_Logo),
                    const SizedBox(height: 20),
                    const Text(
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
                  ],
                ),
              ),
            ),
          ),

          // Right side of the screen (2/3 width)
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.blue,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      'Geo Attendant Website',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'MomoTrustDisplay',
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: const Text(
                        'Geo_Attendant is a location-based attendance system designed to record student attendance using their live geographic location. The system verifies a student’s presence by checking whether their real-time location falls within a predefined area, such as a classroom or campus, ensuring that attendance is marked only when the student is physically present. This approach helps reduce proxy attendance and improves accuracy and reliability compared to traditional manual methods. By leveraging location technology, Geo_Attendant provides a more efficient, transparent, and secure way for students to register their attendance in real time.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'MomoTrustDisplay',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
