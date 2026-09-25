import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/customer.dart';
import '../../domain/usecases/load_customers.dart';
import '../../domain/usecases/create_customer.dart';
import '../../domain/usecases/update_customer.dart';
import '../../domain/usecases/deactivate_customer.dart';
import '../../domain/usecases/delete_customer.dart';
import '../../domain/usecases/search_customers.dart';
import '../../domain/repositories/customer_repository.dart';
import 'customer_event.dart';
import 'customer_state.dart';

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final LoadCustomersUseCase _loadCustomersUseCase;
  final CreateCustomerUseCase _createCustomerUseCase;
  final UpdateCustomerUseCase _updateCustomerUseCase;
  final DeactivateCustomerUseCase _deactivateCustomerUseCase;
  final DeleteCustomerUseCase _deleteCustomerUseCase;
  final SearchCustomersUseCase _searchCustomersUseCase;
  final CustomerRepository _customerRepository;

  CustomerBloc({
    required LoadCustomersUseCase loadCustomersUseCase,
    required CreateCustomerUseCase createCustomerUseCase,
    required UpdateCustomerUseCase updateCustomerUseCase,
    required DeactivateCustomerUseCase deactivateCustomerUseCase,
    required DeleteCustomerUseCase deleteCustomerUseCase,
    required SearchCustomersUseCase searchCustomersUseCase,
    required CustomerRepository customerRepository,
  }) : _loadCustomersUseCase = loadCustomersUseCase,
       _createCustomerUseCase = createCustomerUseCase,
       _updateCustomerUseCase = updateCustomerUseCase,
       _deactivateCustomerUseCase = deactivateCustomerUseCase,
       _deleteCustomerUseCase = deleteCustomerUseCase,
       _searchCustomersUseCase = searchCustomersUseCase,
       _customerRepository = customerRepository,
       super(const CustomerState()) {
    on<LoadCustomers>(_onLoadCustomers);
    on<LoadCustomerDetail>(_onLoadCustomerDetail);
    on<CreateCustomerRequested>(_onCreateCustomer);
    on<UpdateCustomerRequested>(_onUpdateCustomer);
    on<DeactivateCustomerRequested>(_onDeactivateCustomer);
    on<DeleteCustomerRequested>(_onDeleteCustomer);
    on<SearchCustomers>(_onSearchCustomers);
    on<FilterCustomersByStatus>(_onFilterByStatus);
  }

  Future<Customer?> findCustomerByCode(String code) =>
      _customerRepository.getCustomerByCode(code.trim().toUpperCase());

  Future<Customer?> findCustomerByName(String name) =>
      _customerRepository.getCustomerByName(name.trim());

  Future<void> _onLoadCustomers(
    LoadCustomers event,
    Emitter<CustomerState> emit,
  ) async {
    emit(state.copyWith(status: CustomerStatus.loading));
    try {
      final customers = await _loadCustomersUseCase(
        isActive: event.filterActive,
      );
      final total = await _customerRepository.totalCustomerCount();
      final active = await _customerRepository.activeCustomerCount();
      final inactive = await _customerRepository.inactiveCustomerCount();
      emit(
        state.copyWith(
          status: CustomerStatus.loaded,
          customers: customers,
          totalCustomers: total,
          activeCustomers: active,
          inactiveCustomers: inactive,
          filterActive: event.filterActive,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CustomerStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onLoadCustomerDetail(
    LoadCustomerDetail event,
    Emitter<CustomerState> emit,
  ) async {
    emit(state.copyWith(status: CustomerStatus.loading));
    try {
      final customer = await _customerRepository.getCustomerById(
        event.customerId,
      );
      emit(
        state.copyWith(
          status: CustomerStatus.loaded,
          selectedCustomer: customer,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CustomerStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onCreateCustomer(
    CreateCustomerRequested event,
    Emitter<CustomerState> emit,
  ) async {
    emit(state.copyWith(status: CustomerStatus.loading));
    try {
      await _createCustomerUseCase(
        name: event.name,
        customerCode: event.customerCode,
        contactPerson: event.contactPerson,
        mobile: event.mobile,
        email: event.email,
        address: event.address,
        gstNumber: event.gstNumber,
        city: event.city,
        state: event.state,
      );
      emit(
        state.copyWith(
          status: CustomerStatus.success,
          successMessage: 'Customer created successfully',
        ),
      );
      add(const LoadCustomers());
    } catch (e) {
      emit(
        state.copyWith(
          status: CustomerStatus.error,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onUpdateCustomer(
    UpdateCustomerRequested event,
    Emitter<CustomerState> emit,
  ) async {
    emit(state.copyWith(status: CustomerStatus.loading));
    try {
      await _updateCustomerUseCase(
        id: event.id,
        name: event.name,
        customerCode: event.customerCode,
        contactPerson: event.contactPerson,
        mobile: event.mobile,
        email: event.email,
        address: event.address,
        gstNumber: event.gstNumber,
        city: event.city,
        state: event.state,
      );
      emit(
        state.copyWith(
          status: CustomerStatus.success,
          successMessage: 'Customer updated successfully',
        ),
      );
      add(const LoadCustomers());
    } catch (e) {
      emit(
        state.copyWith(
          status: CustomerStatus.error,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onDeactivateCustomer(
    DeactivateCustomerRequested event,
    Emitter<CustomerState> emit,
  ) async {
    emit(state.copyWith(status: CustomerStatus.loading));
    try {
      await _deactivateCustomerUseCase(event.customerId);
      emit(
        state.copyWith(
          status: CustomerStatus.success,
          successMessage: 'Customer deactivated',
        ),
      );
      add(const LoadCustomers());
    } catch (e) {
      emit(
        state.copyWith(
          status: CustomerStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onDeleteCustomer(
    DeleteCustomerRequested event,
    Emitter<CustomerState> emit,
  ) async {
    emit(state.copyWith(status: CustomerStatus.loading));
    try {
      await _deleteCustomerUseCase(event.customerId);
      emit(
        state.copyWith(
          status: CustomerStatus.success,
          successMessage: 'Customer deleted',
        ),
      );
      add(const LoadCustomers());
    } catch (e) {
      emit(
        state.copyWith(
          status: CustomerStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onSearchCustomers(
    SearchCustomers event,
    Emitter<CustomerState> emit,
  ) async {
    try {
      if (event.query.isEmpty) {
        add(const LoadCustomers());
        return;
      }
      final customers = await _searchCustomersUseCase(event.query);
      emit(
        state.copyWith(
          status: CustomerStatus.loaded,
          customers: customers,
          searchQuery: event.query,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CustomerStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onFilterByStatus(
    FilterCustomersByStatus event,
    Emitter<CustomerState> emit,
  ) async {
    add(LoadCustomers(filterActive: event.isActive));
  }
}
