import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../settings/domain/entities/billing_settings.dart';
import '../../domain/entities/weighment.dart';
import '../../domain/services/preprinted_ticket_layout.dart';

/// On-screen preview of the weighment slip: a single, centered white receipt
/// card styled for the screen - red business branding, red title banner, an
/// aligned weighment-details block with dashed separators, a light red
/// advisory note and a red footer strip.
///
/// This widget is presentation only. The print job is still built by
/// `PrePrintedTicketPdfGenerator` from `PrePrintedTicketLayout` and keeps
/// placing two identical copies on one sheet, so nothing drawn here can change
/// what reaches the paper. Every value is resolved by [PrePrintedTicketData] -
/// the same object the printer uses - so the preview can never disagree with
/// the printed ticket.
///
/// Fields follow the configured character grid (Settings ▸ Continuous Form
/// Printing): printable fields are grouped by grid line and drawn in column
/// order, which on the default grid reads - SERIAL NO. / DATE / TIME, VEHICLE
/// NO., WT. CHARGES (Rs.), MATERIAL, GROSS, TARE, Nett, CUSTOMER.
class WeighmentSlipPreview extends StatelessWidget {
  const WeighmentSlipPreview({
    super.key,
    required this.bill,
    required this.settings,
  });

  final Weighment bill;
  final BillingSettings settings;

  /// Design width of the single receipt card in logical pixels.
  ///
  /// The card keeps the square proportion of one copy on the 11 x 5.5 in
  /// continuous form (5.5 x 5.5 in), so scaling it with the window preserves
  /// the ticket's aspect ratio.
  static const double ticketDesignWidth = 440;

  /// The sheet is never scaled below this fraction of its design width; past
  /// it the preview scrolls horizontally instead of shrinking the text into
  /// something unreadable.
  static const double minReadableScale = 0.8;

  /// Fields the dot-matrix job prints in bold, so the preview matches the ink
  /// weight the operator will see on paper.
  static const Set<PrePrintedField> _boldFields = {
    PrePrintedField.vehicle,
    PrePrintedField.charges,
    PrePrintedField.gross,
    PrePrintedField.tare,
    PrePrintedField.net,
  };

  @override
  Widget build(BuildContext context) {
    final data = PrePrintedTicketData(bill: bill, settings: settings);
    final lines = _fieldLines(decodePrePrintedGrid(settings.printFieldGrid));
    final page = PrePrintedTicketLayout.initialPaperFormat(settings);

    // One receipt = half the sheet: 5.5 x 5.5 in on the 11 x 5.5 in form, so
    // the preview keeps the printed copy's square proportion.
    final minHeight = ticketDesignWidth * 2 * page.height / page.width;

    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : ticketDesignWidth;
        final receipt = _buildReceipt(data, lines, minHeight);

        // The receipt stays centered and keeps its aspect ratio; it scales
        // down with the window until the readable floor, then the preview
        // area scrolls instead of shrinking the text further.
        if (available >= ticketDesignWidth) {
          return Center(child: receipt);
        }
        if (available >= ticketDesignWidth * minReadableScale) {
          return Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.topCenter,
              child: receipt,
            ),
          );
        }
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: receipt,
        );
      },
    );
  }

  /// Printable fields grouped into the ticket's rows: one row per grid line,
  /// fields inside a row ordered by their configured column.
  static List<List<PrePrintedField>> _fieldLines(
    Map<PrePrintedField, PrePrintedFieldPlacement> placements,
  ) {
    final byLine = <int, List<PrePrintedField>>{};
    for (final field in PrePrintedField.values) {
      final placement = placements[field];
      if (placement == null || !placement.isPrintable) continue;
      byLine.putIfAbsent(placement.line, () => <PrePrintedField>[]).add(field);
    }

    final lines = <List<PrePrintedField>>[];
    for (final line in byLine.keys.toList()..sort()) {
      final fields = byLine[line]!
        ..sort(
          (a, b) => placements[a]!.column.compareTo(placements[b]!.column),
        );
      lines.add(fields);
    }
    return lines;
  }

  /// The single receipt: paper edge, border and shadow drawn around one copy
  /// of the ticket - no duplicate copy, no cut line between copies.
  Widget _buildReceipt(
    PrePrintedTicketData data,
    List<List<PrePrintedField>> lines,
    double minHeight,
  ) {
    return Container(
      width: ticketDesignWidth,
      constraints: BoxConstraints(minHeight: minHeight),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF94A3B8), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      // IntrinsicHeight gives the ticket column a definite height (the sheet's
      // half-sheet proportion, floored by minHeight), which is what lets the
      // footer Spacer fill the spare height inside a vertically scrolling
      // dialog, exactly as the two-up sheet did.
      child: IntrinsicHeight(
        child: _TicketCopy(data: data, lines: lines),
      ),
    );
  }
}

/// On-screen receipt card: one receipt, styled for the preview (red
/// branding, red title banner, advisory note and footer strip) while still
/// rendering the same [PrePrintedTicketData] the print job uses for each of
/// its two printed copies.
class _TicketCopy extends StatelessWidget {
  const _TicketCopy({required this.data, required this.lines});

  final PrePrintedTicketData data;
  final List<List<PrePrintedField>> lines;

  /// Brand red used for the business name, the title banner and the footer
  /// strip, matching the reference preview design.
  static const Color _brandRed = Color(0xFFDC2626);

  static const TextStyle _body = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 11,
    height: 1.35,
    color: Color(0xFF111827),
  );

  @override
  Widget build(BuildContext context) {
    final settings = data.settings;
    final labelStyle = _body.copyWith(fontWeight: FontWeight.w700);
    final valueStyle = _body;
    final labelWidth = _labelColumnWidth(labelStyle);
    final title = settings.receiptTitle.trim();
    final footerNote = _footerNote(settings);

    // Horizontal inset shared by every section except the edge-to-edge
    // footer strip.
    const inset = EdgeInsets.symmetric(horizontal: 16);

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            // ── Letterhead: phones, red branding, tagline, service ──
            child: _letterhead(settings),
          ),

          // ── Red title banner: WEIGHMENT RECEIPT ──
          if (title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: const BoxDecoration(
                  color: _brandRed,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: _body.copyWith(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _DashedRule(),
                const SizedBox(height: 4),

                // ── Weighment details, aligned label column ──────
                for (final fields in lines)
                  if (fields.length == 1)
                    _labelValueRow(
                      fields.single,
                      labelWidth: labelWidth,
                      labelStyle: labelStyle,
                      valueStyle: valueStyle,
                    )
                  else
                    _inlineRow(
                      fields,
                      labelStyle: labelStyle,
                      valueStyle: valueStyle,
                    ),

                const SizedBox(height: 6),
                const _DashedRule(),
              ],
            ),
          ),

          // Any spare sheet height becomes one gap above the footer, so the
          // card keeps its proportions without rows drifting apart.
          const Spacer(),

          // ── Light red advisory section ───────────────────────
          if (footerNote.isNotEmpty)
            Padding(
              padding: inset.copyWith(bottom: 10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Text(
                  'Note: $footerNote',
                  textAlign: TextAlign.center,
                  style: _body.copyWith(
                    fontSize: 9.5,
                    height: 1.3,
                    color: const Color(0xFF991B1B),
                  ),
                ),
              ),
            ),

          // ── Red footer strip: THANK YOU! / 24x7 SERVICE / DRIVE SAFE! ──
          footerStrip(),
        ],
      ),
    );
  }

  /// Red footer strip closing the receipt card, edge to edge.
  static Widget footerStrip() {
    const textStyle = TextStyle(
      fontFamily: 'PlusJakartaSans',
      fontSize: 9.5,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.6,
      color: Colors.white,
    );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 14),
      decoration: const BoxDecoration(
        color: _brandRed,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(4)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('THANK YOU!', style: textStyle),
          Text('24x7 SERVICE', style: textStyle),
          Text('DRIVE SAFE!', style: textStyle),
        ],
      ),
    );
  }

  /// Letterhead from the configured business branding: phone numbers first,
  /// then the logo (when configured), the business name in brand red, the
  /// tagline, the service line and the address/contact details.
  Widget _letterhead(BillingSettings settings) {
    final logoPath = settings.logoPath?.trim() ?? '';
    final phone = settings.phoneNumber?.trim() ?? '';
    final contact = [
      if (phone.isNotEmpty) 'Tel: $phone',
      if (settings.email != null && settings.email!.trim().isNotEmpty)
        'E-Mail: ${settings.email!.trim()}',
      if (settings.gstin != null && settings.gstin!.trim().isNotEmpty)
        'GSTIN: ${settings.gstin!.trim()}',
    ].join('   ');

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (phone.isNotEmpty)
            Text(
              phone,
              textAlign: TextAlign.center,
              style: _body.copyWith(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF374151),
              ),
            ),
          if (logoPath.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 4),
              child: Image.file(
                File(logoPath),
                height: 40,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            )
          else
            const SizedBox(height: 6),
          Text(
            settings.businessName.toUpperCase(),
            textAlign: TextAlign.center,
            style: _body.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: _brandRed,
            ),
          ),
          if (settings.businessSubtitle != null &&
              settings.businessSubtitle!.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                settings.businessSubtitle!.trim(),
                textAlign: TextAlign.center,
                style: _body.copyWith(fontSize: 10.5),
              ),
            ),
          if (settings.serviceText != null &&
              settings.serviceText!.trim().isNotEmpty)
            Text(
              settings.serviceText!.trim(),
              textAlign: TextAlign.center,
              style: _body.copyWith(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
                color: const Color(0xFF374151),
              ),
            ),
          if (settings.address != null && settings.address!.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                settings.address!.trim(),
                textAlign: TextAlign.center,
                style: _body.copyWith(
                  fontSize: 9.5,
                  color: const Color(0xFF475569),
                ),
              ),
            ),
          if (contact.isNotEmpty)
            Text(
              contact,
              textAlign: TextAlign.center,
              style: _body.copyWith(
                fontSize: 9.5,
                color: const Color(0xFF475569),
              ),
            ),
        ],
      ),
    );
  }

  String _footerNote(BillingSettings settings) {
    if (!settings.showFooterNote) return '';
    final configured = settings.footerNote?.trim();
    if (configured != null && configured.isNotEmpty) return configured;
    return 'Please check the weight before leaving the weighbridge.';
  }

  /// Widest single label, so every colon in the ticket lines up on one
  /// column no matter which font the platform resolves for Courier.
  double _labelColumnWidth(TextStyle labelStyle) {
    final painter = TextPainter(textDirection: TextDirection.ltr);
    var widest = 0.0;
    for (final fields in lines) {
      if (fields.length != 1) continue;
      painter.text = TextSpan(
        text: fields.single.prePrintedLabel,
        style: labelStyle,
      );
      painter.layout();
      if (painter.width > widest) widest = painter.width;
    }
    return widest + 8;
  }

  /// A row of its own: fixed label column, colon, then the value. The value
  /// is clipped with an ellipsis rather than wrapping, matching how the print
  /// job clips a value at its configured character width.
  Widget _labelValueRow(
    PrePrintedField field, {
    required double labelWidth,
    required TextStyle labelStyle,
    required TextStyle valueStyle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: labelWidth,
            child: Text(field.prePrintedLabel, style: labelStyle),
          ),
          Text(': ', style: labelStyle),
          Expanded(
            child: Text(
              data.valueFor(field),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: WeighmentSlipPreview._boldFields.contains(field)
                  ? valueStyle.copyWith(fontWeight: FontWeight.w700)
                  : valueStyle,
            ),
          ),
        ],
      ),
    );
  }

  /// Several fields sharing one grid line (SERIAL NO. / DATE / TIME): drawn
  /// side by side and scaled down as a whole when the row is wider than the
  /// ticket, so the row can never overflow the copy.
  Widget _inlineRow(
    List<PrePrintedField> fields, {
    required TextStyle labelStyle,
    required TextStyle valueStyle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < fields.length; i++) ...[
              if (i > 0) const SizedBox(width: 16),
              Text(fields[i].prePrintedLabel, style: labelStyle),
              Text(': ', style: labelStyle),
              Text(
                data.valueFor(fields[i]),
                style: WeighmentSlipPreview._boldFields.contains(fields[i])
                    ? valueStyle.copyWith(fontWeight: FontWeight.w700)
                    : valueStyle,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Dashed separator between the letterhead, the field block and the footer.
class _DashedRule extends StatelessWidget {
  const _DashedRule();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 2,
      child: CustomPaint(
        painter: const _DashedLinePainter(color: Color(0xFF94A3B8)),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  const _DashedLinePainter({required this.color});

  final Color color;

  static const double _dash = 4.0;
  static const double _gap = 3.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final y = size.height / 2;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, y),
        Offset(math.min(x + _dash, size.width), y),
        paint,
      );
      x += _dash + _gap;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter oldDelegate) =>
      oldDelegate.color != color;
}
