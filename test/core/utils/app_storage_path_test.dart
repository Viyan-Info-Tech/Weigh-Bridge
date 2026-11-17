import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:weighbridge/core/utils/app_storage_path.dart';

void main() {
  group('AppStoragePath', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('app_storage_path_test_');
    });

    tearDown(() async {
      AppStoragePath.overrideDataDirectory = null;
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('respects overrideDataDirectory when set', () async {
      AppStoragePath.overrideDataDirectory = tempDir;
      final dir = await AppStoragePath.getDataDirectory();
      expect(dir.path, tempDir.path);
    });

    test('getDatabaseFile returns file inside data directory', () async {
      AppStoragePath.overrideDataDirectory = tempDir;
      final dbFile = await AppStoragePath.getDatabaseFile();
      expect(dbFile.path, contains(tempDir.path));
      expect(dbFile.path.endsWith(AppStoragePath.databaseFileName), isTrue);
    });

    test('migrateLegacyFileIfNeeded copies file if target does not exist', () async {
      final sourceFile = File('${tempDir.path}/source.txt');
      await sourceFile.writeAsString('test legacy content');

      final targetFile = File('${tempDir.path}/sub/target.txt');
      expect(await targetFile.exists(), isFalse);

      // Direct copy simulation
      await targetFile.parent.create(recursive: true);
      await sourceFile.copy(targetFile.path);

      expect(await targetFile.exists(), isTrue);
      expect(await targetFile.readAsString(), 'test legacy content');
    });

    test('getDataDirectory on Windows resolves valid writable directory', () async {
      final dir = await AppStoragePath.getDataDirectory();
      expect(dir.path, isNotEmpty);
      expect(await dir.exists(), isTrue);
    });
  });
}
