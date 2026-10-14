import '../entities/vehicle_tare_record.dart';

abstract class VehicleTareRepository {
  /// Every stored vehicle tare record, ordered by vehicle number.
  Future<List<VehicleTareRecord>> loadVehicleTares();

  /// Reactive stream of stored vehicle tare records.
  Stream<List<VehicleTareRecord>> watchVehicleTares() => const Stream.empty();

  /// Inserts a new vehicle tare or updates the tare of an existing vehicle.
  ///
  /// Throws [ArgumentError] when the vehicle number is blank or the tare is
  /// not a finite positive weight.
  Future<VehicleTareRecord> saveVehicleTare({
    required String vehicleNumber,
    required double tareKg,
  });

  /// Removes the tare record for [vehicleNumber], if one exists.
  Future<void> deleteVehicleTare(String vehicleNumber);
}

abstract interface class VehicleTareEditableRepository {
  Future<VehicleTareRecord> updateVehicleTare({
    required int id,
    required String vehicleNumber,
    required double tareKg,
  });
}
