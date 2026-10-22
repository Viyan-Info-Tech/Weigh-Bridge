import 'package:intl/intl.dart';

/// Currency symbol used for weighment charges. The application bills in INR.
const String currencySymbol = '₹';

/// Placeholder shown where no charge value exists (older records, previews).
const String noChargesPlaceholder = '—';

/// Single source of truth for how the manual Charges amount is rendered.
///
/// Every surface (form validation messages, the weighment slip, the printed
/// ticket, the report table, report totals, exports and the details dialog)
/// formats through here, so a saved amount can never appear as `250.5` in one
/// place and `₹ 250.50` in another.
///
/// Amounts use the `en_IN` locale with a fixed two-decimal pattern, e.g.
/// `₹ 250.50`. (Grouping follows whatever the bundled `intl` build renders
/// for that locale; the two-decimal value is what every surface guarantees.)
final NumberFormat chargesAmountFormat = NumberFormat('#,##0.00', 'en_IN');

/// The number only, e.g. `250.50`. Used where the surrounding layout adds its
/// own symbol or where a bare number is wanted (CSV cells).
String formatChargesAmount(double? charges) =>
    chargesAmountFormat.format(charges ?? 0);

/// `₹ 250.50` for a stored amount, or the em-dash placeholder when the
/// weighment has no charge (records saved before the Charges feature).
String formatCharges(double? charges) => charges == null
    ? noChargesPlaceholder
    : '$currencySymbol ${formatChargesAmount(charges)}';

/// Parses operator-typed charges text into a stored amount.
///
/// Returns `null` for an empty value (no charge entered) and for anything that
/// is not a non-negative amount with at most two decimal places, so invalid
/// input can never be persisted.
double? parseChargesInput(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return null;
  if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(trimmed)) return null;
  return double.tryParse(trimmed);
}
