import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/billing_settings.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';
import '../../../../features/bill/domain/entities/weighment.dart';
import '../../../../features/bill/domain/repositories/bill_repository.dart';
import '../../../../features/customer/domain/repositories/customer_repository.dart';
import '../../../../features/material/domain/repositories/material_item_repository.dart';
import '../widgets/bill_numbering_card.dart';
import '../widgets/business_information_card.dart';
import '../widgets/footer_settings_card.dart';
import '../widgets/receipt_content_card.dart';
import '../widgets/receipt_preview_card.dart';
import '../widgets/settings_app_bar.dart';
import '../widgets/weight_unit_card.dart';
import '../widgets/weighment_rate_settings_card.dart';
import '../widgets/weighing_scale_settings_card.dart';
import '../widgets/admin_password_card.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();

  String _weightUnit = 'ton';

  final _billPrefixController = TextEditingController(text: 'WB');
  final _billStartingNumberController = TextEditingController(text: '1');
  final _billNumberDigitsController = TextEditingController(text: '5');

  final _businessNameController = TextEditingController(text: 'VIYAN WEIGHBRIDGE');
  final _businessSubtitleController =
      TextEditingController(text: 'Computer Weigh Bridge');
  final _serviceTextController = TextEditingController(text: '24 HOURS SERVICE');
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _gstinController = TextEditingController();
  final _logoPathController = TextEditingController();

  final _receiptTitleController = TextEditingController(text: 'WEIGHMENT RECEIPT');
  final _footerNoteController = TextEditingController(
    text: 'Please check the weight before leaving the weighbridge.',
  );

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

  Weighment? _latestWeighment;
  String? _customerName;
  String? _materialName;
  bool _isLoadingWeighment = true;

  @override
  void initState() {
    super.initState();
    final currentSettings = context.read<SettingsBloc>().state.settings;
    if (currentSettings != null) {
      _populateFromSettings(currentSettings);
      _isInitialized = true;
    }
    _loadLatestWeighment();
  }

  Future<void> _loadLatestWeighment() async {
    try {
      BillRepository? billRepository;
      CustomerRepository? customerRepository;
      MaterialItemRepository? materialRepository;

      try {
        billRepository = context.read<BillRepository>();
      } catch (_) {}

      try {
        customerRepository = context.read<CustomerRepository>();
      } catch (_) {}

      try {
        materialRepository = context.read<MaterialItemRepository>();
      } catch (_) {}

      if (billRepository == null ||
          customerRepository == null ||
          materialRepository == null) {
        if (mounted) {
          setState(() => _isLoadingWeighment = false);
        }
        return;
      }

      final weighments = await billRepository.getRecentBillsByDateRange(
        startDate: DateTime(2000),
        endDate: DateTime.now(),
        limit: 1,
      );

      if (weighments.isEmpty) {
        if (mounted) {
          setState(() => _isLoadingWeighment = false);
        }
        return;
      }

      final weighment = weighments.first;

      String? resolvedCustomerName;
      String? resolvedMaterialName;

      if (weighment.customerId > 0) {
        final customer = await customerRepository.getCustomerById(
          weighment.customerId,
        );
        resolvedCustomerName = customer?.name;
      }

      if (weighment.materialId > 0) {
        final material = await materialRepository.getMaterialById(
          weighment.materialId,
        );
        resolvedMaterialName = material?.name;
      }

      if (mounted) {
        setState(() {
          _latestWeighment = weighment;
          _customerName = resolvedCustomerName;
          _materialName = resolvedMaterialName;
          _isLoadingWeighment = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingWeighment = false);
      }
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
    _billPrefixController.text = settings.billPrefix.toUpperCase();
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
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF64748B),
                side: const BorderSide(color: Color(0xFFCBD5E1)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
    final prefix = _billPrefixController.text.trim().toUpperCase();
    final startText = _billStartingNumberController.text.trim();
    final startNum = int.tryParse(startText);
    final digits = int.tryParse(_billNumberDigitsController.text.trim());
    if (!RegExp(r'^[A-Z]{1,5}$').hasMatch(prefix) ||
        startNum == null ||
        startNum < 1 ||
        startText.length > 9 ||
        digits == null ||
        digits < 1 ||
        digits > 9 ||
        startText.length > digits) {
      return '--';
    }
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
    final digits =
        int.tryParse(_billNumberDigitsController.text.trim()) ?? 5;

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
    final digits =
        int.tryParse(_billNumberDigitsController.text.trim()) ?? 5;

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

  void _onToggleField(String field, bool value) {
    setState(() {
      switch (field) {
        case 'serialNumber':
          _showSerialNumber = value;
        case 'date':
          _showDate = value;
        case 'time':
          _showTime = value;
        case 'vehicleNumber':
          _showVehicleNumber = value;
        case 'material':
          _showMaterial = value;
        case 'customer':
          _showCustomer = value;
        case 'grossWeight':
          _showGrossWeight = value;
        case 'tareWeight':
          _showTareWeight = value;
        case 'netWeight':
          _showNetWeight = value;
        case 'amount':
          _showAmount = value;
        case 'paymentMode':
          _showPaymentMode = value;
        case 'cashReceived':
          _showCashReceived = value;
        case 'remarks':
          _showRemarks = value;
        case 'footerNote':
          _showFooterNote = value;
      }
    });
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
        final settings = _buildCurrentSettingsSnapshot();

        return Scaffold(
          backgroundColor: const Color(0xFFF1F5F9),
          body: Form(
            key: _formKey,
            child: Column(
              children: [
                SettingsAppBar(
                  isSaving: isSaving,
                  isEditing: _isEditing,
                  onEdit: () => setState(() => _isEditing = true),
                  onCancelEditing: _cancelEditing,
                  onSave: _handleSave,
                  onReset: _showResetConfirmationDialog,
                ),
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
                          const AdminPasswordCard(),
                          const SizedBox(height: 16),
                          WeightUnitCard(
                            weightUnit: _weightUnit,
                            isEditing: _isEditing,
                            onWeightUnitChanged: (value) =>
                                setState(() => _weightUnit = value),
                          ),
                          const SizedBox(height: 16),
                          BillNumberingCard(
                            prefixController: _billPrefixController,
                            startingNumberController:
                                _billStartingNumberController,
                            numberDigitsController: _billNumberDigitsController,
                            isEditing: _isEditing,
                            onChanged: (_) => setState(() {}),
                            nextBillPreview: _currentBillPreview,
                          ),
                          const SizedBox(height: 16),
                          WeighmentRateSettingsCard(isEditing: _isEditing),
                          const SizedBox(height: 16),
                          WeighingScaleSettingsCard(isEditing: _isEditing),
                          const SizedBox(height: 16),
                          BusinessInformationCard(
                            businessNameController: _businessNameController,
                            businessSubtitleController:
                                _businessSubtitleController,
                            serviceTextController: _serviceTextController,
                            addressController: _addressController,
                            phoneController: _phoneController,
                            emailController: _emailController,
                            gstinController: _gstinController,
                            logoPathController: _logoPathController,
                            isEditing: _isEditing,
                            onLogoClear: () {
                              setState(() {
                                _logoPathController.clear();
                              });
                            },
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 16),
                          ReceiptContentCard(
                            receiptTitleController: _receiptTitleController,
                            isEditing: _isEditing,
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
                            onSelectAll: () => _selectAllFields(true),
                            onDeselectAll: () => _selectAllFields(false),
                            onToggle: _onToggleField,
                            onTitleChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 16),
                          FooterSettingsCard(
                            footerNoteController: _footerNoteController,
                            showFooterNote: _showFooterNote,
                            isEditing: _isEditing,
                            onShowFooterNoteChanged: (value) {
                              setState(() {
                                _showFooterNote = value ?? true;
                              });
                            },
                            onFooterNoteChanged: (_) => setState(() {}),
                          ),
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
                                  child: ReceiptPreviewCard(
                                    settings: settings,
                                    billPreview: _currentBillPreview,
                                    dateFormatted: DateFormat('dd/MM/yyyy')
                                        .format(DateTime.now()),
                                    timeFormatted: DateFormat('hh:mm:ss a')
                                        .format(DateTime.now()),
                                    timestamp:
                                        DateFormat('dd/MM/yyyy HH:mm:ss')
                                            .format(DateTime.now()),
                                    weightUnit: _weightUnit,
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
                                    latestWeighment: _latestWeighment,
                                    customerName: _customerName,
                                    materialName: _materialName,
                                    isLoadingWeighment: _isLoadingWeighment,
                                  ),
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
                            ReceiptPreviewCard(
                              settings: settings,
                              billPreview: _currentBillPreview,
                              dateFormatted:
                                  DateFormat('dd/MM/yyyy').format(DateTime.now()),
                              timeFormatted:
                                  DateFormat('hh:mm:ss a').format(DateTime.now()),
                              timestamp: DateFormat('dd/MM/yyyy HH:mm:ss')
                                  .format(DateTime.now()),
                              weightUnit: _weightUnit,
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
                              latestWeighment: _latestWeighment,
                              customerName: _customerName,
                              materialName: _materialName,
                              isLoadingWeighment: _isLoadingWeighment,
                            ),
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
}
