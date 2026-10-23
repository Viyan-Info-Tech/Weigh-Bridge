import 'package:equatable/equatable.dart';

import '../../domain/entities/material_item.dart';

class MaterialState extends Equatable {
  final List<MaterialItem> materials;
  final bool isLoading;
  final String? error;
  final String? successMessage;

  const MaterialState({
    this.materials = const [],
    this.isLoading = false,
    this.error,
    this.successMessage,
  });

  MaterialState copyWith({
    List<MaterialItem>? materials,
    bool? isLoading,
    String? error,
    String? successMessage,
    bool clearError = false,
    bool clearSuccessMessage = false,
  }) {
    return MaterialState(
      materials: materials ?? this.materials,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      successMessage: clearSuccessMessage
          ? null
          : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [materials, isLoading, error, successMessage];
}
