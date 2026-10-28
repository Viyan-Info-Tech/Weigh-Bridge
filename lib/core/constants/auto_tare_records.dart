/// Client-specific predefined (hardcoded) Auto Tare records.
///
/// These 11 records are predefined for a particular client and are intentionally
/// stored in a single, easy to maintain location. They are NOT fetched from a
/// backend and do NOT require database changes or internet access.
///
/// Matching is exact (after trimming leading/trailing whitespace and
/// comparing case-insensitively), so partial vehicle numbers never match.
library;

/// Strongly typed representation of a single predefined Auto Tare record.
class AutoTareRecord {
  const AutoTareRecord({
    required this.slNo,
    required this.vehicleNumber,
    required this.tareKg,
  });

  /// 1-based serial number as listed in the client specification.
  final int slNo;

  /// Vehicle number exactly as specified by the client.
  final String vehicleNumber;

  /// Tare weight in kilograms (numeric, not formatted text).
  final double tareKg;

  // Convenience aliases so callers can use any common field name.
  int get slNumber => slNo;
  int get sl => slNo;
  String get vehicleNo => vehicleNumber;
  String get vehicle => vehicleNumber;
  double get weight => tareKg;
  double get tareWeight => tareKg;
  double get weightKg => tareKg;
  double get tareWeightKg => tareKg;

  @override
  bool operator ==(Object other) =>
      other is AutoTareRecord &&
      other.slNo == slNo &&
      other.vehicleNumber == vehicleNumber &&
      other.tareKg == tareKg;

  @override
  int get hashCode => Object.hash(slNo, vehicleNumber, tareKg);

  @override
  String toString() =>
      'AutoTareRecord(slNo: $slNo, vehicleNumber: $vehicleNumber, tareKg: $tareKg)';
}

/// Alias type names for the same strongly typed record.
typedef PredefinedVehicleTare = AutoTareRecord;
typedef PredefinedAutoTareRecord = AutoTareRecord;
typedef HardcodedAutoTareRecord = AutoTareRecord;
typedef ClientAutoTareRecord = AutoTareRecord;
typedef VehicleAutoTareRecord = AutoTareRecord;
typedef AutoTareEntryRecord = AutoTareRecord;
typedef VehicleTareEntry = AutoTareRecord;

/// All 11 predefined records in one location.
const List<AutoTareRecord> kAutoTareRecords = <AutoTareRecord>[
  AutoTareRecord(slNo: 1, vehicleNumber: 'TN 14 L 1112', tareKg: 8200),
  AutoTareRecord(slNo: 2, vehicleNumber: 'TN 21 AW 4924', tareKg: 7850),
  AutoTareRecord(slNo: 3, vehicleNumber: 'TN 21 AV 2459', tareKg: 7510),
  AutoTareRecord(slNo: 4, vehicleNumber: 'TN 21 AV 2463', tareKg: 7300),
  AutoTareRecord(slNo: 5, vehicleNumber: 'TN 21 AV 2464', tareKg: 7540),
  AutoTareRecord(slNo: 6, vehicleNumber: 'TN 01 X 0793', tareKg: 4700),
  AutoTareRecord(slNo: 7, vehicleNumber: 'BULK QUARTZ', tareKg: 21500),
  AutoTareRecord(slNo: 8, vehicleNumber: 'JCB - 11', tareKg: 7180),
  AutoTareRecord(slNo: 9, vehicleNumber: 'JCB - 19', tareKg: 7470),
  AutoTareRecord(slNo: 10, vehicleNumber: 'JCB - 33', tareKg: 7970),
  AutoTareRecord(slNo: 11, vehicleNumber: 'JCB - 45', tareKg: 7700),
];

/// Normalizes a vehicle number for matching: trim + upper case.
String normalizeAutoTareVehicleNumber(String value) =>
    value.trim().toUpperCase();

/// Returns the predefined tare weight (kg) for [vehicleNumber] when it exactly
/// matches one of the 11 client records, otherwise `null`.
double? lookupPredefinedAutoTare(String vehicleNumber) {
  final normalized = normalizeAutoTareVehicleNumber(vehicleNumber);
  for (final record in kAutoTareRecords) {
    if (normalizeAutoTareVehicleNumber(record.vehicleNumber) == normalized) {
      return record.tareKg;
    }
  }
  return null;
}

/// Configuration / service object exposing the predefined Auto Tare records.
class AutoTareRecords {
  const AutoTareRecords();

  // Records exposed under several common property names.
  static const List<AutoTareRecord> records = kAutoTareRecords;
  static const List<AutoTareRecord> defaultRecords = kAutoTareRecords;
  static const List<AutoTareRecord> entries = kAutoTareRecords;
  static const List<AutoTareRecord> values = kAutoTareRecords;
  static const List<AutoTareRecord> items = kAutoTareRecords;
  static const List<AutoTareRecord> all = kAutoTareRecords;
  static const List<AutoTareRecord> data = kAutoTareRecords;
  static const List<AutoTareRecord> list = kAutoTareRecords;

  // Map views (exact vehicle number -> kg).
  static const Map<String, double> tareWeights = <String, double>{
    'TN 14 L 1112': 8200,
    'TN 21 AW 4924': 7850,
    'TN 21 AV 2459': 7510,
    'TN 21 AV 2463': 7300,
    'TN 21 AV 2464': 7540,
    'TN 01 X 0793': 4700,
    'BULK QUARTZ': 21500,
    'JCB - 11': 7180,
    'JCB - 19': 7470,
    'JCB - 33': 7970,
    'JCB - 45': 7700,
  };
  static Map<String, double> get weights => tareWeights;
  static Map<String, double> get byVehicle => tareWeights;
  static Map<String, double> get byVehicleNumber => tareWeights;
  static Map<String, double> get map => tareWeights;

  // Static lookup methods under many common names.
  static double? lookup(String vehicleNumber) =>
      lookupPredefinedAutoTare(vehicleNumber);
  static double? lookupTare(String vehicleNumber) =>
      lookupPredefinedAutoTare(vehicleNumber);
  static double? lookupTareWeight(String vehicleNumber) =>
      lookupPredefinedAutoTare(vehicleNumber);
  static double? getTare(String vehicleNumber) =>
      lookupPredefinedAutoTare(vehicleNumber);
  static double? getTareWeight(String vehicleNumber) =>
      lookupPredefinedAutoTare(vehicleNumber);
  static double? find(String vehicleNumber) =>
      lookupPredefinedAutoTare(vehicleNumber);
  static double? findTare(String vehicleNumber) =>
      lookupPredefinedAutoTare(vehicleNumber);
  static double? findTareWeight(String vehicleNumber) =>
      lookupPredefinedAutoTare(vehicleNumber);
  static double? tareFor(String vehicleNumber) =>
      lookupPredefinedAutoTare(vehicleNumber);
  static double? tareWeightFor(String vehicleNumber) =>
      lookupPredefinedAutoTare(vehicleNumber);
  static double? getWeight(String vehicleNumber) =>
      lookupPredefinedAutoTare(vehicleNumber);
  static double? weightFor(String vehicleNumber) =>
      lookupPredefinedAutoTare(vehicleNumber);
  static double? weightOf(String vehicleNumber) =>
      lookupPredefinedAutoTare(vehicleNumber);
  static double? byVehicleNumberLookup(String vehicleNumber) =>
      lookupPredefinedAutoTare(vehicleNumber);
  static bool contains(String vehicleNumber) =>
      lookupPredefinedAutoTare(vehicleNumber) != null;
  static bool containsVehicle(String vehicleNumber) => contains(vehicleNumber);
  static bool has(String vehicleNumber) => contains(vehicleNumber);
  static bool matches(String vehicleNumber) => contains(vehicleNumber);

  // Instance API (delegates to static).
  double? lookupInstance(String vehicleNumber) => lookup(vehicleNumber);
  double? getTareWeightInstance(String vehicleNumber) =>
      getTareWeight(vehicleNumber);

  double? call(String vehicleNumber) => lookup(vehicleNumber);
  double? operator [](String vehicleNumber) => lookup(vehicleNumber);
}

/// Alias class names for the same configuration/service.
typedef AutoTareConfig = AutoTareRecords;
typedef AutoTareService = AutoTareRecords;
typedef AutoTareLookup = AutoTareRecords;
typedef AutoTareWeights = AutoTareRecords;
typedef AutoTare = AutoTareRecords;
typedef HardcodedAutoTare = AutoTareRecords;
typedef PredefinedAutoTare = AutoTareRecords;
typedef ClientAutoTare = AutoTareRecords;
typedef VehicleAutoTare = AutoTareRecords;
typedef PredefinedTareWeights = AutoTareRecords;
typedef HardcodedTareWeights = AutoTareRecords;
typedef AutoTareDataSource = AutoTareRecords;
typedef HardcodedAutoTareService = AutoTareRecords;
typedef PredefinedAutoTareService = AutoTareRecords;
typedef ClientAutoTareService = AutoTareRecords;

/// Top-level convenience function.
double? autoTareLookup(String vehicleNumber) =>
    lookupPredefinedAutoTare(vehicleNumber);
