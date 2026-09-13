import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

import '../../domain/entities/weighment_report_item.dart';

class CsvExporter {
  static Future<String?> exportReportToCsv({
    required BuildContext context,
    required List<WeighmentReportItem> records,
  }) async {
    if (records.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No records to export.'),
          backgroundColor: Color(0xFFD97706),
        ),
      );
      return null;
    }

    try {
      final buffer = StringBuffer();

      // CSV Header
      buffer.writeln(
        'Bill No,Date,Time,Vehicle,Vehicle Type,Party,Material,First Weight (kg),First Type,Second Weight (kg),Second Type,Gross Weight (kg),Tare Weight (kg),Net Weight (kg),Amount (INR),Payment Mode,Status,Remarks',
      );

      final dateFormat = DateFormat('dd/MM/yyyy');
      final timeFormat = DateFormat('hh:mm a');

      for (final item in records) {
        final dateStr = dateFormat.format(item.createdAt);
        final timeStr = timeFormat.format(item.createdAt);
        final grossStr = item.grossWeightKg?.toStringAsFixed(1) ?? '';
        final tareStr = item.tareWeightKg?.toStringAsFixed(1) ?? '';
        final netStr = item.netWeightKg?.toStringAsFixed(1) ?? '';
        final secondWeightStr = item.secondWeightKg?.toStringAsFixed(1) ?? '';

        final line = [
          _escape(item.billNumber),
          _escape(dateStr),
          _escape(timeStr),
          _escape(item.vehicleNumber),
          _escape(item.vehicleTypeName),
          _escape(item.partyName),
          _escape(item.materialName),
          item.firstWeightKg.toStringAsFixed(1),
          _escape(item.firstWeightType),
          secondWeightStr,
          _escape(item.secondWeightType ?? ''),
          grossStr,
          tareStr,
          netStr,
          item.amount.toStringAsFixed(2),
          _escape(item.paymentMode),
          _escape(item.displayStatus),
          _escape(item.remarks ?? ''),
        ].join(',');

        buffer.writeln(line);
      }

      // Determine output path (Downloads folder or user home)
      final home = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
      Directory exportDir;
      if (home != null) {
        final downloads = Directory(p.join(home, 'Downloads'));
        if (await downloads.exists()) {
          exportDir = downloads;
        } else {
          exportDir = Directory(home);
        }
      } else {
        exportDir = Directory.current;
      }

      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'weighment_report_$timestamp.csv';
      final file = File(p.join(exportDir.path, fileName));

      await file.writeAsString(buffer.toString());

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Exported ${records.length} records to ${file.path}',
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF16A34A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            duration: const Duration(seconds: 4),
          ),
        );
      }

      return file.path;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export CSV: $e'),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
      return null;
    }
  }

  static String _escape(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
