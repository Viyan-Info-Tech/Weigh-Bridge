import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class IsAuthenticatedUseCase {
  final AuthRepository _repository;

  IsAuthenticatedUseCase(this._repository);

  Future<Either<Failure, bool>> call() {
    return _repository.isAuthenticated();
  }
}
