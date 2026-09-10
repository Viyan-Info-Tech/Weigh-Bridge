import 'package:flutter/material.dart';

class WeightDisplay extends StatelessWidget {
  final double netWeightTon;
  final double firstWeight;
  final double secondWeight;

  const WeightDisplay({
    super.key,
    required this.netWeightTon,
    required this.firstWeight,
    required this.secondWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          _buildTruckIllustration(),
          const SizedBox(height: 20),
          Text(
            '${netWeightTon.toStringAsFixed(3)} ton',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: Colors.grey.shade900,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildWeightIndicator('FIRST', firstWeight),
              _buildWeightIndicator('SECOND', secondWeight),
              _buildWeightIndicator('TARE', 0),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTruckIllustration() {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4F8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomPaint(
        painter: _TruckPainter(),
      ),
    );
  }

  Widget _buildWeightIndicator(String label, double value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade500,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${value.toStringAsFixed(0)} kg',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }
}

class _TruckPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final fillPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // Platform base
    canvas.drawLine(
      Offset(w * 0.1, h * 0.85),
      Offset(w * 0.9, h * 0.85),
      paint,
    );

    // Truck body
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.2, h * 0.35, w * 0.6, h * 0.35),
      const Radius.circular(4),
    );
    canvas.drawRRect(bodyRect, paint);

    // Cab
    final cabRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.65, h * 0.25, w * 0.18, h * 0.45),
      const Radius.circular(4),
    );
    canvas.drawRRect(cabRect, paint);

    // Wheels
    canvas.drawCircle(Offset(w * 0.3, h * 0.75), w * 0.06, fillPaint);
    canvas.drawCircle(Offset(w * 0.75, h * 0.75), w * 0.06, fillPaint);

    // Load cells
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.15, h * 0.85, w * 0.1, h * 0.08),
        const Radius.circular(2),
      ),
      fillPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.75, h * 0.85, w * 0.1, h * 0.08),
        const Radius.circular(2),
      ),
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
