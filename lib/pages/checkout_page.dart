// lib/pages/checkout_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import 'order_success_page.dart';
import 'add_address_page.dart';
import 'voucher_page.dart';

class CheckoutPage extends StatefulWidget {
  // ✅ PERBAIKI: Pastikan tipe data totalAmount adalah int
  final int totalAmount;

  const CheckoutPage({super.key, required this.totalAmount});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  // State variables
  String? _selectedAddress;
  String _selectedPaymentMethod = 'Cash on Delivery'; // Metode default
  String? _generatedPaymentCode;

  final List<String> _paymentMethods = [
    'Cash on Delivery',
    'Bank Transfer',
    'Gopay',
    'OVO',
    'DANA',
  ];

  final NumberFormat f = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    // Set alamat yang dipilih dari provider saat halaman dimuat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final app = Provider.of<AppProvider>(context, listen: false);
      setState(() {
        _selectedAddress = app.user.address;
      });
    });
  }

  // ✅ PERBAIKI: Method untuk menangani pemesanan
  Future<void> _handlePlaceOrder() async {
    // Validasi: pastikan alamat sudah dipilih
    if (_selectedAddress == null || _selectedAddress!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih alamat pengiriman.')),
      );
      return;
    }

    // Dapatkan provider di luar try-catch untuk kejelasan
    final app = Provider.of<AppProvider>(context, listen: false);

    try {
      // ✅ HAPUS PARAMETER YANG TIDAK DIPERLUKAN
      // AppProvider akan menghitung total secara internal
      await app.placeOrder(
        address: _selectedAddress!,
        paymentMethod: _selectedPaymentMethod,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OrderSuccessPage(total: widget.totalAmount),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Bagian Alamat Pengiriman ---
            _buildSectionTitle('Alamat Pengiriman'),
            const SizedBox(height: 8),
            Consumer<AppProvider>(
              builder: (context, app, _) => _buildAddressSelector(app),
            ),

            const SizedBox(height: 24),

            // ✅ TAMBAHKAN: Bagian Voucher
            Consumer<AppProvider>(
              builder: (context, app, _) => _buildVoucherSection(app),
            ),
            const SizedBox(height: 24),

            // --- Bagian Metode Pembayaran ---
            _buildSectionTitle('Metode Pembayaran'),
            const SizedBox(height: 8),
            _buildPaymentMethodSelector(app),
            const SizedBox(height: 24),

            // --- Bagian Kode Unik (Kondisional) ---
            if (_generatedPaymentCode != null) ...[
              _buildSectionTitle('Kode Pembayaran'),
              const SizedBox(height: 8),
              _buildPaymentCodeDisplay(),
              const SizedBox(height: 24),
            ],

            // --- Ringkasan Pesanan ---
            _buildSectionTitle('Ringkasan Pesanan'),
            const SizedBox(height: 8),
            Consumer<AppProvider>(
              builder: (context, app, _) => _buildOrderSummary(app),
            ),

            const SizedBox(height: 32),

            // --- Tombol Place Order ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handlePlaceOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'KONFIRMASI & BAYAR',
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

  // Widget untuk judul bagian
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  // Widget untuk pemilih alamat
  Widget _buildAddressSelector(AppProvider app) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: app.user.addresses.isEmpty
          ? ListTile(
              title: const Text('Belum ada alamat yang disimpan'),
              trailing: TextButton(
                child: const Text('Tambah Alamat'),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddAddressPage()),
                  );
                  if (result != null && result is String) {
                    await app.addAddress(result);
                    setState(() {
                      _selectedAddress = result;
                    });
                  }
                },
              ),
            )
          : Column(
              children: [
                ...app.user.addresses.map((address) {
                  return RadioListTile<String>(
                    title: Text(address),
                    value: address,
                    groupValue: _selectedAddress,
                    activeColor: Colors.orange,
                    onChanged: (value) {
                      setState(() {
                        _selectedAddress = value;
                      });
                    },
                  );
                }).toList(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Tambah Alamat Baru'),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AddAddressPage()),
                        );
                        if (result != null && result is String) {
                          await app.addAddress(result);
                          setState(() {
                            _selectedAddress = result;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // Widget untuk pemilih metode pembayaran
  Widget _buildPaymentMethodSelector(AppProvider app) {
    return Column(
      children: _paymentMethods.map((method) {
        return RadioListTile<String>(
          title: Text(method),
          value: method,
          groupValue: _selectedPaymentMethod,
          activeColor: Colors.orange,
          onChanged: (value) {
            setState(() {
              _selectedPaymentMethod = value!;
              _generatedPaymentCode =
                  ['Bank Transfer', 'Gopay', 'OVO', 'DANA'].contains(value)
                      ? app.generatePaymentCode()
                      : null;
            });
          },
        );
      }).toList(),
    );
  }

  // ✅ TAMBAHKAN: Widget untuk bagian voucher
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
          // Tampilkan voucher yang aktif
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
                    child: const Text('Hapus',
                        style: TextStyle(color: Colors.red)),
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
                style: TextStyle(
                    color: Colors.orange, fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                // Navigasi ke halaman voucher dan tunggu hasil
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
                      SnackBar(
                          content: Text(
                              'Voucher "${result['code']}" berhasil digunakan!')),
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

  // Widget untuk menampilkan kode pembayaran unik
  Widget _buildPaymentCodeDisplay() {
    if (_generatedPaymentCode == null) {
      return const SizedBox.shrink(); // Sembunyikan jika tidak ada kode
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Kode Pembayaran Unik:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            _generatedPaymentCode!,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk menampilkan ringkasan total
  Widget _buildOrderSummary(AppProvider app) {
    // ✅ PERBAIKI: Semua perhitungan menggunakan int
    final int subtotal = app.cartTotal();
    const int tax = 11000;
    final int delivery = app.effectiveDeliveryFee;
    // Perhitungan total sudah benar karena semua variabel adalah int
    final int finalTotal =
        (subtotal - app.currentVoucherDiscount) + tax + delivery;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildSummaryRow('Subtotal', f.format(subtotal)),
          _buildSummaryRow('Pajak', f.format(tax)),
          _buildSummaryRow(
              'Ongkir', app.isFreeDelivery ? 'Gratis' : f.format(delivery)),
          if (app.currentVoucherDiscount > 0)
            _buildSummaryRow(
                'Diskon Voucher', '-${f.format(app.currentVoucherDiscount)}'),
          const Divider(),
          _buildSummaryRow(
            'Total',
            f.format(finalTotal),
            isTotal: true,
          ),
        ],
      ),
    );
  }

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
