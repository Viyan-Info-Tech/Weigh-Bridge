import 'dart:convert';
import 'dart:typed_data';
import 'package:ed25519_edwards/ed25519_edwards.dart';
import '../../domain/entities/license.dart';

class LicenseModel {
  final License license;
  final String rawJson;

  const LicenseModel({required this.license, required this.rawJson});

  factory LicenseModel.fromJson(String jsonString) {
    final Map<String, dynamic> decoded = json.decode(jsonString);
    if (!decoded.containsKey('signature')) {
      throw FormatException('License file missing signature field');
    }
    if (!decoded.containsKey('licenseId')) {
      throw FormatException('License file missing licenseId field');
    }
    if (!decoded.containsKey('productId')) {
      throw FormatException('License file missing productId field');
    }
    if (!decoded.containsKey('machineHash')) {
      throw FormatException('License file missing machineHash field');
    }
    if (!decoded.containsKey('issuedAt')) {
      throw FormatException('License file missing issuedAt field');
    }
    if (!decoded.containsKey('expiresAt')) {
      throw FormatException('License file missing expiresAt field');
    }
    if (!decoded.containsKey('licenseType')) {
      throw FormatException('License file missing licenseType field');
    }
    if (!decoded.containsKey('licenseVersion')) {
      throw FormatException('License file missing licenseVersion field');
    }

    final license = License(
      licenseId: decoded['licenseId'] as String,
      productId: decoded['productId'] as String,
      customerId: decoded['customerId'] as String? ?? '',
      customerName: decoded['customerName'] as String? ?? '',
      machineHash: decoded['machineHash'] as String,
      issuedAt: DateTime.parse(decoded['issuedAt'] as String),
      expiresAt: DateTime.parse(decoded['expiresAt'] as String),
      licenseType: decoded['licenseType'] as String,
      licenseVersion: (decoded['licenseVersion'] as num).toInt(),
      signature: decoded['signature'] as String,
    );

    return LicenseModel(license: license, rawJson: jsonString);
  }

  String get payloadJson {
    final payload = license.toPayload();
    final sorted = Map<String, dynamic>.from(payload)..remove('signature');
    return _canonicalEncode(sorted);
  }

  bool verifySignature(String publicKeyHex) {
    try {
      final publicKeyBytes = _hexToBytes(publicKeyHex);
      if (publicKeyBytes.length != PublicKeySize) return false;
      final publicKey = PublicKey(publicKeyBytes);
      final messageBytes = Uint8List.fromList(utf8.encode(payloadJson));
      final signatureBytes = _hexToBytes(license.signature);
      if (signatureBytes.length != SignatureSize) return false;
      return verify(publicKey, messageBytes, signatureBytes);
    } catch (_) {
      return false;
    }
  }

  static Uint8List _hexToBytes(String hex) {
    final bytes = <int>[];
    for (var i = 0; i < hex.length; i += 2) {
      bytes.add(int.parse(hex.substring(i, i + 2), radix: 16));
    }
    return Uint8List.fromList(bytes);
  }

  static String _canonicalEncode(Map<String, dynamic> map) {
    final sortedKeys = map.keys.toList()..sort();
    final buffer = StringBuffer();
    buffer.write('{');
    for (var i = 0; i < sortedKeys.length; i++) {
      if (i > 0) buffer.write(',');
      final key = sortedKeys[i];
      final value = map[key];
      buffer.write(jsonEncode(key));
      buffer.write(':');
      if (value is String) {
        buffer.write(jsonEncode(value));
      } else if (value is int) {
        buffer.write(value);
      } else if (value is bool) {
        buffer.write(value ? 'true' : 'false');
      } else if (value is Map<String, dynamic>) {
        buffer.write(_canonicalEncode(value));
      } else if (value is List) {
        buffer.write(jsonEncode(value));
      } else {
        buffer.write(jsonEncode(value));
      }
    }
    buffer.write('}');
    return buffer.toString();
  }
}
