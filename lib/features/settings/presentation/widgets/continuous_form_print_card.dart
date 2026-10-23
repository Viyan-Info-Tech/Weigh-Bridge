import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../bill/domain/services/preprinted_ticket_layout.dart';
import '../../domain/entities/billing_settings.dart';
import 'settings_form_field.dart';

/// Editable copy of the continuous-form print settings.
///
/// The Settings page owns one instance, populates it from [BillingSettings]
/// whenever settings arrive and reads it back when the operator saves, so the
/// card can stay stateless while still offering ~40 individually tuned values.
class PrintSettingsForm {
  PrintSettingsForm();

  int cpi = 12;
  int lpi = 6;
  bool useCustomPaper = false;
  double paperWidthMm = 0;
  double paperLengthMm = 0;
  double topOffsetMm = 0;
  double leftOffsetMm = 0;
  double columnWidthMm = 0;
  bool printWeightUnit = true;
  Map<PrePrintedField, PrePrintedFieldPlacement> grid = Map.of(
    kDefaultPrePrintedGrid,
  );

  final Map<String, TextEditingController> _controllers = {};

  /// Controller for a numeric field, created once and re-seeded whenever
  /// [applySettings] runs so the inputs always show the stored value.
  TextEditingController controller(String key, String initialValue) {
    final existing = _controllers[key];
    if (existing != null) return existing;
    return _controllers[key] = TextEditingController(text: initialValue);
  }

  void applySettings(BillingSettings settings) {
    cpi = settings.printCpi;
    lpi = settings.printLpi;
    useCustomPaper =
        settings.printPaperWidthMm > 0 && settings.printPaperLengthMm > 0;
    paperWidthMm = settings.printPaperWidthMm;
    paperLengthMm = settings.printPaperLengthMm;
    topOffsetMm = settings.printTopOffsetMm;
    leftOffsetMm = settings.printLeftOffsetMm;
    columnWidthMm = settings.printColumnWidthMm;
    printWeightUnit = settings.printWeightUnit;
    grid = decodePrePrintedGrid(settings.printFieldGrid);

    _controllers['paperWidth']?.text = _fmt(paperWidthMm);
    _controllers['paperLength']?.text = _fmt(paperLengthMm);
    _controllers['top']?.text = _fmt(topOffsetMm);
    _controllers['left']?.text = _fmt(leftOffsetMm);
    _controllers['column']?.text = _fmt(columnWidthMm);
    for (final field in PrePrintedField.values) {
      final placement = grid[field];
      _controllers['${field.name}.col']?.text = '${placement?.column ?? 0}';
      _controllers['${field.name}.line']?.text = '${placement?.line ?? 0}';
      _controllers['${field.name}.width']?.text =
          '${placement?.widthChars ?? 0}';
    }
  }

  void resetAlignment() {
    topOffsetMm = 0;
    leftOffsetMm = 0;
    columnWidthMm = 0;
    grid = Map.of(kDefaultPrePrintedGrid);
    _controllers['top']?.text = '0';
    _controllers['left']?.text = '0';
    _controllers['column']?.text = '0';
    for (final field in PrePrintedField.values) {
      final placement = kDefaultPrePrintedGrid[field]!;
      _controllers['${field.name}.col']?.text = '${placement.column}';
      _controllers['${field.name}.line']?.text = '${placement.line}';
      _controllers['${field.name}.width']?.text = '${placement.widthChars}';
    }
  }

  /// Grid as stored in the settings row: `null` while it still equals the
  /// defaults, so the column stays clean until an operator actually tunes it.
  String? get gridJson {
    final isDefault =
        grid.length == kDefaultPrePrintedGrid.length &&
        grid.entries.every((e) => kDefaultPrePrintedGrid[e.key] == e.value);
    return isDefault ? null : encodePrePrintedGrid(grid);
  }

  double get effectivePaperWidthMm => useCustomPaper ? paperWidthMm : 0;

  double get effectivePaperLengthMm => useCustomPaper ? paperLengthMm : 0;

  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
  }

  static String _fmt(double value) =>
      value == value.roundToDouble() ? value.round().toString() : '$value';
}

/// Settings card for printing onto the client's existing pre-printed
/// HMB Enterprises continuous-form certificate.
///
/// Nothing here re-creates the company design - that is already on the paper.
/// The card only positions the dynamic weighment values on the character grid
/// of the connected dot-matrix printer and lets the operator fine-tune the
/// alignment against a real printed sample.
class ContinuousFormPrintCard extends StatelessWidget {
  const ContinuousFormPrintCard({
    super.key,
    required this.form,
    required this.isEditing,
    required this.onChanged,
  });

  final PrintSettingsForm form;
  final bool isEditing;
  final VoidCallback onChanged;

  static const _labelStyle = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Color(0xFF334155),
  );

  static const _hintStyle = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 11,
    color: Color(0xFF94A3B8),
  );

  @override
  Widget build(BuildContext context) {
    return CardWrapper(
      icon: Icons.print_rounded,
      iconBg: const Color(0xFFF5F3FF),
      iconColor: const Color(0xFF7C3AED),
      title: 'Continuous Form Printing',
      subtitle:
          'Prints only the weighment data onto your existing pre-printed '
          'certificate - company details, headings and footer come from the paper',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _notice(),
          const SizedBox(height: 16),
          ResponsiveFieldRow(
            children: [
              _segmented<int>(
                label: 'Character pitch (CPI)',
                hint:
                    '12 CPI is condensed; 10 CPI is the classic dot-matrix pitch',
                value: form.cpi,
                options: const {10: '10 CPI', 12: '12 CPI'},
                enabled: isEditing,
                onSelected: (value) {
                  form.cpi = value;
                  onChanged();
                },
              ),
              _segmented<int>(
                label: 'Line pitch (LPI)',
                hint: 'Vertical density of the printed rows',
                value: form.lpi,
                options: const {6: '6 LPI', 8: '8 LPI'},
                enabled: isEditing,
                onSelected: (value) {
                  form.lpi = value;
                  onChanged();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          ResponsiveFieldRow(
            minItemWidth: 240,
            children: [
              _switchTile(
                title: 'Custom paper size',
                subtitle:
                    'Off = use the size the printer driver reports. On = force '
                    'the width/length below into the print dialog.',
                value: form.useCustomPaper,
                enabled: isEditing,
                onChanged: (value) {
                  form.useCustomPaper = value;
                  onChanged();
                },
              ),
              _switchTile(
                title: 'Print weight unit',
                subtitle:
                    'Shows "80.000 ton". Turn off when the paper already has '
                    'the unit printed on it.',
                value: form.printWeightUnit,
                enabled: isEditing,
                onChanged: (value) {
                  form.printWeightUnit = value;
                  onChanged();
                },
              ),
            ],
          ),
          if (form.useCustomPaper) ...[
            const SizedBox(height: 16),
            ResponsiveFieldRow(
              children: [
                _numberField(
                  key: 'paperWidth',
                  label: 'Paper width (mm)',
                  hint: 'e.g. 279',
                  initial: PrintSettingsForm._fmt(form.paperWidthMm),
                  enabled: isEditing && form.useCustomPaper,
                  allowDecimal: true,
                  onChanged: (text) {
                    form.paperWidthMm = double.tryParse(text) ?? 0;
                    onChanged();
                  },
                ),
                _numberField(
                  key: 'paperLength',
                  label: 'Paper length (mm)',
                  hint: 'e.g. 140',
                  initial: PrintSettingsForm._fmt(form.paperLengthMm),
                  enabled: isEditing && form.useCustomPaper,
                  allowDecimal: true,
                  onChanged: (text) {
                    form.paperLengthMm = double.tryParse(text) ?? 0;
                    onChanged();
                  },
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          ResponsiveFieldRow(
            minItemWidth: 180,
            children: [
              _numberField(
                key: 'top',
                label: 'Top offset (mm)',
                hint: '0',
                initial: PrintSettingsForm._fmt(form.topOffsetMm),
                enabled: isEditing,
                allowDecimal: true,
                onChanged: (text) {
                  form.topOffsetMm = double.tryParse(text) ?? 0;
                  onChanged();
                },
              ),
              _numberField(
                key: 'left',
                label: 'Left offset (mm)',
                hint: '0',
                initial: PrintSettingsForm._fmt(form.leftOffsetMm),
                enabled: isEditing,
                allowDecimal: true,
                onChanged: (text) {
                  form.leftOffsetMm = double.tryParse(text) ?? 0;
                  onChanged();
                },
              ),
              _numberField(
                key: 'column',
                label: 'Copy spacing (mm)',
                hint: '0 = half sheet',
                initial: PrintSettingsForm._fmt(form.columnWidthMm),
                enabled: isEditing,
                allowDecimal: true,
                onChanged: (text) {
                  form.columnWidthMm = double.tryParse(text) ?? 0;
                  onChanged();
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Field alignment (characters from the copy origin, lines from '
                  'the first row; -1 hides a field)',
                  style: _hintStyle,
                ),
              ),
              if (isEditing) ...[
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    form.resetAlignment();
                    onChanged();
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 15),
                  label: const Text('Reset alignment'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF64748B),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    textStyle: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          _fieldHeader(),
          const SizedBox(height: 6),
          for (final field in PrePrintedField.values) _fieldRow(field),
        ],
      ),
    );
  }

  Widget _notice() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF2563EB)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Each ticket prints twice - identical left and right copies on one '
              'row of the continuous form, in a single job. The logo, company '
              'name, address, headings, borders and thank-you note are already '
              'on the paper and are never printed by the application.',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 11.5,
                height: 1.45,
                color: Color(0xFF1E3A8A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _segmented<T>({
    required String label,
    required String hint,
    required T value,
    required Map<T, String> options,
    required bool enabled,
    required ValueChanged<T> onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _labelStyle),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          padding: const EdgeInsets.all(3),
          child: Row(
            children: [
              for (final option in options.entries) ...[
                if (option.key != options.keys.first) const SizedBox(width: 6),
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(6),
                    onTap: enabled ? () => onSelected(option.key) : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: value == option.key
                            ? const Color(0xFF0D3B82)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        option.value,
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: value == option.key
                              ? Colors.white
                              : const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(hint, style: _hintStyle),
      ],
    );
  }

  Widget _switchTile({
    required String title,
    required String subtitle,
    required bool value,
    required bool enabled,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 6, 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: _labelStyle),
                const SizedBox(height: 3),
                Text(subtitle, softWrap: true, style: _hintStyle),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: enabled ? onChanged : null,
            activeTrackColor: const Color(0xFF0D3B82),
          ),
        ],
      ),
    );
  }

  Widget _numberField({
    required String key,
    required String label,
    required String hint,
    required String initial,
    required bool enabled,
    required ValueChanged<String> onChanged,
    bool allowDecimal = false,
  }) {
    return SettingsFormTextField(
      label: label,
      hint: hint,
      controller: form.controller(key, initial),
      enabled: enabled,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          allowDecimal ? RegExp(r'[0-9.]') : RegExp(r'[0-9-]'),
        ),
      ],
      onChanged: onChanged,
    );
  }

  Widget _fieldHeader() {
    return Row(
      children: [
        const Expanded(child: Text('Field', style: _labelStyle)),
        _gridHeadCell('Col'),
        _gridHeadCell('Line'),
        _gridHeadCell('Width'),
      ],
    );
  }

  static Widget _gridHeadCell(String text) => SizedBox(
    width: 64,
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Color(0xFF94A3B8),
      ),
    ),
  );

  Widget _fieldRow(PrePrintedField field) {
    final placement = form.grid[field] ?? kDefaultPrePrintedGrid[field]!;

    // Re-read every cell from its controller so one edit can never drop a
    // value the operator entered in a neighbouring cell.
    void update() {
      form.grid[field] = PrePrintedFieldPlacement(
        column:
            int.tryParse(
              form.controller('${field.name}.col', '${placement.column}').text,
            ) ??
            placement.column,
        line:
            int.tryParse(
              form.controller('${field.name}.line', '${placement.line}').text,
            ) ??
            placement.line,
        widthChars:
            int.tryParse(
              form
                  .controller('${field.name}.width', '${placement.widthChars}')
                  .text,
            ) ??
            placement.widthChars,
      );
      onChanged();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              field.prePrintedLabel,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          _gridCell('${field.name}.col', placement.column, update),
          _gridCell('${field.name}.line', placement.line, update),
          _gridCell('${field.name}.width', placement.widthChars, update),
        ],
      ),
    );
  }

  Widget _gridCell(String key, int value, VoidCallback onChangedCell) {
    return SizedBox(
      width: 64,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: TextFormField(
          key: ValueKey('print-grid-$key'),
          controller: form.controller(key, '$value'),
          enabled: isEditing,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9-]')),
          ],
          onChanged: (_) => onChangedCell(),
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 8,
            ),
            filled: true,
            fillColor: isEditing ? const Color(0xFFF8FAFC) : Colors.transparent,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
              borderSide: const BorderSide(
                color: Color(0xFF0D3B82),
                width: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
