import 'package:equatable/equatable.dart';

class Party extends Equatable {
  final int id;
  final String name;
  final String? mobile;
  final String? address;
  final String? gstNumber;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Party({
    required this.id,
    required this.name,
    this.mobile,
    this.address,
    this.gstNumber,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, name, mobile, address, gstNumber, isActive];
}
