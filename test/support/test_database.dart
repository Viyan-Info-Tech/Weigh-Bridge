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

/// Seeds a weighment and returns its id.
Future<int> seedWeighment(
  AppDatabase db, {
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
      vehicleNumber: vehicleNumber,
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

/// Runs [body] with a fresh in-memory database that is closed afterwards.
Future<T> withDatabase<T>(Future<T> Function(AppDatabase db) body) async {
  final db = createInMemoryDatabase();
  try {
    return await body(db);
  } finally {
    await db.close();
  }
}
