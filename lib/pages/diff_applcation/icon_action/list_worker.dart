import 'package:flutter/material.dart';

void main() {
  runApp(const ListWorkerSite());
}

class ListWorkerSite extends StatelessWidget {
  const ListWorkerSite({super.key});
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
    return (w * 0.035).clamp(24.0, 48.0);
  }

  static double huge(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return (w * 0.11).clamp(120.0, 180.0);
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, String>> data = [
    {
      "ID": "1",
      "Name": "John Doe",
      "Department": 'IT',
      "Phone": "012345678",
      "CheckIn": "12:23",
      "CheckOut": "1:23", //
    },
    {
      "ID": "2",
      "Name": "Jane Smith",
      "Department": 'Sale',
      "Phone": "098765432",
      "CheckIn": "12:23",
      "CheckOut": "2:23", //
    },
    {
      "ID": "3",
      "Name": "Alex Kim",
      "Department": 'Legal',
      "Phone": "012987345",
      "CheckIn": "12:23",
      "CheckOut": "3:23", //
    },
  ];
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
                  Text(
                    'List Workers',
                    style: TextStyle(fontSize: AppText.title(context)),
                  ),
                  Spacer(),
                  VerticalDivider(thickness: 2, color: Colors.grey),
                  Icon(Icons.person, size: AppIcon.large(context)),
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
            SizedBox(height: 50),
            SizedBox(
              height: 1000,
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(16),
                  margin: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[300],
                  ),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(flex: 1, child: Text('ID')),
                          Expanded(flex: 2, child: Text('Name')),
                          Expanded(flex: 3, child: Text('Department')),
                          Expanded(flex: 3, child: Text('Phone number')),
                          Expanded(flex: 2, child: Text('Check-in')),
                          Expanded(flex: 2, child: Text('Check-out')),
                          Expanded(
                            flex: 2,
                            child: OutlinedButton(
                              onPressed: () {},
                              child: Text('Date'),
                            ),
                          ),
                        ],
                      ),
                      Divider(thickness: 2, color: Colors.grey[400]),
                      Expanded(
                        child: ListView.builder(
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 8,
                              ),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 1,
                                    child: Text('${data[index]['ID']}'),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text('${data[index]['Name']}'),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text('${data[index]['Department']}'),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text('${data[index]['Phone']}'),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text('${data[index]['CheckIn']}'),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text('${data[index]['CheckOut']}'),
                                  ),
                                  Expanded(flex: 2, child: Text('Date')),
                                ],
                              ),
                            );
                          },
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
