import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../features/bill/domain/entities/weighment.dart';
import '../../../../features/settings/domain/entities/billing_settings.dart';
import 'receipt_preview.dart';

/// A card wrapper that displays the live receipt preview.
/// Extracted from settings_page.dart to separate the preview container
/// from the preview content.
class ReceiptPreviewCard extends StatelessWidget {
  const ReceiptPreviewCard({
    super.key,
    required this.settings,
    required this.billPreview,
    required this.dateFormatted,
    required this.timeFormatted,
    required this.timestamp,
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
    required this.isLoadingWeighment,
  });

  final BillingSettings settings;
  final String billPreview;
  final String dateFormatted;
  final String timeFormatted;
  final String timestamp;
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
  final bool isLoadingWeighment;

  @override
  Widget build(BuildContext context) {
    final hasLogo =
        settings.logoPath != null &&
        settings.logoPath!.trim().isNotEmpty &&
        File(settings.logoPath!).existsSync();

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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Live Receipt Preview',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        isLoadingWeighment
                            ? 'Loading recent weighment data...'
                            : (latestWeighment == null
                                ? 'No recent weighment data available'
                                : 'Reflects template changes in real time'),
                        softWrap: true,
                        style: const TextStyle(
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
                      child: ReceiptPreview(
                        settings: settings,
                        billPreview: billPreview,
                        dateFormatted: dateFormatted,
                        timeFormatted: timeFormatted,
                        timestamp: timestamp,
                        hasLogo: hasLogo,
                        weightUnit: weightUnit,
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
                        latestWeighment: latestWeighment,
                        customerName: customerName,
                        materialName: materialName,
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
}
