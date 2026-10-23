import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:weighbridge/core/database/app_database.dart';

import '../../support/test_database.dart';

void main() {
  test('schema version is 35', () {
    final db = createInMemoryDatabase();
    addTearDown(db.close);
    expect(db.schemaVersion, 35);
  });

  test('onCreate creates all application tables', () async {
    await withDatabase((db) async {
      final tables = [
        'users',
        'weighments',
        'app_settings',
        'scale_settings',
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

  test(
    'onCreate does not create customer or vehicle tables but creates materials',
    () async {
      await withDatabase((db) async {
        for (final table in [
          'customers',
          'vehicles',
          'vehicle_types',
          'parties',
        ]) {
          final rows = await db
              .customSelect(
                "SELECT name FROM sqlite_master WHERE type='table' AND name = ?",
                variables: [Variable.withString(table)],
              )
              .get();
          expect(rows, isEmpty, reason: 'table $table must not exist');
        }
        // The materials master is part of the current schema.
        final materialsRows = await db
            .customSelect(
              "SELECT name FROM sqlite_master WHERE type='table' AND name = 'materials'",
            )
            .get();
        expect(
          materialsRows,
          isNotEmpty,
          reason: 'table materials should exist',
        );
      });
    },
  );

  test(
    'fresh weighments table has no customer column but has material_id',
    () async {
      await withDatabase((db) async {
        final cols = await db
            .customSelect("SELECT name FROM pragma_table_info('weighments')")
            .get();
        final names = cols.map((r) => r.data['name'] as String).toSet();
        expect(names, isNot(contains('customer_id')));
        // materialId is the master reference for the material snapshot.
        expect(names, contains('material_id'));
        expect(names, isNot(contains('party_id')));
        expect(
          names,
          containsAll(<String>[
            'bill_number',
            'vehicle_number',
            'first_weight_kg',
            'mobile_number',
            'weight_unit',
            'charges',
          ]),
        );
      });
    },
  );

  test('fresh weighments table charges column is nullable', () async {
    await withDatabase((db) async {
      final cols = await db
          .customSelect("SELECT * FROM pragma_table_info('weighments')")
          .get();
      final chargesCol = cols.firstWhere(
        (r) => r.data['name'] == 'charges',
        orElse: () => throw StateError('charges column missing'),
      );
      expect(chargesCol.data['type'], 'REAL');
      expect(chargesCol.data['notnull'], 0);
      expect(chargesCol.data['dflt_value'], isNull);
    });
  });

  test(
    'fresh app_settings table has no show_material or show_party columns',
    () async {
      await withDatabase((db) async {
        final cols = await db
            .customSelect("SELECT name FROM pragma_table_info('app_settings')")
            .get();
        final names = cols.map((r) => r.data['name'] as String).toSet();
        expect(names, isNot(contains('show_material')));
        expect(names, isNot(contains('show_party')));
        expect(names, isNot(contains('show_vehicle_type')));
        expect(names, contains('show_vehicle_number'));
        expect(names, contains('show_remarks'));
      });
    },
  );

  test('onCreate creates the weighments report query index', () async {
    await withDatabase((db) async {
      final rows = await db
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type='index' "
            "AND tbl_name='weighments'",
          )
          .get();
      final names = rows.map((r) => r.read<String>('name')).toSet();
      expect(names, contains('idx_weighments_created_at'));
      expect(names, isNot(contains('idx_weighments_customer_created')));
      expect(names, isNot(contains('idx_weighments_material_created')));
    });
  });

  test(
    'upgrading from v23 keeps only the created_at weighment index',
    () async {
      // A file-backed database is required: the migration only replays on a
      // fresh connection, and an already-open in-memory executor would be
      // reused instead of reopened. The database is built in the genuine v23
      // shape (customer/material relationships still present), because the
      // v25/v26/v29 rebuild steps copy those columns forward.
      final dir = await Directory.systemTemp.createTemp('weighbridge_idx');
      addTearDown(() => dir.delete(recursive: true));
      final file = File(p.join(dir.path, 'v23.sqlite'));

      final seed = NativeDatabase(file);
      await seed.ensureOpen(_StubExecutorUser(23));
      final now = DateTime(2026, 10, 1).millisecondsSinceEpoch;
      await seed.runCustom(
        'CREATE TABLE customers ('
        'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
        'name TEXT NOT NULL, customer_code TEXT, '
        'is_active INTEGER NOT NULL DEFAULT 1, '
        'created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL)',
      );
      await seed.runCustom(
        'CREATE TABLE materials ('
        'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
        'name TEXT NOT NULL, code TEXT NOT NULL DEFAULT \'\', '
        'is_active INTEGER NOT NULL DEFAULT 1, '
        'created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL)',
      );
      await seed.runCustom(
        'CREATE TABLE weighments ('
        'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
        'bill_number TEXT NOT NULL UNIQUE, '
        'customer_id INTEGER NOT NULL REFERENCES customers(id), '
        'vehicle_number TEXT NOT NULL, '
        'material_id INTEGER NOT NULL REFERENCES materials(id), '
        'payment_mode TEXT NOT NULL, '
        'first_weight_kg REAL NOT NULL, '
        'first_weight_type TEXT NOT NULL DEFAULT \'GROSS\', '
        'second_weight_kg REAL, second_weight_type TEXT, net_weight_kg REAL, '
        'vehicle_charge REAL NOT NULL DEFAULT 0, '
        'amount REAL NOT NULL DEFAULT 0, remarks TEXT, '
        'weight_unit TEXT NOT NULL DEFAULT \'ton\', '
        'created_at INTEGER NOT NULL DEFAULT (strftime(\'%s\',\'now\')), '
        'updated_at INTEGER NOT NULL DEFAULT (strftime(\'%s\',\'now\')))',
      );
      await seed.runCustom(
        'CREATE TABLE app_settings ('
        'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
        'weight_unit TEXT NOT NULL DEFAULT \'ton\', '
        'bill_prefix TEXT NOT NULL DEFAULT \'WB\', '
        'bill_starting_number INTEGER NOT NULL DEFAULT 1, '
        'bill_number_digits INTEGER NOT NULL DEFAULT 5, '
        'business_name TEXT NOT NULL DEFAULT \'VIYAN WEIGHBRIDGE\', '
        'business_subtitle TEXT, service_text TEXT, address TEXT, '
        'phone_number TEXT, email TEXT, gstin TEXT, logo_path TEXT, '
        'receipt_title TEXT NOT NULL DEFAULT \'WEIGHMENT RECEIPT\', '
        'show_serial_number INTEGER NOT NULL DEFAULT 1, '
        'show_date INTEGER NOT NULL DEFAULT 1, '
        'show_time INTEGER NOT NULL DEFAULT 1, '
        'show_vehicle_number INTEGER NOT NULL DEFAULT 1, '
        'show_material INTEGER NOT NULL DEFAULT 1, '
        'show_party INTEGER NOT NULL DEFAULT 1, '
        'show_gross_weight INTEGER NOT NULL DEFAULT 1, '
        'show_tare_weight INTEGER NOT NULL DEFAULT 1, '
        'show_net_weight INTEGER NOT NULL DEFAULT 1, '
        'show_amount INTEGER NOT NULL DEFAULT 1, '
        'show_payment_mode INTEGER NOT NULL DEFAULT 1, '
        'show_cash_received INTEGER NOT NULL DEFAULT 1, '
        'show_remarks INTEGER NOT NULL DEFAULT 1, '
        'show_footer_note INTEGER NOT NULL DEFAULT 1, '
        'footer_note TEXT, updated_at INTEGER NOT NULL)',
      );
      await seed.runCustom(
        'INSERT INTO customers (id, name, customer_code, is_active, '
        'created_at, updated_at) VALUES (1, \'Acme\', \'C-001\', 1, ?, ?)',
        [now, now],
      );
      await seed.runCustom(
        'INSERT INTO materials (id, name, code, is_active, created_at, '
        'updated_at) VALUES (1, \'Cement\', \'M-1\', 1, ?, ?)',
        [now, now],
      );
      await seed.runCustom(
        'INSERT INTO weighments (bill_number, customer_id, vehicle_number, '
        'material_id, payment_mode, first_weight_kg, weight_unit, created_at, '
        'updated_at) VALUES (\'WB-00001\', 1, \'MH12AB1234\', 1, \'cash\', '
        '5000.0, \'kg\', ?, ?)',
        [now, now],
      );
      await seed.runCustom('PRAGMA user_version = 23');
      await seed.close();

      final migrated = AppDatabase.forTesting(NativeDatabase(file));
      addTearDown(migrated.close);
      await migrated.customSelect('SELECT 1').get();

      // The pre-existing row survives the full 23 -> 29 upgrade chain.
      final kept = await migrated.billDao.getWeighmentByBillNumber('WB-00001');
      expect(kept, isNotNull);
      expect(kept!.vehicleNumber, 'MH12AB1234');

      final rows = await migrated
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type='index' "
            "AND tbl_name='weighments'",
          )
          .get();
      final names = rows.map((r) => r.read<String>('name')).toSet();
      expect(names, contains('idx_weighments_created_at'));
      // The customer/material modules were removed in v29, so their indexes
      // must never come back.
      expect(names, isNot(contains('idx_weighments_customer_created')));
      expect(names, isNot(contains('idx_weighments_material_created')));

      final version = await migrated.customSelect('PRAGMA user_version').get();
      expect(version.single.data['user_version'], migrated.schemaVersion);
    },
  );

  test('weighments date range query uses the created_at index', () async {
    await withDatabase((db) async {
      final rows = await db
          .customSelect(
            'EXPLAIN QUERY PLAN SELECT id FROM weighments '
            'WHERE created_at >= 1 AND created_at <= 2 '
            'ORDER BY created_at DESC',
          )
          .get();
      final detail = rows.map((r) => r.read<String>('detail')).join(' ');
      expect(detail, contains('idx_weighments_created_at'));
      // The index also supplies the ordering, so no temp b-tree sort.
      expect(detail, isNot(contains('TEMP B-TREE')));
    });
  });

  test('database user_version is set to the schema version', () async {
    await withDatabase((db) async {
      final rows = await db.customSelect('PRAGMA user_version').get();
      expect(rows.single.data['user_version'], db.schemaVersion);
    });
  });

  test('can insert a weighment without customer or material', () async {
    await withDatabase((db) async {
      final id = await seedWeighment(
        db,
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
      await seedWeighment(db, billNumber: 'WB-00001');
      expect(
        () => seedWeighment(db, billNumber: 'WB-00001'),
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

    test(
      'backfills vehicle_number and drops removed modules but restores materials',
      () async {
        final sqlite = await createV14Database();
        final db = AppDatabase.forTesting(sqlite);
        addTearDown(db.close);

        final migrated = await db.billDao.getWeighmentByBillNumber('WB-00001');
        expect(migrated, isNotNull);
        expect(migrated!.vehicleNumber, 'MH12AB1234');

        final orphan = await db.billDao.getWeighmentByBillNumber('WB-00002');
        expect(orphan!.vehicleNumber, 'VEHICLE #99');

        // The genuinely removed masters are dropped. The material master was
        // temporarily removed at v29 but is restored by v33, so it must exist.
        for (final table in [
          'vehicles',
          'vehicle_types',
          'customers',
          'parties',
        ]) {
          final rows = await db
              .customSelect(
                "SELECT name FROM sqlite_master WHERE type='table' AND name = ?",
                variables: [Variable.withString(table)],
              )
              .get();
          expect(rows, isEmpty, reason: 'table $table should be dropped');
        }

        final materialsRows = await db
            .customSelect(
              "SELECT name FROM sqlite_master WHERE type='table' AND name = 'materials'",
            )
            .get();
        expect(materialsRows, isNotEmpty, reason: 'materials master restored');

        final cols = await db
            .customSelect("SELECT name FROM pragma_table_info('weighments')")
            .get();
        final names = cols.map((r) => r.data['name'] as String).toSet();
        expect(names, isNot(contains('vehicle_id')));
        expect(names, isNot(contains('customer_id')));
        // Re-added (nullable) by the v33 migration.
        expect(names, contains('material_id'));
        expect(names, isNot(contains('party_id')));
        expect(names, contains('vehicle_number'));

        final settingsCols = await db
            .customSelect("SELECT name FROM pragma_table_info('app_settings')")
            .get();
        final settingsNames = settingsCols
            .map((r) => r.data['name'] as String)
            .toSet();
        expect(settingsNames, isNot(contains('show_vehicle_type')));
        expect(settingsNames, isNot(contains('show_material')));
        expect(settingsNames, isNot(contains('show_party')));

        final settings = await db.appSettingsDao.getSettings();
        expect(settings.showVehicleNumber, isFalse);

        final version = await db.customSelect('PRAGMA user_version').get();
        expect(version.single.data['user_version'], db.schemaVersion);
      },
    );
  });

  group('v28 -> v29 migration', () {
    /// Builds a real v28 database on disk: weighments still carry
    /// `customer_id`/`material_id`, the customers/materials masters exist, and
    /// app_settings still has the `show_material`/`show_party` toggles.
    Future<NativeDatabase> createV28Database(
      Directory dir,
      String fileName,
    ) async {
      final file = File(p.join(dir.path, fileName));
      final sqlite = NativeDatabase(file);
      await sqlite.ensureOpen(_StubExecutorUser(28));
      final now = DateTime(2026, 10, 1).millisecondsSinceEpoch;

      await sqlite.runCustom(
        'CREATE TABLE customers ('
        'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
        'name TEXT NOT NULL, customer_code TEXT, contact_person TEXT, '
        'mobile TEXT, email TEXT, address TEXT, gst_number TEXT, city TEXT, '
        'state TEXT, is_active INTEGER NOT NULL DEFAULT 1, '
        'created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL)',
      );
      await sqlite.runCustom(
        'CREATE TABLE materials ('
        'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
        'name TEXT NOT NULL, code TEXT NOT NULL DEFAULT \'\', '
        'is_active INTEGER NOT NULL DEFAULT 1, '
        'created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL)',
      );
      // The v28 shape: customer_id NOT NULL, material_id nullable, plus the
      // mobile_number column from v27/v28.
      await sqlite.runCustom(
        'CREATE TABLE weighments ('
        'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
        'bill_number TEXT NOT NULL UNIQUE, '
        'customer_id INTEGER NOT NULL REFERENCES customers(id), '
        'vehicle_number TEXT NOT NULL, '
        'material_id INTEGER REFERENCES materials(id), '
        'first_weight_kg REAL NOT NULL, '
        'first_weight_type TEXT NOT NULL DEFAULT \'GROSS\', '
        'second_weight_kg REAL, second_weight_type TEXT, net_weight_kg REAL, '
        'remarks TEXT, mobile_number TEXT, '
        'weight_unit TEXT NOT NULL DEFAULT \'ton\', '
        'created_at INTEGER NOT NULL DEFAULT (strftime(\'%s\',\'now\')), '
        'updated_at INTEGER NOT NULL DEFAULT (strftime(\'%s\',\'now\')))',
      );
      await sqlite.runCustom(
        'CREATE TABLE app_settings ('
        'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
        'weight_unit TEXT NOT NULL DEFAULT \'ton\', '
        'bill_prefix TEXT NOT NULL DEFAULT \'WB\', '
        'bill_starting_number INTEGER NOT NULL DEFAULT 1, '
        'bill_number_digits INTEGER NOT NULL DEFAULT 5, '
        'business_name TEXT NOT NULL DEFAULT \'VIYAN WEIGHBRIDGE\', '
        'business_subtitle TEXT, service_text TEXT, address TEXT, '
        'phone_number TEXT, email TEXT, gstin TEXT, logo_path TEXT, '
        'receipt_title TEXT NOT NULL DEFAULT \'WEIGHMENT RECEIPT\', '
        'show_serial_number INTEGER NOT NULL DEFAULT 1, '
        'show_date INTEGER NOT NULL DEFAULT 1, '
        'show_time INTEGER NOT NULL DEFAULT 1, '
        'show_vehicle_number INTEGER NOT NULL DEFAULT 1, '
        'show_material INTEGER NOT NULL DEFAULT 1, '
        'show_party INTEGER NOT NULL DEFAULT 1, '
        'show_gross_weight INTEGER NOT NULL DEFAULT 1, '
        'show_tare_weight INTEGER NOT NULL DEFAULT 1, '
        'show_net_weight INTEGER NOT NULL DEFAULT 1, '
        'show_remarks INTEGER NOT NULL DEFAULT 1, '
        'show_footer_note INTEGER NOT NULL DEFAULT 1, '
        'footer_note TEXT, updated_at INTEGER NOT NULL)',
      );
      await sqlite.runCustom(
        'INSERT INTO customers (id, name, customer_code, is_active, '
        'created_at, updated_at) VALUES (1, \'Acme\', \'C-001\', 1, ?, ?)',
        [now, now],
      );
      await sqlite.runCustom(
        'INSERT INTO materials (id, name, code, is_active, created_at, '
        'updated_at) VALUES (1, \'Cement\', \'M-1\', 1, ?, ?)',
        [now, now],
      );
      await sqlite.runCustom(
        'INSERT INTO weighments (id, bill_number, customer_id, '
        'vehicle_number, material_id, first_weight_kg, '
        'first_weight_type, second_weight_kg, net_weight_kg, remarks, '
        'mobile_number, weight_unit, created_at, updated_at) '
        'VALUES (1, \'WB-00001\', 1, \'MH12AB1234\', 1, 5000.0, '
        '\'GROSS\', 2000.0, 3000.0, \'keep me\', \'6381812437\', \'kg\', ?, ?)',
        [now, now],
      );
      await sqlite.runCustom(
        'INSERT INTO weighments (id, bill_number, customer_id, '
        'vehicle_number, material_id, first_weight_kg, '
        'first_weight_type, weight_unit, created_at, updated_at) '
        'VALUES (2, \'WB-00002\', 1, \'MH12AB5678\', NULL, 4200.0, '
        '\'TARE\', \'kg\', ?, ?)',
        [now, now],
      );
      await sqlite.runCustom(
        'INSERT INTO app_settings (id, business_name, show_material, '
        'show_party, show_vehicle_number, updated_at) '
        'VALUES (1, \'Acme Weighbridge\', 0, 0, 1, ?)',
        [now],
      );
      await sqlite.runCustom(
        'CREATE INDEX IF NOT EXISTS idx_weighments_created_at '
        'ON weighments(created_at DESC)',
      );
      await sqlite.runCustom(
        'CREATE INDEX IF NOT EXISTS idx_weighments_customer_created '
        'ON weighments(customer_id, created_at DESC)',
      );
      await sqlite.runCustom(
        'CREATE INDEX IF NOT EXISTS idx_weighments_material_created '
        'ON weighments(material_id, created_at DESC)',
      );
      await sqlite.runCustom('PRAGMA user_version = 28');
      await sqlite.close();

      return NativeDatabase(file);
    }

    test(
      'preserves weighment rows while dropping removed-module columns/tables',
      () async {
        final dir = await Directory.systemTemp.createTemp('wb_v29');
        addTearDown(() => dir.delete(recursive: true));

        final db = AppDatabase.forTesting(await createV28Database(dir, 'a.db'));
        addTearDown(db.close);

        // Both pre-existing rows survive the table rebuild with their
        // vehicle + weight data intact.
        final kept = await db.billDao.getWeighmentByBillNumber('WB-00001');
        expect(kept, isNotNull);
        expect(kept!.vehicleNumber, 'MH12AB1234');
        expect(kept.firstWeightKg, 5000.0);
        expect(kept.secondWeightKg, 2000.0);
        expect(kept.netWeightKg, 3000.0);
        expect(kept.remarks, 'keep me');
        expect(kept.mobileNumber, '6381812437');

        final tareOnly = await db.billDao.getWeighmentByBillNumber('WB-00002');
        expect(tareOnly, isNotNull);
        expect(tareOnly!.vehicleNumber, 'MH12AB5678');
        expect(tareOnly.firstWeightType, 'TARE');

        // The customer relationship is dropped, while material_id is restored
        // (nullable) by the v33 migration.
        final cols = await db
            .customSelect("SELECT * FROM pragma_table_info('weighments')")
            .get();
        final names = cols.map((r) => r.data['name'] as String).toSet();
        expect(names, isNot(contains('customer_id')));
        expect(names, contains('material_id'));
        expect(names, contains('mobile_number'));
        expect(names, contains('remarks'));

        // The removed customer master is dropped, while the material master is
        // restored by v33 (with its new Empty/Load shape).
        for (final table in ['customers']) {
          final rows = await db
              .customSelect(
                "SELECT name FROM sqlite_master WHERE type='table' AND name = ?",
                variables: [Variable.withString(table)],
              )
              .get();
          expect(rows, isEmpty, reason: 'table $table should be dropped');
        }
        final materialsRows = await db
            .customSelect(
              "SELECT name FROM sqlite_master WHERE type='table' AND name = 'materials'",
            )
            .get();
        expect(materialsRows, isNotEmpty, reason: 'materials master restored');

        // The receipt toggles for the removed modules are gone, while the
        // remaining settings values are preserved.
        final settingsCols = await db
            .customSelect("SELECT name FROM pragma_table_info('app_settings')")
            .get();
        final settingsNames = settingsCols
            .map((r) => r.data['name'] as String)
            .toSet();
        expect(settingsNames, isNot(contains('show_material')));
        expect(settingsNames, isNot(contains('show_party')));
        final settings = await db.appSettingsDao.getSettings();
        expect(settings.businessName, 'Acme Weighbridge');
        expect(settings.showVehicleNumber, isTrue);

        // New weighments save without any customer/material reference.
        await db.billDao.insertWeighment(
          WeighmentsCompanion.insert(
            billNumber: 'WB-00003',
            vehicleNumber: 'MH12AB9012',
            firstWeightKg: 10000,
            weightUnit: const Value('kg'),
          ),
        );
        final fresh = await db.billDao.getWeighmentByBillNumber('WB-00003');
        expect(fresh, isNotNull);

        final version = await db.customSelect('PRAGMA user_version').get();
        expect(version.single.data['user_version'], db.schemaVersion);
      },
    );

    test(
      'recreates the unique bill_number constraint after the rebuild',
      () async {
        final dir = await Directory.systemTemp.createTemp('wb_v29_idx');
        addTearDown(() => dir.delete(recursive: true));

        final db = AppDatabase.forTesting(await createV28Database(dir, 'b.db'));
        addTearDown(db.close);

        // Dropping and renaming the table discards its indexes, so a duplicate
        // bill number must still be rejected.
        await expectLater(
          db.billDao.insertWeighment(
            WeighmentsCompanion.insert(
              billNumber: 'WB-00001',
              vehicleNumber: 'MH12AB9999',
              firstWeightKg: 100,
            ),
          ),
          throwsA(anything),
        );
      },
    );

    test('keeps only the created_at query index after the rebuild', () async {
      final dir = await Directory.systemTemp.createTemp('wb_v29_query_idx');
      addTearDown(() => dir.delete(recursive: true));

      final db = AppDatabase.forTesting(await createV28Database(dir, 'c.db'));
      addTearDown(db.close);

      final indexes = await db
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type='index' "
            "AND tbl_name='weighments'",
          )
          .get();
      final names = indexes.map((r) => r.data['name'] as String).toSet();
      expect(names, contains('idx_weighments_created_at'));
      expect(names, isNot(contains('idx_weighments_customer_created')));
      expect(names, isNot(contains('idx_weighments_material_created')));
    });
  });

  group('schema self-repair (beforeOpen)', () {
    /// Builds a database stamped with the CURRENT schema version whose
    /// weighments table is missing the additive columns - the state left
    /// behind when an intermediate build set PRAGMA user_version ahead of
    /// the migration steps (onUpgrade then never runs for such a file).
    Future<NativeDatabase> createStampedButIncompleteDatabase(
      Directory dir,
    ) async {
      final file = File(p.join(dir.path, 'stamped.sqlite'));
      final sqlite = NativeDatabase(file);
      await sqlite.ensureOpen(_StubExecutorUser(35));
      final now = DateTime(2026, 10, 1).millisecondsSinceEpoch;

      // Weighments as an intermediate v29-v31-era build created it: no
      // charges, no material_id, no previous_weighment_id.
      await sqlite.runCustom(
        'CREATE TABLE weighments ('
        'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
        'bill_number TEXT NOT NULL UNIQUE, '
        'vehicle_number TEXT NOT NULL, '
        'first_weight_kg REAL NOT NULL, '
        'first_weight_type TEXT NOT NULL DEFAULT \'GROSS\', '
        'second_weight_kg REAL, second_weight_type TEXT, net_weight_kg REAL, '
        'material TEXT, description TEXT, remarks TEXT, mobile_number TEXT, '
        'weight_unit TEXT NOT NULL DEFAULT \'ton\', '
        'created_at INTEGER NOT NULL DEFAULT (strftime(\'%s\',\'now\')), '
        'updated_at INTEGER NOT NULL DEFAULT (strftime(\'%s\',\'now\')))',
      );
      await sqlite.runCustom(
        'INSERT INTO weighments (id, bill_number, vehicle_number, '
        'first_weight_kg, net_weight_kg, remarks, weight_unit, '
        'created_at, updated_at) VALUES (1, \'WB-00001\', \'MH12AB1234\', '
        '5000.0, 3000.0, \'keep me\', \'kg\', ?, ?)',
        [now, now],
      );
      // app_settings without the schema-34 print columns.
      await sqlite.runCustom(
        'CREATE TABLE app_settings ('
        'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
        'weight_unit TEXT NOT NULL DEFAULT \'ton\', '
        'business_name TEXT NOT NULL DEFAULT \'VIYAN WEIGHBRIDGE\', '
        'updated_at INTEGER NOT NULL)',
      );
      // The file claims it is fully migrated - this is the bug's fingerprint.
      await sqlite.runCustom('PRAGMA user_version = 35');
      await sqlite.close();

      return NativeDatabase(file);
    }

    test(
      'adds missing weighments.charges so Reports queries stop failing',
      () async {
        final dir = await Directory.systemTemp.createTemp('wb_repair');
        addTearDown(() => dir.delete(recursive: true));

        final db = AppDatabase.forTesting(
          await createStampedButIncompleteDatabase(dir),
        );
        addTearDown(db.close);

        // The exact query that threw SQLiteException(1): no such column:
        // weighments.charges before the repair.
        final charges = await db
            .customSelect(
              "SELECT charges FROM weighments WHERE bill_number = 'WB-00001'",
            )
            .get();
        expect(charges.single.data['charges'], isNull);

        // The repaired column matches the declared shape (nullable REAL).
        final cols = await db
            .customSelect("SELECT * FROM pragma_table_info('weighments')")
            .get();
        final chargesCol = cols.firstWhere((r) => r.data['name'] == 'charges');
        expect(chargesCol.data['type'], 'REAL');
        expect(chargesCol.data['notnull'], 0);

        // Other additive columns from the same class of bug are healed too.
        final names = cols.map((r) => r.data['name'] as String).toSet();
        expect(
          names,
          containsAll(<String>['material_id', 'previous_weighment_id']),
        );

        // app_settings print columns are repaired as well.
        final settingsCols = await db
            .customSelect("SELECT name FROM pragma_table_info('app_settings')")
            .get();
        final settingsNames = settingsCols.map((r) => r.read<String>('name'));
        expect(settingsNames, contains('print_cpi'));
        expect(settingsNames, contains('print_field_grid'));

        // Existing rows are preserved and new charges round-trip.
        final kept = await db.billDao.getWeighmentByBillNumber('WB-00001');
        expect(kept, isNotNull);
        expect(kept!.vehicleNumber, 'MH12AB1234');
        expect(kept.remarks, 'keep me');
        await db.billDao.insertWeighment(
          WeighmentsCompanion.insert(
            billNumber: 'WB-00002',
            vehicleNumber: 'MH12AB5678',
            firstWeightKg: 4200,
            charges: const Value(250.5),
            weightUnit: const Value('kg'),
          ),
        );
        final fresh = await db.billDao.getWeighmentByBillNumber('WB-00002');
        expect(fresh!.charges, 250.5);
      },
    );
  });

  group('v31 -> v32 migration', () {
    /// Builds a genuine v31 database on disk: the weighments table has the
    /// free-text `material`/`description` columns but no `charges`.
    Future<NativeDatabase> createV31Database(Directory dir) async {
      final file = File(p.join(dir.path, 'v31.sqlite'));
      final sqlite = NativeDatabase(file);
      await sqlite.ensureOpen(_StubExecutorUser(31));
      final now = DateTime(2026, 10, 1).millisecondsSinceEpoch;

      await sqlite.runCustom(
        'CREATE TABLE weighments ('
        'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
        'bill_number TEXT NOT NULL UNIQUE, '
        'vehicle_number TEXT NOT NULL, '
        'first_weight_kg REAL NOT NULL, '
        'first_weight_type TEXT NOT NULL DEFAULT \'GROSS\', '
        'second_weight_kg REAL, second_weight_type TEXT, net_weight_kg REAL, '
        'material TEXT, description TEXT, remarks TEXT, mobile_number TEXT, '
        'weight_unit TEXT NOT NULL DEFAULT \'ton\', '
        'created_at INTEGER NOT NULL DEFAULT (strftime(\'%s\',\'now\')), '
        'updated_at INTEGER NOT NULL DEFAULT (strftime(\'%s\',\'now\')))',
      );
      await sqlite.runCustom(
        'INSERT INTO weighments (id, bill_number, vehicle_number, '
        'first_weight_kg, first_weight_type, second_weight_kg, '
        'second_weight_type, net_weight_kg, material, remarks, weight_unit, '
        'created_at, updated_at) VALUES (1, \'WB-00001\', \'MH12AB1234\', '
        '5000.0, \'GROSS\', 2000.0, \'TARE\', 3000.0, \'Cement\', '
        '\'keep me\', \'kg\', ?, ?)',
        [now, now],
      );
      await sqlite.runCustom('PRAGMA user_version = 31');
      await sqlite.close();

      return NativeDatabase(file);
    }

    test('adds a nullable charges column and preserves legacy rows', () async {
      final dir = await Directory.systemTemp.createTemp('wb_v32');
      addTearDown(() => dir.delete(recursive: true));

      final db = AppDatabase.forTesting(await createV31Database(dir));
      addTearDown(db.close);

      // The pre-existing row survives with its data intact and a NULL charge.
      final kept = await db.billDao.getWeighmentByBillNumber('WB-00001');
      expect(kept, isNotNull);
      expect(kept!.vehicleNumber, 'MH12AB1234');
      expect(kept.firstWeightKg, 5000.0);
      expect(kept.netWeightKg, 3000.0);
      expect(kept.material, 'Cement');
      expect(kept.remarks, 'keep me');
      expect(kept.charges, isNull);

      // The new column exists and is nullable.
      final cols = await db
          .customSelect("SELECT * FROM pragma_table_info('weighments')")
          .get();
      final names = cols.map((r) => r.data['name'] as String).toSet();
      expect(names, contains('charges'));
      final chargesCol = cols.firstWhere((r) => r.data['name'] == 'charges');
      expect(chargesCol.data['notnull'], 0);

      // New rows can store a charge, and it reads back exactly.
      await db.billDao.insertWeighment(
        WeighmentsCompanion.insert(
          billNumber: 'WB-00002',
          vehicleNumber: 'MH12AB5678',
          firstWeightKg: 4200,
          charges: const Value(250.5),
          weightUnit: const Value('kg'),
        ),
      );
      final fresh = await db.billDao.getWeighmentByBillNumber('WB-00002');
      expect(fresh, isNotNull);
      expect(fresh!.charges, 250.5);

      final version = await db.customSelect('PRAGMA user_version').get();
      expect(version.single.data['user_version'], db.schemaVersion);
    });
  });

  group('v33 -> v34 migration', () {
    /// Builds a genuine v33 database on disk: `app_settings` has every column
    /// of the previous schema but none of the continuous-form print columns.
    Future<NativeDatabase> createV33Database(Directory dir) async {
      final file = File(p.join(dir.path, 'v33.sqlite'));
      final sqlite = NativeDatabase(file);
      await sqlite.ensureOpen(_StubExecutorUser(33));
      final now = DateTime(2026, 10, 1).millisecondsSinceEpoch;

      await sqlite.runCustom(
        'CREATE TABLE app_settings ('
        'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
        'weight_unit TEXT NOT NULL DEFAULT \'ton\', '
        'bill_prefix TEXT NOT NULL DEFAULT \'WB\', '
        'bill_starting_number INTEGER NOT NULL DEFAULT 1, '
        'bill_number_digits INTEGER NOT NULL DEFAULT 5, '
        'business_name TEXT NOT NULL DEFAULT \'VIYAN WEIGHBRIDGE\', '
        'business_subtitle TEXT, service_text TEXT, address TEXT, '
        'phone_number TEXT, email TEXT, gstin TEXT, logo_path TEXT, '
        'receipt_title TEXT NOT NULL DEFAULT \'WEIGHMENT RECEIPT\', '
        'show_serial_number INTEGER NOT NULL DEFAULT 1, '
        'show_date INTEGER NOT NULL DEFAULT 1, '
        'show_time INTEGER NOT NULL DEFAULT 1, '
        'show_vehicle_number INTEGER NOT NULL DEFAULT 1, '
        'show_gross_weight INTEGER NOT NULL DEFAULT 1, '
        'show_tare_weight INTEGER NOT NULL DEFAULT 1, '
        'show_net_weight INTEGER NOT NULL DEFAULT 1, '
        'show_remarks INTEGER NOT NULL DEFAULT 1, '
        'show_footer_note INTEGER NOT NULL DEFAULT 1, '
        'footer_note TEXT, updated_at INTEGER NOT NULL)',
      );
      await sqlite.runCustom(
        'INSERT INTO app_settings (id, business_name, bill_prefix, '
        'footer_note, updated_at) VALUES (1, \'Acme Weighbridge\', \'AC\', '
        '\'keep me\', ?)',
        [now],
      );
      await sqlite.runCustom('PRAGMA user_version = 33');
      await sqlite.close();

      return NativeDatabase(file);
    }

    test(
      'adds the print columns with defaults and keeps the settings row',
      () async {
        final dir = await Directory.systemTemp.createTemp('wb_v34');
        addTearDown(() => dir.delete(recursive: true));

        final db = AppDatabase.forTesting(await createV33Database(dir));
        addTearDown(db.close);

        // Every new column exists on the upgraded table.
        final cols = await db
            .customSelect("SELECT * FROM pragma_table_info('app_settings')")
            .get();
        final names = cols.map((r) => r.data['name'] as String).toSet();
        expect(
          names,
          containsAll(<String>[
            'print_cpi',
            'print_lpi',
            'print_paper_width_mm',
            'print_paper_length_mm',
            'print_left_offset_mm',
            'print_top_offset_mm',
            'print_column_width_mm',
            'print_field_grid',
            'print_weight_unit',
          ]),
        );

        // The pre-existing row survives untouched and reads the defaults:
        // 12 CPI, 6 LPI, printer-reported paper, zero nudges, no grid yet.
        final settings = await db.appSettingsDao.getSettings();
        expect(settings.businessName, 'Acme Weighbridge');
        expect(settings.billPrefix, 'AC');
        expect(settings.footerNote, 'keep me');
        expect(settings.printCpi, 12);
        expect(settings.printLpi, 6);
        expect(settings.printPaperWidthMm, 0.0);
        expect(settings.printPaperLengthMm, 0.0);
        expect(settings.printLeftOffsetMm, 0.0);
        expect(settings.printTopOffsetMm, 0.0);
        expect(settings.printColumnWidthMm, 0.0);
        expect(settings.printFieldGrid, isNull);
        expect(settings.printWeightUnit, isTrue);

        final version = await db.customSelect('PRAGMA user_version').get();
        expect(version.single.data['user_version'], db.schemaVersion);
      },
    );
  });

  group('v34 -> v35 migration', () {
    /// Builds a genuine v34 database on disk: `weighments` has every column
    /// of the previous schema but none of the second-weight columns.
    Future<NativeDatabase> createV34Database(Directory dir) async {
      final file = File(p.join(dir.path, 'v34.sqlite'));
      final sqlite = NativeDatabase(file);
      await sqlite.ensureOpen(_StubExecutorUser(34));
      final now = DateTime(2026, 10, 1).millisecondsSinceEpoch;

      await sqlite.runCustom(
        'CREATE TABLE weighments ('
        'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
        'bill_number TEXT NOT NULL UNIQUE, '
        'vehicle_number TEXT NOT NULL, '
        'first_weight_kg REAL NOT NULL, '
        "first_weight_type TEXT NOT NULL DEFAULT 'GROSS', "
        'second_weight_kg REAL, second_weight_type TEXT, '
        'net_weight_kg REAL, material TEXT, material_id INTEGER, '
        'charges REAL, description TEXT, remarks TEXT, mobile_number TEXT, '
        "weight_unit TEXT NOT NULL DEFAULT 'ton', "
        'created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL)',
      );
      await sqlite.runCustom(
        'INSERT INTO weighments '
        '(bill_number, vehicle_number, first_weight_kg, created_at, '
        'updated_at) VALUES '
        "('WB-00001', 'TN31CM2026', 14710, ?, ?)",
        [now, now],
      );
      await sqlite.runCustom('PRAGMA user_version = 34');
      await sqlite.close();

      return NativeDatabase(file);
    }

    test(
      'adds previous_weighment_id and keeps existing weighment rows intact',
      () async {
        final dir = await Directory.systemTemp.createTemp('wb_v35');
        addTearDown(() => dir.delete(recursive: true));

        final db = AppDatabase.forTesting(await createV34Database(dir));
        addTearDown(db.close);

        // The new column exists on the upgraded table.
        final cols = await db
            .customSelect("SELECT * FROM pragma_table_info('weighments')")
            .get();
        final names = cols.map((r) => r.data['name'] as String).toSet();
        expect(names, contains('previous_weighment_id'));

        // The pre-existing row survives untouched and reads back NULL for
        // the new column: a normal bill has no second-weight link.
        final bill = await db.billDao.getWeighmentByBillNumber('WB-00001');
        expect(bill, isNotNull);
        expect(bill!.vehicleNumber, 'TN31CM2026');
        expect(bill.firstWeightKg, 14710);
        expect(bill.previousWeighmentId, isNull);

        final version = await db.customSelect('PRAGMA user_version').get();
        expect(version.single.data['user_version'], db.schemaVersion);
      },
    );
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
