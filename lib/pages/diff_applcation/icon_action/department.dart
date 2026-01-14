import 'package:flutter/material.dart';

void main() {
  runApp(const DepartmentSite());
}

class DepartmentSite extends StatelessWidget {
  const DepartmentSite({super.key});
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
                      'Department',
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
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: EdgeInsets.all(12),
                      margin: EdgeInsets.all(8),
                      height: 514,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[300],
                      ),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: <Widget>[
                                Expanded(
                                  flex: 1,
                                  child: Row(
                                    children: <Widget>[
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        margin: const EdgeInsets.all(8),
                                        height: 250,
                                        width: 250,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          color: Colors.grey[100],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Icon(
                                              Icons.bar_chart_rounded,
                                              size: AppIcon.large(context),
                                            ),
                                            SizedBox(height: 10),
                                            Text('Sale'),
                                            Divider(thickness: 2),
                                            Text(
                                              'Total Employees: 40',
                                              style: TextStyle(
                                                color: Colors.blue,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Spacer(),
                                      Container(
                                        padding: EdgeInsets.all(16),
                                        margin: EdgeInsets.all(8),
                                        height: 250,
                                        width: 250,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          color: Colors.grey[100],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Icon(
                                              Icons.computer,
                                              size: AppIcon.large(context),
                                            ),
                                            SizedBox(height: 10),
                                            Text('IT'),
                                            Divider(
                                              thickness: 2,
                                              color: Colors.grey[500],
                                            ),
                                            Text(
                                              'Total Employees: 60',
                                              style: TextStyle(
                                                color: Colors.blue,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Spacer(),
                                      Container(
                                        padding: EdgeInsets.all(16),
                                        margin: EdgeInsets.all(8),
                                        height: 250,
                                        width: 250,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          color: Colors.grey[100],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Icon(
                                              Icons.monetization_on_outlined,
                                              size: AppIcon.large(context),
                                            ),
                                            SizedBox(height: 10),
                                            Text('Finance'),
                                            Divider(
                                              thickness: 2,
                                              color: Colors.grey[500],
                                            ),
                                            Text(
                                              'Total Employees: 86',
                                              style: TextStyle(
                                                color: Colors.blue,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Row(
                                    children: <Widget>[
                                      Container(
                                        padding: EdgeInsets.all(16),
                                        margin: EdgeInsets.all(8),
                                        height: 250,
                                        width: 250,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          color: Colors.grey[100],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Icon(
                                              Icons.gavel,
                                              size: AppIcon.large(context),
                                            ),
                                            SizedBox(height: 10),
                                            Text('Legal'),
                                            Divider(
                                              thickness: 2,
                                              color: Colors.grey[500],
                                            ),
                                            Text(
                                              'Total Employees: 60',
                                              style: TextStyle(
                                                color: Colors.blue,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Spacer(),
                                      Container(
                                        padding: EdgeInsets.all(16),
                                        margin: EdgeInsets.all(8),
                                        height: 250,
                                        width: 250,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          color: Colors.grey[100],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Icon(
                                              Icons.api,
                                              size: AppIcon.large(context),
                                            ),
                                            SizedBox(height: 10),
                                            Text('API'),
                                            Divider(
                                              thickness: 2,
                                              color: Colors.grey[500],
                                            ),
                                            Text(
                                              'Total Employees: 40',
                                              style: TextStyle(
                                                color: Colors.blue,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Spacer(),
                                      Container(
                                        padding: EdgeInsets.all(16),
                                        margin: EdgeInsets.all(8),
                                        height: 250,
                                        width: 250,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          color: Colors.grey[100],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Icon(
                                              Icons.group,
                                              size: AppIcon.large(context),
                                            ),
                                            SizedBox(height: 10),
                                            Text('Others'),
                                            Divider(
                                              thickness: 2,
                                              color: Colors.grey[500],
                                            ),
                                            Text(
                                              'Total Employees: 20',
                                              style: TextStyle(
                                                color: Colors.blue,
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
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: EdgeInsets.all(16),
                      margin: EdgeInsets.all(8),
                      height: 600,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[300],
                      ),
                      child: Container(
                        padding: EdgeInsets.all(16),
                        margin: EdgeInsets.all(8),
                        height: 500,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Flexible(
                                  child: Text(
                                    'All team leader of each department',
                                    style: TextStyle(
                                      fontSize: AppText.title(context),
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 40),
                            Row(
                              children: <Widget>[
                                Icon(
                                  Icons.bar_chart_rounded,
                                  size: AppIcon.small(context),
                                ),
                                SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    'Team leader of Sale: Mr. John De',
                                    style: TextStyle(
                                      fontSize: AppText.body(context),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              children: <Widget>[
                                Icon(
                                  Icons.computer,
                                  size: AppIcon.small(context),
                                ),
                                SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    'Team leader of IT: Mr. Jane Smith',
                                    style: TextStyle(
                                      fontSize: AppText.body(context),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              children: <Widget>[
                                Icon(
                                  Icons.monetization_on_outlined,
                                  size: AppIcon.small(context),
                                ),
                                SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    'Team leader of Finance: Mrs. Jane Jasmin',
                                    style: TextStyle(
                                      fontSize: AppText.body(context),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              children: <Widget>[
                                Icon(Icons.gavel, size: AppIcon.small(context)),
                                SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    'Team leader of Legal: Mr. Grafin Petter',
                                    style: TextStyle(
                                      fontSize: AppText.body(context),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              children: <Widget>[
                                Icon(Icons.api, size: AppIcon.small(context)),
                                SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    'Team leader of API: Mr. Jake Selly',
                                    style: TextStyle(
                                      fontSize: AppText.body(context),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              children: <Widget>[
                                Icon(
                                  Icons.people,
                                  size: AppIcon.small(context),
                                ),
                                SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    'Team leader of Legal: Mrs. Meg Griffin',
                                    style: TextStyle(
                                      fontSize: AppText.body(context),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
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
