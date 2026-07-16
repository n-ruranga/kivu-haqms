import 'package:kivu_haqms/features/auth/domain/entities/user_entity.dart';

/// Contract for authentication.
/// Duke: implement this with Firebase Auth (email/password + Google).
abstract class AuthRepository {
  /// Emits the current user, or null when signed out.
  Stream<UserEntity?> get authStateChanges;

  Future<UserEntity?> getCurrentUser();

  /// Temporary stub login used until Firebase Auth is wired.
  Future<UserEntity> signInAsDemoUser();

  Future<void> signOut();
}
