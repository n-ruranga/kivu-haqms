import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kivu_haqms/features/auth/domain/entities/user_entity.dart';
import 'package:kivu_haqms/features/auth/domain/repositories/auth_repository.dart';
import 'package:kivu_haqms/features/auth/presentation/cubit/auth_state.dart';

/// Owns auth UI state. Pages call methods; they never talk to Firebase directly.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthInitial()) {
    _subscription = _repository.authStateChanges.listen(_onAuthChanged);
    checkAuthStatus();
  }

  final AuthRepository _repository;
  StreamSubscription<UserEntity?>? _subscription;

  Future<void> checkAuthStatus() async {
    emit(const AuthLoading());
    try {
      final user = await _repository.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
      emit(const AuthUnauthenticated());
    }
  }

  /// Called after OTP / email login succeeds (stub for now).
  Future<void> completeDemoLogin() async {
    emit(const AuthLoading());
    try {
      final user = await _repository.signInAsDemoUser();
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> signOut() async {
    emit(const AuthLoading());
    try {
      await _repository.signOut();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  void _onAuthChanged(UserEntity? user) {
    if (user != null) {
      emit(AuthAuthenticated(user));
    } else if (state is! AuthLoading) {
      emit(const AuthUnauthenticated());
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
