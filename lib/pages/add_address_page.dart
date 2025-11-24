// lib/pages/add_address_page.dart
import 'package:flutter/material.dart';

class AddAddressPage extends StatefulWidget {
  // Terima alamat yang ada jika dalam mode edit
  final String? existingAddress;
  
  const AddAddressPage({super.key, this.existingAddress});

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller dengan alamat yang ada (jika ada)
    _addressController = TextEditingController(text: widget.existingAddress ?? '');
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingAddress == null ? 'Add Address' : 'Edit Address'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          // Tombol Save
          TextButton(
            onPressed: () {
              if (_addressController.text.trim().isNotEmpty) {
                // Kembalikan teks alamat ke halaman sebelumnya
                Navigator.pop(context, _addressController.text.trim());
              } else {
                // Tampilkan peringatan jika kosong
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter an address')),
                );
              }
            },
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                hintText: 'Enter your full address',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              autofocus: true,
            ),
          ],
        ),
      ),
    );
  }
}