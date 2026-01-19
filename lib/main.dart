import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/auth_service.dart';
import 'services/product_service.dart';
import 'services/order_service.dart';
import 'services/database_service.dart';
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'screens/splash_page.dart';
import 'screens/auth/login_page.dart';
import 'screens/auth/register_page.dart';
import 'screens/user/home_user.dart';
import 'screens/user/detail_product.dart';
import 'screens/user/orders_page.dart';
import 'screens/user/profile_page.dart';
import 'screens/user/settings_page.dart';
import 'screens/admin/home_admin.dart';
import 'screens/admin/add_product.dart';
import 'screens/admin/edit_product.dart';
import 'screens/cart_page.dart';
import 'utils/constants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final productService = ProductService(authService);
    final orderService = OrderService();
    final databaseService = DatabaseService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(authService)),
        ChangeNotifierProvider(create: (_) => ProductProvider(productService)),
        ChangeNotifierProvider(create: (_) => CartProvider(databaseService)),
        ChangeNotifierProvider(create: (_) => OrderProvider(orderService, authService)),
      ],
      child: MaterialApp(
        title: kAppName,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: kPrimaryColor,
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xFFF8FAFC),
          appBarTheme: AppBarTheme(
            elevation: 0,
            centerTitle: true,
            backgroundColor: kPrimaryColor,
            foregroundColor: Colors.white,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: kPrimaryColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: kErrorColor),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: kPrimaryColor,
            ),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (c) => const SplashPage(),
          '/login': (c) => const LoginPage(),
          '/register': (c) => const RegisterPage(),
          '/user': (c) => const HomeUser(),
          '/detail': (c) => const DetailProduct(),
          '/admin': (c) => const HomeAdmin(),
          '/admin/add': (c) => const AddProduct(),
          '/admin/edit': (c) => const EditProduct(),
          '/cart': (c) => const CartPage(),
          '/orders': (c) => const OrdersPage(),
          '/profile': (c) => const ProfilePage(),
          '/settings': (c) => const SettingsPage(),
        },
      ),
    );
  }
}
