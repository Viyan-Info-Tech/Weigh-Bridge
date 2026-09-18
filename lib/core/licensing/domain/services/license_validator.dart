import 'dart:async';
import 'dart:developer';
import 'package:weighbridge/core/licensing/data/constants/keys.dart';
import 'package:weighbridge/core/licensing/data/datasources/clock_rollback_datasource.dart';
import 'package:weighbridge/core/licensing/data/models/license_model.dart';
import 'package:weighbridge/core/licensing/domain/entities/license.dart';
import 'package:weighbridge/core/licensing/domain/enums/license_status.dart';
import 'package:weighbridge/core/licensing/machine_identity_service.dart';

abstract class LicenseValidator {
  Future<LicenseStatus> validateLicense(License license);
}

class LicenseValidatorImpl implements LicenseValidator {
  final MachineIdentityService _machineIdentityService;
  final ClockRollbackDataSource _clockRollbackDataSource;
  final String _publicKeyHex;

  LicenseValidatorImpl({
    required MachineIdentityService machineIdentityService,
    required ClockRollbackDataSource clockRollbackDataSource,
    String? publicKeyHex,
  }) : _machineIdentityService = machineIdentityService,
       _clockRollbackDataSource = clockRollbackDataSource,
       _publicKeyHex = publicKeyHex ?? kPublicKeyHex;

  @override
  Future<LicenseStatus> validateLicense(License license) async {
    final model = LicenseModel(license: license, rawJson: '');
    if (!model.verifySignature(_publicKeyHex)) {
      _log('Signature validation: FAILED');
      return LicenseStatus.invalidSignature;
    }
    _log('Signature validation: PASSED');

    if (license.productId != 'VIYAN-WEIGHBRIDGE') {
      _log('Product validation: FAILED (wrong product)');
      return LicenseStatus.wrongProduct;
    }
    _log('Product validation: PASSED');

    final currentMachineHash = await _machineIdentityService.getMachineHash();
    if (license.machineHash != currentMachineHash) {
      _log('Machine validation: FAILED');
      return LicenseStatus.wrongMachine;
    }
    _log('Machine validation: PASSED');

    if (DateTime.now().isAfter(license.expiresAt)) {
      _log('Expiry validation: EXPIRED');
      return LicenseStatus.expired;
    }
    _log('Expiry validation: VALID');

    final rollbackState = await _clockRollbackDataSource.loadState();
    if (rollbackState != null) {
      final lastKnownValidTime = rollbackState['lastKnownValidTime'] as String?;
      if (lastKnownValidTime != null) {
        final lastTime = DateTime.parse(lastKnownValidTime);
        if (DateTime.now().difference(lastTime).inMinutes < -5) {
          _log('Clock rollback: DETECTED');
          return LicenseStatus.clockRollbackDetected;
        }
      }
    }
    _log('Clock rollback check: PASSED');
    _log('Final license status: VALID');
    return LicenseStatus.valid;
  }

  void _log(String message) {
    log('[LicenseValidator] $message');
  }
}
