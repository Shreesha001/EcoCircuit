import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  User? _user;
  String _fullName = "Loading...";
  String _email = "Loading...";
  String _phone = "Loading...";
  String _createdAt = "Loading...";
  int _devicesScanned = 0;
  double _carbonFootprintSaved = 0.0;
  int _badgesEarned = 0;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
  _user = _auth.currentUser;
  if (_user != null) {
    try {
      DocumentSnapshot userDoc = 
          await _firestore.collection('users').doc(_user!.uid).get();

      if (userDoc.exists && userDoc.data() != null) {
        Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;

        setState(() {
          _fullName = data?['full_name'] ?? "No Name";
          _email = data?['email'] ?? _user!.email ?? "No Email";
          _phone = data?['phone'] ?? "Not Available";
          _createdAt = (data?['created_at'] != null)
              ? data!['created_at'].toDate().toString().substring(0, 10)
              : "Unknown";
          _devicesScanned = data?['devices_scanned'] ?? 0;
          _carbonFootprintSaved = data?['carbon_saved'] ?? 0.0;
          _badgesEarned = data?['badges'] ?? 0;

          _nameController.text = _fullName;
          _phoneController.text = _phone;
        });
      } else {
        setState(() {
          _fullName = "No Name";
          _email = _user!.email ?? "No Email";
          _phone = "Not Available";
          _createdAt = "Unknown";
          _devicesScanned = 0;
          _carbonFootprintSaved = 0.0;
          _badgesEarned = 0;
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() {
        _fullName = "Error Loading";
        _email = "Error Loading";
        _phone = "Error Loading";
        _createdAt = "Error";
        _devicesScanned = 0;
        _carbonFootprintSaved = 0.0;
        _badgesEarned = 0;
      });
    }
  }
}


  Future<void> _updateUserData() async {
    if (_user != null) {
      await _firestore.collection('users').doc(_user!.uid).update({
        'full_name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
      });

      setState(() {
        _fullName = _nameController.text.trim();
        _phone = _phoneController.text.trim();
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile updated successfully!"))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      appBar: AppBar(
        title: Text("Profile", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.green[100], // Light Green AppBar
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Color(0xFF228B22)), // Olive Green Settings Icon
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Profile Picture
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(
                "https://static.vecteezy.com/system/resources/thumbnails/020/765/399/small_2x/default-profile-account-unknown-icon-black-silhouette-free-vector.jpg",
              ),
            ),

            const SizedBox(height: 10),

            // Name & Edit Button
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _fullName,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                IconButton(
                  icon: Icon(Icons.edit, color: Color(0xFF228B22)), // Olive Green Edit Icon
                  onPressed: () {
                    setState(() {
                      _isEditing = true;
                    });
                  },
                )
              ],
            ),

            Text(
              _email,
              style: TextStyle(color: Colors.grey[700]),
            ),

            const SizedBox(height: 30),

            // Editable Fields
            _isEditing ? _buildEditableFields() : _buildProfileDetails(),

            const SizedBox(height: 30),

            // Save Button
            _isEditing
                ? ElevatedButton(
                    onPressed: _updateUserData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF228B22), // Olive Green Button
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                    ),
                    child: Text("Save", style: TextStyle(fontSize: 18, color: Colors.white)),
                  )
                : SizedBox.shrink(),

            const SizedBox(height: 30),

            // Badges Earned & Carbon Footprint Saved
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatCard("Badges Earned", _badgesEarned.toString()),
                  _buildStatCard("Carbon Saved", "${_carbonFootprintSaved.toStringAsFixed(2)} kg"),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDetails() {
    return Column(
      children: [
        _buildInfoTile(Icons.phone, "Phone", _phone),
        _buildInfoTile(Icons.calendar_today, "Joined On", _createdAt),
        _buildInfoTile(Icons.devices, "Devices Scanned", "$_devicesScanned"),
        _buildInfoTile(Icons.eco, "Carbon Footprint Saved", "${_carbonFootprintSaved.toStringAsFixed(2)} kg"),
      ],
    );
  }

  Widget _buildEditableFields() {
    return Column(
      children: [
        _buildEditableTextField(Icons.person, "Full Name", _nameController),
        _buildEditableTextField(Icons.phone, "Phone", _phoneController),
      ],
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return Card(
      color: Colors.grey[200], 
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: ListTile(
        leading: Icon(icon, color: Color(0xFF228B22)), // Olive Green Icons
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        subtitle: Text(value, style: TextStyle(color: Colors.grey[700])),
      ),
    );
  }

  Widget _buildEditableTextField(IconData icon, String label, TextEditingController controller) {
    return Card(
      color: Colors.grey[200], 
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: ListTile(
        leading: Icon(icon, color: Color(0xFF228B22)), // Olive Green Icons
        title: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            border: InputBorder.none,
          ),
          style: TextStyle(color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Expanded(
      child: Card(
        color: Colors.green[50], 
        margin: EdgeInsets.symmetric(horizontal: 5),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
              const SizedBox(height: 5),
              Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[800])),
            ],
          ),
        ),
      ),
    );
  }
}
