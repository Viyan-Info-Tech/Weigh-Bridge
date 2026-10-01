import '../entities/auto_tare_entry.dart';
import '../repositories/auto_tare_repository.dart';

class GetAutoTareForDate {
  final AutoTareRepository repository;

  GetAutoTareForDate(this.repository);

  Future<AutoTareEntry?> call(DateTime date) => repository.getAutoTare(date);
}
