import 'package:flutter/material.dart';

class BillFormFieldShell extends StatelessWidget {
  const BillFormFieldShell({
    super.key,
    this.prefixIcon,
    this.prefixText,
    this.suffix,
    this.backgroundColor = Colors.white,
    required this.child,
  });

  final IconData? prefixIcon;
  final String? prefixText;
  final Widget? suffix;
  final Color backgroundColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
        border:
            Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (prefixIcon != null || prefixText != null)
            Container(
              width: 36,
              height: 38,
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(5),
                ),
                border: Border(
                  right: BorderSide(
                      color: Color(0xFFE2E8F0), width: 1.0),
                ),
              ),
              alignment: Alignment.center,
              child: prefixIcon != null
                  ? Icon(prefixIcon,
                      size: 17, color: const Color(0xFF475569))
                  : Text(
                      prefixText!,
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF475569),
                      ),
                    ),
            ),
          Expanded(child: child),
          ?suffix,
        ],
      ),
    );
  }
}

class BillFormSearchButton extends StatelessWidget {
  const BillFormSearchButton({
    super.key,
    required this.onTap,
    required this.tooltip,
  });

  final VoidCallback? onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
                color: const Color(0xFFBFDBFE), width: 0.8),
          ),
          child: const Icon(
            Icons.search_rounded,
            size: 16,
            color: Color(0xFF2563EB),
          ),
        ),
      ),
    );
  }
}
