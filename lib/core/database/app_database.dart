import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;

import 'daos/user_dao.dart';
import 'daos/party_dao.dart';
import 'daos/vehicle_dao.dart';
import 'daos/vehicle_type_dao.dart';
import 'daos/material_dao.dart';
import 'daos/bill_dao.dart';
import 'daos/app_settings_dao.dart';
import 'tables/users_table.dart';
import 'tables/parties_table.dart';
import 'tables/vehicle_types_table.dart';
import 'tables/vehicles_table.dart';
import 'tables/materials_table.dart';
import 'tables/weighments_table.dart';
import 'tables/app_settings_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Users,
    Parties,
    VehicleTypes,
    Vehicles,
    Materials,
    Weighments,
    AppSettings,
  ],
  daos: [
    UserDao,
    PartyDao,
    VehicleTypeDao,
    VehicleDao,
    MaterialDao,
    BillDao,
    AppSettingsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 13;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 5) {
        await m.createTable(vehicleTypes);

        await customStatement('''
              CREATE TABLE vehicles_new (
                id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
                vehicle_number TEXT NOT NULL UNIQUE,
                vehicle_type_id INTEGER NOT NULL REFERENCES vehicle_types(id),
                driver_name TEXT,
                driver_phone TEXT,
                is_active INTEGER NOT NULL DEFAULT 1,
                created_at INTEGER NOT NULL,
                updated_at INTEGER NOT NULL
              )
            ''');
        await customStatement(
          "INSERT INTO vehicles_new (id, vehicle_number, vehicle_type_id, driver_name, driver_phone, is_active, created_at, updated_at) "
          "SELECT id, vehicle_number, 1, driver_name, driver_phone, is_active, created_at, updated_at FROM vehicles",
        );
        await customStatement('DROP TABLE vehicles');
        await customStatement('ALTER TABLE vehicles_new RENAME TO vehicles');

        await customStatement('''
              CREATE TABLE materials_new (
                id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                category TEXT,
                unit TEXT NOT NULL DEFAULT 'ton',
                is_active INTEGER NOT NULL DEFAULT 1,
                created_at INTEGER NOT NULL,
                updated_at INTEGER NOT NULL
              )
            ''');
        await customStatement(
          "INSERT INTO materials_new (id, name, category, unit, is_active, created_at, updated_at) "
          "SELECT id, name, category, unit, is_active, created_at, updated_at FROM materials",
        );
        await customStatement('DROP TABLE materials');
        await customStatement('ALTER TABLE materials_new RENAME TO materials');

        await customStatement('''
              CREATE TABLE weighments_new (
                id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
                bill_number TEXT NOT NULL UNIQUE,
                party_id INTEGER NOT NULL REFERENCES parties(id),
                vehicle_id INTEGER NOT NULL REFERENCES vehicles(id),
                material_id INTEGER NOT NULL REFERENCES materials(id),
                payment_mode TEXT NOT NULL,
                first_weight_kg REAL NOT NULL,
                second_weight_kg REAL,
                net_weight_kg REAL,
                vehicle_charge REAL NOT NULL DEFAULT 0,
                remarks TEXT,
                status TEXT NOT NULL DEFAULT 'pending',
                created_at INTEGER NOT NULL DEFAULT (strftime('%s','now') * 1000),
                updated_at INTEGER NOT NULL DEFAULT (strftime('%s','now') * 1000)
              )
            ''');
        await customStatement(
          "INSERT INTO weighments_new (id, bill_number, party_id, vehicle_id, material_id, payment_mode, "
          "first_weight_kg, second_weight_kg, net_weight_kg, vehicle_charge, remarks, status, created_at, updated_at) "
          "SELECT id, bill_number, party_id, vehicle_id, material_id, payment_mode, "
          "first_weight_kg, second_weight_kg, net_weight_kg, rate, remarks, 'completed', created_at, updated_at FROM weighments",
        );
        await customStatement('DROP TABLE weighments');
        await customStatement(
          'ALTER TABLE weighments_new RENAME TO weighments',
        );
      }

      if (from < 6) {
        await customStatement('''
              CREATE TABLE weighments_new (
                id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
                bill_number TEXT NOT NULL UNIQUE,
                party_id INTEGER NOT NULL REFERENCES parties(id),
                vehicle_id INTEGER NOT NULL REFERENCES vehicles(id),
                material_id INTEGER NOT NULL REFERENCES materials(id),
                payment_mode TEXT NOT NULL,
                first_weight_kg REAL NOT NULL,
                second_weight_kg REAL,
                net_weight_kg REAL,
                vehicle_charge REAL NOT NULL DEFAULT 0,
                remarks TEXT,
                status TEXT NOT NULL DEFAULT 'pending',
                created_at INTEGER NOT NULL DEFAULT (strftime('%s','now') * 1000),
                updated_at INTEGER NOT NULL DEFAULT (strftime('%s','now') * 1000)
              )
            ''');
        await customStatement(
          "INSERT INTO weighments_new (id, bill_number, party_id, vehicle_id, material_id, payment_mode, "
          "first_weight_kg, second_weight_kg, net_weight_kg, vehicle_charge, remarks, status, created_at, updated_at) "
          "SELECT id, bill_number, party_id, vehicle_id, material_id, payment_mode, "
          "first_weight_kg, second_weight_kg, net_weight_kg, rate, remarks, 'completed', created_at, updated_at FROM weighments",
        );
        await customStatement('DROP TABLE weighments');
        await customStatement(
          'ALTER TABLE weighments_new RENAME TO weighments',
        );
      }

      if (from < 7) {
        await customStatement('''
              CREATE TABLE weighments_repair (
                id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
                bill_number TEXT NOT NULL UNIQUE,
                party_id INTEGER NOT NULL REFERENCES parties(id),
                vehicle_id INTEGER NOT NULL REFERENCES vehicles(id),
                material_id INTEGER NOT NULL REFERENCES materials(id),
                payment_mode TEXT NOT NULL,
                first_weight_kg REAL NOT NULL,
                second_weight_kg REAL,
                net_weight_kg REAL,
                vehicle_charge REAL NOT NULL DEFAULT 0,
                amount REAL NOT NULL DEFAULT 0,
                remarks TEXT,
                status TEXT NOT NULL DEFAULT 'pending',
                created_at INTEGER NOT NULL DEFAULT (strftime('%s','now') * 1000),
                updated_at INTEGER NOT NULL DEFAULT (strftime('%s','now') * 1000)
              )
            ''');

        final hasRateColumn = await customSelect(
          "SELECT name FROM pragma_table_info('weighments') WHERE name='rate'",
        ).getSingleOrNull();
        final hasChargeColumn = await customSelect(
          "SELECT name FROM pragma_table_info('weighments') WHERE name='vehicle_charge'",
        ).getSingleOrNull();

        if (hasRateColumn != null) {
          await customStatement(
            "INSERT INTO weighments_repair (id, bill_number, party_id, vehicle_id, material_id, payment_mode, "
            "first_weight_kg, second_weight_kg, net_weight_kg, vehicle_charge, amount, remarks, status, created_at, updated_at) "
            "SELECT id, bill_number, party_id, vehicle_id, material_id, payment_mode, "
            "first_weight_kg, second_weight_kg, net_weight_kg, rate, rate, remarks, COALESCE(status, 'completed'), "
            "COALESCE(created_at, strftime('%s','now') * 1000), COALESCE(updated_at, strftime('%s','now') * 1000) "
            "FROM weighments",
          );
        } else if (hasChargeColumn != null) {
          await customStatement(
            "INSERT INTO weighments_repair (id, bill_number, party_id, vehicle_id, material_id, payment_mode, "
            "first_weight_kg, second_weight_kg, net_weight_kg, vehicle_charge, amount, remarks, status, created_at, updated_at) "
            "SELECT id, bill_number, party_id, vehicle_id, material_id, payment_mode, "
            "first_weight_kg, second_weight_kg, net_weight_kg, vehicle_charge, vehicle_charge, remarks, COALESCE(status, 'completed'), "
            "COALESCE(created_at, strftime('%s','now') * 1000), COALESCE(updated_at, strftime('%s','now') * 1000) "
            "FROM weighments",
          );
        }

        await customStatement('DROP TABLE weighments');
        await customStatement(
          'ALTER TABLE weighments_repair RENAME TO weighments',
        );
      }

      if (from < 8) {
        final hasAmountColumn = await customSelect(
          "SELECT name FROM pragma_table_info('weighments') WHERE name='amount'",
        ).getSingleOrNull();
        if (hasAmountColumn == null) {
          await m.addColumn(weighments, weighments.amount);
        }
      }

      if (from < 9) {
        await customStatement('''
              CREATE TABLE materials_new (
                id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                category TEXT,
                is_active INTEGER NOT NULL DEFAULT 1,
                created_at INTEGER NOT NULL,
                updated_at INTEGER NOT NULL
              )
            ''');
        await customStatement(
          "INSERT INTO materials_new (id, name, category, is_active, created_at, updated_at) "
          "SELECT id, name, category, is_active, created_at, updated_at FROM materials",
        );
        await customStatement('DROP TABLE materials');
        await customStatement('ALTER TABLE materials_new RENAME TO materials');
      }

      if (from < 10) {
        final hasCreatedAtDefault = await customSelect(
          "SELECT name FROM pragma_table_info('materials') WHERE name='created_at'",
        ).getSingleOrNull();
        if (hasCreatedAtDefault != null) {
          await customStatement('''
                CREATE TABLE materials_new (
                  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
                  name TEXT NOT NULL,
                  category TEXT,
                  is_active INTEGER NOT NULL DEFAULT 1,
                  created_at INTEGER NOT NULL DEFAULT (strftime('%s','now') * 1000),
                  updated_at INTEGER NOT NULL DEFAULT (strftime('%s','now') * 1000)
                )
              ''');
          await customStatement(
            "INSERT INTO materials_new (id, name, category, is_active, created_at, updated_at) "
            "SELECT id, name, category, is_active, "
            "COALESCE(created_at, strftime('%s','now') * 1000), "
            "COALESCE(updated_at, strftime('%s','now') * 1000) FROM materials",
          );
          await customStatement('DROP TABLE materials');
          await customStatement(
            'ALTER TABLE materials_new RENAME TO materials',
          );
        }
      }

      if (from < 11) {
        await m.createTable(appSettings);
      }

      if (from < 12) {
        final hasFirstWeightType = await customSelect(
          "SELECT name FROM pragma_table_info('weighments') WHERE name='first_weight_type'",
        ).getSingleOrNull();
        if (hasFirstWeightType == null) {
          await m.addColumn(weighments, weighments.firstWeightType);
        }
        final hasSecondWeightType = await customSelect(
          "SELECT name FROM pragma_table_info('weighments') WHERE name='second_weight_type'",
        ).getSingleOrNull();
        if (hasSecondWeightType == null) {
          await m.addColumn(weighments, weighments.secondWeightType);
        }
      }

      if (from < 13) {
        final hasWeightUnit = await customSelect(
          "SELECT name FROM pragma_table_info('weighments') WHERE name='weight_unit'",
        ).getSingleOrNull();
        if (hasWeightUnit == null) {
          await m.addColumn(weighments, weighments.weightUnit);
          await customStatement(
            "UPDATE weighments SET weight_unit = 'kg' WHERE first_weight_kg >= 500",
          );
        }
      }
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final home = Platform.environment['HOME'];
    if (home == null || home.isEmpty) {
      throw StateError('Unable to determine macOS home directory');
    }
    final dbFolder = Directory(
      p.join(home, 'Library', 'Application Support', 'Weighbridge'),
    );
    if (!await dbFolder.exists()) {
      await dbFolder.create(recursive: true);
    }
    final file = File(p.join(dbFolder.path, 'weighbridge.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
