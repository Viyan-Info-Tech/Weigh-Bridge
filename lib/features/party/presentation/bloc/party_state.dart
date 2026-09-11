import 'package:equatable/equatable.dart';

import '../../domain/entities/party.dart';

enum PartyStatus { initial, loading, loaded, error, success }

class PartyState extends Equatable {
  final PartyStatus status;
  final List<Party> parties;
  final Party? selectedParty;
  final int totalParties;
  final int activeParties;
  final int inactiveParties;
  final String? errorMessage;
  final String? successMessage;
  final String? searchQuery;
  final bool? filterActive;

  const PartyState({
    this.status = PartyStatus.initial,
    this.parties = const [],
    this.selectedParty,
    this.totalParties = 0,
    this.activeParties = 0,
    this.inactiveParties = 0,
    this.errorMessage,
    this.successMessage,
    this.searchQuery,
    this.filterActive,
  });

  PartyState copyWith({
    PartyStatus? status,
    List<Party>? parties,
    Party? selectedParty,
    int? totalParties,
    int? activeParties,
    int? inactiveParties,
    String? errorMessage,
    String? successMessage,
    String? searchQuery,
    bool? filterActive,
  }) {
    return PartyState(
      status: status ?? this.status,
      parties: parties ?? this.parties,
      selectedParty: selectedParty ?? this.selectedParty,
      totalParties: totalParties ?? this.totalParties,
      activeParties: activeParties ?? this.activeParties,
      inactiveParties: inactiveParties ?? this.inactiveParties,
      errorMessage: errorMessage,
      successMessage: successMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      filterActive: filterActive ?? this.filterActive,
    );
  }

  @override
  List<Object?> get props => [status, parties, selectedParty, totalParties, activeParties, inactiveParties, errorMessage, successMessage, searchQuery, filterActive];
}
