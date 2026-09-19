import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:weighbridge/core/database/app_database.dart';

import '../../../support/test_database.dart';

void main() {
  late AppDatabase db;
  late int truckTypeId;
  late int trailerTypeId;

  setUp(() async {
    db = createInMemoryDatabase();
    truckTypeId = await seedVehicleType(db, name: 'Truck');
    trailerTypeId = await seedVehicleType(db, name: 'Trailer');
  });

  tearDown(() async {
    await db.close();
  });

  group('VehicleDao', () {
    test('insert and lookup by id and number', () async {
      final id = await seedVehicle(
        db,
        vehicleNumber: 'TN31CM2026',
        vehicleTypeId: truckTypeId,
        driverName: 'Ramesh',
        driverPhone: '9876543210',
      );
      final byId = await db.vehicleDao.getVehicleById(id);
      expect(byId, isNotNull);
      expect(byId!.vehicleNumber, 'TN31CM2026');
      expect(byId.driverName, 'Ramesh');

      final byNumber = await db.vehicleDao.getVehicleByNumber('TN31CM2026');
      expect(byNumber, isNotNull);
      expect(byNumber!.id, id);
    });

    test('vehicle number is unique', () async {
      await seedVehicle(
        db,
        vehicleNumber: 'TN31CM2026',
        vehicleTypeId: truckTypeId,
      );
      expect(
        () => seedVehicle(
          db,
          vehicleNumber: 'TN31CM2026',
          vehicleTypeId: truckTypeId,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('filters active and inactive vehicles', () async {
      await seedVehicle(
        db,
        vehicleNumber: 'TN31A',
        vehicleTypeId: truckTypeId,
      );
      await seedVehicle(
        db,
        vehicleNumber: 'TN31B',
        vehicleTypeId: truckTypeId,
        isActive: false,
      );

      expect(
        (await db.vehicleDao.getAllActiveVehicles()).map((v) => v.vehicleNumber),
        ['TN31A'],
      );
      expect((await db.vehicleDao.getAllVehicles()).length, 2);
      expect(
        (await db.vehicleDao.getVehiclesByStatus(isActive: false)).single
            .vehicleNumber,
        'TN31B',
      );
    });

    test('getVehiclesByType filters active vehicles of a type', () async {
      await seedVehicle(
        db,
        vehicleNumber: 'TN31A',
        vehicleTypeId: truckTypeId,
      );
      await seedVehicle(
        db,
        vehicleNumber: 'TN31B',
        vehicleTypeId: trailerTypeId,
      );
      await seedVehicle(
        db,
        vehicleNumber: 'TN31C',
        vehicleTypeId: truckTypeId,
        isActive: false,
      );

      final trucks = await db.vehicleDao.getVehiclesByType(truckTypeId);
      expect(trucks.map((v) => v.vehicleNumber), ['TN31A']);
    });

    test('searchVehicles matches number or driver name', () async {
      await seedVehicle(
        db,
        vehicleNumber: 'TN31CM2026',
        vehicleTypeId: truckTypeId,
        driverName: 'Ramesh',
      );
      await seedVehicle(
        db,
        vehicleNumber: 'KA01AB1234',
        vehicleTypeId: truckTypeId,
        driverName: 'Suresh',
      );

      expect(
        (await db.vehicleDao.searchVehicles('TN31')).single.vehicleNumber,
        'TN31CM2026',
      );
      expect(
        (await db.vehicleDao.searchVehicles('ram')).single.vehicleNumber,
        'TN31CM2026',
      );
      expect(await db.vehicleDao.searchVehicles('ZZZ'), isEmpty);
    });

    test('deactivateVehicle flips isActive', () async {
      final id = await seedVehicle(
        db,
        vehicleNumber: 'TN31A',
        vehicleTypeId: truckTypeId,
      );
      await db.vehicleDao.deactivateVehicle(id);
      final v = await db.vehicleDao.getVehicleById(id);
      expect(v!.isActive, isFalse);
    });

    test('updateVehicle replaces fields', () async {
      final id = await seedVehicle(
        db,
        vehicleNumber: 'TN31A',
        vehicleTypeId: truckTypeId,
        driverName: 'Ramesh',
      );
      final ok = await db.vehicleDao.updateVehicle(
        VehiclesCompanion(
          id: Value(id),
          vehicleNumber: const Value('TN31CM2026'),
          vehicleTypeId: Value(trailerTypeId),
          driverName: const Value('Suresh'),
          updatedAt: Value(DateTime.now()),
        ),
      );
      expect(ok, isTrue);
      final v = await db.vehicleDao.getVehicleById(id);
      expect(v!.vehicleNumber, 'TN31CM2026');
      expect(v.vehicleTypeId, trailerTypeId);
      expect(v.driverName, 'Suresh');
    });

    test('deleteVehicle removes the record', () async {
      final id = await seedVehicle(
        db,
        vehicleNumber: 'TN31A',
        vehicleTypeId: truckTypeId,
      );
      final deleted = await db.vehicleDao.deleteVehicle(id);
      expect(deleted, 1);
      expect(await db.vehicleDao.getVehicleById(id), isNull);
    });
  });
}