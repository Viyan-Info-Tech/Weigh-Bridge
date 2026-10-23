import '../entities/weighment.dart';

abstract class BillRepository {
  Future<int> saveWeighment(Weighment weighment);

  /// Saves a new weighment under a bill number allocated by the database.
  ///
  /// Returns the row id together with the number that was actually stored.
  /// Callers must treat that number as the single source of truth for
  /// display, printing and follow-up saves instead of any number they had
  /// previewed beforehand.
  Future<({int id, String billNumber})> saveWeighmentWithNewBillNumber(
    Weighment weighment,
  );

  Future<void> updateWeighment(int id, Weighment weighment);
  Future<List<Weighment>> getRecentBills({DateTime? date, int? limit});
  Future<List<Weighment>> getRecentBillsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    int? limit,
  });
  Future<Weighment?> getWeighmentById(int id);
  Future<Weighment?> getWeighmentByBillNumber(String billNumber);

  /// Most recent single-weight bill ever saved for [vehicleNumber], or null.
  ///
  /// Used by the SECOND WEIGHT flow to retrieve the previous weighment of a
  /// returning truck. Matching is trimmed and case-insensitive; a bill that
  /// already holds both weights is complete and is never returned.
  Future<Weighment?> getLatestSingleWeightWeighmentForVehicle(
    String vehicleNumber,
  );

  /// Previews the bill number the next new weighment would receive. Does not
  /// reserve it; only [saveWeighmentWithNewBillNumber] consumes a number.
  Future<String> generateNextBillNumber();

  Future<int> deleteWeighment(int id);
}
