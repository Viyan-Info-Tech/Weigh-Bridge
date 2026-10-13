import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;

/// Supplies the fonts used by the weighbridge ticket.
///
/// The receipt is laid out in aligned columns, so it needs a monospaced face.
/// The PDF base-14 fonts (`pw.Font.courier()`) are monospaced but have no
/// Unicode coverage: any character outside Latin-1 - the rupee sign, en and em
/// dashes, smart quotes, Tamil text in a customer name - cannot be drawn, and
/// `pdf` logs "Courier has no Unicode support" for each one.
///
/// A TrueType font from the asset bundle fixes that. Drop these two files in
/// `assets/fonts/` and declare them under `flutter: assets:` to enable it:
///
/// ```
/// assets/fonts/NotoSansMono-Regular.ttf
/// assets/fonts/NotoSansMono-Bold.ttf
/// ```
///
/// Until then [load] falls back to Courier, so the ticket always renders and the
/// app never fails to build over a missing font.
class ReceiptPdfFonts {
  const ReceiptPdfFonts();

  static const String regularAsset = 'assets/fonts/NotoSansMono-Regular.ttf';
  static const String boldAsset = 'assets/fonts/NotoSansMono-Bold.ttf';

  /// Resolved once per process. Ticket printing is not hot, but the on-screen
  /// preview and the print button can both ask for fonts in quick succession.
  static pw.ThemeData? _cached;

  /// Returns a theme using Unicode-capable fonts when the assets are present,
  /// otherwise the original Courier theme.
  ///
  /// Never throws: a missing or unreadable asset degrades to Courier, which
  /// prints the ticket with Latin-1 only.
  static Future<pw.ThemeData> load() async {
    final cached = _cached;
    if (cached != null) return cached;

    final theme = await _loadUnicodeTheme() ?? _courierTheme();
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
      // Assets not bundled. Courier is the documented fallback.
      return null;
    }
  }
}
