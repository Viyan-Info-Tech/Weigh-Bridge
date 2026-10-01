import '../entities/auto_tare_entry.dart';
import '../repositories/auto_tare_repository.dart';

/// Stores the common tare for a day, replacing any previous value for it.
class SaveAutoTareForDate {
  final AutoTareRepository repository;

  SaveAutoTareForDate(this.repository);

  Future<AutoTareEntry> call({required DateTime date, required double tareKg}) {
    return repository.saveAutoTare(date: date, tareKg: tareKg);
  }
}
