import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopeefood_local/pages/register_page.dart';
import 'models/food.dart';
import 'providers/app_provider.dart';
import 'pages/splash_page.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/product_detail_page.dart';
import 'pages/cart_page.dart';
import 'pages/order_history_page.dart';
import 'pages/profile_page.dart';
import 'pages/voucher_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting('id_ID', null);
  final prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider(prefs),
      child: Consumer<AppProvider>(
        builder: (context, appProvider, _) {
          final isDark = appProvider.isDark;

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'MakanKuyy',
            theme: ThemeData(
              brightness: isDark ? Brightness.dark : Brightness.light,
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF64B5F6),
                brightness: isDark ? Brightness.dark : Brightness.light,
              ),
              scaffoldBackgroundColor:
                  isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
              appBarTheme: AppBarTheme(
                backgroundColor:
                    isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF),
                titleTextStyle: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                elevation: 0,
                iconTheme: IconThemeData(
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              textTheme: TextTheme(
                bodyMedium: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black87,
                  fontSize: 16,
                ),
                bodyLarge: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isDark ? const Color(0xFF64B5F6) : const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: isDark ? Colors.white10 : Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            initialRoute: '/',
            routes: {
              '/': (context) => const SplashPage(),
              '/login': (context) => const LoginPage(),
              '/home': (context) => const HomePage(),
              '/cart': (context) => const CartPage(),
              '/orders': (context) => const OrderHistoryPage(),
              '/profile': (context) => const ProfilePage(),
              '/orderHistory': (context) => const OrderHistoryPage(),
              '/voucher': (context) {
                final totalBelanja =
                    ModalRoute.of(context)!.settings.arguments as int?;
                return VoucherPage(totalBelanja: totalBelanja ?? 0);
              },
              '/register': (context) => const RegisterPage(),

            },
            onGenerateRoute: (settings) {
              if (settings.name == '/detail') {
                final food = settings.arguments as Food;
                return PageRouteBuilder(
                  pageBuilder: (_, __, ___) => ProductDetailPage(food: food),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    final fade = Tween(begin: 0.0, end: 1.0).animate(animation);
                    final offset =
                        Tween(begin: const Offset(0, 0.1), end: Offset.zero)
                            .animate(CurvedAnimation(
                                parent: animation, curve: Curves.easeInOut));
                    return FadeTransition(
                      opacity: fade,
                      child: SlideTransition(
                        position: offset,
                        child: child,
                      ),
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 400),
                );
              }
              return null;
            },
          );
        },
      ),
    );
  }
  
}
