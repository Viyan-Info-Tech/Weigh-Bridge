import 'package:weighbridge/core/licensing/data/datasources/license_local_datasource.dart';
import 'package:weighbridge/core/licensing/data/datasources/machine_identity_datasource_win.dart';
import 'package:weighbridge/core/licensing/data/datasources/clock_rollback_datasource.dart';
import 'package:weighbridge/core/licensing/data/models/license_model.dart';
import 'package:weighbridge/core/licensing/domain/entities/license.dart';
import 'package:weighbridge/core/licensing/domain/enums/license_status.dart';
import 'package:weighbridge/core/licensing/domain/services/license_validator.dart';
import 'package:weighbridge/core/licensing/machine_identity_service.dart';

class LicenseRepositoryImpl {
  final LicenseLocalDataSource _licenseDataSource;
  final LicenseValidatorImpl _validator;
  final MachineIdentityService _machineIdentityService;

  LicenseRepositoryImpl({
    LicenseLocalDataSource? licenseDataSource,
    LicenseValidatorImpl? validator,
    MachineIdentityService? machineIdentityService,
  })  : _licenseDataSource = licenseDataSource ?? LicenseLocalDataSource(),
        _validator = validator ?? LicenseValidatorImpl(
          machineIdentityService: MachineIdentityService(
            WindowsMachineIdentityDatasource(),
          ),
          clockRollbackDataSource: ClockRollbackDataSource(),
        ),
        _machineIdentityService =
            machineIdentityService ?? MachineIdentityService(WindowsMachineIdentityDatasource());

  Future<LicenseStatus> validateLicense() async {
    final license = await _loadLicenseEntity();
    if (license == null) return LicenseStatus.notActivated;
    return await _validator.validateLicense(license);
  }

  Future<LicenseModel?> getLicenseModel() async {
    final hasLicense = await _licenseDataSource.hasLicense();
    if (!hasLicense) return null;
    try {
      final jsonString = await _licenseDataSource.loadLicense();
      return LicenseModel.fromJson(jsonString);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveLicense(String licenseJson) async {
    await _licenseDataSource.saveLicense(licenseJson);
  }

  Future<String> getMachineHash() async {
    return _machineIdentityService.getMachineHash();
  }

  Future<License?> _loadLicenseEntity() async {
    final model = await getLicenseModel();
    return model?.license;
  }
}
