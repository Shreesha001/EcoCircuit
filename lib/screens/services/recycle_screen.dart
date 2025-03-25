import 'package:flutter/material.dart';

class RecycleScreen extends StatelessWidget {
  const RecycleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Recycle Your Device")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Recycle Your Device",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Help protect the environment by recycling your device responsibly.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            _buildRecycleOption(
              title: "♻️ Find an E-Waste Center",
              description: "Locate certified recycling centers near you.",
              onTap: () {
                // Implement e-waste center locator
              },
            ),
            _buildRecycleOption(
              title: "📦 Mail-in Recycling Programs",
              description:
                  "Send your device to manufacturers for proper disposal.",
              onTap: () {
                // Implement mail-in program options
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecycleOption({
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios, size: 20),
        onTap: onTap,
      ),
    );
  }
}
