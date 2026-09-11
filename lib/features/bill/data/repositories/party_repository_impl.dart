import '../datasources/party_local_datasource.dart';
import '../../domain/entities/party.dart';
import '../../domain/repositories/party_repository.dart';

class PartyRepositoryImpl implements PartyRepository {
  final PartyLocalDataSource _localDataSource;

  PartyRepositoryImpl({required PartyLocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  @override
  Future<List<Party>> getActiveParties() async {
    return _localDataSource.getAllActiveParties();
  }

  @override
  Future<Party?> getPartyById(int id) async {
    return _localDataSource.getPartyById(id);
  }

  @override
  Future<List<Party>> searchParties(String query) async {
    return _localDataSource.searchParties(query);
  }
}
