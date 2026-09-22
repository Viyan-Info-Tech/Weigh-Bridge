import 'package:flutter_test/flutter_test.dart';
import 'package:weighbridge/features/auth/domain/entities/user.dart';

void main() {
  group('User entity', () {
    late User user;

    setUp(() {
      user = User(
        id: 1,
        username: 'admin',
        role: 'admin',
        isActive: true,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 6, 1),
      );
    });

    group('equality', () {
      test('two users with same props are equal', () {
        final other = User(
          id: 1,
          username: 'admin',
          role: 'admin',
          isActive: true,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 6, 1),
        );

        expect(user, equals(other));
      });

      test('two users with different id are not equal', () {
        final other = user.copyWith(id: 2);
        expect(user, isNot(equals(other)));
      });

      test('two users with different username are not equal', () {
        final other = user.copyWith(username: 'operator');
        expect(user, isNot(equals(other)));
      });

      test('two users with different role are not equal', () {
        final other = user.copyWith(role: 'operator');
        expect(user, isNot(equals(other)));
      });

      test('two users with different isActive are not equal', () {
        final other = user.copyWith(isActive: false);
        expect(user, isNot(equals(other)));
      });

      test('two users with different createdAt are not equal', () {
        final other = user.copyWith(createdAt: DateTime(2025, 1, 1));
        expect(user, isNot(equals(other)));
      });

      test('two users with different updatedAt are not equal', () {
        final other = user.copyWith(updatedAt: DateTime(2025, 6, 1));
        expect(user, isNot(equals(other)));
      });

      test('user is a User instance', () {
        expect(user, isA<User>());
      });
    });

    group('copyWith', () {
      test('returns same user when no fields are changed', () {
        final copied = user.copyWith();
        expect(copied, equals(user));
      });

      test('copyWith updates id', () {
        final copied = user.copyWith(id: 42);
        expect(copied.id, 42);
        expect(copied.username, user.username);
        expect(copied.role, user.role);
        expect(copied.isActive, user.isActive);
        expect(copied.createdAt, user.createdAt);
        expect(copied.updatedAt, user.updatedAt);
      });

      test('copyWith updates username', () {
        final copied = user.copyWith(username: 'operator');
        expect(copied.username, 'operator');
        expect(copied.id, user.id);
      });

      test('copyWith updates role', () {
        final copied = user.copyWith(role: 'operator');
        expect(copied.role, 'operator');
        expect(copied.id, user.id);
      });

      test('copyWith updates isActive', () {
        final copied = user.copyWith(isActive: false);
        expect(copied.isActive, isFalse);
        expect(copied.id, user.id);
      });

      test('copyWith updates createdAt', () {
        final newDate = DateTime(2025, 3, 15);
        final copied = user.copyWith(createdAt: newDate);
        expect(copied.createdAt, newDate);
        expect(copied.updatedAt, user.updatedAt);
      });

      test('copyWith updates updatedAt', () {
        final newDate = DateTime(2025, 9, 1);
        final copied = user.copyWith(updatedAt: newDate);
        expect(copied.updatedAt, newDate);
        expect(copied.createdAt, user.createdAt);
      });

      test('copyWith updates multiple fields at once', () {
        final copied = user.copyWith(
          username: 'operator',
          role: 'user',
          isActive: false,
        );
        expect(copied.username, 'operator');
        expect(copied.role, 'user');
        expect(copied.isActive, isFalse);
        expect(copied.id, user.id);
      });

      test('copyWith with null username returns original username', () {
        final copied = user.copyWith(username: null);
        expect(copied.username, user.username);
      });
    });

    group('props', () {
      test('props list contains all fields', () {
        expect(
          user.props,
          equals([
            user.id,
            user.username,
            user.role,
            user.isActive,
            user.createdAt,
            user.updatedAt,
          ]),
        );
      });
    });
  });
}
