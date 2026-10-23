import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../settings/domain/entities/billing_settings.dart';
import '../entities/weighment.dart';
import 'preprinted_ticket_layout.dart';
import 'receipt_pdf_fonts.dart';

/// Builds the print job document that prints ONLY the dynamic weighment values
/// onto the client's pre-printed continuous-form certificate stationery.
///
/// The physical paper already contains the company logo, company name, address,
/// phone numbers, headings, boxes/borders, field labels, and footer.
///
/// This generator draws ONLY the actual weighment data values:
/// - Left side: Copy 0 of the weighment values.
/// - Right side: Copy 1 of identical weighment values.
/// - NO background, NO company logo, NO headings, NO borders, and NO footer.
///
/// Every value is placed at its configured character grid coordinates (x, y)
/// from [PrePrintedTicketLayout] and printed with that field's own configured
/// font size and weight (bold or regular) from the same field grid.
class PrePrintedTicketPdfGenerator {
  const PrePrintedTicketPdfGenerator();

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

    pdf.addPage(
      pw.Page(
        // Physical paper, edge to edge: PDF point (0, 0) is the top-left corner
        // of the sheet matching the Windows printer driver's physical offsets.
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
                  right: (pageFormat.width - (item.x + item.maxWidth)).clamp(
                    0.0,
                    pageFormat.width,
                  ),
                  child: pw.Text(
                    item.text,
                    maxLines: 1,
                    softWrap: false,
                    overflow: pw.TextOverflow.clip,
                    style: pw.TextStyle(
                      fontSize: item.fontSize,
                      fontWeight: item.isBold
                          ? pw.FontWeight.bold
                          : pw.FontWeight.normal,
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
