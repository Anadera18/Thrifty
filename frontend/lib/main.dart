import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'firebase_options.dart';
import 'features/auth/presentation/screens/auth_startup_gate.dart';
import 'features/auth/presentation/widgets/seller_only_gate.dart';
import 'features/search/presentation/screens/search.dart';
import 'features/add_product/presentation/screens/add_product_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabasePublishableKey =
      String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
  if (supabaseUrl.isEmpty || supabasePublishableKey.isEmpty) {
    debugPrint(
      'Supabase config loaded: '
      'URL=${supabaseUrl.isNotEmpty}, '
      'publishable key=${supabasePublishableKey.isNotEmpty}.',
    );
    runApp(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Supabase configuration was not loaded. Check that '
                'frontend/supabase.env.json contains the exact keys '
                'SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY, then run Flutter '
                'with --dart-define-from-file=supabase.env.json from the '
                'frontend folder.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
    return;
  }

  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabasePublishableKey,
  );

  if (kDebugMode) {
    unawaited(_checkSupabaseConnection());
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  runApp(const ProviderScope(child: ThriftyApp()));
}

Future<void> _checkSupabaseConnection() async {
  try {
    final rows = await Supabase.instance.client
        .from('products')
        .select('id')
        .eq('status', 'active')
        .limit(1);
    debugPrint(
      'Supabase active-products smoke check passed '
      '(${rows.length} row(s) returned).',
    );
  } catch (error) {
    debugPrint('Supabase active-products smoke check failed: $error');
  }
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
      home: const AuthStartupGate(),

      // Daftar rute halaman
      routes: {
        '/search': (context) => const FilterSearchScreen(),
        '/sell-item': (context) => const SellerOnlyGate(
          child: AddProductScreen(),
        ),
      },
    );
  }
}
