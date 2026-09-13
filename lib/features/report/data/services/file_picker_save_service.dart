import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';

import '../../domain/services/file_save_service.dart';

class FilePickerSaveService implements FileSaveService {
  @override
  Future<String?> saveFile({
    required String suggestedFileName,
    required Uint8List bytes,
    required String mimeType,
  }) async {
    final savedUri = await FilePicker.saveFile(
      dialogTitle: 'Save Weighment Report',
      fileName: suggestedFileName,
      bytes: bytes,
      mimeType: mimeType,
    );

    if (savedUri == null) {
      return null;
    }

    return savedUri.toFilePath();
  }
}
