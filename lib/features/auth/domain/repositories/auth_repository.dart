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

  //sends sms with otp
  Future<void>verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(String error) onVerificationFailed,
  });

  //complete sign-in using the code the user typed in
  Future<UserEntity> signInWithOtp({
    required String verificationId,
    required String smsCode,
  });
}
