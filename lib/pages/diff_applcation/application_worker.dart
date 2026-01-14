import 'package:flutter/material.dart';
import 'package:geo_attendance_new_ui/main.dart';
import 'package:geo_attendance_new_ui/pages/diff_applcation/icon_action/dashboard.dart';
import 'package:geo_attendance_new_ui/pages/diff_applcation/icon_action/department.dart';
import 'package:geo_attendance_new_ui/pages/diff_applcation/icon_action/graphic.dart';
import 'package:geo_attendance_new_ui/pages/diff_applcation/icon_action/list_worker.dart';
import 'package:geo_attendance_new_ui/pages/diff_applcation/icon_action/get_attendant.dart';
import 'package:geo_attendance_new_ui/pages/diff_applcation/icon_action/notifications.dart';
import 'package:geo_attendance_new_ui/pages/diff_applcation/icon_action/profile.dart';
import 'package:geo_attendance_new_ui/pages/diff_applcation/icon_action/schedules.dart';
import 'package:geo_attendance_new_ui/pages/diff_applcation/icon_action/security.dart';
import 'package:geo_attendance_new_ui/pages/diff_applcation/icon_action/setting.dart';
import 'package:geo_attendance_new_ui/pages/login_page.dart';

void main() {
  runApp(const WorkerPage());
}

class WorkerPage extends StatelessWidget {
  const WorkerPage({super.key});
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
  int selectedIndex = 2;

  List<bool> isSelected = [
    false,
    false,
    true,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
  ];

  final List<Widget> pages = [
    NotificationSite(),
    GetAttendance(),
    DashboardSite(),
    GraphicSite(),
    ProfileSite(),
    DepartmentSite(),
    ListWorkerSite(),
    SchedulesSite(),
    SettingSite(),
    SecuritySite(),
  ];

  void select(int index) {
    setState(() {
      selectedIndex = index;
      isSelected = [
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
      ];
      isSelected[index] = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      width: 50,
                      child: Column(
                        spacing: 275,
                        children: <Widget>[
                          SizedBox(
                            child: Column(
                              children: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      selectedIndex = 0;
                                      select(0);
                                    });
                                  },
                                  style: TextButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    backgroundColor: isSelected[0]
                                        ? Colors.blue
                                        : Colors.transparent,
                                  ),
                                  child: Icon(Icons.notifications),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      selectedIndex = 1;
                                      select(1);
                                    });
                                  },
                                  style: TextButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    backgroundColor: isSelected[1]
                                        ? Colors.blue
                                        : Colors.transparent,
                                  ),
                                  child: Icon(Icons.check),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            child: Column(
                              children: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    // Dachboard Site
                                    setState(() {
                                      selectedIndex = 2;
                                      select(2);
                                    });
                                  },
                                  style: TextButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    backgroundColor: isSelected[2]
                                        ? Colors.blue
                                        : Colors.transparent,
                                  ),
                                  child: const Icon(Icons.add_box_outlined),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // Graphic Site
                                    setState(() {
                                      selectedIndex = 3;
                                      select(3);
                                    });
                                  },
                                  style: TextButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    backgroundColor: isSelected[3]
                                        ? Colors.blue
                                        : Colors.transparent,
                                  ),
                                  child: const Icon(Icons.auto_graph),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // Profile Site
                                    setState(() {
                                      selectedIndex = 4;
                                      select(4);
                                    });
                                  },
                                  style: TextButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    backgroundColor: isSelected[4]
                                        ? Colors.blue
                                        : Colors.transparent,
                                  ),
                                  child: Icon(Icons.person),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // Department Site
                                    setState(() {
                                      selectedIndex = 5;
                                      select(5);
                                    });
                                  },
                                  style: TextButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    backgroundColor: isSelected[5]
                                        ? Colors.blue
                                        : Colors.transparent,
                                  ),
                                  child: Icon(Icons.schema_outlined),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // List Worker Site
                                    setState(() {
                                      selectedIndex = 6;
                                      select(6);
                                    });
                                  },
                                  style: TextButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    backgroundColor: isSelected[6]
                                        ? Colors.blue
                                        : Colors.transparent,
                                  ),
                                  child: Icon(Icons.grading_sharp),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      selectedIndex = 7;
                                      select(7);
                                    });
                                  },
                                  style: TextButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    backgroundColor: isSelected[7]
                                        ? Colors.blue
                                        : Colors.transparent,
                                  ),
                                  child: Icon(Icons.date_range),
                                ),
                                Divider(thickness: 2),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      selectedIndex = 8;
                                      select(8);
                                    });
                                  },
                                  style: TextButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    backgroundColor: isSelected[8]
                                        ? Colors.blue
                                        : Colors.transparent,
                                  ),
                                  child: Icon(Icons.settings),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      selectedIndex = 9;
                                      select(9);
                                    });
                                  },
                                  style: TextButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    backgroundColor: isSelected[9]
                                        ? Colors.blue
                                        : Colors.transparent,
                                  ),
                                  child: Icon(Icons.shield),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            child: Column(
                              children: <Widget>[
                                Divider(thickness: 2),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LoginPage(),
                                      ),
                                    );
                                  },
                                  child: Icon(Icons.logout),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          VerticalDivider(thickness: 2, color: Colors.grey),
          Expanded(flex: 20, child: pages[selectedIndex]),
        ],
      ),
    );
  }
}
