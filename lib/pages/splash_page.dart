// splash_page.dart
// Halaman splash sederhana yang mengecek status login lalu navigasi.

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import 'login_page.dart';
import 'home_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    // Timer singkat lalu cek login
    Timer(const Duration(milliseconds: 1000), () {
      final prov = Provider.of<AppProvider>(context, listen: false);
      if (prov.isLoggedIn) {
        Navigator.pushReplacement(context, _createRoute(const HomePage()));
      } else {
        Navigator.pushReplacement(context, _createRoute(const LoginPage()));
      }
    });
  }

  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, a1, a2) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 3000),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange,
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: const [
          Icon(Icons.fastfood, color: Colors.white, size: 64),
          SizedBox(height: 12),
          Text('MakanKuyy', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))
        ]),
      ),
    );
  }
}
