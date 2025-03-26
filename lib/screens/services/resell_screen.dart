import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

class ResellScreen extends StatefulWidget {
  final String scanId;
  final Map<String, dynamic> deviceData;

  const ResellScreen({
    super.key,
    required this.scanId,
    required this.deviceData,
  });

  @override
  State<ResellScreen> createState() => _ResellScreenState();
}

class _ResellScreenState extends State<ResellScreen> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _condition = 'Good';
  List<String> _imageUrls = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitResellListing() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final listingData = {
        'deviceBrand': widget.deviceData["deviceCompany"],
        'deviceModel': widget.deviceData["deviceModel"],
        'deviceAge': widget.deviceData["deviceAge"],
        'originalScanId': widget.scanId,
        'price': double.parse(_priceController.text),
        'condition': _condition,
        'description': _descriptionController.text,
        'images': _imageUrls,
        'sellerId': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'active',
        'currency': 'INR', // Add currency field
      };

      await FirebaseFirestore.instance
          .collection('marketplace')
          .add(listingData);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('scans')
          .doc(widget.scanId)
          .update({'status': 'resell_listed'});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item listed for resale successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _isLoading = true);
      try {
        // Implement your Firebase Storage upload logic here
        // _imageUrls.add(downloadUrl);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to upload image: $e')));
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List Item for Resale'),
        backgroundColor: Colors.teal[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Device Info Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.deviceData["deviceCompany"]} ${widget.deviceData["deviceModel"]}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Age: ${widget.deviceData["deviceAge"]}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Price Field
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Asking Price (₹)',
                  prefixIcon: const Icon(Icons.currency_rupee),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Enter a valid amount';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Price must be greater than zero';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Condition Dropdown
              DropdownButtonFormField<String>(
                value: _condition,
                decoration: InputDecoration(
                  labelText: 'Condition',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                items: [
                  DropdownMenuItem(
                    value: 'Like New',
                    child: Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber[700]),
                        const SizedBox(width: 8),
                        const Text('Like New'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'Good',
                    child: Row(
                      children: [
                        Icon(Icons.star_half, color: Colors.amber[700]),
                        const SizedBox(width: 8),
                        const Text('Good'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'Fair',
                    child: Row(
                      children: [
                        Icon(Icons.star_border, color: Colors.amber[700]),
                        const SizedBox(width: 8),
                        const Text('Fair'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'Poor',
                    child: Row(
                      children: [
                        const Icon(Icons.star_border, color: Colors.grey),
                        const SizedBox(width: 8),
                        const Text('Poor'),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) => setState(() => _condition = value!),
              ),
              const SizedBox(height: 16),

              // Description Field
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Description',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Please add a description'
                            : null,
              ),
              const SizedBox(height: 20),

              // Image Upload Section
              const Text(
                'Upload Photos (Max 5)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (_imageUrls.isNotEmpty)
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _imageUrls.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                _imageUrls[index],
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: IconButton(
                                icon: const Icon(Icons.close, size: 18),
                                onPressed: () {
                                  setState(() {
                                    _imageUrls.removeAt(index);
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _imageUrls.length >= 5 ? null : _uploadImage,
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('Add Photo'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitResellListing,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'LIST ITEM FOR RESALE',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
