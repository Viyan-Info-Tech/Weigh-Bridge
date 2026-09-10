import 'package:flutter/material.dart';

/// A custom-painted vector logo depicting a truck on a weighbridge platform,
/// matching the brand mark in the top-left of the login screen.
class TruckWeighbridgeLogo extends StatelessWidget {
  final double size;
  final Color color;

  const TruckWeighbridgeLogo({
    super.key,
    this.size = 52,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * 0.95),
      painter: _TruckLogoPainter(color: color),
    );
  }
}

class _TruckLogoPainter extends CustomPainter {
  final Color color;

  _TruckLogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.055
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // 1. Truck Cab Outline
    final cabPath = Path();
    final cabLeft = w * 0.18;
    final cabRight = w * 0.82;
    final cabTop = h * 0.12;
    final cabBottom = h * 0.72;
    final r = w * 0.08;

    cabPath.moveTo(cabLeft + r, cabTop);
    cabPath.lineTo(cabRight - r, cabTop);
    cabPath.arcToPoint(
      Offset(cabRight, cabTop + r),
      radius: Radius.circular(r),
    );
    cabPath.lineTo(cabRight, cabBottom);
    cabPath.lineTo(cabLeft, cabBottom);
    cabPath.lineTo(cabLeft, cabTop + r);
    cabPath.arcToPoint(Offset(cabLeft + r, cabTop), radius: Radius.circular(r));
    canvas.drawPath(cabPath, strokePaint);

    // 2. Windshield
    final windshieldR = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.26, h * 0.22, w * 0.48, h * 0.22),
      Radius.circular(w * 0.04),
    );
    canvas.drawRRect(windshieldR, strokePaint);

    // 3. Grille (Horizontal lines)
    final grillePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.045
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(w * 0.35, h * 0.54),
      Offset(w * 0.65, h * 0.54),
      grillePaint,
    );
    canvas.drawLine(
      Offset(w * 0.35, h * 0.62),
      Offset(w * 0.65, h * 0.62),
      grillePaint,
    );

    // 4. Headlights (round or capsule dots on sides)
    canvas.drawCircle(Offset(w * 0.24, h * 0.60), w * 0.035, fillPaint);
    canvas.drawCircle(Offset(w * 0.76, h * 0.60), w * 0.035, fillPaint);

    // 5. Side mirrors
    final mirrorPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.045
      ..strokeCap = StrokeCap.round;

    // Left mirror
    canvas.drawLine(
      Offset(cabLeft, h * 0.26),
      Offset(w * 0.08, h * 0.26),
      mirrorPaint,
    );
    canvas.drawLine(
      Offset(w * 0.08, h * 0.22),
      Offset(w * 0.08, h * 0.38),
      mirrorPaint,
    );

    // Right mirror
    canvas.drawLine(
      Offset(cabRight, h * 0.26),
      Offset(w * 0.92, h * 0.26),
      mirrorPaint,
    );
    canvas.drawLine(
      Offset(w * 0.92, h * 0.22),
      Offset(w * 0.92, h * 0.38),
      mirrorPaint,
    );

    // 6. Wheels (left and right at bottom)
    final wheelLeft = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.08, h * 0.58, w * 0.09, h * 0.24),
      Radius.circular(w * 0.03),
    );
    final wheelRight = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.83, h * 0.58, w * 0.09, h * 0.24),
      Radius.circular(w * 0.03),
    );
    canvas.drawRRect(wheelLeft, fillPaint);
    canvas.drawRRect(wheelRight, fillPaint);

    // 7. Weighbridge Platform Bar (Scale deck underneath)
    final platformPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.065
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(w * 0.04, h * 0.86),
      Offset(w * 0.96, h * 0.86),
      platformPaint,
    );

    // Load cell / base stands below the platform
    final standPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.16, h * 0.89, w * 0.12, h * 0.08),
        Radius.circular(w * 0.015),
      ),
      standPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.72, h * 0.89, w * 0.12, h * 0.08),
        Radius.circular(w * 0.015),
      ),
      standPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _TruckLogoPainter oldDelegate) =>
      oldDelegate.color != color;
}
