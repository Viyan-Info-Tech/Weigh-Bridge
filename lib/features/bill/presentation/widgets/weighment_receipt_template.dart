import 'package:flutter/material.dart';

import '../../domain/services/weighment_receipt_data.dart';

/// The dot-matrix weighment slip, drawn from a [WeighmentReceiptData].
///
/// This is the single visual implementation of the receipt. The ticket dialog,
/// the Settings live preview and the printed PDF all render from the same
/// [WeighmentReceiptData], so there is no second layout to forget when the
/// receipt changes.
///
/// The layout is fixed-width by design - a slip printer has one paper width -
/// but it degrades gracefully: below [compactWidth] the gutters, label column
/// and type size all step down so a narrow thermal preview still fits.
class WeighmentReceiptTemplate extends StatelessWidget {
  const WeighmentReceiptTemplate({super.key, required this.data});

  final WeighmentReceiptData data;

  /// Below this width the slip switches to its compact metrics.
  static const double compactWidth = 340;

  static const TextStyle _mono = TextStyle(
    fontFamily: 'Courier',
    fontSize: 13,
    color: Colors.black,
  );

  static const TextStyle _monoBold = TextStyle(
    fontFamily: 'Courier',
    fontSize: 13,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 420.0;
        final compact = available < compactWidth;

        final horizontalPadding = compact ? 12.0 : 36.0;
        final verticalPadding = compact ? 14.0 : 32.0;
        final labelWidth = compact ? 92.0 : 130.0;
        final tableLabelWidth = compact ? 65.0 : 100.0;
        final baseFontSize = compact ? 10.5 : 13.0;
        final titleFontSize = compact ? 11.0 : 13.5;
        final companyFontSize = compact ? 13.0 : 16.0;

        final mono = _mono.copyWith(fontSize: baseFontSize);
        final monoBold = _monoBold.copyWith(fontSize: baseFontSize);
        final companyStyle = monoBold.copyWith(
          fontSize: companyFontSize,
          letterSpacing: 0.5,
        );
        final titleStyle = monoBold.copyWith(fontSize: titleFontSize);
        final fieldLabelStyle = monoBold.copyWith(fontSize: baseFontSize);
        final fieldValueStyle = mono.copyWith(fontSize: baseFontSize);
        final fieldValueBoldStyle = monoBold.copyWith(fontSize: baseFontSize);
        final tableHeaderStyle = monoBold.copyWith(fontSize: baseFontSize);
        final tableCellStyle = mono.copyWith(fontSize: baseFontSize);
        final tableCellBoldStyle = monoBold.copyWith(fontSize: baseFontSize);
        final dashedStyle = mono.copyWith(
          fontSize: baseFontSize,
          letterSpacing: -0.2,
        );
        final noteStyle = mono.copyWith(fontSize: baseFontSize - 2);
        final timestampStyle = mono.copyWith(
          fontSize: baseFontSize - 2,
          color: Colors.grey.shade600,
        );

        return Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Company letterhead (centered)
              Center(
                child: Column(
                  children: [
                    Text(
                      data.companyName.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: companyStyle,
                    ),
                    if (data.settings.businessSubtitle != null &&
                        data.settings.businessSubtitle!.trim().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        data.settings.businessSubtitle!,
                        textAlign: TextAlign.center,
                        style: mono.copyWith(fontSize: baseFontSize - 1),
                      ),
                    ],
                    if (data.settings.serviceText != null &&
                        data.settings.serviceText!.trim().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        data.settings.serviceText!,
                        textAlign: TextAlign.center,
                        style: monoBold.copyWith(
                          fontSize: baseFontSize - 1.5,
                        ),
                      ),
                    ],
                    if (data.settings.address != null &&
                        data.settings.address!.trim().isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        data.settings.address!,
                        textAlign: TextAlign.center,
                        style: mono.copyWith(fontSize: baseFontSize - 1.5),
                      ),
                    ],
                    if (_hasContactLine) ...[
                      const SizedBox(height: 2),
                      Text(
                        _contactLine,
                        textAlign: TextAlign.center,
                        style: mono.copyWith(fontSize: baseFontSize - 1.5),
                      ),
                    ],
                  ],
                ),
              ),

              SizedBox(height: compact ? 12 : 22),

              // 2. Receipt title
              Text(data.receiptTitle, style: titleStyle),

              SizedBox(height: compact ? 8 : 12),

              // 3. Metadata fields, colons vertically aligned
              if (data.hasSerialNumber)
                _buildFieldRow(
                  'TOKEN NO',
                  data.bill.billNumber,
                  labelWidth: labelWidth,
                  labelStyle: fieldLabelStyle,
                  valueStyle: fieldValueStyle,
                ),
              if (data.hasVehicleNumber)
                _buildFieldRow(
                  'VEHICLE NO',
                  data.vehicleNumber,
                  labelWidth: labelWidth,
                  labelStyle: fieldLabelStyle,
                  valueStyle: fieldValueBoldStyle,
                ),
              if (data.hasCustomer)
                _buildFieldRow(
                  'DESCRIPTION',
                  data.customerName,
                  labelWidth: labelWidth,
                  labelStyle: fieldLabelStyle,
                  valueStyle: fieldValueStyle,
                ),
              if (data.hasMaterial)
                _buildFieldRow(
                  'PRODUCT',
                  data.resolvedMaterialName,
                  labelWidth: labelWidth,
                  labelStyle: fieldLabelStyle,
                  valueStyle: fieldValueStyle,
                ),
              if (data.customerPhone.isNotEmpty)
                _buildFieldRow(
                  'MOBILE NO',
                  data.customerPhone,
                  labelWidth: labelWidth,
                  labelStyle: fieldLabelStyle,
                  valueStyle: fieldValueStyle,
                ),
              if (data.hasRemarks)
                _buildFieldRow(
                  'CONTAINER No',
                  data.bill.remarks!,
                  labelWidth: labelWidth,
                  labelStyle: fieldLabelStyle,
                  valueStyle: fieldValueStyle,
                ),

              SizedBox(height: compact ? 6 : 10),

              // 4. Dashed line above the weight table
              _buildDashedLine(dashedStyle),

              // 5. Weight table header
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(width: tableLabelWidth),
                    Expanded(
                      flex: 3,
                      child: Text(
                        'WEIGHT',
                        textAlign: TextAlign.center,
                        style: tableHeaderStyle,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        'DATE',
                        textAlign: TextAlign.center,
                        style: tableHeaderStyle,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        'TIME',
                        textAlign: TextAlign.center,
                        style: tableHeaderStyle,
                      ),
                    ),
                  ],
                ),
              ),

              // 6. Dashed line below the header
              _buildDashedLine(dashedStyle),

              // 7. Weight rows
              if (data.showGrossRow)
                _buildWeightRow(
                  label: 'GROSS',
                  weight: data.formatWeight(data.weights.grossKg),
                  date: data.grossDate,
                  time: data.grossTime,
                  labelWidth: tableLabelWidth,
                  labelStyle: fieldLabelStyle,
                  valueStyle: tableCellBoldStyle,
                  textStyle: tableCellStyle,
                ),
              if (data.showTareRow)
                _buildWeightRow(
                  label: 'TARE',
                  weight: data.formatWeight(data.weights.tareKg),
                  date: data.tareDate,
                  time: data.tareTime,
                  labelWidth: tableLabelWidth,
                  labelStyle: fieldLabelStyle,
                  valueStyle: tableCellBoldStyle,
                  textStyle: tableCellStyle,
                ),
              if (data.showNetRow)
                _buildWeightRow(
                  label: 'NET',
                  weight: data.formatWeight(data.weights.netKg),
                  date: '--',
                  time: '--',
                  labelWidth: tableLabelWidth,
                  labelStyle: fieldLabelStyle,
                  valueStyle: tableCellBoldStyle,
                  textStyle: tableCellStyle,
                ),

              // 8. Dashed line below the table
              _buildDashedLine(dashedStyle),

              // 9. Financials
              if (data.hasAmount || data.hasPaymentMode) ...[
                SizedBox(height: compact ? 4 : 8),
                Row(
                  children: [
                    if (data.hasAmount)
                      Text(
                        'CHARGES (Rs.) : ${data.bill.amount.toStringAsFixed(2)}',
                        style: monoBold.copyWith(fontSize: baseFontSize),
                      ),
                    const Spacer(),
                    if (data.hasPaymentMode)
                      Text(
                        'PAYMENT MODE : ${data.bill.paymentMode.toUpperCase()}',
                        style: monoBold.copyWith(fontSize: baseFontSize),
                      ),
                  ],
                ),
              ],

              // 10. Footer note
              if (data.hasFooterNote) ...[
                SizedBox(height: compact ? 8 : 12),
                Text(
                  'Note: ${data.footerNoteText}',
                  style: noteStyle,
                ),
              ],

              SizedBox(height: compact ? 14 : 28),

              // 11. Print timestamp
              Center(
                child: Text(
                  '* Printed on: ${data.printDate} *',
                  style: timestampStyle,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool get _hasContactLine =>
      (data.settings.phoneNumber != null &&
          data.settings.phoneNumber!.trim().isNotEmpty) ||
      (data.settings.email != null && data.settings.email!.trim().isNotEmpty) ||
      (data.settings.gstin != null && data.settings.gstin!.trim().isNotEmpty);

  String get _contactLine => [
    if (data.settings.phoneNumber != null &&
        data.settings.phoneNumber!.trim().isNotEmpty)
      'Tel: ${data.settings.phoneNumber!}',
    if (data.settings.email != null && data.settings.email!.trim().isNotEmpty)
      'E-Mail: ${data.settings.email!}',
    if (data.settings.gstin != null && data.settings.gstin!.trim().isNotEmpty)
      'GSTIN: ${data.settings.gstin!}',
  ].join('   ');

  Widget _buildFieldRow(
    String label,
    String value, {
    required double labelWidth,
    required TextStyle labelStyle,
    required TextStyle valueStyle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: labelWidth, child: Text(label, style: labelStyle)),
          Text(': ', style: labelStyle),
          Expanded(child: Text(value, style: valueStyle)),
        ],
      ),
    );
  }

  Widget _buildDashedLine(TextStyle style) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SizedBox(
        width: double.infinity,
        height: 2,
        child: CustomPaint(
          painter: _DashedLinePainter(
            color: style.color ?? Colors.black,
            strokeWidth: 1.0,
            dashWidth: 4.5,
            dashSpace: 3.0,
          ),
        ),
      ),
    );
  }

  Widget _buildWeightRow({
    required String label,
    required String weight,
    required String date,
    required String time,
    required double labelWidth,
    required TextStyle labelStyle,
    required TextStyle valueStyle,
    required TextStyle textStyle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: Row(
        children: [
          SizedBox(width: labelWidth, child: Text(label, style: labelStyle)),
          Expanded(
            flex: 3,
            child: Text(weight, textAlign: TextAlign.center, style: valueStyle),
          ),
          Expanded(
            flex: 3,
            child: Text(date, textAlign: TextAlign.center, style: textStyle),
          ),
          Expanded(
            flex: 3,
            child: Text(time, textAlign: TextAlign.center, style: textStyle),
          ),
        ],
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  const _DashedLinePainter({
    this.color = Colors.black,
    this.strokeWidth = 1.0,
    this.dashWidth = 4.5,
    this.dashSpace = 3.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double startX = 0;
    final y = size.height / 2;
    while (startX < size.width) {
      final endX = (startX + dashWidth).clamp(0.0, size.width);
      canvas.drawLine(Offset(startX, y), Offset(endX, y), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter oldDelegate) =>
      color != oldDelegate.color ||
      strokeWidth != oldDelegate.strokeWidth ||
      dashWidth != oldDelegate.dashWidth ||
      dashSpace != oldDelegate.dashSpace;
}
