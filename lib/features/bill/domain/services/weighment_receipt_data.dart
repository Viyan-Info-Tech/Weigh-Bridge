import 'package:intl/intl.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../settings/domain/entities/billing_settings.dart';
import '../entities/weighment.dart';
import 'receipt_weight_resolver.dart';

/// Everything a weighment receipt needs to render, resolved once.
///
/// The on-screen slip ([WeighmentSlipDialog]), the Settings live preview and
/// the printed PDF ([WeighmentTicketPdfGenerator]) all build from this object,
/// so the receipt can only be designed in one place. Before this existed the
/// slip and the Settings preview each carried their own copy of the layout and
/// the two drifted apart.
class WeighmentReceiptData {
  WeighmentReceiptData({
    required this.bill,
    required this.settings,
    DateTime? printedAt,
    this.forPreview = false,
  }) : printedAt = printedAt ?? DateTime.now() {
    weights = const ReceiptWeightResolver().resolve(bill);
  }

  final Weighment bill;
  final BillingSettings settings;
  final bool forPreview;

  /// When the slip was rendered. The printed ticket stamps this, so a preview
  /// and the PDF it produces carry the same timestamp.
  final DateTime printedAt;

  /// Display weights. `null` means "not captured" and renders as `--`.
  late final ResolvedReceiptWeights weights;

  // ---------------------------------------------------------------------------
  // Visibility flags
  //
  // Each flag answers "does this section have anything to say for this bill",
  // which is why a completed bill shows every section regardless of the
  // operator's toggles: a finished ticket is a settled record, not a draft.
  // In preview mode, toggles are honored directly to show real-time changes.
  // ---------------------------------------------------------------------------

  bool get isCompleted => bill.isCompleted;

  bool get hasSerialNumber => settings.showSerialNumber;

  bool get hasVehicleNumber => settings.showVehicleNumber;

  bool get hasGrossWeight => forPreview
      ? settings.showGrossWeight &&
            (weights.grossKg != null && weights.grossKg! > 0)
      : (isCompleted ||
            settings.showGrossWeight ||
            (weights.grossKg != null && weights.grossKg! > 0));

  bool get hasTareWeight => forPreview
      ? settings.showTareWeight &&
            (weights.tareKg != null && weights.tareKg! > 0)
      : (isCompleted ||
            settings.showTareWeight ||
            (weights.tareKg != null && weights.tareKg! > 0));

  bool get hasNetWeight => forPreview
      ? settings.showNetWeight && (weights.netKg != null && weights.netKg! > 0)
      : (isCompleted ||
            settings.showNetWeight ||
            (weights.netKg != null && weights.netKg! > 0));

  bool get hasRemarks =>
      settings.showRemarks &&
      bill.remarks != null &&
      bill.remarks!.trim().isNotEmpty;

  bool get hasMaterial =>
      bill.material != null && bill.material!.trim().isNotEmpty;

  /// True when the weighment carries a manually entered charge.
  ///
  /// Legacy rows (saved before the Charges feature) have a null charge and
  /// simply omit the row rather than printing a placeholder.
  bool get hasCharges => bill.charges != null;

  /// Charges formatted as `₹ 250.50` from the shared currency formatter.
  String get chargesText => formatCharges(bill.charges);

  bool get hasFooterNote => settings.showFooterNote;

  /// The weight rows that actually carry a value.
  ///
  /// A section can be enabled and still have nothing to print - a gross-only
  /// weighment has no tare row - so the row check is separate from the flag.
  bool get showGrossRow =>
      hasGrossWeight && weights.grossKg != null && weights.grossKg! > 0;

  bool get showTareRow =>
      hasTareWeight && weights.tareKg != null && weights.tareKg! > 0;

  bool get showNetRow =>
      hasNetWeight && weights.netKg != null && weights.netKg! > 0;

  // ---------------------------------------------------------------------------
  // Letterhead
  // ---------------------------------------------------------------------------

  String get companyName => settings.businessName.isNotEmpty
      ? settings.businessName
      : 'VIYAN WEIGHBRIDGE';

  String get receiptTitle => settings.receiptTitle.trim().isNotEmpty
      ? settings.receiptTitle.trim()
      : 'Public';

  String get footerNoteText {
    final custom = settings.footerNote?.trim();
    return (custom != null && custom.isNotEmpty)
        ? custom
        : 'Please check the weight before leaving the weighbridge.';
  }

  // ---------------------------------------------------------------------------
  // Field values
  // ---------------------------------------------------------------------------

  String get vehicleNumber =>
      bill.vehicleNumber.isEmpty ? '--' : bill.vehicleNumber;

  String get materialName =>
      (bill.material == null || bill.material!.trim().isEmpty)
      ? '--'
      : bill.material!.trim();

  String get contactPhone => bill.mobileNumber ?? '';

  // ---------------------------------------------------------------------------
  // Weights
  // ---------------------------------------------------------------------------

  bool get isTon =>
      settings.weightUnit.toLowerCase() == 'ton' ||
      settings.weightUnit.toLowerCase() == 'tonne';

  String get weightUnit => isTon ? 'ton' : 'kg';

  int get weightDecimals => isTon ? 3 : 0;

  String formatWeight(double? kg) {
    if (kg == null) return '--';
    final display = isTon ? kg / 1000 : kg;
    return '${display.toStringAsFixed(weightDecimals)} $weightUnit';
  }

  String get grossDate =>
      _dateFor(weights.grossKg, bill.grossCapturedAt, bill.createdAt);

  String get grossTime =>
      _timeFor(weights.grossKg, bill.grossCapturedAt, bill.createdAt);

  String get tareDate =>
      _dateFor(weights.tareKg, bill.tareCapturedAt, bill.createdAt);

  String get tareTime =>
      _timeFor(weights.tareKg, bill.tareCapturedAt, bill.updatedAt);

  String _dateFor(double? kg, DateTime? capturedAt, DateTime fallback) {
    if (kg == null) return '--';
    return DateFormat('dd/MM/yyyy').format(capturedAt ?? fallback);
  }

  String _timeFor(double? kg, DateTime? capturedAt, DateTime fallback) {
    if (kg == null) return '--';
    return DateFormat('HH:mm:ss').format(capturedAt ?? fallback);
  }

  String get printDate => DateFormat('dd/MM/yyyy HH:mm:ss').format(printedAt);
}
