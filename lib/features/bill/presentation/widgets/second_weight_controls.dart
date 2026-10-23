import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Separate SECOND WEIGHT toggle button for the weighment form.
///
/// Sits beside (never inside) the GROSS/TARE TYPE selector. Tapping it
/// toggles the second-weight workflow: when active, the TYPE selector is
/// hidden and entering a vehicle number retrieves that truck's previous
/// weighment. Styling mirrors the TYPE options so the row reads as one
/// control group, with a distinct purple accent so the mode is obvious.
class SecondWeightToggle extends StatelessWidget {
  const SecondWeightToggle({
    super.key,
    required this.isActive,
    required this.onTap,
    this.isBusy = false,
  });

  final bool isActive;
  final VoidCallback onTap;

  /// True while the previous-weighment lookup is running.
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Tooltip(
        message: isActive
            ? 'Return to normal weighment (GROSS / TARE)'
            : 'Weigh a returning truck using its previous weighment',
        waitDuration: const Duration(milliseconds: 500),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFFF5F3FF)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isActive
                    ? const Color(0xFF7C3AED)
                    : const Color(0xFFCBD5E1),
                width: isActive ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.swap_horiz_rounded,
                  size: 20,
                  color: isActive
                      ? const Color(0xFF7C3AED)
                      : const Color(0xFF64748B),
                ),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    'SECOND WEIGHT',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: isActive
                          ? const Color(0xFF7C3AED)
                          : const Color(0xFF334155),
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                if (isBusy) ...[
                  const SizedBox(width: 7),
                  const SizedBox(
                    width: 13,
                    height: 13,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF7C3AED),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Status line shown under the SECOND WEIGHT toggle while the mode is active.
///
/// Communicates the outcome of the previous-weighment lookup: the bill that
/// was matched (and which weight it locked), the search in progress, or a
/// clear explanation when no eligible weighment exists.
class SecondWeightStatusBanner extends StatelessWidget {
  const SecondWeightStatusBanner({
    super.key,
    required this.isFetching,
    this.vehicleNumber = '',
    this.previousBillNumber,
    this.previousWeightType,
    this.previousWeightText,
    this.previousCapturedAt,
    this.message,
  });

  final bool isFetching;
  final String vehicleNumber;
  final String? previousBillNumber;
  final String? previousWeightType;
  final String? previousWeightText;
  final DateTime? previousCapturedAt;

  /// Operator-facing explanation (not found / invalid data / lookup error).
  final String? message;

  @override
  Widget build(BuildContext context) {
    if (isFetching) {
      return _BannerShell(
        color: const Color(0xFF0284C7),
        background: const Color(0xFFEFF6FF),
        child: Row(
          children: [
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF0284C7),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Searching previous weighment for $vehicleNumber…',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0C4A6E),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final billNumber = previousBillNumber;
    if (billNumber != null) {
      final type = previousWeightType ?? 'GROSS';
      final capturedAt = previousCapturedAt;
      final capturedText = capturedAt != null
          ? ' · ${DateFormat('dd/MM/yyyy hh:mm a').format(capturedAt)}'
          : '';
      return _BannerShell(
        color: const Color(0xFF16A34A),
        background: const Color(0xFFF0FDF4),
        child: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              size: 15,
              color: Color(0xFF16A34A),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Previous $type ${previousWeightText ?? ''} loaded from '
                'bill $billNumber$capturedText — this weight is locked. '
                'Capture the current weight.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF15803D),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final message = this.message;
    if (message != null && message.isNotEmpty) {
      return _BannerShell(
        color: const Color(0xFFD97706),
        background: const Color(0xFFFFFBEB),
        child: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              size: 15,
              color: Color(0xFFD97706),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF92400E),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

class _BannerShell extends StatelessWidget {
  const _BannerShell({
    required this.color,
    required this.background,
    required this.child,
  });

  final Color color;
  final Color background;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: child,
    );
  }
}
