import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:weighbridge/core/database/app_database.dart';

import '../../../support/test_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = createInMemoryDatabase();
  });

  tearDown(() async {
    await db.close();
  });

  group('VehicleTypeDao', () {
    test('insert and lookup by id and name', () async {
      final id = await seedVehicleType(db, name: 'Truck', loadPrice: 250);
      final byId = await db.vehicleTypeDao.getVehicleTypeById(id);
      expect(byId, isNotNull);
      expect(byId!.name, 'Truck');
      expect(byId.loadPrice, 250);
      expect(byId.emptyPrice, 0);
      expect(byId.isActive, isTrue);

      final byName = await db.vehicleTypeDao.getVehicleTypeByName('Truck');
      expect(byName, isNotNull);
      expect(byName!.id, id);
    });

    test('filters active and inactive types', () async {
      await seedVehicleType(db, name: 'Truck');
      await seedVehicleType(db, name: 'Trailer', isActive: false);

      expect(
        (await db.vehicleTypeDao.getAllActiveVehicleTypes()).map((v) => v.name),
        ['Truck'],
      );
      expect(
        (await db.vehicleTypeDao.getAllVehicleTypes()).length,
        2,
      );
    });

    test('searchVehicleTypes matches case-insensitively via LIKE', () async {
      await seedVehicleType(db, name: 'Tipper');
      await seedVehicleType(db, name: 'Container');

      expect(
        (await db.vehicleTypeDao.searchVehicleTypes('tIp')).single.name,
        'Tipper',
      );
      expect(await db.vehicleTypeDao.searchVehicleTypes('xyz'), isEmpty);
    });

    test('name is unique', () async {
      await seedVehicleType(db, name: 'Truck');
      expect(
        () => seedVehicleType(db, name: 'Truck'),
        throwsA(isA<Exception>()),
      );
    });

    test('deactivateVehicleType flips isActive', () async {
      final id = await seedVehicleType(db, name: 'Truck');
      await db.vehicleTypeDao.deactivateVehicleType(id);
      final t = await db.vehicleTypeDao.getVehicleTypeById(id);
      expect(t!.isActive, isFalse);
    });

    test('updateVehicleType replaces name and prices', () async {
      final id = await seedVehicleType(db, name: 'Truck');
      await db.vehicleTypeDao.updateVehicleType(
        VehicleTypesCompanion(
          id: Value(id),
          name: const Value('Lorry'),
          emptyPrice: const Value(50),
          loadPrice: const Value(300),
          updatedAt: Value(DateTime.now()),
        ),
      );
      final t = await db.vehicleTypeDao.getVehicleTypeById(id);
      expect(t!.name, 'Lorry');
      expect(t.emptyPrice, 50);
      expect(t.loadPrice, 300);
    });

    test('deleteVehicleType removes the record', () async {
      final id = await seedVehicleType(db, name: 'Truck');
      final deleted = await db.vehicleTypeDao.deleteVehicleType(id);
      expect(deleted, 1);
      expect(await db.vehicleTypeDao.getVehicleTypeById(id), isNull);
    });
  });
}