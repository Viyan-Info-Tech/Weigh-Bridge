import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Status/configuration control for the day's common tare, shown next to the
/// weight display.
///
/// This is the operator's entry point into the auto tare configuration: tapping
/// it opens the "Enter Auto Tare" screen, so the day's common tare can be
/// created or changed. It reports "Not Set" until one is configured.
///
/// Applying a configured tare to the weighment being edited is a separate
/// action (the AUTO TARE F3 button / the F3 key), so the two controls never
/// overlap.
class AutoTareIndicator extends StatelessWidget {
  const AutoTareIndicator({
    super.key,
    required this.autoTareKg,
    required this.weightUnit,
    required this.onTap,
    this.autoTareDate,
  });

  final double autoTareKg;
  final String weightUnit;
  final DateTime? autoTareDate;

  /// Opens the auto tare configuration screen.
  final VoidCallback onTap;

  bool get _isTon => weightUnit.trim().toLowerCase() == 'ton';
  bool get _hasAutoTare => autoTareKg.isFinite && autoTareKg > 0;

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF16A34A);
    const bg = Color(0xFFDCFCE7);

    final valueText = _hasAutoTare
        ? '${_isTon ? (autoTareKg / 1000).toStringAsFixed(3) : NumberFormat('#,##0').format(autoTareKg)} '
              '${_isTon ? 'Ton' : 'Kg'}'
        : 'Active';

    final dateText = autoTareDate == null
        ? null
        : DateFormat('dd MMM yyyy').format(autoTareDate!);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const Key('auto_tare_indicator'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        hoverColor: const Color(0xFFE2E8F0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.monitor_weight_rounded, size: 14, color: accent),
              const SizedBox(width: 6),
              const Text(
                'AUTO TARE',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF64748B),
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: accent.withValues(alpha: 0.25)),
                ),
                child: Text(
                  valueText,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: accent,
                  ),
                ),
              ),
              if (dateText != null) ...[
                const SizedBox(width: 8),
                Text(
                  dateText,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
              const SizedBox(width: 4),
              Icon(
                Icons.edit_outlined,
                size: 12,
                color: accent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
