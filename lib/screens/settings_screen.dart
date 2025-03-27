import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth_screen/login_screen.dart'; // Ensure this file exists

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (Route<dynamic> route) => false, // Clears the navigation stack
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Light theme background
      appBar: AppBar(
        title: Text("Settings", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.green[100], // Light Green AppBar
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          _buildSettingTile(
            Icons.dark_mode,
            "Dark Mode",
            Switch(
              value: _darkMode,
              onChanged: (value) {
                setState(() {
                  _darkMode = value;
                });
              },
            ),
          ),
          _buildSettingTile(
            Icons.logout,
            "Sign Out",
            IconButton(
              icon: Icon(Icons.arrow_forward, color: Colors.red),
              onPressed: _signOut,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile(IconData icon, String title, Widget action) {
    return Card(
      color: Colors.grey[200], // Light theme card
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: ListTile(
        leading: Icon(icon, color: Color(0xFF228B22)), // Forest Green Icon
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        trailing: action,
      ),
    );
  }
}
