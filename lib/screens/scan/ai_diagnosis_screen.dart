import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter/material.dart';

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
  bool isRepairable = false;
  List<String> repairSteps = [];

  @override
  void initState() {
    super.initState();
    _generateDiagnosis();
  }

  /// **Generate AI Diagnosis**
  Future<void> _generateDiagnosis() async {
    final String prompt = """
    I have a ${widget.deviceData["deviceCompany"]} ${widget.deviceData["deviceModel"]}.
    It is ${widget.deviceData["deviceAge"]} old.
    The problem is: ${widget.deviceData["problem"]}.
    Visual damage: ${widget.deviceData["visualDamage"]}.
    
    1. Diagnose the problem.
    2. If user can fix it, give step-by-step repair instructions.
    3. If not repairable, say it's not repairable.
    """;

    try {
      final response = await model.generateContent([Content.text(prompt)]);
      String result = response.text ?? "Unable to generate diagnosis.";

      // Check if the response contains repair steps
      if (result.toLowerCase().contains("step 1") ||
          result.toLowerCase().contains("fix")) {
        isRepairable = true;
        repairSteps =
            result.split("\n").where((line) => line.trim().isNotEmpty).toList();
      } else {
        isRepairable = false;
      }

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
          .update({"ai-report": result});
    } catch (e) {
      setState(() {
        aiDiagnosis = "Error generating diagnosis: $e";
        isLoading = false;
      });
    }
  }

  /// **Handle User Confirmation**
  void _handleUserResponse(bool issueResolved) {
    if (issueResolved) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Great! Your device issue is resolved! 🎉")),
      );
      Navigator.pop(context);
    } else {
      setState(() {
        isRepairable = false;
      });
    }
  }

  /// **Navigate to Resell / Repair / Recycle**
  void _navigateToOption(String option) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Navigating to $option...")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Diagnosis"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Diagnosis Report:",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          aiDiagnosis,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (isRepairable) ...[
                      const Text(
                        "Follow these steps to fix the issue:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          itemCount: repairSteps.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.green,
                                child: Text(
                                  "${index + 1}",
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(repairSteps[index]),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Did this fix your issue?",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () => _handleUserResponse(true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            child: const Text("Yes ✅"),
                          ),
                          ElevatedButton(
                            onPressed: () => _handleUserResponse(false),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text("No ❌"),
                          ),
                        ],
                      ),
                    ] else ...[
                      const Center(
                        child: Text(
                          "Sorry, this issue is not repairable 😞",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildOptionButton("♻️ Recycle", Colors.blue),
                          _buildOptionButton("🔧 Repair", Colors.orange),
                          _buildOptionButton("💰 Resell", Colors.purple),
                        ],
                      ),
                    ],
                  ],
                ),
      ),
    );
  }

  Widget _buildOptionButton(String text, Color color) {
    return ElevatedButton(
      onPressed: () => _navigateToOption(text),
      style: ElevatedButton.styleFrom(backgroundColor: color),
      child: Text(text),
    );
  }
}
