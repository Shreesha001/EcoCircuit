import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class RecycleScreen extends StatefulWidget {
  final String scanId;
  final Map<String, dynamic> deviceData;

  const RecycleScreen({
    super.key,
    required this.scanId,
    required this.deviceData,
  });

  @override
  _RecycleScreenState createState() => _RecycleScreenState();
}

class _RecycleScreenState extends State<RecycleScreen> {
  List<Map<String, dynamic>> recyclingCenters = [];
  bool isLoading = true;

  // 🔑 Replace with your actual Google Places API Key
  final String googleApiKey =
      "AIzaSyCIHMLvq0cuQku3pXU_DDdCcUUn1a7NU_s"; // Replace with your API key

  @override
  void initState() {
    super.initState();
    _fetchRecyclingCenters();
  }

  /// **🔍 Get User's Location & Fetch Nearby E-Waste Recycling Centers**
  Future<void> _fetchRecyclingCenters() async {
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

      // ✅ 3. Google Places API URL for finding **E-Waste Recycling Centers**
      String url =
          "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
          "location=$lat,$lng"
          "&radius=10000" // 🔄 Increased radius to 10 km
          "&keyword=e-waste recycling|electronics recycling|electronic waste disposal" // 🔥 More accurate results
          "&rankby=prominence" // 📊 Sort by relevance & rating
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
          recyclingCenters = centers;
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

  /// **📍 Open Google Maps by Searching Name + Address**
  void _openGoogleMaps(String name, String address) async {
    // Format the query for Google Maps Search
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
      appBar: AppBar(title: const Text("Nearest E-Waste Centers")),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : recyclingCenters.isEmpty
              ? const Center(
                child: Text(
                  "No recycling centers found nearby.",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              )
              : ListView.builder(
                itemCount: recyclingCenters.length,
                itemBuilder: (context, index) {
                  var center = recyclingCenters[index];
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
