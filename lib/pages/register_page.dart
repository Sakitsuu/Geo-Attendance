import 'package:flutter/material.dart';
import 'package:geo_attendance_new_ui/main.dart';
import 'package:geo_attendance_new_ui/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(const SignUpPage());
}

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        fontFamily: 'MomoTrustDisplay',
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  String Application_Logo = 'geo_attendance_logo.png';

  String id = '';
  String invalidID = '';

  String pw = '';
  String invalidPW = '';

  String verify_pw = '';
  String invalid_verifyPW = '';
  String invalidEmail = '';

  TextEditingController idController = TextEditingController();
  TextEditingController pwController = TextEditingController();
  TextEditingController verifyPwController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String Status = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              Image.asset(Application_Logo),
              Text(
                'Sign Up Page',
                style: TextStyle(fontSize: 20, fontFamily: 'MomoTrustDisplay'),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: 300,
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: idController,
                      decoration: InputDecoration(labelText: 'ID'),
                      onChanged: (id) {
                        if (id.isEmpty) {
                          setState(() {
                            invalidID = 'Invalid ID';
                          });
                        } else {
                          setState(() {
                            invalidID = 'Valid ID';
                          });
                        }
                      },
                    ),
                    Text('Status: $invalidID'),
                  ],
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: 300,
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (email) {
                        final ok = RegExp(
                          r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                        ).hasMatch(email.trim());
                        setState(
                          () => invalidEmail = ok
                              ? 'Valid Email'
                              : 'Invalid Email',
                        );
                      },
                    ),
                    Text('Status: $invalidEmail'),
                  ],
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: 300,
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: pwController,
                      decoration: InputDecoration(labelText: 'Password'),
                      onChanged: (pw) {
                        if (pw.length < 6 || pw.length > 12 || pw.isEmpty) {
                          setState(() {
                            invalidPW = 'Password invalid';
                          });
                        } else {
                          setState(() {
                            invalidPW = 'Valid Password';
                          });
                        }
                      },
                    ),
                    Text('Status: $invalidPW'),
                  ],
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: 300,
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: verifyPwController,
                      decoration: InputDecoration(labelText: 'Verify Password'),
                      onChanged: (verify_pw) {
                        if (verify_pw != pwController.text) {
                          setState(() {
                            invalid_verifyPW = 'Passwords do not match';
                          });
                        } else {
                          setState(() {
                            invalid_verifyPW = 'Passwords match';
                          });
                        }
                      },
                    ),
                    Text('Status: $invalid_verifyPW'),
                  ],
                ),
              ),
              SizedBox(height: 30),
              OutlinedButton(
                onPressed: () async {
                  // Handle id and password
                  if (invalidID == 'Valid ID' &&
                      invalidPW == 'Valid Password' &&
                      invalid_verifyPW == 'Passwords match') {
                    // Process to application after successful sign up
                    setState(() {
                      Status = 'Signing Up...';
                    });

                    try {
                      // 1️⃣ Create Firebase Auth user
                      UserCredential
                      user = await _auth.createUserWithEmailAndPassword(
                        email:
                            '${idController.text.trim()}@geo.com', // Using ID as email placeholder
                        password: pwController.text.trim(),
                      );

                      // 2️⃣ Save user info to Firestore
                      await _firestore
                          .collection('users')
                          .doc(user.user!.uid)
                          .set({
                            'id': idController.text.trim(),
                            'createdAt': FieldValue.serverTimestamp(),
                          });

                      // 3️⃣ Success - navigate to login
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Sign Up Successful!')),
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MyApp()),
                      );
                    } catch (e) {
                      setState(() {
                        Status = 'Sign Up Failed: $e';
                      });
                    }
                  } else {
                    // Show error or prompt user to correct inputs
                    setState(() {
                      Status =
                          'Unable to Sign Up. Please check your id and password again.';
                    });
                  }
                },
                child: Text('Sign Up'),
              ),
              Text('$Status', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ),
    );
  }
}
