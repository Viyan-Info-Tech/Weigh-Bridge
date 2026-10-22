import 'package:flutter_test/flutter_test.dart';
import 'package:weighbridge/core/utils/currency_formatter.dart';

void main() {
  group('formatCharges', () {
    test('renders a stored amount as rupees with two decimals', () {
      expect(formatCharges(250), '₹ 250.00');
      expect(formatCharges(250.50), '₹ 250.50');
      expect(formatCharges(1000), '₹ 1,000.00');
    });

    test('formats large amounts with the locale grouping', () {
      // The exact grouping is whatever the bundled intl renders for en_IN;
      // the guarantee is a two-decimal rupee amount.
      expect(formatCharges(150000), '₹ 150,000.00');
    });

    test('renders a zero charge as ₹ 0.00 (zero is a real value)', () {
      expect(formatCharges(0), '₹ 0.00');
    });

    test('renders a missing charge as the placeholder', () {
      expect(formatCharges(null), '—');
    });
  });

  group('formatChargesAmount', () {
    test('renders the number only', () {
      expect(formatChargesAmount(250.50), '250.50');
      expect(formatChargesAmount(null), '0.00');
    });
  });

  group('parseChargesInput', () {
    test('parses whole and decimal amounts', () {
      expect(parseChargesInput('150'), 150);
      expect(parseChargesInput('250.50'), 250.50);
      expect(parseChargesInput('1000.00'), 1000);
      expect(parseChargesInput('0'), 0);
    });

    test('trims surrounding whitespace', () {
      expect(parseChargesInput('  250  '), 250);
    });

    test('returns null for an empty value', () {
      expect(parseChargesInput(''), isNull);
      expect(parseChargesInput('   '), isNull);
    });

    test('rejects more than two decimal places', () {
      expect(parseChargesInput('250.555'), isNull);
    });

    test('rejects negative amounts', () {
      expect(parseChargesInput('-100'), isNull);
    });

    test('rejects letters and other symbols', () {
      expect(parseChargesInput('abc'), isNull);
      expect(parseChargesInput('₹100'), isNull);
      expect(parseChargesInput('1e3'), isNull);
    });

    test('rejects a bare or trailing-dot decimal point', () {
      expect(parseChargesInput('.'), isNull);
      expect(parseChargesInput('250.'), isNull);
      expect(parseChargesInput('250.5.'), isNull);
    });

    test('rejects multiple decimal points', () {
      expect(parseChargesInput('2.50.5'), isNull);
    });
  });

  test('parse and format round-trip through the same source', () {
    const typed = '250.50';
    final parsed = parseChargesInput(typed)!;
    expect(formatCharges(parsed), '₹ 250.50');
  });
}
