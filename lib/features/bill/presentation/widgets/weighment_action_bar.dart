import 'package:flutter/material.dart';

/// Visual variants for a weighment action button.
enum WeighmentActionButtonStyle { primary, danger, neutral }

/// Bottom action bar for the weighment screen.
///
/// Order: SAVE, CANCEL, REGISTER WEIGHT, MANUAL TARE, AUTO TARE, RE-PRINT.
/// Each button renders an icon badge, a label, and an optional keycap showing
/// its shortcut.
class WeighmentActionBar extends StatelessWidget {
  const WeighmentActionBar({
    super.key,
    required this.isSaving,
    required this.onSave,
    required this.onCancel,
    required this.onRegisterWeight,
    required this.onManualTare,
    required this.onAutoTare,
    required this.onReprint,
  });

  final bool isSaving;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final VoidCallback onRegisterWeight;
  final VoidCallback onManualTare;
  final VoidCallback onAutoTare;
  final VoidCallback onReprint;

  @override
  Widget build(BuildContext context) {
    final isDisabled = isSaving;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // 1. Save completed ticket (Primary Action)
          WeighmentActionButton(
            icon: Icons.save_rounded,
            label: 'SAVE',
            shortcut: 'Ctrl+S',
            style: WeighmentActionButtonStyle.primary,
            isLoading: isSaving,
            onTap: isDisabled ? null : onSave,
          ),
          // 2. Escape: CANCEL (Danger Action)
          WeighmentActionButton(
            icon: Icons.cancel_rounded,
            label: 'CANCEL',
            shortcut: 'ESC',
            style: WeighmentActionButtonStyle.danger,
            onTap: isSaving ? null : onCancel,
          ),
          // 3. F1: REGISTER WEIGHT (capture current scale weight for selected type)
          WeighmentActionButton(
            icon: Icons.monitor_weight_rounded,
            label: 'REGISTER WEIGHT',
            shortcut: 'F1',
            accentColor: const Color(0xFF16A34A),
            accentBgColor: const Color(0xFFDCFCE7),
            onTap: isSaving ? null : onRegisterWeight,
          ),
          // 4. F2: MANUAL TARE
          WeighmentActionButton(
            icon: Icons.edit_note_rounded,
            label: 'MANUAL TARE',
            shortcut: 'F2',
            accentColor: const Color(0xFF0284C7),
            accentBgColor: const Color(0xFFE0F2FE),
            onTap: isSaving ? null : onManualTare,
          ),
          // 5. F3: AUTO TARE (today's common tare)
          WeighmentActionButton(
            icon: Icons.monitor_weight_rounded,
            label: 'AUTO TARE',
            shortcut: 'F3',
            accentColor: const Color(0xFF0891B2),
            accentBgColor: const Color(0xFFE0F7FA),
            onTap: isSaving ? null : onAutoTare,
          ),
          // 6. F4: RE-PRINT
          WeighmentActionButton(
            icon: Icons.print_rounded,
            label: 'RE-PRINT',
            shortcut: 'F4',
            accentColor: const Color(0xFF334155),
            accentBgColor: const Color(0xFFF1F5F9),
            onTap: onReprint,
          ),
        ],
      ),
    );
  }
}

/// A single keycap-styled button used by [WeighmentActionBar].
class WeighmentActionButton extends StatelessWidget {
  const WeighmentActionButton({
    super.key,
    required this.icon,
    required this.label,
    this.shortcut,
    this.style = WeighmentActionButtonStyle.neutral,
    this.accentColor,
    this.accentBgColor,
    required this.onTap,
    this.isLoading = false,
  });

  final IconData icon;
  final String label;
  final String? shortcut;
  final WeighmentActionButtonStyle style;
  final Color? accentColor;
  final Color? accentBgColor;
  final VoidCallback? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;
    final shortcutLabel = shortcut;

    final BoxDecoration decoration;
    final Color textColor;
    final Color iconColor;
    final Color iconBoxBg;
    final Color keycapBg;
    final Color keycapBorder;
    final Color keycapText;

    switch (style) {
      case WeighmentActionButtonStyle.primary:
        decoration = BoxDecoration(
          gradient: isEnabled
              ? const LinearGradient(
                  colors: [Color(0xFF15803D), Color(0xFF16A34A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isEnabled ? null : const Color(0xFFCBD5E1),
          borderRadius: BorderRadius.circular(8),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: const Color(0xFF16A34A).withValues(alpha: 0.28),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        );
        textColor = isEnabled ? Colors.white : const Color(0xFF64748B);
        iconColor = isEnabled ? Colors.white : const Color(0xFF64748B);
        iconBoxBg = isEnabled
            ? Colors.white.withValues(alpha: 0.20)
            : Colors.transparent;
        keycapBg = Colors.white.withValues(alpha: 0.20);
        keycapBorder = Colors.white.withValues(alpha: 0.35);
        keycapText = Colors.white;
        break;

      case WeighmentActionButtonStyle.danger:
        decoration = BoxDecoration(
          gradient: isEnabled
              ? const LinearGradient(
                  colors: [Color(0xFFB91C1C), Color(0xFFDC2626)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isEnabled ? null : const Color(0xFFCBD5E1),
          borderRadius: BorderRadius.circular(8),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: const Color(0xFFDC2626).withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        );
        textColor = isEnabled ? Colors.white : const Color(0xFF64748B);
        iconColor = isEnabled ? Colors.white : const Color(0xFF64748B);
        iconBoxBg = isEnabled
            ? Colors.white.withValues(alpha: 0.20)
            : Colors.transparent;
        keycapBg = Colors.white.withValues(alpha: 0.22);
        keycapBorder = Colors.white.withValues(alpha: 0.35);
        keycapText = Colors.white;
        break;

      case WeighmentActionButtonStyle.neutral:
        final accent = accentColor ?? const Color(0xFF334155);
        final bg = accentBgColor ?? const Color(0xFFF1F5F9);
        decoration = BoxDecoration(
          color: isEnabled ? Colors.white : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isEnabled
                ? const Color(0xFFE2E8F0)
                : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 1.5),
                  ),
                ]
              : null,
        );
        textColor = isEnabled
            ? const Color(0xFF0F172A)
            : const Color(0xFF94A3B8);
        iconColor = isEnabled ? accent : const Color(0xFF94A3B8);
        iconBoxBg = isEnabled ? bg : const Color(0xFFF1F5F9);
        keycapBg = isEnabled ? bg : const Color(0xFFF1F5F9);
        keycapBorder = isEnabled
            ? accent.withValues(alpha: 0.25)
            : const Color(0xFFCBD5E1);
        keycapText = isEnabled ? accent : const Color(0xFF94A3B8);
        break;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        hoverColor: style == WeighmentActionButtonStyle.neutral
            ? const Color(0xFFF8FAFC)
            : Colors.white.withValues(alpha: 0.12),
        child: Ink(
          decoration: decoration,
          child: Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon badge container
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: iconBoxBg,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: isLoading
                          ? SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: iconColor,
                              ),
                            )
                          : Icon(icon, size: 15, color: iconColor),
                    ),
                  ),
                  const SizedBox(width: 7),

                  // Button text
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                      letterSpacing: 0.35,
                    ),
                  ),

                  // Shortcut keycap badge
                  if (shortcutLabel != null) ...[
                    const SizedBox(width: 7),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: keycapBg,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: keycapBorder, width: 1),
                      ),
                      child: Text(
                        shortcutLabel,
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: keycapText,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
