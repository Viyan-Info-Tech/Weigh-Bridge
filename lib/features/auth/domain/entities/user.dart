import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String username;
  final String role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.username,
    required this.role,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  User copyWith({
    int? id,
    String? username,
    String? role,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    username,
    role,
    isActive,
    createdAt,
    updatedAt,
  ];
}
