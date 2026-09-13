import 'dart:typed_data';

abstract class FileSaveService {
  /// Opens a native save file dialog allowing the user to select location & edit filename.
  /// Writes [bytes] to the chosen location.
  /// Returns the saved absolute file path on success, or null if the user cancelled.
  Future<String?> saveFile({
    required String suggestedFileName,
    required Uint8List bytes,
    required String mimeType,
  });
}
