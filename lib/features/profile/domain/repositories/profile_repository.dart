import 'package:kivu_haqms/features/auth/domain/entities/user_entity.dart';
import 'package:kivu_haqms/features/profile/domain/entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<ProfileEntity> getProfile(UserEntity authUser);

  Future<ProfileEntity> updateProfile(ProfileEntity profile);

  Future<ProfileEntity> updatePreferences({
    required String userId,
    bool? pushNotificationsEnabled,
    bool? appointmentRemindersEnabled,
  });
}
