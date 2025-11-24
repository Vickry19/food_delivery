import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_provider.dart';
import '../models/cart_item.dart';
import '../models/order.dart'; // Pastikan ini diimpor
import 'order_detail_page.dart'; // Impor halaman detail

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<AppProvider>(context);
    final currency =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    // ✅ PERBARUI LOGIKA FILTER
    final upcomingOrders = prov.orders
        .where((o) =>
            o.status != 'Pesanan Selesai' && o.status != 'Pesanan Dibatalkan')
        .toList();
    final pastOrders = prov.orders
        .where((o) =>
            o.status == 'Pesanan Selesai' || o.status == 'Pesanan Dibatalkan')
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
        ),
        title: const Text(
          'My Orders',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundImage:
                  const AssetImage('assets/images/avatar_placeholder.png'),
              child: Text(
                prov.user.name.isNotEmpty
                    ? prov.user.name[0].toUpperCase()
                    : 'U',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white),
              ),
              onBackgroundImageError: (exception, stackTrace) {
                debugPrint('Error loading avatar image: $exception');
              },
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.orange,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.orange,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrdersList(upcomingOrders, prov, currency, isUpcoming: true),
          _buildOrdersList(pastOrders, prov, currency, isUpcoming: false),
        ],
      ),
    );
  }

  // Widget untuk membangun daftar pesanan
  Widget _buildOrdersList(
      List<OrderModel> orders, AppProvider prov, NumberFormat currency,
      {required bool isUpcoming}) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isUpcoming ? Icons.pending_actions : Icons.history,
                size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              isUpcoming ? 'No upcoming orders' : 'No order history',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: orders.length,
      itemBuilder: (context, idx) {
        final o = orders[idx];
        final restaurantName =
            o.items.isNotEmpty ? o.items.first.food.name : 'Unknown Restaurant';
        final totalItems =
            o.items.fold<int>(0, (int sum, CartItem item) => sum + item.qty);

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            // ✅ TAP UNTUK LIHAT DETAIL
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => OrderDetailPage(order: o)),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Pesanan
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        restaurantName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        o.status,
                        style: TextStyle(
                          color: _getStatusColor(o.status),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    // ✅ TAMBAHKAN WAKTU PEMESANAN
                    '$totalItems items • #${o.id} • ${DateFormat('dd MMM, HH:mm').format(o.time)}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  // Aksi untuk pesanan mendatang
                  if (isUpcoming)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          currency.format(o.total),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Row(
                          children: [
                            // ✅ TOMBOL CANCEL
                            TextButton(
                              onPressed: () =>
                                  _showCancelDialog(context, prov, o.id),
                              child: const Text('Cancel',
                                  style: TextStyle(color: Colors.red)),
                            ),
                            const SizedBox(width: 8),
                            // ✅ TOMBOL TRACK ORDER
                            ElevatedButton(
                              onPressed: () => _launchMaps(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                              ),
                              child: const Text('Track Order'),
                            ),
                            const SizedBox(width: 8),
                            // ✅ TOMBOL PESANAN DITERIMA
                            ElevatedButton(
                              onPressed: () => _showConfirmReceivedDialog(
                                  context, prov, o.id),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              child: const Text('Pesanan Diterima'),
                            ),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ✅ FUNGSI UNTUK MENDAPATKAN WARNA STATUS
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Sedang Dalam Perjalanan':
        return Colors.orange;
      case 'Pesanan Selesai':
        return Colors.green;
      case 'Pesanan Dibatalkan':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // ✅ DIALOG KONFIRMASI PEMBATALAN
  Future<void> _showCancelDialog(
      BuildContext context, AppProvider prov, String orderId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Batalkan Pesanan'),
        content: const Text('Apakah Anda yakin ingin membatalkan pesanan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tidak'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await prov.cancelOrder(orderId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pesanan berhasil dibatalkan')),
        );
      }
    }
  }

  // ✅ DIALOG KONFIRMASI PESANAN DITERIMA
  Future<void> _showConfirmReceivedDialog(
      BuildContext context, AppProvider prov, String orderId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi Penerimaan'),
        content: const Text('Apakah Anda yakin sudah menerima pesanan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Belum'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya, Sudah'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await prov.completeOrder(orderId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pesanan telah selesai')),
        );
      }
    }
  }

  // ✅ FUNGSI UNTUK MEMBUKA GOOGLE MAPS
  Future<void> _launchMaps() async {
    final Uri url = Uri.parse('https://maps.google.com');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }
}
