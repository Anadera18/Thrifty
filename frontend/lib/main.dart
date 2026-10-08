import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/auth/presentation/screens/login_screen.dart';

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
      home: const LoginScreen(),
    );
  }
}
