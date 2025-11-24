// lib/pages/voucher_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class VoucherPage extends StatelessWidget {
  // Terima total belanja untuk validasi
  final int? totalBelanja;
  // ✅ TERIMA PARAMETER BARU
  final List<String> appliedCodes;

  VoucherPage({super.key, this.totalBelanja, this.appliedCodes = const []});

  // Data voucher (bisa dipindah ke tempat lain atau diambil dari backend)
  final List<Map<String, dynamic>> vouchers = [
    {
      'code': 'HEMAT10',
      'description': 'Diskon 10% untuk semua menu',
      'minPurchase': 50000,
    },
    {
      'code': 'HEMAT20',
      'description': 'Diskon 20% (Maks. Rp 50.000)',
      'minPurchase': 100000,
    },
    {
      'code': 'GRATISONGKIR',
      'description': 'Gratis ongkir (Rp 10.000)', // ✅ DESKRIPSI LEBIH JELAS
      'minPurchase': 30000,
    },
  ];

  bool _isVoucherApplicable(Map<String, dynamic> voucher) {
    // Jika totalBelanja null, anggap tidak berlaku
    if (totalBelanja == null) return false;
    return totalBelanja! >= voucher['minPurchase'];
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Voucher'),
        backgroundColor: Colors.orange,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: vouchers.length,
        itemBuilder: (context, index) {
          final voucher = vouchers[index];
          final isApplicable = _isVoucherApplicable(voucher);
          // ✅ CEK APAKAH VOUCHER SUDAH DIGUNAKAN
          final isAlreadyUsed = appliedCodes.contains(voucher['code']);

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              leading: const Icon(Icons.local_offer, color: Colors.orange),
              title: Text(voucher['code']),
              subtitle: Text(voucher['description']),
              trailing: isAlreadyUsed
                  ? const Text(
                      // ✅ TAMPILKAN TEKS "SUDAH DIGUNAKAN"
                      'Sudah Digunakan',
                      style: TextStyle(color: Colors.grey),
                    )
                  : isApplicable
                      ? ElevatedButton(
                          child: const Text('Gunakan'),
                          onPressed: () => Navigator.pop(context, voucher),
                        )
                      : Text(
                          'Min. ${currency.format(voucher['minPurchase'])}',
                          style: const TextStyle(color: Colors.grey),
                        ),
            ),
          );
        },
      ),
    );
  }
}
