import 'dart:io' show File, Platform, Process;
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
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
      return _openInSystemViewer(pdfBytes, jobName);
    }

    return printed;
  }

  /// Runs a print job whose page is built *after* the operator has chosen the
  /// printer, the paper size and the orientation.
  ///
  /// This is the path the pre-printed weighbridge certificate uses: the
  /// Windows print dialog reports back the real physical paper size and the
  /// printer's printable-area offsets, [onLayout] receives them as a
  /// [PdfPageFormat], and the PDF is laid out against those actual dimensions
  /// instead of a hard-coded page size. One call produces one coordinated job -
  /// for the dual-copy certificate both copies live on that single page.
  ///
  /// No browser or web preview is involved: on Windows this opens the native
  /// print dialog and streams the document straight to the selected printer.
  ///
  /// Returns `false` when the operator cancels the dialog or the job fails.
  Future<bool> printPdfLayout({
    required String jobName,
    required LayoutCallback onLayout,
    PdfPageFormat initialFormat = PdfPageFormat.a4,
  }) async {
    try {
      return await Printing.layoutPdf(
        name: jobName,
        onLayout: onLayout,
        format: initialFormat,
      );
    } catch (_) {
      // Native printing channel might not be connected in current debug
      // session (hot reload): build the document with the intended paper size
      // and hand it to the system viewer instead of losing the job.
      try {
        final pdfBytes = await onLayout(initialFormat);
        return _openInSystemViewer(pdfBytes, jobName);
      } catch (_) {
        return false;
      }
    }
  }

  /// Writes [pdfBytes] to a temp file and opens it with the default PDF
  /// handler. Only reached when the native print channel is unavailable.
  Future<bool> _openInSystemViewer(Uint8List pdfBytes, String jobName) async {
    if (kIsWeb || !Platform.isWindows) return false;
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
      return true;
    } catch (_) {
      return false;
    }
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
