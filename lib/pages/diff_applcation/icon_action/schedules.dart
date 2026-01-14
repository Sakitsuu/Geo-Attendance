import 'package:flutter/material.dart';

void main() {
  runApp(const SchedulesSite());
}

class SchedulesSite extends StatelessWidget {
  const SchedulesSite({super.key});
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
  @override
  Widget build(BuildContext context) {
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
                  Text('Schedule', style: TextStyle(fontSize: 32)),
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
          ],
        ),
      ),
    );
  }
}
