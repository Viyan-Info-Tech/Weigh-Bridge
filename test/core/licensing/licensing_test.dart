import 'dart:convert';
import 'dart:typed_data';
import 'package:ed25519_edwards/ed25519_edwards.dart' as ed;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weighbridge/core/licensing/data/datasources/clock_rollback_datasource.dart';
import 'package:weighbridge/core/licensing/data/datasources/license_local_datasource.dart';
import 'package:weighbridge/core/licensing/data/datasources/machine_identity_datasource_win.dart';
import 'package:weighbridge/core/licensing/data/models/license_model.dart';
import 'package:weighbridge/core/licensing/domain/entities/license.dart';
import 'package:weighbridge/core/licensing/domain/enums/license_status.dart';
import 'package:weighbridge/core/licensing/domain/services/license_validator.dart';
import 'package:weighbridge/core/licensing/machine_identity_service.dart';
import 'package:weighbridge/core/licensing/license_service.dart';

class MockLicenseLocalDataSource extends Mock
    implements LicenseLocalDataSource {}

class MockMachineIdentityService extends Mock
    implements MachineIdentityService {}

class MockClockRollbackDataSource extends Mock
    implements ClockRollbackDataSource {}

ed.KeyPair generateTestKeyPair() {
  return ed.generateKey();
}

Map<String, dynamic> buildLicensePayload({
  required String licenseId,
  required String productId,
  required String customerId,
  required String customerName,
  required String machineHash,
  required DateTime issuedAt,
  required DateTime expiresAt,
  required String licenseType,
  required int licenseVersion,
}) {
  return {
    'licenseId': licenseId,
    'productId': productId,
    'customerId': customerId,
    'customerName': customerName,
    'machineHash': machineHash,
    'issuedAt': issuedAt.toIso8601String(),
    'expiresAt': expiresAt.toIso8601String(),
    'licenseType': licenseType,
    'licenseVersion': licenseVersion,
  };
}

String signKeyPair(ed.KeyPair keyPair, Map<String, dynamic> payload) {
  final sorted = Map<String, dynamic>.from(payload)..remove('signature');
  final buffer = StringBuffer();
  buffer.write('{');
  final keys = sorted.keys.toList()..sort();
  for (var i = 0; i < keys.length; i++) {
    if (i > 0) buffer.write(',');
    buffer.write(jsonEncode(keys[i]));
    buffer.write(':');
    final value = sorted[keys[i]];
    if (value is String) {
      buffer.write(jsonEncode(value));
    } else if (value is int) {
      buffer.write(value);
    } else if (value is bool) {
      buffer.write(value ? 'true' : 'false');
    } else {
      buffer.write(jsonEncode(value));
    }
  }
  buffer.write('}');
  final messageBytes = Uint8List.fromList(utf8.encode(buffer.toString()));
  final signature = ed.sign(keyPair.privateKey, messageBytes);
  return bytesToHex(signature);
}

String bytesToHex(Uint8List bytes) {
  return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}

License createSignedLicense({
  required ed.KeyPair keyPair,
  required String productId,
  required String machineHash,
  required DateTime expiresAt,
  String licenseId = 'VY-WB-000001',
  String customerId = 'CUSTOMER-001',
  String customerName = 'Test Customer',
  String licenseType = '12_MONTH',
  int licenseVersion = 1,
}) {
  final issuedAt = DateTime.utc(2026, 9, 18);
  final payload = buildLicensePayload(
    licenseId: licenseId,
    productId: productId,
    customerId: customerId,
    customerName: customerName,
    machineHash: machineHash,
    issuedAt: issuedAt,
    expiresAt: expiresAt,
    licenseType: licenseType,
    licenseVersion: licenseVersion,
  );
  final signature = signKeyPair(keyPair, payload);
  final signedPayload = Map<String, dynamic>.from(payload)
    ..['signature'] = signature;
  final jsonString = jsonEncode(signedPayload);
  return LicenseModel.fromJson(jsonString).license;
}

void main() {
  group('LicenseValidator - Valid license', () {
    test(
      'correct signature, correct product, correct machine, valid expiry => VALID',
      () async {
        final keyPair = generateTestKeyPair();
        final machineHash = 'abc123machinehash';
        final expiresAt = DateTime.utc(2027, 9, 18);

        final license = createSignedLicense(
          keyPair: keyPair,
          productId: 'VIYAN-WEIGHBRIDGE',
          machineHash: machineHash,
          expiresAt: expiresAt,
        );

        final mockMachineService = MockMachineIdentityService();
        final mockClockDs = MockClockRollbackDataSource();

        when(
          () => mockMachineService.getMachineHash(),
        ).thenAnswer((_) async => machineHash);
        when(() => mockClockDs.loadState()).thenAnswer((_) async => null);

        final validator = LicenseValidatorImpl(
          machineIdentityService: mockMachineService,
          clockRollbackDataSource: mockClockDs,
          publicKeyHex: _publicKeyHex(keyPair),
        );

        final status = await validator.validateLicense(license);
        expect(status, LicenseStatus.valid);
      },
    );
  });

  group('LicenseValidator - Wrong machine', () {
    test('correct signature, wrong machine => WRONG_MACHINE', () async {
      final keyPair = generateTestKeyPair();
      final licenseMachineHash = 'abc123machinehash';
      final currentMachineHash = 'differentmachinehash';
      final expiresAt = DateTime.utc(2027, 9, 18);

      final license = createSignedLicense(
        keyPair: keyPair,
        productId: 'VIYAN-WEIGHBRIDGE',
        machineHash: licenseMachineHash,
        expiresAt: expiresAt,
      );

      final mockMachineService = MockMachineIdentityService();
      final mockClockDs = MockClockRollbackDataSource();

      when(
        () => mockMachineService.getMachineHash(),
      ).thenAnswer((_) async => currentMachineHash);
      when(() => mockClockDs.loadState()).thenAnswer((_) async => null);

      final validator = LicenseValidatorImpl(
        machineIdentityService: mockMachineService,
        clockRollbackDataSource: mockClockDs,
        publicKeyHex: _publicKeyHex(keyPair),
      );

      final status = await validator.validateLicense(license);
      expect(status, LicenseStatus.wrongMachine);
    });
  });

  group('LicenseValidator - Expired', () {
    test(
      'correct signature, correct machine, expired date => EXPIRED',
      () async {
        final keyPair = generateTestKeyPair();
        final machineHash = 'abc123machinehash';
        final expiresAt = DateTime.utc(2020, 9, 18);

        final license = createSignedLicense(
          keyPair: keyPair,
          productId: 'VIYAN-WEIGHBRIDGE',
          machineHash: machineHash,
          expiresAt: expiresAt,
        );

        final mockMachineService = MockMachineIdentityService();
        final mockClockDs = MockClockRollbackDataSource();

        when(
          () => mockMachineService.getMachineHash(),
        ).thenAnswer((_) async => machineHash);
        when(() => mockClockDs.loadState()).thenAnswer((_) async => null);

        final validator = LicenseValidatorImpl(
          machineIdentityService: mockMachineService,
          clockRollbackDataSource: mockClockDs,
          publicKeyHex: _publicKeyHex(keyPair),
        );

        final status = await validator.validateLicense(license);
        expect(status, LicenseStatus.expired);
      },
    );
  });

  group('LicenseValidator - Tampered expiry', () {
    test('modify expiresAt without resigning => INVALID_SIGNATURE', () async {
      final keyPair = generateTestKeyPair();
      final machineHash = 'abc123machinehash';
      final expiresAt = DateTime.utc(2027, 9, 18);

      final license = createSignedLicense(
        keyPair: keyPair,
        productId: 'VIYAN-WEIGHBRIDGE',
        machineHash: machineHash,
        expiresAt: expiresAt,
      );

      final tamperedLicense = license.copyWith(
        expiresAt: DateTime.utc(2030, 9, 18),
      );

      final mockMachineService = MockMachineIdentityService();
      final mockClockDs = MockClockRollbackDataSource();

      when(
        () => mockMachineService.getMachineHash(),
      ).thenAnswer((_) async => machineHash);
      when(() => mockClockDs.loadState()).thenAnswer((_) async => null);

      final validator = LicenseValidatorImpl(
        machineIdentityService: mockMachineService,
        clockRollbackDataSource: mockClockDs,
        publicKeyHex: _publicKeyHex(keyPair),
      );

      final status = await validator.validateLicense(tamperedLicense);
      expect(status, LicenseStatus.invalidSignature);
    });
  });

  group('LicenseValidator - Tampered machine hash', () {
    test('modify machineHash without resigning => INVALID_SIGNATURE', () async {
      final keyPair = generateTestKeyPair();
      final machineHash = 'abc123machinehash';
      final expiresAt = DateTime.utc(2027, 9, 18);

      final license = createSignedLicense(
        keyPair: keyPair,
        productId: 'VIYAN-WEIGHBRIDGE',
        machineHash: machineHash,
        expiresAt: expiresAt,
      );

      final tamperedLicense = license.copyWith(machineHash: 'tamperedhash');

      final mockMachineService = MockMachineIdentityService();
      final mockClockDs = MockClockRollbackDataSource();

      when(
        () => mockMachineService.getMachineHash(),
      ).thenAnswer((_) async => machineHash);
      when(() => mockClockDs.loadState()).thenAnswer((_) async => null);

      final validator = LicenseValidatorImpl(
        machineIdentityService: mockMachineService,
        clockRollbackDataSource: mockClockDs,
        publicKeyHex: _publicKeyHex(keyPair),
      );

      final status = await validator.validateLicense(tamperedLicense);
      expect(status, LicenseStatus.invalidSignature);
    });
  });

  group('LicenseValidator - Wrong product', () {
    test('correct signature, wrong product => WRONG_PRODUCT', () async {
      final keyPair = generateTestKeyPair();
      final machineHash = 'abc123machinehash';
      final expiresAt = DateTime.utc(2027, 9, 18);

      final license = createSignedLicense(
        keyPair: keyPair,
        productId: 'VIYAN-MEDASSIST',
        machineHash: machineHash,
        expiresAt: expiresAt,
      );

      final mockMachineService = MockMachineIdentityService();
      final mockClockDs = MockClockRollbackDataSource();

      when(
        () => mockMachineService.getMachineHash(),
      ).thenAnswer((_) async => machineHash);
      when(() => mockClockDs.loadState()).thenAnswer((_) async => null);

      final validator = LicenseValidatorImpl(
        machineIdentityService: mockMachineService,
        clockRollbackDataSource: mockClockDs,
        publicKeyHex: _publicKeyHex(keyPair),
      );

      final status = await validator.validateLicense(license);
      expect(status, LicenseStatus.wrongProduct);
    });
  });

  group('LicenseValidator - Malformed license', () {
    test('missing signature field => MALFORMED_LICENSE', () {
      expect(
        () => LicenseModel.fromJson('{"licenseId":"test"}'),
        throwsA(isA<FormatException>()),
      );
    });

    test('empty JSON => MALFORMED_LICENSE', () {
      expect(
        () => LicenseModel.fromJson('{}'),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('LicenseValidator - Clock rollback', () {
    test(
      'lastKnownValidTime is future beyond tolerance => CLOCK_ROLLBACK_DETECTED',
      () async {
        final keyPair = generateTestKeyPair();
        final machineHash = 'abc123machinehash';
        final expiresAt = DateTime.utc(2027, 9, 18);

        final license = createSignedLicense(
          keyPair: keyPair,
          productId: 'VIYAN-WEIGHBRIDGE',
          machineHash: machineHash,
          expiresAt: expiresAt,
        );

        final mockMachineService = MockMachineIdentityService();
        final mockClockDs = MockClockRollbackDataSource();

        when(
          () => mockMachineService.getMachineHash(),
        ).thenAnswer((_) async => machineHash);
        when(() => mockClockDs.loadState()).thenAnswer(
          (_) async => {
            'lastKnownValidTime': DateTime.now()
                .add(const Duration(minutes: 30))
                .toIso8601String(),
          },
        );

        final validator = LicenseValidatorImpl(
          machineIdentityService: mockMachineService,
          clockRollbackDataSource: mockClockDs,
          publicKeyHex: _publicKeyHex(keyPair),
        );

        final status = await validator.validateLicense(license);
        expect(status, LicenseStatus.clockRollbackDetected);
      },
    );

    test('minor clock adjustment within tolerance => VALID', () async {
      final keyPair = generateTestKeyPair();
      final machineHash = 'abc123machinehash';
      final expiresAt = DateTime.utc(2027, 9, 18);

      final license = createSignedLicense(
        keyPair: keyPair,
        productId: 'VIYAN-WEIGHBRIDGE',
        machineHash: machineHash,
        expiresAt: expiresAt,
      );

      final mockMachineService = MockMachineIdentityService();
      final mockClockDs = MockClockRollbackDataSource();

      when(
        () => mockMachineService.getMachineHash(),
      ).thenAnswer((_) async => machineHash);
      when(() => mockClockDs.loadState()).thenAnswer(
        (_) async => {
          'lastKnownValidTime': DateTime.now()
              .subtract(const Duration(minutes: 2))
              .toIso8601String(),
        },
      );

      final validator = LicenseValidatorImpl(
        machineIdentityService: mockMachineService,
        clockRollbackDataSource: mockClockDs,
        publicKeyHex: _publicKeyHex(keyPair),
      );

      final status = await validator.validateLicense(license);
      expect(status, LicenseStatus.valid);
    });
  });

  group('LicenseServiceImpl - Not activated', () {
    test('no license file => notActivated', () async {
      final mockLicenseDs = MockLicenseLocalDataSource();
      final mockMachineService = MockMachineIdentityService();
      final mockClockDs = MockClockRollbackDataSource();

      when(() => mockLicenseDs.hasLicense()).thenAnswer((_) async => false);

      final service = LicenseServiceImpl(
        licenseDataSource: mockLicenseDs,
        machineIdentityService: mockMachineService,
        clockRollbackDataSource: mockClockDs,
      );

      final status = await service.validate();
      expect(status, LicenseStatus.notActivated);
    });
  });

  group('MachineIdentityService', () {
    test('getMachineHash returns non-empty SHA-256 string', () async {
      final datasource = StubMachineIdentityDatasource(
        identifiers: ['GUID123', 'PROC456', 'BOARD789'],
      );
      final service = MachineIdentityService(datasource);
      final hash = await service.getMachineHash();
      expect(hash, isNotEmpty);
      expect(hash.length, 64);
    });

    test('same identifiers produce same hash', () async {
      final datasource = StubMachineIdentityDatasource(
        identifiers: ['GUID123', 'PROC456', 'BOARD789'],
      );
      final service = MachineIdentityService(datasource);
      final hash1 = await service.getMachineHash();
      final hash2 = await service.getMachineHash();
      expect(hash1, hash2);
    });

    test('different identifiers produce different hash', () async {
      final datasource1 = StubMachineIdentityDatasource(
        identifiers: ['GUID123', 'PROC456', 'BOARD789'],
      );
      final datasource2 = StubMachineIdentityDatasource(
        identifiers: ['GUID123', 'PROC456', 'BOARD000'],
      );
      final service1 = MachineIdentityService(datasource1);
      final service2 = MachineIdentityService(datasource2);
      final hash1 = await service1.getMachineHash();
      final hash2 = await service2.getMachineHash();
      expect(hash1, isNot(equals(hash2)));
    });

    test('empty identifiers uses fallback', () async {
      final datasource = StubMachineIdentityDatasource(identifiers: []);
      final service = MachineIdentityService(datasource);
      final hash = await service.getMachineHash();
      expect(hash, isNotEmpty);
    });

    test('identifiers are normalized', () async {
      final datasource = StubMachineIdentityDatasource(
        identifiers: [' AbC ', '  DEF  '],
      );
      final service = MachineIdentityService(datasource);
      final hash = await service.getMachineHash();
      expect(hash, isNotEmpty);
      final hash2 = await service.getMachineHash();
      expect(hash, hash2);
    });
  });

  group('Ed25519 crypto', () {
    test('generate creates valid key pair', () {
      final keyPair = generateTestKeyPair();
      expect(keyPair.publicKey.bytes.length, 32);
      expect(keyPair.privateKey.bytes.length, 64);
    });

    test('sign and verify roundtrip', () {
      final keyPair = generateTestKeyPair();
      final message = 'test message';
      final signature = ed.sign(
        keyPair.privateKey,
        Uint8List.fromList(utf8.encode(message)),
      );
      expect(
        ed.verify(
          keyPair.publicKey,
          Uint8List.fromList(utf8.encode(message)),
          signature,
        ),
        isTrue,
      );
    });

    test('wrong message fails verification', () {
      final keyPair = generateTestKeyPair();
      final message = 'test message';
      final signature = ed.sign(
        keyPair.privateKey,
        Uint8List.fromList(utf8.encode(message)),
      );
      expect(
        ed.verify(
          keyPair.publicKey,
          Uint8List.fromList(utf8.encode('wrong')),
          signature,
        ),
        isFalse,
      );
    });

    test('tampered signature fails verification', () {
      final keyPair = generateTestKeyPair();
      final message = 'test message';
      final signature = ed.sign(
        keyPair.privateKey,
        Uint8List.fromList(utf8.encode(message)),
      );
      final tampered = Uint8List.fromList(
        signature.map((b) => b ^ 0xFF).toList(),
      );
      expect(
        ed.verify(
          keyPair.publicKey,
          Uint8List.fromList(utf8.encode(message)),
          tampered,
        ),
        isFalse,
      );
    });
  });

  group('LicenseModel', () {
    test('valid signed license parses correctly', () {
      final keyPair = generateTestKeyPair();
      final license = createSignedLicense(
        keyPair: keyPair,
        productId: 'VIYAN-WEIGHBRIDGE',
        machineHash: 'testHash',
        expiresAt: DateTime.utc(2027, 9, 18),
      );
      expect(license.licenseId, 'VY-WB-000001');
      expect(license.productId, 'VIYAN-WEIGHBRIDGE');
      expect(license.machineHash, 'testHash');
      expect(license.signature.isNotEmpty, isTrue);
    });

    test('valid signature verifies correctly', () {
      final keyPair = generateTestKeyPair();
      final license = createSignedLicense(
        keyPair: keyPair,
        productId: 'VIYAN-WEIGHBRIDGE',
        machineHash: 'testHash',
        expiresAt: DateTime.utc(2027, 9, 18),
      );
      final model = LicenseModel(license: license, rawJson: '');
      expect(model.verifySignature(_publicKeyHex(keyPair)), isTrue);
    });

    test('wrong public key fails verification', () {
      final keyPair = generateTestKeyPair();
      final license = createSignedLicense(
        keyPair: keyPair,
        productId: 'VIYAN-WEIGHBRIDGE',
        machineHash: 'testHash',
        expiresAt: DateTime.utc(2027, 9, 18),
      );
      final model = LicenseModel(license: license, rawJson: '');
      final otherKeyPair = generateTestKeyPair();
      expect(model.verifySignature(_publicKeyHex(otherKeyPair)), isFalse);
    });
  });
}

String _publicKeyHex(ed.KeyPair keyPair) {
  return keyPair.publicKey.bytes
      .map((b) => b.toRadixString(16).padLeft(2, '0'))
      .join();
}
