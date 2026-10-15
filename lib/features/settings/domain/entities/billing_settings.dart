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
  final DateTime updatedAt;

  const BillingSettings({
    this.weightUnit = 'kg',
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
    updatedAt,
  ];
}
