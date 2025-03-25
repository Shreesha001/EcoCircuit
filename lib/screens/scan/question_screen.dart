import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_circuit/responsive/mobilescreen_layout.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:eco_circuit/screens/home_screen.dart';

class QuestionScreen extends StatefulWidget {
  final File image;

  const QuestionScreen({super.key, required this.image});

  @override
  _QuestionScreenState createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final TextEditingController deviceCompanyController = TextEditingController();
  final TextEditingController deviceModelController = TextEditingController();
  final TextEditingController deviceAgeController = TextEditingController();
  final TextEditingController problemController = TextEditingController();
  final TextEditingController visualDamageController = TextEditingController();

  /// Shows a snackbar
  void _showCustomSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: isError ? Colors.red[400] : Colors.green[400],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Upload Image & Save Form Data
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      _showCustomSnackBar("You need to be logged in", isError: true);
      return;
    }

    try {
      // 1. Upload Image to Firebase Storage
      String filePath =
          'deviceScans/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      TaskSnapshot snapshot = await FirebaseStorage.instance
          .ref(filePath)
          .putFile(widget.image);
      String imageUrl = await snapshot.ref.getDownloadURL();

      // 2. Prepare all form data
      final formData = {
        "imageUrl": imageUrl,
        "deviceCompany": deviceCompanyController.text.trim(),
        "deviceModel": deviceModelController.text.trim(),
        "deviceAge": deviceAgeController.text.trim(),
        "problem": problemController.text.trim(),
        "visualDamage": visualDamageController.text.trim(),
        "timestamp": FieldValue.serverTimestamp(),
        "userId": user.uid,
        "userEmail": user.email,
      };

      // 3. Save to both collections in a batch write
      final batch = FirebaseFirestore.instance.batch();

      // Main collection
      final mainDocRef =
          FirebaseFirestore.instance.collection("deviceScans").doc();
      batch.set(mainDocRef, formData);

      // User's personal scan history
      final userDocRef = FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("scans")
          .doc(mainDocRef.id);
      batch.set(userDocRef, formData);

      await batch.commit();

      // 4. Show Success Message & Navigate to Home
      _showCustomSnackBar("Device scan submitted successfully!");

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MobileScreenLayout()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      _showCustomSnackBar("Error saving data: ${e.toString()}", isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Device Details"),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body:
          _isLoading
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text("Submitting your device information..."),
                  ],
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Display the selected image
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: FileImage(widget.image),
                            fit: BoxFit.cover,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),

                      // Form fields
                      _buildTextField(
                        controller: deviceCompanyController,
                        label: "Device Company*",
                        hint: "e.g., Samsung, Apple",
                        icon: Icons.business,
                      ),
                      _buildTextField(
                        controller: deviceModelController,
                        label: "Device Model*",
                        hint: "e.g., iPhone 13, Galaxy S21",
                        icon: Icons.phone_android,
                      ),
                      _buildTextField(
                        controller: deviceAgeController,
                        label: "Device Age*",
                        hint: "e.g., 2 years",
                        keyboardType: TextInputType.number,
                        icon: Icons.calendar_today,
                      ),
                      _buildTextField(
                        controller: problemController,
                        label: "Problem You Are Facing*",
                        hint: "Describe the issue",
                        maxLines: 3,
                        icon: Icons.warning,
                      ),
                      _buildTextField(
                        controller: visualDamageController,
                        label: "Any Visual Damage?*",
                        hint: "Describe any physical damage",
                        maxLines: 2,
                        icon: Icons.visibility,
                      ),

                      const SizedBox(height: 30),

                      // Submit button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                        ),
                        child:
                            _isLoading
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : const Text(
                                  "SUBMIT DEVICE INFO",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            validator:
                (value) => value!.isEmpty ? "This field is required" : null,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, color: Colors.green),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.green, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(
                vertical: 15,
                horizontal: 20,
              ),
            ),
            maxLines: maxLines,
            keyboardType: keyboardType,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    deviceCompanyController.dispose();
    deviceModelController.dispose();
    deviceAgeController.dispose();
    problemController.dispose();
    visualDamageController.dispose();
    super.dispose();
  }
}
