import 'dart:math' as math;
import 'package:flutter/material.dart';

/// The big circle on the location onboarding page.
///
/// For now it shows a drawn radar placeholder. LATER: pass a real map
/// (e.g. FlutterMap / GoogleMap) as [child] and it will be clipped to the
/// circle automatically:
///
///   LocationRadar(child: MyMapWidget())
class LocationRadar extends StatelessWidget {
  const LocationRadar({super.key, this.size = 190, this.child});

  final double size;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.08),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0x3322D3EE),
            blurRadius: 40,
            spreadRadius: 4,
          ),
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipOval(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              colors: [Color(0xFFF4FDFF), Color(0xFFE3F7FB)],
            ),
          ),
          child: child ??
              const CustomPaint(
                painter: _RadarPainter(),
                size: Size.infinite,
              ),
        ),
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  const _RadarPainter();

  static const _teal = Color(0xFF0E7490);

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;

    final ring = Paint()
      ..color = _teal.withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Rings
    for (final f in [0.34, 0.67, 1.0]) {
      canvas.drawCircle(c, r * f - 0.5, ring);
    }

    // Crosshair
    canvas.drawLine(Offset(c.dx - r, c.dy), Offset(c.dx + r, c.dy), ring);
    canvas.drawLine(Offset(c.dx, c.dy - r), Offset(c.dx, c.dy + r), ring);

    // Sweep wedge
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -math.pi / 2 - math.pi / 3,
      math.pi / 3,
      true,
      Paint()..color = const Color(0xFF22D3EE).withValues(alpha: 0.18),
    );

    // Seller pins (relative positions, -1..1)
    const pins = [
      Offset(0.45, -0.35),
      Offset(-0.5, -0.2),
      Offset(-0.25, 0.55),
      Offset(0.35, 0.45),
    ];
    for (final p in pins) {
      final o = c + Offset(p.dx * r * 0.8, p.dy * r * 0.8);
      canvas.drawCircle(o, 6, Paint()..color = Colors.white);
      canvas.drawCircle(o, 4, Paint()..color = const Color(0xFF14532D));
    }

    // "You" dot
    canvas.drawCircle(
      c,
      13,
      Paint()..color = const Color(0xFF22D3EE).withValues(alpha: 0.28),
    );
    canvas.drawCircle(c, 7, Paint()..color = Colors.white);
    canvas.drawCircle(c, 5, Paint()..color = _teal);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}