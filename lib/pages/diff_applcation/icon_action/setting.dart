import 'package:flutter/material.dart';

void main() {
  runApp(const SettingSite());
}

class SettingSite extends StatelessWidget {
  const SettingSite({super.key});
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
    return Scaffold();
  }
}
