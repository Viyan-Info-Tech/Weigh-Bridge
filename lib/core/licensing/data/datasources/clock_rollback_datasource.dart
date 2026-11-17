import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import '../../../utils/app_storage_path.dart';

class ClockRollbackDataSource {
  static const String _stateFileName = 'license_state.dat';

  Future<File> getStateFile() async {
    final directory = await AppStoragePath.getDataDirectory();
    final filePath = p.join(directory.path, _stateFileName);
    final file = File(filePath);

    await AppStoragePath.migrateLegacyFileIfNeeded(
      legacySubPath: _stateFileName,
      targetFile: file,
    );

    return file;
  }

  Future<Map<String, dynamic>?> loadState() async {
    try {
      final file = await getStateFile();
      if (!await file.exists()) return null;
      final content = await file.readAsString();
      final decoded = Map<String, dynamic>.from(json.decode(content));
      return decoded;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveState(Map<String, dynamic> state) async {
    final file = await getStateFile();
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode(state));
  }
}
