import 'dart:async';

import 'package:kivu_haqms/features/auth/domain/entities/user_entity.dart';
import 'package:kivu_haqms/features/auth/domain/repositories/auth_repository.dart';

/// In-memory auth used for navigation while Firebase is not connected yet.
/// Duke: replace this with `FirebaseAuthRepository`.
class StubAuthRepository implements AuthRepository {
  UserEntity? _currentUser;
  final _controller = StreamController<UserEntity?>.broadcast();

  @override
  Stream<UserEntity?> get authStateChanges => _controller.stream;

  @override
  Future<UserEntity?> getCurrentUser() async => _currentUser;

  @override
  Future<UserEntity> signInAsDemoUser() async {
    const user = UserEntity(
      id: 'demo-user',
      displayName: 'Jean',
      phoneNumber: '+250700000000',
    );
    _currentUser = user;
    _controller.add(user);
    return user;
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _controller.add(null);
  }
}
