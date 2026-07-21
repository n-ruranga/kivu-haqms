import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kivu_haqms/features/auth/domain/entities/user_entity.dart';
import 'package:kivu_haqms/features/auth/domain/repositories/auth_repository.dart';
import 'package:kivu_haqms/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:kivu_haqms/features/auth/presentation/cubit/auth_state.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepository;

  const testUser = UserEntity(
    id: 'test-uid',
    displayName: 'Test User',
    email: 'test@kivu.com',
  );

  setUp(() {
    mockRepository = MockAuthRepository();
    when(() => mockRepository.authStateChanges)
        .thenAnswer((_) => const Stream.empty());
  });

  group('AuthCubit', () {
    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when checkAuthStatus finds a saved session',
      setUp: () {
        when(() => mockRepository.getCurrentUser())
            .thenAnswer((_) async => testUser);
      },
      build: () => AuthCubit(
        mockRepository,
        splashMinDuration: Duration.zero,
        autoCheckAuthStatus: false,
      ),
      act: (cubit) => cubit.checkAuthStatus(),
      expect: () => [
        const AuthLoading(),
        const AuthAuthenticated(testUser),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] when checkAuthStatus finds no session',
      setUp: () {
        when(() => mockRepository.getCurrentUser())
            .thenAnswer((_) async => null);
      },
      build: () => AuthCubit(
        mockRepository,
        splashMinDuration: Duration.zero,
        autoCheckAuthStatus: false,
      ),
      act: (cubit) => cubit.checkAuthStatus(),
      expect: () => [
        const AuthLoading(),
        const AuthUnauthenticated(),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] on successful signIn',
      setUp: () {
        when(() => mockRepository.signIn(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => testUser);
      },
      build: () => AuthCubit(
        mockRepository,
        splashMinDuration: Duration.zero,
        autoCheckAuthStatus: false,
      ),
      act: (cubit) => cubit.signIn(email: 'test@kivu.com', password: 'password123'),
      expect: () => [
        const AuthLoading(),
        const AuthAuthenticated(testUser),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthFailure] when signIn throws',
      setUp: () {
        when(() => mockRepository.signIn(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenThrow(Exception('Incorrect email or password.'));
      },
      build: () => AuthCubit(
        mockRepository,
        splashMinDuration: Duration.zero,
        autoCheckAuthStatus: false,
      ),
      act: (cubit) => cubit.signIn(email: 'wrong@kivu.com', password: 'bad'),
      expect: () => [
        const AuthLoading(),
        isA<AuthFailure>(),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] on signOut',
      setUp: () {
        when(() => mockRepository.signOut()).thenAnswer((_) async {});
      },
      build: () => AuthCubit(
        mockRepository,
        splashMinDuration: Duration.zero,
        autoCheckAuthStatus: false,
      ),
      act: (cubit) => cubit.signOut(),
      expect: () => [
        const AuthLoading(),
        const AuthUnauthenticated(),
      ],
    );
  });
}