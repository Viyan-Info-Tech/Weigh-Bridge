import 'dart:convert';
import 'dart:typed_data';
import 'package:ed25519_edwards/ed25519_edwards.dart' as ed;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weighbridge/core/licensing/data/datasources/license_local_datasource.dart';
import 'package:weighbridge/core/licensing/data/datasources/clock_rollback_datasource.dart';
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

ed.KeyPair generateTestKeyPair() => ed.generateKey();

String bytesToHex(Uint8List bytes) =>
    bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

String _publicKeyHex(ed.KeyPair kp) =>
    kp.publicKey.bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

Map<String, dynamic> _payload({
  required String licenseId,
  required String productId,
  required String machineHash,
  required DateTime issuedAt,
  required DateTime expiresAt,
}) {
  return {
    'licenseId': licenseId,
    'productId': productId,
    'customerId': 'CUST',
    'customerName': 'T',
    'machineHash': machineHash,
    'issuedAt': issuedAt.toIso8601String(),
    'expiresAt': expiresAt.toIso8601String(),
    'licenseType': '12_MONTH',
    'licenseVersion': 1,
  };
}

String signData(ed.KeyPair kp, Map<String, dynamic> payload) {
  final sorted = Map<String, dynamic>.from(payload)..remove('signature');
  final buf = StringBuffer();
  buf.write('{');
  final keys = sorted.keys.toList()..sort();
  for (var i = 0; i < keys.length; i++) {
    if (i > 0) buf.write(',');
    buf.write(jsonEncode(keys[i]));
    buf.write(':');
    final v = sorted[keys[i]];
    if (v is String) {
      buf.write(jsonEncode(v));
    } else if (v is int) {
      buf.write(v);
    } else {
      buf.write(jsonEncode(v));
    }
  }
  buf.write('}');
  return bytesToHex(
    ed.sign(kp.privateKey, Uint8List.fromList(utf8.encode(buf.toString()))),
  );
}

License signedLicense({
  required ed.KeyPair keyPair,
  String productId = 'VIYAN-WEIGHBRIDGE',
  String machineHash = 'mach',
  DateTime? expiresAt,
}) {
  final issuedAt = DateTime.utc(2026, 9, 18);
  expiresAt ??= DateTime.utc(2027, 9, 18);
  final payload = _payload(
    licenseId: 'VY-WB-001',
    productId: productId,
    machineHash: machineHash,
    issuedAt: issuedAt,
    expiresAt: expiresAt,
  );
  final sig = signData(keyPair, payload);
  final signed = Map<String, dynamic>.from(payload)..['signature'] = sig;
  return LicenseModel.fromJson(jsonEncode(signed)).license;
}

String _licenseJson(License license) => jsonEncode({
  'licenseId': license.licenseId,
  'productId': license.productId,
  'customerId': license.customerId,
  'customerName': license.customerName,
  'machineHash': license.machineHash,
  'issuedAt': license.issuedAt.toIso8601String(),
  'expiresAt': license.expiresAt.toIso8601String(),
  'licenseType': license.licenseType,
  'licenseVersion': license.licenseVersion,
  'signature': license.signature,
});

void main() {
  late MockLicenseLocalDataSource mockLicDs;
  late MockMachineIdentityService mockMachineSvc;
  late MockClockRollbackDataSource mockClockDs;
  late ed.KeyPair keyPair;

  setUp(() {
    keyPair = generateTestKeyPair();
    mockLicDs = MockLicenseLocalDataSource();
    mockMachineSvc = MockMachineIdentityService();
    mockClockDs = MockClockRollbackDataSource();
  });

  LicenseServiceImpl buildService({LicenseValidatorImpl? validator}) {
    return LicenseServiceImpl(
      licenseDataSource: mockLicDs,
      machineIdentityService: mockMachineSvc,
      clockRollbackDataSource: mockClockDs,
      validator: validator,
    );
  }

  LicenseValidatorImpl buildValidator() => LicenseValidatorImpl(
    machineIdentityService: mockMachineSvc,
    clockRollbackDataSource: mockClockDs,
    publicKeyHex: _publicKeyHex(keyPair),
  );

  group('LicenseServiceImpl - validate', () {
    test('returns notActivated when no license file', () async {
      when(() => mockLicDs.hasLicense()).thenAnswer((_) async => false);
      final service = buildService();
      final status = await service.validate();
      expect(status, LicenseStatus.notActivated);
    });

    test('returns valid for valid license', () async {
      final license = signedLicense(keyPair: keyPair);
      when(() => mockLicDs.hasLicense()).thenAnswer((_) async => true);
      when(
        () => mockLicDs.loadLicense(),
      ).thenAnswer((_) async => _licenseJson(license));
      when(
        () => mockMachineSvc.getMachineHash(),
      ).thenAnswer((_) async => license.machineHash);
      when(() => mockClockDs.loadState()).thenAnswer((_) async => null);
      final service = buildService(validator: buildValidator());
      final status = await service.validate();
      expect(status, LicenseStatus.valid);
    });

    test('returns malformedLicense for corrupt JSON', () async {
      when(() => mockLicDs.hasLicense()).thenAnswer((_) async => true);
      when(() => mockLicDs.loadLicense()).thenAnswer((_) async => 'not json');
      final service = buildService(validator: buildValidator());
      final status = await service.validate();
      expect(status, LicenseStatus.malformedLicense);
    });

    test('returns malformedLicense when load throws', () async {
      when(() => mockLicDs.hasLicense()).thenAnswer((_) async => true);
      when(() => mockLicDs.loadLicense()).thenThrow(Exception('error'));
      final service = buildService(validator: buildValidator());
      final status = await service.validate();
      expect(status, LicenseStatus.malformedLicense);
    });

    test('returns invalidSignature', () async {
      final license = signedLicense(keyPair: keyPair);
      when(() => mockLicDs.hasLicense()).thenAnswer((_) async => true);
      when(() => mockLicDs.loadLicense()).thenAnswer(
        (_) async => _licenseJson(license.copyWith(signature: 'bad')),
      );
      when(
        () => mockMachineSvc.getMachineHash(),
      ).thenAnswer((_) async => license.machineHash);
      when(() => mockClockDs.loadState()).thenAnswer((_) async => null);
      final service = buildService(validator: buildValidator());
      final status = await service.validate();
      expect(status, LicenseStatus.invalidSignature);
    });

    test('returns wrongMachine', () async {
      final license = signedLicense(keyPair: keyPair);
      when(() => mockLicDs.hasLicense()).thenAnswer((_) async => true);
      when(
        () => mockLicDs.loadLicense(),
      ).thenAnswer((_) async => _licenseJson(license));
      when(
        () => mockMachineSvc.getMachineHash(),
      ).thenAnswer((_) async => 'other');
      when(() => mockClockDs.loadState()).thenAnswer((_) async => null);
      final service = buildService(validator: buildValidator());
      final status = await service.validate();
      expect(status, LicenseStatus.wrongMachine);
    });

    test('returns expired', () async {
      final license = signedLicense(
        keyPair: keyPair,
        expiresAt: DateTime.utc(2020, 1, 1),
      );
      when(() => mockLicDs.hasLicense()).thenAnswer((_) async => true);
      when(
        () => mockLicDs.loadLicense(),
      ).thenAnswer((_) async => _licenseJson(license));
      when(
        () => mockMachineSvc.getMachineHash(),
      ).thenAnswer((_) async => license.machineHash);
      when(() => mockClockDs.loadState()).thenAnswer((_) async => null);
      final service = buildService(validator: buildValidator());
      final status = await service.validate();
      expect(status, LicenseStatus.expired);
    });

    test('returns clockRollbackDetected', () async {
      final license = signedLicense(keyPair: keyPair);
      when(() => mockLicDs.hasLicense()).thenAnswer((_) async => true);
      when(
        () => mockLicDs.loadLicense(),
      ).thenAnswer((_) async => _licenseJson(license));
      when(
        () => mockMachineSvc.getMachineHash(),
      ).thenAnswer((_) async => license.machineHash);
      when(() => mockClockDs.loadState()).thenAnswer(
        (_) async => {
          'lastKnownValidTime': DateTime.now()
              .add(const Duration(minutes: 30))
              .toIso8601String(),
        },
      );
      final service = buildService(validator: buildValidator());
      final status = await service.validate();
      expect(status, LicenseStatus.clockRollbackDetected);
    });
  });

  group('LicenseServiceImpl - loadLicense', () {
    test('returns null when no license', () async {
      when(() => mockLicDs.hasLicense()).thenAnswer((_) async => false);
      final service = buildService();
      final result = await service.loadLicense();
      expect(result, isNull);
    });

    test('returns license when file exists', () async {
      final license = signedLicense(keyPair: keyPair);
      when(() => mockLicDs.hasLicense()).thenAnswer((_) async => true);
      when(
        () => mockLicDs.loadLicense(),
      ).thenAnswer((_) async => _licenseJson(license));
      final service = buildService();
      final result = await service.loadLicense();
      expect(result, isNotNull);
      expect(result!.licenseId, license.licenseId);
    });

    test('returns null for corrupt data', () async {
      when(() => mockLicDs.hasLicense()).thenAnswer((_) async => true);
      when(() => mockLicDs.loadLicense()).thenThrow(Exception('bad'));
      final service = buildService();
      final result = await service.loadLicense();
      expect(result, isNull);
    });
  });

  group('LicenseServiceImpl - saveLicense', () {
    test('persists license', () async {
      when(() => mockLicDs.saveLicense('test')).thenAnswer((_) async => {});
      final service = buildService();
      await service.saveLicense('test');
      verify(() => mockLicDs.saveLicense('test')).called(1);
    });
  });

  group('LicenseServiceImpl - getMachineHash', () {
    test('returns machine hash from service', () async {
      when(
        () => mockMachineSvc.getMachineHash(),
      ).thenAnswer((_) async => 'abc123');
      final service = buildService();
      final hash = await service.getMachineHash();
      expect(hash, 'abc123');
    });
  });
}
