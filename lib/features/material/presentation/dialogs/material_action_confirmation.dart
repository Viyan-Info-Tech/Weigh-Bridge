import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/material_bloc.dart';
import '../bloc/material_event.dart';

/// Confirmation dialogs for the material list row actions.
///
/// The three actions only differ by copy and accent color, so they share one
/// dialog shell and dispatch their [MaterialBloc] event through a callback.
class MaterialActionConfirmation extends StatelessWidget {
  const MaterialActionConfirmation({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.confirmColor,
    required this.onConfirmed,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final Color confirmColor;
  final VoidCallback onConfirmed;

  /// Shows the shell and dispatches [event] once the user confirms.
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required Color confirmColor,
    required MaterialEvent event,
  }) {
    return showDialog(
      context: context,
      builder: (dialogContext) => MaterialActionConfirmation(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        confirmColor: confirmColor,
        onConfirmed: () {
          context.read<MaterialBloc>().add(event);
          Navigator.pop(dialogContext);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontWeight: FontWeight.w700,
          fontSize: 16,
          color: Color(0xFF0F172A),
        ),
      ),
      content: Text(
        message,
        style: const TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 13,
          color: Color(0xFF475569),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(foregroundColor: const Color(0xFF64748B)),
          child: const Text(
            'Cancel',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        FilledButton(
          onPressed: onConfirmed,
          style: FilledButton.styleFrom(
            backgroundColor: confirmColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            confirmLabel,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
