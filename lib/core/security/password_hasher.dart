import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

class PasswordHasher {
  static const int _saltLength = 16;
  static const int _iterations = 10000;
  static const int _keyLength = 32;

  String hashPassword(String password) {
    final salt = _generateSalt();
    final passwordBytes = Uint8List.fromList(utf8.encode(password));

    final derivedKey = _deriveKey(passwordBytes, salt, _iterations, _keyLength);

    final hashHex = derivedKey.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    final saltHex = salt.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '$_iterations:\$$saltHex\$$hashHex';
  }

  bool verifyPassword(String password, String storedHash) {
    try {
      final parts = storedHash.split(':');
      if (parts.length != 2) return false;

      final iterations = int.parse(parts[0]);
      final saltAndHash = parts[1];
      final splitIndex = saltAndHash.indexOf('\$', 1);
      if (splitIndex == -1) return false;

      final saltHex = saltAndHash.substring(1, splitIndex);
      final hashHex = saltAndHash.substring(splitIndex + 1);

      final salt = _hexToBytes(saltHex);
      final storedHashBytes = _hexToBytes(hashHex);

      final passwordBytes = Uint8List.fromList(utf8.encode(password));
      final derivedKey = _deriveKey(passwordBytes, salt, iterations, storedHashBytes.length);

      if (derivedKey.length != storedHashBytes.length) return false;

      return _constantTimeCompare(derivedKey, storedHashBytes);
    } catch (_) {
      return false;
    }
  }

  List<int> _generateSalt() {
    final random = Random.secure();
    return List<int>.generate(_saltLength, (_) => random.nextInt(256));
  }

  Uint8List _deriveKey(Uint8List password, List<int> salt, int iterations, int keyLength) {
    final mac = HMac.withDigest(Digest('SHA-256'));
    final gen = PBKDF2KeyDerivator(mac);
    gen.init(Pbkdf2Parameters(Uint8List.fromList(salt), iterations, keyLength));
    return gen.process(password);
  }

  List<int> _hexToBytes(String hex) {
    final bytes = <int>[];
    for (var i = 0; i < hex.length; i += 2) {
      bytes.add(int.parse(hex.substring(i, i + 2), radix: 16));
    }
    return bytes;
  }

  bool _constantTimeCompare(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a[i] ^ b[i];
    }
    return result == 0;
  }
}
