import 'package:flutter/material.dart';

import '../widgets/field_visibility_section.dart';
import '../widgets/settings_form_field.dart';

class ReceiptContentCard extends StatelessWidget {
  const ReceiptContentCard({
    super.key,
    required this.receiptTitleController,
    required this.isEditing,
    required this.showSerialNumber,
    required this.showDate,
    required this.showTime,
    required this.showVehicleNumber,
    required this.showMaterial,
    required this.showCustomer,
    required this.showGrossWeight,
    required this.showTareWeight,
    required this.showNetWeight,
    required this.showAmount,
    required this.showPaymentMode,
    required this.showCashReceived,
    required this.showRemarks,
    required this.showFooterNote,
    required this.onSelectAll,
    required this.onDeselectAll,
    required this.onToggle,
    required this.onTitleChanged,
  });

  final TextEditingController receiptTitleController;
  final bool isEditing;
  final bool showSerialNumber;
  final bool showDate;
  final bool showTime;
  final bool showVehicleNumber;
  final bool showMaterial;
  final bool showCustomer;
  final bool showGrossWeight;
  final bool showTareWeight;
  final bool showNetWeight;
  final bool showAmount;
  final bool showPaymentMode;
  final bool showCashReceived;
  final bool showRemarks;
  final bool showFooterNote;
  final VoidCallback onSelectAll;
  final VoidCallback onDeselectAll;
  final Function(String field, bool value) onToggle;
  final ValueChanged<String> onTitleChanged;

  @override
  Widget build(BuildContext context) {
    return CardWrapper(
      icon: Icons.receipt_long_rounded,
      iconBg: const Color(0xFFFEF3C7),
      iconColor: const Color(0xFFD97706),
      title: 'Receipt & Ticket Content',
      subtitle:
          'Customize the document title and select which fields appear on the printed receipt',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final titleField = SettingsFormTextField(
                label: 'Receipt Title',
                hint: 'WEIGHMENT RECEIPT',
                controller: receiptTitleController,
                textCapitalization: TextCapitalization.characters,
                onChanged: onTitleChanged,
                isEditing: isEditing,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Title is required'
                    : null,
              );
              final actions = Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  TextButton.icon(
                    onPressed: isEditing ? onSelectAll : null,
                    icon: const Icon(Icons.check_box_outlined, size: 16),
                    label: const Text('Select All'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF0D3B82),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: isEditing ? onDeselectAll : null,
                    icon: const Icon(Icons.clear_rounded, size: 16),
                    label: const Text('Deselect All'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF64748B),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              );

              if (constraints.maxWidth < 640) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    titleField,
                    const SizedBox(height: 8),
                    Align(alignment: Alignment.centerRight, child: actions),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 6, child: titleField),
                  const SizedBox(width: 12),
                  Padding(
                    padding: const EdgeInsets.only(top: 22),
                    child: actions,
                  ),
                ],
              );
            },
          ),
          FieldVisibilitySection(
            showSerialNumber: showSerialNumber,
            showDate: showDate,
            showTime: showTime,
            showVehicleNumber: showVehicleNumber,
            showMaterial: showMaterial,
            showCustomer: showCustomer,
            showGrossWeight: showGrossWeight,
            showTareWeight: showTareWeight,
            showNetWeight: showNetWeight,
            showAmount: showAmount,
            showPaymentMode: showPaymentMode,
            showCashReceived: showCashReceived,
            showRemarks: showRemarks,
            showFooterNote: showFooterNote,
            isEditing: isEditing,
            onSelectAll: onSelectAll,
            onDeselectAll: onDeselectAll,
            onToggle: onToggle,
          ),
        ],
      ),
    );
  }
}
