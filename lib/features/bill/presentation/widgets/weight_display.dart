import 'package:flutter/material.dart';
import 'truck_image_asset.dart';

/// Modern Commercial Semi-Trailer Truck Digital Weighbridge Scale Display
/// Features:
/// - Photorealistic European white cab-over commercial semi-truck on weighbridge platform
/// - Integrated high-tech digital scale display inside the cargo container body
/// - Neon 7-segment digital LED readout with ghost background segments
/// - Sub-metric weight summary breakdown (Gross, Tare, Net)
class WeightDisplay extends StatelessWidget {
  final double netWeightTon;
  final double grossWeight;
  final double tareWeight;
  final String weightUnit;

  const WeightDisplay({
    super.key,
    required this.netWeightTon,
    required this.grossWeight,
    required this.tareWeight,
    this.weightUnit = 'kg',
  });

  @override
  Widget build(BuildContext context) {
    // Format display tonnage from actual BillState
    final double activeWeight = netWeightTon;
    final String weightString = activeWeight.toStringAsFixed(3);
    final double netKg = netWeightTon * 1000;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 580;

          if (isCompact) {
            return _buildModernTruckScale(weightString, netKg);
          }

          return _buildModernTruckScale(weightString, netKg);
        },
      ),
    );
  }

  Widget _buildModernTruckScale(String weightString, double netKg) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 3.0,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;

            // Coordinates for digital display console on the container surface
            final containerLeft = w * 0.206;
            final containerTop = h * 0.055;
            final containerWidth = w * 0.788;
            final containerHeight = h * 0.637;

            return Stack(
              fit: StackFit.expand,
              children: [
                // 1. Complete Photorealistic Modern Commercial Semi-Truck
                Image.asset(
                  'assets/images/photorealistic_truck_scale.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Image.memory(
                    photorealisticTruckBytes,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        CustomPaint(painter: _FallbackModernTruckPainter()),
                  ),
                ),

                // 2. High-Tech Digital Scale Console embedded on the Container surface
                Positioned(
                  left: containerLeft + (containerWidth * 0.015),
                  top: containerTop + (containerHeight * 0.04),
                  width: containerWidth * 0.97,
                  height: containerHeight * 0.92,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: containerWidth * 0.03,
                      vertical: containerHeight * 0.05,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xE6081426), // Deep tinted digital glass
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF38BDF8).withValues(alpha: 0.35),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [

                        // Center: Prominent Glowing 7-Segment Digital Weight Readout
                        Expanded(
                          child: Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Faint ghost "88" unlit segments
                                  _buildGhostDigit(containerHeight * 0.44),
                                  const SizedBox(width: 3),
                                  _buildGhostDigit(containerHeight * 0.44),
                                  const SizedBox(width: 6),

                                  // Active 7-Segment digits for the weight (e.g. "2.000")
                                  ..._buildDigitalString(
                                      weightString, containerHeight * 0.48),

                                  const SizedBox(width: 8),

                                  // Unit label in matching electric green
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: containerHeight * 0.16),
                                    child: Text(
                                      weightUnit,
                                      style: const TextStyle(
                                        fontFamily: 'PlusJakartaSans',
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF00FF44),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Bottom Strip: Gross, Tare, Net Weight Summary
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'GROSS: ${grossWeight > 0 ? '${grossWeight.toStringAsFixed(0)} $weightUnit' : '—'}',
                                style: const TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                              Text(
                                'TARE: ${tareWeight > 0 ? '${tareWeight.toStringAsFixed(0)} $weightUnit' : '—'}',
                                style: const TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                              Text(
                                'NET: ${netKg > 0 ? '${netKg.toStringAsFixed(0)} $weightUnit' : '—'}',
                                style: const TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF38BDF8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }


  List<Widget> _buildDigitalString(String text, double digitHeight) {
    final widgets = <Widget>[];
    final digitWidth = digitHeight * 0.52;

    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      final nextIsDot = (i + 1 < text.length) && text[i + 1] == '.';

      if (char == '.') {
        continue;
      }

      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1.5),
          child: CustomPaint(
            size: Size(digitWidth, digitHeight),
            painter: _SevenSegmentPainter(
              char: char,
              hasDot: nextIsDot,
              litColor: const Color(0xFF00FF44),
              unlitColor: const Color(0x1800FF44),
            ),
          ),
        ),
      );
    }
    return widgets;
  }

  Widget _buildGhostDigit(double digitHeight) {
    final digitWidth = digitHeight * 0.52;
    return CustomPaint(
      size: Size(digitWidth, digitHeight),
      painter: const _SevenSegmentPainter(
        char: ' ',
        hasDot: false,
        litColor: Color(0xFF00FF44),
        unlitColor: Color(0x1400FF44),
        drawAllAsGhost: true,
      ),
    );
  }
}

/// Fallback vector painter rendering the complete modern European truck
/// Used in headless test environments or when images cannot be decoded
class _FallbackModernTruckPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Soft ground contact shadow
    final shadowPaint = Paint()..color = const Color(0x25000000);
    final shadowRect = Rect.fromLTWH(w * 0.04, h * 0.88, w * 0.94, h * 0.04);
    canvas.drawOval(shadowRect, shadowPaint);

    // Blue Trailer Container Box
    final containerPaint = Paint()..color = const Color(0xFF6BA3CC);
    final containerBorder = Paint()
      ..color = const Color(0xFF4A7C9E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    final containerRect =
        Rect.fromLTWH(w * 0.206, h * 0.055, w * 0.788, h * 0.637);
    canvas.drawRect(containerRect, containerPaint);
    canvas.drawRect(containerRect, containerBorder);

    // White Modern Cab-Over Tractor Body
    final cabPaint = Paint()..color = Colors.white;
    final cabBorder = Paint()
      ..color = const Color(0xFF94A3B8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final cabPath = Path()
      ..moveTo(w * 0.206, h * 0.82)
      ..lineTo(w * 0.05, h * 0.82)
      ..lineTo(w * 0.05, h * 0.50)
      ..lineTo(w * 0.11, h * 0.12)
      ..lineTo(w * 0.206, h * 0.04)
      ..close();
    canvas.drawPath(cabPath, cabPaint);
    canvas.drawPath(cabPath, cabBorder);

    // Windshield
    final darkWindow = Paint()..color = const Color(0xFF1E293B);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.065, h * 0.25, w * 0.09, h * 0.22),
        const Radius.circular(4),
      ),
      darkWindow,
    );

    // Wheels
    final tirePaint = Paint()..color = const Color(0xFF262626);
    final rimPaint = Paint()..color = const Color(0xFFE2E8F0);
    final wheelY = h * 0.85;
    final r = h * 0.09;

    for (final wx in [w * 0.12, w * 0.35, w * 0.65, w * 0.76, w * 0.87]) {
      canvas.drawCircle(Offset(wx, wheelY), r, tirePaint);
      canvas.drawCircle(Offset(wx, wheelY), r * 0.55, rimPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Precise 7-Segment Digital Digit Painter
class _SevenSegmentPainter extends CustomPainter {
  final String char;
  final bool hasDot;
  final Color litColor;
  final Color unlitColor;
  final bool drawAllAsGhost;

  const _SevenSegmentPainter({
    required this.char,
    required this.hasDot,
    required this.litColor,
    required this.unlitColor,
    this.drawAllAsGhost = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final t = w * 0.18;
    final g = t * 0.18;

    final segments = _getSegments(drawAllAsGhost ? '8' : char);

    final litPaint = Paint()
      ..color = drawAllAsGhost ? unlitColor : litColor
      ..style = PaintingStyle.fill;

    final unlitPaint = Paint()
      ..color = unlitColor
      ..style = PaintingStyle.fill;

    // Segment A (Top Horizontal)
    final pathA = Path()
      ..moveTo(g + t, 0)
      ..lineTo(w - g - t, 0)
      ..lineTo(w - g - t * 1.5, t)
      ..lineTo(g + t * 1.5, t)
      ..close();
    canvas.drawPath(pathA, segments[0] ? litPaint : unlitPaint);

    // Segment B (Top-Right Vertical)
    final pathB = Path()
      ..moveTo(w, g + t)
      ..lineTo(w, h * 0.5 - g)
      ..lineTo(w - t, h * 0.5 - g - t * 0.5)
      ..lineTo(w - t, g + t * 1.5)
      ..close();
    canvas.drawPath(pathB, segments[1] ? litPaint : unlitPaint);

    // Segment C (Bottom-Right Vertical)
    final pathC = Path()
      ..moveTo(w, h * 0.5 + g)
      ..lineTo(w, h - g - t)
      ..lineTo(w - t, h - g - t * 1.5)
      ..lineTo(w - t, h * 0.5 + g + t * 0.5)
      ..close();
    canvas.drawPath(pathC, segments[2] ? litPaint : unlitPaint);

    // Segment D (Bottom Horizontal)
    final pathD = Path()
      ..moveTo(g + t * 1.5, h - t)
      ..lineTo(w - g - t * 1.5, h - t)
      ..lineTo(w - g - t, h)
      ..lineTo(g + t, h)
      ..close();
    canvas.drawPath(pathD, segments[3] ? litPaint : unlitPaint);

    // Segment E (Bottom-Left Vertical)
    final pathE = Path()
      ..moveTo(0, h * 0.5 + g)
      ..lineTo(t, h * 0.5 + g + t * 0.5)
      ..lineTo(t, h - g - t * 1.5)
      ..lineTo(0, h - g - t)
      ..close();
    canvas.drawPath(pathE, segments[4] ? litPaint : unlitPaint);

    // Segment F (Top-Left Vertical)
    final pathF = Path()
      ..moveTo(0, g + t)
      ..lineTo(t, g + t * 1.5)
      ..lineTo(t, h * 0.5 - g - t * 0.5)
      ..lineTo(0, h * 0.5 - g)
      ..close();
    canvas.drawPath(pathF, segments[5] ? litPaint : unlitPaint);

    // Segment G (Middle Horizontal)
    final pathG = Path()
      ..moveTo(g + t * 1.5, h * 0.5)
      ..lineTo(g + t * 2, h * 0.5 - t * 0.5)
      ..lineTo(w - g - t * 2, h * 0.5 - t * 0.5)
      ..lineTo(w - g - t * 1.5, h * 0.5)
      ..lineTo(w - g - t * 2, h * 0.5 + t * 0.5)
      ..lineTo(g + t * 2, h * 0.5 + t * 0.5)
      ..close();
    canvas.drawPath(pathG, segments[6] ? litPaint : unlitPaint);

    // Decimal Point Dot
    if (hasDot) {
      final dotRadius = t * 0.55;
      canvas.drawCircle(
        Offset(w + dotRadius + 1, h - dotRadius),
        dotRadius,
        litPaint,
      );
    }
  }

  List<bool> _getSegments(String c) {
    switch (c) {
      case '0':
        return [true, true, true, true, true, true, false];
      case '1':
        return [false, true, true, false, false, false, false];
      case '2':
        return [true, true, false, true, true, false, true];
      case '3':
        return [true, true, true, true, false, false, true];
      case '4':
        return [false, true, true, false, false, true, true];
      case '5':
        return [true, false, true, true, false, true, true];
      case '6':
        return [true, false, true, true, true, true, true];
      case '7':
        return [true, true, true, false, false, false, false];
      case '8':
        return [true, true, true, true, true, true, true];
      case '9':
        return [true, true, true, true, false, true, true];
      case '-':
        return [false, false, false, false, false, false, true];
      default:
        return [false, false, false, false, false, false, false];
    }
  }

  @override
  bool shouldRepaint(covariant _SevenSegmentPainter oldDelegate) =>
      oldDelegate.char != char ||
      oldDelegate.hasDot != hasDot ||
      oldDelegate.litColor != litColor;
}
