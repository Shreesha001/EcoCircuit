import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PurchaseDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> purchaseData;
  final String purchaseId;

  const PurchaseDetailsScreen({
    super.key,
    required this.purchaseData,
    required this.purchaseId,
  });

  @override
  State<PurchaseDetailsScreen> createState() => _PurchaseDetailsScreenState();
}

class _PurchaseDetailsScreenState extends State<PurchaseDetailsScreen> {
  final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: '₹',
    decimalDigits: 0,
    locale: 'en_IN',
  );
  bool _isUpdating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Purchase Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Chip
            Align(
              alignment: Alignment.topRight,
              child: Chip(
                label: Text(
                  widget.purchaseData['status']?.toString().toUpperCase() ??
                      'PENDING',
                  style: TextStyle(
                    color: _getStatusColor(widget.purchaseData['status']),
                  ),
                ),
                backgroundColor: _getStatusColor(
                  widget.purchaseData['status'],
                ).withOpacity(0.2),
              ),
            ),

            // Device Info
            _buildSectionTitle('Device Information'),
            _buildDetailRow('Model', widget.purchaseData['deviceModel']),
            _buildDetailRow('Condition', widget.purchaseData['condition']),
            _buildDetailRow(
              'Price',
              _currencyFormat.format(widget.purchaseData['price']),
            ),

            // Buyer Info
            _buildSectionTitle('Buyer Information'),
            _buildDetailRow('Name', widget.purchaseData['buyerName']),
            _buildDetailRow('Email', widget.purchaseData['buyerEmail']),
            _buildDetailRow('Phone', widget.purchaseData['buyerPhone']),
            _buildDetailRow('Address', widget.purchaseData['buyerAddress']),

            // Notes
            if (widget.purchaseData['notes'] != null &&
                widget.purchaseData['notes'].isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Buyer Notes'),
                  Text(widget.purchaseData['notes']),
                ],
              ),

            // Action Buttons
            if (widget.purchaseData['status'] == 'pending')
              _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isUpdating ? null : () => _updateStatus('rejected'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Reject'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isUpdating ? null : () => _updateStatus('accepted'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal[700],
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child:
                  _isUpdating
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                        'Accept',
                        style: TextStyle(color: Colors.white),
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(String status) async {
    setState(() => _isUpdating = true);

    try {
      await FirebaseFirestore.instance
          .collection('purchases')
          .doc(widget.purchaseId)
          .update({
            'status': status,
            'processedAt': FieldValue.serverTimestamp(),
          });

      // Update marketplace listing if rejected
      if (status == 'rejected') {
        await FirebaseFirestore.instance
            .collection('marketplace')
            .doc(widget.purchaseData['listingId'])
            .update({'status': 'active'});
      }

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Purchase $status successfully')));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      if (!mounted) return;
      setState(() => _isUpdating = false);
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }
}
