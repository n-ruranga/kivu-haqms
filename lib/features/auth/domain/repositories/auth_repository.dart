import 'package:kivu_haqms/features/auth/domain/entities/user_entity.dart';

/// Contract for authentication.

abstract class AuthRepository {
  /// Emits the current user, or null when signed out.
  Stream<UserEntity?> get authStateChanges;

  Future<UserEntity?> getCurrentUser();

  // creates a new account with email and password
  Future<UserEntity> signUp({
    required String email,
    required String password,
    required String displayName,
  });

  //logs in an existing user with email and password
  Future<UserEntity> signIn({
    required String email,
    required String password,
  });

  //logs in/signs up with Google account
  Future<UserEntity> signInWithGoogle();

  //sends a password reset email.
  Future<void> sendPasswordResetEmail(String email);

  Future<void> signOut();
}
