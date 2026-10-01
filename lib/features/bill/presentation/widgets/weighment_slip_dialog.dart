import 'dart:io';

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

/// Modern on-screen preview dialog for the A4 invoice-style weighment document.
///
/// Features:
/// - True document-proportioned paper preview reflecting the printed A4 invoice.
/// - Prominent Viyan Weighbridge letterhead & branding.
/// - Clean document metadata header with invoice number, date, and time.
/// - Two-column vehicle, customer, and material summary card.
/// - Unified weight details with 3 visual highlight cards and a structured table.
/// - Charges, payment mode, and completed status breakdown with colored chips.
/// - Operator note, authorized signatory signature lines, and print timestamp.
/// - Direct "Print Ticket" action sending the document to the system printer.
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
    final bill = widget.bill;
    final customer = widget.customer;
    final materialName = widget.materialName;

    final activeSettings = _resolveActiveSettings();
    final weights = const ReceiptWeightResolver().resolve(bill);

    final vehicleNo = bill.vehicleNumber.isEmpty ? '—' : bill.vehicleNumber;
    final customerName = customer?.name ?? '—';
    final customerPhone = customer?.mobile ?? '';
    final dateFormatted = DateFormat('dd/MM/yyyy').format(bill.createdAt);
    final timeFormatted = DateFormat('hh:mm:ss a').format(bill.createdAt);
    final printDate = DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());
    final isCompleted = bill.isCompleted;

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
        : (weights.grossKg != null ? dateFormatted : '--');
    final grossTime = weights.grossKg != null && bill.grossCapturedAt != null
        ? DateFormat('hh:mm a').format(bill.grossCapturedAt!)
        : (weights.grossKg != null
              ? DateFormat('hh:mm a').format(bill.createdAt)
              : '--');

    final tareDate = weights.tareKg != null && bill.tareCapturedAt != null
        ? DateFormat('dd/MM/yyyy').format(bill.tareCapturedAt!)
        : (weights.tareKg != null ? dateFormatted : '--');
    final tareTime = weights.tareKg != null && bill.tareCapturedAt != null
        ? DateFormat('hh:mm a').format(bill.tareCapturedAt!)
        : (weights.tareKg != null
              ? DateFormat('hh:mm a').format(bill.updatedAt)
              : '--');

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
    final hasCash = activeSettings.showCashReceived;

    final hasRemarks =
        activeSettings.showRemarks &&
        bill.remarks != null &&
        bill.remarks!.trim().isNotEmpty;
    final hasFooter = activeSettings.showFooterNote;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 900),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.20),
              blurRadius: 40,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Modal Top Header Bar ─────────────────────
            _buildModalTopBar(context, bill.billNumber),

            // ── Document Paper Sheet ─────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Company Letterhead Header
                      _buildCompanyHeader(activeSettings),

                      const SizedBox(height: 18),
                      const Divider(color: Color(0xFFE2E8F0), height: 1),
                      const SizedBox(height: 14),

                      // 2. Invoice Title Banner & Bill Info Bar
                      _buildInvoiceBanner(
                        activeSettings,
                        bill.billNumber,
                        dateFormatted,
                        timeFormatted,
                      ),

                      const SizedBox(height: 14),

                      // 3. Vehicle & Party Details Card
                      _buildVehicleAndPartyCard(
                        vehicleNo: vehicleNo,
                        customerName: customerName,
                        customerPhone: customerPhone,
                        materialName: materialName,
                      ),

                      const SizedBox(height: 16),

                      // 4. WEIGHT DETAILS Section (Cards + Table)
                      _buildWeightSection(
                        hasGross: hasGross,
                        hasTare: hasTare,
                        hasNet: hasNet,
                        grossWeightDisplay: formatWeight(weights.grossKg),
                        tareWeightDisplay: formatWeight(weights.tareKg),
                        netWeightDisplay: formatWeight(weights.netKg),
                        grossDate: grossDate,
                        grossTime: grossTime,
                        tareDate: tareDate,
                        tareTime: tareTime,
                        hasGrossValue: weights.grossKg != null,
                        hasTareValue: weights.tareKg != null,
                        hasNetValue: weights.netKg != null,
                      ),

                      const SizedBox(height: 16),

                      // 5. Financials & Payment Card
                      if (hasAmount || hasPayment || hasCash)
                        _buildFinancialsCard(
                          bill: bill,
                          isCompleted: isCompleted,
                          hasAmount: hasAmount,
                          hasPayment: hasPayment,
                          hasCash: hasCash,
                        ),

                      if (hasRemarks) ...[
                        const SizedBox(height: 12),
                        _buildRemarksCard(bill.remarks!),
                      ],

                      const SizedBox(height: 22),

                      // 6. Signatures & Footer Note
                      _buildSignaturesAndFooter(
                        activeSettings: activeSettings,
                        hasFooter: hasFooter,
                        printDate: printDate,
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

  // ── 1. Modal Top Bar ──────────────────────────────────────

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
              border: Border.all(color: const Color(0xFFBBF7D0)),
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
                'Weighment Invoice Preview',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              Text(
                'Document #$billNumber · A4 Format',
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

  // ── 2. Company Letterhead Header ─────────────────────────

  Widget _buildCompanyHeader(BillingSettings settings) {
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
              height: 44,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => _buildDefaultLogo(),
            ),
          )
        else
          _buildDefaultLogo(),
        const SizedBox(height: 6),
        Text(
          settings.businessName.isNotEmpty
              ? settings.businessName
              : 'VIYAN WEIGHBRIDGE',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 18,
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
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF475569),
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
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Color(0xFF16A34A),
              letterSpacing: 0.8,
            ),
          ),
        ],
        if (settings.address != null &&
            settings.address!.trim().isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            settings.address!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 9.5,
              color: Color(0xFF64748B),
            ),
          ),
        ],
        if ((settings.phoneNumber != null &&
                settings.phoneNumber!.trim().isNotEmpty) ||
            (settings.email != null && settings.email!.trim().isNotEmpty) ||
            (settings.gstin != null && settings.gstin!.trim().isNotEmpty)) ...[
          const SizedBox(height: 3),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            children: [
              if (settings.phoneNumber != null &&
                  settings.phoneNumber!.trim().isNotEmpty)
                Text(
                  'Ph: ${settings.phoneNumber!}',
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 9,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              if (settings.email != null && settings.email!.trim().isNotEmpty)
                Text(
                  'Email: ${settings.email!}',
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 9,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              if (settings.gstin != null && settings.gstin!.trim().isNotEmpty)
                Text(
                  'GSTIN: ${settings.gstin!}',
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF475569),
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
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          'VW',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // ── 3. Invoice Title Banner ──────────────────────────────

  Widget _buildInvoiceBanner(
    BillingSettings settings,
    String billNumber,
    String dateFormatted,
    String timeFormatted,
  ) {
    final title = settings.receiptTitle.isNotEmpty
        ? settings.receiptTitle
        : 'WEIGHMENT RECEIPT';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'WEIGHMENT INVOICE',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Bill No: ',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                  ),
                ),
                Text(
                  billNumber,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Date: $dateFormatted',
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF475569),
                ),
              ),
              Text(
                'Time: $timeFormatted',
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF475569),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── 4. Vehicle & Party Information Card ──────────────────

  Widget _buildVehicleAndPartyCard({
    required String vehicleNo,
    required String customerName,
    required String customerPhone,
    required String materialName,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: Vehicle & Material
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoItem(
                  icon: Icons.local_shipping_outlined,
                  label: 'VEHICLE / TRUCK NO',
                  value: vehicleNo,
                  isPrimary: true,
                ),
                const SizedBox(height: 10),
                _buildInfoItem(
                  icon: Icons.category_outlined,
                  label: 'MATERIAL / COMMODITY',
                  value: materialName,
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 60,
            color: const Color(0xFFF1F5F9),
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),
          // Right: Customer & Contact
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoItem(
                  icon: Icons.business_rounded,
                  label: 'CUSTOMER / PARTY',
                  value: customerName,
                  isPrimary: true,
                ),
                if (customerPhone.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _buildInfoItem(
                    icon: Icons.phone_android_rounded,
                    label: 'MOBILE / PHONE',
                    value: customerPhone,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    bool isPrimary = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF64748B)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 1.5),
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: isPrimary ? 13 : 11.5,
                  fontWeight: isPrimary ? FontWeight.w800 : FontWeight.w600,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── 5. WEIGHT DETAILS Section ────────────────────────────

  Widget _buildWeightSection({
    required bool hasGross,
    required bool hasTare,
    required bool hasNet,
    required String grossWeightDisplay,
    required String tareWeightDisplay,
    required String netWeightDisplay,
    required String grossDate,
    required String grossTime,
    required String tareDate,
    required String tareTime,
    required bool hasGrossValue,
    required bool hasTareValue,
    required bool hasNetValue,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section Title Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: const Row(
              children: [
                Icon(Icons.scale_rounded, size: 16, color: Color(0xFF16A34A)),
                SizedBox(width: 8),
                Text(
                  'WEIGHT DETAILS',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),

          // 3 Visual KPI Cards: Gross | Tare | Net
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _buildWeightKpiCard(
                  title: 'GROSS WEIGHT',
                  weightDisplay: grossWeightDisplay,
                  dateText: grossDate,
                  timeText: grossTime,
                  hasValue: hasGrossValue,
                  accentColor: const Color(0xFF0284C7),
                  bgColor: const Color(0xFFF0F9FF),
                ),
                const SizedBox(width: 10),
                _buildWeightKpiCard(
                  title: 'TARE WEIGHT',
                  weightDisplay: tareWeightDisplay,
                  dateText: tareDate,
                  timeText: tareTime,
                  hasValue: hasTareValue,
                  accentColor: const Color(0xFFD97706),
                  bgColor: const Color(0xFFFFFBEB),
                ),
                const SizedBox(width: 10),
                _buildWeightKpiCard(
                  title: 'NET WEIGHT',
                  weightDisplay: netWeightDisplay,
                  dateText: '--',
                  timeText: '--',
                  hasValue: hasNetValue,
                  isNet: true,
                  accentColor: const Color(0xFF16A34A),
                  bgColor: const Color(0xFFF0FDF4),
                ),
              ],
            ),
          ),

          // Structured Full-width Table
          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
            ),
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(2.4),
                1: FlexColumnWidth(1.8),
                2: FlexColumnWidth(1.6),
                3: FlexColumnWidth(2.0),
              },
              children: [
                // Table Header
                TableRow(
                  decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
                  children: [
                    _buildTableCell('Weight Type', isHeader: true),
                    _buildTableCell('Date', isHeader: true),
                    _buildTableCell('Time', isHeader: true),
                    _buildTableCell('Weight', isHeader: true, alignRight: true),
                  ],
                ),
                // Gross Row
                if (hasGross)
                  TableRow(
                    children: [
                      _buildTableCell('Gross Weight', isBold: true),
                      _buildTableCell(grossDate),
                      _buildTableCell(grossTime),
                      _buildTableCell(
                        grossWeightDisplay,
                        alignRight: true,
                        isBold: true,
                      ),
                    ],
                  ),
                // Tare Row
                if (hasTare)
                  TableRow(
                    children: [
                      _buildTableCell('Tare Weight', isBold: true),
                      _buildTableCell(tareDate),
                      _buildTableCell(tareTime),
                      _buildTableCell(
                        tareWeightDisplay,
                        alignRight: true,
                        isBold: true,
                      ),
                    ],
                  ),
                // Net Row
                if (hasNet)
                  TableRow(
                    decoration: const BoxDecoration(color: Color(0xFFF0FDF4)),
                    children: [
                      _buildTableCell(
                        'Net Weight',
                        isBold: true,
                        textColor: const Color(0xFF15803D),
                      ),
                      _buildTableCell('—', textColor: const Color(0xFF15803D)),
                      _buildTableCell('—', textColor: const Color(0xFF15803D)),
                      _buildTableCell(
                        netWeightDisplay,
                        alignRight: true,
                        isBold: true,
                        textColor: const Color(0xFF15803D),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightKpiCard({
    required String title,
    required String weightDisplay,
    required String dateText,
    required String timeText,
    required bool hasValue,
    required Color accentColor,
    required Color bgColor,
    bool isNet = false,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: hasValue
                ? accentColor.withValues(alpha: 0.35)
                : const Color(0xFFE2E8F0),
            width: isNet ? 1.4 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
                color: hasValue ? accentColor : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              weightDisplay,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: hasValue
                    ? const Color(0xFF0F172A)
                    : const Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 6),
            Container(height: 1, color: const Color(0xFFE2E8F0)),
            const SizedBox(height: 4),
            Text(
              dateText == '--' ? 'Date : --' : 'Date : $dateText',
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 8.5,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              timeText == '--' ? 'Time : --' : 'Time : $timeText',
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 8.5,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    bool alignRight = false,
    bool isBold = false,
    Color? textColor,
  }) {
    final isDash = text == '--';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(
        text,
        textAlign: alignRight ? TextAlign.right : TextAlign.left,
        style: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: isHeader ? 9.5 : 10.5,
          fontWeight: isHeader || isBold ? FontWeight.w800 : FontWeight.w600,
          color: isHeader
              ? const Color(0xFF475569)
              : (textColor ??
                    (isDash
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF0F172A))),
        ),
      ),
    );
  }

  // ── 6. Financials & Payment Card ──────────────────────────

  Widget _buildFinancialsCard({
    required Weighment bill,
    required bool isCompleted,
    required bool hasAmount,
    required bool hasPayment,
    required bool hasCash,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          // Charges
          if (hasAmount) ...[
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'WEIGHMENT CHARGES',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '₹${NumberFormat('#,##0.00').format(bill.amount)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
          ],

          // Payment Mode
          if (hasPayment) ...[
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PAYMENT MODE',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    bill.paymentMode.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
          ],

          // Cash Received
          if (hasCash && bill.paymentMode.toUpperCase() == 'CASH') ...[
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CASH RECEIVED',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '₹${NumberFormat('#,##0.00').format(bill.amount)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(width: 10),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isCompleted
                  ? const Color(0xFFDCFCE7)
                  : const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isCompleted
                    ? const Color(0xFFBBF7D0)
                    : const Color(0xFFFDE68A),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isCompleted
                      ? Icons.check_circle_rounded
                      : Icons.pending_rounded,
                  size: 14,
                  color: isCompleted
                      ? const Color(0xFF16A34A)
                      : const Color(0xFFD97706),
                ),
                const SizedBox(width: 5),
                Text(
                  isCompleted ? 'COMPLETED' : 'INCOMPLETE',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: isCompleted
                        ? const Color(0xFF15803D)
                        : const Color(0xFFB45309),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 7. Remarks Card ───────────────────────────────────────

  Widget _buildRemarksCard(String remarks) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.chat_bubble_outline_rounded,
            size: 14,
            color: Color(0xFF64748B),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 10.5,
                  color: Color(0xFF475569),
                ),
                children: [
                  const TextSpan(
                    text: 'Direct delivery to site: ',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  TextSpan(text: remarks),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 8. Signatures & Footer Note ───────────────────────────

  Widget _buildSignaturesAndFooter({
    required BillingSettings activeSettings,
    required bool hasFooter,
    required String printDate,
  }) {
    final customNote = activeSettings.footerNote?.trim();
    final noteText = (customNote != null && customNote.isNotEmpty)
        ? customNote
        : 'Please check the weight before leaving the weighbridge.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hasFooter)
          Center(
            child: Text(
              'Note: $noteText',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 9,
                fontStyle: FontStyle.italic,
                color: Color(0xFF64748B),
              ),
            ),
          ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 140,
                  height: 1,
                  color: const Color(0xFF0F172A),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Driver's Signature",
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 9,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  activeSettings.businessName.isNotEmpty
                      ? activeSettings.businessName
                      : 'VIYAN WEIGHBRIDGE',
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: 160,
                  height: 1,
                  color: const Color(0xFF0F172A),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Authorized Signatory',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 9,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            '* Printed on: $printDate *',
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 7.5,
              color: Color(0xFF94A3B8),
            ),
          ),
        ),
      ],
    );
  }

  // ── 9. Modal Bottom Action Bar ───────────────────────────

  Widget _buildModalBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close_rounded, size: 16),
              label: const Text('Close'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF475569),
                side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
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
              label: const Text('Print Ticket'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
                elevation: 2,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
