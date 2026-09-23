import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../features/bill/domain/entities/weighment.dart';
import '../../../../features/settings/domain/entities/billing_settings.dart';
import 'dashed_divider.dart';

class ReceiptPreview extends StatelessWidget {
  const ReceiptPreview({
    super.key,
    required this.settings,
    required this.billPreview,
    required this.dateFormatted,
    required this.timeFormatted,
    required this.timestamp,
    required this.hasLogo,
    required this.weightUnit,
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
    required this.latestWeighment,
    required this.customerName,
    required this.materialName,
  });

  final BillingSettings settings;
  final String billPreview;
  final String dateFormatted;
  final String timeFormatted;
  final String timestamp;
  final bool hasLogo;
  final String weightUnit;
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
  final Weighment? latestWeighment;
  final String? customerName;
  final String? materialName;

  @override
  Widget build(BuildContext context) {
    return Column(
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
        if (settings.address != null && settings.address!.isNotEmpty) ...[
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
        if (settings.gstin != null && settings.gstin!.isNotEmpty) ...[
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
        const DashedDivider(),
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
        if (showSerialNumber || showDate || showTime) ...[
          const DashedDivider(),
          const SizedBox(height: 4),
          if (showSerialNumber) _buildReceiptRow('SL.NO.', billPreview),
          if (showDate) _buildReceiptRow('Date', dateFormatted),
          if (showTime) _buildReceiptRow('Time', timeFormatted),
          const SizedBox(height: 4),
        ],

        if (showVehicleNumber || showMaterial || showCustomer) ...[
          const DashedDivider(),
          const SizedBox(height: 4),
          if (showVehicleNumber)
            _buildReceiptRow(
              'Vehicle No.',
              latestWeighment?.vehicleNumber ?? '',
            ),
          if (showMaterial) _buildReceiptRow('Material', materialName ?? ''),
          if (showCustomer) _buildReceiptRow('Customer', customerName ?? ''),
          const SizedBox(height: 4),
        ],

        if (showGrossWeight || showTareWeight || showNetWeight) ...[
          const DashedDivider(),
          const SizedBox(height: 4),
          if (showGrossWeight)
            _buildReceiptWeightRow(
              'Gross Weight',
              _formatWeight(latestWeighment?.grossWeightKg),
            ),
          if (showTareWeight)
            _buildReceiptWeightRow(
              'Tare Weight',
              _formatWeight(latestWeighment?.tareWeightKg),
            ),
          if (showNetWeight) ...[
            const SizedBox(height: 2),
            const DashedDivider(),
            const SizedBox(height: 2),
            _buildReceiptWeightRow(
              'Net Weight',
              _formatWeight(latestWeighment?.netWeightKg),
              isBold: true,
            ),
          ],
          const SizedBox(height: 4),
        ],

        if (showAmount || showPaymentMode || showCashReceived) ...[
          const DashedDivider(),
          const SizedBox(height: 4),
          if (showAmount)
            _buildReceiptRow(
              'Amount',
              'Rs. ${_formatAmount(latestWeighment?.amount)}',
            ),
          if (showPaymentMode)
            _buildReceiptRow(
              'Payment',
              latestWeighment?.paymentMode.toUpperCase() ?? '',
            ),
          if (showCashReceived)
            _buildReceiptRow(
              'Cash Received',
              'Rs. ${_formatAmount(latestWeighment?.amount)}',
            ),
          const SizedBox(height: 4),
        ],

        if (showRemarks) ...[
          const DashedDivider(),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
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
                  latestWeighment?.remarks ?? '',
                  style: const TextStyle(
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

        if (showFooterNote &&
            settings.footerNote != null &&
            settings.footerNote!.isNotEmpty) ...[
          const DashedDivider(),
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
    );
  }

  String _formatWeight(double? weightKg) {
    if (weightKg == null || weightKg <= 0) return '';
    if (weightUnit == 'kg') {
      return '${NumberFormat('#,##0').format(weightKg)} kg';
    }
    return '${NumberFormat('#,##0.000').format(weightKg / 1000)} ton';
  }

  String _formatAmount(double? amount) {
    if (amount == null) return '0.00';
    return amount.toStringAsFixed(2);
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
}
