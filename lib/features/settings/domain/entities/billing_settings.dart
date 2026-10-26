import 'package:equatable/equatable.dart';

class BillingSettings extends Equatable {
  final String weightUnit;
  final String billPrefix;
  final int billStartingNumber;
  final int billNumberDigits;
  final String businessName;
  final String? businessSubtitle;
  final String? serviceText;
  final String? address;
  final String? phoneNumber;
  final String? email;
  final String? gstin;
  final String? logoPath;
  final String receiptTitle;
  final bool showSerialNumber;
  final bool showDate;
  final bool showTime;
  final bool showVehicleNumber;
  final bool showGrossWeight;
  final bool showTareWeight;
  final bool showNetWeight;
  final bool showRemarks;
  final bool showFooterNote;
  final String? footerNote;

  // ---------------------------------------------------------------------------
  // Continuous-form (pre-printed certificate) printing
  //
  // These values only position the dynamic weighment data on the client's
  // existing HMB Enterprises stationery; they never add company details, which
  // are already printed on the paper.
  // ---------------------------------------------------------------------------

  /// Characters per inch used for the ticket: 10 (classic dot-matrix) or 12
  /// (condensed fit). Values outside 1..20 are ignored by the layout.
  final int printCpi;

  /// Lines per inch used for the ticket: 6 or 8.
  final int printLpi;

  /// Custom paper width in millimetres. `0` means "use the paper size the
  /// printer driver reports in the print dialog".
  final double printPaperWidthMm;

  /// Custom paper length in millimetres. `0` means "use the printer default".
  final double printPaperLengthMm;

  /// Fine horizontal nudge, in millimetres, added to the printer's own
  /// printable-area left offset.
  final double printLeftOffsetMm;

  /// Fine vertical nudge, in millimetres, added to the printer's own
  /// printable-area top offset.
  final double printTopOffsetMm;

  /// Distance in millimetres between the left copy's origin and the right
  /// copy's origin. `0` means "half the printable width", which keeps the two
  /// copies balanced on whatever paper the driver reports.
  final double printColumnWidthMm;

  /// JSON grid of per-field character positions for the **left** copy, see
  /// `decodePrePrintedGrid` in `preprinted_ticket_layout.dart`.
  ///
  /// Historic name: before the two copies became independently tunable this
  /// was the only grid and both copies used it. It stays the left copy so
  /// existing saved settings keep their current alignment.
  final String? printFieldGrid;

  /// JSON grid of per-field character positions for the **right** copy.
  ///
  /// `null` means the right copy still shares [printFieldGrid], which is how
  /// settings saved before independent alignment existed are interpreted. Once
  /// either copy is tuned the settings screen persists both grids explicitly,
  /// so editing one copy never moves the other.
  final String? printRightFieldGrid;

  /// Whether the weight values carry their unit (`80.000 ton`) or print as a
  /// bare number (`80.000`) for forms whose unit is pre-printed.
  final bool printWeightUnit;

  final DateTime updatedAt;

  const BillingSettings({
    this.weightUnit = 'ton',
    this.billPrefix = 'WB',
    this.billStartingNumber = 1,
    this.billNumberDigits = 5,
    this.businessName = 'VIYAN WEIGHBRIDGE',
    this.businessSubtitle = 'Computer Weigh Bridge',
    this.serviceText = '24 HOURS SERVICE',
    this.address,
    this.phoneNumber,
    this.email,
    this.gstin,
    this.logoPath,
    this.receiptTitle = 'WEIGHMENT RECEIPT',
    this.showSerialNumber = true,
    this.showDate = true,
    this.showTime = true,
    this.showVehicleNumber = true,
    this.showGrossWeight = true,
    this.showTareWeight = true,
    this.showNetWeight = true,
    this.showRemarks = true,
    this.showFooterNote = true,
    this.footerNote = 'Please check the weight before leaving the weighbridge.',
    this.printCpi = 12,
    this.printLpi = 6,
    this.printPaperWidthMm = 0,
    this.printPaperLengthMm = 0,
    this.printLeftOffsetMm = 0,
    this.printTopOffsetMm = 0,
    this.printColumnWidthMm = 0,
    this.printFieldGrid,
    this.printRightFieldGrid,
    this.printWeightUnit = true,
    required this.updatedAt,
  });

  String get billPreview {
    final number = billStartingNumber.toString().padLeft(billNumberDigits, '0');
    return '$billPrefix-$number';
  }

  BillingSettings copyWith({
    String? weightUnit,
    String? billPrefix,
    int? billStartingNumber,
    int? billNumberDigits,
    String? businessName,
    String? businessSubtitle,
    bool clearBusinessSubtitle = false,
    String? serviceText,
    bool clearServiceText = false,
    String? address,
    bool clearAddress = false,
    String? phoneNumber,
    bool clearPhoneNumber = false,
    String? email,
    bool clearEmail = false,
    String? gstin,
    bool clearGstin = false,
    String? logoPath,
    bool clearLogoPath = false,
    String? receiptTitle,
    bool? showSerialNumber,
    bool? showDate,
    bool? showTime,
    bool? showVehicleNumber,
    bool? showGrossWeight,
    bool? showTareWeight,
    bool? showNetWeight,
    bool? showRemarks,
    bool? showFooterNote,
    String? footerNote,
    bool clearFooterNote = false,
    int? printCpi,
    int? printLpi,
    double? printPaperWidthMm,
    double? printPaperLengthMm,
    double? printLeftOffsetMm,
    double? printTopOffsetMm,
    double? printColumnWidthMm,
    String? printFieldGrid,
    bool clearPrintFieldGrid = false,
    String? printRightFieldGrid,
    bool clearPrintRightFieldGrid = false,
    bool? printWeightUnit,
    DateTime? updatedAt,
  }) {
    return BillingSettings(
      weightUnit: weightUnit ?? this.weightUnit,
      billPrefix: billPrefix ?? this.billPrefix,
      billStartingNumber: billStartingNumber ?? this.billStartingNumber,
      billNumberDigits: billNumberDigits ?? this.billNumberDigits,
      businessName: businessName ?? this.businessName,
      businessSubtitle: clearBusinessSubtitle
          ? null
          : (businessSubtitle ?? this.businessSubtitle),
      serviceText: clearServiceText ? null : (serviceText ?? this.serviceText),
      address: clearAddress ? null : (address ?? this.address),
      phoneNumber: clearPhoneNumber ? null : (phoneNumber ?? this.phoneNumber),
      email: clearEmail ? null : (email ?? this.email),
      gstin: clearGstin ? null : (gstin ?? this.gstin),
      logoPath: clearLogoPath ? null : (logoPath ?? this.logoPath),
      receiptTitle: receiptTitle ?? this.receiptTitle,
      showSerialNumber: showSerialNumber ?? this.showSerialNumber,
      showDate: showDate ?? this.showDate,
      showTime: showTime ?? this.showTime,
      showVehicleNumber: showVehicleNumber ?? this.showVehicleNumber,
      showGrossWeight: showGrossWeight ?? this.showGrossWeight,
      showTareWeight: showTareWeight ?? this.showTareWeight,
      showNetWeight: showNetWeight ?? this.showNetWeight,
      showRemarks: showRemarks ?? this.showRemarks,
      showFooterNote: showFooterNote ?? this.showFooterNote,
      footerNote: clearFooterNote ? null : (footerNote ?? this.footerNote),
      printCpi: printCpi ?? this.printCpi,
      printLpi: printLpi ?? this.printLpi,
      printPaperWidthMm: printPaperWidthMm ?? this.printPaperWidthMm,
      printPaperLengthMm: printPaperLengthMm ?? this.printPaperLengthMm,
      printLeftOffsetMm: printLeftOffsetMm ?? this.printLeftOffsetMm,
      printTopOffsetMm: printTopOffsetMm ?? this.printTopOffsetMm,
      printColumnWidthMm: printColumnWidthMm ?? this.printColumnWidthMm,
      printFieldGrid: clearPrintFieldGrid
          ? null
          : (printFieldGrid ?? this.printFieldGrid),
      printRightFieldGrid: clearPrintRightFieldGrid
          ? null
          : (printRightFieldGrid ?? this.printRightFieldGrid),
      printWeightUnit: printWeightUnit ?? this.printWeightUnit,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    weightUnit,
    billPrefix,
    billStartingNumber,
    billNumberDigits,
    businessName,
    businessSubtitle,
    serviceText,
    address,
    phoneNumber,
    email,
    gstin,
    logoPath,
    receiptTitle,
    showSerialNumber,
    showDate,
    showTime,
    showVehicleNumber,
    showGrossWeight,
    showTareWeight,
    showNetWeight,
    showRemarks,
    showFooterNote,
    footerNote,
    printCpi,
    printLpi,
    printPaperWidthMm,
    printPaperLengthMm,
    printLeftOffsetMm,
    printTopOffsetMm,
    printColumnWidthMm,
    printFieldGrid,
    printRightFieldGrid,
    printWeightUnit,
    updatedAt,
  ];
}
