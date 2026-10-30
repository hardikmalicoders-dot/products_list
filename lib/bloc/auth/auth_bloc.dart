import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:products_list/data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository(),
        super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthErrorCleared>(_onErrorCleared);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  // Event handlers
  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final token = await _authRepository.getAccessToken();
      if (token != null && token.isNotEmpty) {
        final user = await _authRepository.getSavedUser();
        if (user != null) {
          emit(AuthAuthenticated(user: user, accessToken: token));
          return;
        }
      }
      emit(const AuthUnauthenticated());
    } catch (_) {
      emit(const AuthUnauthenticated());
    }
  }

  //TODO: Implement this method to handle login event
  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final authResponse = await _authRepository.login(
        username: event.username,
        password: event.password,
      );
      emit(AuthAuthenticated(
        user: authResponse.user,
        accessToken: authResponse.accessToken,
      ));
    } catch (e) {
      emit(AuthUnauthenticated(errorMessage: e.toString()));
    }
  }

  // Event handlers
  void _onErrorCleared(
    AuthErrorCleared event,
    Emitter<AuthState> emit,
  ) {
    emit(const AuthUnauthenticated());
  }

  //TODO: Implement this method to handle logout event
  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.logout();
    emit(const AuthUnauthenticated());
  }
}
