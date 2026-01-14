import 'package:flutter/material.dart';
import 'package:geo_attendance_new_ui/pages/diff_applcation/application_manager.dart';
import 'package:geo_attendance_new_ui/pages/diff_applcation/application_worker.dart';

void main() {
  runApp(const LoginPage());
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});
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

  TextEditingController idController = TextEditingController();
  TextEditingController pwController = TextEditingController();
  TextEditingController verifyPwController = TextEditingController();

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
                'Login Page',
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
                      onChanged: (value) {
                        if (id.isEmpty) {
                          setState(() {
                            invalidID = 'Invalid ID';
                          });
                        } else {
                          setState(() {
                            id = value;
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
                      controller: pwController,
                      decoration: InputDecoration(labelText: 'Password'),
                      onChanged: (value) {
                        if (pw.length < 6 || pw.length > 12 || pw.isEmpty) {
                          setState(() {
                            invalidPW = 'Password invalid';
                          });
                        } else {
                          setState(() {
                            pw = value;
                            invalidPW = 'Valid Password';
                          });
                        }
                      },
                    ),
                    Text('Status: $invalidPW'),
                  ],
                ),
              ),

              SizedBox(height: 30),
              OutlinedButton(
                onPressed: () {
                  final enteredId = idController.text.trim();
                  final enteredPw = pwController.text.trim();
                  // Handle id and password
                  if (enteredId == 'Manager' && enteredPw == 'Manager123') {
                    // Process to application with manager features
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ManagerPage()),
                    );
                  } else {
                    // Process to application with worker features
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => WorkerPage()),
                    );
                  }
                },
                child: Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
