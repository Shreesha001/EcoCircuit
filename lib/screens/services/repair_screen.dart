import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RepairScreen extends StatefulWidget {
  final String scanId;

  const RepairScreen({super.key, required this.scanId});

  @override
  _RepairScreenState createState() => _RepairScreenState();
}

class _RepairScreenState extends State<RepairScreen> {
  List<Map<String, dynamic>> repairCenters = [];
  bool isLoading = true;
  String? deviceCompany;

  // 🔑 Replace with your actual Google Places API Key
  final String googleApiKey =
      "AIzaSyCIHMLvq0cuQku3pXU_DDdCcUUn1a7NU_s"; // Replace with your API key

  @override
  void initState() {
    super.initState();
    _fetchDeviceCompany();
  }

  /// **Step 1: Fetch Device Company from Firestore**
  Future<void> _fetchDeviceCompany() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;

      // 🔍 Get scan document from Firestore
      var snapshot =
          await FirebaseFirestore.instance
              .collection("users")
              .doc(userId)
              .collection("scans")
              .doc(widget.scanId)
              .get();

      if (snapshot.exists) {
        String company = snapshot.data()?["deviceCompany"] ?? "Unknown";
        setState(() {
          deviceCompany = company;
        });

        // Fetch repair centers based on this company
        _fetchRepairCenters(company);
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Device data not found!")));
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error fetching device: $e")));
    }
  }

  /// **Step 2: Fetch Nearby Repair Centers Based on Device Company**
  Future<void> _fetchRepairCenters(String company) async {
    try {
      // ✅ 1. Request location permission
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      // ✅ 2. Get current user location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      double lat = position.latitude;
      double lng = position.longitude;

      // ✅ 3. Google Places API URL for finding repair centers for the device company
      String url =
          "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
          "location=$lat,$lng"
          "&radius=10000" // 🔄 Search in 10 km range
          "&keyword=$company repair|$company service center|phone repair|laptop repair" // 🔥 Focused search
          "&rankby=prominence" // 📊 Rank by relevance
          "&key=$googleApiKey";

      // ✅ 4. Fetch data from Google Places API
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<Map<String, dynamic>> centers = [];

        for (var place in data["results"]) {
          centers.add({
            "name": place["name"],
            "address": place["vicinity"] ?? "Address not available",
            "rating": place["rating"]?.toString() ?? "No rating",
          });
        }

        setState(() {
          repairCenters = centers;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// **Step 3: Open Google Maps by Searching Name + Address**
  void _openGoogleMaps(String name, String address) async {
    String query = Uri.encodeComponent("$name, $address");
    final Uri url = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=$query",
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open Google Maps")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          deviceCompany != null
              ? "Repair Centers for $deviceCompany"
              : "Finding Repair Centers...",
        ),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : repairCenters.isEmpty
              ? const Center(
                child: Text(
                  "No repair centers found nearby.",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              )
              : ListView.builder(
                itemCount: repairCenters.length,
                itemBuilder: (context, index) {
                  var center = repairCenters[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      title: Text(
                        center["name"],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        "📍 ${center["address"]}\n⭐ ${center["rating"]}",
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.map, color: Colors.blue),
                        onPressed:
                            () => _openGoogleMaps(
                              center["name"],
                              center["address"],
                            ),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
