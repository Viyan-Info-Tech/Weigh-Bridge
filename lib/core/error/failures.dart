sealed class Failure {
  const Failure();
}

class AuthenticationFailure extends Failure {
  final String message;
  const AuthenticationFailure({this.message = 'Invalid username or password'});
}

class DatabaseFailure extends Failure {
  final String message;
  const DatabaseFailure({this.message = 'Something went wrong. Please try again.'});
}

class SessionFailure extends Failure {
  final String message;
  const SessionFailure({this.message = 'Session error occurred.'});
}

class ValidationFailure extends Failure {
  final String message;
  const ValidationFailure({required this.message});
}

class UnknownFailure extends Failure {
  final String message;
  const UnknownFailure({this.message = 'An unexpected error occurred.'});
}
