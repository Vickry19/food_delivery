// lib/services/storage_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/order.dart';
import '../models/address.dart';

class StorageService {
  final SharedPreferences prefs;
  StorageService(this.prefs);

  // ---------- User ----------
  Future<void> saveUser(UserModel user) async {
    try {
      await prefs.setString('user', jsonEncode(user.toMap()));
    } catch (_) {}
  }

  UserModel? getUser() {
    try {
      final s = prefs.getString('user');
      if (s == null) return null;
      return UserModel.fromMap(jsonDecode(s));
    } catch (_) {
      return null;
    }
  }

  Future<void> setLoggedIn(bool v) async {
    await prefs.setBool('loggedIn', v);
  }

  bool get isLoggedIn => prefs.getBool('loggedIn') ?? false;

  // ---------- Orders ----------
  Future<void> saveOrders(List<OrderModel> orders) async {
    try {
      final list = orders.map((o) => jsonEncode(o.toMap())).toList();
      await prefs.setStringList('orders', list);
    } catch (_) {}
  }

  List<OrderModel> getOrders() {
    try {
      final data = prefs.getStringList('orders') ?? [];
      return data.map((s) => OrderModel.fromMap(jsonDecode(s))).toList();
    } catch (_) {
      return [];
    }
  }

  // ---------- Addresses ----------
  Future<void> saveAddresses(List<Address> addresses) async {
    try {
      final list = addresses.map((a) => jsonEncode(a.toMap())).toList();
      await prefs.setStringList('addresses', list);
    } catch (_) {}
  }

  List<Address> getAddresses() {
    try {
      final data = prefs.getStringList('addresses') ?? [];
      return data.map((s) => Address.fromMap(jsonDecode(s))).toList();
    } catch (_) {
      return [];
    }
  }
}
