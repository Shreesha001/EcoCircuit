import 'package:flutter/material.dart';

class ResellScreen extends StatelessWidget {
  const ResellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Resell Your Device")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Sell Your Device",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Get the best price for your old device by selling it on a marketplace.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            _buildResellOption(
              title: "📦 Sell on Online Marketplace",
              description:
                  "List your device on platforms like eBay, OLX, or Facebook Marketplace.",
              onTap: () {
                // Implement redirection to marketplace or upload form
              },
            ),
            _buildResellOption(
              title: "💬 Find Local Buyers",
              description:
                  "Sell your device to someone nearby using local selling groups.",
              onTap: () {
                // Implement chat or local buyer search
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResellOption({
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
