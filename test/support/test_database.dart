import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weighbridge/core/database/app_database.dart';

/// Creates an isolated in-memory database for a single test.
///
/// Every test must create its own instance and close it in `tearDown`.
AppDatabase createInMemoryDatabase() {
  return AppDatabase.forTesting(NativeDatabase.memory());
}

/// Seeding helpers for the tests in this package.

Future<int> seedParty(
  AppDatabase db, {
  required String name,
  String? mobile,
  String? contactPerson,
  String? gstNumber,
  String? city,
  String? state,
  bool isActive = true,
}) {
  return db.partyDao.insertParty(
    PartiesCompanion.insert(
      name: name,
      mobile: Value(mobile),
      contactPerson: Value(contactPerson),
      gstNumber: Value(gstNumber),
      city: Value(city),
      state: Value(state),
      isActive: Value(isActive),
    ),
  );
}

Future<int> seedVehicleType(
  AppDatabase db, {
  required String name,
  double emptyPrice = 0,
  double loadPrice = 0,
  bool isActive = true,
}) {
  return db.vehicleTypeDao.insertVehicleType(
    VehicleTypesCompanion.insert(
      name: name,
      emptyPrice: Value(emptyPrice),
      loadPrice: Value(loadPrice),
      isActive: Value(isActive),
    ),
  );
}

Future<int> seedVehicle(
  AppDatabase db, {
  required String vehicleNumber,
  required int vehicleTypeId,
  String? driverName,
  String? driverPhone,
  bool isActive = true,
}) {
  return db.vehicleDao.insertVehicle(
    VehiclesCompanion.insert(
      vehicleNumber: vehicleNumber,
      vehicleTypeId: vehicleTypeId,
      driverName: Value(driverName),
      driverPhone: Value(driverPhone),
      isActive: Value(isActive),
    ),
  );
}

Future<int> seedMaterial(
  AppDatabase db, {
  required String name,
  String? category,
  bool isActive = true,
}) {
  return db.materialDao.insertMaterial(
    MaterialsCompanion.insert(
      name: name,
      category: Value(category),
      isActive: Value(isActive),
    ),
  );
}

/// Seeds all parent records needed to insert a weighment and returns
/// their ids.
Future<SeededRefs> seedParents(AppDatabase db) async {
  final partyId = await seedParty(db, name: 'Seed Party', mobile: '9000000000');
  final vehicleTypeId = await seedVehicleType(db, name: 'Truck');
  final vehicleId = await seedVehicle(
    db,
    vehicleNumber: 'TN31SEED01',
    vehicleTypeId: vehicleTypeId,
    driverName: 'Driver',
  );
  final materialId = await seedMaterial(db, name: 'Cement');
  return SeededRefs(
    partyId: partyId,
    vehicleTypeId: vehicleTypeId,
    vehicleId: vehicleId,
    materialId: materialId,
  );
}

Future<int> seedWeighment(
  AppDatabase db, {
  required int partyId,
  required int vehicleId,
  required int materialId,
  required String billNumber,
  String paymentMode = 'cash',
  double firstWeightKg = 0,
  String firstWeightType = 'GROSS',
  double? secondWeightKg,
  String? secondWeightType,
  double? netWeightKg,
  double vehicleCharge = 0,
  double amount = 0,
  String? remarks,
  String status = 'pending',
  String weightUnit = 'ton',
  DateTime? createdAt,
}) {
  return db.billDao.insertWeighment(
    WeighmentsCompanion.insert(
      billNumber: billNumber,
      partyId: partyId,
      vehicleId: vehicleId,
      materialId: materialId,
      paymentMode: paymentMode,
      firstWeightKg: firstWeightKg,
      firstWeightType: Value(firstWeightType),
      secondWeightKg: Value(secondWeightKg),
      secondWeightType: Value(secondWeightType),
      netWeightKg: Value(netWeightKg),
      vehicleCharge: Value(vehicleCharge),
      amount: Value(amount),
      remarks: Value(remarks),
      status: Value(status),
      weightUnit: Value(weightUnit),
      createdAt: createdAt != null ? Value(createdAt) : const Value.absent(),
    ),
  );
}

class SeededRefs {
  final int partyId;
  final int vehicleTypeId;
  final int vehicleId;
  final int materialId;

  const SeededRefs({
    required this.partyId,
    required this.vehicleTypeId,
    required this.vehicleId,
    required this.materialId,
  });
}

/// Runs [body] with a fresh in-memory database that is closed afterwards.
Future<T> withDatabase<T>(Future<T> Function(AppDatabase db) body) async {
  final db = createInMemoryDatabase();
  try {
    return await body(db);
  } finally {
    await db.close();
  }
}