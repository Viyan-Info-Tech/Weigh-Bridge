import '../../domain/entities/auto_tare_entry.dart';
import '../../domain/repositories/auto_tare_repository.dart';
import '../datasources/auto_tare_local_datasource.dart';

class AutoTareRepositoryImpl implements AutoTareRepository {
  final AutoTareLocalDataSource localDataSource;

  AutoTareRepositoryImpl(this.localDataSource);

  @override
  Future<AutoTareEntry?> getAutoTare(DateTime date) =>
      localDataSource.getAutoTare(date);

  @override
  Future<AutoTareEntry> saveAutoTare({
    required DateTime date,
    required double tareKg,
    DateTime? savedAt,
  }) {
    return localDataSource.saveAutoTare(
      date: date,
      tareKg: tareKg,
      savedAt: savedAt,
    );
  }

  @override
  Future<void> deleteAutoTare(DateTime date) =>
      localDataSource.deleteAutoTare(date);
}
