import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

class ReportExportListener {
  ReportExportListener._();

  static Future<void> showExportFailureDialog(
    BuildContext context,
    String title,
    String? message, {
    bool isError = false,
  }) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: isError ? const Color(0xFFDC2626) : null,
          ),
        ),
        content: Text(
          message ??
              'There are no weighment records matching the selected filters.',
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 13,
            color: Color(0xFF475569),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(
              'OK',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w700,
                color: Color(0xFF0284C7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void openFolder(String filePath) {
    try {
      if (Platform.isMacOS) {
        Process.run('open', ['-R', filePath]);
      } else if (Platform.isWindows) {
        Process.run('explorer.exe', ['/select,', filePath]);
      } else if (Platform.isLinux) {
        Process.run('xdg-open', [p.dirname(filePath)]);
      }
    } catch (e) {
      debugPrint('Error opening folder: $e');
    }
  }
}
