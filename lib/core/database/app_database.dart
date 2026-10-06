import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'daos/user_dao.dart';
import 'daos/customer_dao.dart';
import 'daos/material_dao.dart';
import 'daos/bill_dao.dart';
import 'daos/app_settings_dao.dart';
import 'daos/scale_settings_dao.dart';
import 'daos/auto_tare_settings_dao.dart';
import 'tables/users_table.dart';
import 'tables/customers_table.dart';
import 'tables/materials_table.dart';
import 'tables/weighments_table.dart';
import 'tables/app_settings_table.dart';
import 'tables/charge_vehicle_types_table.dart';
import 'tables/weighment_rates_table.dart';
import 'tables/scale_settings_table.dart';
import 'tables/auto_tare_settings_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Users,
    Customers,
    Materials,
    Weighments,
    AppSettings,
    ChargeVehicleTypes,
    WeighmentRates,
    ScaleSettings,
    AutoTareSettings,
  ],
  daos: [
    UserDao,
    CustomerDao,
    MaterialDao,
    BillDao,
    AppSettingsDao,
    ScaleSettingsDao,
    AutoTareSettingsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 25;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _createAdminCredentialsTable();
      await customStatement(
        'CREATE UNIQUE INDEX materials_name_unique ON materials (lower(trim(name)))',
      );
      await customStatement(
        'CREATE UNIQUE INDEX customers_name_unique ON customers (lower(trim(name)))',
      );
      await _createWeighmentQueryIndexes();
      await _seedWeighmentRates();
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
        // Rename the "parties" domain to "customers". The customers table
        // keeps the same schema as parties; every row is carried over and
        // the party_id foreign key on weighments becomes customer_id.
        await m.createTable(customers);
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

      if (from < 19) {
        await m.createTable(chargeVehicleTypes);
        await m.createTable(weighmentRates);
        await _seedWeighmentRates();
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

      if (from < 23) {
        // Date-based common (platform) tare captured each morning with F3.
        await m.createTable(autoTareSettings);
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
        await customStatement('ALTER TABLE weighments_new RENAME TO weighments');
        // The rebuild discards every index on the old table, including the
        // unique constraint on bill_number that SQLite keeps per-table.
        await customStatement(
          'CREATE UNIQUE INDEX IF NOT EXISTS weighments_bill_number '
          'ON weighments(bill_number)',
        );
        await _createWeighmentQueryIndexes();
      }
    },
  );

  /// Creates the weighments indexes used by the bill list and report queries.
  ///
  /// These are declared as raw statements rather than table annotations
  /// because the composite column order depends on how the filters combine,
  /// and because every upgrade step below 24 rebuilds the weighments table,
  /// which silently drops drift-generated indexes.
  ///
  /// `created_at` is the primary report workload, so it leads on its own and
  /// trails the customer and material composites; that ordering lets SQLite
  /// satisfy both the range filter and the `ORDER BY created_at DESC` from the
  /// index without a temp b-tree sort.
  ///
  /// No index is added for `vehicle_number` or `payment_mode`: the report
  /// filters them with `LIKE '%..%'` and `lower(..) = ..`, neither of which
  /// SQLite can satisfy from a b-tree index.
  Future<void> _createWeighmentQueryIndexes() async {
    await batch((batch) {
      batch.customStatement(
        'CREATE INDEX IF NOT EXISTS idx_weighments_created_at '
        'ON weighments(created_at DESC)',
      );
      batch.customStatement(
        'CREATE INDEX IF NOT EXISTS idx_weighments_customer_created '
        'ON weighments(customer_id, created_at DESC)',
      );
      batch.customStatement(
        'CREATE INDEX IF NOT EXISTS idx_weighments_material_created '
        'ON weighments(material_id, created_at DESC)',
      );
    });
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

  Future<void> _seedWeighmentRates() async {
    const data = <(String, List<(String, double?, double)>)>[
      (
        'Lorry & Mini Lorry - 6 Wheelers',
        [
          ('EMPTY', null, 90),
          ('LOAD', null, 110),
          ('ABOVE_20', 20, 130),
          ('ABOVE_30', 30, 150),
        ],
      ),
      (
        'Tarus',
        [
          ('EMPTY', null, 110),
          ('LOAD', null, 130),
          ('ABOVE_20', 20, 150),
          ('ABOVE_30', 30, 170),
          ('ABOVE_40', 40, 190),
          ('ABOVE_50', 50, 210),
          ('ABOVE_60', 60, 230),
        ],
      ),
      (
        'Tarus Above 10 Wheelers',
        [
          ('EMPTY', null, 120),
          ('LOAD', null, 140),
          ('ABOVE_20', 20, 160),
          ('ABOVE_30', 30, 180),
          ('ABOVE_40', 40, 200),
          ('ABOVE_50', 50, 220),
          ('ABOVE_60', 60, 240),
        ],
      ),
      (
        'Trailers',
        [
          ('EMPTY', null, 130),
          ('LOAD', null, 150),
          ('ABOVE_20', 20, 170),
          ('ABOVE_30', 30, 190),
          ('ABOVE_40', 40, 220),
          ('ABOVE_50', 50, 240),
          ('ABOVE_60', 60, 260),
        ],
      ),
      (
        'Multi Axel Trailer',
        [
          ('EMPTY', null, 180),
          ('LOAD', null, 260),
          ('ABOVE_20', 20, 280),
          ('ABOVE_30', 30, 300),
          ('ABOVE_40', 40, 320),
          ('ABOVE_50', 50, 340),
          ('ABOVE_60', 60, 360),
        ],
      ),
      (
        'Van / Mini Van / Bullock Carts / 3&4 Wheelers / Tri-cycle',
        [('EMPTY', null, 80), ('LOAD', null, 90)],
      ),
    ];

    for (final (name, rates) in data) {
      final vehicleTypeId = await into(
        chargeVehicleTypes,
      ).insert(ChargeVehicleTypesCompanion.insert(name: name));
      await batch((batch) {
        batch.insertAll(
          weighmentRates,
          rates.map(
            (rate) => WeighmentRatesCompanion.insert(
              vehicleTypeId: vehicleTypeId,
              rateType: rate.$1,
              weightLimit: Value(rate.$2),
              amount: rate.$3,
            ),
          ),
        );
      });
    }
  }
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
