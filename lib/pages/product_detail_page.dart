import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/food.dart';
import '../providers/app_provider.dart';
import 'cart_page.dart'; // Impor halaman keranjang

class ProductDetailPage extends StatefulWidget {
  final Food food;

  const ProductDetailPage({super.key, required this.food});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {

  List<Map<String, dynamic>> get _getSelectedAddOns {
    return addOns.where((addOn) => selectedAddOns[addOn['name']] == true).toList();
  }
  // Data untuk pilihan "Add On"
  final List<Map<String, dynamic>> addOns = [
    {'name': 'Pepper Julienne', 'price': 2500},
    {'name': 'Baby Spinach', 'price': 4500},
    {'name': 'Mushroom', 'price': 2500},
  ];

  // Map untuk melacak Add On mana yang dipilih
  Map<String, bool> selectedAddOns = {};

  @override
  void initState() {
    super.initState();
    // Inisialisasi semua Add On sebagai tidak dipilih
    for (var addOn in addOns) {
      selectedAddOns[addOn['name']] = false;
    }
  }

  // Fungsi untuk menghitung total harga
  int calculateTotalPrice() {
    int totalPrice = widget.food.price;
    for (var addOn in addOns) {
      if (selectedAddOns[addOn['name']] == true) {
        totalPrice += addOn['price'] as int;
      }
    }
    return totalPrice;
  }

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppProvider>(context);
    final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: '\Rp ');
    final isFav = app.isFavorite(widget.food);

    return Scaffold(
      backgroundColor: Colors.white,
      // ===================== TAMBAHKAN FLOATING ACTION BUTTON DI SINI =====================
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigasi ke halaman keranjang saat tombol ditekan
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CartPage()),
          );
        },
        backgroundColor: Colors.orange,
        child: Stack(
          clipBehavior: Clip.none, // Agar badge bisa keluar dari lingkaran
          children: [
            const Icon(Icons.shopping_cart),
            // Badge untuk menampilkan jumlah item di keranjang
            if (app.cart.isNotEmpty)
              Positioned(
                right: -6,
                top: -6,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    '${app.cart.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
      // =========================================================================
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stack untuk menempatkan gambar, tombol kembali, dan favorit
            Stack(
              children: [
                // Gambar Produk
                Hero(
                  tag: 'food_${widget.food.id}',
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    child: Image.network(
                      widget.food.image,
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 300,
                        color: Colors.grey[300],
                        alignment: Alignment.center,
                        child: const Icon(Icons.fastfood,
                            size: 48, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                // Tombol Kembali Kustom
                Positioned(
                  top: 40,
                  left: 20,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.black),
                    ),
                  ),
                ),
                // Ikon Favorit
                Positioned(
                  top: 40,
                  right: 20,
                  child: GestureDetector(
                    onTap: () => app.toggleFavorite(widget.food),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? Colors.redAccent : Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Padding untuk konten di bawah gambar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama Produk
                  Text(
                    widget.food.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Deskripsi
                  Text(
                    'Cooked with onion, pepper, tomato and our special spices',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Bagian "Choice of Add On"
                  const Text(
                    'Choice of Add On',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Daftar Add On dengan Checkbox
                  ...addOns.map((addOn) {
                    return CheckboxListTile(
                      title: Text(addOn['name']),
                      value: selectedAddOns[addOn['name']],
                      activeColor: Colors.orange,
                      onChanged: (bool? value) {
                        setState(() {
                          selectedAddOns[addOn['name']] = value!;
                        });
                      },
                      secondary: Text(
                        'Rp ${addOn['price'].toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 24),

                  // Tombol ADD TO CART
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Panggil addToCart dengan food dan add-on yang dipilih
                        app.addToCart(widget.food, addOns: _getSelectedAddOns);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${widget.food.name} added to cart!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'ADD TO CART - ${formatCurrency.format(calculateTotalPrice())}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}