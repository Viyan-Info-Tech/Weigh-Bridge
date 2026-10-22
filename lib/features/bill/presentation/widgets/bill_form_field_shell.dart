import 'package:flutter/material.dart';

class BillFormFieldShell extends StatelessWidget {
  const BillFormFieldShell({
    super.key,
    this.prefixIcon,
    this.prefixText,
    this.suffix,
    this.backgroundColor = Colors.white,
    this.hasError = false,
    this.isValid = false,
    this.isFocused = false,
    required this.child,
  });

  final IconData? prefixIcon;
  final String? prefixText;
  final Widget? suffix;
  final Color backgroundColor;
  final bool hasError;
  final bool isValid;

  /// Drives the blue focus border so an actively-edited field reads as current.
  final bool isFocused;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final borderColor = hasError
        ? const Color(0xFFDC2626)
        : isFocused
        ? const Color(0xFF0D3B82)
        : isValid
        ? const Color(0xFF16A34A)
        : const Color(0xFFCBD5E1);

    final borderWidth = hasError || isFocused ? 1.5 : 1.0;

    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (prefixIcon != null || prefixText != null)
            Container(
              width: 44,
              height: 46,
              decoration: BoxDecoration(
                color: hasError
                    ? const Color(0xFFFEF2F2)
                    : const Color(0xFFF8FAFC),
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(5),
                ),
                border: Border(
                  right: BorderSide(
                    color: hasError
                        ? const Color(0xFFFCA5A5)
                        : const Color(0xFFE2E8F0),
                    width: 1.0,
                  ),
                ),
              ),
              alignment: Alignment.center,
              child: prefixIcon != null
                  ? Icon(
                      prefixIcon,
                      size: 20,
                      color: hasError
                          ? const Color(0xFFDC2626)
                          : const Color(0xFF475569),
                    )
                  : Text(
                      prefixText!,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: hasError
                            ? const Color(0xFFDC2626)
                            : const Color(0xFF475569),
                      ),
                    ),
            ),
          Expanded(child: child),
          if (suffix != null)
            suffix!
          else if (isValid)
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(
                Icons.check_rounded,
                size: 18,
                color: Color(0xFF16A34A),
              ),
            ),
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
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(5),
        child: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: const Color(0xFFBFDBFE), width: 0.8),
          ),
          child: const Icon(
            Icons.search_rounded,
            size: 18,
            color: Color(0xFF2563EB),
          ),
        ),
      ),
    );
  }
}
