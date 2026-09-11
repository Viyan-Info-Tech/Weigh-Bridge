import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/load_parties.dart';
import '../../domain/usecases/create_party.dart';
import '../../domain/usecases/update_party.dart';
import '../../domain/usecases/deactivate_party.dart';
import '../../domain/usecases/search_parties.dart';
import '../../domain/repositories/party_repository.dart';
import 'party_event.dart';
import 'party_state.dart';

class PartyBloc extends Bloc<PartyEvent, PartyState> {
  final LoadPartiesUseCase _loadPartiesUseCase;
  final CreatePartyUseCase _createPartyUseCase;
  final UpdatePartyUseCase _updatePartyUseCase;
  final DeactivatePartyUseCase _deactivatePartyUseCase;
  final SearchPartiesUseCase _searchPartiesUseCase;
  final PartyRepository _partyRepository;

  PartyBloc({
    required LoadPartiesUseCase loadPartiesUseCase,
    required CreatePartyUseCase createPartyUseCase,
    required UpdatePartyUseCase updatePartyUseCase,
    required DeactivatePartyUseCase deactivatePartyUseCase,
    required SearchPartiesUseCase searchPartiesUseCase,
    required PartyRepository partyRepository,
  })  : _loadPartiesUseCase = loadPartiesUseCase,
        _createPartyUseCase = createPartyUseCase,
        _updatePartyUseCase = updatePartyUseCase,
        _deactivatePartyUseCase = deactivatePartyUseCase,
        _searchPartiesUseCase = searchPartiesUseCase,
        _partyRepository = partyRepository,
        super(const PartyState()) {
    on<LoadParties>(_onLoadParties);
    on<LoadPartyDetail>(_onLoadPartyDetail);
    on<CreatePartyRequested>(_onCreateParty);
    on<UpdatePartyRequested>(_onUpdateParty);
    on<DeactivatePartyRequested>(_onDeactivateParty);
    on<SearchParties>(_onSearchParties);
    on<FilterPartiesByStatus>(_onFilterByStatus);
  }

  Future<void> _onLoadParties(LoadParties event, Emitter<PartyState> emit) async {
    emit(state.copyWith(status: PartyStatus.loading));
    try {
      final parties = await _loadPartiesUseCase(isActive: event.filterActive);
      final total = await _partyRepository.totalPartyCount();
      final active = await _partyRepository.activePartyCount();
      final inactive = await _partyRepository.inactivePartyCount();
      emit(state.copyWith(
        status: PartyStatus.loaded,
        parties: parties,
        totalParties: total,
        activeParties: active,
        inactiveParties: inactive,
        filterActive: event.filterActive,
      ));
    } catch (e) {
      emit(state.copyWith(status: PartyStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onLoadPartyDetail(LoadPartyDetail event, Emitter<PartyState> emit) async {
    emit(state.copyWith(status: PartyStatus.loading));
    try {
      final party = await _partyRepository.getPartyById(event.partyId);
      emit(state.copyWith(status: PartyStatus.loaded, selectedParty: party));
    } catch (e) {
      emit(state.copyWith(status: PartyStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onCreateParty(CreatePartyRequested event, Emitter<PartyState> emit) async {
    emit(state.copyWith(status: PartyStatus.loading));
    try {
      await _createPartyUseCase(
        name: event.name,
        contactPerson: event.contactPerson,
        mobile: event.mobile,
        email: event.email,
        address: event.address,
        gstNumber: event.gstNumber,
        city: event.city,
        state: event.state,
      );
      emit(state.copyWith(status: PartyStatus.success, successMessage: 'Party created successfully'));
      add(const LoadParties());
    } catch (e) {
      emit(state.copyWith(status: PartyStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onUpdateParty(UpdatePartyRequested event, Emitter<PartyState> emit) async {
    emit(state.copyWith(status: PartyStatus.loading));
    try {
      await _updatePartyUseCase(
        id: event.id,
        name: event.name,
        contactPerson: event.contactPerson,
        mobile: event.mobile,
        email: event.email,
        address: event.address,
        gstNumber: event.gstNumber,
        city: event.city,
        state: event.state,
      );
      emit(state.copyWith(status: PartyStatus.success, successMessage: 'Party updated successfully'));
      add(const LoadParties());
    } catch (e) {
      emit(state.copyWith(status: PartyStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onDeactivateParty(DeactivatePartyRequested event, Emitter<PartyState> emit) async {
    emit(state.copyWith(status: PartyStatus.loading));
    try {
      await _deactivatePartyUseCase(event.partyId);
      emit(state.copyWith(status: PartyStatus.success, successMessage: 'Party deactivated'));
      add(const LoadParties());
    } catch (e) {
      emit(state.copyWith(status: PartyStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onSearchParties(SearchParties event, Emitter<PartyState> emit) async {
    try {
      if (event.query.isEmpty) {
        add(const LoadParties());
        return;
      }
      final parties = await _searchPartiesUseCase(event.query);
      emit(state.copyWith(
        status: PartyStatus.loaded,
        parties: parties,
        searchQuery: event.query,
      ));
    } catch (e) {
      emit(state.copyWith(status: PartyStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onFilterByStatus(FilterPartiesByStatus event, Emitter<PartyState> emit) async {
    add(LoadParties(filterActive: event.isActive));
  }
}
