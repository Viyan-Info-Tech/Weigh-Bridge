import 'dart:async';
import 'package:weighbridge/core/licensing/data/datasources/machine_identity_datasource.dart';
import 'package:weighbridge/core/licensing/data/datasources/machine_identity_datasource_win.dart';
import 'package:weighbridge/core/licensing/data/datasources/license_local_datasource.dart';
import 'package:weighbridge/core/licensing/data/datasources/clock_rollback_datasource.dart';
import 'package:weighbridge/core/licensing/data/models/license_model.dart';
import 'package:weighbridge/core/licensing/domain/entities/license.dart';
import 'package:weighbridge/core/licensing/domain/enums/license_status.dart';
import 'package:weighbridge/core/licensing/domain/services/license_validator.dart';
import 'package:weighbridge/core/licensing/machine_identity_service.dart';

abstract class LicenseService {
  Future<LicenseStatus> validate();
  Future<License?> loadLicense();
  Future<void> saveLicense(String licenseJson);
  Future<String> getMachineHash();
}

class LicenseServiceImpl implements LicenseService {
  final LicenseLocalDataSource _licenseDataSource;
  final MachineIdentityService _machineIdentityService;
  final ClockRollbackDataSource _clockRollbackDataSource;
  late final LicenseValidatorImpl _validator;

  LicenseServiceImpl({
    LicenseLocalDataSource? licenseDataSource,
    MachineIdentityDatasource? machineIdentityDataSource,
    ClockRollbackDataSource? clockRollbackDataSource,
    LicenseValidatorImpl? validator,
    MachineIdentityService? machineIdentityService,
  }) : _licenseDataSource = licenseDataSource ?? LicenseLocalDataSource(),
       _machineIdentityService =
           machineIdentityService ??
           MachineIdentityService(
             machineIdentityDataSource ?? WindowsMachineIdentityDatasource(),
           ),
       _clockRollbackDataSource =
           clockRollbackDataSource ?? ClockRollbackDataSource() {
    _validator =
        validator ??
        LicenseValidatorImpl(
          machineIdentityService: _machineIdentityService,
          clockRollbackDataSource: _clockRollbackDataSource,
        );
  }

  @override
  Future<LicenseStatus> validate() async {
    final hasLicense = await _licenseDataSource.hasLicense();
    if (!hasLicense) {
      return LicenseStatus.notActivated;
    }

    try {
      final jsonString = await _licenseDataSource.loadLicense();
      final model = LicenseModel.fromJson(jsonString);
      return await _validator.validateLicense(model.license);
    } catch (_) {
      return LicenseStatus.malformedLicense;
    }
  }

  @override
  Future<License?> loadLicense() async {
    final hasLicense = await _licenseDataSource.hasLicense();
    if (!hasLicense) return null;
    try {
      final jsonString = await _licenseDataSource.loadLicense();
      final model = LicenseModel.fromJson(jsonString);
      return model.license;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveLicense(String licenseJson) async {
    await _licenseDataSource.saveLicense(licenseJson);
    await _updateClockRollbackState();
  }

  Future<void> deleteLicense() async {
    await _licenseDataSource.deleteLicense();
  }

  @override
  Future<String> getMachineHash() async {
    return _machineIdentityService.getMachineHash();
  }

  Future<void> _updateClockRollbackState() async {
    await _clockRollbackDataSource.saveState({
      'lastKnownValidTime': DateTime.now().toIso8601String(),
      'lastValidationTime': DateTime.now().toIso8601String(),
    });
  }
}
