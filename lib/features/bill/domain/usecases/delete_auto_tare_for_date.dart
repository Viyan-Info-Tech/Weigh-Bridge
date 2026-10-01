import '../repositories/auto_tare_repository.dart';

/// Clears the auto tare for a day. Bills already saved keep their own tare.
class DeleteAutoTareForDate {
  final AutoTareRepository repository;

  DeleteAutoTareForDate(this.repository);

  Future<void> call(DateTime date) => repository.deleteAutoTare(date);
}
