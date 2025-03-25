import 'dart:io';
import 'package:eco_circuit/screens/scan/question_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  File? _selectedImage;

  /// **Pick Image from Camera or Gallery**
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await ImagePicker().pickImage(source: source);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });

        // Navigate to QuestionScreen with the selected image
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuestionScreen(image: _selectedImage!),
          ),
        );
      }
    } catch (e) {
      // Show error message if image picking fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error picking image: ${e.toString()}")),
      );
    }
  }

  /// **Show Image Picker Dialog**
  void _showImagePickerDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.green),
              title: const Text("Take a Photo"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.blue),
              title: const Text("Choose from Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel, color: Colors.red),
              title: const Text("Cancel"),
              onTap: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan Device")),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: _showImagePickerDialog,
          icon: const Icon(Icons.camera_alt, size: 28, color: Colors.white),
          label: const Text(
            "Scan / Upload Image",
            style: TextStyle(fontSize: 18),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3,
          ),
        ),
      ),
    );
  }
}
