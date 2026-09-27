import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/security/admin_password_service.dart';

Future<bool> showChangeAdminPasswordDialog(BuildContext context) async =>
    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _ChangeAdminPasswordDialog(),
    ) ??
    false;

class _ChangeAdminPasswordDialog extends StatefulWidget {
  const _ChangeAdminPasswordDialog();

  @override
  State<_ChangeAdminPasswordDialog> createState() =>
      _ChangeAdminPasswordDialogState();
}

class _ChangeAdminPasswordDialogState
    extends State<_ChangeAdminPasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  final _currentFocus = FocusNode();
  final _newFocus = FocusNode();
  final _confirmFocus = FocusNode();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    _currentFocus.dispose();
    _newFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await context.read<AdminPasswordService>().changePassword(
        currentPassword: _currentController.text,
        newPassword: _newController.text,
      );
      if (mounted) Navigator.of(context).pop(true);
    } on AdminPasswordException catch (error) {
      if (mounted) {
        setState(() {
          _error = error.message;
          _saving = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Could not update the password. Please try again.';
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.escape): () {
          if (!_saving) Navigator.of(context).pop(false);
        },
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Container(
          width: 420,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.14),
                blurRadius: 32,
                offset: const Offset(0, 14),
              ),
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Header Row ──
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
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
                          Icons.lock_reset_rounded,
                          color: Color(0xFF0D3B82),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Change Password',
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
                              'Update administrator access credentials',
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
                        onTap: _saving ? null : () => Navigator.of(context).pop(false),
                        borderRadius: BorderRadius.circular(6),
                        hoverColor: const Color(0xFFF1F5F9),
                        child: Container(
                          padding: const EdgeInsets.all(6),
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

                  // ── Current Password ──
                  _buildPasswordField(
                    label: 'Current Password',
                    hint: 'Enter your current password',
                    controller: _currentController,
                    focusNode: _currentFocus,
                    obscureText: _obscureCurrent,
                    onToggleVisibility: () =>
                        setState(() => _obscureCurrent = !_obscureCurrent),
                    prefixIcon: Icons.lock_outline_rounded,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter current password';
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) => _newFocus.requestFocus(),
                  ),

                  const SizedBox(height: 14),

                  // ── New Password ──
                  _buildPasswordField(
                    label: 'New Password',
                    hint: 'Enter new password (min. 3 characters)',
                    controller: _newController,
                    focusNode: _newFocus,
                    obscureText: _obscureNew,
                    onToggleVisibility: () =>
                        setState(() => _obscureNew = !_obscureNew),
                    prefixIcon: Icons.key_rounded,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter new password';
                      }
                      if (value.trim().length < 3) {
                        return 'Password must be at least 3 characters';
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) => _confirmFocus.requestFocus(),
                  ),

                  const SizedBox(height: 14),

                  // ── Confirm New Password ──
                  _buildPasswordField(
                    label: 'Confirm New Password',
                    hint: 'Re-enter new password to verify',
                    controller: _confirmController,
                    focusNode: _confirmFocus,
                    obscureText: _obscureConfirm,
                    onToggleVisibility: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                    prefixIcon: Icons.check_circle_outline_rounded,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm the new password';
                      }
                      if (value != _newController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) => _changePassword(),
                  ),

                  // ── Error banner ──
                  if (_error != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFECACA)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            size: 16,
                            color: Color(0xFFDC2626),
                          ),
                          const SizedBox(width: 8),
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

                  const SizedBox(height: 24),

                  // ── Action Buttons ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Cancel Button
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _saving
                              ? null
                              : () => Navigator.of(context).pop(false),
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
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      // Update Password Button
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _saving ? null : _changePassword,
                          borderRadius: BorderRadius.circular(8),
                          child: Ink(
                            decoration: BoxDecoration(
                              color: const Color(0xFF0D3B82),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0D3B82)
                                      .withValues(alpha: 0.28),
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
                                  if (_saving)
                                    const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                  else ...[
                                    const Icon(
                                      Icons.lock_reset_rounded,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 7),
                                  ],
                                  Text(
                                    _saving ? 'Updating...' : 'Update Password',
                                    style: const TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
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
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    required IconData prefixIcon,
    required FormFieldValidator<String> validator,
    required ValueChanged<String> onFieldSubmitted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscureText,
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 12.5,
              fontWeight: FontWeight.w400,
              color: Color(0xFF94A3B8),
            ),
            prefixIcon: Icon(
              prefixIcon,
              size: 17,
              color: const Color(0xFF64748B),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 17,
                color: const Color(0xFF64748B),
              ),
              tooltip: obscureText ? 'Show password' : 'Hide password',
              onPressed: onToggleVisibility,
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFF0D3B82),
                width: 1.6,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFFDC2626),
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFFDC2626),
                width: 1.6,
              ),
            ),
          ),
          onChanged: (_) {
            if (_error != null) setState(() => _error = null);
          },
          validator: validator,
          onFieldSubmitted: onFieldSubmitted,
        ),
      ],
    );
  }
}
