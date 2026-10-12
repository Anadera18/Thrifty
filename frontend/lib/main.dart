import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/auth/presentation/screens/login_screen.dart';
import 'features/search/presentation/screens/search.dart';
import 'features/product_detail/presentation/screens/product_detail.dart';

void main() {
  runApp(const ProviderScope(child: ThriftyApp()));
}

class ThriftyApp extends StatelessWidget {
  const ThriftyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thrifty',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF14532D),
      ),

      // Halaman pertama aplikasi
      home: const  FilterSearchScreen(),

      // Daftar rute halaman
      routes: {
        '/search': (context) => const FilterSearchScreen(),
        '/product-detail': (context) => const ProductDetailScreen(),
      },
    );
  }
}
