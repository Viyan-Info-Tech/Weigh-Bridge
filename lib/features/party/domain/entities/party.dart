import 'package:equatable/equatable.dart';

class Party extends Equatable {
  final int id;
  final String name;
  final String? contactPerson;
  final String? mobile;
  final String? email;
  final String? address;
  final String? gstNumber;
  final String? city;
  final String? state;
  final bool isActive;
  final int vehicleCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Party({
    required this.id,
    required this.name,
    this.contactPerson,
    this.mobile,
    this.email,
    this.address,
    this.gstNumber,
    this.city,
    this.state,
    this.isActive = true,
    this.vehicleCount = 0,
    required this.createdAt,
    required this.updatedAt,
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
    isActive,
    vehicleCount,
  ];
}
