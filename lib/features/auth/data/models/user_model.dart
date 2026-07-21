import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:kivu_haqms/features/auth/domain/entities/user_entity.dart';

// map firebase user into UserEntity
class UserModel extends UserEntity{
  const UserModel({
    required super.id,
    required super.displayName,
    super.email,
    super.phoneNumber,
  });

  factory UserModel.fromFirebaseUser(fb.User user){
    return UserModel(
      id: user.uid,
      displayName: user.displayName ?? user.email?.split('@').first ?? 'User',
      email: user.email,
      phoneNumber: user.phoneNumber,
    );
  }
}
