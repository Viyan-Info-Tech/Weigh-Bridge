import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/is_authenticated.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/logout.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final IsAuthenticatedUseCase _isAuthenticatedUseCase;

  AuthBloc({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required IsAuthenticatedUseCase isAuthenticatedUseCase,
  })  : _loginUseCase = loginUseCase,
        _logoutUseCase = logoutUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _isAuthenticatedUseCase = isAuthenticatedUseCase,
        super(const AuthState()) {
    on<AppStarted>(_onAppStarted);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.checking, clearErrorMessage: true));

    final authResult = await _isAuthenticatedUseCase();
    final isAuth = authResult.fold(
      (failure) => false,
      (authenticated) => authenticated,
    );

    if (!isAuth) {
      emit(state.copyWith(status: AuthStatus.unauthenticated, clearErrorMessage: true));
      return;
    }

    final userResult = await _getCurrentUserUseCase();
    final user = userResult.fold(
      (failure) => null,
      (user) => user,
    );

    if (user != null) {
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        clearErrorMessage: true,
      ));
    } else {
      emit(state.copyWith(status: AuthStatus.unauthenticated, clearErrorMessage: true));
    }
  }

  Future<void> _onLoginSubmitted(LoginSubmitted event, Emitter<AuthState> emit) async {
    if (event.username.trim().isEmpty) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: 'Username is required',
      ));
      return;
    }

    if (event.password.isEmpty) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: 'Password is required',
      ));
      return;
    }

    emit(state.copyWith(status: AuthStatus.authenticating, clearErrorMessage: true));

    final result = await _loginUseCase(event.username, event.password);
    result.fold(
      (failure) {
        final message = switch (failure) {
          AuthenticationFailure() => failure.message,
          DatabaseFailure() => failure.message,
          SessionFailure() => failure.message,
          ValidationFailure() => failure.message,
          UnknownFailure() => failure.message,
        };
        emit(state.copyWith(
          status: AuthStatus.failure,
          errorMessage: message,
        ));
      },
      (user) => emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        clearErrorMessage: true,
      )),
    );
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    await _logoutUseCase();
    emit(state.copyWith(
      status: AuthStatus.unauthenticated,
      user: null,
      clearErrorMessage: true,
    ));
  }
}
