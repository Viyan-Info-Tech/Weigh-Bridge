import 'package:equatable/equatable.dart';

abstract class PartyEvent extends Equatable {
  const PartyEvent();

  @override
  List<Object?> get props => [];
}

class LoadParties extends PartyEvent {
  final String? searchQuery;
  final bool? filterActive;

  const LoadParties({this.searchQuery, this.filterActive});

  @override
  List<Object?> get props => [searchQuery, filterActive];
}

class LoadPartyDetail extends PartyEvent {
  final int partyId;

  const LoadPartyDetail(this.partyId);

  @override
  List<Object?> get props => [partyId];
}

class CreatePartyRequested extends PartyEvent {
  final String name;
  final String? contactPerson;
  final String? mobile;
  final String? email;
  final String? address;
  final String? gstNumber;
  final String? city;
  final String? state;

  const CreatePartyRequested({
    required this.name,
    this.contactPerson,
    this.mobile,
    this.email,
    this.address,
    this.gstNumber,
    this.city,
    this.state,
  });

  @override
  List<Object?> get props => [
    name,
    contactPerson,
    mobile,
    email,
    address,
    gstNumber,
    city,
    state,
  ];
}

class UpdatePartyRequested extends PartyEvent {
  final int id;
  final String name;
  final String? contactPerson;
  final String? mobile;
  final String? email;
  final String? address;
  final String? gstNumber;
  final String? city;
  final String? state;

  const UpdatePartyRequested({
    required this.id,
    required this.name,
    this.contactPerson,
    this.mobile,
    this.email,
    this.address,
    this.gstNumber,
    this.city,
    this.state,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    contactPerson,
    mobile,
    email,
    address,
    gstNumber,
    city,
    state,
  ];
}

class DeactivatePartyRequested extends PartyEvent {
  final int partyId;

  const DeactivatePartyRequested(this.partyId);

  @override
  List<Object?> get props => [partyId];
}

class DeletePartyRequested extends PartyEvent {
  final int partyId;

  const DeletePartyRequested(this.partyId);

  @override
  List<Object?> get props => [partyId];
}

class SearchParties extends PartyEvent {
  final String query;

  const SearchParties(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterPartiesByStatus extends PartyEvent {
  final bool? isActive;

  const FilterPartiesByStatus(this.isActive);

  @override
  List<Object?> get props => [isActive];
}
