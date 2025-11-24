// cart_item.dart
// Model item pada keranjang; mengandung Food dan jumlah (qty).

import 'food.dart';

class CartItem {
  final Food food;
  int qty;

final List<Map<String, dynamic>> selectedAddOns;
  CartItem({required this.food, this.qty = 1 ,this.selectedAddOns = const [],});

  int get subtotal {
    int addOnsPrice = selectedAddOns.fold(0, (sum, addOn) => sum + (addOn['price'] as int));
    return (food.price + addOnsPrice) * qty;
  }

  Map<String, dynamic> toMap() => {
        'food': food.toMap(),
        'qty': qty,
      };

  factory CartItem.fromMap(Map<String, dynamic> m) => CartItem(
        food: Food.fromMap(Map<String, dynamic>.from(m['food'])),
        qty: m['qty'] as int,
      );
}
