import 'package:flutter/material.dart';

/// Reuses the supplied Thrifty brand icon across the app.
class ThriftyLogo extends StatelessWidget {
  const ThriftyLogo({super.key, this.size = 56});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/thrifty_icon.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );
  }
}
