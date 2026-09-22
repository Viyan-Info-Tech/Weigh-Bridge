import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weighbridge/core/security/session_manager.dart';

void main() {
  late SessionManager sessionManager;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    sessionManager = SessionManager(prefs);
  });

  group('SessionManager', () {
    group('saveSession', () {
      test('saves userId, username, and role', () async {
        await sessionManager.saveSession(
          userId: 1,
          username: 'admin',
          role: 'admin',
        );

        expect(sessionManager.hasActiveSession(), isTrue);
        expect(sessionManager.getUserId(), 1);
        expect(sessionManager.getUsername(), 'admin');
        expect(sessionManager.getRole(), 'admin');
      });

      test('overwrites previous session values', () async {
        await sessionManager.saveSession(
          userId: 1,
          username: 'admin',
          role: 'admin',
        );
        await sessionManager.saveSession(
          userId: 2,
          username: 'operator',
          role: 'user',
        );

        expect(sessionManager.getUserId(), 2);
        expect(sessionManager.getUsername(), 'operator');
        expect(sessionManager.getRole(), 'user');
      });

      test('saves different types of roles', () async {
        await sessionManager.saveSession(
          userId: 3,
          username: 'viewer',
          role: 'viewer',
        );

        expect(sessionManager.getRole(), 'viewer');
        expect(sessionManager.getUserId(), 3);
      });
    });

    group('clearSession', () {
      test('removes session after clear', () async {
        await sessionManager.saveSession(
          userId: 1,
          username: 'admin',
          role: 'admin',
        );

        await sessionManager.clearSession();

        expect(sessionManager.hasActiveSession(), isFalse);
        expect(sessionManager.getUserId(), isNull);
        expect(sessionManager.getUsername(), isNull);
        expect(sessionManager.getRole(), isNull);
      });

      test('clearSession is idempotent', () async {
        await sessionManager.clearSession();
        await sessionManager.clearSession();

        expect(sessionManager.hasActiveSession(), isFalse);
      });

      test('clearSession after save then save again works', () async {
        await sessionManager.saveSession(
          userId: 1,
          username: 'admin',
          role: 'admin',
        );
        await sessionManager.clearSession();
        await sessionManager.saveSession(
          userId: 2,
          username: 'operator',
          role: 'user',
        );

        expect(sessionManager.hasActiveSession(), isTrue);
        expect(sessionManager.getUserId(), 2);
        expect(sessionManager.getUsername(), 'operator');
        expect(sessionManager.getRole(), 'user');
      });
    });

    group('hasActiveSession', () {
      test('returns false when no session exists', () {
        expect(sessionManager.hasActiveSession(), isFalse);
      });

      test('returns true after saveSession', () async {
        await sessionManager.saveSession(
          userId: 1,
          username: 'admin',
          role: 'admin',
        );

        expect(sessionManager.hasActiveSession(), isTrue);
      });

      test('returns false after clearSession', () async {
        await sessionManager.saveSession(
          userId: 1,
          username: 'admin',
          role: 'admin',
        );
        await sessionManager.clearSession();

        expect(sessionManager.hasActiveSession(), isFalse);
      });
    });

    group('getUserId', () {
      test('returns null when no session', () {
        expect(sessionManager.getUserId(), isNull);
      });

      test('returns saved userId', () async {
        await sessionManager.saveSession(
          userId: 42,
          username: 'admin',
          role: 'admin',
        );

        expect(sessionManager.getUserId(), 42);
      });
    });

    group('getUsername', () {
      test('returns null when no session', () {
        expect(sessionManager.getUsername(), isNull);
      });

      test('returns saved username', () async {
        await sessionManager.saveSession(
          userId: 1,
          username: 'admin',
          role: 'admin',
        );

        expect(sessionManager.getUsername(), 'admin');
      });
    });

    group('getRole', () {
      test('returns null when no session', () {
        expect(sessionManager.getRole(), isNull);
      });

      test('returns saved role', () async {
        await sessionManager.saveSession(
          userId: 1,
          username: 'admin',
          role: 'admin',
        );

        expect(sessionManager.getRole(), 'admin');
      });
    });

    group('concurrent access', () {
      test('sequential save and clear preserves correctness', () async {
        for (var i = 0; i < 5; i++) {
          await sessionManager.saveSession(
            userId: i,
            username: 'user$i',
            role: 'role$i',
          );
          expect(sessionManager.getUserId(), i);
          expect(sessionManager.getUsername(), 'user$i');
          expect(sessionManager.getRole(), 'role$i');
        }

        await sessionManager.clearSession();
        expect(sessionManager.hasActiveSession(), isFalse);
      });
    });
  });
}
