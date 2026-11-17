import 'dart:io';
import 'package:path/path.dart' as p;
import '../../../utils/app_storage_path.dart';

class LicenseLocalDataSource {
  static const String _licenseFileName = 'license.dat';

  Future<File> getLicenseFile() async {
    final directory = await AppStoragePath.getDataDirectory();
    final filePath = p.join(directory.path, _licenseFileName);
    final file = File(filePath);

    await AppStoragePath.migrateLegacyFileIfNeeded(
      legacySubPath: _licenseFileName,
      targetFile: file,
    );

    return file;
  }

  Future<bool> hasLicense() async {
    try {
      final file = await getLicenseFile();
      return await file.exists();
    } catch (_) {
      return false;
    }
  }

  Future<String> loadLicense() async {
    final file = await getLicenseFile();
    if (!await file.exists()) {
      throw StateError('No license file found');
    }
    return file.readAsString();
  }

  Future<void> saveLicense(String licenseJson) async {
    final file = await getLicenseFile();
    await file.parent.create(recursive: true);
    await file.writeAsString(licenseJson);
  }

  Future<void> deleteLicense() async {
    final file = await getLicenseFile();
    if (await file.exists()) {
      await file.delete();
    }
  }
}
