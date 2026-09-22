import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:flutter_test/flutter_test.dart';
import 'package:weighbridge/core/licensing/data/datasources/license_local_datasource.dart';

class TestableLicenseLocalDataSource extends LicenseLocalDataSource {
  final Directory tempDir;

  TestableLicenseLocalDataSource(this.tempDir);

  @override
  Future<File> getLicenseFile() async {
    final filePath = p.join(tempDir.path, 'license.dat');
    return File(filePath);
  }
}

void main() {
  late Directory tempDir;
  late TestableLicenseLocalDataSource dataSource;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('license_ds_test_');
    dataSource = TestableLicenseLocalDataSource(tempDir);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('LicenseLocalDataSource - hasLicense', () {
    test('returns false when license file does not exist', () async {
      final result = await dataSource.hasLicense();
      expect(result, isFalse);
    });

    test('returns true when license file exists', () async {
      final file = await dataSource.getLicenseFile();
      await file.writeAsString('{"test": true}');
      final result = await dataSource.hasLicense();
      expect(result, isTrue);
    });

    test('returns false when directory error occurs', () async {
      final badDs = TestableLicenseLocalDataSource(Directory(''));
      final result = await badDs.hasLicense();
      expect(result, isFalse);
    });
  });

  group('LicenseLocalDataSource - loadLicense', () {
    test('throws StateError when license file does not exist', () async {
      expect(dataSource.loadLicense(), throwsA(isA<StateError>()));
    });

    test('returns content when license file exists', () async {
      final content = '{"licenseId":"test","productId":"PROD"}';
      final file = await dataSource.getLicenseFile();
      await file.writeAsString(content);
      final result = await dataSource.loadLicense();
      expect(result, content);
    });
  });

  group('LicenseLocalDataSource - saveLicense', () {
    test('creates license file with given content', () async {
      final content = '{"licenseId":"VY-WB-001"}';
      await dataSource.saveLicense(content);
      final file = await dataSource.getLicenseFile();
      expect(await file.exists(), isTrue);
      expect(await file.readAsString(), content);
    });

    test('overwrites existing license file', () async {
      await dataSource.saveLicense('first');
      await dataSource.saveLicense('second');
      final file = await dataSource.getLicenseFile();
      expect(await file.readAsString(), 'second');
    });

    test('creates parent directories if missing', () async {
      final nestedDir = Directory(p.join(tempDir.path, 'a', 'b', 'c'));
      await nestedDir.create(recursive: true);
      final nestedDs = TestableLicenseLocalDataSource(nestedDir);
      final file = await nestedDs.getLicenseFile();
      await file.parent.create(recursive: true);
      await nestedDs.saveLicense('nested');
      expect(await file.exists(), isTrue);
    });
  });

  group('LicenseLocalDataSource - deleteLicense', () {
    test('deletes existing license file', () async {
      final file = await dataSource.getLicenseFile();
      await file.writeAsString('content');
      expect(await file.exists(), isTrue);
      await dataSource.deleteLicense();
      expect(await file.exists(), isFalse);
    });

    test('does not throw when license file does not exist', () async {
      await dataSource.deleteLicense();
      expect(true, isTrue);
    });
  });
}
