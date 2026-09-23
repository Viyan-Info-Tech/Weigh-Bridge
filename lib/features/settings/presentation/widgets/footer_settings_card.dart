import 'package:flutter/material.dart';

import 'settings_form_field.dart';

class FooterSettingsCard extends StatelessWidget {
  const FooterSettingsCard({
    super.key,
    required this.footerNoteController,
    required this.showFooterNote,
    required this.isEditing,
    required this.onShowFooterNoteChanged,
    required this.onFooterNoteChanged,
  });

  final TextEditingController footerNoteController;
  final bool showFooterNote;
  final bool isEditing;
  final ValueChanged<bool?> onShowFooterNoteChanged;
  final ValueChanged<String> onFooterNoteChanged;

  @override
  Widget build(BuildContext context) {
    return CardWrapper(
      icon: Icons.edit_note_rounded,
      iconBg: const Color(0xFFECFDF5),
      iconColor: const Color(0xFF059669),
      title: 'Footer Settings',
      subtitle:
          'Disclaimer or notice printed at the bottom of the weighment slip',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: showFooterNote,
                onChanged: isEditing ? onShowFooterNoteChanged : null,
                activeColor: const Color(0xFF0D3B82),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    'Show Footer Note on Receipt',
                    softWrap: true,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SettingsFormTextField(
            label: 'Footer Note Text',
            hint: 'Please check the weight before leaving the weighbridge.',
            controller: footerNoteController,
            maxLines: 2,
            enabled: showFooterNote,
            onChanged: onFooterNoteChanged,
            isEditing: isEditing,
          ),
        ],
      ),
    );
  }
}
