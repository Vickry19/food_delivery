// lib/models/address.dart
class Address {
  String id;
  String fullName;
  String mobileNumber;
  String state;
  String city;
  String street;
  bool isDefault;

  Address({
    required this.id,
    required this.fullName,
    required this.mobileNumber,
    required this.state,
    required this.city,
    required this.street,
    this.isDefault = false,
  });

  String get displayShort => '$street, $city';

  Map<String, dynamic> toMap() => {
        'id': id,
        'fullName': fullName,
        'mobileNumber': mobileNumber,
        'state': state,
        'city': city,
        'street': street,
        'isDefault': isDefault,
      };

  factory Address.fromMap(Map<String, dynamic> m) => Address(
        id: m['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        fullName: m['fullName'] ?? '',
        mobileNumber: m['mobileNumber'] ?? '',
        state: m['state'] ?? '',
        city: m['city'] ?? '',
        street: m['street'] ?? '',
        isDefault: m['isDefault'] ?? false,
      );
}
