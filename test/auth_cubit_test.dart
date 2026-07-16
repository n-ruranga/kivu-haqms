import 'package:flutter_test/flutter_test.dart';
import 'package:kivu_haqms/features/auth/data/repositories/stub_auth_repository.dart';
import 'package:kivu_haqms/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:kivu_haqms/features/auth/presentation/cubit/auth_state.dart';

void main() {
  late StubAuthRepository repository;
  late AuthCubit cubit;

  setUp(() {
    repository = StubAuthRepository();
    cubit = AuthCubit(repository);
  });

  tearDown(() async {
    await cubit.close();
  });

  test('starts unauthenticated when no session exists', () async {
    await pumpEventQueue();
    expect(cubit.state, isA<AuthUnauthenticated>());
  });

  test('completeDemoLogin emits AuthAuthenticated', () async {
    await cubit.completeDemoLogin();
    expect(cubit.state, isA<AuthAuthenticated>());
    final state = cubit.state as AuthAuthenticated;
    expect(state.user.displayName, 'Jean');
  });

  test('signOut emits AuthUnauthenticated', () async {
    await cubit.completeDemoLogin();
    await cubit.signOut();
    expect(cubit.state, isA<AuthUnauthenticated>());
  });
}
