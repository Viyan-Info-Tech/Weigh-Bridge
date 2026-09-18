import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ClockRollbackDataSource {
  static const String _stateFileName = 'license_state.dat';

  Future<File> getStateFile() async {
    final directory = await getApplicationSupportDirectory();
    final filePath = p.join(directory.path, _stateFileName);
    return File(filePath);
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
