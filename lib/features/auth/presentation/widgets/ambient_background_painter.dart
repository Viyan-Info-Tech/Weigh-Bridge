import 'package:flutter/material.dart';

/// Painter for the subtle concentric circular arcs in the blue branding panel.
class BlueConcentricArcsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Center point for the concentric circles near the top right of the left panel
    final center = Offset(size.width * 0.72, size.height * 0.18);

    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final glowPaint = Paint()
      ..color = const Color(0xFF60A5FA).withValues(alpha: 0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);

    // Subtle ambient glow
    canvas.drawCircle(center, size.width * 0.45, glowPaint);

    // Concentric rings
    final radii = [
      size.width * 0.35,
      size.width * 0.55,
      size.width * 0.75,
      size.width * 0.95,
      size.width * 1.15,
      size.width * 1.40,
    ];

    for (final r in radii) {
      canvas.drawCircle(center, r, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Painter for the soft ambient circular arcs on the top-right of the login panel.
class LoginSoftRingsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.98, size.height * 0.08);

    final ringPaint1 = Paint()
      ..color = const Color(0xFFE0EDFD).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 32;

    final ringPaint2 = Paint()
      ..color = const Color(0xFFEEF6FF).withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 48;

    final ringPaint3 = Paint()
      ..color = const Color(0xFFF3F8FF).withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 64;

    canvas.drawCircle(center, size.width * 0.42, ringPaint3);
    canvas.drawCircle(center, size.width * 0.30, ringPaint2);
    canvas.drawCircle(center, size.width * 0.18, ringPaint1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Painter for the dynamic swoosh underline beneath "Weigh Today Build Tomorrow".
class ScriptUnderlinePainter extends CustomPainter {
  final Color color;

  ScriptUnderlinePainter({this.color = Colors.white});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    path.moveTo(0, size.height * 0.75);
    path.quadraticBezierTo(
      size.width * 0.45,
      size.height * 1.1,
      size.width,
      size.height * 0.15,
    );

    final paint = Paint()
      ..color = color.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant ScriptUnderlinePainter oldDelegate) =>
      oldDelegate.color != color;
}
