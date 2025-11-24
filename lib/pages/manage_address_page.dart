// lib/pages/manage_address_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'add_address_page.dart'; // Halaman ini juga akan kita perbarui

class ManageAddressPage extends StatelessWidget {
  const ManageAddressPage({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Addresses'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
        onPressed: () async {
          // Navigasi ke AddAddressPage dan tunggu hasilnya (String)
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddAddressPage()),
          );

          // Jika user memasukkan alamat, tambahkan ke provider
          if (result != null && result is String) {
            await prov.addAddress(result);
          }
        },
      ),
      body: prov.user.addresses.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.location_on, size: 80, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('No addresses yet', style: TextStyle(fontSize: 16)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: prov.user.addresses.length,
              itemBuilder: (context, index) {
                // Sekarang kita bekerja dengan String, bukan objek Address
                final addressString = prov.user.addresses[index];
                final isDefault = prov.user.address == addressString;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: isDefault
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(Icons.location_on),
                    title: Text(addressString),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'edit') {
                          // Navigasi ke AddAddressPage dengan alamat yang ada
                          final editedAddress = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddAddressPage(existingAddress: addressString),
                            ),
                          );
                          // Jika alamat diedit, perbarui di provider
                          if (editedAddress != null && editedAddress is String) {
                            await prov.updateAddressByIndex(index, editedAddress);
                          }
                        } else if (value == 'default') {
                          // Set alamat sebagai default
                          await prov.setDefaultAddress(addressString);
                        } else if (value == 'delete') {
                          // Tampilkan dialog konfirmasi
                          final ok = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Hapus alamat'),
                              content: const Text('Yakin ingin menghapus alamat ini?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Batal'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  child: const Text('Hapus'),
                                ),
                              ],
                            ),
                          );
                          // Jika dikonfirmasi, hapus alamat
                          if (ok == true) {
                            await prov.removeAddressByIndex(index);
                          }
                        }
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        // Sembunyikan opsi 'Set Default' jika sudah default
                        if (!isDefault) const PopupMenuItem(value: 'default', child: Text('Set Default')),
                        const PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}