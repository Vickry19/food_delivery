// lib/pages/cart_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shopeefood_local/models/cart_item.dart';
import 'package:shopeefood_local/pages/voucher_page.dart'; // Impor halaman voucher
import '../providers/app_provider.dart';
import 'checkout_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final NumberFormat f = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppProvider>(context);
    final cart = app.cart;

    if (cart.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('My Cart'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_cart, size: 80, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Your cart is empty',
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Add items to get started',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    // ✅ PERHITUNGAN HARGA MENGGUNAKAN INT
    final subtotal = app.cartTotal();
    const tax = 11000; // ✅ UBAH MENJADI INT
    final delivery = app.effectiveDeliveryFee;
    final finalTotal = (subtotal - app.currentVoucherDiscount) + tax + delivery;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('My Cart'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Daftar Item di Keranjang
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cart.length,
              itemBuilder: (context, i) {
                final c = cart[i];
                return _buildCartItem(c, app);
              },
            ),
            const SizedBox(height: 20),

            // Bagian Voucher
            _buildVoucherSection(app),
            const SizedBox(height: 20),

            // Rincian Biaya
            _buildOrderSummary(subtotal, tax, delivery, finalTotal, app),
            const SizedBox(height: 20),

            // Tombol Checkout
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // ✅ NOTIFIKASI SAAT NAVIGASI KE CHECKOUT
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Menuju ke halaman pembayaran...'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                  // Navigasi ke halaman checkout
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CheckoutPage(totalAmount: finalTotal),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'CHECKOUT',
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
    );
  }

  // Widget untuk membangun setiap item di keranjang
  Widget _buildCartItem(CartItem c, AppProvider app) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          // Gambar Makanan
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              c.food.image,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 80,
                height: 80,
                color: Colors.grey[200],
                child: const Icon(Icons.fastfood, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Nama dan Harga
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.food.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (c.selectedAddOns.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: c.selectedAddOns.map((addOn) {
                      return Text(
                        '+ ${addOn['name']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 4),
                Text(
                  // Harga per item (subtotal dibagi qty)
                  f.format(c.subtotal / c.qty),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          // Tombol Jumlah
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: () {
                  app.changeQty(c.food, c.qty - 1);
                  // ✅ NOTIFIKASI SEDERHANA (opsional)
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   const SnackBar(content: Text('Item dikurangi'), duration: Duration(milliseconds: 500)),
                  // );
                },
              ),
              Text(
                '${c.qty}',
                style: const TextStyle(fontSize: 16),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () {
                  app.changeQty(c.food, c.qty + 1);
                  // ✅ NOTIFIKASI SEDERHANA (opsional)
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   const SnackBar(content: Text('Item ditambahkan'), duration: Duration(milliseconds: 500)),
                  // );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget untuk bagian input voucher
  Widget _buildVoucherSection(AppProvider app) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.shade300),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tampilkan voucher yang aktif (hanya satu)
        if (app.appliedVoucherCode != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Voucher: ${app.appliedVoucherCode}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    app.clearVoucher();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Voucher dihapus')),
                    );
                  },
                  child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ),
        // Tombol untuk memilih voucher baru
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.add, color: Colors.orange),
            label: const Text(
              "Pilih Voucher",
              style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
            ),
            onPressed: () async {
              // Kirim total belanja sebagai double
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VoucherPage(totalBelanja: app.cartTotal()),
                ),
              );

              // Jika user memilih voucher, terapkan
              if (result != null && result is Map) {
                try {
                  app.applyVoucher(result['code']);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Voucher "${result['code']}" berhasil digunakan!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              }
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.orange),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

  // Widget untuk menampilkan ringkasan pesanan
  Widget _buildOrderSummary(
      int subtotal, int tax, int delivery, int finalTotal, AppProvider app) {
    return Column(
      children: [
        _buildSummaryRow('Subtotal', f.format(subtotal)),
        _buildSummaryRow('Tax', f.format(tax)),
        _buildSummaryRow(
            'Delivery', app.isFreeDelivery ? 'Free' : f.format(delivery)),
        const Divider(),
        _buildSummaryRow(
          'Total',
          f.format(finalTotal),
          isTotal: true,
        ),
      ],
    );
  }

  // Widget untuk setiap baris ringkasan (Subtotal, Tax, dll.)
  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.orange : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}