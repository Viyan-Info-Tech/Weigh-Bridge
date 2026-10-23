import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;

class ReceiptPdfFonts {
  const ReceiptPdfFonts();

  static const String regularAsset = 'fonts/PlusJakartaSans-Regular.ttf';
  static const String boldAsset = 'fonts/PlusJakartaSans-Bold.ttf';

  static pw.ThemeData? _cached;

  static bool _unicodeSupported = false;

  static bool get unicodeSupported => _unicodeSupported;

  static Future<pw.ThemeData> load() async {
    final cached = _cached;
    if (cached != null) return cached;

    final unicodeTheme = await _loadUnicodeTheme();

    _unicodeSupported = unicodeTheme != null;

    final theme = unicodeTheme ?? _courierTheme();
    _cached = theme;

    return theme;
  }

  static pw.ThemeData _courierTheme() {
    return pw.ThemeData.withFont(
      base: pw.Font.courier(),
      bold: pw.Font.courierBold(),
    );
  }

  static Future<pw.ThemeData?> _loadUnicodeTheme() async {
    try {
      final regular = pw.Font.ttf(await rootBundle.load(regularAsset));

      final bold = pw.Font.ttf(await rootBundle.load(boldAsset));

      return pw.ThemeData.withFont(base: regular, bold: bold);
    } catch (_) {
      return null;
    }
  }
}
