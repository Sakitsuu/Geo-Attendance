import 'package:flutter/material.dart';

void main() {
  runApp(const ProfileSite());
}

class ProfileSite extends StatelessWidget {
  const ProfileSite({super.key});
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
                      'Profile',
                      style: TextStyle(fontSize: AppText.title(context)),
                    ),
                    VerticalDivider(thickness: 2, color: Colors.grey),

                    SizedBox(
                      height: 75,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Good morning, name!',
                            style: TextStyle(
                              fontSize: AppText.subtitle(context),
                            ),
                          ),
                          Text(
                            'Here\'s your status',
                            style: TextStyle(
                              fontSize: AppText.body(context),
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    Icon(Icons.person, size: AppIcon.large(context)),
                  ],
                ),
              ),
              SizedBox(height: 50),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(16),
                      margin: EdgeInsets.all(8),
                      height: 257,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[300],
                      ),
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  'Attendance Rate',
                                  style: TextStyle(
                                    fontSize: AppText.title(context),
                                  ),
                                ),
                              ),
                              Spacer(),
                              Icon(Icons.alarm, size: AppIcon.medium(context)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(16),
                      margin: EdgeInsets.all(8),
                      height: 257,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[300],
                      ),
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  'Engagement Rate',
                                  style: TextStyle(
                                    fontSize: AppText.title(context),
                                  ),
                                ),
                              ),
                              Spacer(),
                              Icon(
                                Icons.arrow_outward_sharp,
                                size: AppIcon.medium(context),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.all(8),
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[300],
                ),
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.error_outline,
                            size: AppIcon.small(context),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Pending Approvals',
                            style: TextStyle(fontSize: AppText.title(context)),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(16),
                      margin: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[200],
                      ),
                      child: Row(
                        children: <Widget>[
                          Text('Time-off Request'),
                          Spacer(),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Request for time-off'),
                                    content: const Text(
                                      'Fill your reasons for time-off',
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          // Save application of time-off request
                                        },
                                        child: Text('Confirm'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Text('Request'),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(16),
                      margin: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[200],
                      ),
                      child: Row(
                        children: <Widget>[
                          Text('Leave Request'),
                          Spacer(),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Request for leave'),
                                    content: const Text(
                                      'Fill your reasons for leave',
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          // Save application of time-off request
                                        },
                                        child: Text('Confirm'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Text('Request'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
