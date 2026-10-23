import 'package:flutter_test/flutter_test.dart';
import 'package:weighbridge/core/utils/text_formatters.dart';

void main() {
  group('validateVehicleNumber', () {
    test('accepts valid Indian registration numbers', () {
      const validNumbers = [
        'TN31HS8090',
        'TN01A1234',
        'KA05MK1234',
        'KL07AB1234',
        'MH12DE3456',
        'AP39BC1234',
        // Spaced formats operators actually type; validation normalises
        // instead of rejecting the spaces.
        'TN 31 HS 8090',
        'TN 30 EN 3000',
        'KL 07 AB 1234',
        '  TN31HS8090  ',
        'tn 31 hs 8090',
      ];

      for (final number in validNumbers) {
        expect(validateVehicleNumber(number), isNull, reason: number);
      }
    });

    test('rejects empty, malformed, long, and invalid-state values', () {
      const invalidNumbers = [
        '',
        'ASDFGHK345678234567890SXCVBNM',
        'TN123456789999',
        'TN@31HS8090',
        'TN @31 HS8090',
        '1234567890',
        'ABC',
        'XX31HS8090',
        'XX 31 HS 8090',
      ];

      for (final number in invalidNumbers) {
        expect(validateVehicleNumber(number), isNotNull, reason: number);
      }
    });
  });

  group('normalizeVehicleNumber', () {
    test('strips every whitespace and upper-cases', () {
      expect(normalizeVehicleNumber('TN 30 EN 3000'), 'TN30EN3000');
      expect(normalizeVehicleNumber('  tn31hs8090  '), 'TN31HS8090');
      expect(normalizeVehicleNumber('TN\t31\tHS\t8090'), 'TN31HS8090');
      expect(normalizeVehicleNumber(''), '');
    });
  });

  group('validateIndianMobileNumber', () {
    test('accepts 10 digit Indian mobile numbers starting with 6 to 9', () {
      const validNumbers = [
        '9876543210',
        '9876543211',
        '8123456789',
        '7012345678',
      ];

      for (final number in validNumbers) {
        expect(validateIndianMobileNumber(number), isNull, reason: number);
      }
    });

    test('rejects empty, short, long, non-digit, and bad-prefix values', () {
      const invalidNumbers = [
        '',
        '987654321111111111111111',
        '1234567890',
        '5123456789',
        '987654321',
        '98765432101',
        '98765ABCDE0',
        '+919876543210',
      ];

      for (final number in invalidNumbers) {
        expect(validateIndianMobileNumber(number), isNotNull, reason: number);
      }
    });
  });
}
