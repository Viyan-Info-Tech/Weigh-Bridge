import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart' hide Weighment;
import '../../domain/entities/weighment.dart';

class BillLocalDataSource {
  final AppDatabase _database;

  BillLocalDataSource(this._database);

  /// Saves a brand new weighment, allocating its bill number from the database.
  ///
  /// The caller must not pass a bill number it generated itself: the number is
  /// read and consumed inside the same transaction as the insert, so the value
  /// returned here is the only one guaranteed to be both stored and unused.
  Future<({int id, String billNumber})> saveWeighmentWithNewBillNumber(
    Weighment weighment,
  ) async {
    final settings = await _database.appSettingsDao.getSettings();
    return _database.billDao.insertWeighmentWithNextBillNumber(
      (billNumber) => _toCompanion(weighment, billNumber),
      prefix: settings.billPrefix,
      digits: settings.billNumberDigits,
      startingNumber: settings.billStartingNumber,
    );
  }

  WeighmentsCompanion _toCompanion(Weighment weighment, String billNumber) {
    return WeighmentsCompanion.insert(
      billNumber: billNumber,
      vehicleNumber: weighment.vehicleNumber,
      firstWeightKg: weighment.firstWeightKg,
      firstWeightType: Value(weighment.firstWeightType),
      secondWeightKg: Value(weighment.secondWeightKg),
      secondWeightType: Value(weighment.secondWeightType),
      netWeightKg: Value(weighment.netWeightKg),
      material: Value(weighment.material),
      materialId: Value(weighment.materialId),
      charges: Value(weighment.charges),
      previousWeighmentId: Value(weighment.previousWeighmentId),
      remarks: Value(weighment.remarks),
      mobileNumber: Value(weighment.mobileNumber),
      weightUnit: Value(weighment.weightUnit),
      createdAt: Value(weighment.createdAt),
      updatedAt: Value(weighment.updatedAt),
    );
  }

  Future<int> saveWeighment(Weighment weighment) async {
    return _database.billDao.insertWeighment(
      _toCompanion(weighment, weighment.billNumber),
    );
  }

  Future<void> updateWeighment(int id, Weighment weighment) async {
    await _database.billDao.updateWeighment(
      id,
      WeighmentsCompanion(
        firstWeightKg: Value(weighment.firstWeightKg),
        firstWeightType: Value(weighment.firstWeightType),
        secondWeightKg: Value(weighment.secondWeightKg),
        secondWeightType: Value(weighment.secondWeightType),
        netWeightKg: Value(weighment.netWeightKg),
        material: Value(weighment.material),
        materialId: Value(weighment.materialId),
        charges: Value(weighment.charges),
        remarks: Value(weighment.remarks),
        mobileNumber: Value(weighment.mobileNumber),
        weightUnit: Value(weighment.weightUnit),
        updatedAt: Value(weighment.updatedAt),
      ),
    );
  }

  Future<List<Weighment>> getRecentBills({DateTime? date, int? limit}) async {
    final records = await _database.billDao.getRecentBills(
      date: date,
      limit: limit,
    );
    return records.map(_toEntity).toList();
  }

  Future<List<Weighment>> getRecentBillsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    int? limit,
  }) async {
    final records = await _database.billDao.getRecentBillsByDateRange(
      startDate: startDate,
      endDate: endDate,
      limit: limit,
    );
    return records.map(_toEntity).toList();
  }

  Future<Weighment?> getWeighmentById(int id) async {
    final record = await _database.billDao.getWeighmentById(id);
    if (record == null) return null;
    return _toEntity(record);
  }

  Future<Weighment?> getWeighmentByBillNumber(String billNumber) async {
    final record = await _database.billDao.getWeighmentByBillNumber(billNumber);
    if (record == null) return null;
    return _toEntity(record);
  }

  /// Most recent single-weight bill for this vehicle, or null.
  ///
  /// See [BillDao.getLatestSingleWeightWeighmentForVehicle] for the matching
  /// and eligibility rules; this method only maps the row onto the entity.
  Future<Weighment?> getLatestSingleWeightWeighmentForVehicle(
    String vehicleNumber,
  ) async {
    final record = await _database.billDao
        .getLatestSingleWeightWeighmentForVehicle(vehicleNumber);
    if (record == null) return null;
    return _toEntity(record);
  }

  Future<String> generateNextBillNumber() async {
    final settings = await _database.appSettingsDao.getSettings();
    return _database.appSettingsDao.generateNextBillNumber(
      prefix: settings.billPrefix,
      digits: settings.billNumberDigits,
      startingNumber: settings.billStartingNumber,
    );
  }

  Future<int> deleteWeighment(int id) async {
    return _database.billDao.deleteWeighment(id);
  }

  Weighment _toEntity(dynamic record) {
    var firstWeight = (record.firstWeightKg as num).toDouble();
    var firstType = (record.firstWeightType as String?) ?? 'GROSS';
    var secondWeight = (record.secondWeightKg as num?)?.toDouble();
    var secondType = record.secondWeightType as String?;

    // Self-heal legacy rows where first weight was stored as 0 and second weight had tare weight
    if (firstWeight == 0 && secondWeight != null && secondWeight > 0) {
      firstWeight = secondWeight;
      firstType = 'TARE';
      secondWeight = null;
      secondType = null;
    }

    final unit =
        (record.weightUnit as String?) ?? (firstWeight >= 500 ? 'kg' : 'ton');

    return Weighment(
      id: record.id,
      billNumber: record.billNumber,
      vehicleNumber: record.vehicleNumber,
      firstWeightKg: firstWeight,
      firstWeightType: firstType,
      secondWeightKg: secondWeight,
      secondWeightType: secondType,
      netWeightKg: (record.netWeightKg as num?)?.toDouble(),
      material: _readMaterial(record),
      materialId: _readMaterialId(record),
      charges: _readCharges(record),
      previousWeighmentId: _readPreviousWeighmentId(record),
      remarks: record.remarks as String?,
      mobileNumber: record.mobileNumber as String?,
      weightUnit: unit,
      createdAt: record.createdAt as DateTime,
      updatedAt: record.updatedAt as DateTime,
    );
  }

  /// Reads the optional `material` column, which may not exist on databases
  /// created before the schema-30 migration.
  String? _readMaterial(dynamic record) {
    // Drift data classes expose columns as getters; use a dynamic read so
    // pre-migration rows (or hand-built fakes without the field) yield null
    // instead of throwing.
    try {
      return (record as dynamic).material as String?;
    } catch (_) {
      return null;
    }
  }

  /// Reads the optional `charges` column, which may not exist on databases
  /// created before the schema-32 migration (legacy rows store NULL).
  double? _readCharges(dynamic record) {
    try {
      return ((record as dynamic).charges as num?)?.toDouble();
    } catch (_) {
      return null;
    }
  }

  /// Reads the optional `material_id` column, which may not exist on
  /// databases created before the schema-33 migration.
  int? _readMaterialId(dynamic record) {
    try {
      return (record as dynamic).materialId as int?;
    } catch (_) {
      return null;
    }
  }

  /// Reads the optional `previous_weighment_id` column, which may not exist
  /// on databases created before the schema-35 migration.
  int? _readPreviousWeighmentId(dynamic record) {
    try {
      return (record as dynamic).previousWeighmentId as int?;
    } catch (_) {
      return null;
    }
  }
}
