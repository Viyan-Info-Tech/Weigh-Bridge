import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/security/admin_password_service.dart';

Future<bool> showChangeAdminPasswordDialog(BuildContext context) async =>
    await showDialog<bool>(
      context: context,
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
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
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
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not update the password.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Change Administrator Password'),
    content: SizedBox(
      width: 380,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _passwordField('Current Password', _currentController),
            const SizedBox(height: 14),
            _passwordField(
              'New Password',
              _newController,
              validator: (value) => value == null || value.isEmpty
                  ? 'Enter a new password'
                  : null,
            ),
            const SizedBox(height: 14),
            _passwordField(
              'Confirm New Password',
              _confirmController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Confirm the new password';
                }
                if (value != _newController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
              onSubmitted: (_) => _changePassword(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _error!,
                  style: const TextStyle(color: Color(0xFFDC2626)),
                ),
              ),
            ],
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: _saving ? null : () => Navigator.of(context).pop(false),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: _saving ? null : _changePassword,
        child: _saving
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Change Password'),
      ),
    ],
  );

  Widget _passwordField(
    String label,
    TextEditingController controller, {
    String? Function(String?)? validator,
    void Function(String)? onSubmitted,
  }) => TextFormField(
    controller: controller,
    obscureText: true,
    decoration: InputDecoration(labelText: label),
    validator: validator ??
        (value) => value == null || value.isEmpty ? 'Enter $label' : null,
    onFieldSubmitted: onSubmitted,
  );
}
