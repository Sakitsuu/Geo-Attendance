import 'package:flutter/material.dart';

void main() {
  runApp(const DashboardSite());
}

class DashboardSite extends StatelessWidget {
  const DashboardSite({super.key});
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

class _MyHomePageState extends State<MyHomePage> {
  late String today;
  late String currentTime;

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    today = "${now.day}-${now.month}-${now.year}";
    currentTime = _formatTime(now);
  }

  String _formatTime(DateTime now) {
    return "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
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
                      'Dashboard',
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
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: EdgeInsets.all(16),
                      margin: EdgeInsets.all(8),
                      height: 547,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[300],
                      ),
                      child: Column(
                        children: <Widget>[
                          Row(
                            spacing: 10,
                            children: <Widget>[
                              Icon(
                                Icons.sunny,
                                size: AppIcon.huge(context),
                                color: Colors.grey[500],
                              ),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Time: $currentTime',
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: AppText.subtitle(context),
                                      ),
                                    ),
                                    Text(
                                      'Realtime insight',
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: AppText.body(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Flexible(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  'Today: ',
                                  style: TextStyle(
                                    fontSize: AppText.title(context),
                                  ),
                                ),
                                Text(
                                  '$today',
                                  style: TextStyle(
                                    fontSize: AppText.subtitle(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      spacing: 10,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(16),
                          margin: EdgeInsets.all(8),
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey[300],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      '452',
                                      style: TextStyle(
                                        fontSize: AppText.title(context),
                                      ),
                                    ),
                                  ),
                                  Spacer(),
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.all(4),
                                      margin: EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.grey[100],
                                      ),
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.blue,
                                        size: AppIcon.medium(context),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'Total Employees',
                                style: TextStyle(
                                  fontSize: AppText.body(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(16),
                          margin: EdgeInsets.all(8),
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey[300],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      '62',
                                      style: TextStyle(
                                        fontSize: AppText.title(context),
                                      ),
                                    ),
                                  ),
                                  Spacer(),
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.all(4),
                                      margin: EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.grey[100],
                                      ),
                                      child: Icon(
                                        Icons.alarm_off,
                                        color: Colors.blue,
                                        size: AppIcon.medium(context),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'Late Arrival',
                                style: TextStyle(
                                  fontSize: AppText.body(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      spacing: 10,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(16),
                          margin: EdgeInsets.all(8),
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey[300],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      '360',
                                      style: TextStyle(
                                        fontSize: AppText.title(context),
                                      ),
                                    ),
                                  ),
                                  Spacer(),
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.all(4),
                                      margin: EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.grey[100],
                                      ),
                                      child: Icon(
                                        Icons.alarm,
                                        color: Colors.blue,
                                        size: AppIcon.medium(context),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'On Time',
                                style: TextStyle(
                                  fontSize: AppText.body(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(16),
                          margin: EdgeInsets.all(8),
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey[300],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      '62',
                                      style: TextStyle(
                                        fontSize: AppText.title(context),
                                      ),
                                    ),
                                  ),
                                  Spacer(),
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.all(4),
                                      margin: EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.grey[100],
                                      ),
                                      child: Icon(
                                        Icons.outbond_outlined,
                                        color: Colors.blue,
                                        size: AppIcon.medium(context),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'Early Depatures',
                                style: TextStyle(
                                  fontSize: AppText.body(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      spacing: 10,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(16),
                          margin: EdgeInsets.all(8),
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey[300],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      '30',
                                      style: TextStyle(
                                        fontSize: AppText.title(context),
                                      ),
                                    ),
                                  ),
                                  Spacer(),
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.all(4),
                                      margin: EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.grey[100],
                                      ),
                                      child: Icon(
                                        Icons.person_off,
                                        color: Colors.blue,
                                        size: AppIcon.medium(context),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'Absent',
                                style: TextStyle(
                                  fontSize: AppText.body(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(16),
                          margin: EdgeInsets.all(8),
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey[300],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      '42',
                                      style: TextStyle(
                                        fontSize: AppText.title(context),
                                      ),
                                    ),
                                  ),
                                  Spacer(),
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.all(4),
                                      margin: EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.grey[100],
                                      ),
                                      child: Icon(
                                        Icons.date_range,
                                        size: AppIcon.medium(context),
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'Time Off',
                                style: TextStyle(
                                  fontSize: AppText.body(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
