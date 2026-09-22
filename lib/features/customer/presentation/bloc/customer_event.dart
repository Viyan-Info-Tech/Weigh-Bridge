import 'package:equatable/equatable.dart';

abstract class CustomerEvent extends Equatable {
  const CustomerEvent();

  @override
  List<Object?> get props => [];
}

class LoadCustomers extends CustomerEvent {
  final String? searchQuery;
  final bool? filterActive;

  const LoadCustomers({this.searchQuery, this.filterActive});

  @override
  List<Object?> get props => [searchQuery, filterActive];
}

class LoadCustomerDetail extends CustomerEvent {
  final int customerId;

  const LoadCustomerDetail(this.customerId);

  @override
  List<Object?> get props => [customerId];
}

class CreateCustomerRequested extends CustomerEvent {
  final String name;
  final String? contactPerson;
  final String? mobile;
  final String? email;
  final String? address;
  final String? gstNumber;
  final String? city;
  final String? state;

  const CreateCustomerRequested({
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

class UpdateCustomerRequested extends CustomerEvent {
  final int id;
  final String name;
  final String? contactPerson;
  final String? mobile;
  final String? email;
  final String? address;
  final String? gstNumber;
  final String? city;
  final String? state;

  const UpdateCustomerRequested({
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

class DeactivateCustomerRequested extends CustomerEvent {
  final int customerId;

  const DeactivateCustomerRequested(this.customerId);

  @override
  List<Object?> get props => [customerId];
}

class DeleteCustomerRequested extends CustomerEvent {
  final int customerId;

  const DeleteCustomerRequested(this.customerId);

  @override
  List<Object?> get props => [customerId];
}

class SearchCustomers extends CustomerEvent {
  final String query;

  const SearchCustomers(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterCustomersByStatus extends CustomerEvent {
  final bool? isActive;

  const FilterCustomersByStatus(this.isActive);

  @override
  List<Object?> get props => [isActive];
}
