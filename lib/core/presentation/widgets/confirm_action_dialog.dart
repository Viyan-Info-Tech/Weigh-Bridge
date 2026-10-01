import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ConfirmActionDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? warningNote;
  final String cancelLabel;
  final String confirmLabel;
  final IconData? icon;
  final IconData? confirmIcon;
  final Color? iconColor;
  final Color? iconBgColor;
  final Color? confirmColor;
  final bool isDanger;
  final double width;

  const ConfirmActionDialog({
    super.key,
    required this.title,
    required this.message,
    this.warningNote,
    this.cancelLabel = 'Cancel',
    this.confirmLabel = 'Confirm',
    this.icon,
    this.confirmIcon,
    this.iconColor,
    this.iconBgColor,
    this.confirmColor,
    this.isDanger = true,
    this.width = 420,
  });

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    String? warningNote,
    String cancelLabel = 'Cancel',
    String confirmLabel = 'Confirm',
    IconData? icon,
    IconData? confirmIcon,
    Color? iconColor,
    Color? iconBgColor,
    Color? confirmColor,
    bool isDanger = true,
    double width = 420,
  }) {
    return showDialog<bool>(
      context: context,
      barrierColor: const Color(0xFF0F172A).withValues(alpha: 0.45),
      builder: (_) => ConfirmActionDialog(
        title: title,
        message: message,
        warningNote: warningNote,
        cancelLabel: cancelLabel,
        confirmLabel: confirmLabel,
        icon: icon,
        confirmIcon: confirmIcon,
        iconColor: iconColor,
        iconBgColor: iconBgColor,
        confirmColor: confirmColor,
        isDanger: isDanger,
        width: width,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor =
        iconColor ??
        (isDanger ? const Color(0xFFDC2626) : const Color(0xFF0D3B82));
    final effectiveIconBgColor =
        iconBgColor ??
        (isDanger ? const Color(0xFFFEF2F2) : const Color(0xFFEFF6FF));
    final effectiveIconBorderColor = isDanger
        ? const Color(0xFFFECDD3)
        : const Color(0xFFDBEAFE);
    final effectiveConfirmColor =
        confirmColor ??
        (isDanger ? const Color(0xFFDC2626) : const Color(0xFF0D3B82));
    final effectiveIcon =
        icon ??
        (isDanger ? Icons.warning_amber_rounded : Icons.info_outline_rounded);

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.escape): () {
          Navigator.of(context).pop(false);
        },
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          constraints: BoxConstraints(maxWidth: width),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1F0F172A),
                blurRadius: 32,
                offset: Offset(0, 16),
              ),
              BoxShadow(
                color: Color(0x0A0F172A),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Badge, Title, and Close Button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: effectiveIconBgColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: effectiveIconBorderColor),
                      ),
                      child: Icon(
                        effectiveIcon,
                        size: 22,
                        color: effectiveIconColor,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(false),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: Colors.grey.shade500,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Message Text
                Text(
                  message,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13.5,
                    color: Color(0xFF475569),
                    height: 1.45,
                  ),
                ),

                // Warning / Alert Note Box
                if (warningNote != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isDanger
                          ? const Color(0xFFFEF2F2)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDanger
                            ? const Color(0xFFFECDD3)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          isDanger
                              ? Icons.error_outline_rounded
                              : Icons.info_outline_rounded,
                          size: 16,
                          color: isDanger
                              ? const Color(0xFFDC2626)
                              : const Color(0xFF64748B),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            warningNote!,
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 12,
                              color: isDanger
                                  ? const Color(0xFF991B1B)
                                  : const Color(0xFF475569),
                              fontWeight: FontWeight.w500,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 22),

                // Action Buttons
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF475569),
                        backgroundColor: const Color(0xFFF8FAFC),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 11,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        cancelLabel,
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: effectiveConfirmColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 11,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (confirmIcon != null) ...[
                            Icon(confirmIcon, size: 16),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            confirmLabel,
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
