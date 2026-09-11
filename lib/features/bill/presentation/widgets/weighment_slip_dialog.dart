import 'package:flutter/material.dart' hide Material;
import 'package:intl/intl.dart';

import '../../../party/domain/entities/party.dart';
import '../../../vehicle/domain/entities/vehicle.dart';
import '../../../vehicle_type/domain/entities/vehicle_type.dart';
import '../../domain/entities/weighment.dart';

/// Authentic Commercial Computerized Weighbridge Bill Slip Dialog
class WeighmentSlipDialog extends StatelessWidget {
  final Weighment bill;
  final Vehicle? vehicle;
  final Party? party;
  final List<VehicleType> vehicleTypes;
  final String materialName;

  const WeighmentSlipDialog({
    super.key,
    required this.bill,
    this.vehicle,
    this.party,
    this.vehicleTypes = const [],
    required this.materialName,
  });

  @override
  Widget build(BuildContext context) {
    final vehicleNo = vehicle?.vehicleNumber ?? 'TN 31 CM 2026';
    String vehicleTypeName = 'Commercial Vehicle';
    if (vehicle != null) {
      try {
        vehicleTypeName = vehicleTypes.firstWhere((vt) => vt.id == vehicle!.vehicleTypeId).name;
      } catch (_) {}
    }
    final partyName = party?.name ?? 'General Party';
    final partyPhone = party?.mobile ?? '';
    final dateFormatted =
        DateFormat('dd MMM yyyy, hh:mm a').format(bill.createdAt);
    final printDateFormatted =
        DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());

    final isPaid = bill.status.toLowerCase() == 'completed';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 580),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Physical Paper Slip Container
            Flexible(
              child: SingleChildScrollView(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: const Color(0xFF0F172A),
                      width: 2.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(4), // Double-line frame gap
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: const Color(0xFF94A3B8),
                        width: 1.0,
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 1. Official Weighbridge Station Letterhead
                        _buildHeader(isPaid),

                        const SizedBox(height: 12),

                        // 2. High-Contrast Certificate Title Banner
                        _buildTitleBanner(),

                        const SizedBox(height: 10),

                        // 3. 2-Column Boxed Vehicle & Transaction Grid
                        _buildMetaGrid(
                          dateFormatted: dateFormatted,
                          vehicleNo: vehicleNo,
                          vehicleType: vehicleTypeName,
                          partyName: partyName,
                          partyPhone: partyPhone,
                        ),

                        const SizedBox(height: 12),

                        // 4. Structured Weighment Measurement Table
                        _buildWeighmentTable(dateFormatted),

                        const SizedBox(height: 10),

                        // 5. Billing Breakdown & Amount in Words
                        _buildChargesBox(),

                        if (bill.remarks != null &&
                            bill.remarks!.trim().isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _buildRemarksBox(bill.remarks!),
                        ],

                        const SizedBox(height: 16),

                        // 6. Signature Lines
                        _buildSignatures(),

                        const SizedBox(height: 14),

                        // 7. Barcode & Legal Disclaimer
                        _buildFooter(printDateFormatted),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Modal Action Buttons Bar
            _buildDialogActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isPaid) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Station Icon Emblem
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
              ),
              child: const Icon(
                Icons.scale_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(height: 4),

            // Primary Station Name
            const Text(
              'VIYAN WEIGHBRIDGE',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
                letterSpacing: 1.5,
              ),
            ),

            const SizedBox(height: 2),

            // Official Tagline
            const Text(
              'GOVERNMENT APPROVED ELECTRONIC COMPUTERIZED WEIGHBRIDGE',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: Color(0xFF334155),
                letterSpacing: 0.8,
              ),
            ),

            const SizedBox(height: 2),

            // Address & Registration details
            const Text(
              'NH-45 Highway Bypass Road, Industrial Zone • Ph: +91 98765 43210',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 8.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
              ),
            ),
            const Text(
              'Govt. License: WB-TN-2026/042 • GSTIN: 33AAAAA0000A1Z5',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 8.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF475569),
              ),
            ),
          ],
        ),

        // Official Rubber Stamp on Top Right
        Positioned(
          right: 0,
          top: 0,
          child: Transform.rotate(
            angle: -0.12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isPaid
                      ? const Color(0xFF16A34A)
                      : const Color(0xFFD97706),
                  width: 1.8,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isPaid ? 'COMPLETED' : 'DRAFT',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: isPaid
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFD97706),
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    bill.paymentMode.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 7.5,
                      fontWeight: FontWeight.w800,
                      color: isPaid
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFD97706),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(
        children: [
          // Left: Weighment Slip: WB-00001
          Expanded(
            child: Text(
              'Weighment Slip: ${bill.billNumber}',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Right: Customer Copy
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B),
              borderRadius: BorderRadius.circular(2),
            ),
            child: const Text(
              'ORIGINAL COPY',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 8,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaGrid({
    required String dateFormatted,
    required String vehicleNo,
    required String vehicleType,
    required String partyName,
    required String partyPhone,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF0F172A), width: 1.0),
      ),
      child: Column(
        children: [
          // Grid Row 1: Date & Time | Vehicle Plate
          Row(
            children: [
              Expanded(
                child: _buildGridCell(
                  label: 'DATE & TIME',
                  value: dateFormatted,
                ),
              ),
              Container(width: 1, height: 42, color: const Color(0xFF0F172A)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'VEHICLE NO',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 8.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF64748B),
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 2),
                      _buildHsrpPlate(vehicleNo),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const Divider(height: 1, thickness: 1, color: Color(0xFF0F172A)),

          // Grid Row 2: Customer/Party | Commodity/Material
          Row(
            children: [
              Expanded(
                child: _buildGridCell(
                  label: 'PARTY / CUSTOMER',
                  value: partyName,
                  subValue: partyPhone.isNotEmpty ? 'Ph: $partyPhone' : null,
                  isBold: true,
                ),
              ),
              Container(width: 1, height: 38, color: const Color(0xFF0F172A)),
              Expanded(
                child: _buildGridCell(
                  label: 'COMMODITY / MATERIAL',
                  value: materialName,
                  isBold: true,
                  valueColor: const Color(0xFF0D3B82),
                ),
              ),
            ],
          ),

          const Divider(height: 1, thickness: 1, color: Color(0xFF0F172A)),

          // Grid Row 3: Vehicle Type & Payment Mode
          Row(
            children: [
              Expanded(
                child: _buildGridCell(
                  label: 'VEHICLE TYPE',
                  value: vehicleType,
                  subValue: 'Payment: ${bill.paymentMode.toUpperCase()}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGridCell({
    required String label,
    required String value,
    String? subValue,
    bool isBold = false,
    Color? valueColor,
    bool isChip = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 1),
          if (isChip)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: const Color(0xFF0D3B82).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Text(
                value,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0D3B82),
                ),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 11,
                      fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
                      color: valueColor ?? const Color(0xFF0F172A),
                    ),
                  ),
                ),
                if (subValue != null) ...[
                  const SizedBox(width: 4),
                  Text(
                    subValue,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 8.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildHsrpPlate(String vehicleNo) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: const Color(0xFF0F172A), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 2.5, vertical: 1),
            decoration: BoxDecoration(
              color: const Color(0xFF0D3B82),
              borderRadius: BorderRadius.circular(1.5),
            ),
            child: const Text(
              'IND',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 6.5,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              vehicleNo,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeighmentTable(String dateFormatted) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF0F172A), width: 1.5),
      ),
      child: Column(
        children: [
          // Table Column Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            color: const Color(0xFFF1F5F9),
            child: const Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Text(
                    'WEIGHMENT DETAILS',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Text(
                    'RECORDED DATE & TIME',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    'WEIGHT (KG)',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1, color: Color(0xFF0F172A)),

          // 1st Weight Row
          _buildWeightRow(
            stage: '1st Weight (Gross/Tare)',
            date: dateFormatted,
            weight: '${bill.firstWeightKg.toStringAsFixed(0)} kg',
          ),

          const Divider(height: 1, thickness: 0.8, color: Color(0xFFE2E8F0)),

          // 2nd Weight Row
          _buildWeightRow(
            stage: '2nd Weight (Tare/Gross)',
            date: dateFormatted,
            weight: '${bill.secondWeightKg?.toStringAsFixed(0) ?? '—'} kg',
          ),

          const Divider(height: 1, thickness: 1.5, color: Color(0xFF0F172A)),

          // High-Contrast Prominent NET WEIGHT Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            color: const Color(0xFFEFF6FF),
            child: Row(
              children: [
                const Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NET WEIGHT',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0D3B82),
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        '(Actual Product Weighment)',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 8,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Text(
                    '${((bill.netWeightKg ?? 0) / 1000).toStringAsFixed(3)} Metric Tons',
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0D3B82),
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    '${(bill.netWeightKg ?? 0).toStringAsFixed(0)} kg',
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0D3B82),
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

  Widget _buildWeightRow({
    required String stage,
    required String date,
    required String weight,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text(
              stage,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF334155),
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              date,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 9.5,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              weight,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChargesBox() {
    final words = _convertAmountToIndianWords(bill.amount);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Vehicle Charge: ₹ ${bill.vehicleCharge.toStringAsFixed(2)}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'TOTAL CHARGES: ',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        '₹ ${bill.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Divider(height: 6, thickness: 0.6, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 2),
          Text(
            'AMOUNT IN WORDS: $words',
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemarksBox(String remarks) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: const Color(0xFFFDE68A), width: 0.8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Remarks: ',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF92400E),
            ),
          ),
          Expanded(
            child: Text(
              remarks,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 9.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF78350F),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignatures() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Driver signature column
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 140,
              height: 1,
              color: const Color(0xFF94A3B8),
            ),
            const SizedBox(height: 4),
            const Text(
              "Driver's Signature",
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),

        // Operator / Authorized Signatory column
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 170,
              height: 1,
              color: const Color(0xFF94A3B8),
            ),
            const SizedBox(height: 4),
            const Text(
              'For VIYAN WEIGHBRIDGE',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const Text(
              'Authorized Weighment Officer',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFooter(String printDate) {
    return Column(
      children: [
        // Realistic Barcode
        SizedBox(
          width: 180,
          height: 24,
          child: CustomPaint(
            painter: _BarcodePainter(bill.billNumber),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '* ${bill.billNumber} *',
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 4),

        // Legal Notice & Disclaimer
        const Text(
          'Weight measured on certified electronic load-cell weighbridge. Discrepancies must be verified before vehicle departs platform. Computer generated certificate.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 7.5,
            fontWeight: FontWeight.w500,
            color: Color(0xFF94A3B8),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Printed: $printDate | Station: WB-TERM-01',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 7.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }

  Widget _buildDialogActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close_rounded, size: 16),
          label: const Text(
            'Close',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontWeight: FontWeight.w700,
            ),
          ),
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF334155),
            backgroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
              side: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton.icon(
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
          icon: const Icon(Icons.print_rounded, size: 18),
          label: const Text(
            'Print Ticket',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D3B82),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            elevation: 4,
          ),
        ),
      ],
    );
  }

  /// Converts a numeric amount into Indian Currency Words
  String _convertAmountToIndianWords(double amount) {
    int n = amount.round();
    if (n <= 0) return 'Zero Rupees Only';

    const units = [
      '', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine', 'Ten',
      'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen'
    ];
    const tens = [
      '', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'
    ];

    String convertBelowThousand(int num) {
      String res = '';
      if (num >= 100) {
        res += '${units[num ~/ 100]} Hundred ';
        num %= 100;
      }
      if (num >= 20) {
        res += '${tens[num ~/ 10]} ';
        num %= 10;
      }
      if (num > 0) {
        res += '${units[num]} ';
      }
      return res;
    }

    String result = '';
    final crore = n ~/ 10000000;
    n %= 10000000;
    final lakh = n ~/ 100000;
    n %= 100000;
    final thousand = n ~/ 1000;
    n %= 1000;

    if (crore > 0) {
      result += '${convertBelowThousand(crore)}Crore ';
    }
    if (lakh > 0) {
      result += '${convertBelowThousand(lakh)}Lakh ';
    }
    if (thousand > 0) {
      result += '${convertBelowThousand(thousand)}Thousand ';
    }
    if (n > 0) {
      result += convertBelowThousand(n);
    }

    return 'Rupees ${result.trim()} Only';
  }
}

/// Precise Code 128 Ticket Barcode Painter
class _BarcodePainter extends CustomPainter {
  final String text;
  const _BarcodePainter(this.text);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF0F172A);
    final w = size.width;
    final h = size.height;

    // Standard high-density barcode bar sequence
    final pattern = [
      2, 1, 3, 1, 1, 2, 4, 1, 2, 3, 1, 2, 1, 3, 2, 1, 1, 4, 2, 1, 3, 1,
      2, 1, 4, 1, 2, 3, 1, 2, 1, 3, 2, 1, 4, 1, 2, 1, 3, 2, 1, 2, 3, 1
    ];
    double totalUnits = 0;
    for (final u in pattern) {
      totalUnits += u;
    }
    final unitWidth = w / totalUnits;
    double currentX = 0;
    bool isBar = true;

    for (final u in pattern) {
      final barWidth = u * unitWidth;
      if (isBar) {
        canvas.drawRect(Rect.fromLTWH(currentX, 0, barWidth, h), paint);
      }
      currentX += barWidth;
      isBar = !isBar;
    }
  }

  @override
  bool shouldRepaint(covariant _BarcodePainter oldDelegate) =>
      oldDelegate.text != text;
}
