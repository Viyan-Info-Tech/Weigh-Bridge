import 'dart:convert';
import 'dart:typed_data';
import 'package:ed25519_edwards/ed25519_edwards.dart' as ed;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weighbridge/core/licensing/data/datasources/license_local_datasource.dart';
import 'package:weighbridge/core/licensing/data/models/license_model.dart';
import 'package:weighbridge/core/licensing/domain/entities/license.dart';
import 'package:weighbridge/core/licensing/domain/enums/license_status.dart';
import 'package:weighbridge/core/licensing/data/datasources/clock_rollback_datasource.dart';
import 'package:weighbridge/core/licensing/domain/services/license_validator.dart';
import 'package:weighbridge/core/licensing/machine_identity_service.dart';
import 'package:weighbridge/core/licensing/data/repositories/license_repository_impl.dart';

class MockLicenseLocalDataSource extends Mock
    implements LicenseLocalDataSource {}

class MockMachineIdentityService extends Mock
    implements MachineIdentityService {}

class MockClockRollbackDataSource extends Mock
    implements ClockRollbackDataSource {}

class MockLicenseValidator extends Mock implements LicenseValidator {}

class MockSettingsLocalDataSource extends Mock {}

ed.KeyPair generateTestKeyPair() => ed.generateKey();

String bytesToHex(Uint8List bytes) =>
    bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

String _publicKeyHex(ed.KeyPair kp) =>
    kp.publicKey.bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

Map<String, dynamic> _buildPayload({
  required String licenseId,
  required String productId,
  required String machineHash,
  required DateTime issuedAt,
  required DateTime expiresAt,
}) {
  return {
    'licenseId': licenseId,
    'productId': productId,
    'customerId': 'CUST-001',
    'customerName': 'Test',
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

License makeSignedLicense({
  required ed.KeyPair keyPair,
  String productId = 'VIYAN-WEIGHBRIDGE',
  String machineHash = 'mach123',
  DateTime? expiresAt,
}) {
  final issuedAt = DateTime.utc(2026, 9, 18);
  expiresAt ??= DateTime.utc(2027, 9, 18);
  final payload = _buildPayload(
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

Map<String, dynamic> _rollbackState(DateTime time) => {
  'lastKnownValidTime': time.toIso8601String(),
};

void main() {
  group('LicenseRepositoryImpl', () {
    late LicenseRepositoryImpl repo;
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

    LicenseValidatorImpl buildValidator() => LicenseValidatorImpl(
      machineIdentityService: mockMachineSvc,
      clockRollbackDataSource: mockClockDs,
      publicKeyHex: _publicKeyHex(keyPair),
    );

    String buildLicenseJson(License license) => jsonEncode({
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

    test('validateLicense returns notActivated when no license', () async {
      when(() => mockLicDs.hasLicense()).thenAnswer((_) async => false);
      repo = LicenseRepositoryImpl(
        licenseDataSource: mockLicDs,
        validator: buildValidator(),
        machineIdentityService: mockMachineSvc,
      );
      final status = await repo.validateLicense();
      expect(status, LicenseStatus.notActivated);
    });

    test('validateLicense returns valid for valid license', () async {
      final license = makeSignedLicense(keyPair: keyPair);
      final validator = buildValidator();
      repo = LicenseRepositoryImpl(
        licenseDataSource: mockLicDs,
        validator: validator,
        machineIdentityService: mockMachineSvc,
      );
      when(() => mockLicDs.hasLicense()).thenAnswer((_) async => true);
      when(
        () => mockLicDs.loadLicense(),
      ).thenAnswer((_) async => buildLicenseJson(license));
      when(
        () => mockMachineSvc.getMachineHash(),
      ).thenAnswer((_) async => license.machineHash);
      when(() => mockClockDs.loadState()).thenAnswer((_) async => null);

      final status = await repo.validateLicense();
      expect(status, LicenseStatus.valid);
    });

    test(
      'validateLicense returns invalidSignature for wrong signature',
      () async {
        final license = makeSignedLicense(keyPair: keyPair);
        final tampered = license.copyWith(signature: 'tampered');
        final validator = buildValidator();
        repo = LicenseRepositoryImpl(
          licenseDataSource: mockLicDs,
          validator: validator,
          machineIdentityService: mockMachineSvc,
        );
        when(() => mockLicDs.hasLicense()).thenAnswer((_) async => true);
        when(
          () => mockLicDs.loadLicense(),
        ).thenAnswer((_) async => buildLicenseJson(tampered));
        when(
          () => mockMachineSvc.getMachineHash(),
        ).thenAnswer((_) async => license.machineHash);
        when(() => mockClockDs.loadState()).thenAnswer((_) async => null);

        final status = await repo.validateLicense();
        expect(status, LicenseStatus.invalidSignature);
      },
    );

    test('validateLicense returns wrongMachine', () async {
      final license = makeSignedLicense(keyPair: keyPair, machineHash: 'orig');
      final validator = buildValidator();
      repo = LicenseRepositoryImpl(
        licenseDataSource: mockLicDs,
        validator: validator,
        machineIdentityService: mockMachineSvc,
      );
      when(() => mockLicDs.hasLicense()).thenAnswer((_) async => true);
      when(
        () => mockLicDs.loadLicense(),
      ).thenAnswer((_) async => buildLicenseJson(license));
      when(
        () => mockMachineSvc.getMachineHash(),
      ).thenAnswer((_) async => 'other');
      when(() => mockClockDs.loadState()).thenAnswer((_) async => null);

      final status = await repo.validateLicense();
      expect(status, LicenseStatus.wrongMachine);
    });

    test('validateLicense returns expired', () async {
      final license = makeSignedLicense(
        keyPair: keyPair,
        expiresAt: DateTime.utc(2020, 1, 1),
      );
      final validator = buildValidator();
      repo = LicenseRepositoryImpl(
        licenseDataSource: mockLicDs,
        validator: validator,
        machineIdentityService: mockMachineSvc,
      );
      when(() => mockLicDs.hasLicense()).thenAnswer((_) async => true);
      when(
        () => mockLicDs.loadLicense(),
      ).thenAnswer((_) async => buildLicenseJson(license));
      when(
        () => mockMachineSvc.getMachineHash(),
      ).thenAnswer((_) async => license.machineHash);
      when(() => mockClockDs.loadState()).thenAnswer((_) async => null);

      final status = await repo.validateLicense();
      expect(status, LicenseStatus.expired);
    });

    test('validateLicense returns wrongProduct', () async {
      final license = makeSignedLicense(keyPair: keyPair, productId: 'WRONG');
      final validator = buildValidator();
      repo = LicenseRepositoryImpl(
        licenseDataSource: mockLicDs,
        validator: validator,
        machineIdentityService: mockMachineSvc,
      );
      when(() => mockLicDs.hasLicense()).thenAnswer((_) async => true);
      when(
        () => mockLicDs.loadLicense(),
      ).thenAnswer((_) async => buildLicenseJson(license));
      when(
        () => mockMachineSvc.getMachineHash(),
      ).thenAnswer((_) async => license.machineHash);
      when(() => mockClockDs.loadState()).thenAnswer((_) async => null);

      final status = await repo.validateLicense();
      expect(status, LicenseStatus.wrongProduct);
    });

    test('validateLicense returns clockRollbackDetected', () async {
      final license = makeSignedLicense(keyPair: keyPair);
      final validator = buildValidator();
      repo = LicenseRepositoryImpl(
        licenseDataSource: mockLicDs,
        validator: validator,
        machineIdentityService: mockMachineSvc,
      );
      when(() => mockLicDs.hasLicense()).thenAnswer((_) async => true);
      when(
        () => mockLicDs.loadLicense(),
      ).thenAnswer((_) async => buildLicenseJson(license));
      when(
        () => mockMachineSvc.getMachineHash(),
      ).thenAnswer((_) async => license.machineHash);
      when(() => mockClockDs.loadState()).thenAnswer(
        (_) async =>
            _rollbackState(DateTime.now().add(const Duration(minutes: 30))),
      );

      final status = await repo.validateLicense();
      expect(status, LicenseStatus.clockRollbackDetected);
    });

    test('validateLicense returns malformedLicense for corrupt data', () async {
      final validator = buildValidator();
      repo = LicenseRepositoryImpl(
        licenseDataSource: mockLicDs,
        validator: validator,
        machineIdentityService: mockMachineSvc,
      );
      when(() => mockLicDs.hasLicense()).thenAnswer((_) async => true);
      when(() => mockLicDs.loadLicense()).thenThrow(Exception('corrupt'));

      final status = await repo.validateLicense();
      expect(status, LicenseStatus.malformedLicense);
    });

    test('getLicenseModel returns null when no license', () async {
      when(() => mockLicDs.hasLicense()).thenAnswer((_) async => false);
      repo = LicenseRepositoryImpl(
        licenseDataSource: mockLicDs,
        machineIdentityService: mockMachineSvc,
      );
      final result = await repo.getLicenseModel();
      expect(result, isNull);
    });

    test('getLicenseModel returns model for valid license', () async {
      final license = makeSignedLicense(keyPair: keyPair);
      when(() => mockLicDs.hasLicense()).thenAnswer((_) async => true);
      when(
        () => mockLicDs.loadLicense(),
      ).thenAnswer((_) async => buildLicenseJson(license));
      repo = LicenseRepositoryImpl(
        licenseDataSource: mockLicDs,
        machineIdentityService: mockMachineSvc,
      );
      final result = await repo.getLicenseModel();
      expect(result, isNotNull);
      expect(result!.license.licenseId, license.licenseId);
    });

    test('getLicenseModel returns null for malformed data', () async {
      when(() => mockLicDs.hasLicense()).thenAnswer((_) async => true);
      when(() => mockLicDs.loadLicense()).thenThrow(FormatException('bad'));
      repo = LicenseRepositoryImpl(
        licenseDataSource: mockLicDs,
        machineIdentityService: mockMachineSvc,
      );
      final result = await repo.getLicenseModel();
      expect(result, isNull);
    });

    test('saveLicense delegates to data source', () async {
      when(() => mockLicDs.saveLicense('test')).thenAnswer((_) async => {});
      repo = LicenseRepositoryImpl(
        licenseDataSource: mockLicDs,
        machineIdentityService: mockMachineSvc,
      );
      await repo.saveLicense('test');
      verify(() => mockLicDs.saveLicense('test')).called(1);
    });

    test('getMachineHash delegates to machine identity service', () async {
      when(
        () => mockMachineSvc.getMachineHash(),
      ).thenAnswer((_) async => 'hash123');
      repo = LicenseRepositoryImpl(
        licenseDataSource: mockLicDs,
        machineIdentityService: mockMachineSvc,
      );
      final result = await repo.getMachineHash();
      expect(result, 'hash123');
    });
  });
}
