import '../models/food.dart';

// Data contoh produk (gunakan gambar lokal)
final List<Food> sampleFoods = [
  Food(
    id: 1,
    name: 'Nasi Goreng Spesial',
    category: 'Makanan',
    price: 20000,
    description: 'Nasi goreng dengan topping ayam, telur, dan kerupuk renyah.',
    image: 'assets/images/nasi_goreng.jpg',
  ),
  Food(
    id: 2,
    name: 'Es Teh Manis',
    category: 'Minuman',
    price: 5000,
    description: 'Segelas es teh manis menyegarkan.',
    image: 'assets/images/es_teh.jpg',
  ),
  Food(
    id: 3,
    name: 'Pisang Goreng',
    category: 'Camilan',
    price: 8000,
    description: 'Pisang goreng hangat renyah di luar lembut di dalam.',
    image: 'assets/images/pisang_goreng.jpg',
  ),
];
