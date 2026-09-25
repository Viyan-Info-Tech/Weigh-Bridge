import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../security/admin_password_service.dart';

Future<bool> showAdminPasswordDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _AdminPasswordDialog(),
  );
  return result ?? false;
}

class _AdminPasswordDialog extends StatefulWidget {
  const _AdminPasswordDialog();

  @override
  State<_AdminPasswordDialog> createState() => _AdminPasswordDialogState();
}

class _AdminPasswordDialogState extends State<_AdminPasswordDialog> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  String? _error;
  bool _obscureText = true;
  bool _isVerifying = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _unlock() async {
    if (_isVerifying) return;
    setState(() => _isVerifying = true);
    bool valid;
    try {
      valid = await context
          .read<AdminPasswordService>()
          .verify(_controller.text);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isVerifying = false;
        _error = 'Could not verify the administrator password.';
      });
      return;
    }
    if (!mounted) return;
    if (valid) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() {
      _isVerifying = false;
      _error = 'Incorrect password. Please try again.';
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
    });
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.escape): () {
          Navigator.of(context).pop(false);
        },
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Container(
          width: 380,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.12),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header Row with Security Badge and Close Button ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE0F2FE), Color(0xFFBAE6FD)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF93C5FD),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings_rounded,
                        color: Color(0xFF0284C7),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Administrator Access',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.2,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Enter password to continue',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Close button
                    InkWell(
                      onTap: () => Navigator.of(context).pop(false),
                      borderRadius: BorderRadius.circular(6),
                      hoverColor: const Color(0xFFF1F5F9),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ── Password Input ──
                TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  obscureText: _obscureText,
                  autofocus: true,
                  textInputAction: TextInputAction.done,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                    letterSpacing: 1.5,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter password',
                    hintStyle: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF94A3B8),
                      letterSpacing: 0,
                    ),
                    prefixIcon: const Icon(
                      Icons.lock_outline_rounded,
                      size: 18,
                      color: Color(0xFF64748B),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 18,
                        color: const Color(0xFF64748B),
                      ),
                      tooltip: _obscureText ? 'Show password' : 'Hide password',
                      onPressed: () {
                        setState(() => _obscureText = !_obscureText);
                      },
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color(0xFFCBD5E1),
                        width: 1.2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: _error != null
                            ? const Color(0xFFEF4444)
                            : const Color(0xFFE2E8F0),
                        width: 1.2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: _error != null
                            ? const Color(0xFFDC2626)
                            : const Color(0xFF0284C7),
                        width: 1.6,
                      ),
                    ),
                  ),
                  onChanged: (_) {
                    if (_error != null) setState(() => _error = null);
                  },
                  onSubmitted: (_) => _unlock(),
                ),

                // ── Error banner ──
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFFECACA)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          size: 15,
                          color: Color(0xFFDC2626),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _error!,
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFDC2626),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 22),

                // ── Action Buttons ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Cancel Button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(false),
                        borderRadius: BorderRadius.circular(8),
                        hoverColor: const Color(0xFFF1F5F9),
                        child: Container(
                          height: 38,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFCBD5E1),
                              width: 1.2,
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Unlock Button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _isVerifying ? null : _unlock,
                        borderRadius: BorderRadius.circular(8),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0E7490), Color(0xFF0891B2)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF0891B2,
                                ).withValues(alpha: 0.30),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Container(
                            height: 38,
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.lock_open_rounded,
                                  size: 15,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  _isVerifying ? 'Checking...' : 'Unlock',
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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
