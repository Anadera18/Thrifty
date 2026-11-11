import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'core/services/database_seeder.dart';
import 'features/onboarding/presentation/screens/welcome_flow.dart';
import 'features/search/presentation/screens/search.dart';
import 'features/product_detail/presentation/screens/product_detail.dart';
import 'features/add_product/presentation/screens/add_product_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Seed initial dummy data into Firestore if collection is empty
    await DatabaseSeeder.seedIfEmpty();
  } catch (e) {
    debugPrint('Firebase initialization or seeding failed: $e');
  }

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
      home: const ThriftySplashScreen(),

      // Daftar rute halaman
      routes: {
        '/search': (context) => const FilterSearchScreen(),
        '/product-detail': (context) => const ProductDetailScreen(),
        '/sell-item': (context) => const AddProductScreen(),
      },
    );
  }
}
