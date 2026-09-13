import 'package:flutter/material.dart';

import '../../../party/domain/entities/party.dart';

class QuickAddPartyDialog extends StatefulWidget {
  final Future<Party?> Function(String name, String? contactPerson) onSave;

  const QuickAddPartyDialog({super.key, required this.onSave});

  static Future<Party?> show(
    BuildContext context, {
    required Future<Party?> Function(String name, String? contactPerson) onSave,
  }) {
    return showDialog<Party?>(
      context: context,
      barrierColor: const Color(0xFF0F172A).withValues(alpha: 0.45),
      builder: (_) => QuickAddPartyDialog(onSave: onSave),
    );
  }

  @override
  State<QuickAddPartyDialog> createState() => _QuickAddPartyDialogState();
}

class _QuickAddPartyDialogState extends State<QuickAddPartyDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  void _onSave() async {
    if (_isLoading) return;
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final created = await widget.onSave(
          _nameController.text.trim(),
          _contactController.text.trim().isEmpty ? null : _contactController.text.trim(),
        );
        if (mounted) {
          if (created != null) {
            Navigator.of(context).pop(created);
          } else {
            setState(() {
              _isLoading = false;
              _errorMessage = 'Party could not be saved';
            });
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = e.toString().replaceAll('Exception: ', '');
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1F0F172A),
              blurRadius: 32,
              offset: Offset(0, 16),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFDBEAFE)),
                      ),
                      child: const Icon(
                        Icons.person_add_alt_1_rounded,
                        size: 20,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Add Party',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Add a new party to your master',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 12.5,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: _isLoading ? null : () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.close_rounded,
                          color: Colors.grey.shade400,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),

                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFECDD3)),
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
                            _errorMessage!,
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 12,
                              color: Color(0xFFB91C1C),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // Party Name
                _buildLabel('Party Name', isRequired: true),
                const SizedBox(height: 7),
                TextFormField(
                  controller: _nameController,
                  autofocus: true,
                  enabled: !_isLoading,
                  textCapitalization: TextCapitalization.words,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0F172A),
                  ),
                  decoration: _inputDecoration('Enter party name'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Party name is required' : null,
                  onFieldSubmitted: (_) => _onSave(),
                  onChanged: (_) {
                    if (_errorMessage != null) {
                      setState(() => _errorMessage = null);
                    }
                  },
                ),

                const SizedBox(height: 16),

                // Contact Person
                _buildLabel('Contact Person', isRequired: false),
                const SizedBox(height: 7),
                TextFormField(
                  controller: _contactController,
                  enabled: !_isLoading,
                  textCapitalization: TextCapitalization.words,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0F172A),
                  ),
                  decoration: _inputDecoration('Enter contact person'),
                  onFieldSubmitted: (_) => _onSave(),
                  onChanged: (_) {
                    if (_errorMessage != null) {
                      setState(() => _errorMessage = null);
                    }
                  },
                ),

                const SizedBox(height: 26),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF64748B),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 11,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _onSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D3B82),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            const Color(0xFF0D3B82).withValues(alpha: 0.6),
                        disabledForegroundColor: Colors.white70,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 11,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Save Party',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
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

  Widget _buildLabel(String text, {required bool isRequired}) {
    return Text.rich(
      TextSpan(
        text: text,
        style: const TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: Color(0xFF334155),
        ),
        children: [
          if (isRequired)
            const TextSpan(
              text: ' *',
              style: TextStyle(color: Color(0xFFE11D48)),
            ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 13,
        color: Colors.grey.shade400,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF0D3B82), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE11D48)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE11D48), width: 1.5),
      ),
    );
  }
}
