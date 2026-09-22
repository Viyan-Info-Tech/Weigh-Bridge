import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:flutter_test/flutter_test.dart';
import 'package:weighbridge/core/licensing/data/datasources/clock_rollback_datasource.dart';

class TestableClockRollbackDataSource extends ClockRollbackDataSource {
  final Directory tempDir;

  TestableClockRollbackDataSource(this.tempDir);

  @override
  Future<File> getStateFile() async {
    final filePath = p.join(tempDir.path, 'license_state.dat');
    return File(filePath);
  }
}

void main() {
  late Directory tempDir;
  late TestableClockRollbackDataSource dataSource;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('clock_rollback_test_');
    dataSource = TestableClockRollbackDataSource(tempDir);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('ClockRollbackDataSource - loadState', () {
    test('returns null when state file does not exist', () async {
      final result = await dataSource.loadState();
      expect(result, isNull);
    });

    test('returns parsed state when file exists', () async {
      final state = {
        'lastKnownValidTime': '2026-09-21T10:00:00.000Z',
        'lastValidationTime': '2026-09-21T10:05:00.000Z',
      };
      final file = await dataSource.getStateFile();
      await file.writeAsString(jsonEncode(state));
      final result = await dataSource.loadState();
      expect(result, isNotNull);
      expect(result!['lastKnownValidTime'], state['lastKnownValidTime']);
      expect(result['lastValidationTime'], state['lastValidationTime']);
    });

    test('returns null for corrupt file content', () async {
      final file = await dataSource.getStateFile();
      await file.writeAsString('not valid json{{{');
      final result = await dataSource.loadState();
      expect(result, isNull);
    });

    test('returns null for empty file', () async {
      final file = await dataSource.getStateFile();
      await file.writeAsString('');
      final result = await dataSource.loadState();
      expect(result, isNull);
    });

    test('returns null when file is not a map', () async {
      final file = await dataSource.getStateFile();
      await file.writeAsString(jsonEncode('just a string'));
      final result = await dataSource.loadState();
      expect(result, isNull);
    });
  });

  group('ClockRollbackDataSource - saveState', () {
    test('writes state as JSON', () async {
      final state = {
        'lastKnownValidTime': '2026-09-21T10:00:00.000Z',
        'lastValidationTime': '2026-09-21T10:05:00.000Z',
      };
      await dataSource.saveState(state);
      final file = await dataSource.getStateFile();
      expect(await file.exists(), isTrue);
      final content =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      expect(content['lastKnownValidTime'], state['lastKnownValidTime']);
      expect(content['lastValidationTime'], state['lastValidationTime']);
    });

    test('creates parent directories if missing', () async {
      final nestedDir = Directory(p.join(tempDir.path, 'a', 'b', 'c'));
      final nestedDs = TestableClockRollbackDataSource(nestedDir);
      await nestedDs.saveState({
        'lastKnownValidTime': '2026-01-01T00:00:00.000Z',
      });
      final file = await nestedDs.getStateFile();
      expect(await file.exists(), isTrue);
    });

    test('overwrites previous state', () async {
      await dataSource.saveState({
        'lastKnownValidTime': '2026-01-01T00:00:00.000Z',
      });
      await dataSource.saveState({
        'lastKnownValidTime': '2026-06-01T00:00:00.000Z',
      });
      final result = await dataSource.loadState();
      expect(result!['lastKnownValidTime'], '2026-06-01T00:00:00.000Z');
    });
  });
}
