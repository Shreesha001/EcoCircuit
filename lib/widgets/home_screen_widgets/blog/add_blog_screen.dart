import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddBlogScreen extends StatefulWidget {
  @override
  _AddBlogScreenState createState() => _AddBlogScreenState();
}

class _AddBlogScreenState extends State<AddBlogScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();

  void _postBlog() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter both title and content"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('blogs').add({
      'title': _titleController.text,
      'content': _contentController.text,
      'author':
          _authorController.text.isEmpty ? "Anonymous" : _authorController.text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    Navigator.pop(context); // Go back after posting
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Prevents overflow
      appBar: AppBar(
        title: const Text(
          "Write a Blog",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 43, 168, 64),
        elevation: 10,
        shadowColor: Colors.white.withOpacity(0.5),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity, // Ensures background covers entire screen
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color.fromARGB(255, 196, 233, 198),
              Colors.green.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildInputCard(
                        controller: _authorController,
                        label: "Name",
                        icon: Icons.person,
                      ),
                      const SizedBox(height: 15),
                      _buildInputCard(
                        controller: _titleController,
                        label: "Blog Title",
                        icon: Icons.title,
                      ),
                      const SizedBox(height: 15),
                      _buildInputCard(
                        controller: _contentController,
                        label: "Blog Content",
                        icon: Icons.edit,
                        maxLines: 5,
                      ),
                      const SizedBox(height: 25),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: FloatingActionButton.extended(
                  onPressed: _postBlog,
                  label: const Text(
                    "Post Blog",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  icon: const Icon(Icons.send),
                  backgroundColor: const Color.fromARGB(255, 107, 182, 110),
                  elevation: 5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper function to create input fields inside cards
  Widget _buildInputCard({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.black),
            border: InputBorder.none,
            prefixIcon: Icon(icon, color: Colors.black),
          ),
        ),
      ),
    );
  }
}
