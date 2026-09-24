import 'package:drift/drift.dart';

import 'charge_vehicle_types_table.dart';

class WeighmentRates extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get vehicleTypeId => integer().references(ChargeVehicleTypes, #id)();
  TextColumn get rateType => text()();
  RealColumn get weightLimit => real().nullable()();
  RealColumn get amount => real()();
}
