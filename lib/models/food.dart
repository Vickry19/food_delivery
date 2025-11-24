// models/food.dart
// Model representasi produk makanan/minuman dengan dukungan serialisasi JSON.

class Food {
  final int id;
  final String name;
  final String category;
  final String image;
  final String description;
  final int price;

  Food({
    required this.id,
    required this.name,
    required this.category,
    required this.image,
    required this.description,
    required this.price,
  });

  // ==== Factory untuk Map (misalnya dari database lokal) ====
  factory Food.fromMap(Map<String, dynamic> m) => Food(
        id: (m['id'] is int) ? m['id'] : int.tryParse(m['id'].toString()) ?? 0,
        name: m['name'] ?? '',
        category: m['category'] ?? '',
        image: m['image'] ?? '',
        description: m['description'] ?? '',
        price: (m['price'] as num).toInt(),
            
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'category': category,
        'image': image,
        'description': description,
        'price': price,
      };

  // ==== Tambahan: konversi ke/dari JSON ====
  factory Food.fromJson(Map<String, dynamic> json) => Food(
        id: (json['id'] is int)
            ? json['id']
            : int.tryParse(json['id'].toString()) ?? 0,
        name: json['name'] ?? '',
        category: json['category'] ?? '',
        image: json['image'] ?? '',
        description: json['description'] ?? '',
        price: (json['price'] as num).toInt(),
      );

  get rating => null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'image': image,
        'description': description,
        'price': price,
      };
}
