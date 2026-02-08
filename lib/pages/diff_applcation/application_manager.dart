import 'package:flutter/material.dart';
import 'package:geo_attendance_new_ui/pages/diff_applcation/icon_action/ManagerRequestPage.dart';
import 'package:geo_attendance_new_ui/pages/diff_applcation/icon_action/dashboard.dart';
import 'package:geo_attendance_new_ui/pages/diff_applcation/icon_action/department.dart';
import 'package:geo_attendance_new_ui/pages/diff_applcation/icon_action/graphic.dart';
import 'package:geo_attendance_new_ui/pages/diff_applcation/icon_action/list_worker.dart';
import 'package:geo_attendance_new_ui/pages/diff_applcation/icon_action/get_attendant.dart';
import 'package:geo_attendance_new_ui/pages/diff_applcation/icon_action/notifications.dart';
import 'package:geo_attendance_new_ui/pages/diff_applcation/icon_action/schedules.dart';
import 'package:geo_attendance_new_ui/pages/diff_applcation/icon_action/security.dart'
    as privacy;
import 'package:geo_attendance_new_ui/pages/diff_applcation/icon_action/setting.dart';
import 'package:geo_attendance_new_ui/pages/login_page.dart';

class ManagerPage extends StatelessWidget {
  const ManagerPage({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ IMPORTANT: no MaterialApp here
    // Your app's only MaterialApp should be in main.dart (AnimatedBuilder themeController)
    return const MyHomePage(title: 'Geo Attendant');
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
    const NotificationSite(),
    const GetAttendance(),
    const DashboardSite(),
    const GraphicSite(),
    const ManagerRequestsPage(),
    const DepartmentSite(),
    const ListWorkerSite(),
    const SchedulesSite(),
    const SettingSite(),
    const privacy.SecuritySite(),
  ];

  void select(int index) {
    setState(() {
      selectedIndex = index;
      isSelected = List<bool>.filled(10, false);
      isSelected[index] = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Row(
        children: <Widget>[
          // ============ LEFT SIDEBAR ============
          SizedBox(
            width: 70,
            child: Container(
              color: cs.surface,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top icons
                  Column(
                    children: [
                      const SizedBox(height: 10),
                      _sideBtn(
                        cs: cs,
                        selected: isSelected[0],
                        icon: Icons.notifications,
                        onTap: () => select(0),
                      ),
                      _sideBtn(
                        cs: cs,
                        selected: isSelected[1],
                        icon: Icons.check,
                        onTap: () => select(1),
                      ),
                      const SizedBox(height: 14),
                      Divider(thickness: 2, color: cs.outlineVariant),
                      const SizedBox(height: 6),

                      _sideBtn(
                        cs: cs,
                        selected: isSelected[2],
                        icon: Icons.add_box_outlined,
                        onTap: () => select(2),
                      ),
                      _sideBtn(
                        cs: cs,
                        selected: isSelected[3],
                        icon: Icons.auto_graph,
                        onTap: () => select(3),
                      ),
                      _sideBtn(
                        cs: cs,
                        selected: isSelected[4],
                        icon: Icons.person,
                        onTap: () => select(4),
                      ),
                      _sideBtn(
                        cs: cs,
                        selected: isSelected[5],
                        icon: Icons.schema_outlined,
                        onTap: () => select(5),
                      ),
                      _sideBtn(
                        cs: cs,
                        selected: isSelected[6],
                        icon: Icons.grading_sharp,
                        onTap: () => select(6),
                      ),
                      _sideBtn(
                        cs: cs,
                        selected: isSelected[7],
                        icon: Icons.date_range,
                        onTap: () => select(7),
                      ),

                      const SizedBox(height: 10),
                      Divider(thickness: 2, color: cs.outlineVariant),
                      const SizedBox(height: 6),

                      _sideBtn(
                        cs: cs,
                        selected: isSelected[8],
                        icon: Icons.settings,
                        onTap: () => select(8),
                      ),
                      _sideBtn(
                        cs: cs,
                        selected: isSelected[9],
                        icon: Icons.shield,
                        onTap: () => select(9),
                      ),
                    ],
                  ),

                  // Bottom logout
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      children: [
                        Divider(thickness: 2, color: cs.outlineVariant),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginPage(),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            foregroundColor: cs.onSurfaceVariant,
                          ),
                          child: const Icon(Icons.logout),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Divider between sidebar and content
          VerticalDivider(thickness: 2, width: 1, color: cs.outlineVariant),

          // ============ PAGE CONTENT ============
          Expanded(child: pages[selectedIndex]),
        ],
      ),
    );
  }

  Widget _sideBtn({
    required ColorScheme cs,
    required bool selected,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: selected ? cs.primaryContainer : Colors.transparent,
          foregroundColor: selected
              ? cs.onPrimaryContainer
              : cs.onSurfaceVariant,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        ),
        child: Icon(icon, size: 24),
      ),
    );
  }
}
