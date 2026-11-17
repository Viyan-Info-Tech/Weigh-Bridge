import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Helper to resolve the storage directory for the Weighbridge application.
///
/// On Windows:
/// Automatically detects available drives. It prefers non-C drives (D:\, E:\, etc.)
/// and uses `<Drive>:\WeighbridgeData`.
/// If no secondary drive exists, it falls back to `C:\WeighbridgeData`
/// (or `getApplicationSupportDirectory()` if write access to C:\ root is restricted).
///
/// On other platforms (macOS, Linux, Android, iOS), it falls back to
/// `getApplicationSupportDirectory()`.
class AppStoragePath {
  static const String dataFolderName = 'WeighbridgeData';
  static const String databaseFileName = 'weighbridge.sqlite';

  /// Preferred drive letters in priority order for Windows.
  static const List<String> preferredDrives = [
    'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
    'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
  ];

  @visibleForTesting
  static Directory? overrideDataDirectory;

  /// Returns the resolved directory for storing application data.
  static Future<Directory> getDataDirectory() async {
    if (overrideDataDirectory != null) {
      return overrideDataDirectory!;
    }

    if (Platform.isWindows) {
      // 1. Try non-C drives (D:\, E:\, G:\, etc.)
      for (final letter in preferredDrives) {
        final driveRoot = Directory('$letter:\\');
        try {
          if (driveRoot.existsSync()) {
            final targetDir = Directory('$letter:\\$dataFolderName');
            if (!targetDir.existsSync()) {
              targetDir.createSync(recursive: true);
            }
            // Verify write permission with a test file
            final testFile = File(p.join(targetDir.path, '.write_test'));
            testFile.writeAsStringSync('test');
            testFile.deleteSync();

            return targetDir;
          }
        } catch (_) {
          // Drive might be read-only or inaccessible (e.g. optical drive); try next
          continue;
        }
      }

      // 2. Fallback to C:\WeighbridgeData
      try {
        final cDir = Directory('C:\\$dataFolderName');
        if (!cDir.existsSync()) {
          cDir.createSync(recursive: true);
        }
        final testFile = File(p.join(cDir.path, '.write_test'));
        testFile.writeAsStringSync('test');
        testFile.deleteSync();

        return cDir;
      } catch (_) {
        // Fallback to AppData if C:\ root is restricted
      }
    }

    // Default fallback for macOS, Linux, or restricted Windows
    final appSupport = await getApplicationSupportDirectory();
    final fallbackDir = Directory(p.join(appSupport.path, 'Weighbridge'));
    if (!fallbackDir.existsSync()) {
      fallbackDir.createSync(recursive: true);
    }
    return fallbackDir;
  }

  /// Returns the SQLite database file, migrating existing data from legacy
  /// AppData location if necessary.
  static Future<File> getDatabaseFile() async {
    final dataDir = await getDataDirectory();
    final targetFile = File(p.join(dataDir.path, databaseFileName));

    await migrateLegacyFileIfNeeded(
      legacySubPath: p.join('Weighbridge', databaseFileName),
      targetFile: targetFile,
      includeSqliteAuxFiles: true,
    );

    return targetFile;
  }

  /// Migrates a file from legacy AppData directory if the target file doesn't exist.
  static Future<void> migrateLegacyFileIfNeeded({
    required String legacySubPath,
    required File targetFile,
    bool includeSqliteAuxFiles = false,
  }) async {
    try {
      if (await targetFile.exists()) return;

      final appSupport = await getApplicationSupportDirectory();
      final legacyFile = File(p.join(appSupport.path, legacySubPath));

      if (await legacyFile.exists()) {
        if (!await targetFile.parent.exists()) {
          await targetFile.parent.create(recursive: true);
        }
        await legacyFile.copy(targetFile.path);

        if (includeSqliteAuxFiles) {
          final legacyWal = File('${legacyFile.path}-wal');
          if (await legacyWal.exists()) {
            await legacyWal.copy('${targetFile.path}-wal');
          }
          final legacyShm = File('${legacyFile.path}-shm');
          if (await legacyShm.exists()) {
            await legacyShm.copy('${targetFile.path}-shm');
          }
        }
      }
    } catch (_) {
      // Non-fatal if legacy migration fails
    }
  }
}
