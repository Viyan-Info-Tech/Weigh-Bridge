import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../settings/domain/entities/billing_settings.dart';
import '../entities/weighment.dart';
import 'preprinted_ticket_layout.dart';
import 'receipt_pdf_fonts.dart';

/// Builds the print job that lands on the client's existing pre-printed
/// HMB Enterprises continuous-form certificate.
///
/// The stationery already carries the logo, company name, address, phone
/// numbers, approval text, headings, borders, watermark and footer, so this
/// generator draws **only the dynamic weighment values** - and it draws each of
/// them twice, once inside the left bill section and once inside the right one,
/// so a single print operation produces two identical records on the same
/// horizontal row of the form.
///
/// The page is the exact paper the printer driver reported after the operator
/// chose the continuous-form size in the Windows print dialog, and the positions
/// come from [PrePrintedTicketLayout], which works in absolute physical-paper
/// coordinates - the same coordinate system the Windows print pipeline renders
/// the PDF in. Nothing is scaled, centred or given page margins, so the values
/// land where the character grid says they will.
class PrePrintedTicketPdfGenerator {
  const PrePrintedTicketPdfGenerator();

  /// [pageFormat] must be the printer-reported format (physical paper size plus
  /// its printable-area offsets), not a hard-coded A4.
  Future<Uint8List> generate({
    required Weighment bill,
    required BillingSettings settings,
    required PdfPageFormat pageFormat,
    DateTime? printedAt,
  }) async {
    final data = PrePrintedTicketData(
      bill: bill,
      settings: settings,
      printedAt: printedAt,
    );
    final layout = PrePrintedTicketLayout(
      pageFormat: pageFormat,
      settings: settings,
    );
    final texts = layout.buildPrintedTexts(data);
    final theme = await ReceiptPdfFonts.load();
    final pdf = pw.Document(theme: theme);
    final fontSize = layout.fontSize;

    pdf.addPage(
      pw.Page(
        // Physical paper, edge to edge: PDF point (0,0) is the top-left corner
        // of the sheet, which is what the driver renders against.
        pageFormat: PdfPageFormat(pageFormat.width, pageFormat.height),
        margin: pw.EdgeInsets.zero,
        clip: true,
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              for (final item in texts)
                pw.Positioned(
                  left: item.x,
                  top: item.y,
                  right: (pageFormat.width - (item.x + item.maxWidth))
                      .clamp(0.0, pageFormat.width),
                  child: pw.Text(
                    item.text,
                    maxLines: 1,
                    softWrap: false,
                    overflow: pw.TextOverflow.clip,
                    style: pw.TextStyle(
                      fontSize: fontSize,
                      fontBold: item.isBold,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
