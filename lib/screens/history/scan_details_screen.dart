import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_circuit/theme/pallete.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ScanDetailsScreen extends StatelessWidget {
  final String scanId;

  const ScanDetailsScreen({super.key, required this.scanId});

  @override
  Widget build(BuildContext context) {
    final String userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan Details"),
        backgroundColor: Pallete.forestGreen,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _showDeleteConfirmation(context, scanId, userId),
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance
                .collection("users")
                .doc(userId)
                .collection("scans")
                .doc(scanId)
                .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Scan not found"));
          }

          final scan = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                // **Device Image**
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    scan["imageUrl"] ?? "",
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => const Icon(
                          Icons.broken_image,
                          size: 100,
                          color: Colors.grey,
                        ),
                  ),
                ),
                const SizedBox(height: 20),

                // **Device Info**
                _buildInfoRow("📱 Device Company", scan["deviceCompany"]),
                _buildInfoRow("🔢 Device Model", scan["deviceModel"]),
                _buildInfoRow("⌛ Device Age", scan["deviceAge"]),
                _buildInfoRow("❓ Problem", scan["problem"]),
                _buildInfoRow("💥 Visual Damage", scan["visualDamage"]),
                _buildInfoRow(
                  "📅 Scanned On",
                  _formatTimestamp(scan["timestamp"]),
                ),
                _buildInfoRow("📧 User Email", scan["userEmail"]),

                const SizedBox(height: 20),

                // **Delete Button**
                ElevatedButton.icon(
                  onPressed:
                      () => _showDeleteConfirmation(context, scanId, userId),
                  icon: const Icon(Icons.delete, color: Colors.white),
                  label: const Text("Delete Scan"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// **Reusable Row for Info Display**
  Widget _buildInfoRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value ?? "N/A",
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// **Show confirmation dialog before deleting scan**
  void _showDeleteConfirmation(
    BuildContext context,
    String scanId,
    String userId,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Scan"),
          content: const Text("Are you sure you want to delete this scan?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Pallete.forestGreen),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _deleteScan(scanId, userId, context);
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  /// **Delete scan from Firestore**
  Future<void> _deleteScan(
    String scanId,
    String userId,
    BuildContext context,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("scans")
          .doc(scanId)
          .delete();

      // Show success message & navigate back
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Scan deleted successfully"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // Go back to history screen
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error deleting scan: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// **Format timestamp to readable date**
  String _formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      DateTime date = timestamp.toDate();
      return "${date.day}/${date.month}/${date.year}  ${date.hour}:${date.minute}";
    }
    return "Unknown Date";
  }
}
