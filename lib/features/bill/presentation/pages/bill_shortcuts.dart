import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Operator intents for the weighment screen's function keys and save
/// actions. Declared as marker intents so they can be routed through a
/// [Shortcuts] + [Actions] pair.
class CancelWeighmentIntent extends Intent {
  const CancelWeighmentIntent();
}

class SaveWeighmentIntent extends Intent {
  const SaveWeighmentIntent();
}

class CaptureLiveWeightIntent extends Intent {
  const CaptureLiveWeightIntent();
}

class ManualTareIntent extends Intent {
  const ManualTareIntent();
}

class AutoTareIntent extends Intent {
  const AutoTareIntent();
}

class ReprintIntent extends Intent {
  const ReprintIntent();
}

class ExitWeighmentIntent extends Intent {
  const ExitWeighmentIntent();
}

class SaveAndPrintIntent extends Intent {
  const SaveAndPrintIntent();
}

class NextFieldIntent extends Intent {
  const NextFieldIntent();
}

class PreviousFieldIntent extends Intent {
  const PreviousFieldIntent();
}

/// Callbacks the keyboard layer invokes, supplied by the page state.
///
/// [isModalOpen] and [isSaving] are read at invoke time rather than captured,
/// so a handler always sees current state exactly as the inline closures did.
class WeighmentShortcutHandlers {
  const WeighmentShortcutHandlers({
    required this.isModalOpen,
    required this.isSaving,
    required this.onCancel,
    required this.onSave,
    required this.onCaptureLiveWeight,
    required this.onManualTare,
    required this.onAutoTare,
    required this.onReprint,
    required this.onExit,
    required this.onSaveAndPrint,
    required this.onNextField,
    required this.onPreviousField,
  });

  final bool Function() isModalOpen;
  final bool Function() isSaving;

  final VoidCallback onCancel;
  final VoidCallback onSave;
  final VoidCallback onCaptureLiveWeight;
  final VoidCallback onManualTare;
  final VoidCallback onAutoTare;
  final VoidCallback onReprint;
  final VoidCallback onSaveAndPrint;
  final VoidCallback onNextField;
  final VoidCallback onPreviousField;

  /// Null when the page was created without an exit hook.
  final VoidCallback? onExit;
}

/// Wraps [child] in the weighment screen's [Shortcuts] and [Actions] pair.
class WeighmentShortcutScope extends StatelessWidget {
  const WeighmentShortcutScope({
    super.key,
    required this.handlers,
    required this.child,
  });

  final WeighmentShortcutHandlers handlers;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final h = handlers;
    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        const SingleActivator(LogicalKeyboardKey.escape):
            const CancelWeighmentIntent(),
        const SingleActivator(LogicalKeyboardKey.keyS, control: true):
            const SaveWeighmentIntent(),
        const SingleActivator(LogicalKeyboardKey.keyS, meta: true):
            const SaveWeighmentIntent(),
        const SingleActivator(LogicalKeyboardKey.f1):
            const CaptureLiveWeightIntent(),
        const SingleActivator(LogicalKeyboardKey.f2): const ManualTareIntent(),
        const SingleActivator(LogicalKeyboardKey.f3): const AutoTareIntent(),
        const SingleActivator(LogicalKeyboardKey.f4): const ReprintIntent(),
        const SingleActivator(LogicalKeyboardKey.f9):
            const ExitWeighmentIntent(),
        const SingleActivator(LogicalKeyboardKey.keyP, control: true):
            const SaveAndPrintIntent(),
        const SingleActivator(LogicalKeyboardKey.keyP, meta: true):
            const SaveAndPrintIntent(),
        const SingleActivator(LogicalKeyboardKey.f10):
            const SaveAndPrintIntent(),
        const SingleActivator(LogicalKeyboardKey.tab): const NextFieldIntent(),
        const SingleActivator(LogicalKeyboardKey.tab, shift: true):
            const PreviousFieldIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          CancelWeighmentIntent: CallbackAction<CancelWeighmentIntent>(
            onInvoke: (_) {
              if (h.isModalOpen() || h.isSaving()) return null;
              h.onCancel();
              return null;
            },
          ),
          SaveWeighmentIntent: CallbackAction<SaveWeighmentIntent>(
            onInvoke: (_) {
              if (h.isModalOpen()) return null;
              h.onSave();
              return null;
            },
          ),
          CaptureLiveWeightIntent: CallbackAction<CaptureLiveWeightIntent>(
            onInvoke: (_) {
              if (h.isModalOpen()) return null;
              h.onCaptureLiveWeight();
              return null;
            },
          ),
          ManualTareIntent: CallbackAction<ManualTareIntent>(
            onInvoke: (_) {
              if (h.isModalOpen() || h.isSaving()) return null;
              h.onManualTare();
              return null;
            },
          ),
          AutoTareIntent: CallbackAction<AutoTareIntent>(
            onInvoke: (_) {
              if (h.isModalOpen() || h.isSaving()) return null;
              h.onAutoTare();
              return null;
            },
          ),
          ReprintIntent: CallbackAction<ReprintIntent>(
            onInvoke: (_) {
              if (h.isModalOpen()) return null;
              h.onReprint();
              return null;
            },
          ),
          ExitWeighmentIntent: CallbackAction<ExitWeighmentIntent>(
            onInvoke: (_) {
              if (h.isModalOpen()) return null;
              h.onExit?.call();
              return null;
            },
          ),
          SaveAndPrintIntent: CallbackAction<SaveAndPrintIntent>(
            onInvoke: (_) {
              if (h.isModalOpen()) return null;
              h.onSaveAndPrint();
              return null;
            },
          ),
          NextFieldIntent: CallbackAction<NextFieldIntent>(
            onInvoke: (_) {
              h.onNextField();
              return null;
            },
          ),
          PreviousFieldIntent: CallbackAction<PreviousFieldIntent>(
            onInvoke: (_) {
              h.onPreviousField();
              return null;
            },
          ),
        },
        child: child,
      ),
    );
  }
}

/// Fallback global key handler for the weighment screen.
///
/// This runs alongside [WeighmentShortcutScope]. Both are kept because they
/// are not equivalent: the global handler receives keys regardless of focus
/// position within the widget tree, while the [Shortcuts] widget only fires
/// while focus is inside its subtree, and it is the only mechanism that maps
/// Tab / Shift+Tab to field traversal. The order they run in is unchanged:
/// [HardwareKeyboard] handlers are invoked before the focused subtree's
/// [Shortcuts], so overlapping keys resolve through here first.
bool handleWeighmentGlobalKeyEvent(
  KeyEvent event, {
  required bool isMounted,
  required bool isActive,
  required bool isModalOpen,
  required bool Function() isSaving,
  required VoidCallback onCancel,
  required VoidCallback onSave,
  required VoidCallback onCaptureLiveWeight,
  required VoidCallback onManualTare,
  required VoidCallback onAutoTare,
  required VoidCallback onReprint,
  required VoidCallback onSaveAndPrint,
  required VoidCallback? onExit,
}) {
  if (!isMounted || !isActive) return false;
  if (event is! KeyDownEvent) return false;
  if (isModalOpen) return false;

  final isControlPressed =
      HardwareKeyboard.instance.isControlPressed ||
      HardwareKeyboard.instance.isMetaPressed;

  final key = event.logicalKey;

  // 1. ESC -> Cancel current weighment
  if (key == LogicalKeyboardKey.escape) {
    if (!isSaving()) onCancel();
    return true;
  }

  // 2. F2 -> Manual Tare
  if (key == LogicalKeyboardKey.f2) {
    if (!isSaving()) onManualTare();
    return true;
  }

  // 3. F3 -> Auto Tare (today's common tare management)
  if (key == LogicalKeyboardKey.f3) {
    if (!isSaving()) onAutoTare();
    return true;
  }

  // 4. F4 -> Re-print
  if (key == LogicalKeyboardKey.f4) {
    onReprint();
    return true;
  }

  // F1 -> Live weight capture
  if (key == LogicalKeyboardKey.f1) {
    onCaptureLiveWeight();
    return true;
  }

  // F9 -> Exit
  if (key == LogicalKeyboardKey.f9) {
    onExit?.call();
    return true;
  }

  // Ctrl+S -> Save ticket
  if (key == LogicalKeyboardKey.keyS && isControlPressed) {
    if (!isSaving()) onSave();
    return true;
  }

  // F10 or Ctrl+P -> Save and print
  if ((key == LogicalKeyboardKey.keyP && isControlPressed) ||
      key == LogicalKeyboardKey.f10) {
    if (!isSaving()) onSaveAndPrint();
    return true;
  }

  return false;
}
