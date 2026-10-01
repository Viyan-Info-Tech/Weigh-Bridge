import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weighbridge/core/database/app_database.dart';

import '../../support/test_database.dart';

void main() {
  test('schema version is 23', () {
    final db = createInMemoryDatabase();
    addTearDown(db.close);
    expect(db.schemaVersion, 23);
  });

  test('onCreate creates all application tables', () async {
    await withDatabase((db) async {
      final tables = [
        'users',
        'customers',
        'materials',
        'weighments',
        'app_settings',
        'admin_credentials',
      ];
      for (final table in tables) {
        final exists = await db
            .customSelect(
              "SELECT name FROM sqlite_master WHERE type='table' AND name = ?",
              variables: [Variable.withString(table)],
            )
            .get();
        expect(
          exists,
          isNotEmpty,
          reason: 'table $table should exist after onCreate',
        );
      }
    });
  });

  test('onCreate does not create vehicle tables', () async {
    await withDatabase((db) async {
      for (final table in ['vehicles', 'vehicle_types']) {
        final rows = await db
            .customSelect(
              "SELECT name FROM sqlite_master WHERE type='table' AND name = ?",
              variables: [Variable.withString(table)],
            )
            .get();
        expect(rows, isEmpty, reason: 'table $table must not exist');
      }
    });
  });

  test('database user_version is set to the schema version', () async {
    await withDatabase((db) async {
      final rows = await db.customSelect('PRAGMA user_version').get();
      expect(rows.single.data['user_version'], 18);
    });
  });

  test('can insert parents and a weighment referencing them', () async {
    await withDatabase((db) async {
      final refs = await seedParents(db);
      final id = await seedWeighment(
        db,
        customerId: refs.customerId,
        materialId: refs.materialId,
        billNumber: 'WB-00001',
        firstWeightKg: 20000,
        secondWeightKg: 5000,
      );
      expect(id, greaterThan(0));

      final stored = await db.billDao.getWeighmentById(id);
      expect(stored, isNotNull);
      expect(stored!.billNumber, 'WB-00001');
      expect(stored.vehicleNumber, 'TN31SEED01');
    });
  });

  test('bill_number unique constraint rejects duplicates', () async {
    await withDatabase((db) async {
      final refs = await seedParents(db);
      await seedWeighment(
        db,
        customerId: refs.customerId,
        materialId: refs.materialId,
        billNumber: 'WB-00001',
      );
      expect(
        () => seedWeighment(
          db,
          customerId: refs.customerId,
          materialId: refs.materialId,
          billNumber: 'WB-00001',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('v14 -> v15 migration', () {
    Future<NativeDatabase> createV14Database() async {
      final tempDir = await Directory.systemTemp.createTemp('weighbridge_v14');
      addTearDown(() => tempDir.delete(recursive: true));

      final file = File('${tempDir.path}/weighbridge_v14.db');
      final sqlite = NativeDatabase(file);
      await sqlite.ensureOpen(_StubExecutorUser(14));

      await sqlite.runCustom('''
CREATE TABLE users (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  unique_id TEXT NOT NULL,
  name TEXT NOT NULL,
  username TEXT NOT NULL,
  password TEXT NOT NULL,
  is_active INTEGER NOT NULL DEFAULT 1,
  last_login_at INTEGER,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
)
''');
      await sqlite.runCustom('''
CREATE TABLE parties (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  contact_person TEXT,
  mobile TEXT,
  email TEXT,
  address TEXT,
  gst_number TEXT,
  city TEXT,
  state TEXT,
  is_active INTEGER NOT NULL DEFAULT 1,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
)
''');
      await sqlite.runCustom('''
CREATE TABLE vehicle_types (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  empty_price REAL NOT NULL DEFAULT 0,
  load_price REAL NOT NULL DEFAULT 0,
  is_active INTEGER NOT NULL DEFAULT 1,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
)
''');
      await sqlite.runCustom('''
CREATE TABLE vehicles (
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
      await sqlite.runCustom('''
CREATE TABLE materials (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  category TEXT,
  is_active INTEGER NOT NULL DEFAULT 1,
  created_at INTEGER NOT NULL DEFAULT (strftime('%s','now') * 1000),
  updated_at INTEGER NOT NULL DEFAULT (strftime('%s','now') * 1000)
)
''');
      await sqlite.runCustom('''
CREATE TABLE weighments (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  bill_number TEXT NOT NULL UNIQUE,
  party_id INTEGER NOT NULL REFERENCES parties(id),
  vehicle_id INTEGER NOT NULL REFERENCES vehicles(id),
  material_id INTEGER NOT NULL REFERENCES materials(id),
  payment_mode TEXT NOT NULL,
  first_weight_kg REAL NOT NULL,
  first_weight_type TEXT NOT NULL DEFAULT 'GROSS',
  second_weight_kg REAL,
  second_weight_type TEXT,
  net_weight_kg REAL,
  vehicle_charge REAL NOT NULL DEFAULT 0,
  amount REAL NOT NULL DEFAULT 0,
  remarks TEXT,
  weight_unit TEXT NOT NULL DEFAULT 'ton',
  created_at INTEGER NOT NULL DEFAULT (strftime('%s','now') * 1000),
  updated_at INTEGER NOT NULL DEFAULT (strftime('%s','now') * 1000)
)
''');
      await sqlite.runCustom('''
CREATE TABLE app_settings (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  weight_unit TEXT NOT NULL DEFAULT 'ton',
  bill_prefix TEXT NOT NULL DEFAULT 'WB',
  bill_starting_number INTEGER NOT NULL DEFAULT 1,
  bill_number_digits INTEGER NOT NULL DEFAULT 5,
  business_name TEXT NOT NULL DEFAULT 'VIYAN WEIGHBRIDGE',
  business_subtitle TEXT,
  service_text TEXT,
  address TEXT,
  phone_number TEXT,
  email TEXT,
  gstin TEXT,
  logo_path TEXT,
  receipt_title TEXT NOT NULL DEFAULT 'WEIGHMENT RECEIPT',
  show_serial_number INTEGER NOT NULL DEFAULT 1,
  show_date INTEGER NOT NULL DEFAULT 1,
  show_time INTEGER NOT NULL DEFAULT 1,
  show_vehicle_number INTEGER NOT NULL DEFAULT 1,
  show_material INTEGER NOT NULL DEFAULT 1,
  show_party INTEGER NOT NULL DEFAULT 1,
  show_vehicle_type INTEGER NOT NULL DEFAULT 1,
  show_gross_weight INTEGER NOT NULL DEFAULT 1,
  show_tare_weight INTEGER NOT NULL DEFAULT 1,
  show_net_weight INTEGER NOT NULL DEFAULT 1,
  show_amount INTEGER NOT NULL DEFAULT 1,
  show_payment_mode INTEGER NOT NULL DEFAULT 1,
  show_cash_received INTEGER NOT NULL DEFAULT 1,
  show_remarks INTEGER NOT NULL DEFAULT 1,
  show_footer_note INTEGER NOT NULL DEFAULT 1,
  footer_note TEXT,
  updated_at INTEGER NOT NULL
)
''');

      final now = DateTime.now().millisecondsSinceEpoch;
      await sqlite.runCustom(
        'INSERT INTO parties (name, created_at, updated_at) VALUES (?, ?, ?)',
        ['Seed Party', now, now],
      );
      await sqlite.runCustom(
        'INSERT INTO vehicle_types (name, created_at, updated_at) VALUES (?, ?, ?)',
        ['Truck', now, now],
      );
      await sqlite.runCustom(
        'INSERT INTO vehicles (vehicle_number, vehicle_type_id, created_at, updated_at) VALUES (?, ?, ?, ?)',
        ['MH12AB1234', 1, now, now],
      );
      await sqlite.runCustom(
        'INSERT INTO materials (name, created_at, updated_at) VALUES (?, ?, ?)',
        ['Cement', now, now],
      );
      await sqlite.runCustom(
        'INSERT INTO weighments (bill_number, party_id, vehicle_id, material_id, payment_mode, '
        'first_weight_kg, first_weight_type, vehicle_charge, amount, weight_unit, created_at, updated_at) '
        'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
        [
          'WB-00001',
          1,
          1,
          1,
          'cash',
          20000.0,
          'GROSS',
          100.0,
          100.0,
          'ton',
          now,
          now,
        ],
      );
      await sqlite.runCustom(
        'INSERT INTO weighments (bill_number, party_id, vehicle_id, material_id, payment_mode, '
        'first_weight_kg, first_weight_type, vehicle_charge, amount, weight_unit, created_at, updated_at) '
        'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
        [
          'WB-00002',
          1,
          99,
          1,
          'cash',
          5000.0,
          'TARE',
          0.0,
          0.0,
          'ton',
          now,
          now,
        ],
      );
      await sqlite.runCustom(
        'INSERT INTO app_settings (show_vehicle_number, show_vehicle_type, show_party, updated_at) '
        'VALUES (?, ?, ?, ?)',
        [0, 1, 1, now],
      );
      await sqlite.runCustom('PRAGMA user_version = 14');
      await sqlite.close();

      return NativeDatabase(file);
    }

    test('backfills vehicle_number and drops vehicle tables', () async {
      final sqlite = await createV14Database();
      final db = AppDatabase.forTesting(sqlite);
      addTearDown(db.close);

      final migrated = await db.billDao.getWeighmentByBillNumber('WB-00001');
      expect(migrated, isNotNull);
      expect(migrated!.vehicleNumber, 'MH12AB1234');
      expect(migrated.vehicleCharge, 100);

      final orphan = await db.billDao.getWeighmentByBillNumber('WB-00002');
      expect(orphan!.vehicleNumber, 'VEHICLE #99');

      for (final table in ['vehicles', 'vehicle_types']) {
        final rows = await db
            .customSelect(
              "SELECT name FROM sqlite_master WHERE type='table' AND name = ?",
              variables: [Variable.withString(table)],
            )
            .get();
        expect(rows, isEmpty, reason: 'table $table should be dropped');
      }

      final cols = await db
          .customSelect("SELECT name FROM pragma_table_info('weighments')")
          .get();
      expect(cols.map((r) => r.data['name']), isNot(contains('vehicle_id')));
      expect(cols.map((r) => r.data['name']), contains('vehicle_number'));

      final settingsCols = await db
          .customSelect("SELECT name FROM pragma_table_info('app_settings')")
          .get();
      expect(
        settingsCols.map((r) => r.data['name']),
        isNot(contains('show_vehicle_type')),
      );

      final settings = await db.appSettingsDao.getSettings();
      expect(settings.showVehicleNumber, isFalse);

      final materialCols = await db
          .customSelect("SELECT name FROM pragma_table_info('materials')")
          .get();
      expect(
        materialCols.map((r) => r.data['name']),
        isNot(contains('category')),
      );
      expect(materialCols.map((r) => r.data['name']), contains('code'));

      final materials = await db.materialDao.getAllMaterials();
      expect(materials.single.name, 'Cement');
      expect(materials.single.code, '1'); // backfilled from the row id

      final version = await db.customSelect('PRAGMA user_version').get();
      expect(version.single.data['user_version'], 18);
    });
  });
}

class _StubExecutorUser implements QueryExecutorUser {
  final int _schemaVersion;
  _StubExecutorUser(this._schemaVersion);

  @override
  int get schemaVersion => _schemaVersion;

  @override
  Future<void> beforeOpen(
    QueryExecutor executor,
    OpeningDetails details,
  ) async {}
}
