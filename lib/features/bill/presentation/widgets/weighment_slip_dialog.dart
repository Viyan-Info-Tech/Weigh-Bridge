import 'dart:io';

import 'package:flutter/material.dart' hide Material;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../party/domain/entities/party.dart';
import '../../../vehicle/domain/entities/vehicle.dart';
import '../../../vehicle_type/domain/entities/vehicle_type.dart';
import '../../../settings/domain/entities/billing_settings.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../domain/entities/weighment.dart';

class WeighmentSlipDialog extends StatelessWidget {
  final Weighment bill;
  final Vehicle? vehicle;
  final Party? party;
  final List<VehicleType> vehicleTypes;
  final String materialName;
  final BillingSettings? settings;
  final VoidCallback? onContinue;
  final String? continueLabel;

  const WeighmentSlipDialog({
    super.key,
    required this.bill,
    this.vehicle,
    this.party,
    this.vehicleTypes = const [],
    required this.materialName,
    this.settings,
    this.onContinue,
    this.continueLabel,
  });

  @override
  Widget build(BuildContext context) {
    // Read from passed settings or fallback to SettingsBloc or defaults
    BillingSettings? blocSettings;
    try {
      blocSettings = context.read<SettingsBloc>().state.settings;
    } catch (_) {
      blocSettings = null;
    }

    final activeSettings =
        settings ?? blocSettings ?? BillingSettings(updatedAt: DateTime.now());

    final vehicleNo = vehicle?.vehicleNumber ?? '—';
    String vehicleTypeName = '—';
    if (vehicle != null) {
      try {
        vehicleTypeName = vehicleTypes
            .firstWhere((vt) => vt.id == vehicle!.vehicleTypeId)
            .name;
      } catch (_) {}
    }
    final partyName = party?.name ?? '—';
    final partyPhone = party?.mobile ?? '';
    final dateFormatted = DateFormat('dd/MM/yyyy').format(bill.createdAt);
    final timeFormatted = DateFormat('hh:mm:ss a').format(bill.createdAt);
    final printDate = DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());
    final isCompleted = bill.status.toLowerCase() == 'completed' || bill.isCompleted;
    final isGrossPending =
        !isCompleted && (bill.firstWeightType.toUpperCase() == 'TARE');

    // Check if any basic info rows are enabled
    final hasSerial = activeSettings.showSerialNumber;
    final hasDate = activeSettings.showDate;
    final hasTime = activeSettings.showTime;
    final hasGeneralInfo = hasSerial || hasDate || hasTime;

    // Check if any vehicle/party rows are enabled
    final hasVehNo = activeSettings.showVehicleNumber;
    final hasMat = activeSettings.showMaterial;
    final hasParty = activeSettings.showParty;
    final hasVehType = activeSettings.showVehicleType;
    final hasDetails = hasVehNo || hasMat || hasParty || hasVehType;

    // Check weight rows
    final hasGross = activeSettings.showGrossWeight;
    final hasTare = activeSettings.showTareWeight;
    final hasNet = activeSettings.showNetWeight;
    final hasWeights = hasGross || hasTare || hasNet;

    // Check financial rows
    final hasAmount = activeSettings.showAmount;
    final hasPayment = activeSettings.showPaymentMode;
    final hasCash = activeSettings.showCashReceived;
    final hasPending = activeSettings.showPendingAmount;
    final hasFinancials = hasAmount || hasPayment || hasCash || hasPending;

    final hasRemarks =
        activeSettings.showRemarks &&
        bill.remarks != null &&
        bill.remarks!.trim().isNotEmpty;
    final hasFooter = activeSettings.showFooterNote;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: SizedBox(
        width: onContinue != null ? 360 : 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SingleChildScrollView(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: const Color(0xFFCBD5E1),
                      width: 0.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(activeSettings),
                      const SizedBox(height: 8),
                      _buildDivider(),
                      const SizedBox(height: 6),
                      _buildTitle(
                        activeSettings,
                        isCompleted: isCompleted,
                        isGrossPending: isGrossPending,
                      ),
                      const SizedBox(height: 8),

                      if (hasGeneralInfo) ...[
                        _buildDivider(),
                        const SizedBox(height: 6),
                        if (hasSerial)
                          _buildInfoRow('Bill No.', bill.billNumber),
                        if (hasDate) _buildInfoRow('Date', dateFormatted),
                        if (hasTime) _buildInfoRow('Time', timeFormatted),
                        const SizedBox(height: 6),
                      ],

                      if (hasDetails) ...[
                        _buildDivider(),
                        const SizedBox(height: 6),
                        if (hasVehNo) _buildInfoRow('Vehicle No.', vehicleNo),
                        if (hasMat) _buildInfoRow('Material', materialName),
                        if (hasParty) ...[
                          _buildInfoRow('Party', partyName),
                          if (partyPhone.isNotEmpty)
                            _buildInfoRow('Party Mobile', partyPhone),
                        ],
                        if (hasVehType)
                          _buildInfoRow('Vehicle Type', vehicleTypeName),
                        const SizedBox(height: 6),
                      ],

                      if (hasWeights) ...[
                        _buildDivider(),
                        const SizedBox(height: 6),
                        Builder(
                          builder: (context) {
                            final unit = bill.weightUnit;
                            final decimals = unit == 'kg' ? 0 : 3;
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isCompleted) ...[
                                  if (hasGross)
                                    _buildWeightRow(
                                      'Gross Weight',
                                      '${bill.grossWeightKg?.toStringAsFixed(decimals) ?? '—'} $unit',
                                    ),
                                  if (hasTare)
                                    _buildWeightRow(
                                      'Tare Weight',
                                      '${bill.tareWeightKg?.toStringAsFixed(decimals) ?? '—'} $unit',
                                    ),
                                  if (hasGross || hasTare) const SizedBox(height: 4),
                                  if (hasNet) ...[
                                    _buildDivider(),
                                    const SizedBox(height: 4),
                                    _buildWeightRow(
                                      'Net Weight',
                                      '${(bill.netWeightKg ?? 0).toStringAsFixed(decimals)} $unit',
                                    ),
                                  ],
                                ] else if (isGrossPending) ...[
                                  if (hasGross)
                                    _buildWeightRow('Gross Weight', 'PENDING'),
                                  if (hasTare)
                                    _buildWeightRow(
                                      'Tare Weight',
                                      '${(bill.tareWeightKg ?? bill.firstWeightKg).toStringAsFixed(decimals)} $unit',
                                    ),
                                  if (hasGross || hasTare) const SizedBox(height: 4),
                                  if (hasNet) ...[
                                    _buildDivider(),
                                    const SizedBox(height: 4),
                                    _buildWeightRow('Net Weight', '—'),
                                  ],
                                ] else ...[
                                  if (hasGross)
                                    _buildWeightRow(
                                      'Gross Weight',
                                      '${(bill.grossWeightKg ?? bill.firstWeightKg).toStringAsFixed(decimals)} $unit',
                                    ),
                                  if (hasTare)
                                    _buildWeightRow('Tare Weight', 'PENDING'),
                                  if (hasGross || hasTare) const SizedBox(height: 4),
                                  if (hasNet) ...[
                                    _buildDivider(),
                                    const SizedBox(height: 4),
                                    _buildWeightRow('Net Weight', '—'),
                                  ],
                                ],
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 6),
                      ],

                      if (hasFinancials) ...[
                        _buildDivider(),
                        const SizedBox(height: 6),
                        if (hasAmount)
                          _buildInfoRow(
                            'Amount',
                            'Rs. ${bill.amount.toStringAsFixed(2)}',
                          ),
                        if (hasPayment)
                          _buildInfoRow(
                            'Payment',
                            bill.paymentMode.toUpperCase(),
                          ),
                        if (hasCash)
                          _buildInfoRow(
                            'Cash Received',
                            'Rs. ${bill.amount.toStringAsFixed(2)}',
                          ),
                        if (hasPending) _buildInfoRow('Pending', 'Rs. 0.00'),
                      ],

                      if (!isCompleted) ...[
                        const SizedBox(height: 6),
                        _buildStatusBadge(isGrossPending: isGrossPending),
                      ],

                      if (hasRemarks) ...[
                        const SizedBox(height: 6),
                        _buildDivider(),
                        const SizedBox(height: 6),
                        _buildRemarks(bill.remarks!),
                      ],

                      if (hasFooter) ...[
                        const SizedBox(height: 8),
                        _buildDivider(),
                        const SizedBox(height: 6),
                        _buildFooterNote(
                          activeSettings,
                          isCompleted: isCompleted,
                          isGrossPending: isGrossPending,
                        ),
                      ],

                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          '* $printDate *',
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
            ),
            const SizedBox(height: 12),
            _buildActions(context, isGrossPending: isGrossPending),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BillingSettings settings) {
    final hasLogo =
        settings.logoPath != null &&
        settings.logoPath!.trim().isNotEmpty &&
        File(settings.logoPath!).existsSync();

    return Column(
      children: [
        if (hasLogo)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Image.file(
              File(settings.logoPath!),
              height: 36,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => _buildDefaultLogo(),
            ),
          )
        else
          _buildDefaultLogo(),
        const SizedBox(height: 4),
        Text(
          settings.businessName.isNotEmpty
              ? settings.businessName
              : 'VIYAN WEIGHBRIDGE',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
            letterSpacing: 1.2,
          ),
        ),
        if (settings.businessSubtitle != null &&
            settings.businessSubtitle!.trim().isNotEmpty) ...[
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
            settings.serviceText!.trim().isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            settings.serviceText!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 8,
              fontWeight: FontWeight.w800,
              color: Color(0xFF475569),
              letterSpacing: 0.6,
            ),
          ),
        ],
        if (settings.address != null &&
            settings.address!.trim().isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            settings.address!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 8,
              color: Color(0xFF64748B),
            ),
          ),
        ],
        if ((settings.phoneNumber != null &&
                settings.phoneNumber!.trim().isNotEmpty) ||
            (settings.gstin != null && settings.gstin!.trim().isNotEmpty)) ...[
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (settings.phoneNumber != null &&
                  settings.phoneNumber!.trim().isNotEmpty)
                Text(
                  'Ph: ${settings.phoneNumber!}',
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 7.5,
                    color: Color(0xFF64748B),
                  ),
                ),
              if (settings.phoneNumber != null &&
                  settings.phoneNumber!.trim().isNotEmpty &&
                  settings.gstin != null &&
                  settings.gstin!.trim().isNotEmpty)
                const Text(
                  ' · ',
                  style: TextStyle(fontSize: 8, color: Color(0xFF94A3B8)),
                ),
              if (settings.gstin != null && settings.gstin!.trim().isNotEmpty)
                Text(
                  'GSTIN: ${settings.gstin!}',
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 7.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildDefaultLogo() {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF38BDF8), width: 1),
      ),
      child: const Icon(Icons.scale_rounded, color: Colors.white, size: 16),
    );
  }

  Widget _buildTitle(
    BillingSettings settings, {
    required bool isCompleted,
    required bool isGrossPending,
  }) {
    final title = settings.receiptTitle.isNotEmpty
        ? settings.receiptTitle
        : 'WEIGHMENT RECEIPT';
    final String displayTitle;
    if (isCompleted) {
      displayTitle = title;
    } else if (isGrossPending) {
      displayTitle = '$title — GROSS WEIGHT PENDING';
    } else {
      displayTitle = '$title — TARE WEIGHT PENDING';
    }

    return Center(
      child: Text(
        displayTitle,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: isCompleted ? 12 : 10,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF0F172A),
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: List.generate(
        40,
        (i) => Expanded(
          child: Container(
            height: 1,
            color: i.isEven ? const Color(0xFF64748B) : Colors.transparent,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightRow(String label, String value) {
    final isPending = value == 'PENDING';
    final isDash = value == '—';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: isPending ? 10 : 11,
                fontWeight: FontWeight.w800,
                color: isPending
                    ? const Color(0xFFD97706)
                    : isDash
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF0F172A),
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge({required bool isGrossPending}) {
    final text = isGrossPending
        ? 'PENDING • GROSS WT'
        : 'PENDING • TARE WT';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.radio_button_checked_rounded,
            size: 12,
            color: Color(0xFFD97706),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFFD97706),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemarks(String remarks) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Note: ',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: Color(0xFF475569),
          ),
        ),
        Expanded(
          child: Text(
            remarks,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooterNote(
    BillingSettings settings, {
    required bool isCompleted,
    required bool isGrossPending,
  }) {
    final customNote = settings.footerNote?.trim();
    final String noteText;
    if (isCompleted) {
      noteText = (customNote != null && customNote.isNotEmpty)
          ? customNote
          : 'Please check the weight before leaving the weighbridge.';
    } else {
      noteText = isGrossPending
          ? 'Gross weight is pending.\nPlease return to the weighbridge for gross weighing.'
          : 'Tare weight is pending.\nPlease return to the weighbridge for tare weighing.';
    }

    return Text(
      'Note: $noteText',
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 8,
        fontWeight: FontWeight.w500,
        color: Color(0xFF94A3B8),
        height: 1.3,
      ),
    );
  }

  Widget _buildActions(BuildContext context, {required bool isGrossPending}) {
    final actionLabel =
        continueLabel ?? (isGrossPending ? 'Gross Weight' : 'Tare Weight');

    if (onContinue != null) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF334155),
                side: const BorderSide(color: Color(0xFFCBD5E1)),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text(
                'Close',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Print job sent for ${bill.billNumber}'),
                    backgroundColor: const Color(0xFF16A34A),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.print_rounded, size: 14),
              label: const Text(
                'Print Ticket',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0F52BA),
                side: const BorderSide(color: Color(0xFF93C5FD)),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: FilledButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                onContinue!();
              },
              icon: const Icon(Icons.arrow_forward_rounded, size: 13),
              label: Text(
                actionLabel,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFD97706),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 4,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                elevation: 1,
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF334155),
              side: const BorderSide(color: Color(0xFFCBD5E1)),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text(
              'Close',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Print job sent for ${bill.billNumber}'),
                  backgroundColor: const Color(0xFF16A34A),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.print_rounded, size: 16),
            label: const Text(
              'Print Ticket',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D3B82),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              elevation: 2,
            ),
          ),
        ),
      ],
    );
  }
}
