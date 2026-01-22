import 'package:flutter/material.dart';

class SettingSite extends StatelessWidget {
  const SettingSite({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingsPage();
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.person),
                  title: Text("Account"),
                  subtitle: Text("Profile & role info"),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text("Edit Profile"),
                  onTap: () {
                    // TODO: navigate to edit profile page
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text("Logout"),
                  onTap: () async {
                    // TODO: FirebaseAuth.instance.signOut();
                    // Navigator push remove until LoginPage
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.lock),
                  title: Text("Security"),
                  subtitle: Text("Password & account protection"),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text("Send password reset email"),
                  onTap: () async {
                    // TODO: FirebaseAuth.instance.sendPasswordResetEmail(...)
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.password),
                  title: const Text("Change password"),
                  onTap: () {
                    // TODO: open change password dialog/page
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Card(
            child: Column(
              children: const [
                ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text("About"),
                  subtitle: Text("App version, privacy, support"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
