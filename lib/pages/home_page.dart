import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopeefood_local/pages/manage_address_page.dart';
import 'package:shopeefood_local/pages/order_history_page.dart';
import 'package:shopeefood_local/widgets/cart_icon.dart';
import '../models/food.dart';
import '../providers/app_provider.dart';
import 'cart_page.dart';
import 'profile_page.dart';
import 'favorite_page.dart';
import 'voucher_page.dart';

// Model Restaurant tetap sama
class Restaurant {
  final String name;
  final String image;
  final double rating;
  final String deliveryTime;
  final String deliveryFee;
  final String category;

  Restaurant({
    required this.name,
    required this.image,
    required this.rating,
    required this.deliveryTime,
    required this.deliveryFee,
    required this.category,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;
  String searchQuery = '';

  late TextEditingController _searchController;

  // Data Kategori dengan Material Icons
  final List<Map<String, dynamic>> categories = [
    {'name': 'Semua', 'icon': Icons.grid_view},
    {'name': 'Makanan', 'icon': Icons.dinner_dining},
    {'name': 'Minuman', 'icon': Icons.local_cafe},
    {'name': 'Snack', 'icon': Icons.cookie},
    {'name': 'Burger', 'icon': Icons.lunch_dining},
    {'name': 'Pizza', 'icon': Icons.local_pizza},
    {'name': 'Sushi', 'icon': Icons.set_meal},
  ];

  // Data Makanan
  final List<Food> allFoods = [
    Food(
        id: 1,
        name: 'Nasi Goreng',
        price: 20000,
        description: "Nasi goreng spesial dengan bumbu rahasia",
        image: 'assets/images/nasi_goreng.jpg',
        category: 'Makanan'),
    Food(
        id: 2,
        name: 'Es Teh Manis',
        price: 5000,
        description: "Teh pilihan dengan gula asli",
        image: 'assets/images/es_teh.jpg',
        category: 'Minuman'),
    Food(
        id: 3,
        name: 'Mie Ayam',
        price: 15000,
        description: "Mie dengan topping ayam cincang",
        image: 'assets/images/mie_ayam.jpg',
        category: 'Makanan'),
    Food(
        id: 4,
        name: 'Ayam Geprek',
        price: 25000,
        description: "Ayam Geprek dengan sambal mantap",
        image: 'assets/images/ayam_geprek.jpg',
        category: 'Makanan'),
    Food(
        id: 5,
        name: 'Burger',
        price: 30000,
        description: "Burger daging sapi premium",
        image: 'assets/images/burger.jpg',
        category: 'Burger'),
    Food(
        id: 6,
        name: 'Kentang Goreng',
        price: 18000,
        description: "Kentang renyah dengan saus pilihan",
        image: 'assets/images/kentang.jpg',
        category: 'Snack'),
    Food(
        id: 7,
        name: 'Pizza',
        price: 75000,
        description: "Pizza dengan topping keju melimpah",
        image: 'assets/images/pizza.jpg',
        category: 'Pizza'),
  ];

  // Data Restoran
  final List<Restaurant> featuredRestaurants = [
    Restaurant(
        name: 'McDonald\'s',
        image: 'assets/images/mcd.jpg',
        rating: 4.5,
        deliveryTime: '10-15 mins',
        deliveryFee: 'Free delivery',
        category: 'Burger'),
    Restaurant(
        name: 'Starbucks',
        image: 'assets/images/starbucks.jpg',
        rating: 4.7,
        deliveryTime: '20-25 mins',
        deliveryFee: 'Free delivery',
        category: 'Minuman'),
    Restaurant(
        name: 'Pizza Hut',
        image: 'assets/images/pizza_hut.jpg',
        rating: 4.6,
        deliveryTime: '30-40 mins',
        deliveryFee: 'Rp 10.000',
        category: 'Pizza'),
    Restaurant(
        name: 'Sushi Tei',
        image: 'assets/images/sushi_tei.jpg',
        rating: 4.8,
        deliveryTime: '45-55 mins',
        deliveryFee: 'Rp 15.000',
        category: 'Sushi'),
  ];

  @override
  void initState() {
    super.initState();

    _searchController = TextEditingController();
    // Inisialisasi kategori pertama kali
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = Provider.of<AppProvider>(context, listen: false);
      // Pastikan kategori 'Semua' ada jika tidak ada yang dipilih
      if (prov.selectedCategory.isEmpty ||
          !categories.any((cat) => cat['name'] == prov.selectedCategory)) {
        prov.setCategory('Semua');
      }
    });

    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) {}
    });
  }

  @override
  void dispose() {
    // Bersihkan controller saat widget di-dispose
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<AppProvider>(context);
    final tabs = [
      _buildHomeTab(prov),
      const FavoritePage(),
      const CartPage(),
      const OrderHistoryPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      drawer: _buildDrawer(prov),
      body: tabs[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        onTap: (i) => setState(() => _index = i),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: 'Favorite'),
          BottomNavigationBarItem(
            icon: const CartIconWithBadge(), // ✅ Gunakan widget baru
            label: 'Orders',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }

  // ===================== 🔸 TAB HOME 🔸 =====================
  Widget _buildHomeTab(AppProvider prov) {
    final isDark = prov.isDark;

    // Filter makanan berdasarkan kategori dan pencarian
    final filteredFoods = allFoods.where((f) {
      final categoryMatch = prov.selectedCategory == 'Semua' ||
          f.category == prov.selectedCategory;
      final searchMatch =
          f.name.toLowerCase().contains(searchQuery.toLowerCase());
      return categoryMatch && searchMatch;
    }).toList();

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          // Ubah floating menjadi false dan pinned menjadi true
          floating: false,
          pinned: true,
          snap: false,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
          title: _buildAddressBar(prov),
          automaticallyImplyLeading: false,
          leading: Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu, color: Colors.black),
                onPressed: () => Scaffold.of(context).openDrawer(),
              );
            },
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(80),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: _buildSearchBar(isDark),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildCategories(prov, isDark),
              const SizedBox(height: 16),
              _buildFeaturedRestaurants(isDark),
              const SizedBox(height: 16),
            ],
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final food = filteredFoods[index];
                final isFav =
                    Provider.of<AppProvider>(context).isFavorite(food);

                return GestureDetector(
                  onTap: () =>
                      Navigator.pushNamed(context, '/detail', arguments: food),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[850] : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(15)),
                            child: Stack(
                              children: [
                                Image.asset(
                                  food.image,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.fastfood,
                                          color: Colors.grey),
                                    );
                                  },
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: IconButton(
                                    icon: Icon(
                                      isFav
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: isFav ? Colors.red : Colors.white,
                                    ),
                                    onPressed: () => Provider.of<AppProvider>(
                                            context,
                                            listen: false)
                                        .toggleFavorite(food),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  food.name,
                                  style: TextStyle(
                                    color:
                                        isDark ? Colors.white : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Rp. ${food.price}',
                                  style: const TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              childCount: filteredFoods.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 80),
        ),
      ],
    );
  }

  // Widget untuk Address Bar (SUDAH DIPERBAIKI)
  // Widget untuk Address Bar dengan Dropdown
  Widget _buildAddressBar(AppProvider prov) {
    // Tampilkan alamat pengguna jika ada, jika tidak tampilkan teks default
    final displayAddress =
        prov.user.address != null && prov.user.address!.isNotEmpty
            ? prov.user.address!
            : 'Set your address';

    return InkWell(
    // ✅ Panggil bottom sheet baru saat diketuk
    onTap: () => _showAddressBottomSheet(context, prov),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Deliver to',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
        Row(
          children: [
            const Icon(Icons.location_on, color: Colors.orange, size: 16),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                displayAddress,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Colors.orange),
          ],
        ),
      ],
    ),
  );
  }

// Tambahkan metode ini untuk menampilkan dialog pemilihan alamat
  // lib/pages/home_page.dart

// ... di dalam class _HomePageState ...

// ✅ TAMBAHKAN METHOD BARU INI
void _showAddressBottomSheet(BuildContext context, AppProvider prov) {
  final TextEditingController _newAddressController = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Penting agar TextField tidak tertutup keyboard
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom, // Sesuaikan dengan keyboard
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.6, // Mulai dari 60% tinggi layar
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, controller) => Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Garis pegangan di atas
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const Text(
                'Pilih Alamat Pengiriman',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              // Daftar alamat yang sudah ada
              if (prov.user.addresses.isNotEmpty) ...[
                Expanded(
                  child: ListView.builder(
                    controller: controller, // Gunakan controller dari DraggableScrollableSheet
                    itemCount: prov.user.addresses.length,
                    itemBuilder: (context, index) {
                      final address = prov.user.addresses[index];

                      return RadioListTile<String>(
                        title: Text(address),
                        value: address,
                        groupValue: prov.user.address,
                        activeColor: Colors.orange,
                        onChanged: (value) {
                          prov.setDefaultAddress(value!);
                          Navigator.pop(context); // Tutup bottom sheet
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Alamat berhasil diperbarui')),
                          );
                        },
                      );
                    },
                  ),
                ),
                const Divider(),
              ],

              // Bagian untuk menambah alamat baru
              const Text(
                'Tambah Alamat Baru',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _newAddressController,
                decoration: const InputDecoration(
                  hintText: 'Masukkan alamat baru',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final newAddress = _newAddressController.text.trim();
                    if (newAddress.isNotEmpty) {
                      // Tambahkan alamat baru
                      await prov.addAddress(newAddress);
                      // Langsung jadikan sebagai alamat utama
                      await prov.setDefaultAddress(newAddress);
                      Navigator.pop(context); // Tutup sheet
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Alamat baru berhasil ditambahkan'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Alamat tidak boleh kosong'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text('Simpan Alamat Baru'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildSearchBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[200],
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'What would you like to order?',
          // ✅ HAPUS 'const' di sini
          hintStyle: TextStyle(color: Colors.grey),
          // ✅ HAPUS 'const' di sini
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          // ✅ Gunakan logika ternary langsung (ini sekarang akan berhasil)
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  // ✅ HAPUS 'const' di sini juga
                  icon: Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      searchQuery = '';
                    });
                  },
                )
              : null,
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildCategories(AppProvider prov, bool isDark) {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final selected = cat['name'] == prov.selectedCategory;
          return GestureDetector(
            onTap: () => prov.setCategory(cat['name']),
            child: Container(
              width: 70,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.orange.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: selected
                          ? Colors.orange
                          : (isDark ? Colors.grey[800] : Colors.white),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      cat['icon'],
                      color: selected
                          ? Colors.white
                          : (isDark ? Colors.white70 : Colors.black87),
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cat['name'],
                    style: TextStyle(
                      color: selected
                          ? Colors.orange
                          : (isDark ? Colors.white70 : Colors.black87),
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedRestaurants(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Featured Restaurants',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 165, // lebih pendek agar tidak overflow
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: featuredRestaurants.length,
            itemBuilder: (context, index) {
              final restaurant = featuredRestaurants[index];
              return Container(
                width: 240, // sedikit diperkecil
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[850] : Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(15)),
                      child: Image.asset(
                        restaurant.image,
                        height: 85, // diperkecil
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            restaurant.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  size: 14, color: Colors.orange),
                              Text(' ${restaurant.rating}',
                                  style: const TextStyle(fontSize: 12)),
                              const SizedBox(width: 6),
                              const Icon(Icons.access_time,
                                  size: 14, color: Colors.grey),
                              Text(' ${restaurant.deliveryTime}',
                                  style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        )
      ],
    );
  }

  // Widget untuk Sidebar (Drawer) (SUDAH DIPERBAIKI)
  Widget _buildDrawer(AppProvider prov) {
    final prov = Provider.of<AppProvider>(context);
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(prov.user.name),
            accountEmail: Text(prov.user.email),
            // Gunakan avatar dummy sementara
            currentAccountPicture: CircleAvatar(
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
            decoration: const BoxDecoration(
              color: Colors.orange,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('My Profile'),
            onTap: () {
              Navigator.pop(context); // Tutup drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: const Text('My Orders'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OrderHistoryPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.local_offer),
            title: const Text('My Voucher'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => VoucherPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Delivery Address'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageAddressPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Log Out'),
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (route) => false);
            },
          ),
        ],
      ),
    );
  }
}

