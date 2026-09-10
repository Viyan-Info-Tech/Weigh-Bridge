import '../entities/party.dart';

abstract class PartyRepository {
  Future<List<Party>> getActiveParties();
  Future<Party?> getPartyById(int id);
  Future<List<Party>> searchParties(String query);
}
