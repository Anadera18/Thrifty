import 'dart:math' as math;
import 'package:flutter/material.dart';

/// THRIFTY logo (teal tile + shopping bag), drawn in code. No asset needed.
class ThriftyLogo extends StatelessWidget {
  const ThriftyLogo({super.key, this.size = 56});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _LogoPainter()),
    );
  }
}

class _LogoPainter extends CustomPainter {
  static const _tile = Color(0xFF0E3436);
  static const _mint = Color(0xFFE0FFF8);
  static const _turquoise = Color(0xFF34D8C4);

  @override
  void paint(Canvas canvas, Size size) {
    // Work in a 100 x 100 coordinate space.
    canvas.scale(size.width / 100, size.height / 100);

    // Tile
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 0, 100, 100),
        const Radius.circular(28),
      ),
      Paint()..color = _tile,
    );

    final bagStroke = Paint()
      ..color = _mint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Bag body
    final body = Path()
      ..moveTo(28, 35)
      ..lineTo(72, 35)
      ..lineTo(70, 74)
      ..quadraticBezierTo(69.5, 80, 63, 80)
      ..lineTo(37, 80)
      ..quadraticBezierTo(30.5, 80, 30, 74)
      ..close();
    canvas.drawPath(body, bagStroke);

    // Bag handle
    final handle = Path()
      ..moveTo(35, 35)
      ..lineTo(35, 28)
      ..quadraticBezierTo(35, 23, 40, 23)
      ..lineTo(60, 23)
      ..quadraticBezierTo(65, 23, 65, 28)
      ..lineTo(65, 35);
    canvas.drawPath(handle, bagStroke);

    // "U" smile
    final u = Path()
      ..moveTo(43, 46)
      ..lineTo(43, 51)
      ..arcTo(
        Rect.fromCircle(center: const Offset(49, 51), radius: 6),
        math.pi,
        -math.pi,
        false,
      )
      ..lineTo(55, 46);
    canvas.drawPath(
      u,
      Paint()
        ..color = _turquoise
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.8
        ..strokeCap = StrokeCap.round,
    );

    // Dot
    canvas.drawCircle(
      const Offset(63.2, 38.2),
      3.2,
      Paint()..color = _turquoise,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}