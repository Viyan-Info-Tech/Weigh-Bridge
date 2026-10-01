import 'dart:io' show File, Platform, Process;
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';

/// Single printer pipeline shared by every print job in the app.
///
/// Both the report printing and the weighment ticket printing go through
/// this service so they use the same printer connection and the same
/// Windows fallback behaviour.
class PrintService {
  const PrintService();

  /// Hands [pdfBytes] to the OS print pipeline.
  ///
  /// Returns `true` when the job reached the printer (or the Windows
  /// fallback opened the document in the system viewer).
  Future<bool> printPdf(Uint8List pdfBytes, {required String jobName}) async {
    var printed = false;
    try {
      // Open standard OS print preview & printer selection dialog
      printed = await Printing.layoutPdf(
        name: jobName,
        onLayout: (_) async => pdfBytes,
      );
    } catch (_) {
      // Native printing channel might not be connected in current debug session
    }

    // Windows fallback if native platform channel is disconnected in hot-reload
    if (!printed && !kIsWeb && Platform.isWindows) {
      try {
        final tempDir = await getTemporaryDirectory();
        final tempFile = File(
          '${tempDir.path}\\$jobName-${DateTime.now().millisecondsSinceEpoch}.pdf',
        );
        await tempFile.writeAsBytes(pdfBytes);
        await Process.run('rundll32', [
          'url.dll,FileProtocolHandler',
          tempFile.path,
        ]);
        printed = true;
      } catch (_) {}
    }

    return printed;
  }

  /// Checks whether the OS reports at least one usable printer.
  ///
  /// Returns `false` when no printer is installed, when enumeration fails
  /// or when the platform channel does not answer in time.
  Future<bool> isPrinterAvailable() async {
    try {
      final printers = await Printing.listPrinters().timeout(
        const Duration(seconds: 5),
      );
      return printers.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
