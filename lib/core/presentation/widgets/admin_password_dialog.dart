import 'package:flutter/material.dart';

const _adminPassword = '123';

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
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _unlock() {
    if (_controller.text == _adminPassword) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() => _error = 'Incorrect password');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Administrator Access'),
      content: SizedBox(
        width: 340,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter password to continue'),
            const SizedBox(height: 18),
            TextField(
              controller: _controller,
              obscureText: true,
              autofocus: true,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: 'Password',
                errorText: _error,
              ),
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
              onSubmitted: (_) => _unlock(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _unlock, child: const Text('Unlock')),
      ],
    );
  }
}
