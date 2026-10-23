import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'daos/user_dao.dart';
import 'daos/bill_dao.dart';
import 'daos/material_dao.dart';
import 'daos/app_settings_dao.dart';
import 'daos/scale_settings_dao.dart';
import 'tables/users_table.dart';
import 'tables/weighments_table.dart';
import 'tables/materials_table.dart';
import 'tables/app_settings_table.dart';
import 'tables/scale_settings_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Users, Weighments, Materials, AppSettings, ScaleSettings],
  daos: [UserDao, BillDao, MaterialDao, AppSettingsDao, ScaleSettingsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 35;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _createAdminCredentialsTable();
      await _createWeighmentQueryIndexes();
      await _createMaterialUniqueIndex();
    },
    onUpgrade: (m, from, to) async {
      if (from < 5) {
        await customStatement('''
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
        // Amount column previously added here; removed in schema 26
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
        // Historical schema (v14-era) with show_vehicle_type included; the
        // column is dropped later in the from < 15 step.
        await customStatement('''
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

      if (from < 14) {
        // Remove the Pending workflow: drop the 'status' column from
        // weighments and the 'show_pending_amount' column from app_settings.
        // Existing completed weighment/bill data is preserved.
        await customStatement('''
              CREATE TABLE weighments_new (
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
        await customStatement(
          "INSERT INTO weighments_new (id, bill_number, party_id, vehicle_id, material_id, payment_mode, "
          "first_weight_kg, first_weight_type, second_weight_kg, second_weight_type, net_weight_kg, "
          "vehicle_charge, amount, remarks, weight_unit, created_at, updated_at) "
          "SELECT id, bill_number, party_id, vehicle_id, material_id, payment_mode, "
          "first_weight_kg, COALESCE(first_weight_type, 'GROSS'), second_weight_kg, second_weight_type, "
          "net_weight_kg, COALESCE(vehicle_charge, 0), COALESCE(amount, 0), remarks, "
          "COALESCE(weight_unit, 'ton'), created_at, updated_at FROM weighments",
        );
        await customStatement('DROP TABLE weighments');
        await customStatement(
          'ALTER TABLE weighments_new RENAME TO weighments',
        );

        await customStatement('''
              CREATE TABLE app_settings_new (
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
        await customStatement(
          "INSERT INTO app_settings_new (id, weight_unit, bill_prefix, bill_starting_number, bill_number_digits, "
          "business_name, business_subtitle, service_text, address, phone_number, email, gstin, logo_path, "
          "receipt_title, show_serial_number, show_date, show_time, show_vehicle_number, show_material, "
          "show_party, show_vehicle_type, show_gross_weight, show_tare_weight, show_net_weight, show_amount, "
          "show_payment_mode, show_cash_received, show_remarks, show_footer_note, footer_note, updated_at) "
          "SELECT id, weight_unit, bill_prefix, bill_starting_number, bill_number_digits, "
          "business_name, business_subtitle, service_text, address, phone_number, email, gstin, logo_path, "
          "receipt_title, show_serial_number, show_date, show_time, show_vehicle_number, show_material, "
          "show_party, show_vehicle_type, show_gross_weight, show_tare_weight, show_net_weight, show_amount, "
          "show_payment_mode, show_cash_received, show_remarks, show_footer_note, footer_note, updated_at "
          "FROM app_settings",
        );
        await customStatement('DROP TABLE app_settings');
        await customStatement(
          'ALTER TABLE app_settings_new RENAME TO app_settings',
        );
      }

      if (from < 15) {
        // Replace the vehicle_id foreign key with a direct vehicle_number
        // text column on each weighment. Existing weighment/bill data is
        // preserved; the vehicle number is carried over from the vehicle
        // master when available, otherwise a readable fallback is used.
        await customStatement('''
              CREATE TABLE weighments_new (
                id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
                bill_number TEXT NOT NULL UNIQUE,
                party_id INTEGER NOT NULL REFERENCES parties(id),
                vehicle_number TEXT NOT NULL,
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
        await customStatement(
          "INSERT INTO weighments_new (id, bill_number, party_id, vehicle_number, material_id, payment_mode, "
          "first_weight_kg, first_weight_type, second_weight_kg, second_weight_type, net_weight_kg, "
          "vehicle_charge, amount, remarks, weight_unit, created_at, updated_at) "
          "SELECT w.id, w.bill_number, w.party_id, COALESCE(v.vehicle_number, 'VEHICLE #' || w.vehicle_id), "
          "w.material_id, w.payment_mode, w.first_weight_kg, w.first_weight_type, w.second_weight_kg, "
          "w.second_weight_type, w.net_weight_kg, w.vehicle_charge, w.amount, w.remarks, w.weight_unit, "
          "w.created_at, w.updated_at FROM weighments w LEFT JOIN vehicles v ON v.id = w.vehicle_id",
        );
        await customStatement('DROP TABLE weighments');
        await customStatement(
          'ALTER TABLE weighments_new RENAME TO weighments',
        );

        await customStatement('DROP TABLE vehicles');
        await customStatement('DROP TABLE vehicle_types');

        // Rebuild app_settings without show_vehicle_type.
        await customStatement('''
              CREATE TABLE app_settings_new (
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
        await customStatement(
          "INSERT INTO app_settings_new (id, weight_unit, bill_prefix, bill_starting_number, bill_number_digits, "
          "business_name, business_subtitle, service_text, address, phone_number, email, gstin, logo_path, "
          "receipt_title, show_serial_number, show_date, show_time, show_vehicle_number, show_material, "
          "show_party, show_gross_weight, show_tare_weight, show_net_weight, show_amount, "
          "show_payment_mode, show_cash_received, show_remarks, show_footer_note, footer_note, updated_at) "
          "SELECT id, weight_unit, bill_prefix, bill_starting_number, bill_number_digits, "
          "business_name, business_subtitle, service_text, address, phone_number, email, gstin, logo_path, "
          "receipt_title, show_serial_number, show_date, show_time, show_vehicle_number, show_material, "
          "show_party, show_gross_weight, show_tare_weight, show_net_weight, show_amount, "
          "show_payment_mode, show_cash_received, show_remarks, show_footer_note, footer_note, updated_at "
          "FROM app_settings",
        );
        await customStatement('DROP TABLE app_settings');
        await customStatement(
          'ALTER TABLE app_settings_new RENAME TO app_settings',
        );
      }

      if (from < 16) {
        // Historical rename of the "parties" domain to "customers".
        // The customers table is dropped again in the from < 29 step, which
        // removes the Customer module entirely; this raw statement keeps
        // very old databases (v15 and below) upgradeable without needing
        // the deleted Drift table class.
        await customStatement('''
              CREATE TABLE IF NOT EXISTS customers (
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
        await customStatement(
          "INSERT INTO customers (id, name, contact_person, mobile, email, address, "
          "gst_number, city, state, is_active, created_at, updated_at) "
          "SELECT id, name, contact_person, mobile, email, address, gst_number, "
          "city, state, is_active, created_at, updated_at FROM parties",
        );

        await customStatement('''
              CREATE TABLE weighments_new (
                id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
                bill_number TEXT NOT NULL UNIQUE,
                customer_id INTEGER NOT NULL REFERENCES customers(id),
                vehicle_number TEXT NOT NULL,
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
        await customStatement(
          "INSERT INTO weighments_new (id, bill_number, customer_id, vehicle_number, material_id, payment_mode, "
          "first_weight_kg, first_weight_type, second_weight_kg, second_weight_type, net_weight_kg, "
          "vehicle_charge, amount, remarks, weight_unit, created_at, updated_at) "
          "SELECT id, bill_number, party_id, vehicle_number, material_id, payment_mode, "
          "first_weight_kg, first_weight_type, second_weight_kg, second_weight_type, net_weight_kg, "
          "vehicle_charge, amount, remarks, weight_unit, created_at, updated_at FROM weighments",
        );
        await customStatement('DROP TABLE weighments');
        await customStatement(
          'ALTER TABLE weighments_new RENAME TO weighments',
        );

        await customStatement('DROP TABLE parties');
      }

      if (from < 17) {
        // Replace the material "category" field with a short, unique "code".
        // Existing rows get their id as the initial code (1, 2, 3 ...) so the
        // operator can keep typing quick codes without data loss.
        await customStatement('''
              CREATE TABLE materials_new (
                id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
                code TEXT NOT NULL UNIQUE,
                name TEXT NOT NULL,
                is_active INTEGER NOT NULL DEFAULT 1,
                created_at INTEGER NOT NULL DEFAULT (strftime('%s','now') * 1000),
                updated_at INTEGER NOT NULL DEFAULT (strftime('%s','now') * 1000)
              )
            ''');
        await customStatement(
          "INSERT INTO materials_new (id, code, name, is_active, created_at, updated_at) "
          "SELECT id, CAST(id AS TEXT), name, is_active, "
          "COALESCE(created_at, strftime('%s','now') * 1000), "
          "COALESCE(updated_at, strftime('%s','now') * 1000) FROM materials",
        );
        await customStatement('DROP TABLE materials');
        await customStatement('ALTER TABLE materials_new RENAME TO materials');
      }

      if (from < 18) {
        // SQLite cannot ALTER TABLE to add a UNIQUE column. Add it nullable,
        // seed legacy codes from their stable row ids, then enforce uniqueness.
        final customerColumns = await customSelect(
          "PRAGMA table_info('customers')",
        ).get();
        if (!customerColumns.any(
          (column) => column.read<String>('name') == 'customer_code',
        )) {
          await customStatement(
            'ALTER TABLE customers ADD COLUMN customer_code TEXT',
          );
        }
        await customStatement(
          "UPDATE customers SET customer_code = CAST(id AS TEXT) WHERE customer_code IS NULL",
        );
        await customStatement(
          'CREATE UNIQUE INDEX IF NOT EXISTS customers_customer_code_unique ON customers (customer_code)',
        );
      }

      if (from < 20) {
        // Preserve legacy rows and their bill references while making their
        // previously duplicated names distinct before enforcing uniqueness.
        await customStatement('''
          UPDATE materials
          SET name = substr(name, 1, 80) || ' (duplicate ' || id || ')'
          WHERE id NOT IN (
            SELECT MIN(id) FROM materials GROUP BY lower(trim(name))
          )
        ''');
        await customStatement('''
          UPDATE customers
          SET name = substr(name, 1, 80) || ' (duplicate ' || id || ')'
          WHERE id NOT IN (
            SELECT MIN(id) FROM customers GROUP BY lower(trim(name))
          )
        ''');
        await customStatement(
          'CREATE UNIQUE INDEX materials_name_unique ON materials (lower(trim(name)))',
        );
        await customStatement(
          'CREATE UNIQUE INDEX customers_name_unique ON customers (lower(trim(name)))',
        );
      }

      if (from < 21) {
        await _createAdminCredentialsTable();
      }

      if (from < 22) {
        // Weigh scale serial connection settings. A single default row is
        // created lazily by ScaleSettingsDao.getSettings() on first use.
        await m.createTable(scaleSettings);
      }

      if (from < 24) {
        // Report and bill-list queries scan weighments by date range and sort
        // by created_at, so the table needed indexes outside its unique
        // constraints. This runs last because the earlier rebuild steps
        // (from < 14/15/16) drop and recreate weighments, which discards any
        // index created before them.
        await _createWeighmentQueryIndexes();
      }

      if (from < 25) {
        // A tare-only weighment has no net weight and so no material. SQLite
        // cannot drop a NOT NULL constraint in place, so the table is rebuilt
        // with a nullable material_id and the existing rows are copied across.
        await customStatement('''
              CREATE TABLE weighments_new (
                id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
                bill_number TEXT NOT NULL UNIQUE,
                customer_id INTEGER NOT NULL REFERENCES customers(id),
                vehicle_number TEXT NOT NULL,
                material_id INTEGER REFERENCES materials(id),
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
        await customStatement(
          'INSERT INTO weighments_new (id, bill_number, customer_id, '
          'vehicle_number, material_id, payment_mode, first_weight_kg, '
          'first_weight_type, second_weight_kg, second_weight_type, '
          'net_weight_kg, vehicle_charge, amount, remarks, weight_unit, '
          'created_at, updated_at) '
          'SELECT id, bill_number, customer_id, vehicle_number, material_id, '
          'payment_mode, first_weight_kg, first_weight_type, second_weight_kg, '
          'second_weight_type, net_weight_kg, vehicle_charge, amount, remarks, '
          'weight_unit, created_at, updated_at FROM weighments',
        );
        await customStatement('DROP TABLE weighments');
        await customStatement(
          'ALTER TABLE weighments_new RENAME TO weighments',
        );
        // The rebuild discards every index on the old table, including the
        // unique constraint on bill_number that SQLite keeps per-table.
        await customStatement(
          'CREATE UNIQUE INDEX IF NOT EXISTS weighments_bill_number '
          'ON weighments(bill_number)',
        );
        await _createWeighmentQueryIndexes();
      }

      if (from < 26) {
        await customStatement('DROP TABLE IF EXISTS weighment_rates');
        await customStatement('DROP TABLE IF EXISTS charge_vehicle_types');

        await customStatement('''
              CREATE TABLE weighments_new (
                id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
                bill_number TEXT NOT NULL UNIQUE,
                customer_id INTEGER NOT NULL REFERENCES customers(id),
                vehicle_number TEXT NOT NULL,
                material_id INTEGER REFERENCES materials(id),
                first_weight_kg REAL NOT NULL,
                first_weight_type TEXT NOT NULL DEFAULT 'GROSS',
                second_weight_kg REAL,
                second_weight_type TEXT,
                net_weight_kg REAL,
                remarks TEXT,
                weight_unit TEXT NOT NULL DEFAULT 'ton',
                created_at INTEGER NOT NULL DEFAULT (strftime('%s','now') * 1000),
                updated_at INTEGER NOT NULL DEFAULT (strftime('%s','now') * 1000)
              )
            ''');
        await customStatement(
          'INSERT INTO weighments_new (id, bill_number, customer_id, '
          'vehicle_number, material_id, first_weight_kg, '
          'first_weight_type, second_weight_kg, second_weight_type, '
          'net_weight_kg, remarks, weight_unit, '
          'created_at, updated_at) '
          'SELECT id, bill_number, customer_id, vehicle_number, material_id, '
          'first_weight_kg, first_weight_type, second_weight_kg, '
          'second_weight_type, net_weight_kg, remarks, '
          'weight_unit, created_at, updated_at FROM weighments',
        );
        await customStatement('DROP TABLE weighments');
        await customStatement(
          'ALTER TABLE weighments_new RENAME TO weighments',
        );
        await customStatement(
          'CREATE UNIQUE INDEX IF NOT EXISTS weighments_bill_number '
          'ON weighments(bill_number)',
        );
        await _createWeighmentQueryIndexes();

        await customStatement('''
              CREATE TABLE app_settings_new (
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
                show_gross_weight INTEGER NOT NULL DEFAULT 1,
                show_tare_weight INTEGER NOT NULL DEFAULT 1,
                show_net_weight INTEGER NOT NULL DEFAULT 1,
                show_remarks INTEGER NOT NULL DEFAULT 1,
                show_footer_note INTEGER NOT NULL DEFAULT 1,
                footer_note TEXT,
                updated_at INTEGER NOT NULL DEFAULT (strftime('%s','now') * 1000)
              )
            ''');
        await customStatement(
          'INSERT INTO app_settings_new (id, weight_unit, bill_prefix, '
          'bill_starting_number, bill_number_digits, business_name, '
          'business_subtitle, service_text, address, phone_number, '
          'email, gstin, logo_path, receipt_title, show_serial_number, '
          'show_date, show_time, show_vehicle_number, show_material, '
          'show_party, show_gross_weight, show_tare_weight, '
          'show_net_weight, show_remarks, show_footer_note, footer_note, '
          'updated_at) '
          'SELECT id, weight_unit, bill_prefix, bill_starting_number, '
          'bill_number_digits, business_name, business_subtitle, '
          'service_text, address, phone_number, email, gstin, logo_path, '
          'receipt_title, show_serial_number, show_date, show_time, '
          'show_vehicle_number, show_material, show_party, '
          'show_gross_weight, show_tare_weight, show_net_weight, '
          'show_remarks, show_footer_note, footer_note, updated_at '
          'FROM app_settings',
        );
        await customStatement('DROP TABLE app_settings');
        await customStatement(
          'ALTER TABLE app_settings_new RENAME TO app_settings',
        );
      }

      if (from < 28) {
        final mobileColumn = await customSelect(
          "SELECT \"notnull\" FROM pragma_table_info('weighments') "
          "WHERE name = 'mobile_number'",
        ).getSingleOrNull();

        if (mobileColumn == null) {
          await m.addColumn(weighments, weighments.mobileNumber);
        } else if (mobileColumn.read<int>('notnull') != 0) {
          // Version 27 briefly shipped the field with NOT NULL + a blank
          // default. Rebuild that table so new and existing records can use
          // the intended nullable representation without losing any data.
          await customStatement(
            'ALTER TABLE weighments RENAME TO weighments_mobile_old',
          );
          await m.createTable(weighments);
          await customStatement('''
            INSERT INTO weighments (
              id, bill_number, customer_id, vehicle_number, material_id,
              first_weight_kg, first_weight_type, second_weight_kg,
              second_weight_type, net_weight_kg, remarks, mobile_number,
              weight_unit, created_at, updated_at
            )
            SELECT
              id, bill_number, customer_id, vehicle_number, material_id,
              first_weight_kg, first_weight_type, second_weight_kg,
              second_weight_type, net_weight_kg, remarks,
              NULLIF(mobile_number, ''), weight_unit, created_at, updated_at
            FROM weighments_mobile_old
          ''');
          await customStatement('DROP TABLE weighments_mobile_old');
          await _createWeighmentQueryIndexes();
        }
      }

      if (from < 29) {
        // Complete removal of the Customer and Material modules. Weighment
        // rows are preserved; only the customer/material relationships and
        // their master tables are dropped. Historical customer/material names
        // are intentionally not carried over: the new workflow is
        // vehicle + weights only, and bills/receipts/reports no longer
        // display either concept.
        await customStatement(
          'DROP INDEX IF EXISTS idx_weighments_customer_created',
        );
        await customStatement(
          'DROP INDEX IF EXISTS idx_weighments_material_created',
        );
        await customStatement(
          'DROP INDEX IF EXISTS customers_customer_code_unique',
        );
        await customStatement('DROP INDEX IF EXISTS materials_name_unique');
        await customStatement('DROP INDEX IF EXISTS customers_name_unique');

        await customStatement('''
              CREATE TABLE weighments_new (
                id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
                bill_number TEXT NOT NULL UNIQUE,
                vehicle_number TEXT NOT NULL,
                first_weight_kg REAL NOT NULL,
                first_weight_type TEXT NOT NULL DEFAULT 'GROSS',
                second_weight_kg REAL,
                second_weight_type TEXT,
                net_weight_kg REAL,
                remarks TEXT,
                mobile_number TEXT,
                weight_unit TEXT NOT NULL DEFAULT 'ton',
                created_at INTEGER NOT NULL DEFAULT (strftime('%s','now') * 1000),
                updated_at INTEGER NOT NULL DEFAULT (strftime('%s','now') * 1000)
              )
            ''');
        await customStatement(
          'INSERT INTO weighments_new (id, bill_number, vehicle_number, '
          'first_weight_kg, first_weight_type, second_weight_kg, '
          'second_weight_type, net_weight_kg, remarks, mobile_number, '
          'weight_unit, created_at, updated_at) '
          'SELECT id, bill_number, vehicle_number, first_weight_kg, '
          'first_weight_type, second_weight_kg, second_weight_type, '
          'net_weight_kg, remarks, NULLIF(mobile_number, \'\'), weight_unit, '
          'created_at, updated_at FROM weighments',
        );
        await customStatement('DROP TABLE weighments');
        await customStatement(
          'ALTER TABLE weighments_new RENAME TO weighments',
        );
        await customStatement(
          'CREATE UNIQUE INDEX IF NOT EXISTS weighments_bill_number '
          'ON weighments(bill_number)',
        );
        await _createWeighmentQueryIndexes();

        await customStatement('DROP TABLE IF EXISTS customers');
        await customStatement('DROP TABLE IF EXISTS materials');

        // Receipt visibility toggles for the removed modules.
        final settingsColumns = await customSelect(
          "PRAGMA table_info('app_settings')",
        ).get();
        final settingsNames = settingsColumns
            .map((c) => c.read<String>('name'))
            .toSet();
        if (settingsNames.contains('show_material') ||
            settingsNames.contains('show_party')) {
          await customStatement('''
                CREATE TABLE app_settings_new (
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
                  show_gross_weight INTEGER NOT NULL DEFAULT 1,
                  show_tare_weight INTEGER NOT NULL DEFAULT 1,
                  show_net_weight INTEGER NOT NULL DEFAULT 1,
                  show_remarks INTEGER NOT NULL DEFAULT 1,
                  show_footer_note INTEGER NOT NULL DEFAULT 1,
                  footer_note TEXT,
                  updated_at INTEGER NOT NULL DEFAULT (strftime('%s','now') * 1000)
                )
              ''');
          await customStatement(
            'INSERT INTO app_settings_new (id, weight_unit, bill_prefix, '
            'bill_starting_number, bill_number_digits, business_name, '
            'business_subtitle, service_text, address, phone_number, '
            'email, gstin, logo_path, receipt_title, show_serial_number, '
            'show_date, show_time, show_vehicle_number, show_gross_weight, '
            'show_tare_weight, show_net_weight, show_remarks, '
            'show_footer_note, footer_note, updated_at) '
            'SELECT id, weight_unit, bill_prefix, bill_starting_number, '
            'bill_number_digits, business_name, business_subtitle, '
            'service_text, address, phone_number, email, gstin, logo_path, '
            'receipt_title, show_serial_number, show_date, show_time, '
            'show_vehicle_number, show_gross_weight, show_tare_weight, '
            'show_net_weight, show_remarks, show_footer_note, footer_note, '
            'updated_at FROM app_settings',
          );
          await customStatement('DROP TABLE app_settings');
          await customStatement(
            'ALTER TABLE app_settings_new RENAME TO app_settings',
          );
        }
      }
      if (from < 30) {
        // Free-text Material + Description columns on the weighment record (TL
        // redesign). Nullable ADD COLUMNs so every existing weighment/bill
        // row is preserved; old bills simply read back NULL (shown as empty /
        // omitted on tickets).
        //
        // Note: the Description feature has since been removed from the app.
        // The column is still created here so the migration path matches the
        // declared table schema; the application no longer writes to it and
        // leaves any previously stored value untouched.
        final weighmentColumns = await customSelect(
          "PRAGMA table_info('weighments')",
        ).get();
        final weighmentNames = weighmentColumns
            .map((c) => c.read<String>('name'))
            .toSet();
        if (!weighmentNames.contains('material')) {
          await m.addColumn(weighments, weighments.material);
        }
        if (!weighmentNames.contains('description')) {
          await m.addColumn(weighments, weighments.description);
        }
      }
      if (from < 32) {
        // Manually entered Charges column on the weighment record.
        //
        // Nullable ADD COLUMN so every existing weighment/bill row is
        // preserved; legacy rows simply read back NULL (shown as an empty
        // value in the form and a zero total in reports). Idempotent guard
        // keeps re-runs and partially upgraded databases safe.
        final weighmentColumns = await customSelect(
          "PRAGMA table_info('weighments')",
        ).get();
        final weighmentNames = weighmentColumns
            .map((c) => c.read<String>('name'))
            .toSet();
        if (!weighmentNames.contains('charges')) {
          await m.addColumn(weighments, weighments.charges);
        }
      }
      if (from < 33) {
        // Re-introduction of the Material module as a name + vehicle-type
        // master (Empty/Load). The old materials table was dropped in v29;
        // this creates the new shape from scratch, so no historical material
        // rows are resurrected. Existing weighments keep their free-text
        // `material` snapshot and gain a nullable `material_id` reference
        // column (NULL for legacy rows). Additive only: no weighment rows
        // are touched, rewritten or dropped.
        await m.createTable(materials);
        await _createMaterialUniqueIndex();
        final weighmentColumns = await customSelect(
          "PRAGMA table_info('weighments')",
        ).get();
        final weighmentNames = weighmentColumns
            .map((c) => c.read<String>('name'))
            .toSet();
        if (!weighmentNames.contains('material_id')) {
          await m.addColumn(weighments, weighments.materialId);
        }
      }
      if (from < 35) {
        // SECOND WEIGHT flow: nullable link from a second weighment back to
        // the single-weight bill whose previous weight it reused, so the two
        // independently identifiable bills keep a traceable relationship.
        //
        // Additive only: one nullable column, existing weighment rows are
        // untouched and simply read back NULL. Idempotent guard keeps re-runs
        // and partially upgraded databases safe. Deliberately placed before
        // the v34 step below, whose empty app_settings guard returns early.
        // The table-existence check covers synthetic upgrade fixtures that
        // carry only part of the schema.
        final weighmentColumns = await customSelect(
          "PRAGMA table_info('weighments')",
        ).get();
        final weighmentNames = weighmentColumns
            .map((c) => c.read<String>('name'))
            .toSet();
        if (weighmentColumns.isNotEmpty &&
            !weighmentNames.contains('previous_weighment_id')) {
          await m.addColumn(weighments, weighments.previousWeighmentId);
        }
      }
      if (from < 34) {
        // Continuous-form print alignment settings for the client's
        // pre-printed HMB Enterprises certificate.
        //
        // Additive only: nine nullable/defaulted columns on app_settings, so
        // existing settings rows are untouched and simply read back the
        // defaults (12 CPI, 6 LPI, printer-reported paper, zero nudges).
        // Idempotent guards keep re-runs and partially upgraded databases safe.
        final settingColumns = await customSelect(
          "PRAGMA table_info('app_settings')",
        ).get();
        // No app_settings table means there is no settings row to upgrade
        // (matches the guard style of the v29 rebuild above). This is the last
        // settings upgrade step; the weighments-only v35 step above has
        // already run, so the migration is complete either way.
        if (settingColumns.isEmpty) return;

        final settingNames = settingColumns
            .map((c) => c.read<String>('name'))
            .toSet();

        if (!settingNames.contains('print_cpi')) {
          await m.addColumn(appSettings, appSettings.printCpi);
        }
        if (!settingNames.contains('print_lpi')) {
          await m.addColumn(appSettings, appSettings.printLpi);
        }
        if (!settingNames.contains('print_paper_width_mm')) {
          await m.addColumn(appSettings, appSettings.printPaperWidthMm);
        }
        if (!settingNames.contains('print_paper_length_mm')) {
          await m.addColumn(appSettings, appSettings.printPaperLengthMm);
        }
        if (!settingNames.contains('print_left_offset_mm')) {
          await m.addColumn(appSettings, appSettings.printLeftOffsetMm);
        }
        if (!settingNames.contains('print_top_offset_mm')) {
          await m.addColumn(appSettings, appSettings.printTopOffsetMm);
        }
        if (!settingNames.contains('print_column_width_mm')) {
          await m.addColumn(appSettings, appSettings.printColumnWidthMm);
        }
        if (!settingNames.contains('print_field_grid')) {
          await m.addColumn(appSettings, appSettings.printFieldGrid);
        }
        if (!settingNames.contains('print_weight_unit')) {
          await m.addColumn(appSettings, appSettings.printWeightUnit);
        }
      }
    },
  );

  /// Creates the weighments index used by the bill list and report queries.
  ///
  /// Only `created_at` is indexed: the remaining report filters use
  /// `LIKE '%..%'`, which SQLite cannot satisfy from a b-tree index.
  Future<void> _createWeighmentQueryIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_weighments_created_at '
      'ON weighments(created_at DESC)',
    );
  }

  /// Enforces one row per material name + vehicle-type combination.
  ///
  /// Expression indexes keep the rule case- and whitespace-insensitive
  /// (`Auto - Empty` and `auto  - empty` are the same combination) without
  /// needing generated columns. The DAO performs the same check in Dart so
  /// the operator always gets a readable error instead of a raw SQLite
  /// constraint failure.
  Future<void> _createMaterialUniqueIndex() async {
    await customStatement(
      'CREATE UNIQUE INDEX IF NOT EXISTS materials_name_type_unique '
      'ON materials (lower(trim(name)), lower(trim(vehicle_type)))',
    );
  }

  Future<void> _createAdminCredentialsTable() => customStatement('''
    CREATE TABLE IF NOT EXISTS admin_credentials (
      id INTEGER NOT NULL PRIMARY KEY CHECK (id = 1),
      password_hash TEXT NOT NULL,
      updated_at INTEGER NOT NULL
    )
  ''');

  Future<String?> getAdminPasswordHash() async {
    final row = await customSelect(
      'SELECT password_hash FROM admin_credentials WHERE id = 1',
    ).getSingleOrNull();
    return row?.read<String>('password_hash');
  }

  /// Lightweight health probe used by the app status bar.
  ///
  /// Returns `true` when the connection answers a trivial query and
  /// `false` when the database is missing or broken.
  Future<bool> healthCheck() async {
    try {
      await customSelect('SELECT 1').get();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> saveAdminPasswordHash(String hash) => customStatement(
    'INSERT INTO admin_credentials (id, password_hash, updated_at) '
    'VALUES (1, ?, ?) ON CONFLICT(id) DO UPDATE SET '
    'password_hash = excluded.password_hash, updated_at = excluded.updated_at',
    [hash, DateTime.now().millisecondsSinceEpoch],
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationSupportDirectory();
    final file = File(
      p.join(directory.path, 'Weighbridge', 'weighbridge.sqlite'),
    );

    // On macOS, preserve backward compatibility with legacy path if it exists
    if (Platform.isMacOS && !await file.exists()) {
      final home = Platform.environment['HOME'];
      if (home != null && home.isNotEmpty) {
        final legacyFile = File(
          p.join(
            home,
            'Library',
            'Application Support',
            'Weighbridge',
            'weighbridge.sqlite',
          ),
        );
        if (await legacyFile.exists()) {
          return NativeDatabase.createInBackground(legacyFile);
        }
      }
    }

    if (!await file.parent.exists()) {
      await file.parent.create(recursive: true);
    }

    return NativeDatabase.createInBackground(file);
  });
}
