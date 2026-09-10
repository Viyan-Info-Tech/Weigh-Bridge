import 'package:flutter/material.dart';

/// Interactive Truck-Style Digital Weighbridge Scale Display
/// Matching the hardware terminal aesthetic with:
/// - Stylized semi-truck silhouette with orange cab and green scale icon
/// - Vertical LED level indicator bar graph
/// - 7-segment green digital LED trailer display with ghost background segments
/// - Triple tandem wheels and realistic chassis details
/// - Quick action pill buttons on the right: FIRST, SECOND, TARE
class WeightDisplay extends StatelessWidget {
  final double netWeightTon;
  final double firstWeight;
  final double secondWeight;
  final VoidCallback? onFirstPressed;
  final VoidCallback? onSecondPressed;
  final VoidCallback? onTarePressed;

  const WeightDisplay({
    super.key,
    required this.netWeightTon,
    required this.firstWeight,
    required this.secondWeight,
    this.onFirstPressed,
    this.onSecondPressed,
    this.onTarePressed,
  });

  @override
  Widget build(BuildContext context) {
    // Format display tonnage (defaults to 2.000 if weight is 0 for initial UI preview)
    final double activeWeight = netWeightTon > 0
        ? netWeightTon
        : (firstWeight > 0 ? (firstWeight / 1000) : 2.000);
    final String weightString = activeWeight.toStringAsFixed(3);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTruckScaleArea(weightString),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildPillButton(context, 'FIRST', onFirstPressed),
                    _buildPillButton(context, 'SECOND', onSecondPressed),
                    _buildPillButton(context, 'TARE', onTarePressed),
                  ],
                ),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Truck Digital Scale Readout Display
              Expanded(
                child: _buildTruckScaleArea(weightString),
              ),
              const SizedBox(width: 14),
              // Action Buttons Column: FIRST, SECOND, TARE
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildPillButton(context, 'FIRST', onFirstPressed),
                  const SizedBox(height: 10),
                  _buildPillButton(context, 'SECOND', onSecondPressed),
                  const SizedBox(height: 10),
                  _buildPillButton(context, 'TARE', onTarePressed),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTruckScaleArea(String weightString) {
    return AspectRatio(
      aspectRatio: 3.55,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;

          // Trailer display region boundaries
          final trailerLeft = w * 0.20;
          final trailerTop = h * 0.08;
          final trailerWidth = w * 0.76;
          final trailerHeight = h * 0.72;

          return Stack(
            children: [
              // 1. Truck Body & Hardware Custom Painter
              Positioned.fill(
                child: CustomPaint(
                  painter: _TruckSilhouettePainter(),
                ),
              ),

              // 2. LED 7-Segment Digital Readout overlay on the trailer
              Positioned(
                left: trailerLeft,
                top: trailerTop,
                width: trailerWidth,
                height: trailerHeight,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: trailerWidth * 0.04,
                    vertical: trailerHeight * 0.08,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Faint ghost "88" unlit segments on the left
                      _buildGhostDigit(trailerHeight * 0.65),
                      const SizedBox(width: 4),
                      _buildGhostDigit(trailerHeight * 0.65),
                      const SizedBox(width: 8),

                      // Active 7-Segment digits for the weight value (e.g. "2.000")
                      ..._buildDigitalString(
                          weightString, trailerHeight * 0.68),

                      const SizedBox(width: 8),

                      // Unit "ton" label in green
                      Padding(
                        padding: EdgeInsets.only(top: trailerHeight * 0.22),
                        child: Text(
                          'ton',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: (trailerHeight * 0.32).clamp(12, 26),
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF00FF44),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      SizedBox(width: trailerWidth * 0.04),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
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
        continue; // Handled as decimal point on preceding digit
      }

      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: CustomPaint(
            size: Size(digitWidth, digitHeight),
            painter: _SevenSegmentPainter(
              char: char,
              hasDot: nextIsDot,
              litColor: const Color(0xFF00FF44),
              unlitColor: const Color(0x1600FF44),
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
        unlitColor: Color(0x1200FF44), // Very faint 888 pattern
        drawAllAsGhost: true,
      ),
    );
  }

  Widget _buildPillButton(
      BuildContext context, String label, VoidCallback? onPressed) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed ??
            () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$label scale action triggered'),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: 96,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF94A3B8), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0284C7),
              letterSpacing: 0.8,
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter for the complete truck silhouette:
/// - Green balance scale icon
/// - Orange cabin with window, roof deflector & bumper
/// - Vertical LED level indicator meter
/// - Solid black trailer scale box with chassis beam
/// - Front wheel and triple tandem rear wheels with white rims
class _TruckSilhouettePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Ground line near the bottom
    final groundY = h * 0.94;
    final wheelRadius = h * 0.16;
    final wheelCenterY = groundY - wheelRadius;

    // Paints
    final blackPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final borderStroke = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final orangePaint = Paint()
      ..color = const Color(0xFFF97316)
      ..style = PaintingStyle.fill;

    final brownPaint = Paint()
      ..color = const Color(0xFF8D6E63)
      ..style = PaintingStyle.fill;

    final windowPaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..style = PaintingStyle.fill;

    // 1. Draw Balance Scale Icon above cabin (top left)
    _drawScaleIcon(canvas, Offset(w * 0.036, h * 0.08), h * 0.16);

    // 2. Draw Trailer Display Body (solid black container)
    final trailerLeft = w * 0.19;
    final trailerTop = h * 0.08;
    final trailerWidth = w * 0.78;
    final trailerHeight = h * 0.72;

    final trailerRect =
        Rect.fromLTWH(trailerLeft, trailerTop, trailerWidth, trailerHeight);
    canvas.drawRect(trailerRect, blackPaint);
    canvas.drawRect(trailerRect, borderStroke);

    // 3. Brown Chassis Runner / Beam under the trailer and extending forward
    final chassisRect = Rect.fromLTWH(
        w * 0.16, trailerTop + trailerHeight - 2, w * 0.80, h * 0.04);
    canvas.drawRect(chassisRect, brownPaint);
    canvas.drawRect(chassisRect, borderStroke);

    // 4. White vertical reflector at the rear trailer edge
    final reflectorRect = Rect.fromLTWH(
        trailerLeft + trailerWidth - (w * 0.012),
        trailerTop + trailerHeight * 0.65,
        w * 0.008,
        trailerHeight * 0.28);
    canvas.drawRect(reflectorRect, Paint()..color = const Color(0xFFE2E8F0));

    // 5. Cabin Body (Orange Cab on the left)
    final cabLeft = w * 0.035;
    final cabRight = w * 0.185;
    final cabBottom = trailerTop + trailerHeight;
    final cabRoofY = h * 0.18;
    final cabWindshieldTopX = cabLeft + (cabRight - cabLeft) * 0.25;

    final cabPath = Path()
      ..moveTo(cabRight, cabBottom)
      ..lineTo(cabLeft, cabBottom)
      ..lineTo(cabLeft, h * 0.40)
      ..lineTo(cabWindshieldTopX, cabRoofY)
      ..lineTo(cabRight, cabRoofY)
      ..close();

    canvas.drawPath(cabPath, orangePaint);
    canvas.drawPath(cabPath, borderStroke);

    // Orange Roof Spoiler / Air Deflector on cab
    final spoilerPath = Path()
      ..moveTo(cabWindshieldTopX + 2, cabRoofY)
      ..lineTo(cabWindshieldTopX + (cabRight - cabWindshieldTopX) * 0.6, h * 0.08)
      ..lineTo(cabRight - 2, cabRoofY)
      ..close();
    canvas.drawPath(spoilerPath, orangePaint);
    canvas.drawPath(spoilerPath, borderStroke);

    // Cabin Windshield / Window
    final windowPath = Path()
      ..moveTo(cabWindshieldTopX + 2, cabRoofY + (h * 0.06))
      ..lineTo(cabLeft + (cabRight - cabLeft) * 0.28, h * 0.46)
      ..lineTo(cabRight - (w * 0.015), h * 0.46)
      ..lineTo(cabRight - (w * 0.015), cabRoofY + (h * 0.06))
      ..close();
    canvas.drawPath(windowPath, windowPaint);
    canvas.drawPath(windowPath, borderStroke);

    // Front Bumper Block (small brown/black bumper on front bottom)
    final bumperRect = Rect.fromLTWH(
        cabLeft - (w * 0.012), cabBottom - (h * 0.07), w * 0.016, h * 0.07);
    canvas.drawRect(bumperRect, brownPaint);
    canvas.drawRect(bumperRect, borderStroke);

    // 6. Vertical LED Level Indicator Meter (between cab and trailer)
    _drawLedLevelMeter(
      canvas,
      Rect.fromLTWH(
        cabRight + 1,
        trailerTop + (h * 0.04),
        (trailerLeft - cabRight - 2).clamp(6.0, 16.0),
        trailerHeight - (h * 0.08),
      ),
    );

    // 7. Wheels
    // Front Wheel (under cabin)
    final frontWheelX = cabLeft + (cabRight - cabLeft) * 0.58;
    _drawWheel(canvas, Offset(frontWheelX, wheelCenterY), wheelRadius);

    // Three Tandem Rear Wheels (under trailer right side)
    final wheelSpacing = wheelRadius * 1.85;
    final rearWheel3X = trailerLeft + trailerWidth - (wheelRadius * 1.6);
    final rearWheel2X = rearWheel3X - wheelSpacing;
    final rearWheel1X = rearWheel2X - wheelSpacing;

    _drawWheel(canvas, Offset(rearWheel1X, wheelCenterY), wheelRadius);
    _drawWheel(canvas, Offset(rearWheel2X, wheelCenterY), wheelRadius);
    _drawWheel(canvas, Offset(rearWheel3X, wheelCenterY), wheelRadius);
  }

  void _drawScaleIcon(Canvas canvas, Offset center, double size) {
    final paint = Paint()
      ..color = const Color(0xFF22C55E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = const Color(0xFF22C55E)
      ..style = PaintingStyle.fill;

    final cx = center.dx;
    final cy = center.dy;
    final halfW = size * 0.45;
    final halfH = size * 0.45;

    // Central pillar
    canvas.drawLine(Offset(cx, cy - halfH), Offset(cx, cy + halfH), paint);
    // Base
    canvas.drawLine(
        Offset(cx - halfW * 0.5, cy + halfH), Offset(cx + halfW * 0.5, cy + halfH), paint);
    // Crossbar
    canvas.drawLine(Offset(cx - halfW, cy - halfH * 0.5),
        Offset(cx + halfW, cy - halfH * 0.5), paint);

    // Left pan
    final leftPanX = cx - halfW;
    final panTopY = cy - halfH * 0.5;
    final panBottomY = cy + halfH * 0.35;
    canvas.drawLine(Offset(leftPanX, panTopY), Offset(leftPanX - 4, panBottomY), paint);
    canvas.drawLine(Offset(leftPanX, panTopY), Offset(leftPanX + 4, panBottomY), paint);
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(leftPanX, panBottomY), width: 12, height: 6),
      0,
      3.14159,
      true,
      fillPaint,
    );

    // Right pan
    final rightPanX = cx + halfW;
    canvas.drawLine(Offset(rightPanX, panTopY), Offset(rightPanX - 4, panBottomY), paint);
    canvas.drawLine(Offset(rightPanX, panTopY), Offset(rightPanX + 4, panBottomY), paint);
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(rightPanX, panBottomY), width: 12, height: 6),
      0,
      3.14159,
      true,
      fillPaint,
    );
  }

  void _drawLedLevelMeter(Canvas canvas, Rect rect) {
    const int totalBars = 10;
    final barHeight = rect.height / (totalBars * 1.5);
    final barGap = barHeight * 0.5;

    final bgPaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawRect(rect, bgPaint);

    for (int i = 0; i < totalBars; i++) {
      // Inverted index: 0 is top (Red), totalBars-1 is bottom (Green)
      Color barColor;
      if (i < 2) {
        barColor = const Color(0xFFEF4444); // Red
      } else if (i < 5) {
        barColor = const Color(0xFFFBBF24); // Amber
      } else {
        barColor = const Color(0xFF22C55E); // Green
      }

      // 6 bars lit from bottom upward
      final isLit = i >= 4;
      final paint = Paint()
        ..color = isLit ? barColor : barColor.withValues(alpha: 0.15)
        ..style = PaintingStyle.fill;

      final y = rect.top + i * (barHeight + barGap);
      final barRect =
          Rect.fromLTWH(rect.left + 1, y, rect.width - 2, barHeight);
      canvas.drawRect(barRect, paint);
    }
  }

  void _drawWheel(Canvas canvas, Offset center, double radius) {
    // 1. Outer Dark Rubber Tire
    final tirePaint = Paint()..color = const Color(0xFF262626);
    canvas.drawCircle(center, radius, tirePaint);

    // Tire border
    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, radius, borderPaint);

    // 2. White/Light Silver Wheel Rim with border
    final rimRadius = radius * 0.62;
    final rimPaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, rimRadius, rimPaint);
    canvas.drawCircle(center, rimRadius, borderPaint);

    // 3. Grey Center Hub
    final hubRadius = radius * 0.32;
    final hubPaint = Paint()..color = const Color(0xFF737373);
    canvas.drawCircle(center, hubRadius, hubPaint);
    canvas.drawCircle(center, hubRadius, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Precise 7-Segment Digital Digit Painter
/// Generates authentic LED display segments with bevels and optional decimal dot
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
    final t = w * 0.18; // Segment thickness
    final g = t * 0.18; // Gap between segments

    // Segment activation map
    final segments = _getSegments(drawAllAsGhost ? '8' : char);

    // Paints
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

  /// Returns [A, B, C, D, E, F, G] boolean flags for each segment
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
