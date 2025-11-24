// lib/providers/app_provider.dart

import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/food.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../models/user.dart'; // Pastikan ini mengimpor UserModel yang sudah diperbarui
import '../services/storage_service.dart';
import '../services/sample_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AppProvider extends ChangeNotifier {
  final SharedPreferences prefs;
  late final StorageService storage;

  // --- STATE VARIABLES ---
  // Gunakan satu properti user saja untuk menghindari kebingungan
  UserModel _user = UserModel(name: '', email: '', password: '');
  UserModel get user => _user;

  // --- THEME ---
  bool _isDark = false;
  bool get isDark => _isDark;

  // --- ADMIN ---
  bool _isAdmin = false;
  bool get isAdmin => _isAdmin;

  // --- FOODS ---
  List<Food> _foods = sampleFoods;
  List<Food> get foods => _foods;

  // --- CART ---
  final List<CartItem> _cart = [];
  List<CartItem> get cart => List.unmodifiable(_cart);

  // --- ORDERS ---
  List<OrderModel> _orders = [];
  List<OrderModel> get orders => _orders;

  // --- FAVORITES ---
  final List<Food> _favorites = [];
  List<Food> get favorites => List.unmodifiable(_favorites);

  // --- CATEGORY ---
  String _selectedCategory = 'Semua';
  String get selectedCategory => _selectedCategory;

  // --- VOUCHER SYSTEM (MENGGUNAKAN INT SECARA LENGKAP) ---
  String? _appliedVoucherCode;
  String? get appliedVoucherCode => _appliedVoucherCode;
  List<String> appliedVouchers = [];
  int totalVoucherDiscount = 0;


  // ✅ PERBAIKI: Gunakan int untuk diskon dan total
  int _currentVoucherDiscount = 0;
  int get currentVoucherDiscount => _currentVoucherDiscount;

  bool _isFreeDelivery = false;
  bool get isFreeDelivery => _isFreeDelivery;

  // ✅ PERBAIKI: Biaya pengiriman yang efektif juga int
  int get effectiveDeliveryFee => _isFreeDelivery ? 0 : 10000;

  // --- CHECKOUT ---
  String? _selectedAddress;
  String? get selectedAddress => _selectedAddress;

  // --- CONSTRUCTOR ---
  AppProvider(this.prefs) {
    storage = StorageService(prefs);

    // Load data saat inisialisasi
    _isDark = prefs.getBool('isDark') ?? false;
    _loadUser();
    _orders = storage.getOrders();
    _isAdmin = prefs.getBool('isAdmin') ?? false;
    _loadFavorites();
    _loadFoods();
  }

  // --- DATA LOADING ---
  Future<void> _loadUser() async {
    final userData = storage.getUser();
    if (userData != null) {
      _user = userData;
    }
    notifyListeners();
  }

  Future<void> _saveUser() async {
    await storage.saveUser(_user);
  }

  Future<void> loadUserData() async {
  User? currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser != null) {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();

    user.name = doc['name'];
    user.email = doc['email'];
    notifyListeners();
  }
}


  Future<void> _loadFavorites() async {
    final favData = prefs.getStringList('favorites') ?? [];
    _favorites.clear();
    for (var f in favData) {
      try {
        _favorites.add(Food.fromJson(jsonDecode(f)));
      } catch (_) {}
    }
    notifyListeners();
  }

  Future<void> _saveFavorites() async {
    final favData = _favorites.map((f) => jsonEncode(f.toJson())).toList();
    await prefs.setStringList('favorites', favData);
  }

  Future<void> _loadFoods() async {
    // Jika Anda ingin memuat dari storage, tambahkan logika di sini
    // Saat ini menggunakan sampleFoods
  }

  Future<void> _saveFoods() async {
    try {
      final list = _foods.map((f) => jsonEncode(f.toJson())).toList();
      await prefs.setStringList('foods', list);
    } catch (_) {}
  }

  // --- THEME TOGGLE ---
  void toggleTheme() {
    _isDark = !_isDark;
    prefs.setBool('isDark', _isDark);
    notifyListeners();
  }

  // --- AUTHENTICATION ---
  bool get isLoggedIn => storage.isLoggedIn;

  Future<void> login(String name, String email,
      {String? phone, String? address, bool isAdmin = false}) async {
    _user.name = name;
    _user.email = email;
    if (phone != null && phone.isNotEmpty) _user.phone = phone;
    if (address != null && address.isNotEmpty) {
      if (!_user.addresses.contains(address)) {
        _user.addresses.add(address);
      }
      _user.address = address; // Set sebagai alamat default
    }

    _isAdmin = isAdmin;
    await prefs.setBool('isAdmin', _isAdmin);

    await _saveUser();
    await storage.setLoggedIn(true);
    notifyListeners();
  }

  Future<void> logout() async {
    await storage.setLoggedIn(false);
    await prefs.remove('isAdmin');
    _isAdmin = false;
    notifyListeners();
  }

  // --- USER PROFILE ---
  Future<void> updateProfile(
      {String? name, String? email, String? phone, String? address}) async {
    if (name != null) _user.name = name;
    if (email != null) _user.email = email;
    if (phone != null) _user.phone = phone;
    if (address != null) {
      if (!_user.addresses.contains(address)) {
        _user.addresses.add(address);
      }
      _user.address = address;
    }

    await _saveUser();
    notifyListeners();
  }

  Future<void> updateAvatar(String? newPath) async {
    _user.avatarPath = newPath;
    await _saveUser();
    notifyListeners();
  }

  // --- CATEGORY FILTER ---
  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  List<Food> getFilteredFoods(List<Food> allFoods) {
    if (_selectedCategory == 'Semua') return allFoods;
    return allFoods.where((f) => f.category == _selectedCategory).toList();
  }

  // --- CART ---
  // ✅ PASTIKAN CARTTOTAL MENGEMBALIKAN INT
  int cartTotal() => _cart.fold(0, (prev, c) => prev + c.subtotal);

  void addToCart(Food food, {List<Map<String, dynamic>>? addOns}) {
    final existingItemIndex = _cart.indexWhere((c) =>
        c.food.id == food.id &&
        _listEquals(c.selectedAddOns, addOns ?? []));

    if (existingItemIndex >= 0) {
      _cart[existingItemIndex].qty++;
    } else {
      _cart.add(CartItem(
        food: food,
        qty: 1,
        selectedAddOns: addOns ?? [],
      ));
    }
    notifyListeners();
  }

  void removeFromCart(Food food) {
    _cart.removeWhere((c) => c.food.id == food.id);
    notifyListeners();
  }

  void changeQty(Food food, int qty) {
    final idx = _cart.indexWhere((c) => c.food.id == food.id);
    if (idx >= 0) {
      if (qty <= 0) {
        _cart.removeAt(idx);
      } else {
        _cart[idx].qty = qty;
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  // --- FAVORITES ---
  void toggleFavorite(Food food) async {
    final idx = _favorites.indexWhere((f) => f.id == food.id);
    if (idx >= 0) {
      _favorites.removeAt(idx);
    } else {
      _favorites.add(food);
    }
    await _saveFavorites();
    notifyListeners();
  }

  bool isFavorite(Food food) =>
      _favorites.any((f) => f.id == food.id);

  // --- VOUCHER SYSTEM (MENGGUNAKAN INT SECARA LENGKAP) ---
  // ✅ PERBAIKI: Hitung diskon sebagai int
  double applyVoucher(String code) {
    final total = cartTotal();
    int discount = 0;
    code = code.trim().toUpperCase();

    switch (code) {
      case 'HEMAT10':
        if (total >= 50000) {
          discount = (total * 0.10).round();
        } else {
          throw Exception('Minimal Rp50.000');
        }
        break;
      case 'HEMAT20':
        if (total >= 100000) {
          discount = (total * 0.20).round();
        } else {
          throw Exception('Minimal Rp100.000');
        }
        break;
      case 'GRATISONGKIR':
        if (total >= 30000) {
          _isFreeDelivery = true;
          discount = 0;
        } else {
          throw Exception('Minimal Rp30.000');
        }
        break;
      case 'MAKANENAK':
        if (total >= 100000) {
          discount = 25000;
        } else {
          throw Exception('Minimal Rp100.000');
        }
        break;
      default:
        throw Exception('Kode voucher tidak valid ❌');
    }

    _appliedVoucherCode = code;
    _currentVoucherDiscount = discount; // Simpan sebagai int
    notifyListeners();
    // ✅ KEMBALIKAN DOUBLE UNTUK UI YANG MASIH MENGGUNAKAN DOUBLE
    return discount.toDouble();
  }

  void clearVoucher() {
    _appliedVoucherCode = null;
    _currentVoucherDiscount = 0;
    _isFreeDelivery = false;
    notifyListeners();
  }

  // --- PAYMENT ---
  String generatePaymentCode() {
  final random = Random();
  return (100000 + random.nextInt(900000)).toString(); // 6 digit
}


  // --- ORDERS ---
  Future<void> removeOrder(String id) async {
    _orders.removeWhere((order) => order.id == id);
    await storage.saveOrders(_orders);
    notifyListeners();
  }

  // ✅ PERBAIKI: Metode placeOrder yang menerima parameter int
  Future<void> placeOrder({
    String? address,
    required String paymentMethod,
  }) async {
    if (_cart.isEmpty) return;

    // ✅ HITUNG SEMUA NILAI SECARA INTERNAL
    final subtotal = cartTotal();
    final total = (subtotal - _currentVoucherDiscount) + 11000 + effectiveDeliveryFee;
    final paymentCode = paymentMethod == "Cash on Delivery" ? null : generatePaymentCode();

    final usedAddress = (address ?? _user.address ?? '').isNotEmpty
        ? (address ?? _user.address!)
        : 'Alamat belum diatur';

    final order = OrderModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      items: List.from(_cart),
      address: usedAddress,
      paymentMethod: paymentMethod,
      time: DateTime.now(),
      status: 'Dalam Perjalanan',
      total: total, // ✅ total sudah bertipe int
      paymentCode: paymentCode,
    );

    _orders.insert(0, order);
    await storage.saveOrders(_orders);

    clearCart();
    clearVoucher();
    notifyListeners();
  }

  // --- UPDATE ORDER STATUS ---
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index >= 0) {
      final o = _orders[index];
      final updated = OrderModel(
        id: o.id,
        items: o.items,
        address: o.address,
        paymentMethod: o.paymentMethod,
        time: o.time,
        status: newStatus,
        total: o.total, // Total sudah int, tidak perlu diubah
        paymentCode: o.paymentCode,
      );
      _orders[index] = updated;
      await storage.saveOrders(_orders);
      notifyListeners();
    }
  }

  // ✅ METODE UNTUK MEMBATALKAN DAN MENYELESAIKAN PESANAN
  Future<void> cancelOrder(String orderId) async {
    await updateOrderStatus(orderId, 'Pesanan Dibatalkan');
  }

  Future<void> completeOrder(String orderId) async {
    await updateOrderStatus(orderId, 'Pesanan Selesai');
  }

  // --- CRUD FOODS ---
  Future<void> addFood(Food food) async {
    _foods.add(food);
    await _saveFoods();
    notifyListeners();
  }

  Future<void> updateFood(Food food) async {
    final idx = _foods.indexWhere((f) => f.id == food.id);
    if (idx >= 0) {
      _foods[idx] = food;
      await _saveFoods();
      notifyListeners();
    }
  }

  Future<void> deleteFood(dynamic id) async {
    _foods.removeWhere((f) => f.id.toString() == id.toString());
    await _saveFoods();
    notifyListeners();
  }

  // --- ADDRESS SYSTEM (MENGGUNAKAN USERMODEL) ---
  Future<void> addAddress(String address) async {
    if (!_user.addresses.contains(address)) {
      _user.addresses.add(address);
      if (_user.addresses.length == 1) {
        _user.address = address;
      }
      await _saveUser();
      notifyListeners();
    }
  }

  Future<void> updateAddressByIndex(int index, String newAddress) async {
    if (index >= 0 && index < _user.addresses.length) {
      final oldAddress = _user.addresses[index];
      _user.addresses[index] = newAddress;
      if (_user.address == oldAddress) {
        _user.address = newAddress;
      }
      await _saveUser();
      notifyListeners();
    }
  }

  Future<void> removeAddressByIndex(int index) async {
    if (index >= 0 && index < _user.addresses.length) {
      final removedAddress = _user.addresses[index];
      _user.addresses.removeAt(index);
      if (_user.address == removedAddress) {
        _user.address = _user.addresses.isNotEmpty ? _user.addresses.first : null;
      }
      await _saveUser();
      notifyListeners();
    }
  }

  Future<void> setDefaultAddress(String address) async {
    if (_user.addresses.contains(address)) {
      _user.address = address;
      await _saveUser();
      notifyListeners();
    }
  }

  void setSelectedAddress(String addr) {
    _selectedAddress = addr;
    notifyListeners();
  }

  // --- HELPERS ---
  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null || b == null) return a == b;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}