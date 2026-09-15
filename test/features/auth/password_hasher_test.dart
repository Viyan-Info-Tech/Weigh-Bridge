import 'package:flutter_test/flutter_test.dart';
import 'package:weighbridge/core/security/password_hasher.dart';

void main() {
  group('PasswordHasher', () {
    late PasswordHasher hasher;

    setUp(() {
      hasher = PasswordHasher();
    });

    test('hashPassword returns a valid hash string', () {
      final hash = hasher.hashPassword('Admin@123');

      expect(hash, isNotEmpty);
      expect(hash.contains(':'), isTrue);
      expect(hash.contains('\$'), isTrue);
    });

    test(
      'hashPassword returns different hashes for same password (different salts)',
      () {
        final hash1 = hasher.hashPassword('Admin@123');
        final hash2 = hasher.hashPassword('Admin@123');

        expect(hash1, isNot(equals(hash2)));
      },
    );

    test('verifyPassword returns true for correct password', () {
      final hash = hasher.hashPassword('Admin@123');
      final result = hasher.verifyPassword('Admin@123', hash);

      expect(result, isTrue);
    });

    test('verifyPassword returns false for wrong password', () {
      final hash = hasher.hashPassword('Admin@123');
      final result = hasher.verifyPassword('WrongPassword', hash);

      expect(result, isFalse);
    });

    test('verifyPassword returns false for empty password', () {
      final hash = hasher.hashPassword('Admin@123');
      final result = hasher.verifyPassword('', hash);

      expect(result, isFalse);
    });

    test('verifyPassword returns false for malformed hash', () {
      final result = hasher.verifyPassword('Admin@123', 'not-a-valid-hash');

      expect(result, isFalse);
    });

    test('verifyPassword handles different passwords correctly', () {
      final hash = hasher.hashPassword('Admin@123');

      expect(hasher.verifyPassword('Admin@123', hash), isTrue);
      expect(hasher.verifyPassword('admin@123', hash), isFalse);
      expect(hasher.verifyPassword('Admin@1234', hash), isFalse);
      expect(hasher.verifyPassword(' Admin@123', hash), isFalse);
    });
  });
}
