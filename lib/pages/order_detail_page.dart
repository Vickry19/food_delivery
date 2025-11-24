// lib/pages/order_detail_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/order.dart';
import '../models/cart_item.dart';

class OrderDetailPage extends StatelessWidget {
  final OrderModel order;

  const OrderDetailPage({super.key, required this.order});

  // ✅ TAMBAHKAN METODE YANG HILANG INI
  // Fungsi untuk mendapatkan warna berdasarkan status pesanan
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Dalam Perjalanan':
      case 'Food on the way':
        return Colors.orange;
      case 'Pesanan Selesai':
      case 'Selesai':
        return Colors.green;
      case 'Pesanan Dibatalkan':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Detail Pesanan'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(
              'Informasi Pesanan',
              icon: Icons.receipt_long,
              children: [
                _buildInfoRow('No. Pesanan', '#${order.id}'),
                _buildInfoRow('Status', order.status, color: _getStatusColor(order.status)),
                _buildInfoRow('Waktu', DateFormat('dd MMM yyyy, HH:mm').format(order.time)),
                _buildInfoRow('Metode Pembayaran', order.paymentMethod),
                if (order.paymentCode != null) _buildInfoRow('Kode Pembayaran', order.paymentCode!),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              'Alamat Pengiriman',
              icon: Icons.location_on,
              children: [_buildInfoRow('', order.address)],
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              'Item Pesanan',
              icon: Icons.fastfood,
              isScrollable: true,
              // ✅ PERBAIKI PEMANGGILAN FUNGSI DI SINI
              children: order.items.map((item) => _buildCartItem(item, currency)).toList(),
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              'Ringkasan Pembayaran',
              icon: Icons.payment,
              children: [
                _buildInfoRow('Total Pembayaran', currency.format(order.total), isBold: true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, {required List<Widget> children, required IconData icon, bool isScrollable = false}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (isScrollable)
              Column(children: children)
            else
              ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                color: color ?? Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ PASTIKAN SIGNATUR FUNGSI INI BENAR
  Widget _buildCartItem(CartItem item, NumberFormat currency) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item.food.image,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 60,
                height: 60,
                color: Colors.grey[200],
                child: const Icon(Icons.fastfood, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.food.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Jumlah: ${item.qty}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                if (item.selectedAddOns.isNotEmpty)
                  ...item.selectedAddOns.map((addOn) => Text(
                    '+ ${addOn['name']}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  )),
                const SizedBox(height: 4),
                Text(
                  currency.format(item.subtotal),
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}