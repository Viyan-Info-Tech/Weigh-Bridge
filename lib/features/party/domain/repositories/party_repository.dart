import '../entities/party.dart';

abstract class PartyRepository {
  Future<List<Party>> getAllParties();
  Future<List<Party>> getAllActiveParties();
  Future<List<Party>> getPartiesByStatus({required bool isActive});
  Future<Party?> getPartyById(int id);
  Future<int> createParty({
    required String name,
    String? contactPerson,
    String? mobile,
    String? email,
    String? address,
    String? gstNumber,
    String? city,
    String? state,
  });
  Future<bool> updateParty({
    required int id,
    required String name,
    String? contactPerson,
    String? mobile,
    String? email,
    String? address,
    String? gstNumber,
    String? city,
    String? state,
  });
  Future<void> deactivateParty(int id);
  Future<void> deleteParty(int id);
  Future<List<Party>> searchParties(String query);
  Future<int> totalPartyCount();
  Future<int> activePartyCount();
  Future<int> inactivePartyCount();
}
