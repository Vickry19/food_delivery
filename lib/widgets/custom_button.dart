// custom_button.dart
// Contoh tombol custom yang bisa digunakan di banyak tempat.
// (Opsional — jika ingin gaya konsisten)

import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color background;
  final Widget? icon;

  const CustomButton({super.key, required this.label, required this.onPressed, this.background = Colors.orange, this.icon});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: icon ?? const SizedBox.shrink(),
      label: Text(label),
      style: ElevatedButton.styleFrom(backgroundColor: background),
    );
  }
}
