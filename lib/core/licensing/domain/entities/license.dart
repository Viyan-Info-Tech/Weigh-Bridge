class License {
  final String licenseId;
  final String productId;
  final String customerId;
  final String customerName;
  final String machineHash;
  final DateTime issuedAt;
  final DateTime expiresAt;
  final String licenseType;
  final int licenseVersion;
  final String signature;

  const License({
    required this.licenseId,
    required this.productId,
    required this.customerId,
    required this.customerName,
    required this.machineHash,
    required this.issuedAt,
    required this.expiresAt,
    required this.licenseType,
    required this.licenseVersion,
    required this.signature,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Map<String, dynamic> toPayload() {
    return {
      'licenseId': licenseId,
      'productId': productId,
      'customerId': customerId,
      'customerName': customerName,
      'machineHash': machineHash,
      'issuedAt': issuedAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'licenseType': licenseType,
      'licenseVersion': licenseVersion,
    };
  }

  License copyWith({
    String? licenseId,
    String? productId,
    String? customerId,
    String? customerName,
    String? machineHash,
    DateTime? issuedAt,
    DateTime? expiresAt,
    String? licenseType,
    int? licenseVersion,
    String? signature,
  }) {
    return License(
      licenseId: licenseId ?? this.licenseId,
      productId: productId ?? this.productId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      machineHash: machineHash ?? this.machineHash,
      issuedAt: issuedAt ?? this.issuedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      licenseType: licenseType ?? this.licenseType,
      licenseVersion: licenseVersion ?? this.licenseVersion,
      signature: signature ?? this.signature,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is License &&
          runtimeType == other.runtimeType &&
          licenseId == other.licenseId &&
          productId == other.productId &&
          customerId == other.customerId &&
          customerName == other.customerName &&
          machineHash == other.machineHash &&
          issuedAt == other.issuedAt &&
          expiresAt == other.expiresAt &&
          licenseType == other.licenseType &&
          licenseVersion == other.licenseVersion;

  @override
  int get hashCode =>
      licenseId.hashCode ^
      productId.hashCode ^
      customerId.hashCode ^
      customerName.hashCode ^
      machineHash.hashCode ^
      issuedAt.hashCode ^
      expiresAt.hashCode ^
      licenseType.hashCode ^
      licenseVersion.hashCode;

  @override
  String toString() {
    return 'License(licenseId: $licenseId, productId: $productId, customerId: $customerId, customerName: $customerName, machineHash: $machineHash, issuedAt: $issuedAt, expiresAt: $expiresAt, licenseType: $licenseType, licenseVersion: $licenseVersion)';
  }
}
