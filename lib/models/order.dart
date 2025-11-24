// order.dart
// Model untuk menyimpan riwayat pesanan.

import 'cart_item.dart';

class OrderModel {
  final String id;
  final List<CartItem> items;
  final String address;
  final String paymentMethod;
  final DateTime time;
  final String status;
  final int total;
  final String? paymentCode;

  OrderModel({
    required this.id,
    required this.items,
    required this.address,
    required this.paymentMethod,
    required this.time,
    required this.status,
    required this.total,
    this.paymentCode,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'items': items.map((e) => e.toMap()).toList(),
        'address': address,
        'paymentMethod': paymentMethod,
        'time': time.toIso8601String(),
        'status': status,
        'total': total,
        'paymentCode': paymentCode,
      };

  factory OrderModel.fromMap(Map<String, dynamic> json) => OrderModel(
        id: json['id'],
        items: List<Map<String, dynamic>>.from(json['items'])
            .map((e) => CartItem.fromMap(e))
            .toList(),
        address: json['address'],
        paymentMethod: json['paymentMethod'],
        time: DateTime.parse(json['time']),
        status: json['status'],
        total: (json['total'] as num).toInt(),
        paymentCode: json['paymentCode'],
      );
}
