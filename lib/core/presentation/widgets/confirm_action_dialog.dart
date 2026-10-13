import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A yes/no confirmation dialog with a fixed keyboard contract.
///
/// [Enter] (and numpad Enter) confirms, matching the primary action button.
/// [Escape] backs out and is treated as "keep what I have", so it always pops
/// `false`.
///
/// Both bindings live on this widget's [CallbackShortcuts], so they apply only
/// while the dialog is open. Nothing outside it is affected, and the bindings
/// stop applying the moment the dialog is dismissed.
class ConfirmActionDialog extends StatefulWidget {
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
  final FocusNode? confirmFocusNode;
  final VoidCallback? onConfirm;

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
    this.confirmFocusNode,
    this.onConfirm,
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
    FocusNode? confirmFocusNode,
    VoidCallback? onConfirm,
  }) {
    final focusNode =
        confirmFocusNode ??
        FocusNode(debugLabel: 'confirm_dialog_action_focus');
    final future = showDialog<bool>(
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
        confirmFocusNode: focusNode,
        onConfirm: onConfirm,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (focusNode.canRequestFocus) {
        focusNode.requestFocus();
      }
    });

    if (confirmFocusNode == null) {
      future.whenComplete(() {
        focusNode.dispose();
      });
    }

    return future;
  }

  @override
  State<ConfirmActionDialog> createState() => _ConfirmActionDialogState();
}

class _ConfirmActionDialogState extends State<ConfirmActionDialog> {
  late final FocusNode _confirmFocusNode;
  bool _ownsFocusNode = false;
  bool _isConfirmed = false;

  void _handleConfirm() {
    if (_isConfirmed) return;
    _isConfirmed = true;
    Navigator.of(context).pop(true);
    widget.onConfirm?.call();
  }

  @override
  void initState() {
    super.initState();
    if (widget.confirmFocusNode != null) {
      _confirmFocusNode = widget.confirmFocusNode!;
      _ownsFocusNode = false;
    } else {
      _confirmFocusNode = FocusNode(
        debugLabel: 'confirmActionDialog_confirmButton',
      );
      _ownsFocusNode = true;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _confirmFocusNode.canRequestFocus) {
        _confirmFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    if (_ownsFocusNode) {
      _confirmFocusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor =
        widget.iconColor ??
        (widget.isDanger ? const Color(0xFFDC2626) : const Color(0xFF0D3B82));
    final effectiveIconBgColor =
        widget.iconBgColor ??
        (widget.isDanger ? const Color(0xFFFEF2F2) : const Color(0xFFEFF6FF));
    final effectiveIconBorderColor = widget.isDanger
        ? const Color(0xFFFECDD3)
        : const Color(0xFFDBEAFE);
    final effectiveConfirmColor =
        widget.confirmColor ??
        (widget.isDanger ? const Color(0xFFDC2626) : const Color(0xFF0D3B82));
    final effectiveIcon =
        widget.icon ??
        (widget.isDanger
            ? Icons.warning_amber_rounded
            : Icons.info_outline_rounded);

    return FocusScope(
      autofocus: true,
      child: CallbackShortcuts(
        bindings: <ShortcutActivator, VoidCallback>{
          const SingleActivator(LogicalKeyboardKey.escape): () {
            Navigator.of(context).pop(false);
          },
          const SingleActivator(LogicalKeyboardKey.enter): _handleConfirm,
          const SingleActivator(LogicalKeyboardKey.numpadEnter): _handleConfirm,
        },
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          child: Container(
            constraints: BoxConstraints(maxWidth: widget.width),
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
                            widget.title,
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
                    widget.message,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13.5,
                      color: Color(0xFF475569),
                      height: 1.45,
                    ),
                  ),

                  // Warning / Alert Note Box
                  if (widget.warningNote != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: widget.isDanger
                            ? const Color(0xFFFEF2F2)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: widget.isDanger
                              ? const Color(0xFFFECDD3)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            widget.isDanger
                                ? Icons.error_outline_rounded
                                : Icons.info_outline_rounded,
                            size: 16,
                            color: widget.isDanger
                                ? const Color(0xFFDC2626)
                                : const Color(0xFF64748B),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.warningNote!,
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 12,
                                color: widget.isDanger
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
                          widget.cancelLabel,
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        focusNode: _confirmFocusNode,
                        autofocus: true,
                        onPressed: _handleConfirm,
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
                            if (widget.confirmIcon != null) ...[
                              Icon(widget.confirmIcon, size: 16),
                              const SizedBox(width: 6),
                            ],
                            Text(
                              widget.confirmLabel,
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
      ),
    );
  }
}
