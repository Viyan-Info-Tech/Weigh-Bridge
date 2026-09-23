import 'package:flutter/material.dart';

class DashedDivider extends StatelessWidget {
  const DashedDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 1,
      child: CustomPaint(painter: _DashedLinePainter()),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0) return;
    const dashWidth = 4.0;
    const dashGap = 3.0;
    final paint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 1;
    var x = 0.0;
    final y = size.height / 2;
    while (x < size.width) {
      final endX = x + dashWidth;
      canvas.drawLine(
        Offset(x, y),
        Offset(endX > size.width ? size.width : endX, y),
        paint,
      );
      x += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
