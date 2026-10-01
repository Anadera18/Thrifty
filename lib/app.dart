import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'pages/marketplace_page.dart';

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const MarketplacePage()),
  ],
);

class ThriftyApp extends StatelessWidget {
  const ThriftyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const brand = Color(0xFF12373F);
    return MaterialApp.router(
      title: 'Thrifty',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: brand),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF8FAFC),
          surfaceTintColor: Colors.transparent,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: brand,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      routerConfig: _router,
    );
  }
}
