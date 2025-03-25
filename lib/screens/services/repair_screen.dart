import 'package:flutter/material.dart';

class RepairScreen extends StatelessWidget {
  const RepairScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Repair Options")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Repair Your Device",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Fix your device at a trusted repair shop or follow a DIY guide.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            _buildRepairOption(
              title: "🛠️ Find a Repair Shop",
              description:
                  "Locate nearby repair centers or authorized service providers.",
              onTap: () {
                // Implement repair shop locator
              },
            ),
            _buildRepairOption(
              title: "📖 Follow DIY Repair Guide",
              description:
                  "Step-by-step instructions for repairing your device at home.",
              onTap: () {
                // Implement DIY repair guide
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRepairOption({
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
