import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_circuit/screens/services/recycle_screen.dart';
import 'package:eco_circuit/screens/services/repair_screen.dart';
import 'package:eco_circuit/screens/services/resell_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class DiagnosisScreen extends StatefulWidget {
  final String scanId;
  final Map<String, dynamic> deviceData;

  const DiagnosisScreen({
    super.key,
    required this.scanId,
    required this.deviceData,
  });

  @override
  _DiagnosisScreenState createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends State<DiagnosisScreen> {
  final model = FirebaseVertexAI.instance.generativeModel(
    model: 'gemini-2.0-flash',
  );
  String aiDiagnosis = "Analyzing device details...";
  bool isLoading = true;
  bool _showActionButtons = false;
  bool _issueResolved = false;

  @override
  void initState() {
    super.initState();
    _generateDiagnosis();
  }

  Future<void> _generateDiagnosis() async {
    final String prompt = """
    I have a ${widget.deviceData["deviceCompany"]} ${widget.deviceData["deviceModel"]}.
    It is ${widget.deviceData["deviceAge"]} old.
    The problem is: ${widget.deviceData["problem"]}.
    Visual damage: ${widget.deviceData["visualDamage"]}.
    
    Provide a detailed diagnosis report with proper formatting (use Markdown for bold/italic).
    Include:
    1. Problem identification
    2. Severity assessment
    3. Recommended action
    4. Environmental impact considerations
    """;

    try {
      final response = await model.generateContent([Content.text(prompt)]);
      String result = response.text ?? "Unable to generate diagnosis.";

      setState(() {
        aiDiagnosis = result;
        isLoading = false;
      });

      // Save AI report to Firestore
      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection("scans")
          .doc(widget.scanId)
          .update({
            "ai-report": result,
            "diagnosisTime": FieldValue.serverTimestamp(),
            "status": "diagnosed",
          });
    } catch (e) {
      setState(() {
        aiDiagnosis = "Error generating diagnosis: $e";
        isLoading = false;
      });
    }
  }

  void _navigateToOption(String option) {
    Widget screen;
    switch (option) {
      case "Recycle":
        screen = RecycleScreen(
          scanId: widget.scanId,
          deviceData: widget.deviceData,
        );
        break;
      case "Repair":
        screen = RepairScreen(scanId: widget.scanId);
        break;
      case "Resell":
        screen = ResellScreen(
          scanId: widget.scanId,
          deviceData: widget.deviceData,
        );
        break;
      default:
        return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  Future<void> _markIssueResolved() async {
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection("scans")
          .doc(widget.scanId)
          .update({
            "status": "resolved",
            "resolvedTime": FieldValue.serverTimestamp(),
          });

      setState(() {
        _issueResolved = true;
      });

      await Future.delayed(const Duration(seconds: 2));
      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error updating status: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Diagnosis Report"),
        backgroundColor: Colors.teal[700],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Device Info Cards
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.45,
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Device Name",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.teal,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      "${widget.deviceData["deviceCompany"]}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.45,
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Device Model",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.teal,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      "${widget.deviceData["deviceModel"]}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Diagnosis Report Card
                    Expanded(
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Diagnosis Report",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                MarkdownBody(
                                  data: aiDiagnosis,
                                  styleSheet: MarkdownStyleSheet(
                                    p: const TextStyle(
                                      fontSize: 16,
                                      height: 1.5,
                                    ),
                                    strong: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                    em: const TextStyle(
                                      fontStyle: FontStyle.italic,
                                    ),
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
                                    h3: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // "Was this helpful?" section
                    if (!_showActionButtons && !_issueResolved) ...[
                      const Text(
                        "Was this diagnosis helpful?",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _markIssueResolved,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              child: const Text("Yes"),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _showActionButtons = true;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              child: const Text("No"),
                            ),
                          ),
                        ],
                      ),
                    ],

                    // Success message
                    if (_issueResolved) ...[
                      const Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 48,
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Glad it was helpful!",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              "Returning to home screen...",
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Action Buttons (shown only if user clicks "No")
                    if (_showActionButtons && !_issueResolved) ...[
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildActionButton(
                            icon: Icons.recycling,
                            label: "Recycle",
                            color: Colors.blue,
                            onPressed: () => _navigateToOption("Recycle"),
                          ),
                          _buildActionButton(
                            icon: Icons.build,
                            label: "Repair",
                            color: Colors.orange,
                            onPressed: () => _navigateToOption("Repair"),
                          ),
                          _buildActionButton(
                            icon: Icons.monetization_on,
                            label: "Resell",
                            color: Colors.purple,
                            onPressed: () => _navigateToOption("Resell"),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 20),
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }
}
