import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/hardware/scale/domain/scale_models.dart';
import '../../../../core/hardware/scale/domain/scale_status.dart';

/// Read-only dashboard for the live scale connection.
///
/// Presents connection state, the digital weight readout, the raw ASCII/hex
/// serial monitor and the telemetry row. It takes only values derived from
/// [ScaleStatus]; the settings card owns the stream subscriptions that
/// produce them.
class LiveScaleConsole extends StatelessWidget {
  const LiveScaleConsole({
    super.key,
    required this.status,
    required this.port,
    required this.baudRate,
    required this.dataBits,
    required this.parity,
    required this.stopBits,
    required this.protocolLabel,
    required this.latestRawAscii,
    required this.latestRawHex,
    required this.receivedPackets,
  });

  final ScaleStatus status;
  final String port;
  final int baudRate;
  final int dataBits;
  final ScaleParity parity;
  final int stopBits;
  final String protocolLabel;
  final String latestRawAscii;
  final String latestRawHex;
  final int receivedPackets;

  @override
  Widget build(BuildContext context) {
    final isConnected = status.isConnected;
    final (stateColor, stateLabel) = switch (status.state) {
      ScaleConnectionState.connected => (
        const Color(0xFF22C55E),
        status.stale ? 'STREAM STALE' : 'ONLINE â€¢ STREAMING',
      ),
      ScaleConnectionState.connecting => (
        const Color(0xFF38BDF8),
        'CONNECTING...',
      ),
      ScaleConnectionState.reconnecting => (
        const Color(0xFFF59E0B),
        'RECONNECTING (${status.reconnectAttempt})...',
      ),
      ScaleConnectionState.error => (const Color(0xFFEF4444), 'PORT ERROR'),
      ScaleConnectionState.disconnected => (
        const Color(0xFF94A3B8),
        'OFFLINE / DISCONNECTED',
      ),
    };

    final double? weight = status.currentWeightKg;
    final String weightString;
    if (!isConnected || weight == null) {
      weightString = '--';
    } else if (weight == 0) {
      weightString = '0';
    } else if (weight.abs() >= 1000) {
      weightString = NumberFormat('#,##0').format(weight);
    } else {
      weightString = weight.toStringAsFixed(1);
    }

    final String packetTime;
    if (status.lastReceivedAt != null) {
      packetTime = DateFormat('HH:mm:ss').format(status.lastReceivedAt!);
    } else {
      packetTime = 'No data';
    }

    final serialSpecs =
        '$port â€¢ $baudRate 8-${parity.name[0].toUpperCase()}-$stopBits';

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // â”€â”€ Top Bar: State & Serial Specs â”€â”€
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // State Pill
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: stateColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          if (isConnected)
                            BoxShadow(
                              color: stateColor.withValues(alpha: 0.6),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 7),
                    Flexible(
                      child: Text(
                        stateLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: stateColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Serial Specs Chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF475569)),
                ),
                child: Text(
                  serialSpecs,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // â”€â”€ Digital Weight Display Console â”€â”€
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF020617),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF1E293B)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Digital weight readout
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            weightString,
                            style: TextStyle(
                              fontFamily: 'Courier',
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              color: isConnected
                                  ? const Color(0xFF4ADE80)
                                  : const Color(0xFF64748B),
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'KG',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: isConnected
                              ? const Color(0xFF86EFAC)
                              : const Color(0xFF475569),
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                // Telemetry Badges
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (status.isOverload)
                      _TelemetryPill(
                        label: 'OVERLOAD',
                        color: const Color(0xFFEF4444),
                        isActive: true,
                      )
                    else if (status.isMotion)
                      _TelemetryPill(
                        label: 'MOTION',
                        color: const Color(0xFFF59E0B),
                        isActive: true,
                      )
                    else if (isConnected)
                      _TelemetryPill(
                        label: status.stable ? 'STABLE' : 'UNSTABLE',
                        color: status.stable
                            ? const Color(0xFF22C55E)
                            : const Color(0xFFF59E0B),
                        isActive: true,
                      )
                    else
                      const _TelemetryPill(
                        label: 'NO SIGNAL',
                        color: Color(0xFF64748B),
                        isActive: false,
                      ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // â”€â”€ Live Raw Serial Data Feed Monitor â”€â”€
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF030712),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF1E293B)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.terminal_rounded,
                          size: 13,
                          color: Color(0xFF38BDF8),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'LIVE SERIAL STREAM (RX)',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF94A3B8),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Packets: $receivedPackets',
                      style: const TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 10.5,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  latestRawAscii.isNotEmpty
                      ? latestRawAscii
                      : (isConnected
                            ? 'Listening on $port... (waiting for scale data transmission)'
                            : 'Port not connected'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: latestRawAscii.isNotEmpty
                        ? const Color(0xFF38BDF8)
                        : const Color(0xFF475569),
                  ),
                ),
                if (latestRawHex.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'HEX: $latestRawHex',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 10,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 10),

          // â”€â”€ Bottom Telemetry Info Row â”€â”€
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  status.error != null
                      ? 'Indicator error: ${status.error}'
                      : isConnected
                      ? 'Protocol: $protocolLabel'
                      : 'Connect indicator to capture weights',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    color: status.error != null
                        ? const Color(0xFFF87171)
                        : const Color(0xFF94A3B8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Last packet: $packetTime',
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 11,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Small labelled status pill used along the console's telemetry row.
class _TelemetryPill extends StatelessWidget {
  const _TelemetryPill({
    required this.label,
    required this.color,
    required this.isActive,
  });

  final String label;
  final Color color;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isActive ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withValues(alpha: isActive ? 0.7 : 0.3),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
