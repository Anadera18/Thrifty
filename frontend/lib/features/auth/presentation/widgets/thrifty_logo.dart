import 'package:flutter/material.dart';

/// Reuses the official Thrifty mascot and brand logo across the app.
class ThriftyLogo extends StatelessWidget {
  const ThriftyLogo({
    super.key,
    this.size = 56,
    this.useFullLogo = false,
  });

  final double size;
  final bool useFullLogo;

  @override
  Widget build(BuildContext context) {
    if (useFullLogo) {
      return Image.asset(
        'assets/images/thrifty_logo.png',
        height: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      );
    }

    return Image.asset(
      'assets/images/thrifty_icon.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );
  }
}
