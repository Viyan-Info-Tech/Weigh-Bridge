import 'package:equatable/equatable.dart';

class Customer extends Equatable {
  final int id;
  final String customerCode;
  final String name;
  final String? contactPerson;
  final String? mobile;
  final String? email;
  final String? address;
  final String? gstNumber;
  final String? city;
  final String? state;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Customer({
    required this.id,
    this.customerCode = '',
    required this.name,
    this.contactPerson,
    this.mobile,
    this.email,
    this.address,
    this.gstNumber,
    this.city,
    this.state,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    customerCode,
    name,
    contactPerson,
    mobile,
    email,
    address,
    gstNumber,
    city,
    state,
    isActive,
    createdAt,
    updatedAt,
  ];
}
