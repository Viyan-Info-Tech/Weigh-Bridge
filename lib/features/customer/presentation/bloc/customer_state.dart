import 'package:equatable/equatable.dart';

import '../../domain/entities/customer.dart';

enum CustomerStatus { initial, loading, loaded, error, success }

class CustomerState extends Equatable {
  final CustomerStatus status;
  final List<Customer> customers;
  final Customer? selectedCustomer;
  final int totalCustomers;
  final int activeCustomers;
  final int inactiveCustomers;
  final String? errorMessage;
  final String? successMessage;
  final String? searchQuery;
  final bool? filterActive;

  const CustomerState({
    this.status = CustomerStatus.initial,
    this.customers = const [],
    this.selectedCustomer,
    this.totalCustomers = 0,
    this.activeCustomers = 0,
    this.inactiveCustomers = 0,
    this.errorMessage,
    this.successMessage,
    this.searchQuery,
    this.filterActive,
  });

  CustomerState copyWith({
    CustomerStatus? status,
    List<Customer>? customers,
    Customer? selectedCustomer,
    int? totalCustomers,
    int? activeCustomers,
    int? inactiveCustomers,
    String? errorMessage,
    String? successMessage,
    String? searchQuery,
    bool? filterActive,
  }) {
    return CustomerState(
      status: status ?? this.status,
      customers: customers ?? this.customers,
      selectedCustomer: selectedCustomer ?? this.selectedCustomer,
      totalCustomers: totalCustomers ?? this.totalCustomers,
      activeCustomers: activeCustomers ?? this.activeCustomers,
      inactiveCustomers: inactiveCustomers ?? this.inactiveCustomers,
      errorMessage: errorMessage,
      successMessage: successMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      filterActive: filterActive ?? this.filterActive,
    );
  }

  @override
  List<Object?> get props => [
    status,
    customers,
    selectedCustomer,
    totalCustomers,
    activeCustomers,
    inactiveCustomers,
    errorMessage,
    successMessage,
    searchQuery,
    filterActive,
  ];
}
