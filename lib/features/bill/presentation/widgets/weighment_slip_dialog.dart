import 'package:flutter/material.dart' hide Material;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:weighbridge/app/app.dart' show showAppSnackBar;
import '../../../customer/domain/entities/customer.dart';
import '../../../settings/domain/entities/billing_settings.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../../../core/printing/print_service.dart';
import '../../domain/entities/weighment.dart';
import '../../domain/services/receipt_weight_resolver.dart';
import '../../domain/services/weighment_ticket_pdf_generator.dart';

/// Authentic on-screen preview dialog for the industrial dot-matrix weighbridge slip.
class WeighmentSlipDialog extends StatefulWidget {
  final Weighment bill;
  final Customer? customer;
  final String materialName;
  final BillingSettings? settings;
  final PrintService printService;

  const WeighmentSlipDialog({
    super.key,
    required this.bill,
    this.customer,
    required this.materialName,
    this.settings,
    this.printService = const PrintService(),
  });

  @override
  State<WeighmentSlipDialog> createState() => _WeighmentSlipDialogState();
}

class _WeighmentSlipDialogState extends State<WeighmentSlipDialog> {
  bool _isPrinting = false;

  BillingSettings _resolveActiveSettings() {
    BillingSettings? blocSettings;
    try {
      blocSettings = context.read<SettingsBloc>().state.settings;
    } catch (_) {
      blocSettings = null;
    }
    return widget.settings ??
        blocSettings ??
        BillingSettings(updatedAt: DateTime.now());
  }

  Future<void> _handlePrint() async {
    if (_isPrinting) return;
    setState(() => _isPrinting = true);
    try {
      final pdfBytes = await const WeighmentTicketPdfGenerator()
          .generateTicketPdf(
            bill: widget.bill,
            customer: widget.customer,
            materialName: widget.materialName,
            settings: _resolveActiveSettings(),
          );
      final printed = await widget.printService.printPdf(
        pdfBytes,
        jobName: 'Weighment_Ticket_${widget.bill.billNumber}',
      );
      if (!mounted) return;
      if (printed) {
        Navigator.of(context).pop();
        showAppSnackBar(
          'Print job sent for ${widget.bill.billNumber}',
          backgroundColor: const Color(0xFF16A34A),
        );
      } else {
        showAppSnackBar(
          'Unable to print ticket for ${widget.bill.billNumber}',
          backgroundColor: const Color(0xFFDC2626),
        );
      }
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(
        'Failed to print ticket: $e',
        backgroundColor: const Color(0xFFDC2626),
      );
    } finally {
      if (mounted) {
        setState(() => _isPrinting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeSettings = _resolveActiveSettings();
    final bill = widget.bill;
    final weights = const ReceiptWeightResolver().resolve(bill);

    final vehicleNo = bill.vehicleNumber.isEmpty ? '--' : bill.vehicleNumber;
    final customerName = widget.customer?.name ?? '--';
    final customerPhone = widget.customer?.mobile ?? '';
    final materialName = widget.materialName.isEmpty
        ? '--'
        : widget.materialName;
    final printDate = DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());
    final isCompleted = bill.isCompleted;

    final hasSerial = activeSettings.showSerialNumber;
    final hasVehNo = activeSettings.showVehicleNumber;
    final hasMat = activeSettings.showMaterial;
    final hasCustomer = activeSettings.showCustomer;

    final hasGross =
        isCompleted ||
        activeSettings.showGrossWeight ||
        (weights.grossKg != null && weights.grossKg! > 0);
    final hasTare =
        isCompleted ||
        activeSettings.showTareWeight ||
        (weights.tareKg != null && weights.tareKg! > 0);
    final hasNet =
        isCompleted ||
        activeSettings.showNetWeight ||
        (weights.netKg != null && weights.netKg! > 0);

    final hasAmount =
        isCompleted || activeSettings.showAmount || bill.amount > 0;
    final hasPayment = activeSettings.showPaymentMode;

    final hasRemarks =
        activeSettings.showRemarks &&
        bill.remarks != null &&
        bill.remarks!.trim().isNotEmpty;
    final hasFooter = activeSettings.showFooterNote;
    final customFooter = activeSettings.footerNote?.trim();
    final footerNoteText = (customFooter != null && customFooter.isNotEmpty)
        ? customFooter
        : 'Please check the weight before leaving the weighbridge.';

    final isTon =
        activeSettings.weightUnit.toLowerCase() == 'ton' ||
        activeSettings.weightUnit.toLowerCase() == 'tonne';
    final unit = isTon ? 'ton' : 'kg';
    final decimals = isTon ? 3 : 0;
    String formatWeight(double? kg) {
      if (kg == null) return '--';
      final display = isTon ? kg / 1000 : kg;
      return '${display.toStringAsFixed(decimals)} $unit';
    }

    final grossDate = weights.grossKg != null && bill.grossCapturedAt != null
        ? DateFormat('dd/MM/yyyy').format(bill.grossCapturedAt!)
        : (weights.grossKg != null
              ? DateFormat('dd/MM/yyyy').format(bill.createdAt)
              : '--');
    final grossTime = weights.grossKg != null && bill.grossCapturedAt != null
        ? DateFormat('hh:mm a').format(bill.grossCapturedAt!)
        : (weights.grossKg != null
              ? DateFormat('hh:mm a').format(bill.createdAt)
              : '--');

    final tareDate = weights.tareKg != null && bill.tareCapturedAt != null
        ? DateFormat('dd/MM/yyyy').format(bill.tareCapturedAt!)
        : (weights.tareKg != null
              ? DateFormat('dd/MM/yyyy').format(bill.createdAt)
              : '--');
    final tareTime = weights.tareKg != null && bill.tareCapturedAt != null
        ? DateFormat('hh:mm a').format(bill.tareCapturedAt!)
        : (weights.tareKg != null
              ? DateFormat('hh:mm a').format(bill.updatedAt)
              : '--');

    final companyName = activeSettings.businessName.isNotEmpty
        ? activeSettings.businessName
        : 'VIYAN WEIGHBRIDGE';
    final receiptTitleConfig = activeSettings.receiptTitle.trim();
    final receiptTitle = receiptTitleConfig.isNotEmpty
        ? receiptTitleConfig
        : 'Public';

    const monoFont = TextStyle(
      fontFamily: 'Courier',
      fontSize: 13,
      color: Colors.black,
    );

    const monoBold = TextStyle(
      fontFamily: 'Courier',
      fontSize: 13,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Container(
        width: 720,
        constraints: const BoxConstraints(maxHeight: 880),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.20),
              blurRadius: 36,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Modal Top Header Bar ─────────────────────
            _buildModalTopBar(context, bill.billNumber),

            // ── Industrial Slip Sheet ────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 36,
                    vertical: 32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Company Letterhead Header (Centered)
                      Center(
                        child: Column(
                          children: [
                            Text(
                              companyName.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Courier',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                letterSpacing: 0.5,
                              ),
                            ),
                            if (activeSettings.businessSubtitle != null &&
                                activeSettings.businessSubtitle!
                                    .trim()
                                    .isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                activeSettings.businessSubtitle!,
                                textAlign: TextAlign.center,
                                style: monoFont.copyWith(fontSize: 12),
                              ),
                            ],
                            if (activeSettings.serviceText != null &&
                                activeSettings.serviceText!
                                    .trim()
                                    .isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                activeSettings.serviceText!,
                                textAlign: TextAlign.center,
                                style: monoBold.copyWith(fontSize: 11.5),
                              ),
                            ],
                            if (activeSettings.address != null &&
                                activeSettings.address!.trim().isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text(
                                activeSettings.address!,
                                textAlign: TextAlign.center,
                                style: monoFont.copyWith(fontSize: 11.5),
                              ),
                            ],
                            if ((activeSettings.phoneNumber != null &&
                                    activeSettings.phoneNumber!
                                        .trim()
                                        .isNotEmpty) ||
                                (activeSettings.email != null &&
                                    activeSettings.email!.trim().isNotEmpty) ||
                                (activeSettings.gstin != null &&
                                    activeSettings.gstin!
                                        .trim()
                                        .isNotEmpty)) ...[
                              const SizedBox(height: 2),
                              Text(
                                [
                                  if (activeSettings.phoneNumber != null &&
                                      activeSettings.phoneNumber!
                                          .trim()
                                          .isNotEmpty)
                                    'Tel: ${activeSettings.phoneNumber!}',
                                  if (activeSettings.email != null &&
                                      activeSettings.email!.trim().isNotEmpty)
                                    'E-Mail: ${activeSettings.email!}',
                                  if (activeSettings.gstin != null &&
                                      activeSettings.gstin!.trim().isNotEmpty)
                                    'GSTIN: ${activeSettings.gstin!}',
                                ].join('   '),
                                textAlign: TextAlign.center,
                                style: monoFont.copyWith(fontSize: 11.5),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 22),

                      // 2. Receipt Subtitle / Category
                      Text(
                        receiptTitle,
                        style: monoBold.copyWith(fontSize: 13.5),
                      ),

                      const SizedBox(height: 12),

                      // 3. Metadata Fields (Colons vertically aligned)
                      if (hasSerial)
                        _buildScreenFieldRow('TOKEN NO', bill.billNumber),
                      if (hasVehNo)
                        _buildScreenFieldRow(
                          'VEHICLE NO',
                          vehicleNo,
                          isBold: true,
                        ),
                      if (hasCustomer)
                        _buildScreenFieldRow('DESCRIPTION', customerName),
                      if (hasMat) _buildScreenFieldRow('PRODUCT', materialName),
                      if (customerPhone.isNotEmpty)
                        _buildScreenFieldRow('MOBILE NO', customerPhone),
                      if (hasRemarks)
                        _buildScreenFieldRow('CONTAINER No', bill.remarks!),

                      const SizedBox(height: 10),

                      // 4. Dashed line above table
                      _buildScreenDashedLine(),

                      // 5. Weight Table Header
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const SizedBox(width: 100),
                            Expanded(
                              flex: 3,
                              child: Text(
                                'WEIGHT',
                                textAlign: TextAlign.center,
                                style: monoBold,
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                'DATE',
                                textAlign: TextAlign.center,
                                style: monoBold,
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                'TIME',
                                textAlign: TextAlign.center,
                                style: monoBold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 6. Dashed line below header
                      _buildScreenDashedLine(),

                      // 7. Weight Rows
                      if (hasGross &&
                          weights.grossKg != null &&
                          weights.grossKg! > 0)
                        _buildScreenWeightRow(
                          label: 'GROSS',
                          weight: formatWeight(weights.grossKg),
                          date: grossDate,
                          time: grossTime,
                        ),

                      if (hasTare &&
                          weights.tareKg != null &&
                          weights.tareKg! > 0)
                        _buildScreenWeightRow(
                          label: 'TARE',
                          weight: formatWeight(weights.tareKg),
                          date: tareDate,
                          time: tareTime,
                        ),

                      if (hasNet && weights.netKg != null && weights.netKg! > 0)
                        _buildScreenWeightRow(
                          label: 'NET',
                          weight: formatWeight(weights.netKg),
                          date: '--',
                          time: '--',
                        ),

                      // 8. Dashed line below table
                      _buildScreenDashedLine(),

                      // 9. Financials
                      if (hasAmount || hasPayment) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            if (hasAmount)
                              Text(
                                'CHARGES (Rs.) : ${bill.amount.toStringAsFixed(2)}',
                                style: monoBold,
                              ),
                            const Spacer(),
                            if (hasPayment)
                              Text(
                                'PAYMENT MODE : ${bill.paymentMode.toUpperCase()}',
                                style: monoBold,
                              ),
                          ],
                        ),
                      ],

                      // 10. Footer note
                      if (hasFooter) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Note: $footerNoteText',
                          style: monoFont.copyWith(fontSize: 11),
                        ),
                      ],

                      const SizedBox(height: 28),

                      // 12. Print timestamp
                      Center(
                        child: Text(
                          '* Printed on: $printDate *',
                          style: monoFont.copyWith(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Modal Bottom Actions Bar ──────────────────
            _buildModalBottomBar(context),
          ],
        ),
      ),
    );
  }

  static Widget _buildScreenFieldRow(
    String label,
    String value, {
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Courier',
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const Text(
            ': ',
            style: TextStyle(
              fontFamily: 'Courier',
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'Courier',
                fontSize: 13,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildScreenDashedLine() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Text(
        '--------------------------------------------------------------------------------',
        maxLines: 1,
        style: TextStyle(
          fontFamily: 'Courier',
          fontSize: 13,
          color: Colors.black,
          letterSpacing: -0.2,
        ),
      ),
    );
  }

  static Widget _buildScreenWeightRow({
    required String label,
    required String weight,
    required String date,
    required String time,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Courier',
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              weight,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Courier',
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              date,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Courier',
                fontSize: 13,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              time,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Courier',
                fontSize: 13,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModalTopBar(BuildContext context, String billNumber) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: Color(0xFF16A34A),
              size: 19,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Weighment Slip Preview',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              Text(
                'Ticket #$billNumber',
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 11.5,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded, size: 20),
            color: const Color(0xFF64748B),
            tooltip: 'Close (Esc)',
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFF1F5F9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModalBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
              foregroundColor: const Color(0xFF64748B),
              side: const BorderSide(color: Color(0xFFCBD5E1)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Close',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: _isPrinting ? null : _handlePrint,
            icon: _isPrinting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.print_rounded, size: 18),
            label: Text(
              _isPrinting ? 'Printing...' : 'Print Ticket',
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w700,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
