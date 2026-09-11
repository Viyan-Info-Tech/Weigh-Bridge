import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'daos/user_dao.dart';
import 'daos/party_dao.dart';
import 'daos/vehicle_dao.dart';
import 'daos/material_dao.dart';
import 'daos/bill_dao.dart';
import 'tables/users_table.dart';
import 'tables/parties_table.dart';
import 'tables/vehicles_table.dart';
import 'tables/materials_table.dart';
import 'tables/weighments_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Users,
    Parties,
    Vehicles,
    Materials,
    Weighments,
  ],
  daos: [
    UserDao,
    PartyDao,
    VehicleDao,
    MaterialDao,
    BillDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(parties);
            await m.createTable(vehicles);
            await m.createTable(materials);
            await m.createTable(weighments);
          }
          if (from < 3) {
            // Add new columns to parties table
            await m.addColumn(parties, parties.contactPerson);
            await m.addColumn(parties, parties.email);
            await m.addColumn(parties, parties.city);
            await m.addColumn(parties, parties.state);
            // Add new columns to vehicles table
            await m.addColumn(vehicles, vehicles.driverName);
            await m.addColumn(vehicles, vehicles.driverPhone);
            await m.addColumn(vehicles, vehicles.tareWeight);
            // Add new column to materials table
            await m.addColumn(materials, materials.category);
          }
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'weighbridge.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
