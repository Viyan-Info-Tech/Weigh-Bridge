import '../entities/auto_tare_entry.dart';

abstract class AutoTareRepository {
  /// Auto tare configured for the day containing [date], or null when unset.
  Future<AutoTareEntry?> getAutoTare(DateTime date);

  /// Creates or replaces the auto tare for the day containing [date].
  Future<AutoTareEntry> saveAutoTare({
    required DateTime date,
    required double tareKg,
  });

  /// Removes the auto tare for the day containing [date].
  Future<void> deleteAutoTare(DateTime date);
}
