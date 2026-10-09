import 'package:flutter/material.dart';

import 'pages/auth_pages.dart';

class ThriftyApp extends StatelessWidget {
  const ThriftyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF12373F);
    const mint = Color(0xFF14B8A6);
    const canvas = Color(0xFFF8FAFC);
    return MaterialApp(
      title: 'Thrifty',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'PlusJakartaSans',
        textTheme: _thriftyTextTheme(),
        scaffoldBackgroundColor: canvas,
        colorScheme: ColorScheme.fromSeed(
          seedColor: ink,
          primary: ink,
          secondary: mint,
          surface: canvas,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 17,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE2E9E8)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE2E9E8)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: ink, width: 1.5),
          ),
        ),
      ),
      home: const LoginPage(),
    );
  }
}

TextTheme _thriftyTextTheme() {
  final base = Typography.material2021().black.apply(
    fontFamily: 'PlusJakartaSans',
  );
  return base.copyWith(
    displayLarge: base.displayLarge?.copyWith(fontFamily: 'Epilogue'),
    displayMedium: base.displayMedium?.copyWith(fontFamily: 'Epilogue'),
    displaySmall: base.displaySmall?.copyWith(fontFamily: 'Epilogue'),
    headlineLarge: base.headlineLarge?.copyWith(fontFamily: 'Epilogue'),
    headlineMedium: base.headlineMedium?.copyWith(fontFamily: 'Epilogue'),
    headlineSmall: base.headlineSmall?.copyWith(fontFamily: 'Epilogue'),
  );
}
