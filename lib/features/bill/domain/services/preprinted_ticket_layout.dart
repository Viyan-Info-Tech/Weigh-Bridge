import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../settings/domain/entities/billing_settings.dart';
import '../entities/weighment.dart';
import 'receipt_weight_resolver.dart';
import 'weighment_receipt_data.dart';

// ---------------------------------------------------------------------------
// Geometry helpers
// ---------------------------------------------------------------------------

/// Points per millimetre (PDF points are 1/72 inch).
const double mmToPoint = 72.0 / 25.4;

/// One dynamic value printed onto the client's pre-printed HMB Enterprises
/// certificate.
///
/// Everything else on the physical paper - logo, company name, address, phone
/// numbers, government approval text, "Weight Certificate" heading, borders,
/// watermark and the thank-you footer - is already printed on the stationery
/// and is deliberately **not** part of this enum. The application only ever
/// writes the values below.
enum PrePrintedField {
  serial('SERIAL NO.'),
  date('DATE'),
  time('TIME'),
  vehicle('VEHICLE NO.'),
  charges('WT. CHARGES (Rs.)'),
  material('MATERIAL'),
  gross('GROSS'),
  tare('TARE'),
  net('Nett'),
  customer('CUSTOMER');

  const PrePrintedField(this.prePrintedLabel);

  /// The label exactly as it appears on the client's printed form. Used by the
  /// on-screen preview so the operator can see where a value will land; it is
  /// never drawn into the print job.
  final String prePrintedLabel;
}

// ---------------------------------------------------------------------------
// Per-field placement on the character grid
// ---------------------------------------------------------------------------

/// Where one field sits inside a single bill section.
///
/// Coordinates are counted on the printer's character grid rather than in
/// millimetres because that is how a dot-matrix form is actually laid out:
/// [column] is characters from the copy's origin (10 or 12 CPI) and [line] is
/// lines from the first printed line (6 or 8 LPI). A negative column or line
/// means "this form has no such position" and the field is not printed.
class PrePrintedFieldPlacement {
  const PrePrintedFieldPlacement({
    required this.column,
    required this.line,
    this.widthChars = 0,
  });

  final int column;
  final int line;

  /// Maximum width of the value in characters. `0` means "up to the end of
  /// this copy's column", which is resolved once the paper size is known.
  final int widthChars;

  bool get isPrintable => column >= 0 && line >= 0;

  Map<String, int> toJson() => {'c': column, 'l': line, 'w': widthChars};

  factory PrePrintedFieldPlacement.fromJson(Map<String, dynamic> json) {
    int read(String key) {
      final value = json[key];
      if (value is int) return value;
      if (value is num) return value.round();
      return 0;
    }

    return PrePrintedFieldPlacement(
      column: read('c'),
      line: read('l'),
      widthChars: read('w'),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is PrePrintedFieldPlacement &&
      other.column == column &&
      other.line == line &&
      other.widthChars == widthChars;

  @override
  int get hashCode => Object.hash(column, line, widthChars);
}

/// Starting grid for a two-up weighbridge certificate.
///
/// These are deliberately generous defaults, not measurements: the exact
/// positions depend on the client's HMB Enterprises stationery and on the TVS
/// printer's margins, so every one of them is editable in
/// Settings ▸ Continuous Form Printing and persisted with the settings row.
const Map<PrePrintedField, PrePrintedFieldPlacement> kDefaultPrePrintedGrid = {
  PrePrintedField.serial: PrePrintedFieldPlacement(
    column: 14,
    line: 0,
    widthChars: 18,
  ),
  PrePrintedField.date: PrePrintedFieldPlacement(
    column: 40,
    line: 0,
    widthChars: 12,
  ),
  PrePrintedField.time: PrePrintedFieldPlacement(
    column: 56,
    line: 0,
    widthChars: 12,
  ),
  PrePrintedField.vehicle: PrePrintedFieldPlacement(
    column: 14,
    line: 1,
    widthChars: 22,
  ),
  PrePrintedField.charges: PrePrintedFieldPlacement(
    column: 16,
    line: 2,
    widthChars: 18,
  ),
  PrePrintedField.material: PrePrintedFieldPlacement(
    column: 14,
    line: 3,
    widthChars: 26,
  ),
  PrePrintedField.gross: PrePrintedFieldPlacement(
    column: 14,
    line: 4,
    widthChars: 16,
  ),
  PrePrintedField.tare: PrePrintedFieldPlacement(
    column: 14,
    line: 5,
    widthChars: 16,
  ),
  PrePrintedField.net: PrePrintedFieldPlacement(
    column: 14,
    line: 6,
    widthChars: 16,
  ),
  PrePrintedField.customer: PrePrintedFieldPlacement(
    column: 14,
    line: 7,
    widthChars: 26,
  ),
};

/// Reads a persisted grid, falling back to [kDefaultPrePrintedGrid] for every
/// field the stored value does not mention.
///
/// Malformed JSON degrades to the defaults instead of throwing: alignment is
/// stored next to operator-typed settings and must never stop a print job.
Map<PrePrintedField, PrePrintedFieldPlacement> decodePrePrintedGrid(
  String? raw,
) {
  final placements = Map<PrePrintedField, PrePrintedFieldPlacement>.from(
    kDefaultPrePrintedGrid,
  );
  if (raw == null || raw.trim().isEmpty) return placements;

  try {
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) return placements;
    for (final field in PrePrintedField.values) {
      final entry = decoded[field.name];
      if (entry is Map<String, dynamic>) {
        placements[field] = PrePrintedFieldPlacement.fromJson(entry);
      }
    }
  } catch (_) {
    return Map<PrePrintedField, PrePrintedFieldPlacement>.from(
      kDefaultPrePrintedGrid,
    );
  }
  return placements;
}

String encodePrePrintedGrid(
  Map<PrePrintedField, PrePrintedFieldPlacement> placements,
) {
  final encoded = <String, dynamic>{
    for (final entry in placements.entries)
      entry.key.name: entry.value.toJson(),
  };
  return jsonEncode(encoded);
}

// ---------------------------------------------------------------------------
// Resolved values
// ---------------------------------------------------------------------------

/// The dynamic values of one weighment, resolved once for both copies.
///
/// Everything comes from the saved [bill], so a re-print prints the original
/// record: the serial number, vehicle, material, the manually entered charges
/// and the captured weights.
class PrePrintedTicketData {
  PrePrintedTicketData({
    required this.bill,
    required this.settings,
    DateTime? printedAt,
  }) : printedAt = printedAt ?? DateTime.now() {
    _receipt = WeighmentReceiptData(
      bill: bill,
      settings: settings,
      printedAt: printedAt,
    );
  }

  final Weighment bill;
  final BillingSettings settings;
  final DateTime printedAt;

  late final WeighmentReceiptData _receipt;

  /// Weights as the rest of the application resolves them (gross/tare/net from
  /// the first/second weight pair, honouring an explicit net).
  ResolvedReceiptWeights get weights => _receipt.weights;

  /// The weighment's own date/time - never the re-print time - so re-printing
  /// an old ticket reproduces the original record.
  DateTime get weighmentAt => bill.grossCapturedAt ?? bill.createdAt;

  String get dateText => DateFormat('dd/MM/yyyy').format(weighmentAt);

  String get timeText => DateFormat('hh:mm a').format(weighmentAt);

  /// Value for [field], or an empty string when there is nothing to print.
  ///
  /// An empty string prints nothing at all (no placeholder, no dash), so a
  /// weighment without charges leaves the WT. CHARGES row untouched on the
  /// pre-printed paper.
  String valueFor(PrePrintedField field) {
    switch (field) {
      case PrePrintedField.serial:
        return bill.billNumber;
      case PrePrintedField.date:
        return dateText;
      case PrePrintedField.time:
        return timeText;
      case PrePrintedField.vehicle:
        return bill.vehicleNumber.trim();
      case PrePrintedField.charges:
        return bill.charges == null ? '' : formatChargesAmount(bill.charges);
      case PrePrintedField.material:
        return bill.material?.trim() ?? '';
      case PrePrintedField.gross:
        return _weightText(weights.grossKg);
      case PrePrintedField.tare:
        return _weightText(weights.tareKg);
      case PrePrintedField.net:
        return _weightText(weights.netKg);
      case PrePrintedField.customer:
        // The weighment record carries no customer yet; the row stays blank on
        // the paper rather than printing a placeholder.
        return '';
    }
  }

  String _weightText(double? kg) {
    if (kg == null || kg <= 0) return '';
    final isTon =
        settings.weightUnit.toLowerCase() == 'ton' ||
        settings.weightUnit.toLowerCase() == 'tonne';
    final decimals = isTon ? 3 : 0;
    final value = isTon ? kg / 1000 : kg;
    final unit = isTon ? 'ton' : 'kg';
    final suffix = settings.printWeightUnit ? ' $unit' : '';
    return '${value.toStringAsFixed(decimals)}$suffix';
  }
}

// ---------------------------------------------------------------------------
// Layout
// ---------------------------------------------------------------------------

/// One value positioned on the physical paper, ready to draw.
class PrePrintedPrintedText {
  const PrePrintedPrintedText({
    required this.field,
    required this.copy,
    required this.text,
    required this.x,
    required this.y,
    required this.maxWidth,
    required this.isBold,
  });

  /// Which dynamic field this is.
  final PrePrintedField field;

  /// `0` = left bill section, `1` = right bill section.
  final int copy;

  /// The value only - never the pre-printed label.
  final String text;

  /// Millimetres-from-points positions measured from the physical paper origin
  /// (top-left corner of the sheet), which is exactly the coordinate system
  /// the Windows print pipeline renders the PDF in.
  final double x;
  final double y;

  /// Available width before the next value or the end of this copy.
  final double maxWidth;

  final bool isBold;
}

/// Turns a printer-reported page format plus the saved print settings into the
/// absolute positions of both bill copies.
///
/// The coordinate system is the physical sheet: the Windows print pipeline
/// renders the generated PDF with PDFium at `(-PHYSICALOFFSETX,
/// -PHYSICALOFFSETY)` of the device context, so PDF point (0, 0) is the
/// top-left corner of the paper itself. Everything here therefore adds the
/// driver's printable-area offsets ([PdfPageFormat.marginLeft] /
/// [PdfPageFormat.marginTop]) plus the operator's fine-tuning nudges.
class PrePrintedTicketLayout {
  PrePrintedTicketLayout({
    required PdfPageFormat pageFormat,
    required BillingSettings settings,
  }) : page = pageFormat,
       settings = settings,
       placements = decodePrePrintedGrid(settings.printFieldGrid) {
    if (cpi <= 0) _cpiInvalid = true;
    if (lpi <= 0) _lpiInvalid = true;
  }

  /// The page exactly as the printer driver reported it after the operator
  /// picked the continuous-form paper size in the Windows print dialog.
  final PdfPageFormat page;

  final BillingSettings settings;

  final Map<PrePrintedField, PrePrintedFieldPlacement> placements;

  bool _cpiInvalid = false;
  bool _lpiInvalid = false;

  // -- Character grid -------------------------------------------------------

  /// Characters per inch (10 or 12). 12 is the condensed-ish fit most
  /// pre-printed forms need; 10 CPI is the classic dot-matrix pitch.
  int get cpi => settings.printCpi <= 0 ? 12 : settings.printCpi;

  /// Lines per inch (6 or 8).
  int get lpi => settings.printLpi <= 0 ? 6 : settings.printLpi;

  /// Horizontal distance of one character, in points.
  double get charWidth => 72.0 / cpi;

  /// Vertical distance of one line, in points.
  double get linePitch => 72.0 / lpi;

  /// Font size whose character advance equals [charWidth] for a Courier-style
  /// monospaced face (advance = 0.6 em): 12 CPI → 10 pt, 10 CPI → 12 pt.
  double get fontSize => charWidth / 0.6;

  // -- Printable area -------------------------------------------------------

  /// First printable point from the left edge of the paper.
  double get printableLeft =>
      page.marginLeft + settings.printLeftOffsetMm * mmToPoint;

  /// First printable point from the top edge of the paper.
  double get printableTop =>
      page.marginTop + settings.printTopOffsetMm * mmToPoint;

  double get printableWidth => page.width - page.marginLeft - page.marginRight;

  double get printableHeight =>
      page.height - page.marginTop - page.marginBottom;

  // -- Two-up columns -------------------------------------------------------

  /// Horizontal distance between the left copy's origin and the right copy's
  /// origin. `0` in settings means "half the printable width", which keeps the
  /// two copies balanced on whatever paper the driver reports.
  double get columnWidth {
    final configured = settings.printColumnWidthMm * mmToPoint;
    if (configured > 0) return configured;
    return printableWidth / 2;
  }

  /// Physical left edge of copy [copy] (0 = left, 1 = right).
  double copyOriginX(int copy) => printableLeft + columnWidth * copy;

  /// Physical top edge shared by both copies - they always print on the same
  /// horizontal row of the continuous form.
  double get copyOriginY => printableTop;

  /// Distance between the two copies' origins expressed in whole characters,
  /// used by the preview to draw the section boundaries on the grid.
  int get columnWidthChars => (columnWidth / charWidth).round();

  // -- Placement ------------------------------------------------------------

  double xFor(int copy, PrePrintedFieldPlacement placement) =>
      copyOriginX(copy) + placement.column * charWidth;

  double yFor(PrePrintedFieldPlacement placement) =>
      copyOriginY + placement.line * linePitch;

  /// Width available to a field: its configured character width, or the
  /// remainder of this copy's column when no width was set.
  double widthFor(int copy, PrePrintedFieldPlacement placement) {
    final copyEnd = copyOriginX(copy) + columnWidth;
    if (placement.widthChars > 0) {
      final configured = placement.widthChars * charWidth;
      return (configured).clamp(
        0.0,
        (copyEnd - xFor(copy, placement)).clamp(0.0, columnWidth),
      );
    }
    return (copyEnd - xFor(copy, placement)).clamp(0.0, columnWidth);
  }

  /// Positions every printable value on both copies of the sheet.
  ///
  /// Both copies receive identical text from the same [data] object, so a
  /// single print operation always produces two matching records.
  List<PrePrintedPrintedText> buildPrintedTexts(PrePrintedTicketData data) {
    final texts = <PrePrintedPrintedText>[];
    final usableHeight = page.height - linePitch;

    for (final field in PrePrintedField.values) {
      final text = data.valueFor(field);
      if (text.isEmpty) continue;

      final placement = placements[field];
      if (placement == null || !placement.isPrintable) continue;

      final y = yFor(placement);
      // A line below the sheet cannot be printed; skip it instead of letting
      // the driver clip or roll the form into a blank page.
      if (y < 0 || y > usableHeight) continue;

      for (final copy in const [0, 1]) {
        final x = xFor(copy, placement);
        if (x < 0 || x > page.width) continue;
        texts.add(
          PrePrintedPrintedText(
            field: field,
            copy: copy,
            text: text,
            x: x,
            y: y,
            maxWidth: widthFor(copy, placement),
            isBold: _isBold(field),
          ),
        );
      }
    }
    return texts;
  }

  /// Fields whose placement is on-paper and whose value exists, in print order
  /// for one copy. The preview draws these alongside their pre-printed labels.
  List<PrePrintedFieldPlacement> placementOrder() => [
    for (final field in PrePrintedField.values)
      if (placements[field] != null) placements[field]!,
  ];

  /// The pre-printed label for a field, for preview purposes only.
  static String labelFor(PrePrintedField field) => field.prePrintedLabel;

  /// Paper size hinted to the Windows print dialog before the operator picks
  /// one: the configured custom size, otherwise a standard 11 x 5.5 inch
  /// continuous form.
  ///
  /// Only a hint - the operator can choose any paper in the dialog, and the
  /// layout is rebuilt from whatever the driver finally reports, so no page
  /// size is ever assumed by the printed output itself.
  static PdfPageFormat initialPaperFormat(BillingSettings settings) {
    if (settings.printPaperWidthMm > 0 && settings.printPaperLengthMm > 0) {
      return PdfPageFormat(
        settings.printPaperWidthMm * mmToPoint,
        settings.printPaperLengthMm * mmToPoint,
      );
    }
    return const PdfPageFormat(11 * 72.0, 5.5 * 72.0);
  }

  static bool _isBold(PrePrintedField field) =>
      field == PrePrintedField.vehicle ||
      field == PrePrintedField.charges ||
      field == PrePrintedField.gross ||
      field == PrePrintedField.tare ||
      field == PrePrintedField.net;

  /// True when the persisted CPI/LPI values were unusable and the layout fell
  /// back to 12 CPI / 6 LPI.
  bool get usedFallbackPitch => _cpiInvalid || _lpiInvalid;
}
