import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Industrial Weighbridge Scale Display Banner
/// Matches the high-contrast dual-camera + central LED weight indicator design:
/// - Left: CCTV Camera 01 view (live scale platform preview)
/// - Center: Beveled graphite frame with massive neon-green LED weight readout ("0 Kg")
/// - Right: CCTV Camera 02 view (alternate scale platform perspective)
/// - Far Right: STABLE, MOTION, OVERLOAD telemetry LED indicators
class WeightDisplay extends StatefulWidget {
  final double netWeightKg;
  final double grossWeight;
  final double tareWeight;
  final String weightUnit;
  final bool isStable;
  final bool isMotion;
  final bool isOverload;
  final double? liveScaleWeightKg;
  final String? activeMode;

  final VoidCallback? onNavigateToReports;
  final VoidCallback? onNavigateToMaterials;

  const WeightDisplay({
    super.key,
    required this.netWeightKg,
    required this.grossWeight,
    required this.tareWeight,
    this.weightUnit = 'kg',
    this.isStable = true,
    this.isMotion = false,
    this.isOverload = false,
    this.liveScaleWeightKg,
    this.activeMode,
    this.onNavigateToReports,
    this.onNavigateToMaterials,
  });

  @override
  State<WeightDisplay> createState() => _WeightDisplayState();
}

class _WeightDisplayState extends State<WeightDisplay> {
  @override
  Widget build(BuildContext context) {
    final gross = widget.grossWeight;
    final tare = widget.tareWeight;

    // Determine weight value to display:
    // If liveScaleWeightKg is provided, display live scale weight
    // Otherwise fallback to captured Net/Gross/Tare/Zero
    final double displayWeightKg;
    final String modeLabel;
    if (widget.liveScaleWeightKg != null) {
      displayWeightKg = widget.liveScaleWeightKg!;
      modeLabel = widget.activeMode ?? (displayWeightKg > 0 ? 'LIVE' : 'ZERO');
    } else if (gross > 0 && tare > 0) {
      displayWeightKg = widget.netWeightKg > 0
          ? widget.netWeightKg
          : (gross - tare).abs();
      modeLabel = 'NET';
    } else if (gross > 0) {
      displayWeightKg = gross;
      modeLabel = 'GROSS';
    } else if (tare > 0) {
      displayWeightKg = tare;
      modeLabel = 'TARE';
    } else {
      displayWeightKg = 0;
      modeLabel = 'ZERO';
    }

    final isKg = widget.weightUnit.toLowerCase() == 'kg';
    final double displayVal = isKg ? displayWeightKg : displayWeightKg / 1000;
    final String weightString = isKg
        ? (displayVal != 0 ? NumberFormat('#,##0').format(displayVal) : '0')
        : (displayVal != 0
              ? NumberFormat('#,##0.000').format(displayVal)
              : '0.000');

    final unitLabel = isKg ? 'Kg' : 'Ton';

    return Container(
      height: 154,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return _buildCenterDigitalConsole(
              weightString: weightString,
              unitLabel: unitLabel,
              modeLabel: modeLabel,
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Left Quick Access: Reports
              Expanded(
                flex: 25,
                child: _buildQuickNavButton(
                  icon: Icons.bar_chart_rounded,
                  title: 'REPORTS',
                  accentColor: const Color(0xFFFBBF24),
                  onTap: widget.onNavigateToReports,
                  tooltip: 'Open Reports Screen',
                ),
              ),

              const SizedBox(width: 8),

              // 2. Center Obsidian Digital Weight Readout
              Expanded(
                flex: 50,
                child: _buildCenterDigitalConsole(
                  weightString: weightString,
                  unitLabel: unitLabel,
                  modeLabel: modeLabel,
                ),
              ),

              const SizedBox(width: 8),

              // 3. Right Quick Access: Materials
              Expanded(
                flex: 25,
                child: _buildQuickNavButton(
                  icon: Icons.category_rounded,
                  title: 'MATERIALS',
                  accentColor: const Color(0xFF38BDF8),
                  onTap: widget.onNavigateToMaterials,
                  tooltip: 'Open Materials Master',
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Quick-access navigation action button for Reports and Materials
  Widget _buildQuickNavButton({
    required IconData icon,
    required String title,
    required Color accentColor,
    required VoidCallback? onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 300),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF334155), Color(0xFF1E293B), Color(0xFF0F172A)],
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF475569), width: 2.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(3.0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(5),
            hoverColor: accentColor.withValues(alpha: 0.12),
            splashColor: accentColor.withValues(alpha: 0.22),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF050B14),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: const Color(0xFF1E293B), width: 1.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: accentColor,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 10,
                        color: accentColor.withValues(alpha: 0.7),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Center(
                      child: Icon(
                        icon,
                        size: 90,
                        color: accentColor,
                        shadows: [
                          Shadow(
                            color: accentColor.withValues(alpha: 0.45),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Center Beveled Graphite Console with Glowing Neon-Green Readout
  Widget _buildCenterDigitalConsole({
    required String weightString,
    required String unitLabel,
    required String modeLabel,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF334155), Color(0xFF1E293B), Color(0xFF0F172A)],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF475569), width: 2.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(3.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF050B14),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: const Color(0xFF1E293B), width: 1.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Row: "WEIGHT" header on left, mode badge on right
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'WEIGHT',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF94A3B8),
                    letterSpacing: 1.5,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1.5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(
                      color: const Color(0xFF334155),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    modeLabel,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF00FF66),
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),

            // Main Center Weight Readout
            Expanded(
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        weightString,
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 66,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF00FF66),
                          letterSpacing: -1.0,
                          shadows: [
                            Shadow(
                              color: const Color(
                                0xFF00FF66,
                              ).withValues(alpha: 0.65),
                              blurRadius: 16,
                            ),
                            Shadow(
                              color: const Color(
                                0xFF00E676,
                              ).withValues(alpha: 0.35),
                              blurRadius: 28,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 22),
                      Text(
                        unitLabel,
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 50,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF00FF66),
                          letterSpacing: 0.5,
                          shadows: [
                            Shadow(
                              color: const Color(
                                0xFF00FF66,
                              ).withValues(alpha: 0.65),
                              blurRadius: 16,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
