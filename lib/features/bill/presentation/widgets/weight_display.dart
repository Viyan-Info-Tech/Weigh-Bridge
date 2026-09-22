import 'package:flutter/material.dart';

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
        ? (displayVal > 0 ? displayVal.toStringAsFixed(0) : '0')
        : (displayVal > 0 ? displayVal.toStringAsFixed(3) : '0.000');

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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Left CCTV Camera 01
          Expanded(
            flex: 23,
            child: _buildCameraFeed(
              cameraLabel: 'CAM 01',
              assetPath: 'assets/images/cam_view_1.jpg',
              fallbackAsset: 'assets/images/modern_truck_scale.jpg',
            ),
          ),

          const SizedBox(width: 8),

          // 2. Center Obsidian Digital Weight Readout
          Expanded(
            flex: 48,
            child: _buildCenterDigitalConsole(
              weightString: weightString,
              unitLabel: unitLabel,
              modeLabel: modeLabel,
            ),
          ),

          const SizedBox(width: 8),

          // 3. Right CCTV Camera 02
          Expanded(
            flex: 23,
            child: _buildCameraFeed(
              cameraLabel: 'CAM 02',
              assetPath: 'assets/images/cam_view_2.jpg',
              fallbackAsset: 'assets/images/weighbridge_truck.jpg',
            ),
          ),

          const SizedBox(width: 6),

          // 4. Far Right Status Telemetry Panel
          SizedBox(
            width: 106,
            child: _buildStatusIndicators(
              isStable: widget.isStable,
              isMotion: widget.isMotion,
              isOverload: widget.isOverload,
            ),
          ),
        ],
      ),
    );
  }

  /// Camera feed view with border, overlay badge, and fallbacks
  Widget _buildCameraFeed({
    required String cameraLabel,
    required String assetPath,
    required String fallbackAsset,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              assetPath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Image.asset(
                fallbackAsset,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFF334155),
                  child: const Center(
                    child: Icon(
                      Icons.videocam_outlined,
                      color: Color(0xFF94A3B8),
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 6,
              left: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      cameraLabel,
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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

  /// Far-right vertical telemetry panel with STABLE, MOTION, OVERLOAD indicators
  Widget _buildStatusIndicators({
    required bool isStable,
    required bool isMotion,
    required bool isOverload,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatusItem(
          label: 'STABLE',
          isActive: isStable,
          activeColor: const Color(0xFF00E676),
        ),
        const SizedBox(height: 12),
        _buildStatusItem(
          label: 'MOTION',
          isActive: isMotion,
          activeColor: const Color(0xFFF59E0B),
        ),
        const SizedBox(height: 12),
        _buildStatusItem(
          label: 'OVERLOAD',
          isActive: isOverload,
          activeColor: const Color(0xFFEF4444),
        ),
      ],
    );
  }

  Widget _buildStatusItem({
    required String label,
    required bool isActive,
    required Color activeColor,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: isActive ? activeColor : const Color(0xFFCBD5E1),
            shape: BoxShape.circle,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.7),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
        ),
        const SizedBox(width: 7),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: isActive ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }
}
