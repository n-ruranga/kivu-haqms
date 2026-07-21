import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kivu_haqms/features/auth/domain/entities/user_entity.dart';
import 'package:kivu_haqms/features/auth/domain/repositories/auth_repository.dart';
import 'package:kivu_haqms/features/auth/presentation/cubit/auth_state.dart';

/// Owns auth UI state. Pages call methods; they never talk to Firebase directly.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository, {Duration? splashMinDuration, bool autoCheckAuthStatus = true,})
      : _splashMinDuration = splashMinDuration ?? const Duration(seconds: 5),
        super(const AuthInitial()){
          _subscription = _repository.authStateChanges.listen(_onAuthChanged);
          if (autoCheckAuthStatus){
            scheduleMicrotask(checkAuthStatus);
          }
        }

  final AuthRepository _repository;
  final Duration _splashMinDuration;
  StreamSubscription<UserEntity?>? _subscription;

  Future<void> checkAuthStatus() async {
    emit(const AuthLoading());
    try {
      final results = await Future.wait([
        _repository.getCurrentUser(),
        Future.delayed(_splashMinDuration),
      ]);

      final user = results[0] as UserEntity?;
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

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async{
    emit(const AuthLoading());
    try{
      final user = await _repository.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
      emit(AuthAuthenticated(user));
    } catch (e){
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async{
    emit(const AuthLoading());
    try{
      final user = await _repository.signIn(email: email, password: password);
      emit(AuthAuthenticated(user));
    } catch (e){
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> signInWithGoogle() async{
    emit(const AuthLoading());
    try{
      final user = await _repository.signInWithGoogle();
      emit(AuthAuthenticated(user));
    } catch (e){
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> sendPasswordResetEmail(String email) async{
    try{
      await _repository.sendPasswordResetEmail(email);
    } catch (e){
      emit(AuthFailure(e.toString()));
    }
  }
}
