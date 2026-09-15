import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'truck_image_asset.dart';

/// Supported digital display color themes
enum ScaleDisplayTheme {
  electricCyan(
    label: 'Cyan',
    accentColor: Color(0xFF00F5FF),
    glowColor: Color(0xFF00C8FF),
    bgTint: Color(0xFF001A26),
    unlitColor: Color(0x1200F5FF),
  ),
  cyberEmerald(
    label: 'Emerald',
    accentColor: Color(0xFF00FF88),
    glowColor: Color(0xFF05DF72),
    bgTint: Color(0xFF002414),
    unlitColor: Color(0x1200FF88),
  ),
  industrialAmber(
    label: 'Amber',
    accentColor: Color(0xFFFFB300),
    glowColor: Color(0xFFF59E0B),
    bgTint: Color(0xFF261800),
    unlitColor: Color(0x12FFB300),
  ),
  iceWhite(
    label: 'Ice',
    accentColor: Color(0xFFF1F5F9),
    glowColor: Color(0xFF94A3B8),
    bgTint: Color(0xFF0F172A),
    unlitColor: Color(0x12FFFFFF),
  );

  final String label;
  final Color accentColor;
  final Color glowColor;
  final Color bgTint;
  final Color unlitColor;

  const ScaleDisplayTheme({
    required this.label,
    required this.accentColor,
    required this.glowColor,
    required this.bgTint,
    required this.unlitColor,
  });
}

/// Ultra-Modern Commercial Semi-Trailer Truck Digital Weighbridge Scale Display
/// Features:
/// - Photorealistic European white cab-over commercial semi-truck on weighbridge platform
/// - High-tech luxury digital glass instrument console embedded on the cargo container
/// - Precision-engineered 7-segment slanted LED readout with realistic multi-layer neon bloom
/// - Smoked optical glass effect with diagonal gloss reflection sheen
/// - Dynamic segmented LED capacity load bar (0 to 50,000 kg)
/// - Interactive multi-color theme switcher (Electric Cyan, Cyber Emerald, Amber, Ice White)
/// - Telemetry metrics breakdown (Gross, Tare, Net)
class WeightDisplay extends StatefulWidget {
  final double netWeightKg;
  final double grossWeight;
  final double tareWeight;
  final String weightUnit;

  const WeightDisplay({
    super.key,
    required this.netWeightKg,
    required this.grossWeight,
    required this.tareWeight,
    this.weightUnit = 'kg',
  });

  @override
  State<WeightDisplay> createState() => _WeightDisplayState();
}

class _WeightDisplayState extends State<WeightDisplay> {
  // Default to the stunning modern Electric Cyan theme
  ScaleDisplayTheme _selectedTheme = ScaleDisplayTheme.electricCyan;

  @override
  Widget build(BuildContext context) {
    final isKg = widget.weightUnit.toLowerCase() == 'kg';
    final double netVal =
        isKg ? widget.netWeightKg : widget.netWeightKg / 1000;
    final String weightString = isKg
        ? (netVal > 0 ? netVal.toStringAsFixed(0) : '0')
        : (netVal > 0 ? netVal.toStringAsFixed(3) : '0.000');

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
          return _buildModernTruckScale(weightString, widget.netWeightKg);
        },
      ),
    );
  }

  String _formatSummaryWeight(double valKg, String unit) {
    if (valKg <= 0) return '0 $unit';
    final isTon = unit.toLowerCase() == 'ton' || unit.toLowerCase() == 'tonne';
    if (isTon) {
      return '${(valKg / 1000).toStringAsFixed(3)} ton';
    }
    return '${valKg.toStringAsFixed(0)} kg';
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

            // Precise coordinates for the digital console on the container surface
            final containerLeft = w * 0.206;
            final containerTop = h * 0.055;
            final containerWidth = w * 0.788;
            final containerHeight = h * 0.637;

            return Stack(
              fit: StackFit.expand,
              children: [
                // 1. Complete Photorealistic Commercial Semi-Truck
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

                // 2. High-Tech Glass Digital Scale Console
                Positioned(
                  left: containerLeft + (containerWidth * 0.012),
                  top: containerTop + (containerHeight * 0.035),
                  width: containerWidth * 0.976,
                  height: containerHeight * 0.93,
                  child: _buildDigitalConsole(
                    weightString: weightString,
                    netKg: netKg,
                    consoleWidth: containerWidth * 0.976,
                    consoleHeight: containerHeight * 0.93,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Builds the complete modern digital weighbridge terminal console
  Widget _buildDigitalConsole({
    required String weightString,
    required double netKg,
    required double consoleWidth,
    required double consoleHeight,
  }) {
    final theme = _selectedTheme;

    return Container(
      decoration: BoxDecoration(
        // Deep obsidian multi-layer dark glass
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF050B14),
            Color(0xFF091424),
            Color(0xFF050D1A),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.accentColor.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: theme.glowColor.withValues(alpha: 0.08),
            blurRadius: 16,
            spreadRadius: -2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: Stack(
          children: [
            // Optical Glass Diagonal Sheen / Glare Highlight
            Positioned.fill(
              child: CustomPaint(
                painter: _GlassGlarePainter(),
              ),
            ),

            // Main Console Layout
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: consoleWidth * 0.024,
                vertical: consoleHeight * 0.04,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- TOP INSTRUMENT STATUS BAR ---
                  _buildHeaderBar(theme, netKg, consoleHeight),

                  // --- CENTER DIGITAL READOUT ---
                  Expanded(
                    child: Center(
                      child: _buildMainDigitalReadout(
                        weightString: weightString,
                        theme: theme,
                        consoleHeight: consoleHeight,
                      ),
                    ),
                  ),

                  // --- BOTTOM TELEMETRY SUMMARY BAR ---
                  _buildTelemetryBottomBar(netKg, theme, consoleHeight),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Top micro status bar with live scale status, dynamic LED load bar, and theme chips
  Widget _buildHeaderBar(ScaleDisplayTheme theme, double netKg, double consoleHeight) {
    return SizedBox(
      height: consoleHeight * 0.16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: Live scale heartbeat indicator
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.accentColor,
                  boxShadow: [
                    BoxShadow(
                      color: theme.accentColor.withValues(alpha: 0.8),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'DIGITAL WEIGHBRIDGE INDICATOR',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.7),
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),

          // Center: Segmented Dynamic LED Capacity Bar (0 to 50,000 kg capacity)
          _buildSegmentedLoadGauge(netKg, theme),

          // Right: Color Theme Switcher Pills
          Row(
            mainAxisSize: MainAxisSize.min,
            children: ScaleDisplayTheme.values.map((t) {
              final isSelected = t == _selectedTheme;
              return InkWell(
                onTap: () => setState(() => _selectedTheme = t),
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? t.accentColor.withValues(alpha: 0.25)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(
                      color: isSelected
                          ? t.accentColor
                          : Colors.white.withValues(alpha: 0.12),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    t.label,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 7,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                      color: isSelected
                          ? t.accentColor
                          : Colors.white.withValues(alpha: 0.45),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Segmented dynamic load gauge (16 LED notches showing scale load percentage)
  Widget _buildSegmentedLoadGauge(double netKg, ScaleDisplayTheme theme) {
    const int totalSegments = 16;
    const double maxCapacityKg = 50000.0;
    final double ratio = (netKg / maxCapacityKg).clamp(0.0, 1.0);
    final int litSegments = (ratio * totalSegments).round();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalSegments, (index) {
        final bool isLit = index < litSegments;
        Color segColor;
        if (index > 13) {
          segColor = const Color(0xFFEF4444); // Overload warning red
        } else if (index > 10) {
          segColor = const Color(0xFFF59E0B); // High capacity amber
        } else {
          segColor = theme.accentColor;
        }

        return Container(
          width: 3,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: isLit ? segColor : Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(0.8),
            boxShadow: isLit
                ? [
                    BoxShadow(
                      color: segColor.withValues(alpha: 0.6),
                      blurRadius: 3,
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }

  /// Prominent, ultra-crisp 7-Segment weight digits with unit badge
  Widget _buildMainDigitalReadout({
    required String weightString,
    required ScaleDisplayTheme theme,
    required double consoleHeight,
  }) {
    final digitHeight = (consoleHeight * 0.52).clamp(24.0, 58.0);
    final digitWidth = digitHeight * 0.56;

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: theme.bgTint.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.accentColor.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Slanted LED Digits Container
            Transform(
              transform: Matrix4.skewX(-0.10), // 6° modern aerodynamic slant
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: _buildDigitsWithSmokedBackground(
                  weightString: weightString,
                  digitWidth: digitWidth,
                  digitHeight: digitHeight,
                  theme: theme,
                ),
              ),
            ),

            const SizedBox(width: 14),

            // High-Tech Unit Indicator Pill
            _buildUnitBadge(theme, digitHeight),
          ],
        ),
      ),
    );
  }

  /// Builds the digits row with elegant, smoked-glass unlit background segments
  List<Widget> _buildDigitsWithSmokedBackground({
    required String weightString,
    required double digitWidth,
    required double digitHeight,
    required ScaleDisplayTheme theme,
  }) {
    final List<Widget> widgets = [];

    // Format display to 5 slots: leading unlit slots gracefully rendered in smoked glass
    // e.g. for "0", 4 unlit digits + "0"
    final int pureDigitsCount = weightString.replaceAll('.', '').length;
    final int leadingSlots = math.max(0, 5 - pureDigitsCount);

    // Subtle leading unlit digit slots (classic high-end industrial scale look)
    for (int s = 0; s < leadingSlots; s++) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: CustomPaint(
            size: Size(digitWidth, digitHeight),
            painter: _PrecisionSevenSegmentPainter(
              char: ' ',
              litColor: theme.accentColor,
              glowColor: theme.glowColor,
              unlitColor: theme.unlitColor,
              drawAllAsGhost: true,
            ),
          ),
        ),
      );
    }

    // Active Weight Digits
    for (int i = 0; i < weightString.length; i++) {
      final char = weightString[i];

      if (char == '.') {
        // Dedicated Glowing Decimal Point
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.5),
            child: SizedBox(
              width: digitWidth * 0.28,
              height: digitHeight,
              child: CustomPaint(
                painter: _DecimalPointPainter(
                  litColor: theme.accentColor,
                  glowColor: theme.glowColor,
                ),
              ),
            ),
          ),
        );
        continue;
      }

      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: CustomPaint(
            size: Size(digitWidth, digitHeight),
            painter: _PrecisionSevenSegmentPainter(
              char: char,
              litColor: theme.accentColor,
              glowColor: theme.glowColor,
              unlitColor: theme.unlitColor,
              drawAllAsGhost: false,
            ),
          ),
        ),
      );
    }

    return widgets;
  }

  /// High-tech unit badge with glow
  Widget _buildUnitBadge(ScaleDisplayTheme theme, double digitHeight) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: theme.accentColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: theme.accentColor.withValues(alpha: 0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.glowColor.withValues(alpha: 0.15),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'UNIT',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 6.5,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.5),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            widget.weightUnit,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: theme.accentColor,
              letterSpacing: 0.5,
              shadows: [
                Shadow(
                  color: theme.glowColor.withValues(alpha: 0.8),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Bottom Strip: Gross, Tare, Net Weight Telemetry Breakdown
  Widget _buildTelemetryBottomBar(double netKg, ScaleDisplayTheme theme, double consoleHeight) {
    return Container(
      height: consoleHeight * 0.18,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // GROSS
          _buildTelemetryMetric(
            label: 'GROSS: ${_formatSummaryWeight(widget.grossWeight, widget.weightUnit)}',
            color: const Color(0xFFCBD5E1),
          ),

          // TARE
          _buildTelemetryMetric(
            label: 'TARE: ${_formatSummaryWeight(widget.tareWeight, widget.weightUnit)}',
            color: const Color(0xFFCBD5E1),
          ),

          // NET (highlighted in theme accent)
          _buildTelemetryMetric(
            label: 'NET: ${_formatSummaryWeight(netKg, widget.weightUnit)}',
            color: theme.accentColor,
            isHighlighted: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryMetric({
    required String label,
    required Color color,
    bool isHighlighted = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isHighlighted
            ? color.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 8.5,
          fontWeight: isHighlighted ? FontWeight.w800 : FontWeight.w600,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

/// Precision 7-Segment LED Digit Painter
/// Generates mathematically perfect hexagonal 45-degree chamfered LED light pipes
/// with realistic neon bloom and smoked-glass unlit segment channels.
class _PrecisionSevenSegmentPainter extends CustomPainter {
  final String char;
  final Color litColor;
  final Color glowColor;
  final Color unlitColor;
  final bool drawAllAsGhost;

  const _PrecisionSevenSegmentPainter({
    required this.char,
    required this.litColor,
    required this.glowColor,
    required this.unlitColor,
    this.drawAllAsGhost = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Golden-ratio slender segment thickness & micro-gap
    final t = w * 0.138;
    final g = t * 0.22;

    final segments = _getSegments(drawAllAsGhost ? '8' : char);

    // Unlit segment paint (subtle dark smoked acrylic)
    final unlitPaint = Paint()
      ..color = unlitColor
      ..style = PaintingStyle.fill;

    // Outer Neon Bloom Paint
    final bloomPaint = Paint()
      ..color = glowColor.withValues(alpha: 0.40)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);

    // Crisp Lit Core Paint
    final litCorePaint = Paint()
      ..color = litColor
      ..style = PaintingStyle.fill;

    // 7 Segments Geometry (A to G)
    final segmentPaths = <Path>[
      // A: Top Horizontal
      _buildHorizontalSegment(
        left: t + g,
        right: w - t - g,
        yCenter: t * 0.5,
        thickness: t,
        gap: g,
      ),
      // B: Top-Right Vertical
      _buildVerticalSegment(
        top: t + g,
        bottom: h * 0.5 - g,
        xCenter: w - t * 0.5,
        thickness: t,
        gap: g,
      ),
      // C: Bottom-Right Vertical
      _buildVerticalSegment(
        top: h * 0.5 + g,
        bottom: h - t - g,
        xCenter: w - t * 0.5,
        thickness: t,
        gap: g,
      ),
      // D: Bottom Horizontal
      _buildHorizontalSegment(
        left: t + g,
        right: w - t - g,
        yCenter: h - t * 0.5,
        thickness: t,
        gap: g,
      ),
      // E: Bottom-Left Vertical
      _buildVerticalSegment(
        top: h * 0.5 + g,
        bottom: h - t - g,
        xCenter: t * 0.5,
        thickness: t,
        gap: g,
      ),
      // F: Top-Left Vertical
      _buildVerticalSegment(
        top: t + g,
        bottom: h * 0.5 - g,
        xCenter: t * 0.5,
        thickness: t,
        gap: g,
      ),
      // G: Middle Horizontal
      _buildHorizontalSegment(
        left: t + g,
        right: w - t - g,
        yCenter: h * 0.5,
        thickness: t,
        gap: g,
      ),
    ];

    // Pass 1: Render unlit smoked glass segments
    for (int i = 0; i < 7; i++) {
      if (!segments[i] || drawAllAsGhost) {
        canvas.drawPath(segmentPaths[i], unlitPaint);
      }
    }

    // Pass 2: If active, render luminous neon bloom
    if (!drawAllAsGhost) {
      for (int i = 0; i < 7; i++) {
        if (segments[i]) {
          canvas.drawPath(segmentPaths[i], bloomPaint);
        }
      }
    }

    // Pass 3: If active, render crisp brilliant core
    if (!drawAllAsGhost) {
      for (int i = 0; i < 7; i++) {
        if (segments[i]) {
          canvas.drawPath(segmentPaths[i], litCorePaint);
        }
      }
    }
  }

  /// Builds a precision 45-degree beveled horizontal segment hexagon
  Path _buildHorizontalSegment({
    required double left,
    required double right,
    required double yCenter,
    required double thickness,
    required double gap,
  }) {
    final halfT = thickness * 0.5;
    return Path()
      ..moveTo(left, yCenter)
      ..lineTo(left + halfT, yCenter - halfT)
      ..lineTo(right - halfT, yCenter - halfT)
      ..lineTo(right, yCenter)
      ..lineTo(right - halfT, yCenter + halfT)
      ..lineTo(left + halfT, yCenter + halfT)
      ..close();
  }

  /// Builds a precision 45-degree beveled vertical segment hexagon
  Path _buildVerticalSegment({
    required double top,
    required double bottom,
    required double xCenter,
    required double thickness,
    required double gap,
  }) {
    final halfT = thickness * 0.5;
    return Path()
      ..moveTo(xCenter, top)
      ..lineTo(xCenter + halfT, top + halfT)
      ..lineTo(xCenter + halfT, bottom - halfT)
      ..lineTo(xCenter, bottom)
      ..lineTo(xCenter - halfT, bottom - halfT)
      ..lineTo(xCenter - halfT, top + halfT)
      ..close();
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
  bool shouldRepaint(covariant _PrecisionSevenSegmentPainter oldDelegate) =>
      oldDelegate.char != char ||
      oldDelegate.litColor != litColor ||
      oldDelegate.glowColor != glowColor ||
      oldDelegate.unlitColor != unlitColor ||
      oldDelegate.drawAllAsGhost != drawAllAsGhost;
}

/// Precision glowing decimal point LED
class _DecimalPointPainter extends CustomPainter {
  final Color litColor;
  final Color glowColor;

  const _DecimalPointPainter({
    required this.litColor,
    required this.glowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final dotRadius = (w * 0.42).clamp(2.0, 4.5);
    final dotCenter = Offset(w * 0.5, h - dotRadius * 2.0);

    // Neon Bloom
    final bloomPaint = Paint()
      ..color = glowColor.withValues(alpha: 0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
    canvas.drawCircle(dotCenter, dotRadius + 1.5, bloomPaint);

    // Brilliant Core
    final corePaint = Paint()
      ..color = litColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(dotCenter, dotRadius, corePaint);
  }

  @override
  bool shouldRepaint(covariant _DecimalPointPainter oldDelegate) =>
      oldDelegate.litColor != litColor || oldDelegate.glowColor != glowColor;
}

/// Diagonal gloss reflection sheen across optical glass
class _GlassGlarePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final glarePath = Path()
      ..moveTo(0, 0)
      ..lineTo(w * 0.55, 0)
      ..lineTo(0, h * 0.85)
      ..close();

    final glarePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.07),
          Colors.white.withValues(alpha: 0.01),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawPath(glarePath, glarePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
