import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';

import '../../../settings/domain/entities/billing_settings.dart';
import '../../domain/entities/weighment.dart';
import '../../domain/services/preprinted_ticket_layout.dart';

/// On-screen preview of what a print job actually puts on the paper: the two
/// identical bill copies of one weighment, side by side, on one sheet of
/// continuous-form stationery.
///
/// Only the dynamic values are drawn in black because only the dynamic values
/// are printed. The pre-printed labels (SERIAL NO., VEHICLE NO., WT. CHARGES
/// (Rs.), MATERIAL, GROSS, TARE, Nett, CUSTOMER, DATE, TIME) are shown in grey
/// so the operator can judge alignment, with a caption making clear they are
/// part of the paper, not of the print job.
class PrePrintedTicketPreview extends StatelessWidget {
  const PrePrintedTicketPreview({
    super.key,
    required this.bill,
    required this.settings,
    this.showCaption = true,
  });

  final Weighment bill;
  final BillingSettings settings;
  final bool showCaption;

  /// Paper assumed by the preview.
  ///
  /// A custom size from Settings wins so the operator can mirror the exact
  /// sheet. Otherwise an 11 x 5.5 inch continuous form - the usual two-up
  /// weighbridge stationery - is assumed with typical dot-matrix unprintable
  /// margins.
  ///
  /// The real print uses the paper and margins the Windows driver reports in
  /// the print dialog, so this is indicative rather than a guarantee.
  static PdfPageFormat previewPaperFormat(BillingSettings settings) {
    const inch = PdfPageFormat.inch;
    final size = PrePrintedTicketLayout.initialPaperFormat(settings);
    return PdfPageFormat(
      size.width,
      size.height,
      marginLeft: 0.25 * inch,
      marginRight: 0.25 * inch,
      marginTop: 0.5 * inch,
      marginBottom: 0.5 * inch,
    );
  }

  @override
  Widget build(BuildContext context) {
    final page = previewPaperFormat(settings);
    final data = PrePrintedTicketData(bill: bill, settings: settings);
    final layout = PrePrintedTicketLayout(pageFormat: page, settings: settings);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final scale = width / page.width;
        final height = page.height * scale;
        final charWidth = layout.charWidth * scale;
        final fontSize = layout.fontSize * scale;
        final sectionHeight =
            (layout.printableHeight - settings.printTopOffsetMm * mmToPoint) *
            scale;

        final placed = <Widget>[];

        for (final field in PrePrintedField.values) {
          final placement = layout.placements[field];
          if (placement == null || !placement.isPrintable) continue;

          final value = data.valueFor(field);
          final y = layout.yFor(placement) * scale;

          for (final copy in const [0, 1]) {
            final x = layout.xFor(copy, placement) * scale;

            // The print pipeline drops values that fall off the paper edge
            // (see PrePrintedTicketLayout.buildPrintedTexts), so the preview
            // skips them too. This also keeps the width clamp below inside a
            // valid range: when a configured grid places a field past the
            // right edge, `width - x` goes negative and clamp(0.0, width - x)
            // throws.
            if (x < 0 || x > width) continue;

            final maxWidth = layout.widthFor(copy, placement) * scale;
            final label = field.prePrintedLabel;
            final labelWidth = label.length * charWidth;
            final labelLeft = x - labelWidth - charWidth;
            final labelRight = x - charWidth * 0.5;

            if (labelRight > 0 && labelLeft < width) {
              placed.add(
                Positioned(
                  left: labelLeft < layout.copyOriginX(copy) * scale
                      ? layout.copyOriginX(copy) * scale
                      : labelLeft,
                  top: y,
                  width: (labelRight - labelLeft).clamp(0.0, width),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontSize: fontSize,
                      height: 1,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ),
              );
            }

            placed.add(
              Positioned(
                left: x,
                top: y,
                width: maxWidth.clamp(0.0, width - x),
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  softWrap: false,
                  style: TextStyle(
                    fontFamily: 'Courier',
                    fontSize: layout.fontSizeFor(placement) * scale,
                    height: 1,
                    fontWeight: placement.isBold
                        ? FontWeight.w700
                        : FontWeight.w400,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
            );
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: height,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  // Printable area of the assumed paper.
                  Positioned(
                    left: layout.printableLeft * scale,
                    top: layout.printableTop * scale,
                    width: layout.printableWidth * scale,
                    height: layout.printableHeight * scale,
                    child: CustomPaint(
                      painter: _DashRectPainter(color: const Color(0xFFE2E8F0)),
                    ),
                  ),
                  // The two bill sections, side by side on one row.
                  for (final copy in const [0, 1])
                    Positioned(
                      left: layout.copyOriginX(copy) * scale,
                      top: layout.copyOriginY * scale,
                      width: layout.columnWidth * scale,
                      height: sectionHeight,
                      child: CustomPaint(
                        painter: _DashRectPainter(
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                  ...placed,
                ],
              ),
            ),
            if (showCaption) ...[
              const SizedBox(height: 8),
              Text(
                'Grey labels are already printed on the paper - the app prints '
                'only the black values. Both copies are identical and print on '
                'one sheet in a single job.',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 11,
                  height: 1.4,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _DashRectPainter extends CustomPainter {
  const _DashRectPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const dashWidth = 5.0;
    const dashSpace = 4.0;
    const inset = 1.0;

    // Top and bottom.
    double x = inset;
    while (x < size.width - inset) {
      final end = (x + dashWidth).clamp(0.0, size.width - inset);
      canvas.drawLine(Offset(x, inset), Offset(end, inset), paint);
      canvas.drawLine(
        Offset(x, size.height - inset),
        Offset(end, size.height - inset),
        paint,
      );
      x += dashWidth + dashSpace;
    }

    // Left and right.
    double y = inset;
    while (y < size.height - inset) {
      final end = (y + dashWidth).clamp(0.0, size.height - inset);
      canvas.drawLine(Offset(inset, y), Offset(inset, end), paint);
      canvas.drawLine(
        Offset(size.width - inset, y),
        Offset(size.width - inset, end),
        paint,
      );
      y += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_DashRectPainter oldDelegate) =>
      oldDelegate.color != color;
}
