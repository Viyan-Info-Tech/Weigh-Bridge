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
      grossCapturedAt: Value(weighment.grossCapturedAt),
      tareCapturedAt: Value(weighment.tareCapturedAt),
      material: Value(weighment.material),
      description: Value(weighment.description),
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
        grossCapturedAt: Value(weighment.grossCapturedAt),
        tareCapturedAt: Value(weighment.tareCapturedAt),
        material: Value(weighment.material),
        description: Value(weighment.description),
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

    final unit = (record.weightUnit as String?) ?? 'kg';

    return Weighment(
      id: record.id,
      billNumber: record.billNumber,
      vehicleNumber: record.vehicleNumber,
      firstWeightKg: firstWeight,
      firstWeightType: firstType,
      secondWeightKg: secondWeight,
      secondWeightType: secondType,
      netWeightKg: (record.netWeightKg as num?)?.toDouble(),
      grossCapturedAt: _readOptionalDateTime(record, 'grossCapturedAt'),
      tareCapturedAt: _readOptionalDateTime(record, 'tareCapturedAt'),
      material: _readOptionalString(record, 'material'),
      description: _readOptionalString(record, 'description'),
      remarks: record.remarks as String?,
      mobileNumber: record.mobileNumber as String?,
      weightUnit: unit,
      createdAt: record.createdAt as DateTime,
      updatedAt: record.updatedAt as DateTime,
    );
  }

  /// Reads a nullable string column that may not exist on databases created
  /// before the Material/Description migration (schema 30).
  String? _readOptionalString(dynamic record, String name) {
    try {
      final value = (record as dynamic);
      // Drift data classes expose columns as getters; use a dynamic read so
      // pre-migration rows (or hand-built fakes without the field) yield null
      // instead of throwing.
      if (name == 'material') {
        return (value.material as String?);
      }
      return (value.description as String?);
    } catch (_) {
      return null;
    }
  }

  /// Reads a nullable DateTime column that may not exist on databases created
  /// before the grossCapturedAt/tareCapturedAt migration (schema 32).
  DateTime? _readOptionalDateTime(dynamic record, String name) {
    try {
      final value = (record as dynamic);
      if (name == 'grossCapturedAt') {
        return (value.grossCapturedAt as DateTime?);
      }
      if (name == 'tareCapturedAt') {
        return (value.tareCapturedAt as DateTime?);
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
