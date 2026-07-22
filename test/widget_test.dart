import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kivu_haqms/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:kivu_haqms/features/auth/presentation/cubit/auth_state.dart';
import 'package:kivu_haqms/features/auth/presentation/pages/login_page.dart';

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  late MockAuthCubit mockAuthCubit;

  setUp(() {
    mockAuthCubit = MockAuthCubit();
    whenListen(
      mockAuthCubit,
      Stream<AuthState>.fromIterable([const AuthUnauthenticated()]),
      initialState: const AuthUnauthenticated(),
    );
  });

  testWidgets('LoginPage shows email, password fields, and a login button',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthCubit>.value(
          value: mockAuthCubit,
          child: const LoginPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
  });
}