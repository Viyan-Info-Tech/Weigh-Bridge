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
        secondWeightKg: Value(weighment.secondWeightKg),
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
        secondWeightKg: Value(weighment.secondWeightKg),
        netWeightKg: Value(weighment.netWeightKg),
        vehicleCharge: Value(weighment.vehicleCharge),
        amount: Value(weighment.amount),
        status: Value(weighment.status),
        remarks: Value(weighment.remarks),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<List<Weighment>> getRecentBills({int limit = 20}) async {
    final records = await _database.billDao.getRecentBills(limit: limit);
    return records.map(_toEntity).toList();
  }

  Future<List<Weighment>> getPendingBills() async {
    final records = await _database.billDao.getPendingBills();
    return records.map(_toEntity).toList();
  }

  Future<Weighment?> getWeighmentById(int id) async {
    final record = await _database.billDao.getWeighmentById(id);
    if (record == null) return null;
    return _toEntity(record);
  }

  Future<String> generateNextBillNumber() async {
    return _database.billDao.generateNextBillNumber();
  }

  Future<int> deleteWeighment(int id) async {
    return _database.billDao.deleteWeighment(id);
  }

  Weighment _toEntity(dynamic record) {
    return Weighment(
      id: record.id,
      billNumber: record.billNumber,
      partyId: record.partyId,
      vehicleId: record.vehicleId,
      materialId: record.materialId,
      paymentMode: record.paymentMode,
      firstWeightKg: record.firstWeightKg,
      secondWeightKg: record.secondWeightKg,
      netWeightKg: record.netWeightKg,
      vehicleCharge: record.vehicleCharge,
      amount: record.amount,
      remarks: record.remarks,
      status: record.status,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
    );
  }
}
