import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class LicenseLocalDataSource {
  static const String _licenseFileName = 'license.dat';

  Future<File> getLicenseFile() async {
    final directory = await getApplicationSupportDirectory();
    final filePath = p.join(directory.path, _licenseFileName);
    return File(filePath);
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
