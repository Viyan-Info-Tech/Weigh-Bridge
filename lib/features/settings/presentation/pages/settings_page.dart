import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/billing_settings.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';
import '../../../../core/utils/text_formatters.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();

  // Weight Unit
  String _weightUnit = 'ton';

  // Bill Numbering Controllers
  final _billPrefixController = TextEditingController(text: 'WB');
  final _billStartingNumberController = TextEditingController(text: '1');
  final _billNumberDigitsController = TextEditingController(text: '5');

  // Business Info Controllers
  final _businessNameController = TextEditingController(
    text: 'VIYAN WEIGHBRIDGE',
  );
  final _businessSubtitleController = TextEditingController(
    text: 'Computer Weigh Bridge',
  );
  final _serviceTextController = TextEditingController(
    text: '24 HOURS SERVICE',
  );
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _gstinController = TextEditingController();
  final _logoPathController = TextEditingController();

  // Receipt Content
  final _receiptTitleController = TextEditingController(
    text: 'WEIGHMENT RECEIPT',
  );
  final _footerNoteController = TextEditingController(
    text: 'Please check the weight before leaving the weighbridge.',
  );

  // Field Visibility Toggles
  bool _showSerialNumber = true;
  bool _showDate = true;
  bool _showTime = true;
  bool _showVehicleNumber = true;
  bool _showMaterial = true;
  bool _showCustomer = true;
  bool _showGrossWeight = true;
  bool _showTareWeight = true;
  bool _showNetWeight = true;
  bool _showAmount = true;
  bool _showPaymentMode = true;
  bool _showCashReceived = true;
  bool _showRemarks = true;
  bool _showFooterNote = true;

  bool _isEditing = false;
  BillingSettings? _savedSettings;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // In case settings are already loaded in bloc
    final currentSettings = context.read<SettingsBloc>().state.settings;
    if (currentSettings != null) {
      _populateFromSettings(currentSettings);
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _billPrefixController.dispose();
    _billStartingNumberController.dispose();
    _billNumberDigitsController.dispose();
    _businessNameController.dispose();
    _businessSubtitleController.dispose();
    _serviceTextController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _gstinController.dispose();
    _logoPathController.dispose();
    _receiptTitleController.dispose();
    _footerNoteController.dispose();
    super.dispose();
  }

  void _populateFromSettings(BillingSettings settings) {
    _savedSettings = settings;
    _weightUnit = settings.weightUnit;
    _billPrefixController.text = settings.billPrefix;
    _billStartingNumberController.text = settings.billStartingNumber.toString();
    _billNumberDigitsController.text = settings.billNumberDigits.toString();
    _businessNameController.text = settings.businessName;
    _businessSubtitleController.text = settings.businessSubtitle ?? '';
    _serviceTextController.text = settings.serviceText ?? '';
    _addressController.text = settings.address ?? '';
    _phoneController.text = settings.phoneNumber ?? '';
    _emailController.text = settings.email ?? '';
    _gstinController.text = settings.gstin ?? '';
    _logoPathController.text = settings.logoPath ?? '';
    _receiptTitleController.text = settings.receiptTitle;
    _footerNoteController.text = settings.footerNote ?? '';

    _showSerialNumber = settings.showSerialNumber;
    _showDate = settings.showDate;
    _showTime = settings.showTime;
    _showVehicleNumber = settings.showVehicleNumber;
    _showMaterial = settings.showMaterial;
    _showCustomer = settings.showCustomer;
    _showGrossWeight = settings.showGrossWeight;
    _showTareWeight = settings.showTareWeight;
    _showNetWeight = settings.showNetWeight;
    _showAmount = settings.showAmount;
    _showPaymentMode = settings.showPaymentMode;
    _showCashReceived = settings.showCashReceived;
    _showRemarks = settings.showRemarks;
    _showFooterNote = settings.showFooterNote;
  }

  void _cancelEditing() {
    if (_savedSettings != null) {
      _populateFromSettings(_savedSettings!);
    }
    setState(() {
      _isEditing = false;
    });
  }

  void _showResetConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFDC2626),
                size: 24,
              ),
              SizedBox(width: 10),
              Text(
                'Reset Settings?',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          content: const Text(
            'This will restore all settings to their default values. Your current changes will be lost.',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
              color: Color(0xFF475569),
              height: 1.4,
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF64748B),
                side: const BorderSide(color: Color(0xFFCBD5E1)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetToDefaults();
                setState(() {
                  _isEditing = true;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text('Reset Defaults'),
            ),
          ],
        );
      },
    );
  }

  void _resetToDefaults() {
    setState(() {
      _weightUnit = 'ton';
      _billPrefixController.text = 'WB';
      _billStartingNumberController.text = '1';
      _billNumberDigitsController.text = '5';
      _businessNameController.text = 'VIYAN WEIGHBRIDGE';
      _businessSubtitleController.text = 'Computer Weigh Bridge';
      _serviceTextController.text = '24 HOURS SERVICE';
      _addressController.text = '';
      _phoneController.text = '';
      _emailController.text = '';
      _gstinController.text = '';
      _logoPathController.text = '';
      _receiptTitleController.text = 'WEIGHMENT RECEIPT';
      _footerNoteController.text =
          'Please check the weight before leaving the weighbridge.';

      _showSerialNumber = true;
      _showDate = true;
      _showTime = true;
      _showVehicleNumber = true;
      _showMaterial = true;
      _showCustomer = true;
      _showGrossWeight = true;
      _showTareWeight = true;
      _showNetWeight = true;
      _showAmount = true;
      _showPaymentMode = true;
      _showCashReceived = true;
      _showRemarks = true;
      _showFooterNote = true;
    });
  }

  void _selectAllFields(bool select) {
    setState(() {
      _showSerialNumber = select;
      _showDate = select;
      _showTime = select;
      _showVehicleNumber = select;
      _showMaterial = select;
      _showCustomer = select;
      _showGrossWeight = select;
      _showTareWeight = select;
      _showNetWeight = select;
      _showAmount = select;
      _showPaymentMode = select;
      _showCashReceived = select;
      _showRemarks = select;
      _showFooterNote = select;
    });
  }

  String get _currentBillPreview {
    final prefix = _billPrefixController.text.trim().isEmpty
        ? 'WB'
        : _billPrefixController.text.trim();
    final startNum =
        int.tryParse(_billStartingNumberController.text.trim()) ?? 1;
    final digits = int.tryParse(_billNumberDigitsController.text.trim()) ?? 5;
    return '$prefix-${startNum.toString().padLeft(digits, '0')}';
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please correct the validation errors in the settings form',
          ),
          backgroundColor: Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final startNum =
        int.tryParse(_billStartingNumberController.text.trim()) ?? 1;
    final digits = int.tryParse(_billNumberDigitsController.text.trim()) ?? 5;

    final updated = BillingSettings(
      weightUnit: _weightUnit,
      billPrefix: _billPrefixController.text.trim().isEmpty
          ? 'WB'
          : _billPrefixController.text.trim().toUpperCase(),
      billStartingNumber: startNum,
      billNumberDigits: digits,
      businessName: _businessNameController.text.trim().isEmpty
          ? 'VIYAN WEIGHBRIDGE'
          : _businessNameController.text.trim(),
      businessSubtitle: _businessSubtitleController.text.trim().isEmpty
          ? null
          : _businessSubtitleController.text.trim(),
      serviceText: _serviceTextController.text.trim().isEmpty
          ? null
          : _serviceTextController.text.trim(),
      address: _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
      phoneNumber: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      gstin: _gstinController.text.trim().isEmpty
          ? null
          : _gstinController.text.trim().toUpperCase(),
      logoPath: _logoPathController.text.trim().isEmpty
          ? null
          : _logoPathController.text.trim(),
      receiptTitle: _receiptTitleController.text.trim().isEmpty
          ? 'WEIGHMENT RECEIPT'
          : _receiptTitleController.text.trim(),
      showSerialNumber: _showSerialNumber,
      showDate: _showDate,
      showTime: _showTime,
      showVehicleNumber: _showVehicleNumber,
      showMaterial: _showMaterial,
      showCustomer: _showCustomer,
      showGrossWeight: _showGrossWeight,
      showTareWeight: _showTareWeight,
      showNetWeight: _showNetWeight,
      showAmount: _showAmount,
      showPaymentMode: _showPaymentMode,
      showCashReceived: _showCashReceived,
      showRemarks: _showRemarks,
      showFooterNote: _showFooterNote,
      footerNote: _footerNoteController.text.trim().isEmpty
          ? null
          : _footerNoteController.text.trim(),
      updatedAt: DateTime.now(),
    );

    context.read<SettingsBloc>().add(UpdateBillingSettings(updated));
  }

  BillingSettings _buildCurrentSettingsSnapshot() {
    final startNum =
        int.tryParse(_billStartingNumberController.text.trim()) ?? 1;
    final digits = int.tryParse(_billNumberDigitsController.text.trim()) ?? 5;

    return BillingSettings(
      weightUnit: _weightUnit,
      billPrefix: _billPrefixController.text.trim().isEmpty
          ? 'WB'
          : _billPrefixController.text.trim().toUpperCase(),
      billStartingNumber: startNum,
      billNumberDigits: digits,
      businessName: _businessNameController.text.trim().isEmpty
          ? 'VIYAN WEIGHBRIDGE'
          : _businessNameController.text.trim(),
      businessSubtitle: _businessSubtitleController.text.trim().isEmpty
          ? null
          : _businessSubtitleController.text.trim(),
      serviceText: _serviceTextController.text.trim().isEmpty
          ? null
          : _serviceTextController.text.trim(),
      address: _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
      phoneNumber: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      gstin: _gstinController.text.trim().isEmpty
          ? null
          : _gstinController.text.trim().toUpperCase(),
      logoPath: _logoPathController.text.trim().isEmpty
          ? null
          : _logoPathController.text.trim(),
      receiptTitle: _receiptTitleController.text.trim().isEmpty
          ? 'WEIGHMENT RECEIPT'
          : _receiptTitleController.text.trim(),
      showSerialNumber: _showSerialNumber,
      showDate: _showDate,
      showTime: _showTime,
      showVehicleNumber: _showVehicleNumber,
      showMaterial: _showMaterial,
      showCustomer: _showCustomer,
      showGrossWeight: _showGrossWeight,
      showTareWeight: _showTareWeight,
      showNetWeight: _showNetWeight,
      showAmount: _showAmount,
      showPaymentMode: _showPaymentMode,
      showCashReceived: _showCashReceived,
      showRemarks: _showRemarks,
      showFooterNote: _showFooterNote,
      footerNote: _footerNoteController.text.trim().isEmpty
          ? null
          : _footerNoteController.text.trim(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsBloc, SettingsState>(
      listener: (context, state) {
        if (state.status == SettingsStatus.saved) {
          if (state.settings != null) {
            _populateFromSettings(state.settings!);
          }
          setState(() {
            _isEditing = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Settings saved successfully!'),
              backgroundColor: Color(0xFF16A34A),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state.status == SettingsStatus.error &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: const Color(0xFFDC2626),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state.status == SettingsStatus.loaded &&
            !_isInitialized &&
            state.settings != null) {
          _populateFromSettings(state.settings!);
          setState(() {
            _isInitialized = true;
          });
        }
      },
      builder: (context, state) {
        final isSaving = state.status == SettingsStatus.saving;

        return Scaffold(
          backgroundColor: const Color(0xFFF1F5F9),
          body: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildTopAppBar(isSaving),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final compact = width < 700;
                      final horizontalPadding = compact
                          ? 12.0
                          : width < 960
                          ? 16.0
                          : 24.0;
                      final verticalPadding = compact ? 12.0 : 16.0;
                      final useTwoColumns = _shouldUseTwoColumns(
                        width,
                        horizontalPadding,
                      );
                      final formColumn = Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildWeightUnitCard(),
                          const SizedBox(height: 16),
                          _buildBillNumberingCard(),
                          const SizedBox(height: 16),
                          _buildBusinessInfoCard(),
                          const SizedBox(height: 16),
                          _buildReceiptContentCard(),
                          const SizedBox(height: 16),
                          _buildFooterNoteCard(),
                        ],
                      );

                      if (useTwoColumns) {
                        return Padding(
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            verticalPadding,
                            horizontalPadding,
                            compact ? 12 : 24,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 6,
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      formColumn,
                                      const SizedBox(height: 24),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                flex: 4,
                                child: SingleChildScrollView(
                                  child: _buildLivePreviewCard(),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          verticalPadding,
                          horizontalPadding,
                          compact ? 16 : 24,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            formColumn,
                            const SizedBox(height: 20),
                            _buildLivePreviewCard(),
                            const SizedBox(height: 24),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _shouldUseTwoColumns(double width, double horizontalPadding) {
    const gap = 20.0;
    final inner = width - (horizontalPadding * 2) - gap;
    if (inner <= 0) return false;
    final leftWidth = inner * 0.6;
    final rightWidth = inner * 0.4;
    if (width >= 1100) return true;
    if (width >= 900) {
      return leftWidth >= 380 && rightWidth >= 280;
    }
    return false;
  }

  Widget _buildResponsiveFieldRow({
    required List<Widget> children,
    double minItemWidth = 200,
    double spacing = 12,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : minItemWidth;
        final needed =
            children.length * minItemWidth + (children.length - 1) * spacing;
        final canFitRow = children.length > 1 && needed <= maxWidth;

        if (canFitRow) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) SizedBox(width: spacing),
                Expanded(child: children[i]),
              ],
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) SizedBox(height: spacing),
              children[i],
            ],
          ],
        );
      },
    );
  }

  Widget _buildActionButtons(bool isSaving) {
    if (!_isEditing) {
      return Wrap(
        spacing: 12,
        runSpacing: 8,
        alignment: WrapAlignment.end,
        children: [
          OutlinedButton.icon(
            onPressed: isSaving ? null : _showResetConfirmationDialog,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Reset Defaults'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF64748B),
              side: const BorderSide(color: Color(0xFFCBD5E1)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => setState(() => _isEditing = true),
            icon: const Icon(Icons.edit_rounded, size: 18),
            label: const Text(
              'Edit Settings',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D3B82),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
            ),
          ),
        ],
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      children: [
        OutlinedButton.icon(
          onPressed: isSaving ? null : _cancelEditing,
          icon: const Icon(Icons.close_rounded, size: 16),
          label: const Text('Cancel'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF64748B),
            side: const BorderSide(color: Color(0xFFCBD5E1)),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: isSaving ? null : _handleSave,
          icon: isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.check_rounded, size: 18),
          label: Text(
            isSaving ? 'Saving...' : 'Save Settings',
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF16A34A),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildTopAppBar(bool isSaving) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stacked = constraints.maxWidth < 820;
          final titleBlock = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D3B82).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: Color(0xFF0D3B82),
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Settings',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Configure billing number format, business information, and ticket layout',
                      softWrap: true,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );

          if (stacked) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                titleBlock,
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: _buildActionButtons(isSaving),
                ),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: titleBlock),
              const SizedBox(width: 12),
              _buildActionButtons(isSaving),
            ],
          );
        },
      ),
    );
  }

  // 1. Weight Unit Card
  Widget _buildWeightUnitCard() {
    return _buildCardWrapper(
      icon: Icons.scale_rounded,
      iconBg: const Color(0xFFEFF6FF),
      iconColor: const Color(0xFF2563EB),
      title: 'Weight Unit',
      subtitle:
          'Select the primary unit for scale measurements across the application',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stackTiles = constraints.maxWidth < 420;
          final kgTile = _buildUnitRadioTile(
            title: 'Kilogram (kg)',
            subtitle: 'Metric standard (1,000 kg = 1 ton)',
            value: 'kg',
          );
          final tonTile = _buildUnitRadioTile(
            title: 'Tonne (ton)',
            subtitle: 'Common industrial weighbridge unit',
            value: 'ton',
          );

          if (stackTiles) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [kgTile, const SizedBox(height: 12), tonTile],
            );
          }

          return Row(
            children: [
              Expanded(child: kgTile),
              const SizedBox(width: 12),
              Expanded(child: tonTile),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUnitRadioTile({
    required String title,
    required String subtitle,
    required String value,
  }) {
    final isSelected = _weightUnit == value;
    return InkWell(
      onTap: _isEditing ? () => setState(() => _weightUnit = value) : null,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF0D3B82).withValues(alpha: 0.05)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF0D3B82)
                : const Color(0xFFE2E8F0),
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF0D3B82)
                      : const Color(0xFF94A3B8),
                  width: isSelected ? 5.5 : 1.5,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    softWrap: true,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w600,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    softWrap: true,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 2. Bill Numbering Card
  Widget _buildBillNumberingCard() {
    return _buildCardWrapper(
      icon: Icons.format_list_numbered_rounded,
      iconBg: const Color(0xFFF5F3FF),
      iconColor: const Color(0xFF7C3AED),
      title: 'Bill Number Settings',
      subtitle:
          'Define the format and starting sequence for generated weighment bills',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildResponsiveFieldRow(
            minItemWidth: 160,
            children: [
              _buildTextField(
                label: 'Prefix',
                hint: 'WB',
                controller: _billPrefixController,
                maxLength: 6,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                ],
                onChanged: (_) => setState(() {}),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              _buildTextField(
                label: 'Starting Number',
                hint: '1',
                controller: _billStartingNumberController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => setState(() {}),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  final n = int.tryParse(v);
                  if (n == null || n < 1) return 'Must be >= 1';
                  return null;
                },
              ),
              _buildTextField(
                label: 'Number of Digits',
                hint: '5',
                controller: _billNumberDigitsController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => setState(() {}),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  final n = int.tryParse(v);
                  if (n == null || n < 3 || n > 10) return 'Between 3-10';
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
                    _currentBillPreview,
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

  // 3. Business Information Card
  Widget _buildBusinessInfoCard() {
    return _buildCardWrapper(
      icon: Icons.business_rounded,
      iconBg: const Color(0xFFEFF6FF),
      iconColor: const Color(0xFF0D3B82),
      title: 'Business Information',
      subtitle: 'Header details printed at the top of every weighment receipt',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildResponsiveFieldRow(
            minItemWidth: 220,
            children: [
              _buildTextField(
                label: 'Business Name *',
                hint: 'VIYAN WEIGHBRIDGE',
                controller: _businessNameController,
                textCapitalization: TextCapitalization.characters,
                onChanged: (_) => setState(() {}),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Business name is required'
                    : null,
              ),
              _buildTextField(
                label: 'Business Subtitle',
                hint: 'Computer Weigh Bridge',
                controller: _businessSubtitleController,
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildResponsiveFieldRow(
            minItemWidth: 220,
            children: [
              _buildTextField(
                label: 'Service Text / Tagline',
                hint: '24 HOURS SERVICE',
                controller: _serviceTextController,
                onChanged: (_) => setState(() {}),
              ),
              _buildTextField(
                label: 'GSTIN (Tax ID)',
                hint: '33XXXXXXXXXXXXXX',
                controller: _gstinController,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [GSTNumberFormatter()],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return null; // GSTIN is optional
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
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTextField(
            label: 'Address',
            hint: 'No. 12, Main Road, Industrial Area, Chennai',
            controller: _addressController,
            maxLines: 2,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          _buildResponsiveFieldRow(
            minItemWidth: 200,
            children: [
              _buildTextField(
                label: 'Phone Number *',
                hint: '9876543210',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                validator: validateIndianMobileNumber,
                onChanged: (_) => setState(() {}),
              ),
              _buildTextField(
                label: 'Email',
                hint: 'info@viyanweighbridge.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final logoField = _buildTextField(
                label: 'Business Logo Path',
                hint: '/Users/.../weighbridge_logo.png',
                controller: _logoPathController,
                onChanged: (_) => setState(() {}),
              );
              final clearButton = OutlinedButton(
                onPressed: _isEditing
                    ? () {
                        setState(() {
                          _logoPathController.clear();
                        });
                      }
                    : null,
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

  // 4. Receipt Content & Field Visibility Card
  Widget _buildReceiptContentCard() {
    return _buildCardWrapper(
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
              final titleField = _buildTextField(
                label: 'Receipt Title',
                hint: 'WEIGHMENT RECEIPT',
                controller: _receiptTitleController,
                textCapitalization: TextCapitalization.characters,
                onChanged: (_) => setState(() {}),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Title is required'
                    : null,
              );
              final actions = Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  TextButton.icon(
                    onPressed: _isEditing ? () => _selectAllFields(true) : null,
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
                    onPressed: _isEditing
                        ? () => _selectAllFields(false)
                        : null,
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
          const SizedBox(height: 16),
          const Text(
            'FIELD VISIBILITY TOGGLES',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildToggleChip(
                  'Serial Number',
                  _showSerialNumber,
                  (v) => setState(() => _showSerialNumber = v),
                ),
                _buildToggleChip(
                  'Date',
                  _showDate,
                  (v) => setState(() => _showDate = v),
                ),
                _buildToggleChip(
                  'Time',
                  _showTime,
                  (v) => setState(() => _showTime = v),
                ),
                _buildToggleChip(
                  'Vehicle Number',
                  _showVehicleNumber,
                  (v) => setState(() => _showVehicleNumber = v),
                ),
                _buildToggleChip(
                  'Material',
                  _showMaterial,
                  (v) => setState(() => _showMaterial = v),
                ),
                _buildToggleChip(
                  'Customer',
                  _showCustomer,
                  (v) => setState(() => _showCustomer = v),
                ),
                _buildToggleChip(
                  'Gross Weight',
                  _showGrossWeight,
                  (v) => setState(() => _showGrossWeight = v),
                ),
                _buildToggleChip(
                  'Tare Weight',
                  _showTareWeight,
                  (v) => setState(() => _showTareWeight = v),
                ),
                _buildToggleChip(
                  'Net Weight',
                  _showNetWeight,
                  (v) => setState(() => _showNetWeight = v),
                ),
                _buildToggleChip(
                  'Amount',
                  _showAmount,
                  (v) => setState(() => _showAmount = v),
                ),
                _buildToggleChip(
                  'Payment Mode',
                  _showPaymentMode,
                  (v) => setState(() => _showPaymentMode = v),
                ),
                _buildToggleChip(
                  'Cash Received',
                  _showCashReceived,
                  (v) => setState(() => _showCashReceived = v),
                ),
                _buildToggleChip(
                  'Remarks',
                  _showRemarks,
                  (v) => setState(() => _showRemarks = v),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleChip(
    String label,
    bool isSelected,
    ValueChanged<bool> onChanged,
  ) {
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      labelStyle: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? const Color(0xFF0D3B82) : const Color(0xFF475569),
      ),
      selectedColor: const Color(0xFF0D3B82).withValues(alpha: 0.12),
      checkmarkColor: const Color(0xFF0D3B82),
      backgroundColor: Colors.white,
      side: BorderSide(
        color: isSelected ? const Color(0xFF0D3B82) : const Color(0xFFCBD5E1),
        width: isSelected ? 1.5 : 1.0,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      onSelected: _isEditing ? onChanged : null,
    );
  }

  // 5. Footer Note Card
  Widget _buildFooterNoteCard() {
    return _buildCardWrapper(
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
                value: _showFooterNote,
                onChanged: _isEditing
                    ? (v) => setState(() => _showFooterNote = v ?? true)
                    : null,
                activeColor: const Color(0xFF0D3B82),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    'Show Footer Note on Receipt',
                    softWrap: true,
                    style: TextStyle(
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
          _buildTextField(
            label: 'Footer Note Text',
            hint: 'Please check the weight before leaving the weighbridge.',
            controller: _footerNoteController,
            maxLines: 2,
            enabled: _showFooterNote,
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  // Right Side: Live Thermal Receipt Preview
  Widget _buildLivePreviewCard() {
    final settings = _buildCurrentSettingsSnapshot();
    final hasLogo =
        settings.logoPath != null &&
        settings.logoPath!.trim().isNotEmpty &&
        File(settings.logoPath!).existsSync();

    final dateFormatted = DateFormat('dd/MM/yyyy').format(DateTime.now());
    final timeFormatted = DateFormat('hh:mm:ss a').format(DateTime.now());
    final timestamp = DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D3B82).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.visibility_rounded,
                    color: Color(0xFF0D3B82),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Live Receipt Preview',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        'Reflects template changes in real time',
                        softWrap: true,
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 11,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          // The Thermal Slip
          Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final available = constraints.maxWidth.isFinite
                    ? constraints.maxWidth
                    : 290.0;
                final slipWidth = available < 290 ? available : 290.0;
                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: slipWidth,
                      minWidth: slipWidth < 180 ? slipWidth : 180,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: const Color(0xFFCBD5E1),
                          width: 0.8,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: slipWidth < 220 ? 10 : 16,
                        vertical: 14,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Business Logo & Header
                          if (hasLogo)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Image.file(
                                File(settings.logoPath!),
                                height: 32,
                                fit: BoxFit.contain,
                                errorBuilder: (_, _, _) => _buildScaleBadge(),
                              ),
                            )
                          else
                            _buildScaleBadge(),
                          const SizedBox(height: 4),
                          Text(
                            settings.businessName,
                            textAlign: TextAlign.center,
                            softWrap: true,
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                              letterSpacing: 1.0,
                            ),
                          ),
                          if (settings.businessSubtitle != null &&
                              settings.businessSubtitle!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              settings.businessSubtitle!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                          if (settings.serviceText != null &&
                              settings.serviceText!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              settings.serviceText!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF475569),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                          if (settings.address != null &&
                              settings.address!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              settings.address!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 7.5,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                          if (settings.phoneNumber != null &&
                              settings.phoneNumber!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Ph: ${settings.phoneNumber}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 7.5,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                          if (settings.gstin != null &&
                              settings.gstin!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              'GSTIN: ${settings.gstin}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 7.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],

                          const SizedBox(height: 6),
                          _buildDashedDivider(),
                          const SizedBox(height: 6),

                          // Receipt Title
                          Text(
                            settings.receiptTitle,
                            textAlign: TextAlign.center,
                            softWrap: true,
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Info Rows
                          if (_showSerialNumber || _showDate || _showTime) ...[
                            _buildDashedDivider(),
                            const SizedBox(height: 4),
                            if (_showSerialNumber)
                              _buildReceiptRow('SL.NO.', _currentBillPreview),
                            if (_showDate)
                              _buildReceiptRow('Date', dateFormatted),
                            if (_showTime)
                              _buildReceiptRow('Time', timeFormatted),
                            const SizedBox(height: 4),
                          ],

                          if (_showVehicleNumber ||
                              _showMaterial ||
                              _showCustomer) ...[
                            _buildDashedDivider(),
                            const SizedBox(height: 4),
                            if (_showVehicleNumber)
                              _buildReceiptRow('Vehicle No.', 'TN 01 AB 1234'),
                            if (_showMaterial)
                              _buildReceiptRow(
                                'Material',
                                'Crushed Stone (Gravel)',
                              ),
                            if (_showCustomer)
                              _buildReceiptRow(
                                'Customer',
                                'UltraTech Cement Ltd.',
                              ),
                            const SizedBox(height: 4),
                          ],

                          if (_showGrossWeight ||
                              _showTareWeight ||
                              _showNetWeight) ...[
                            _buildDashedDivider(),
                            const SizedBox(height: 4),
                            if (_showGrossWeight)
                              _buildReceiptWeightRow(
                                'Gross Weight',
                                _weightUnit == 'kg'
                                    ? '28,450 kg'
                                    : '28.450 ton',
                              ),
                            if (_showTareWeight)
                              _buildReceiptWeightRow(
                                'Tare Weight',
                                _weightUnit == 'kg'
                                    ? '10,200 kg'
                                    : '10.200 ton',
                              ),
                            if (_showNetWeight) ...[
                              const SizedBox(height: 2),
                              _buildDashedDivider(),
                              const SizedBox(height: 2),
                              _buildReceiptWeightRow(
                                'Net Weight',
                                _weightUnit == 'kg'
                                    ? '18,250 kg'
                                    : '18.250 ton',
                                isBold: true,
                              ),
                            ],
                            const SizedBox(height: 4),
                          ],

                          if (_showAmount ||
                              _showPaymentMode ||
                              _showCashReceived) ...[
                            _buildDashedDivider(),
                            const SizedBox(height: 4),
                            if (_showAmount)
                              _buildReceiptRow('Amount', 'Rs. 350.00'),
                            if (_showPaymentMode)
                              _buildReceiptRow('Payment', 'CASH'),
                            if (_showCashReceived)
                              _buildReceiptRow('Cash Received', 'Rs. 350.00'),
                            const SizedBox(height: 4),
                          ],

                          if (_showRemarks) ...[
                            _buildDashedDivider(),
                            const SizedBox(height: 4),
                            const Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Note: ',
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF475569),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'Standard delivery weighment',
                                    style: TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 8.5,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                          ],

                          if (_showFooterNote &&
                              settings.footerNote != null &&
                              settings.footerNote!.isNotEmpty) ...[
                            _buildDashedDivider(),
                            const SizedBox(height: 6),
                            Text(
                              'Note: ${settings.footerNote!}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 8,
                                color: Color(0xFF94A3B8),
                                height: 1.3,
                              ),
                            ),
                          ],

                          const SizedBox(height: 8),
                          Center(
                            child: Text(
                              '* $timestamp *',
                              style: const TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 7,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScaleBadge() {
    return Center(
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF38BDF8), width: 1),
        ),
        child: const Icon(Icons.scale_rounded, color: Colors.white, size: 15),
      ),
    );
  }

  Widget _buildDashedDivider() {
    return SizedBox(
      width: double.infinity,
      height: 1,
      child: CustomPaint(painter: _DashedLinePainter()),
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return _buildAdaptiveReceiptRow(
      label: label,
      value: value,
      valueStyle: const TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 9.5,
        fontWeight: FontWeight.w700,
        color: Color(0xFF0F172A),
      ),
    );
  }

  Widget _buildReceiptWeightRow(
    String label,
    String value, {
    bool isBold = false,
  }) {
    return _buildAdaptiveReceiptRow(
      label: label,
      value: value,
      valueStyle: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: isBold ? 10.5 : 10.0,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF0F172A),
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildAdaptiveReceiptRow({
    required String label,
    required String value,
    required TextStyle valueStyle,
  }) {
    const labelStyle = TextStyle(
      fontFamily: 'PlusJakartaSans',
      fontSize: 9.5,
      fontWeight: FontWeight.w600,
      color: Color(0xFF64748B),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.2),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : 290.0;
          if (maxWidth < 160) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: labelStyle),
                Text(value, softWrap: true, style: valueStyle),
              ],
            );
          }

          final labelWidth = (maxWidth * 0.42).clamp(72.0, 100.0);
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: labelWidth,
                child: Text(label, softWrap: true, style: labelStyle),
              ),
              Expanded(child: Text(value, softWrap: true, style: valueStyle)),
            ],
          );
        },
      ),
    );
  }

  // Card Shell Helper
  Widget _buildCardWrapper({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 400;
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(compact ? 14 : 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: iconColor, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          softWrap: true,
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          softWrap: true,
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 16),
              child,
            ],
          ),
        );
      },
    );
  }

  // Text Field Helper
  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
    int? maxLength,
    bool enabled = true,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onChanged,
    FormFieldValidator<String>? validator,
  }) {
    final effectiveEnabled = enabled && _isEditing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          softWrap: true,
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          enabled: effectiveEnabled,
          maxLines: maxLines,
          maxLength: maxLength,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          validator: validator,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: effectiveEnabled
                ? const Color(0xFF0F172A)
                : const Color(0xFF334155),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Colors.grey.shade400,
            ),
            filled: true,
            fillColor: effectiveEnabled
                ? const Color(0xFFF8FAFC)
                : const Color(0xFFF1F5F9),
            counterText: '',
            errorMaxLines: 3,
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
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
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
              borderSide: const BorderSide(color: Color(0xFFDC2626)),
            ),
          ),
        ),
      ],
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0) return;
    const dashWidth = 4.0;
    const dashGap = 3.0;
    final paint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 1;
    var x = 0.0;
    final y = size.height / 2;
    while (x < size.width) {
      final endX = x + dashWidth;
      canvas.drawLine(
        Offset(x, y),
        Offset(endX > size.width ? size.width : endX, y),
        paint,
      );
      x += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
