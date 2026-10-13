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

Future<int> seedCustomer(
  AppDatabase db, {
  required String name,
  String? mobile,
  String? contactPerson,
  String? gstNumber,
  String? city,
  String? state,
  bool isActive = true,
}) {
  return db.customerDao.insertCustomer(
    CustomersCompanion.insert(
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

Future<int> seedMaterial(
  AppDatabase db, {
  required String code,
  required String name,
  bool isActive = true,
}) {
  return db.materialDao.insertMaterial(
    MaterialsCompanion.insert(
      code: code,
      name: name,
      isActive: Value(isActive),
    ),
  );
}

/// Seeds all parent records needed to insert a weighment and returns
/// their ids.
Future<SeededRefs> seedParents(AppDatabase db) async {
  final customerId = await seedCustomer(
    db,
    name: 'Seed Customer',
    mobile: '9000000000',
  );
  final materialId = await seedMaterial(db, code: '1', name: 'Cement');
  return SeededRefs(customerId: customerId, materialId: materialId);
}

Future<int> seedWeighment(
  AppDatabase db, {
  required int customerId,
  required int materialId,
  required String billNumber,
  String vehicleNumber = 'TN31SEED01',
  double firstWeightKg = 0,
  String firstWeightType = 'GROSS',
  double? secondWeightKg,
  String? secondWeightType,
  double? netWeightKg,
  String? remarks,
  String weightUnit = 'ton',
  DateTime? createdAt,
}) {
  return db.billDao.insertWeighment(
    WeighmentsCompanion.insert(
      billNumber: billNumber,
      customerId: customerId,
      vehicleNumber: vehicleNumber,
      materialId: Value(materialId),
      firstWeightKg: firstWeightKg,
      firstWeightType: Value(firstWeightType),
      secondWeightKg: Value(secondWeightKg),
      secondWeightType: Value(secondWeightType),
      netWeightKg: Value(netWeightKg),
      remarks: Value(remarks),
      weightUnit: Value(weightUnit),
      createdAt: createdAt != null ? Value(createdAt) : const Value.absent(),
    ),
  );
}

class SeededRefs {
  final int customerId;
  final int materialId;

  const SeededRefs({required this.customerId, required this.materialId});
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
