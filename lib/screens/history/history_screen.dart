import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_circuit/theme/pallete.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Scan History",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Pallete.appBarColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection("users")
                  .doc(userId)
                  .collection("scans")
                  .orderBy("timestamp", descending: true)
                  .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("No scans found"));
            }

            final scans = snapshot.data!.docs;

            return ListView.builder(
              itemCount: scans.length,
              itemBuilder: (context, index) {
                final scan = scans[index].data() as Map<String, dynamic>;
                final String scanId = scans[index].id;
                final aiReport = scan["ai-report"] ?? "No diagnosis available";

                return GestureDetector(
                  onTap: () {
                    _showDiagnosisDialog(context, aiReport);
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Device Image
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                bottomLeft: Radius.circular(12),
                              ),
                              child: Image.network(
                                scan["imageUrl"] ?? "",
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) => Container(
                                      width: 100,
                                      height: 100,
                                      color: Colors.grey[200],
                                      child: const Icon(
                                        Icons.broken_image,
                                        size: 40,
                                        color: Colors.grey,
                                      ),
                                    ),
                              ),
                            ),
                            // Device Info
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${scan["deviceCompany"]} ${scan["deviceModel"]}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatTimestamp(scan["timestamp"]),
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Status: ${scan["status"] ?? "unknown"}",
                                      style: TextStyle(
                                        color: _getStatusColor(scan["status"]),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Delete Button
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDelete(context, scanId),
                            ),
                          ],
                        ),
                        // Status Indicator
                        Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: _getStatusColor(scan["status"]),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showDiagnosisDialog(BuildContext context, String aiReport) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("AI Diagnosis Report"),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: MarkdownBody(
                  data: aiReport,
                  styleSheet: MarkdownStyleSheet(
                    p: const TextStyle(fontSize: 16),
                    h1: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                    h2: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ],
          ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String scanId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Delete Scan"),
            content: const Text(
              "Are you sure you want to delete this scan record?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        final userId = FirebaseAuth.instance.currentUser!.uid;
        await FirebaseFirestore.instance
            .collection("users")
            .doc(userId)
            .collection("scans")
            .doc(scanId)
            .delete();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Scan deleted successfully")),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to delete scan: $e")));
      }
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      DateTime date = timestamp.toDate();
      return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
    }
    return "Unknown Date";
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case "diagnosed":
        return Colors.orange;
      case "resolved":
        return Colors.green;
      case "recycled":
        return Colors.blue;
      case "resold":
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
