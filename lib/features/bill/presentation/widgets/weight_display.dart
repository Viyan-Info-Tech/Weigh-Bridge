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
    final double netVal = isKg ? widget.netWeightKg : widget.netWeightKg / 1000;
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
          colors: [Color(0xFF050B14), Color(0xFF091424), Color(0xFF050D1A)],
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
            Positioned.fill(child: CustomPaint(painter: _GlassGlarePainter())),

            // Main Console Layout
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: (consoleWidth * 0.022).clamp(4.0, 16.0),
                vertical: (consoleHeight * 0.035).clamp(2.0, 10.0),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- TOP INSTRUMENT STATUS BAR ---
                  _buildHeaderBar(theme, netKg, consoleWidth, consoleHeight),

                  // --- CENTER DIGITAL READOUT ---
                  Expanded(
                    child: Center(
                      child: _buildMainDigitalReadout(
                        weightString: weightString,
                        theme: theme,
                        consoleWidth: consoleWidth,
                        consoleHeight: consoleHeight,
                      ),
                    ),
                  ),

                  // --- BOTTOM TELEMETRY SUMMARY BAR ---
                  _buildTelemetryBottomBar(
                    netKg,
                    theme,
                    consoleWidth,
                    consoleHeight,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Responsive top status bar adapting between spacious 3-column and compact 2-row layouts
  Widget _buildHeaderBar(
    ScaleDisplayTheme theme,
    double netKg,
    double consoleWidth,
    double consoleHeight,
  ) {
    if (consoleWidth < 480) {
      // Compact layout for smaller desktop widths:
      // Row 1: Status indicator (left) + Theme chips (right)
      // Row 2: Centered dynamic load gauge
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatusIndicator(
                  theme,
                  consoleWidth,
                  consoleHeight,
                ),
              ),
              const SizedBox(width: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: _buildThemeSwitcher(theme, consoleWidth),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: _buildSegmentedLoadGauge(
                netKg,
                theme,
                consoleWidth,
                consoleHeight,
              ),
            ),
          ),
        ],
      );
    }

    // Standard / Large desktop layout: single spacious row with 3 flexible sections
    return SizedBox(
      height: (consoleHeight * 0.16).clamp(14.0, 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: Live scale heartbeat indicator
          Expanded(
            flex: 4,
            child: _buildStatusIndicator(theme, consoleWidth, consoleHeight),
          ),

          // Center: Segmented Dynamic LED Capacity Bar
          Expanded(
            flex: 3,
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: _buildSegmentedLoadGauge(
                  netKg,
                  theme,
                  consoleWidth,
                  consoleHeight,
                ),
              ),
            ),
          ),

          // Right: Color Theme Switcher Pills
          Expanded(
            flex: 4,
            child: Align(
              alignment: Alignment.centerRight,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: _buildThemeSwitcher(theme, consoleWidth),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Heartbeat status indicator with responsive text and dot
  Widget _buildStatusIndicator(
    ScaleDisplayTheme theme,
    double consoleWidth,
    double consoleHeight,
  ) {
    final dotSize = (consoleHeight * 0.065).clamp(5.0, 7.5);
    final fontSize = (consoleHeight * 0.075).clamp(6.5, 8.5);
    final statusText = consoleWidth < 380
        ? 'LIVE SCALE'
        : (consoleWidth < 520
            ? 'SCALE INDICATOR'
            : 'DIGITAL WEIGHBRIDGE INDICATOR');

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.accentColor,
            boxShadow: [
              BoxShadow(
                color: theme.accentColor.withValues(alpha: 0.8),
                blurRadius: 5,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        SizedBox(width: (dotSize * 0.8).clamp(3.0, 6.0)),
        Flexible(
          child: Text(
            statusText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.75),
              letterSpacing: 0.6,
            ),
          ),
        ),
      ],
    );
  }

  /// Theme switcher chips with scalable padding and font
  Widget _buildThemeSwitcher(ScaleDisplayTheme theme, double consoleWidth) {
    final isCompact = consoleWidth < 480;
    final hPad = isCompact ? 3.5 : 5.0;
    final vPad = isCompact ? 1.0 : 1.5;
    final fontSize = isCompact ? 6.5 : 7.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: ScaleDisplayTheme.values.map((t) {
        final isSelected = t == _selectedTheme;
        return InkWell(
          onTap: () => setState(() => _selectedTheme = t),
          borderRadius: BorderRadius.circular(4),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 1.5),
            padding: EdgeInsets.symmetric(
              horizontal: hPad,
              vertical: vPad,
            ),
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
                fontSize: fontSize,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected
                    ? t.accentColor
                    : Colors.white.withValues(alpha: 0.45),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Segmented dynamic load gauge (16 LED notches showing scale load percentage)
  Widget _buildSegmentedLoadGauge(
    double netKg,
    ScaleDisplayTheme theme,
    double consoleWidth,
    double consoleHeight,
  ) {
    const int totalSegments = 16;
    const double maxCapacityKg = 50000.0;
    final double ratio = (netKg / maxCapacityKg).clamp(0.0, 1.0);
    final int litSegments = (ratio * totalSegments).round();

    final segWidth = (consoleWidth * 0.0055).clamp(2.0, 3.5);
    final segHeight = (consoleHeight * 0.055).clamp(4.0, 6.5);
    final segSpacing = (consoleWidth * 0.002).clamp(0.6, 1.0);

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
          width: segWidth,
          height: segHeight,
          margin: EdgeInsets.symmetric(horizontal: segSpacing),
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
    required double consoleWidth,
    required double consoleHeight,
  }) {
    final digitHeight = (consoleHeight * 0.50).clamp(22.0, 58.0);
    final digitWidth = digitHeight * 0.56;
    final hPadding = (consoleWidth * 0.024).clamp(6.0, 14.0);
    final vPadding = (consoleHeight * 0.035).clamp(2.0, 5.0);
    final gapWidth = (digitHeight * 0.20).clamp(4.0, 14.0);

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: consoleWidth * 0.95,
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: vPadding),
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

              SizedBox(width: gapWidth),

              // High-Tech Unit Indicator Pill
              _buildUnitBadge(theme, digitHeight),
            ],
          ),
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

  /// High-tech unit badge with glow that scales smoothly with digitHeight
  Widget _buildUnitBadge(ScaleDisplayTheme theme, double digitHeight) {
    final unitLabelSize = (digitHeight * 0.13).clamp(5.5, 7.5);
    final unitTextSize = (digitHeight * 0.32).clamp(11.0, 17.0);
    final hPadding = (digitHeight * 0.15).clamp(4.0, 8.0);
    final vPadding = (digitHeight * 0.08).clamp(2.0, 5.0);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: vPadding),
      decoration: BoxDecoration(
        color: theme.accentColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(5),
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
              fontSize: unitLabelSize,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.5),
              letterSpacing: 0.8,
            ),
          ),
          SizedBox(height: (digitHeight * 0.02).clamp(0.5, 1.5)),
          Text(
            widget.weightUnit,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: unitTextSize,
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

  /// Bottom Strip: Gross, Tare, Net Weight Telemetry Breakdown with guaranteed responsiveness
  Widget _buildTelemetryBottomBar(
    double netKg,
    ScaleDisplayTheme theme,
    double consoleWidth,
    double consoleHeight,
  ) {
    final isCompact = consoleWidth < 400;
    final grossStr = _formatSummaryWeight(widget.grossWeight, widget.weightUnit);
    final tareStr = _formatSummaryWeight(widget.tareWeight, widget.weightUnit);
    final netStr = _formatSummaryWeight(netKg, widget.weightUnit);

    final grossLabel = isCompact ? 'G: $grossStr' : 'GROSS: $grossStr';
    final tareLabel = isCompact ? 'T: $tareStr' : 'TARE: $tareStr';
    final netLabel = isCompact ? 'N: $netStr' : 'NET: $netStr';

    final fontSize = (consoleHeight * 0.08).clamp(7.0, 9.0);

    return Container(
      height: (consoleHeight * 0.18).clamp(16.0, 24.0),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          // GROSS
          Expanded(
            child: _buildTelemetryMetric(
              label: grossLabel,
              color: const Color(0xFFCBD5E1),
              fontSize: fontSize,
            ),
          ),
          const SizedBox(width: 4),

          // TARE
          Expanded(
            child: _buildTelemetryMetric(
              label: tareLabel,
              color: const Color(0xFFCBD5E1),
              fontSize: fontSize,
            ),
          ),
          const SizedBox(width: 4),

          // NET (highlighted in theme accent)
          Expanded(
            child: _buildTelemetryMetric(
              label: netLabel,
              color: theme.accentColor,
              isHighlighted: true,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryMetric({
    required String label,
    required Color color,
    bool isHighlighted = false,
    required double fontSize,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isHighlighted
            ? color.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: fontSize,
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

  const _DecimalPointPainter({required this.litColor, required this.glowColor});

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
    final containerRect = Rect.fromLTWH(
      w * 0.206,
      h * 0.055,
      w * 0.788,
      h * 0.637,
    );
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
