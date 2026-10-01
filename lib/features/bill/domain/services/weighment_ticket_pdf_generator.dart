import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../settings/domain/entities/billing_settings.dart';
import '../entities/weighment.dart';
import '../../../customer/domain/entities/customer.dart';
import 'receipt_weight_resolver.dart';

/// Builds the weighment ticket (receipt) PDF that is sent to the printer
/// by the "Print Ticket" button.
///
/// The document mirrors the on-screen receipt preview: it is built from
/// the **saved** [Weighment] entity, uses the same
/// [ReceiptWeightResolver] as the preview and renders every missing
/// weight as `--` (never `0`, never a fabricated net weight).
class WeighmentTicketPdfGenerator {
  const WeighmentTicketPdfGenerator();

  static final PdfColor _dark = PdfColor.fromHex('#0F172A');
  static final PdfColor _slate = PdfColor.fromHex('#64748B');
  static final PdfColor _muted = PdfColor.fromHex('#94A3B8');
  static final PdfColor _steel = PdfColor.fromHex('#475569');
  static final PdfColor _accentBorder = PdfColor.fromHex('#38BDF8');
  static final PdfColor _transparent = PdfColor(0, 0, 0, 0);
  static final PdfColor _white = PdfColor(1, 1, 1, 1);

  Future<Uint8List> generateTicketPdf({
    required Weighment bill,
    required Customer? customer,
    required String materialName,
    required BillingSettings settings,
    DateTime? printedAt,
  }) async {
    final regularFontData = await rootBundle.load(
      'fonts/PlusJakartaSans-Regular.ttf',
    );
    final boldFontData = await rootBundle.load(
      'fonts/PlusJakartaSans-ExtraBold.ttf',
    );
    final pdfTheme = pw.ThemeData.withFont(
      base: pw.Font.ttf(regularFontData),
      bold: pw.Font.ttf(boldFontData),
    );
    final pdf = pw.Document(theme: pdfTheme);

    final weights = const ReceiptWeightResolver().resolve(bill);

    final vehicleNo = bill.vehicleNumber.isEmpty ? '—' : bill.vehicleNumber;
    final customerName = customer?.name ?? '—';
    final customerPhone = customer?.mobile ?? '';
    final dateFormatted = DateFormat('dd/MM/yyyy').format(bill.createdAt);
    final timeFormatted = DateFormat('hh:mm:ss a').format(bill.createdAt);
    final printDate = DateFormat(
      'dd/MM/yyyy HH:mm:ss',
    ).format(printedAt ?? DateTime.now());
    final isCompleted = bill.isCompleted;

    final hasSerial = settings.showSerialNumber;
    final hasDate = settings.showDate;
    final hasTime = settings.showTime;
    final hasGeneralInfo = hasSerial || hasDate || hasTime;

    final hasVehNo = settings.showVehicleNumber;
    final hasMat = settings.showMaterial;
    final hasCustomer = settings.showCustomer;
    final hasDetails = hasVehNo || hasMat || hasCustomer;

    final hasGross =
        isCompleted ||
        settings.showGrossWeight ||
        (weights.grossKg != null && weights.grossKg! > 0);
    final hasTare =
        isCompleted ||
        settings.showTareWeight ||
        (weights.tareKg != null && weights.tareKg! > 0);
    final hasNet =
        isCompleted ||
        settings.showNetWeight ||
        (weights.netKg != null && weights.netKg! > 0);
    final hasWeights = hasGross || hasTare || hasNet;

    final hasAmount = isCompleted || settings.showAmount || bill.amount > 0;
    final hasPayment = settings.showPaymentMode;
    final hasCash = settings.showCashReceived;
    final hasFinancials = hasAmount || hasPayment || hasCash;

    final hasRemarks =
        settings.showRemarks &&
        bill.remarks != null &&
        bill.remarks!.trim().isNotEmpty;
    final hasFooter = settings.showFooterNote;
    final customFooter = settings.footerNote?.trim();
    final footerNoteText = (customFooter != null && customFooter.isNotEmpty)
        ? customFooter
        : 'Please check the weight before leaving the weighbridge.';

    final isTon =
        settings.weightUnit.toLowerCase() == 'ton' ||
        settings.weightUnit.toLowerCase() == 'tonne';
    final unit = isTon ? 'ton' : 'kg';
    final decimals = isTon ? 3 : 0;
    String formatWeight(double? kg) {
      if (kg == null) return '--';
      final display = isTon ? kg / 1000 : kg;
      return '${display.toStringAsFixed(decimals)} $unit';
    }

    final valueStyle = pw.TextStyle(
      fontSize: 10,
      fontWeight: pw.FontWeight.bold,
      color: _dark,
    );
    final labelStyle = pw.TextStyle(fontSize: 10, color: _slate);
    final weightLabelStyle = pw.TextStyle(fontSize: 10, color: _slate);
    pw.TextStyle weightValueStyle(String value) => pw.TextStyle(
      fontSize: 11,
      fontWeight: pw.FontWeight.bold,
      color: value == '--' ? _muted : _dark,
      letterSpacing: 0.3,
    );

    pw.Widget divider() => pw.Row(
      children: List.generate(
        40,
        (i) => pw.Expanded(
          child: pw.Container(
            height: 1,
            color: i.isEven ? _slate : _transparent,
          ),
        ),
      ),
    );

    pw.Widget infoRow(String label, String value) => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(width: 110, child: pw.Text(label, style: labelStyle)),
          pw.Expanded(child: pw.Text(value, style: valueStyle)),
        ],
      ),
    );

    pw.Widget weightRow(String label, String value) => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 110,
            child: pw.Text(label, style: weightLabelStyle),
          ),
          pw.Expanded(child: pw.Text(value, style: weightValueStyle(value))),
        ],
      ),
    );

    final logoPath = settings.logoPath?.trim();
    final hasLogo =
        logoPath != null && logoPath.isNotEmpty && File(logoPath).existsSync();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.portrait,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Container(
              width: 300,
              padding: const pw.EdgeInsets.all(8),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  // ── Letterhead ─────────────────────────────
                  pw.Center(
                    child: hasLogo
                        ? pw.Image(
                            pw.MemoryImage(File(logoPath).readAsBytesSync()),
                            height: 36,
                            fit: pw.BoxFit.contain,
                          )
                        : pw.Container(
                            width: 28,
                            height: 28,
                            alignment: pw.Alignment.center,
                            decoration: pw.BoxDecoration(
                              color: _dark,
                              shape: pw.BoxShape.circle,
                              border: pw.Border.all(
                                color: _accentBorder,
                                width: 1,
                              ),
                            ),
                            child: pw.Text(
                              'WB',
                              style: pw.TextStyle(
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold,
                                color: _white,
                              ),
                            ),
                          ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Center(
                    child: pw.Text(
                      settings.businessName.isNotEmpty
                          ? settings.businessName
                          : 'VIYAN WEIGHBRIDGE',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: _dark,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  if (settings.businessSubtitle != null &&
                      settings.businessSubtitle!.trim().isNotEmpty) ...[
                    pw.SizedBox(height: 2),
                    pw.Center(
                      child: pw.Text(
                        settings.businessSubtitle!,
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: _slate,
                        ),
                      ),
                    ),
                  ],
                  if (settings.serviceText != null &&
                      settings.serviceText!.trim().isNotEmpty) ...[
                    pw.SizedBox(height: 2),
                    pw.Center(
                      child: pw.Text(
                        settings.serviceText!,
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold,
                          color: _steel,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ],
                  if (settings.address != null &&
                      settings.address!.trim().isNotEmpty) ...[
                    pw.SizedBox(height: 2),
                    pw.Center(
                      child: pw.Text(
                        settings.address!,
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(fontSize: 8, color: _slate),
                      ),
                    ),
                  ],
                  if ((settings.phoneNumber != null &&
                          settings.phoneNumber!.trim().isNotEmpty) ||
                      (settings.gstin != null &&
                          settings.gstin!.trim().isNotEmpty)) ...[
                    pw.SizedBox(height: 2),
                    pw.Center(
                      child: pw.Text(
                        [
                          if (settings.phoneNumber != null &&
                              settings.phoneNumber!.trim().isNotEmpty)
                            'Ph: ${settings.phoneNumber!}',
                          if (settings.gstin != null &&
                              settings.gstin!.trim().isNotEmpty)
                            'GSTIN: ${settings.gstin!}',
                        ].join(' · '),
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(fontSize: 7.5, color: _slate),
                      ),
                    ),
                  ],
                  pw.SizedBox(height: 8),
                  divider(),
                  pw.SizedBox(height: 6),

                  // ── Title ──────────────────────────────────
                  pw.Center(
                    child: pw.Text(
                      settings.receiptTitle.isNotEmpty
                          ? settings.receiptTitle
                          : 'WEIGHMENT RECEIPT',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: _dark,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 8),

                  // ── Bill info ──────────────────────────────
                  if (hasGeneralInfo) ...[
                    divider(),
                    pw.SizedBox(height: 6),
                    if (hasSerial) infoRow('Bill No.', bill.billNumber),
                    if (hasDate) infoRow('Date', dateFormatted),
                    if (hasTime) infoRow('Time', timeFormatted),
                    pw.SizedBox(height: 6),
                  ],

                  // ── Vehicle / material / customer ──────────
                  if (hasDetails) ...[
                    divider(),
                    pw.SizedBox(height: 6),
                    if (hasVehNo) infoRow('Vehicle No.', vehicleNo),
                    if (hasMat) infoRow('Material', materialName),
                    if (hasCustomer) ...[
                      infoRow('Customer', customerName),
                      if (customerPhone.isNotEmpty)
                        infoRow('Customer Mobile', customerPhone),
                    ],
                    pw.SizedBox(height: 6),
                  ],

                  // ── Weights + status ───────────────────────
                  if (hasWeights) ...[
                    divider(),
                    pw.SizedBox(height: 6),
                    if (hasGross)
                      weightRow('Gross Weight', formatWeight(weights.grossKg)),
                    if (hasTare)
                      weightRow('Tare Weight', formatWeight(weights.tareKg)),
                    if (hasGross || hasTare) pw.SizedBox(height: 4),
                    if (hasNet) ...[
                      divider(),
                      pw.SizedBox(height: 4),
                      weightRow('Net Weight', formatWeight(weights.netKg)),
                    ],
                    pw.SizedBox(height: 5),
                    weightRow(
                      'Status',
                      isCompleted ? 'COMPLETED' : 'INCOMPLETE',
                    ),
                    pw.SizedBox(height: 6),
                  ],

                  // ── Financials ─────────────────────────────
                  if (hasFinancials) ...[
                    divider(),
                    pw.SizedBox(height: 6),
                    if (hasAmount)
                      infoRow(
                        'Amount',
                        '₹${NumberFormat('#,##0.00').format(bill.amount)}',
                      ),
                    if (hasPayment)
                      infoRow('Payment', bill.paymentMode.toUpperCase()),
                    if (hasCash && bill.paymentMode.toUpperCase() == 'CASH')
                      infoRow(
                        'Cash Received',
                        '₹${NumberFormat('#,##0.00').format(bill.amount)}',
                      ),
                    pw.SizedBox(height: 6),
                  ],

                  // ── Remarks ────────────────────────────────
                  if (hasRemarks) ...[
                    pw.SizedBox(height: 6),
                    divider(),
                    pw.SizedBox(height: 6),
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Note: ',
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: _steel,
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Text(
                            bill.remarks!,
                            style: pw.TextStyle(fontSize: 9, color: _slate),
                          ),
                        ),
                      ],
                    ),
                  ],

                  // ── Footer note ────────────────────────────
                  if (hasFooter) ...[
                    pw.SizedBox(height: 8),
                    divider(),
                    pw.SizedBox(height: 6),
                    pw.Center(
                      child: pw.Text(
                        'Note: $footerNoteText',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize: 8,
                          color: _muted,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],

                  pw.SizedBox(height: 8),
                  pw.Center(
                    child: pw.Text(
                      '* $printDate *',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(fontSize: 7, color: _muted),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    return pdf.save();
  }
}
