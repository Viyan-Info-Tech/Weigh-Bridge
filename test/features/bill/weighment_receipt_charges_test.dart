import 'package:flutter_test/flutter_test.dart';
import 'package:weighbridge/features/bill/domain/entities/weighment.dart';
import 'package:weighbridge/features/bill/domain/services/weighment_receipt_data.dart';
import 'package:weighbridge/features/settings/domain/entities/billing_settings.dart';

/// The receipt shows the charge exactly as it was saved on the bill. A
/// reprint re-renders this same object, so a printed ticket can never
/// disagree with the amount stored in the database.
void main() {
  final settings = BillingSettings(updatedAt: DateTime(2026));

  Weighment bill({double? charges}) {
    final now = DateTime(2026, 9, 10, 16, 27);
    return Weighment(
      id: 1,
      billNumber: 'WB-00001',
      vehicleNumber: 'TN31CM2026',
      grossWeightKg: 100000,
      tareWeightKg: 20000,
      netWeightKg: 80000,
      charges: charges,
      createdAt: now,
      updatedAt: now,
    );
  }

  test('a saved charge is shown as ₹ with two decimals', () {
    final data = WeighmentReceiptData(
      bill: bill(charges: 250.50),
      settings: settings,
    );
    expect(data.hasCharges, isTrue);
    expect(data.chargesText, '₹ 250.50');
  });

  test('a zero charge is still shown (₹ 0.00), not hidden', () {
    final data = WeighmentReceiptData(
      bill: bill(charges: 0),
      settings: settings,
    );
    expect(data.hasCharges, isTrue);
    expect(data.chargesText, '₹ 0.00');
  });

  test('legacy bills without a charge hide the row entirely', () {
    final data = WeighmentReceiptData(bill: bill(), settings: settings);
    expect(data.hasCharges, isFalse);
  });

  test('the amount is never recalculated from the weights', () {
    // 100t gross, 20t tare: a stored charge that has nothing to do with the
    // weights must survive untouched.
    final data = WeighmentReceiptData(
      bill: bill(charges: 1234.56),
      settings: settings,
    );
    expect(data.chargesText, '₹ 1,234.56');
  });
}
