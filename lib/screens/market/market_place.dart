import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'purchase_screen.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: '₹',
    decimalDigits: 0,
    locale: 'en_IN',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Marketplace'),
        backgroundColor: Colors.teal[700],
      ),
      body: _buildMarketplaceList(),
    );
  }

  Widget _buildMarketplaceList() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('marketplace')
              .where('status', isEqualTo: 'active')
              .orderBy('createdAt', descending: true)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No devices available'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final listing = snapshot.data!.docs[index];
            final data = listing.data() as Map<String, dynamic>;
            final listingId = listing.id;

            return FutureBuilder<DocumentSnapshot>(
              future:
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(data['sellerId'])
                      .collection('scans')
                      .doc(data['originalScanId'])
                      .get(),
              builder: (context, scanSnapshot) {
                if (scanSnapshot.connectionState == ConnectionState.waiting) {
                  return _buildListingCard(data, null, listingId);
                }
                if (scanSnapshot.hasError) {
                  return _buildListingCard(data, null, listingId);
                }
                final scanData =
                    scanSnapshot.data?.data() as Map<String, dynamic>?;
                return _buildListingCard(data, scanData, listingId);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildListingCard(
    Map<String, dynamic> listingData,
    Map<String, dynamic>? scanData,
    String listingId,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child:
                    scanData?['imageUrl'] != null
                        ? Image.network(
                          scanData!['imageUrl'],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 48,
                                color: Colors.grey,
                              ),
                            );
                          },
                        )
                        : const Center(
                          child: Icon(
                            Icons.phone_android,
                            size: 48,
                            color: Colors.grey,
                          ),
                        ),
              ),
            ),
            const SizedBox(height: 12),

            // Device Name
            Text(
              '${listingData['deviceBrand']} ${listingData['deviceModel']}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Condition and Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(listingData['condition'] ?? 'Unknown'),
                  backgroundColor: _getConditionColor(listingData['condition']),
                ),
                Text(
                  _currencyFormat.format(listingData['price'] ?? 0),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Description
            if (listingData['description'] != null)
              Text(
                listingData['description'],
                style: TextStyle(color: Colors.grey[600]),
              ),
            const SizedBox(height: 16),

            // Contact Seller Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    () => _handlePurchase(context, listingData, listingId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Contact Seller',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getConditionColor(String? condition) {
    switch (condition?.toLowerCase()) {
      case 'like new':
        return Colors.green[100]!;
      case 'good':
        return Colors.blue[100]!;
      case 'fair':
        return Colors.orange[100]!;
      case 'poor':
        return Colors.red[100]!;
      default:
        return Colors.grey[200]!;
    }
  }

  Future<void> _handlePurchase(
    BuildContext context,
    Map<String, dynamic> listingData,
    String listingId,
  ) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                PurchaseScreen(listingData: listingData, listingId: listingId),
      ),
    );
  }
}
