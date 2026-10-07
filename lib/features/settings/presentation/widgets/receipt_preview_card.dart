import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../features/bill/domain/entities/weighment.dart';
import '../../../../features/bill/domain/services/weighment_receipt_data.dart';
import '../../../../features/bill/presentation/widgets/weighment_receipt_template.dart';
import '../../../../features/customer/domain/entities/customer.dart';
import '../../../../features/settings/domain/entities/billing_settings.dart';

/// A card wrapper that displays the live receipt preview.
///
/// The preview renders [WeighmentReceiptTemplate] from a [WeighmentReceiptData]
/// built out of the most recent weighment, which is exactly what the ticket
/// dialog and the printed PDF render. There is no second receipt layout here,
/// so a template change reaches the preview, the slip and the printout
/// together.
class ReceiptPreviewCard extends StatelessWidget {
  const ReceiptPreviewCard({
    super.key,
    required this.settings,
    required this.showSerialNumber,
    required this.showVehicleNumber,
    required this.showMaterial,
    required this.showCustomer,
    required this.showGrossWeight,
    required this.showTareWeight,
    required this.showNetWeight,
    required this.showAmount,
    required this.showPaymentMode,
    required this.showRemarks,
    required this.showFooterNote,
    required this.latestWeighment,
    required this.customer,
    required this.materialName,
    required this.isLoadingWeighment,
  });

  final BillingSettings settings;

  final bool showSerialNumber;
  final bool showVehicleNumber;
  final bool showMaterial;
  final bool showCustomer;
  final bool showGrossWeight;
  final bool showTareWeight;
  final bool showNetWeight;
  final bool showAmount;
  final bool showPaymentMode;
  final bool showRemarks;
  final bool showFooterNote;
  final Weighment? latestWeighment;
  final Customer? customer;
  final String? materialName;
  final bool isLoadingWeighment;

  static final Weighment _sampleBill = Weighment(
    id: 0,
    billNumber: 'WB-00037',
    customerId: 0,
    vehicleNumber: 'TN56VD5677',
    paymentMode: 'Cash',
    firstWeightKg: 200000,
    firstWeightType: 'GROSS',
    secondWeightKg: 10000,
    secondWeightType: 'TARE',
    netWeightKg: 190000,
    vehicleCharge: 0.0,
    amount: 90.0,
    remarks: '',
    createdAt: DateTime(2026, 10, 7, 19, 40),
    updatedAt: DateTime(2026, 10, 7, 19, 40),
  );

  static final Customer _sampleCustomer = Customer(
    id: 0,
    name: 'Viyaninfo',
    mobile: '6381812437',
    isActive: true,
    createdAt: DateTime(2026, 10, 7),
    updatedAt: DateTime(2026, 10, 7),
  );

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
                                  ? 'Showing sample weighment (reflects template changes in real time)'
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
          // The Authentic Bill Canvas - matching Weighment Slip Dialog
          Container(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(14)),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                const standardSlipWidth = 640.0;
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: standardSlipWidth,
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: standardSlipWidth,
                        child: _buildSlip(hasLogo),
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

  Widget _buildSlip(bool hasLogo) {
    final bill = latestWeighment ?? _sampleBill;
    final activeCustomer =
        customer ?? (latestWeighment == null ? _sampleCustomer : null);
    final activeMaterialName =
        (materialName != null && materialName!.isNotEmpty)
            ? materialName!
            : (latestWeighment == null ? 'Sand' : '');

    final receiptData = WeighmentReceiptData(
      bill: bill,
      customer: activeCustomer,
      materialName: activeMaterialName,
      settings: settings,
      forPreview: true,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasLogo)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Center(
                child: Image.file(
                  File(settings.logoPath!),
                  height: 44,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
            ),
          WeighmentReceiptTemplate(
            data: receiptData,
          ),
        ],
      ),
    );
  }
}
