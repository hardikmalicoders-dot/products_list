import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:products_list/bloc/auth/auth_bloc.dart';
import 'package:products_list/bloc/auth/auth_event.dart';
import 'package:products_list/bloc/auth/auth_state.dart';
import 'package:products_list/data/models/auth_response_model.dart';
import 'package:products_list/data/models/user_model.dart';
import 'package:products_list/data/repositories/auth_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late User testUser;
  late AuthResponse testAuthResponse;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    testUser = User(
      id: 1,
      username: 'emilys',
      email: 'emily@example.com',
      firstName: 'Emily',
      lastName: 'Johnson',
      gender: 'female',
      image: 'https://example.com/image.png',
    );
    testAuthResponse = AuthResponse(
      user: testUser,
      accessToken: 'test_access_token',
      refreshToken: 'test_refresh_token',
    );
  });

  group('AuthBloc', () {
    test('initial state is AuthInitial', () {
      final authBloc = AuthBloc(authRepository: mockAuthRepository);
      expect(authBloc.state, equals(const AuthInitial()));
      authBloc.close();
    });

    blocTest<AuthBloc, AuthState>(
      'emits [AuthAuthenticated] when token and saved user exist on AuthCheckRequested',
      build: () {
        when(() => mockAuthRepository.getAccessToken())
            .thenAnswer((_) async => 'valid_token');
        when(() => mockAuthRepository.getSavedUser())
            .thenAnswer((_) async => testUser);
        return AuthBloc(authRepository: mockAuthRepository);
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [
        AuthAuthenticated(user: testUser, accessToken: 'valid_token'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthUnauthenticated] when no saved token exists on AuthCheckRequested',
      build: () {
        when(() => mockAuthRepository.getAccessToken())
            .thenAnswer((_) async => null);
        return AuthBloc(authRepository: mockAuthRepository);
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [
        const AuthUnauthenticated(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when login succeeds',
      build: () {
        when(() => mockAuthRepository.login(
              username: 'emilys',
              password: 'emilyspass',
            )).thenAnswer((_) async => testAuthResponse);
        return AuthBloc(authRepository: mockAuthRepository);
      },
      act: (bloc) => bloc.add(const AuthLoginRequested(
        username: 'emilys',
        password: 'emilyspass',
      )),
      expect: () => [
        const AuthLoading(),
        AuthAuthenticated(user: testUser, accessToken: 'test_access_token'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] when login fails',
      build: () {
        when(() => mockAuthRepository.login(
              username: 'wrong',
              password: 'wrong',
            )).thenThrow(Exception('Invalid credentials'));
        return AuthBloc(authRepository: mockAuthRepository);
      },
      act: (bloc) => bloc.add(const AuthLoginRequested(
        username: 'wrong',
        password: 'wrong',
      )),
      expect: () => [
        const AuthLoading(),
        const AuthUnauthenticated(errorMessage: 'Exception: Invalid credentials'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthUnauthenticated] when AuthErrorCleared is dispatched',
      build: () => AuthBloc(authRepository: mockAuthRepository),
      act: (bloc) => bloc.add(const AuthErrorCleared()),
      expect: () => [
        const AuthUnauthenticated(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthUnauthenticated] and calls logout on AuthLogoutRequested',
      build: () {
        when(() => mockAuthRepository.logout()).thenAnswer((_) async {});
        return AuthBloc(authRepository: mockAuthRepository);
      },
      act: (bloc) => bloc.add(const AuthLogoutRequested()),
      expect: () => [
        const AuthUnauthenticated(),
      ],
      verify: (_) {
        verify(() => mockAuthRepository.logout()).called(1);
      },
    );
  });
}
