import 'package:flutter/material.dart';

/// The official brand logo for Viyan Weighbridge.
/// Renders the high-tech stylized 'V' monogram emblem with a vector fallback.
class ViyanWeighbridgeLogo extends StatelessWidget {
  final double size;
  final bool withBackground;
  final bool withGlow;
  final Color? tintColor;

  const ViyanWeighbridgeLogo({
    super.key,
    this.size = 52,
    this.withBackground = true,
    this.withGlow = true,
    this.tintColor,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(size * 0.22);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: withGlow
            ? [
                BoxShadow(
                  color: const Color(0xFF00F5FF).withValues(alpha: 0.35),
                  blurRadius: size * 0.25,
                  offset: const Offset(0, 2),
                ),
                BoxShadow(
                  color: const Color(0xFF0D3B82).withValues(alpha: 0.3),
                  blurRadius: size * 0.4,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Image.asset(
          'assets/images/viyan_logo.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => CustomPaint(
            size: Size(size, size),
            painter: _ViyanVLogoPainter(
              color: tintColor ?? const Color(0xFF00F5FF),
            ),
          ),
        ),
      ),
    );
  }
}

/// Backwards-compatible alias for existing references
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
    return ViyanWeighbridgeLogo(size: size, withGlow: true, tintColor: color);
  }
}

/// High-tech vector fallback painter for the Viyan 'V' monogram emblem
class _ViyanVLogoPainter extends CustomPainter {
  final Color color;

  _ViyanVLogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Dark rounded squircle background
    final bgPaint = Paint()..color = const Color(0xFF07111E);
    final bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      Radius.circular(w * 0.22),
    );
    canvas.drawRRect(bgRect, bgPaint);

    // Border
    final borderPaint = Paint()
      ..color = const Color(0xFF00F5FF).withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.03;
    canvas.drawRRect(bgRect, borderPaint);

    // Outer V wing path
    final outerVPath = Path()
      ..moveTo(w * 0.18, h * 0.24)
      ..lineTo(w * 0.36, h * 0.24)
      ..lineTo(w * 0.50, h * 0.65)
      ..lineTo(w * 0.64, h * 0.24)
      ..lineTo(w * 0.82, h * 0.24)
      ..lineTo(w * 0.58, h * 0.82)
      ..lineTo(w * 0.42, h * 0.82)
      ..close();

    // Inner glow
    final glowPaint = Paint()
      ..color = const Color(0xFF00F5FF).withValues(alpha: 0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
    canvas.drawPath(outerVPath, glowPaint);

    // Core V
    final vPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFE2E8F0), Color(0xFF00F5FF), Color(0xFF0D3B82)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(outerVPath, vPaint);

    // Center precision chevron
    final innerChevron = Path()
      ..moveTo(w * 0.40, h * 0.36)
      ..lineTo(w * 0.50, h * 0.52)
      ..lineTo(w * 0.60, h * 0.36)
      ..lineTo(w * 0.54, h * 0.36)
      ..lineTo(w * 0.50, h * 0.44)
      ..lineTo(w * 0.46, h * 0.36)
      ..close();

    final chevronPaint = Paint()
      ..color = const Color(0xFF00F5FF)
      ..style = PaintingStyle.fill;
    canvas.drawPath(innerChevron, chevronPaint);
  }

  @override
  bool shouldRepaint(covariant _ViyanVLogoPainter oldDelegate) =>
      oldDelegate.color != color;
}
