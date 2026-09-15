import 'package:equatable/equatable.dart';

class LocalUserModel extends Equatable {
  final int id;
  final String username;
  final String passwordHash;
  final String role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LocalUserModel({
    required this.id,
    required this.username,
    required this.passwordHash,
    required this.role,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LocalUserModel.fromDrift(dynamic driftUser) {
    return LocalUserModel(
      id: driftUser.id,
      username: driftUser.username,
      passwordHash: driftUser.passwordHash,
      role: driftUser.role,
      isActive: driftUser.isActive,
      createdAt: driftUser.createdAt,
      updatedAt: driftUser.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    username,
    passwordHash,
    role,
    isActive,
    createdAt,
    updatedAt,
  ];
}
