import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart' hide Weighment;
import '../../domain/entities/weighment.dart';

class BillLocalDataSource {
  final AppDatabase _database;

  BillLocalDataSource(this._database);

  Future<int> saveWeighment(Weighment weighment) async {
    return _database.billDao.insertWeighment(
      WeighmentsCompanion.insert(
        billNumber: weighment.billNumber,
        partyId: weighment.partyId,
        vehicleId: weighment.vehicleId,
        materialId: weighment.materialId,
        paymentMode: weighment.paymentMode,
        firstWeightKg: weighment.firstWeightKg,
        firstWeightType: Value(weighment.firstWeightType),
        secondWeightKg: Value(weighment.secondWeightKg),
        secondWeightType: Value(weighment.secondWeightType),
        netWeightKg: Value(weighment.netWeightKg),
        vehicleCharge: Value(weighment.vehicleCharge),
        amount: Value(weighment.amount),
        remarks: Value(weighment.remarks),
        status: Value(weighment.status),
      ),
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
        vehicleCharge: Value(weighment.vehicleCharge),
        amount: Value(weighment.amount),
        status: Value(weighment.status),
        remarks: Value(weighment.remarks),
        updatedAt: Value(DateTime.now()),
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

  Future<List<Weighment>> getPendingBills() async {
    final records = await _database.billDao.getPendingBills();
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

    return Weighment(
      id: record.id,
      billNumber: record.billNumber,
      partyId: record.partyId,
      vehicleId: record.vehicleId,
      materialId: record.materialId,
      paymentMode: record.paymentMode,
      firstWeightKg: firstWeight,
      firstWeightType: firstType,
      secondWeightKg: secondWeight,
      secondWeightType: secondType,
      netWeightKg: (record.netWeightKg as num?)?.toDouble(),
      vehicleCharge: (record.vehicleCharge as num).toDouble(),
      amount: (record.amount as num).toDouble(),
      remarks: record.remarks as String?,
      status: record.status as String,
      createdAt: record.createdAt as DateTime,
      updatedAt: record.updatedAt as DateTime,
    );
  }
}
