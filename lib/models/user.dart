// lib/models/user.dart

class UserModel {
  // Properti tidak boleh 'final' agar bisa diubah
  String name;
  String email;
  String? phone;
  String? password;
  String? avatarPath;

  // ✅ PERUBAHAN 1: List untuk menyimpan SEMUA alamat pengguna
  // Diinisialisasi dengan list kosong saat objek dibuat
  List<String> addresses = [];

  // ✅ PERUBAHAN 2: Alamat yang SEDANG DIPILIH untuk pengiriman
  // Bisa null jika pengguna belum memilih alamat sama sekali
  String? address;

  // Konstruktor diperbarui
  UserModel({
    required this.name,
    required this.email,
    this.phone,
    this.password,
    this.avatarPath,
    // Bisa menerima list alamat dan alamat terpilih saat membuat objek
    List<String>? addresses,
    this.address,
  }) {
    // Jika ada alamat yang diberikan, gunakan, jika tidak kosongkan
    this.addresses = addresses ?? [];
  }

  // ✅ PERUBAHAN 3: Perbarui factory constructor `fromMap`
  factory UserModel.fromMap(Map<String, dynamic> map) {
    // Siapkan list alamat, dengan penanganan yang aman jika data tidak ada
    List<String> addressesList = [];
    if (map['addresses'] != null && map['addresses'] is List) {
      // Konversi List<dynamic> menjadi List<String>
      addressesList = List<String>.from(map['addresses']);
    }

    return UserModel(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      password: map['password'],
      phone: map['phone'],
      avatarPath: map['avatarPath'],
      // Gunakan list yang sudah disiapkan
      addresses: addressesList,
      // Alamat yang dipilih bisa null
      address: map['address'],
    );
  }

  // ✅ PERUBAHAN 4: Perbarui method `toMap`
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'avatarPath': avatarPath,
      // List akan otomatis dikonversi ke format yang bisa disimpan
      'addresses': addresses,
      'address': address,
    };
  }

  // ✅ TAMBAHAN: Method helper untuk mendapatkan alamat yang akan ditampilkan
  // Ini mempermudah di bagian UI
  String get displayAddress {
    // Jika ada alamat yang dipilih, tampilkan itu
    if (address != null && address!.isNotEmpty) {
      return address!;
    }
    // Jika ada alamat di list, tapi belum dipilih, tampilkan yang pertama
    if (addresses.isNotEmpty) {
      return addresses.first;
    }
    // Jika sama sekali tidak ada, tampilkan teks default
    return 'Set your address';
  }
}