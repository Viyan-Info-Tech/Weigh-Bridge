import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'settings_form_field.dart';

class BillNumberingCard extends StatelessWidget {
  const BillNumberingCard({
    super.key,
    required this.prefixController,
    required this.startingNumberController,
    required this.numberDigitsController,
    required this.isEditing,
    required this.onChanged,
    required this.nextBillPreview,
  });

  final TextEditingController prefixController;
  final TextEditingController startingNumberController;
  final TextEditingController numberDigitsController;
  final bool isEditing;
  final ValueChanged<String> onChanged;
  final String nextBillPreview;

  @override
  Widget build(BuildContext context) {
    return CardWrapper(
      icon: Icons.format_list_numbered_rounded,
      iconBg: const Color(0xFFF5F3FF),
      iconColor: const Color(0xFF7C3AED),
      title: 'Bill Number Settings',
      subtitle:
          'Define the format and starting sequence for generated weighment bills',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveFieldRow(
            minItemWidth: 160,
            children: [
              SettingsFormTextField(
                label: 'Prefix',
                hint: 'WB',
                controller: prefixController,
                maxLength: 5,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    final upper = newValue.text.toUpperCase();
                    return newValue.copyWith(
                      text: upper,
                      selection: newValue.selection,
                      composing: TextRange.empty,
                    );
                  }),
                ],
                onChanged: onChanged,
                isEditing: isEditing,
                validator: (value) {
                  final prefix = value?.trim() ?? '';
                  if (prefix.isEmpty) return 'Prefix is required';
                  if (!RegExp(r'^[A-Z]{1,5}$').hasMatch(prefix)) {
                    return 'Use 1–5 uppercase letters';
                  }
                  return null;
                },
              ),
              SettingsFormTextField(
                label: 'Starting Number',
                hint: '1',
                controller: startingNumberController,
                keyboardType: TextInputType.number,
                maxLength: 9,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: onChanged,
                isEditing: isEditing,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  if (!RegExp(r'^[0-9]{1,9}$').hasMatch(v)) {
                    return 'Enter up to 9 digits';
                  }
                  final n = int.tryParse(v);
                  if (n == null || n < 1) return 'Must be >= 1';
                  final digits = int.tryParse(numberDigitsController.text);
                  if (digits != null && v.length > digits) {
                    return 'Starting number cannot exceed the selected number of digits.';
                  }
                  return null;
                },
              ),
              SettingsFormTextField(
                label: 'Number of Digits',
                hint: '5',
                controller: numberDigitsController,
                keyboardType: TextInputType.number,
                maxLength: 1,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: onChanged,
                isEditing: isEditing,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  if (!RegExp(r'^[1-9]$').hasMatch(v)) {
                    return 'Enter a number from 1 to 9';
                  }
                  final n = int.tryParse(v);
                  if (n == null) return 'Enter a number from 1 to 9';
                  final startingNumber = startingNumberController.text.trim();
                  if (startingNumber.isNotEmpty && startingNumber.length > n) {
                    return 'Starting number cannot exceed the selected number of digits.';
                  }
                  return null;
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Wrap(
              spacing: 10,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: Color(0xFF64748B),
                ),
                const Text(
                  'Next Bill Number Preview:',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D3B82),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    nextBillPreview,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
