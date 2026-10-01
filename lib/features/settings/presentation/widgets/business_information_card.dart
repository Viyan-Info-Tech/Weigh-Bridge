import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/text_formatters.dart';
import 'settings_form_field.dart';

class BusinessInformationCard extends StatelessWidget {
  const BusinessInformationCard({
    super.key,
    required this.businessNameController,
    required this.businessSubtitleController,
    required this.serviceTextController,
    required this.addressController,
    required this.phoneController,
    required this.emailController,
    required this.gstinController,
    required this.logoPathController,
    required this.isEditing,
    required this.onLogoClear,
    required this.onChanged,
  });

  final TextEditingController businessNameController;
  final TextEditingController businessSubtitleController;
  final TextEditingController serviceTextController;
  final TextEditingController addressController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController gstinController;
  final TextEditingController logoPathController;
  final bool isEditing;
  final VoidCallback onLogoClear;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return CardWrapper(
      icon: Icons.business_rounded,
      iconBg: const Color(0xFFEFF6FF),
      iconColor: const Color(0xFF0D3B82),
      title: 'Business Information',
      subtitle: 'Header details printed at the top of every weighment receipt',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveFieldRow(
            minItemWidth: 220,
            children: [
              SettingsFormTextField(
                label: 'Business Name *',
                hint: 'VIYAN WEIGHBRIDGE',
                controller: businessNameController,
                textCapitalization: TextCapitalization.characters,
                onChanged: onChanged,
                isEditing: isEditing,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Business name is required'
                    : null,
              ),
              SettingsFormTextField(
                label: 'Business Subtitle',
                hint: 'Computer Weigh Bridge',
                controller: businessSubtitleController,
                onChanged: onChanged,
                isEditing: isEditing,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ResponsiveFieldRow(
            minItemWidth: 220,
            children: [
              SettingsFormTextField(
                label: 'Service Text / Tagline',
                hint: '24 HOURS SERVICE',
                controller: serviceTextController,
                onChanged: onChanged,
                isEditing: isEditing,
              ),
              SettingsFormTextField(
                label: 'GSTIN (Tax ID)',
                hint: '33XXXXXXXXXXXXXX',
                controller: gstinController,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [GSTNumberFormatter()],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return null;
                  }
                  final gst = value.trim().toUpperCase();
                  if (gst.length != 15) {
                    return 'GST number must be 15 characters';
                  }
                  if (!RegExp(
                    r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][1-9A-Z]Z[0-9A-Z]$',
                  ).hasMatch(gst)) {
                    return 'Enter a valid GST number';
                  }
                  return null;
                },
                onChanged: onChanged,
                isEditing: isEditing,
              ),
            ],
          ),
          const SizedBox(height: 12),
          SettingsFormTextField(
            label: 'Address',
            hint: 'No. 12, Main Road, Industrial Area, Chennai',
            controller: addressController,
            maxLines: 2,
            onChanged: onChanged,
            isEditing: isEditing,
          ),
          const SizedBox(height: 12),
          ResponsiveFieldRow(
            minItemWidth: 200,
            children: [
              SettingsFormTextField(
                label: 'Phone Number',
                hint: '9876543210',
                controller: phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return null;
                  }
                  return validateIndianMobileNumber(value);
                },
                onChanged: onChanged,
                isEditing: isEditing,
              ),
              SettingsFormTextField(
                label: 'Email',
                hint: 'info@viyanweighbridge.com',
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                onChanged: onChanged,
                isEditing: isEditing,
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final logoField = SettingsFormTextField(
                label: 'Business Logo Path',
                hint: '/Users/.../weighbridge_logo.png',
                controller: logoPathController,
                onChanged: onChanged,
                isEditing: isEditing,
              );
              final clearButton = OutlinedButton(
                onPressed: isEditing ? onLogoClear : null,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF64748B),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Clear'),
              );

              if (constraints.maxWidth < 480) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    logoField,
                    const SizedBox(height: 8),
                    Align(alignment: Alignment.centerRight, child: clearButton),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: logoField),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 22),
                    child: clearButton,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
